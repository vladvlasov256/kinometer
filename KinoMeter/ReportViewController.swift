//
//  ReportViewController.swift
//  MovieMeter
//
//  Created by Vladimir Vlasov on 23.09.17.
//  Copyright © 2017 Sofa Technologies. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController {
    
    var report: String? {
        didSet {
            self.text?.text = report
        }
    }
    
    @IBOutlet weak var text: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.text?.text = report
    }

}
