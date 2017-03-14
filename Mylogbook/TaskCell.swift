
import UIKit
import BEMCheckBox

// MARK: Task Cell

class TaskCell: UITableViewCell {
    
    // MARK: Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addDashedBottomBorder()
    }
    
    func addDashedBottomBorder() {
        let border: CAShapeLayer = CAShapeLayer()
        
        let name = "Dashed Bottom Border"
        
        let color = DarkTheme.base(.divider).uiColor.cgColor
        
        let bounds = CGRect(x: 0, y: 0, width: frame.width - 12, height: 0)
        
        let bezierRect = CGRect(x: 0, y: bounds.height, width: bounds.width, height: 0)
        
        border.name = name
        border.bounds = bounds
        border.position = CGPoint(x: frame.width / 2, y: frame.height)
        border.fillColor = color
        border.strokeColor = color
        border.lineWidth = 2.0
        border.lineJoin = kCALineJoinMiter
        border.lineDashPattern = [3, 3]
        border.path = UIBezierPath(roundedRect: bezierRect, cornerRadius: 0).cgPath
        
        if layer.sublayers?.last?.name == name { layer.sublayers?.removeLast() }
        
        layer.addSublayer(border)
    }
}
