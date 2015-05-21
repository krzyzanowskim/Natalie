//
//  XNatalie.swift
//
//  Created by phimage on 14/05/15.
/*
The MIT License (MIT)

Copyright (c) 2015 Eric Marchand (phimage)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import AppKit

var sharedPlugin: XNatalie?

let Defaults = NSUserDefaults.standardUserDefaults()
let StoryboardExt = "storyboard"

class XNatalie: NSObject {
    var bundle: NSBundle

    class func pluginDidLoad(bundle: NSBundle) {
        let appName = NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? NSString
        if appName == "Xcode" {
            sharedPlugin = XNatalie(bundle: bundle)
        }
    }
    
    var storyboardEnabledMenuItem: NSMenuItem!
    var storyboardFileName: String?

    init(bundle: NSBundle) {
        self.bundle = bundle

        super.init()
        addObservers()
    }

    deinit {
        removeObservers()
    }

    // MARK: config

    static let pluginEnabledString = "XNatalieEnabled"
    var pluginEnabled: Bool {
        get {
            return Defaults.boolForKey(XNatalie.pluginEnabledString)
        }
        set {
            Defaults.setBool(newValue, forKey: XNatalie.pluginEnabledString)
        }
    }
    
    static let launchPathString = "XNataliePath"
    var launchPath: String {
        get {
            return Defaults.stringForKey(XNatalie.launchPathString) ?? "/usr/local/bin/natalie.swift"
        }
        set {
            Defaults.setObject(newValue, forKey: XNatalie.launchPathString)
        }
    }
    
    var swiftFile = "Storyboards.swift"
    
    // MARK: notifications
    
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidFinishLaunching:", name: NSApplicationDidFinishLaunchingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "transitionFromOneFileToAnother:", name: "transition from one file to another", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "ideEditorDocumentDidSave:", name: "IDEEditorDocumentDidSaveNotification", object: nil)
    }
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func applicationDidFinishLaunching(notification: NSNotification!) {
        createMenuItems()
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSApplicationDidFinishLaunchingNotification, object: nil)
    }

    func transitionFromOneFileToAnother(notification: NSNotification!) {
        if let url = documentURLFromNotification(notification) {
            let urlString = url.description
            let begin = (urlString as NSString).rangeOfString("file://")
            if (begin.location != NSNotFound) {
                let fullPath = (urlString as NSString).substringFromIndex(begin.location + begin.length)
                if fullPath.pathExtension == StoryboardExt {
                    self.storyboardFileName = fullPath
                }
                else {
                    self.storyboardFileName = nil
                    // println("Ignoring \(fullPath.pathExtension)")
                }
            }
            else {
                self.storyboardFileName = nil
                println("Unable to find file:// in \(urlString)")
            }
        }
    }
    
    func ideEditorDocumentDidSave(notification: NSNotification!){
        if !self.pluginEnabled {
            return
        }
        
        if let fileName = self.storyboardFileName {
            if let notificationObject: AnyObject = notification.object
                where notificationObject.isKindOfClass(NSClassFromString("IBStoryboardDocument")) // as? IBStoryboardDocument
            {
                let storyboardPath = self.workingPath ?? fileName
                let data = taskForStoryboardAtPath(storyboardPath)
                
                let storyboardFile = self.workingPath ?? fileName.stringByDeletingLastPathComponent
                writeSwiftFile(data, path: storyboardFile)
            }
        }
    }
    
    // MARK: specific
    func taskForStoryboardAtPath(path: String) -> NSData {
        let task = NSTask()
        task.launchPath = self.launchPath
        
        let pipe = NSPipe()
        task.standardOutput = pipe
        
        task.arguments = [path]
        task.currentDirectoryPath = path
        
        task.launch()
        task.waitUntilExit()
        
        return pipe.fileHandleForReading.readDataToEndOfFile()
    }
    
    func writeSwiftFile(data: NSData, path: String) -> String? {
        let outputFolder = path.stringByAppendingPathComponent(self.swiftFile)
        
        if NSFileManager.defaultManager().fileExistsAtPath(outputFolder) {
            NSFileManager.defaultManager().removeItemAtPath(outputFolder, error: nil)
        }
        NSFileManager.defaultManager().createFileAtPath(outputFolder, contents: nil, attributes: nil)
        
        if let forWriting = NSFileHandle(forWritingAtPath: outputFolder) {
            println("writing to \(outputFolder)")
            forWriting.writeData(data)
            return outputFolder
        }
        return nil
    }
    
    var workingPath: String? {
        if let file = self.workspaceFile {
            return file.stringByDeletingPathExtension
        }
        return nil
    }
    
    // MARK: menu
    func createMenuItems() {
        if let topItem = NSApp.mainMenu??.itemWithTitle("Product") {
            let pluginMenuItem = NSMenuItem()
            pluginMenuItem.title = "Natalie"
            
            let pluginMenu = NSMenu()
            
            let generateMenuItem = NSMenuItem(title:"Generate", action:"generate:", keyEquivalent:"")
            generateMenuItem.target = self
            pluginMenu.addItem(generateMenuItem)
            
            self.storyboardEnabledMenuItem = NSMenuItem(title:"Enable generate when saving", action:"enableMenu:", keyEquivalent:"")
            self.storyboardEnabledMenuItem.target = self
            pluginMenu.addItem(self.storyboardEnabledMenuItem)
            updateStoryboardEnabledMenuItem()
            
            let editLaunchPathMenuItem = NSMenuItem(title:"Edit launch path", action:"editLaunchPath:", keyEquivalent:"")
            editLaunchPathMenuItem.target = self
            pluginMenu.addItem(editLaunchPathMenuItem)
            
            
            pluginMenuItem.submenu = pluginMenu
            
            topItem.submenu!.addItem(NSMenuItem.separatorItem())
            topItem.submenu!.addItem(pluginMenuItem)
            
        }
    }
    
    
    func generate(sender: NSMenuItem!) {
        if  let storyboardPath = self.workingPath {
            let data = taskForStoryboardAtPath(storyboardPath)

            let alert = NSAlert()
            
            if let dst = writeSwiftFile(data, path: storyboardPath) {
              
                alert.messageText = "File generated at path: \(dst)"
               
            } else {
                 alert.messageText = "Failed to write \(swiftFile)"
            }
        
            
            alert.beginSheetModalForWindow(NSApp.keyWindow!!, completionHandler: { (response) -> Void in
                
            })
            
            let timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("closeAlert:"), userInfo: alert, repeats: false)
        }
        else {
            println("not able to find project path")
        }
    }
    
    func closeAlert(timer: NSTimer) {
        if let alert = timer.userInfo as? NSAlert, window = alert.window as? NSWindow {
            window.orderOut(nil)
        }
    }
    
    func enableMenu(sender: NSMenuItem!) {
        self.pluginEnabled = !self.pluginEnabled
        updateStoryboardEnabledMenuItem()
    }
    
    func editLaunchPath(sender: NSMenuItem!) {
        let alert = NSAlert()
        alert.messageText = "Choose path for executable"
        alert.addButtonWithTitle("Valid")
        alert.addButtonWithTitle("Cancel")
        
        let input = NSTextField(frame:NSMakeRect(0, 0, 200, 24))
        input.stringValue = self.launchPath
        alert.accessoryView = input
        
        alert.beginSheetModalForWindow(NSApp.keyWindow!!) { (response) -> Void in
            if (response == NSAlertFirstButtonReturn) {
                self.launchPath = input.stringValue
            }
        }
    }

    func updateStoryboardEnabledMenuItem() {
        self.storyboardEnabledMenuItem.state = self.pluginEnabled ? NSOnState : NSOffState
    }
    
    // MARK: utils
    
    func documentURLFromNotification(notification: NSNotification) -> NSURL?{
        if let dico = notification.object as? Dictionary<String,AnyObject>,
            documentLocation = dico["next"] as? DVTDocumentLocation {
                return documentLocation.documentURL
        }
        return nil
    }
    
    lazy var workspaceFile: String? = {
        if let workspace = self.workspace {
            return workspace.representingFilePath?.pathString
        }
        return nil
        }()
    
    lazy var workspaceName: String? = {
        if let workspace = self.workspace {
            return workspace.name
        }
        return nil
        }()
    
    lazy var workspace: IDEWorkspace? = {
        if let workspaceWindowControllers = IDEWorkspaceWindowController.workspaceWindowControllers() as? Array<AnyObject> {
            for controller in workspaceWindowControllers {
                if controller.valueForKey("window")! as? NSObject == NSApp.keyWindow! {
                    if let workSpace = controller.valueForKey("_workspace") as? IDEWorkspace {
                        return workSpace
                    }
                }
            }
        }
        return nil
        }()
}
