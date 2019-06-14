import UIKit
import SwiftKeychainWrapper
import SbankenClient

class SettingsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var key: UITextField!
    @IBOutlet weak var secret: UITextField!
    @IBOutlet weak var user: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let spinner = SpinnerViewController()

    var allSaved = true
    
    var accounts : [Account] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        updateClientID()
    }
    
    func updateClientID() {
        if let clientID = KeychainWrapper.standard.string(forKey: "clientID") {
            key.text = clientID
        }
    }
    
    func storeValues() {
        allSaved = true
        
        allSaved = allSaved && saveToKeychain(field: key, key: "clientID")
        allSaved = allSaved && saveToKeychain(field: secret, key: "clientSecret")
        allSaved = allSaved && saveToKeychain(field: user, key: "userID")
        
        if (!allSaved) {
            alertPopup(title: "Innstillinger", message: "Kunne ikke lagre innstillinger")
        }
    }

    func saveToKeychain(field: UITextField?, key: String)  -> Bool {
        if let value = field?.text, value.isEmpty == false {
            return KeychainWrapper.standard.set(value, forKey: key)
        }
        
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        storeValues()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return allSaved
    }
    
    @IBAction func update(_ sender: Any) {
        self.view.endEditing(true)
        
        storeValues()
        
        if (allSaved) {
            _ = appDelegate.updateClient()
        }
        
        if let userID = user.text, userID.isEmpty == false {
            getAccounts(userID)
        } else {
            alertPopup(title: "Innstillinger", message: "Du må oppgi fødselsnummer for å hente kontoliste")
        }
    }
    
    func getAccounts(_ userID : String) {
        if let client = appDelegate.getClient() {
            showSpinner(self.spinner)

            client.accounts(userId: userID, success: { (accs) in
                self.clearSpinner(self.spinner)

                self.accounts = accs
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }) { (error) in
                self.clearSpinner(self.spinner)

                if let err = error {
                    print(err)
                } else {
                    print("An unknown error occured")
                }
            }
        }
    }
}

extension SettingsViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath)
        
        cell.textLabel?.text = accounts[indexPath.row].name
        cell.detailTextLabel?.text = accounts[indexPath.row].accountNumber
        
        return cell
    }
}

extension SettingsViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let account = self.accounts[indexPath.row]
        
        allSaved = allSaved && KeychainWrapper.standard.set(account.accountId, forKey: "accountID")
        
        saveDefaultAccount(name: account.name, number: account.accountNumber)
    }
}

