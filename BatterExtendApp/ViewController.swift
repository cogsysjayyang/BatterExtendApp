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
    @IBOutlet weak var addNewAppActionSets: NSButton!
    var runningAppList:NSMutableArray!
    var existingAppAction:NSMutableArray!
    
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
    @IBAction func reloadList(_ sender: Any) {
        mainTableview.reloadData()
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
        mainTableview.reloadData()
        
        if ptManager.isConnected {
            let ds = rowDataStruct.init(appName: sender.title, icon: sender.image!)
            ptManager.sendData(data: ds.encode(), type: PTType.rowDataStruct.rawValue)

        }
        
    }

}
extension ViewController: NSTableViewDataSource, NSTableViewDelegate{
    func numberOfRows(in mainTableview:NSTableView) -> Int {
        return existingAppAction.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
       
        //let asset = runningAppList[row] as? NSImage
        if (tableColumn?.identifier)!.rawValue == "appName" {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "appImage")
            let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as! NSTableCellView
            let item = existingAppAction[row] as! rowDataStruct
            cellView.imageView?.image=item.icon
            cellView.textField?.stringValue=item.appName
            return cellView
            
        }
//        else if (tableColumn?.identifier)!.rawValue == "appSize"{
//            cellView.textField!.stringValue = "size"
//        }
        
        return nil
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
