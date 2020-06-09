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
    var existingAppAction:NSMutableArray!
    var detailExistingAppAction:NSMutableArray!
    
    // MARK: - Properties
    let ptManager = PTManager.instance
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the PTManager
        ptManager.delegate = self
        ptManager.connect(portNumber: PORT_NUMBER)
        
        reloadData()
        mainTableview.delegate = self
        mainTableview.dataSource = self
        
        subTableview.delegate = self
        subTableview.dataSource = self
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    @IBAction func addNewItems(_ sender: Any) {
        reloadDataCheckRunning()
        let newItemsMeum = NSMenu.init(title: "In Running App")
        for subItem in runningAppList{
            let title = subItem as! rowDataStruct
            let submenuitem = NSMenuItem.init(title: title.appName, action: #selector(addNewAppItem), keyEquivalent: "")
            submenuitem.image = title.icon
            newItemsMeum.addItem(submenuitem)
        }
        newItemsMeum.popUp(positioning: nil, at:addNewAppActionSets.frame.origin, in: self.view)
        
    }
    @IBAction func deleteItemFromList(_ sender: Any) {
        let indexOfDelete = mainTableview.selectedRow
        let objectShouldDelete:rowDataStruct = existingAppAction.object(at: indexOfDelete) as! rowDataStruct
        
        mainTableview.removeRows(at: mainTableview.selectedRowIndexes, withAnimation: .effectFade)
        CoreDataManager.shared.deleteAutoActionList(appName: objectShouldDelete.appName) { (onSuccess) in
            print("deleted = \(onSuccess)")
        }
        
        existingAppAction.removeObject(at: indexOfDelete)
        mainTableview.reloadData()
    }
    @IBAction func addNewAction(_ sender: Any) {
        
    }
    @IBAction func removeSeletctedAction(_ sender: Any) {
    }
    func reloadDataCheckRunning(){
        runningAppList = NSMutableArray.init()
        for app:NSRunningApplication in NSWorkspace.shared.runningApplications {
            if app.activationPolicy == .regular {
                runningAppList.add(rowDataStruct.init(appName: app.localizedName!, icon: app.icon!))
            }
        }
    }
    func reloadData() -> Void {
        existingAppAction = NSMutableArray.init()
        detailExistingAppAction = NSMutableArray.init()
        let autoActionList: [AutoActionList] = CoreDataManager.shared.getAutoActionList()
        let appNames : [String] = autoActionList.map({$0.appName!})
        //let appIcons : [Data] = autoActionList.map({$0.appIcon!})
        
        for appName in appNames {
            let appIcon : Data? = autoActionList.filter({$0.appName == appName}).first?.appIcon
            //existingAppAction.add(rowDataStruct.init(appName: appName, icon: NSImage.init(data: appIcons[appNames.firstIndex(of: appName)!])!))
            existingAppAction.add(rowDataStruct.init(appName: appName, icon: NSImage.init(data: appIcon!)!))
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
        
        existingAppAction.add(rowDataStruct.init(appName: sender.title, icon: sender.image!))
        //mainTableview.reloadData()
        
        mainTableview.beginUpdates()
        mainTableview.insertRows(at: IndexSet(integer: existingAppAction.count-1), withAnimation: .effectFade)
        mainTableview.endUpdates()
        
        if ptManager.isConnected {
            let ds = rowDataStruct.init(appName: sender.title, icon: sender.image!)
            ptManager.sendData(data: ds.encode(), type: PTType.rowDataStruct.rawValue)

        }
        
        
        //add to coreData
        CoreDataManager.shared.saveAutoActionList(actionName: "still notSure", appName: sender.title, appIcon: (sender.image?.tiffRepresentation)!, scriptPath: "still notSure") { (onSuccess) in
            print("saved = \(onSuccess)")
        }
        //end add to coreData
        
    }

}
extension ViewController: NSTableViewDataSource, NSTableViewDelegate{
    func numberOfRows(in tableview:NSTableView) -> Int {
        if tableview.isEqual(mainTableview) {
            return existingAppAction.count
        }
        if tableview.isEqual(subTableview) {
            return detailExistingAppAction.count
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
                let item = existingAppAction[row] as! rowDataStruct
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

                cellView.textField?.stringValue = detailExistingAppAction[row] as! String

                return cellView

            }
        }
        
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        detailExistingAppAction = NSMutableArray.init()
        let indexOfSelected = mainTableview.selectedRow
        let objectSelected:rowDataStruct = existingAppAction.object(at: indexOfSelected) as! rowDataStruct

        let autoActionList: [AutoActionList] = CoreDataManager.shared.getAutoActionList()

        let appStuffs : [AutoActionList] = autoActionList.filter({$0.appName == objectSelected.appName})
        for stuff in appStuffs {
            detailExistingAppAction.add(stuff.actionName!)
        }
        subTableview.reloadData()
    }
    
}
extension ViewController: PTManagerDelegate {
    
    func peertalk(shouldAcceptDataOfType type: UInt32) -> Bool {
        return true
    }
    
    func peertalk(didReceiveData data: Data, ofType type: UInt32) {
        if type == PTType.string.rawValue {
            let count = data.convert() as! String
            runScript(appName: count)
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
                ptManager.sendData(data: (subItem as! rowDataStruct).encode(), type: PTType.rowDataStruct.rawValue)
            }
        }
        
    }
    
    func runScript(appName:String) -> Void {
        let scriptCMD = "tell application \"\(appName)\" \nactivate \nend tell"
        let script = NSAppleScript(source: scriptCMD)
        script?.executeAndReturnError(nil)
    }
    
}
