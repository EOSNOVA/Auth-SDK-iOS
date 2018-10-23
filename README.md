
# Requirements
- [NOVA 1.3.1][1]
- iOS 10.0

#### For more information please see [the website][2].

# Installation

## CocoaPods


## Carthage


## Swift Package Manager


## Manually

# Usage

## In pList file,

### add this,

```xml
<key>LSApplicationQueriesSchemes</key>
    <array>
        <string>eosnova</string>
    </array>
```

### add this,

```xml
<key>CFBundleURLTypes</key>
<array>
 <dict>
     <key>CFBundleTypeRole</key>
     <string>Editor</string>
     <key>CFBundleURLSchemes</key>
     <array>
         <string>{scheme}</string>
     </array>
 </dict>
</array>
```

{scheme} must be replaced <b>eosnova.packagename</b><br/>
ex) when packagename is <b>com.wzdworks.Nova</b>, {scheme} will be replaced <b>eosnova.com.wzdworks.Nova</b>


## In AppDelegate,

```swift

import NovaAuth  //import this

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
        ....
        NovaAuth.shared.register(dappName: "YOUR APP NAME. IT WILL SHOW NOVA SDK AUTH")
        ....
        
        return ....
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        ....
        NovaAuth.shared.openURL(url: url)
        ....
        
        return ....
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    
        ....
        NovaAuth.shared.applicationDidBecomeActive()
        ....
        
    }
}
```
## Request

### Read Account Info
```swift
        // read account info (/v1/chain/get_account)
        // account will be choosed in nova
        // 'raw' contains account information
        NovaAuth.shared.requestAccount { result in
            let code = result.code
            let msg = result.msg
            let raw = result.raw
        }
```

### Transfer token
```swift        
        // from : Account name format. not be empty
        // to : Account name format. not be empty
        // contract : Token contract format. not be empty
        // symbol : Token symbol uppercased. not be empty
        // amount : send amount. > 0
        // precision : >= 0
        // memo : can be empty
        NovaAuth.shared.requestTransfer(from: "sender", to: "receiver", contract: "eosio.token", symbol: "EOS", amount: 1990.0509, precision: 4, memo: "mynamesugyum") { result in
            let code = result.code
            let msg = result.msg
            let raw = result.raw
        } 
```

### Stake / Unstake
```swift        
        // stake
        // account : Account name format. not be empty
        // cpu : Eos token format. >= 0
        // net : Eos token format. >= 0
        // * cpu, net both 0 will make error
        NovaAuth.shared.requestStake(account: "mynamesugyum", to: "receiver", cpu: 0.5959, net: 0.5959, transfer: true) { result in
            let code = result.code
            let msg = result.msg
            let raw = result.raw
        }
        
        
        // unstake
        // account : Account name format. not be empty
        // cpu : Eos token format. >= 0
        // net : Eos token format. >= 0
        // * cpu, net both 0 will make error
        NovaAuth.shared.requestUnstake(account: "mynamesugyum", to: "receiver", cpu: 0.5959, net: 0.5959) { result in
            let code = result.code
            let msg = result.msg
            let raw = result.raw
        }
```

### Make signed string
```swift        
        // account : Account name format. not be empty
        // message : Key-Value Dictionary. at least include 1 key.
        // 'raw' contains signed dictionary


        var msg = Dictionary<String, String>()
        msg["key1"] = "myname"
        msg["key2"] = "is"
        msg["key3"] = "sugyum"
        
        NovaAuth.shared.requestSignature(account: "mynamesugyum", messages: msg) { result in
            let code = result.code
            let msg = result.msg
            let raw = result.raw
        }
```

### Push a your custom action
```swift        
        // push a your custom action.
        
        // make your action
        var args = Dictionary<String,Any>()
        args["payer"] = "sender"
        args["receiver"] = "receiver"
        args["bytes"] = 4096
        let action = NovaAction(code: "eosio", action: "buyrambytes", args: args)
        
        // push action
        // account : Account name format. not be empty.
        NovaAuth.shared.requestCustomTransaction(account: "mynamesugyum", action: action) { result in
            let code = result.code
            let msg = result.msg
            let raw = result.raw
        }
```

### Push your custom actions
```swift        
        // push your custom actions
        
        let from = "mynamesugyum"
        let to = "actiontest11"
        let ram = 5959
        let cpu = 0.59
        let net = 0.59
        let ownerPublicKey = "key"
        let activePublicKey = "key"
        
        var ownerKey = Dictionary<String,Any>()
        ownerKey["key"] = ownerPublicKey
        ownerKey["weight"] = 1
        
        var ownerInfo = Dictionary<String,Any>()
        ownerInfo["threshold"] = 1
        ownerInfo["keys"] = [ownerKey]
        ownerInfo["waits"] = Array<Any>()
        ownerInfo["accounts"] = Array<Any>()
        
        var activeKey = Dictionary<String,Any>()
        activeKey["key"] = activePublicKey
        activeKey["weight"] = 1
        
        var activeInfo = Dictionary<String,Any>()
        activeInfo["threshold"] = 1
        activeInfo["keys"] = [activeKey]
        activeInfo["waits"] = Array<Any>()
        activeInfo["accounts"] = Array<Any>()
        
        var args = Dictionary<String,Any>()
        args["creator"] = from
        args["name"] = to
        args["owner"] = ownerInfo
        args["active"] = activeInfo
        
        let action1 = NovaAction(code: "eosio", action: "newaccount", args: args)
        
        ///////////////////////////////////////////////////////////////////////////////
        var args2 = Dictionary<String,Any>()
        args2["payer"] = from
        args2["receiver"] = to
        args2["bytes"] = ram
        
        let action2 = NovaAction(code: "eosio", action: "buyrambytes", args: args2)
        
        ///////////////////////////////////////////////////////////////////////////////
        var args3 = Dictionary<String,Any>()
        args3["from"] = from
        args3["receiver"] = to
        args3["stake_cpu_quantity"] = String(format: "%.4f EOS", cpu)
        args3["stake_net_quantity"] = String(format: "%.4f EOS", net)
        args3["transfer"] = true
        
        let action3 = NovaAction(code: "eosio", action: "delegatebw", args: args3)
        
        NovaAuth.shared.requestCustomTransaction(account: from, actions: [action1, action2, action3]) { result in
            let code = result.code
            let msg = result.msg
            let raw = result.raw
        }
```

### Result (NovaAuthResult)

```swift
class NovaAuthResult {
    var code:Int
    var msg:String
    var raw:String                  //has response raw value from eos network or other information.
}
    
```  
#### Response code
    0:"success"
    100:"user cancel",              //User pressed 'cancel' button
    101:"wrong arguments",          //Parameter of your request is wrong
    200:"No account in Nova",       //Account list empty in nova.
    201:"No account in Nova",       //Can't find account in nova.
    300:"transaction fail",         //Fail to push transaction. because of bad network or other reason.
    
    500:"can't receive response",   //User back to dapp without any action
    501:"wrong response"            // not use yet.

# License 

    Copyright 2018 WizardWorks Inc. All rights reserved.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

[1]: https://apple.co/2NZZrUj
[2]: http://eosnova.io
