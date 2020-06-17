//
//  ViewController.swift
//  BatterExtendApp
//
//  Created by xiaoke yang on 2020/05/29.
//  Copyright © 2020 xiaoke yang. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var mainTableview: NSTableView!
    @IBOutlet weak var subTableview: NSTableView!
    @IBOutlet weak var addNewAppActionSets: NSButton!
    var runningAppList:NSMutableArray!
    var existingApps:NSMutableArray!
    
    var existingAppAction:NSMutableArray!
    var detailExistingAppAction:NSMutableArray!
    
    // MARK: - Properties
    let ptManager = PTManager.instance
    var mainTableDefault = 0
    var subTableDefault = 0
    
   
    override func viewDidLoad() {
        super.viewDidLoad()

        mainTableDefault = mainTableview.selectedRow
        subTableDefault = subTableview.selectedRow
        // Setup the PTManager
        ptManager.delegate = self
        ptManager.connect(portNumber: PORT_NUMBER)
        
        reloadData()
        mainTableview.delegate = self
        mainTableview.dataSource = self
        
        subTableview.delegate = self
        subTableview.dataSource = self
        subTableview.allowsTypeSelect = true
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    @IBAction func addNewItems(_ sender: Any) {
        reloadDataCheckRunning()
        let newItemsMenu = NSMenu.init(title: "In Running App")
        for subItem in runningAppList{
            let title = subItem as! rowDataStruct
            let submenuitem = NSMenuItem.init(title: title.appName, action: #selector(addNewAppItem), keyEquivalent: "")
            submenuitem.image = title.icon
            newItemsMenu.addItem(submenuitem)
        }
        newItemsMenu.popUp(positioning: nil, at:addNewAppActionSets.frame.origin, in: self.view)
        
    }
    @IBAction func deleteItemFromList(_ sender: Any) {
        if mainTableview.selectedRow>=0 {
            let indexOfDelete = mainTableview.selectedRow
            let objectShouldDelete:rowDataStruct = (existingAppAction[indexOfDelete] as! NSArray)[0] as! rowDataStruct
            
            CoreDataManager.shared.deleteAutoActionList(appName: objectShouldDelete.appName, subRow: 0) { (onSuccess) in
                print("deleted = \(onSuccess)")
            }
            
            existingAppAction.removeObject(at: indexOfDelete)
            existingApps.removeObject(at: indexOfDelete)
            mainTableview.removeRows(at: mainTableview.selectedRowIndexes, withAnimation: .effectFade)
            //mainTableview.reloadData()
        }
    }
    @IBAction func addNewAction(_ sender: Any) {
        let item = (existingAppAction[mainTableview.selectedRow] as! NSArray)[0] as! rowDataStruct
        addnewActionForApp(AppName:item.appName, Appicon: item.icon, isOnlyAction: true)
        subTableview.reloadData()
    }
    @IBAction func removeSeletctedAction(_ sender: Any) {
        
        if subTableview.selectedRow>=0 {
            let indexOfDelete = mainTableview.selectedRow
            let objectShouldDelete:rowDataStruct = (existingAppAction[indexOfDelete] as! NSArray)[0] as! rowDataStruct
            
            CoreDataManager.shared.deleteAutoActionList(appName: objectShouldDelete.appName, subRow: subTableview.selectedRow) { (onSuccess) in
                print("deleted = \(onSuccess)")
            }
            ((existingAppAction[mainTableview.selectedRow] as! NSArray)[1] as! NSMutableArray).removeObject(at: subTableview.selectedRow)
            subTableview.removeRows(at: subTableview.selectedRowIndexes, withAnimation: .effectFade)
            if subTableview.numberOfRows == 0{
                existingAppAction.removeObject(at: indexOfDelete)
                existingApps.removeObject(at: indexOfDelete)
                mainTableview.removeRows(at: mainTableview.selectedRowIndexes, withAnimation: .effectFade)
            }
        }
    }
    func reloadDataCheckRunning(){
        runningAppList = NSMutableArray.init()
        for app:NSRunningApplication in NSWorkspace.shared.runningApplications {
            if app.activationPolicy == .regular {
                if !existingApps.contains(app.localizedName!) {
                    runningAppList.add(rowDataStruct.init(appName: app.localizedName!, icon: app.icon!))
                }
            }
        }
    }
    func reloadData() -> Void {
        existingApps = NSMutableArray.init()
        existingAppAction = NSMutableArray.init()
        //detailExistingAppAction = NSMutableArray.init()
        let autoActionList: [AutoActionList] = CoreDataManager.shared.getAutoActionList()
        let appNames : [String] = autoActionList.map({$0.appName!})
        //let appIcons : [Data] = autoActionList.map({$0.appIcon!})
        
        for appName in appNames {
            if !existingApps.contains(appName) {
                existingApps.add(appName)
             
                let appIcon : Data? = autoActionList.filter({$0.appName == appName}).first?.appIcon
                           
               
                let actions : [AutoActionList] = autoActionList.filter({$0.appName == appName})
               
                detailExistingAppAction = NSMutableArray.init()
               
                for action in actions {
                   detailExistingAppAction.add(NSArray.init(objects: action.actionName!, action.scriptPath!))
                }
               
                //existingAppAction.add(rowDataStruct.init(appName: appName, icon: NSImage.init(data: appIcon!)!))
                existingAppAction.add(NSArray.init(objects: rowDataStruct.init(appName: appName, icon: NSImage.init(data: appIcon!)!), detailExistingAppAction!))
            }
        }
        
        
        
        
        
    }
//    func addNewAppItem(title:rowDataStruct) -> Void {
//        existingAppAction.add(title)
//        mainTableview.reloadData()
//    }
    @objc func addNewAppItem(_ sender: NSMenuItem){
//        var index=0
//        for subItem in runningAppList {
//             let title = subItem as! rowDataStruct
//            if title.appName == titleS {
//                index = runningAppList.index(of: title)
//            }
//        }
        addnewActionForApp(AppName: sender.title, Appicon: sender.image!, isOnlyAction: false)
    }
    
    func addnewActionForApp(AppName:String, Appicon:NSImage, isOnlyAction:Bool) -> Void {
        let newAppActionAlert = NSAlert.init()
        newAppActionAlert.alertStyle = NSAlert.Style.warning
        
        let actionName:String
        let actionScriptPath:String
        
        if !existingApps.contains(AppName)||isOnlyAction{
            let inputedActionName = NSTextField.init(frame: NSRect.init(x: 0, y: 0, width: 100, height: 30))
            newAppActionAlert.messageText = "Enter new Action Name"
            newAppActionAlert.accessoryView = inputedActionName
            newAppActionAlert.addButton(withTitle: "Continue")
            newAppActionAlert.addButton(withTitle: "Cancel")
            newAppActionAlert.icon = Appicon
            let response = newAppActionAlert.runModal()
            
            if response == NSApplication.ModalResponse.alertFirstButtonReturn {
                actionName = inputedActionName.stringValue
                
                let selectScriptPanel = NSOpenPanel.init()
                let scriptResult = selectScriptPanel.runModal()
                
                if scriptResult.rawValue == NSFileHandlingPanelOKButton {
                    actionScriptPath = selectScriptPanel.url!.path as String
                    
                    if !isOnlyAction{
                        existingApps.add(AppName)
                        //print(actionScriptPath)
                        detailExistingAppAction = NSMutableArray.init()
                        detailExistingAppAction.add(NSArray.init(objects: actionName, actionScriptPath))
                        existingAppAction.add(NSArray.init(objects: rowDataStruct.init(appName: AppName, icon: Appicon), detailExistingAppAction!))
                        
                        mainTableview.beginUpdates()
                        mainTableview.insertRows(at: IndexSet(integer: existingAppAction.count-1), withAnimation: .effectFade)
                        mainTableview.endUpdates()
                        
                        mainTableview.selectRowIndexes(IndexSet(integer: existingAppAction.count-1), byExtendingSelection: false)
                    }else{
                        ((existingAppAction[mainTableview.selectedRow] as! NSArray)[1] as! NSMutableArray).add(NSArray.init(objects: actionName, actionScriptPath))
                    }
                    
                    if ptManager.isConnected {
                        let ds = rowDataStruct.init(appName: AppName, icon: Appicon)
                        ptManager.sendData(data: ds.encode(), type: PTType.rowDataStruct.rawValue)
                        
                    }
                    
                    
                    //add to coreData
                    CoreDataManager.shared.saveAutoActionList(actionName: actionName, appName: AppName, appIcon: (Appicon.tiffRepresentation)!, scriptPath: actionScriptPath) { (onSuccess) in
                        print("saved = \(onSuccess)")
                    }
                    //end add to coreData
                }
                
            }
            
        }
    }

}
extension ViewController: NSTableViewDataSource, NSTableViewDelegate{
    func numberOfRows(in tableview:NSTableView) -> Int {
        if tableview.isEqual(mainTableview) {
            return existingAppAction.count
        }
        if tableview.isEqual(subTableview)&&mainTableview.selectedRow>=0 {
            return ((existingAppAction[mainTableview.selectedRow] as! NSArray)[1] as! NSMutableArray).count
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
       
        //let asset = runningAppList[row] as? NSImage
        if tableView.isEqual(mainTableview) {
            if (tableColumn?.identifier)!.rawValue == "appName" {
                tableColumn?.title = "Apps"
                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "appImage")
                let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as! NSTableCellView
                let item = (existingAppAction[row] as! NSArray)[0] as! rowDataStruct
                cellView.imageView?.image=item.icon
                cellView.textField?.stringValue=item.appName
                return cellView
                
            }
        }
        if tableView.isEqual(subTableview) {
            if (tableColumn?.identifier)!.rawValue == "appAction"{

                tableColumn?.title = "appActions"


                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "actions")

                let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as! NSTableCellView

                cellView.textField?.stringValue = (((existingAppAction[mainTableview.selectedRow] as! NSArray)[1] as! NSMutableArray)[row] as! NSArray)[0] as! String

                return cellView

            }
            if (tableColumn?.identifier)!.rawValue == "applescriptPath"{

                tableColumn?.title = "AppleScript"


                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "applescripts")

                let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as! NSTableCellView

                cellView.textField?.stringValue = (((existingAppAction[mainTableview.selectedRow] as! NSArray)[1] as! NSMutableArray)[row] as! NSArray)[1] as! String

                return cellView

            }
        }
        
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        //detailExistingAppAction = NSMutableArray.init()
//        let indexOfSelected = mainTableview.selectedRow
//        let objectSelected:rowDataStruct = (existingAppAction[indexOfSelected] as! NSArray)[0] as! rowDataStruct

//        let autoActionList: [AutoActionList] = CoreDataManager.shared.getAutoActionList()
//
//        let appStuffs : [AutoActionList] = autoActionList.filter({$0.appName == objectSelected.appName})
//        for stuff in appStuffs {
//            detailExistingAppAction.add(stuff.actionName!)
//        }
        
        if mainTableview.selectedRow != mainTableDefault{
            subTableview.reloadData()
            mainTableDefault = mainTableview.selectedRow
        }
        //subTableview.reloadData()
        
        if subTableview.selectedRow != subTableDefault && subTableview.selectedRow>=0{
            let prt = (((existingAppAction[mainTableview.selectedRow] as! NSArray)[1] as! NSMutableArray)[subTableview.selectedRow] as! NSArray)[1] as! String
            print(prt)
//            runScriptFromFile(scriptPath: prt)
            subTableDefault = subTableview.selectedRow
        }
        
        
    }
    func runScriptFromFile(scriptPath:String) -> Void {
        let scriptURL = NSURL.init(fileURLWithPath: scriptPath)
        let script = NSAppleScript.init(contentsOf: scriptURL as URL, error: nil)
        script?.executeAndReturnError(nil)
        
    }
    
}
extension ViewController: PTManagerDelegate {
    
