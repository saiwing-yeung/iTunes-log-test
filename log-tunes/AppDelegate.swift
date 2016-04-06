//
//  AppDelegate.swift
//  log-tunes
//
//  Created by Saiwing Yeung on 3/31/16.
//  Copyright © 2016 ___SWY___. All rights reserved.
//

import Cocoa

#if DEBUG
	func DLog(msgs: AnyObject...) {
		print(msgs)
	}
#else
	func DLog(msgs: AnyObject...) {
		/* */
	}
#endif


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var statusMenu: NSMenu!
	
	//	iTunes would send a new Playing notification when the user
	//	1) plays a media
	//	2) changes any media attributes of the current playing media
	//	3) unpause a previously paused media
	//	We only want to log in the case of #1
	
	//	Therefore we need to have a mechanism to determine whether a newly received
 	//	 Playing notification is an actual new play.
	//	To do this we keep track of some information of the previously logged media
 	//	 so that the next time we receive a Play notification we can differentiate
	//	 case #1 from #2 and #3.

	//	The two attributes we use are the PersistentID and Play Count.
	static var prevPersistentID: String = ""
	static var prevPlayCount: UInt = 999999

	
	//	func matchesForRegexInText
	//	Used for doing regular expression matches
	//	Taken from: http://stackoverflow.com/a/27880748/461389
	func matchesForRegexInText(regex: String!, text: String!) -> [String] {
		
		do {
			let regex = try NSRegularExpression(pattern: regex, options: [])
			let nsString = text as NSString
			let results = regex.matchesInString(text, options: [],
			                                    range: NSMakeRange(0, nsString.length))
			return results.map { nsString.substringWithRange($0.range)}
		} catch let error as NSError {
			DLog("invalid regex: \(error.localizedDescription)")
			return []
		}
	}
	
	
	//	func logASong
	//	The call back that receives notifications from iTunes
	func logASong(notification: NSNotification) {
		DLog("\n\n#\n# New notification \n#")
		DLog(notification)

		let info = notification.userInfo
		let state = (info!["Player State"] != nil) ? String(info!["Player State"]!).stringByReplacingOccurrencesOfString("\"", withString: "\\\"") : ""
		DLog(state)
		
		
		//	We only proceed if the type of notification is Playing
		if (state == "Playing") {
			
			//	Figure out whether we should log this notification
			let newPersistentID = String(info!["PersistentID"]!)

			DLog("newPersistentID: ", newPersistentID)
			DLog("prevPlayCount: ", AppDelegate.prevPlayCount)
			
			let newPlayCount = UInt(info!["Play Count"]! as! Int)
			
			//	If the PersistentID is different from the previous one (meaning different media file)
			//	 then we always log.
			if (AppDelegate.prevPersistentID == newPersistentID) {
				DLog("Same newPersistentID")
				
				//	If it's the same media, then we log only if the play count has been incremented.
				if (AppDelegate.prevPlayCount == newPlayCount) {
					DLog("Same play count => don't log")
					return
				} else {
					DLog("Play count incremented => log this play")
				}
			} else {
				DLog("Different newPersistentID => log this play")
				AppDelegate.prevPlayCount = newPlayCount
			}

			AppDelegate.prevPersistentID = newPersistentID
			AppDelegate.prevPlayCount = newPlayCount
			
			
			//	We will log this play. Let's get some information about this media.
			let name = (info!["Name"] != nil) ? String(info!["Name"]!).stringByReplacingOccurrencesOfString("\"", withString: "\\\"") : ""
			let artist = (info!["Artist"] != nil) ? String(info!["Artist"]!).stringByReplacingOccurrencesOfString("\"", withString: "\\\"") : ""
			let album = (info!["Album"] != nil) ? String(info!["Album"]!).stringByReplacingOccurrencesOfString("\"", withString: "\\\"") : ""
			let tracknum = (info!["Track Number"] != nil) ? String(info!["Track Number"]!).stringByReplacingOccurrencesOfString("\"", withString: "\\\"") : ""
			let genre = (info!["Genre"] != nil) ? String(info!["Genre"]!).stringByReplacingOccurrencesOfString("\"", withString: "\\\"") : ""
			
			let rating = (info!["Rating"] != nil) ? String(info!["Rating"]!) : ""
			let count = (info!["Play Count"] != nil) ? String(info!["Play Count"]!) : ""
			let length = (info!["elapsedStr"] != nil) ? String(info!["elapsedStr"]!).stringByReplacingOccurrencesOfString("-", withString: "") : ""
			let loc = (info!["Location"] != nil) ? String(info!["Location"]!) : ""

			//	Format the date/time
			let dayTimePeriodFormatter = NSDateFormatter()
			dayTimePeriodFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			let dateFormatted = dayTimePeriodFormatter.stringFromDate(NSDate())
			
			//	We will use part of the path of the media as a proxy of its category (Music, iTunes U, etc.)
			let matches = matchesForRegexInText("(?<=/Music/iTunes/iTunes%20Music/)[^/]+", text: loc)
			var category = ""
			if (matches.count > 0) {
				category = matches[0].stringByReplacingOccurrencesOfString("%20", withString: " ")
			}
			DLog(name, artist, album, genre, category, dateFormatted, length, rating, count, tracknum, state)

			//	Format the line in CSV
			let theLine = "\"" + dateFormatted + "\",\"" + name + "\",\"" + artist + "\",\"" + album + "\",\"" + tracknum + "\",\"" + genre + "\",\"" + category + "\",\"" + length + "\",\"" + rating + "\",\"" + count + "\"\n"
			let lineData = theLine.dataUsingEncoding(NSUTF8StringEncoding)
			
			//	Get the file log location
			let defaults = NSUserDefaults.standardUserDefaults()
			let allPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
			let pathForLog = allPaths.first!.stringByAppendingString("/iTunes-log.csv")
			
			let logLoc = defaults.stringForKey("logLoc") ?? pathForLog
			DLog("logASong) logLoc: ", logLoc)

			//	If the file doesn't exist, create it
			var newFile = false
			if (!NSFileManager.defaultManager().fileExistsAtPath(logLoc)) {
				newFile = true

				if (!NSFileManager.defaultManager().createFileAtPath(logLoc, contents: nil, attributes: nil)) {
					DLog("log-tunes: Error creating file --- ")
				}
			}

			//	Append to the log file
			if let fileHandle = NSFileHandle(forWritingAtPath: logLoc) {
				if (newFile) {
					fileHandle.writeData(NSString(string: "date,name,artist,album,tracknum,genre,category,length,rating,count\n").dataUsingEncoding(NSUTF8StringEncoding)!)
				}
				fileHandle.seekToEndOfFile()
				fileHandle.writeData(lineData!)
				fileHandle.closeFile()
			} else {
				DLog("log-tunes: Error writing to file --- ", theLine)
			}
			
		}
	}
	
	
	//	Initiate stuff after the application is finished launching
	func applicationDidFinishLaunching(aNotification: NSNotification) {

		//	Add us as observer of iTunes
		NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(logASong), name: "com.apple.iTunes.playerInfo", object: "com.apple.iTunes.player")
		
		//	See if there is a saved preference for log location
		//	If not, set the default location in the pref
		let defaults = NSUserDefaults.standardUserDefaults()
		if let logLoc = defaults.stringForKey("logLoc") {
			DLog("applicationDidFinishLaunching) logLoc found: " + logLoc)
		} else {
			let allPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
			let defaultLogLoc = allPaths.first!.stringByAppendingString("/itunes-log.csv")

			defaults.setObject(defaultLogLoc, forKey: "logLoc")
			DLog("applicationDidFinishLaunching) logLoc created in pref: " + defaultLogLoc)
		}
		defaults.synchronize()
		
	}
}

