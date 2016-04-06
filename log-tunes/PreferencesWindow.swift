//
//  PreferencesWindow.swift
//  log-tunes
//
//  Created by Saiwing Yeung on 4/1/16.
//  Copyright © 2016 ___SWY___. All rights reserved.
//


import Cocoa

class PreferencesWindow: NSWindowController {

	@IBOutlet weak var logFileLocField: NSTextFieldCell!

	override var windowNibName : String! {
		return "PreferencesWindow"
	}
	
	override func windowDidLoad() {
		super.windowDidLoad()
		
		self.window?.center()
		self.window?.makeKeyAndOrderFront(nil)
		NSApp.activateIgnoringOtherApps(true)
		
		//	Make window model
		self.window?.level = Int(CGWindowLevelForKey(.FloatingWindowLevelKey))
		self.window?.level = Int(CGWindowLevelForKey(.MaximumWindowLevelKey))
		
		let defaults = NSUserDefaults.standardUserDefaults()
		let logLoc = defaults.stringForKey("logLoc") ?? ""
		
		logFileLocField.stringValue = NSURL(fileURLWithPath: logLoc).lastPathComponent!
		
	}
	
	@IBAction func changeClicked(sender: NSButton) {
		let defaults = NSUserDefaults.standardUserDefaults()
		let logLoc = defaults.stringForKey("logLoc") ?? ""
		Swift.debugPrint("(in changeClicked) logLoc: ", logLoc)
		
		let savePanel = NSSavePanel()
		savePanel.title = "Choose a file to save the log:"

		//	Have to do both of these; otherwise when user selects a file it becomes /path/old_file/new_file
		savePanel.directoryURL = NSURL(fileURLWithPath: logLoc).URLByDeletingLastPathComponent!
		savePanel.nameFieldStringValue = NSURL(fileURLWithPath: logLoc).lastPathComponent!
		
		//	Make model
		savePanel.level = Int(CGWindowLevelForKey(.FloatingWindowLevelKey))
		savePanel.level = Int(CGWindowLevelForKey(.MaximumWindowLevelKey))
		
		
		savePanel.beginWithCompletionHandler { (result: Int) -> Void in
			if result == NSFileHandlingPanelOKButton {
				let chosenPath = savePanel.URL!
				Swift.debugPrint("chosenPath: ", chosenPath)
				let chosenFileStr = chosenPath.path
				
				Swift.debugPrint("chosenFileStr: ", chosenFileStr!)
				defaults.setObject(chosenFileStr!, forKey: "logLoc")
				defaults.synchronize()
				
				dispatch_async(dispatch_get_main_queue()) {
					self.logFileLocField.stringValue = NSURL(fileURLWithPath: chosenFileStr!).lastPathComponent!
				}
			}
		}
	}
	
}
