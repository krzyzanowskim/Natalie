//
//  NataliePlugin.swift
//
//  Created by phimage on 14/05/15.
//  Copyright (c) 2015 phimage. All rights reserved.
//

import AppKit

var sharedPlugin: NataliePlugin?

let Defaults = NSUserDefaults.standardUserDefaults()
let StoryboardExt = "storyboard"

class NataliePlugin: NSObject {
    var bundle: NSBundle
    
    var storyboardEnabledMenuItem: NSMenuItem!
    var storyboardFileName: String?

    class func pluginDidLoad(bundle: NSBundle) {
        let appName = NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? NSString
        if appName == "Xcode" {
            sharedPlugin = NataliePlugin(bundle: bundle)
        }
    }

    init(bundle: NSBundle) {
        self.bundle = bundle

        super.init()
        createMenuItems()
        addObservers()
    }

    deinit {
        removeObservers()
    }
    
    // MARK: config
    
    static let pluginEnabledString = "NathalieEnabled"
    var pluginEnabled: Bool {
        get {
            return Defaults.boolForKey(NataliePlugin.pluginEnabledString)
        }
        set {
            Defaults.setBool(newValue, forKey: NataliePlugin.pluginEnabledString)
        }
    }
    
    static let launchPathString = "NathaliePath"
    var launchPath: String {
        get {
            return Defaults.stringForKey(NataliePlugin.launchPathString) ?? "/usr/local/bin/natalie.swift"
        }
        set {
            Defaults.setObject(newValue, forKey: NataliePlugin.launchPathString)
        }
    }
    
    // MARK: notifications

    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "transitionFromOneFileToAnother:", name: "transition from one file to another", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "ideEditorDocumentDidSave:", name: "IDEEditorDocumentDidSaveNotification", object: nil)
    }
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
    
    func writeSwiftFile(data: NSData, path: String) {
        let outputFolder = path.stringByAppendingPathComponent("Storyboards.swift")
        
        if NSFileManager.defaultManager().fileExistsAtPath(outputFolder) {
            NSFileManager.defaultManager().removeItemAtPath(outputFolder, error: nil)
        }
        NSFileManager.defaultManager().createFileAtPath(outputFolder, contents: nil, attributes: nil)
        
        if let forWriting = NSFileHandle(forWritingAtPath: outputFolder) {
            println("writing to \(outputFolder)")
            forWriting.writeData(data)
        }
    }
    
    var workingPath: String? {
        if let file = self.workspaceFile {
            return file.stringByDeletingPathExtension
        }
        return nil
    }

    // MARK: menu
    func createMenuItems() {
        if let topItem = NSApp.mainMenu!!.itemWithTitle("Product") {
                       let pluginMenuItem = NSMenuItem()
            pluginMenuItem.title = "Natalie"
            
            let pluginMenu = NSMenu()
            
            self.storyboardEnabledMenuItem = NSMenuItem(title:"Enable", action:"enableMenu:", keyEquivalent:"")
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

