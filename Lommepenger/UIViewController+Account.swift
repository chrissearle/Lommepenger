import UIKit

extension UIViewController {
    func saveDefaultAccount(name: String, number: String) {
        let defaults = UserDefaults.standard
        
        defaults.set(name, forKey: "accountName")
        defaults.set(number, forKey: "accountNumber")
    }
    
    func defaultAccount() -> String? {
        let defaults = UserDefaults.standard
        
        if let accountName = defaults.string(forKey: "accountName"), accountName.isEmpty == false,
            let accountNumber = defaults.string(forKey: "accountNumber"), accountNumber.isEmpty == false {
            
            return "\(accountName) (\(accountNumber))"
        }
        
        return nil
    }
}