    func peertalk(shouldAcceptDataOfType type: UInt32) -> Bool {
        return true
    }
    
    func peertalk(didReceiveData data: Data, ofType type: UInt32) {
        if type == PTType.number.rawValue {
            let count = data.convert() as! Int
            //runScript(appName: count)
//            let prt = (((existingAppAction[count] as! NSArray)[1] as! NSMutableArray)[0] as! NSArray)[1] as! String
//            runScriptFromFile(scriptPath: prt)
            for subAction in (existingAppAction[count] as! NSArray)[1] as! NSMutableArray{
                ptManager.sendObject(object: (subAction as! NSArray)[0] as! String, type: PTType.string.rawValue)
            }
            ptManager.sendObject(object: 0, type: PTType.number.rawValue)
            
        }
        
        if type == PTType.string.rawValue {
            let mainIndex = Int((data.convert() as! String).split(separator: "^")[0])
            let subIndex = Int((data.convert() as! String).split(separator: "^")[1])
            runScriptFromFile(scriptPath: (((existingAppAction[mainIndex!] as! NSArray)[1] as! NSMutableArray)[subIndex!] as! NSArray)[1] as! String)
        }
    }
    
    func peertalk(didChangeConnection connected: Bool) {
        print("Connection: \(connected)")
        
        if connected {
            for subItem in existingAppAction{
//                let title = subItem as! rowDataStruct
//                let submenuitem = NSMenuItem.init(title: title.appName, action: #selector(addNewAppItem), keyEquivalent: "")
//                submenuitem.image = title.icon
//                newItemsMeum.addItem(submenuitem)
                ptManager.sendData(data: ((subItem as! NSArray)[0] as! rowDataStruct).encode(), type: PTType.rowDataStruct.rawValue)
            }
        }
        
    }
    
    func runScript(appName:String) -> Void {
        let scriptCMD = "tell application \"\(appName)\" \nactivate \nend tell"
        let script = NSAppleScript(source: scriptCMD)
        script?.executeAndReturnError(nil)
    }
    
}
