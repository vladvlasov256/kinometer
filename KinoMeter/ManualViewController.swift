//
//  ManualViewController.swift
//  MovieMeter
//
//  Created by Vladimir Vlasov on 23.09.17.
//  Copyright © 2017 Sofa Technologies. All rights reserved.
//

import UIKit

class ManualViewController: UIViewController {
    
    @IBOutlet weak var text: UILabel?
    @IBOutlet weak var hint: UILabel?
    
    @IBOutlet weak var leftSwipe: UISwipeGestureRecognizer?
    @IBOutlet weak var rightSwipe: UISwipeGestureRecognizer?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.leftSwipe?.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func swipeRight(recognizer: UISwipeGestureRecognizer) {
        self.rightSwipe?.isEnabled = false
        self.leftSwipe?.isEnabled = true
        self.text?.text = "Листай 👈🏻 если не видел(а)"
        self.hint?.text = "Попробуй"
    }
    
    @IBAction func swipeLeft(recognizer: UISwipeGestureRecognizer) {
        self.leftSwipe?.isEnabled = false
        self.dismiss(animated: true, completion: nil)
    }

}
