//
//  TransparentBarViewController.swift
//  TFTransparentNavigationBar
//
//  Created by Aleš Kocur on 03/10/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import TFTransparentNavigationBar


class TransparentBarViewController: UIViewController, TFTransparentNavigationBarProtocol, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var viewFadingBehaviour = ViewFadingBehaviour()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpFading(viewFadingBehaviour, forTableView: tableView)
        
        print(self.navigationController?.navigationBar.frame ?? "nil")

    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - TFTransparentNavigationBarProtocol
    
    func navigationControllerBarPushStyle() -> TFNavigationBarStyle {
        return .transparent
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 25
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        return cell
    }
    
}
