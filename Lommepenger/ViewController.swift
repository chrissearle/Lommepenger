import UIKit

import SwiftKeychainWrapper
import SbankenClient

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var accountNameText: UILabel!
    @IBOutlet weak var accountBalanceText: UILabel!
    @IBOutlet weak var accountAvailableText: UILabel!
    @IBOutlet weak var transactionTableView: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let spinner = SpinnerViewController()

    var transactions : [Transaction] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        updateScreen()
    }
    
    func updateScreen() {
        updateAccountName()

        if let client = appDelegate.getClient(),
            let accountID = KeychainWrapper.standard.string(forKey: "accountID"),
            let userID = KeychainWrapper.standard.string(forKey: "userID") {
            getAccountDetails(accountID, client: client, userID: userID)
        } else {
            performSegue(withIdentifier: "SettingsSegue", sender: nil)
        }
    }
    
    func getAccountDetails(_ accountID: String, client: SbankenClient, userID: String) {
        showSpinner(self.spinner)
        
        client.accounts(userId: userID, success: { (accs) in
            self.clearSpinner(self.spinner)
            
            let account = accs.filter { $0.accountId == accountID }.first
            
            if let account = account {
                DispatchQueue.main.async {
                    self.accountAvailableText.text = self.nokFor(double: account.available)
                    self.accountBalanceText.text = self.nokFor(double: account.balance)
                    
                    self.getAccountTransactions(account.accountId, client: client, userID: userID)
                }
            }
        }) { (error, errorString) in
            self.clearSpinner(self.spinner)

            if let error = error {
                print("Unable to get account \(error)")
            }
            
            if let errorString = errorString {
                print("Unable to get account reason \(errorString)")
            }

            DispatchQueue.main.async {
                self.alertPopup(title: "En feil har oppstått", message: "Kunne ikke hente konto")
                
                return
            }
        }
    }

    func getAccountTransactions(_ accountID: String, client: SbankenClient, userID: String) {
        print(accountID)
        print(userID)

        showSpinner(self.spinner)
        
        guard let startDate = Calendar.current.date(
            byAdding: .month,
            value: -3,
            to: Date()) else {
                return
        }

        client.transactions(userId: userID, accountId: accountID, startDate: startDate, success: { (trans) in
            self.clearSpinner(self.spinner)
            
            DispatchQueue.main.async {
                self.transactions = trans.items
                
                self.transactionTableView.reloadData()
            }
        }) { (err) in
            self.clearSpinner(self.spinner)
            
            if let error = err {
                print("Unable to get transactions \(error)")
            }
            
            DispatchQueue.main.async {
                self.alertPopup(title: "En feil har oppstått", message: "Kunne ikke hente transaksjoner")
                
                return
            }
        }
    }
    
    @IBAction func unwindToMain(segue:UIStoryboardSegue) {
        print("rewind")

        updateScreen()
    }
    
    func updateAccountName() {
        if let defaultAccount = defaultAccount() {
            accountNameText.text = defaultAccount
        }
    }

func nokFor(double: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencySymbol = ""
    formatter.currencyDecimalSeparator = ","
    formatter.currencyGroupingSeparator = " "
    
    if let formatted = formatter.string(from: double as NSNumber) {
        return "\(formatted) kr"
    } else {
        return "\(double)"
    }
}

    @IBAction func refresh(_ sender: Any) {
        print("refresh")

        updateScreen()
    }
}

extension ViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Siste \(transactions.count) transaksjoner"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath) as! TransactionCell
        
        cell.amountLabel.text = nokFor(double: transactions[indexPath.row].amount)
        cell.descriptionLabel.text = transactions[indexPath.row].text
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        
        if let date = transactions[indexPath.row].accountingDate {
            cell.dateLabel.text = dateFormatter.string(from: date)
        }
        
        if (transactions[indexPath.row].amount >= 0) {
            cell.backgroundColor = UIColor.white
        } else {
            cell.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.9, alpha: 1.0)
        }
        
        return cell
    }
}

extension ViewController {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
}
