//
//  MainViewController.swift
//  NovaSdkTest
//
//  Created by SuGyumKim on 23/10/2018.
//  Copyright © 2018 WizardWorks. All rights reserved.
//

import UIKit
import NovaAuth

class MainViewController: UITableViewController {

    private var account:String = ""
    private var callback:((NovaAuthResult) -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        callback = { result in
            self.performSegue(withIdentifier: "showResponse", sender: result)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResponse" {
            let result = sender as! NovaAuthResult
            let dest = segue.destination as! ResponseViewController
            dest.code = result.code
            dest.msg = result.msg
            dest.raw = result.raw
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Account Info" : "Functions"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var title = ""
        if indexPath.section == 0 {
            if self.account == "" {
                title = "not selected"
            } else {
                title = self.account
            }
        } else {
            switch indexPath.row {
            case 0:
                title = "Make signature"
            case 1:
                title = "Transfer"
            case 2:
                title = "Stake(delegatebw)"
            case 3:
                title = "Unstake(undelegatebw)"
            case 4:
                title = "Do a custom action(buy ram)"
            default:
                title = "Do custom actions(create account)"
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = title
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            NovaAuth.shared.requestAccount { result in
                if let data = result.raw.data(using: .utf8),
                    let json = try? JSONSerialization.jsonObject(with: data, options:[]) as? [String: Any],
                    let account = json["account_name"] {
                    self.account = account as! String
                }
                
                self.tableView.reloadData()
                self.performSegue(withIdentifier: "showResponse", sender: result)
            }
        } else {
            if account == "" {
                self.showSimpleAlert(msg: "Select account first.")
                return
            }
            
            switch indexPath.row {
            case 0:
                var msg = Dictionary<String, String>()
                msg["key1"] = "This message"
                msg["key2"] = "will be signed"
                
                NovaAuth.shared.requestSignature(account: self.account,
                                                 messages: msg,
                                                 callback: self.callback)
            case 1:
                NovaAuth.shared.requestTransfer(from: self.account,
                                                to: "mynamesugyum",
                                                contract: "eosio.token",
                                                symbol: "EOS",
                                                amount: 0.0011,
                                                precision: 4,
                                                memo: "memomemotest",
                                                callback: self.callback)
            case 2:
                NovaAuth.shared.requestStake(account: self.account,
                                             to:"mynamesugyum",
                                             cpu: 1.0,
                                             net: 1.0,
                                             transfer: true,
                                             callback: self.callback)
            case 3:
                NovaAuth.shared.requestUnstake(account: self.account,
                                               to:"mynamesugyum",
                                               cpu: 1.0,
                                               net: 1.0,
                                               callback: self.callback)
            case 4:
                let args:[String : Any] = ["payer":self.account,
                                           "receiver":"mynamesugyum",
                                           "quant":String(format: "%.4f EOS", 0.001)]
                
                let action = NovaAction(code: "eosio", action: "buyram", args: args)
                
                NovaAuth.shared.requestCustomTransaction(account: self.account,
                                                         action: action,
                                                         callback: self.callback)
            default:
                // do custom actions (ex : create account)
                let from = self.account
                let to = "wzdworksno41"
                let ram = 5959
                let cpu = 0.59
                let net = 0.59
                let ownerPublicKey = "EOS6kgpkVY5tey7i8XFFtRKNxCNyVPUMk6ByjxepmXCsdkCLahXup"
                let activePublicKey = "EOS6kgpkVY5tey7i8XFFtRKNxCNyVPUMk6ByjxepmXCsdkCLahXup"
                
                let ownerKey:[String : Any] = ["key" : ownerPublicKey,
                                               "weight" : 1]
                let ownerInfo:[String : Any] = ["threshold" : 1,
                                                "keys" : [ownerKey],
                                                "waits" : Array<Any>(),
                                                "accounts" : Array<Any>()]
                
                let activeKey:[String : Any] = ["key" : activePublicKey,
                                                "weight" : 1]
                let activeInfo:[String : Any] = ["threshold" : 1,
                                                 "keys" : [activeKey],
                                                 "waits" : Array<Any>(),
                                                 "accounts" : Array<Any>()]
                
                let args:[String : Any] = ["creator" : from,
                                           "name" : to,
                                           "owner" : ownerInfo,
                                           "active" : activeInfo]
                
                let action = NovaAction(code: "eosio", action: "newaccount", args: args)
                
                ///////////////////////////////////////////////////////////////////////////////
                let ramParam:[String : Any] = ["payer" : from,
                                               "receiver" : to,
                                               "bytes" : ram]
                
                let buyramAction = NovaAction(code: "eosio", action: "buyrambytes", args: ramParam)
                
                ///////////////////////////////////////////////////////////////////////////////
                let stakeParam:[String : Any] = ["from" : from,
                                                 "receiver" : to,
                                                 "stake_cpu_quantity" : String(format: "%.4f EOS", cpu),
                                                 "stake_net_quantity" : String(format: "%.4f EOS", net),
                                                 "transfer" : true]
                
                let stakeAction = NovaAction(code: "eosio", action: "delegatebw", args: stakeParam)
                
                NovaAuth.shared.requestCustomTransaction(account: self.account,
                                                         actions: [action, buyramAction, stakeAction],
                                                         callback: self.callback)
            }
        }
    }
    
    private func showSimpleAlert(msg:String) {
        let alert = UIAlertController(title: "ERROR", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
