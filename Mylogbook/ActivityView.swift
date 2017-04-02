
import UIKit

// MARK: Acitivity View

protocol ActivityView {
    func showActivityIndicator()
    
    func hideActivityIndicator(replaceWith button: UIBarButtonItem?)
}

extension ActivityView where Self: UIViewController {
    private func activityIndicator() -> UIActivityIndicatorView {
        let frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        let indicator = UIActivityIndicatorView(frame: frame)
        
        indicator.activityIndicatorViewStyle = .gray
        
        return indicator
    }
    
    func showActivityIndicator() {
        let indicator = activityIndicator()
        
        let button = UIBarButtonItem(customView: indicator)
        
        self.navigationItem.setRightBarButton(button, animated: true)
        
        indicator.startAnimating()
    }
    
    func showActivityIndicator(for button: UIButton) {
        let indicator = activityIndicator()
        
        indicator.center = CGPoint(x: button.bounds.width / 2, y: button.bounds.height / 2)
        
        button.setTitleColor(UIColor.clear.withAlphaComponent(0), for: .disabled)
        
        button.isEnabled = false
        
        button.addSubview(indicator)
        
        indicator.startAnimating()
    }
    
    func hideActivityIndicator(replaceWith button: UIBarButtonItem? = nil) {
        let indicator = self.navigationItem.rightBarButtonItem?.customView as? UIActivityIndicatorView
        
        indicator?.stopAnimating()
        
        self.navigationItem.setRightBarButton(button, animated: true)
    }
    
    func hideActivityIndicator(for button: UIButton) {
        if let indicator = button.subviews.first(where: { $0 is UIActivityIndicatorView }) {
            indicator.removeFromSuperview()
        }
        
        button.setTitleColor(UIColor.lightGray.withAlphaComponent(0.8), for: .disabled)
        
        button.isEnabled = true
    }
}
