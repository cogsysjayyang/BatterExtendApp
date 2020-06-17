//
//  DetailViewController.swift
//  BatterExtendiOS
//
//  Created by jay on 02/06/2020.
//  Copyright © 2020 xiaoke yang. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var sample: UICollectionView!
    var existingActions:NSMutableArray!

    let ptManager = PTManager.instance

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
                //label.text = detail.timestamp!.description
                self.navigationItem.title = detail
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
        existingActions = NSMutableArray.init()
        sample.delegate = self
        sample.dataSource = self
        ptManager.delegate = self
        ptManager.connect(portNumber: PORT_NUMBER)
    }

    var detailItem: String? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    var detailItemIndex = 0


}

extension DetailViewController:UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return existingActions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailCell", for: indexPath)
        //detailAction.text = (existingActions.object(at: indexPath.row) as! String)
        //print(label.text!)
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 20))
        cell.contentView.backgroundColor = UIColor.blue
        label.text = (existingActions.object(at: indexPath.row) as! String)
        cell.contentView.addSubview(label)
        print(label.text!)
        return cell
    
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ptManager.sendObject(object: String(detailItemIndex)+"^"+String(indexPath.row), type: PTType.string.rawValue)
    }
    
    
}

extension DetailViewController:PTManagerDelegate{
    
    func peertalk(shouldAcceptDataOfType type: UInt32) -> Bool {
        return true
    }
    
    func peertalk(didReceiveData data: Data, ofType type: UInt32) {
    
        if type == PTType.string.rawValue {
            let subAction = data.convert() as! String
            //countall = count
//            print(subAction)
            existingActions.add(subAction)
        }
        if type == PTType.number.rawValue{
            sample.reloadData()
        }
    }
    
    func peertalk(didChangeConnection connected: Bool) {
        print("Connection: \(connected)")
    }
    
}

