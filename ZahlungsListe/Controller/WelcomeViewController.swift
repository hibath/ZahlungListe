//
//  WelcomeViewController.swift
//  ZahlungList
//
//  Created by Heba Thabet Agha on 15.02.23.
//

import UIKit
import CLTypingLabel

class WelcomeViewController: UIViewController {

    @IBOutlet weak var nameLable: CLTypingLabel!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLable.text = "💸 Money Tracking"
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            navigationController?.isNavigationBarHidden =  true

        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
             self.performSegue(withIdentifier: "goToPieChart", sender: self)
        })
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
