import UIKit

extension UIViewController {
    func showSpinner(_ spinner: SpinnerViewController) {
        DispatchQueue.main.async {
            self.addChild(spinner)
            spinner.view.frame = self.view.frame
            self.view.addSubview(spinner.view)
            spinner.didMove(toParent: self)
        }
    }
    
    func clearSpinner(_ spinner: SpinnerViewController) {
        DispatchQueue.main.async {
            spinner.willMove(toParent: nil)
            spinner.view.removeFromSuperview()
            spinner.removeFromParent()
        }
    }
    
}
