//
//  StatusMenuController.swift
//  log-tunes
//
//  Created by Saiwing Yeung on 4/1/16.
//  Copyright © 2016 ___SWY___. All rights reserved.
//


import Cocoa

class StatusMenuController: NSObject {

	@IBOutlet weak var statusMenu: NSMenu!
	var preferencesWindow: PreferencesWindow!
	
	let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
	
	override func awakeFromNib() {
		let icon = NSImage(named: "statusIcon")
		icon?.template = true // best for dark mode
		statusItem.image = icon
		statusItem.menu = statusMenu
		
		preferencesWindow = PreferencesWindow()
	}

	@IBAction func aboutClicked(sender: NSMenuItem) {
		
		NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://github.com/saiwing-yeung/log-tunes")!)
	}

	@IBAction func preferencesClicked(sender: NSMenuItem) {
		preferencesWindow.showWindow(nil)
	}
	
	@IBAction func quitClicked(sender: NSMenuItem) {
		NSApplication.sharedApplication().terminate(self)
	}
}
