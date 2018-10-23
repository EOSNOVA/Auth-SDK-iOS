//
//  ResponseViewController.swift
//  NovaSdkTest
//
//  Created by SuGyumKim on 23/10/2018.
//  Copyright © 2018 WizardWorks. All rights reserved.
//

import UIKit

class ResponseViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var code:Int = -1
    var msg:String = ""
    var raw:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.code == -1 {
            self.textView.text = "Unexpected problem"
        } else {
            self.textView.text = "code : \(code)\nmessage : \(msg)\nraw : \(raw)"
        }
    }
}
