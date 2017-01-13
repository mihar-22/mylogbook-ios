
import SCLAlertView

class Alert: SCLAlertView {
    private let appearance = SCLAlertView.SCLAppearance(
        kTitleTop: 40,
        kWindowWidth: 250,
        kTextFont: UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight),
        kButtonFont: UIFont.systemFont(ofSize: 13, weight: UIFontWeightBold),
        showCloseButton: false,
        showCircularIcon: false,
        contentViewCornerRadius: 2,
        buttonCornerRadius: 2
    )
    
    required init() {
        super.init(appearance: appearance)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addPositiveButton(_ title: String, action: @escaping () -> Void) {
        addButton(title,
                  backgroundColor: DarkTheme.brand.uiColor,
                  textColor: LightTheme.base(.primary).uiColor,
                  showDurationStatus: false,
                  action: action)
    }

    func addNegativeButton(_ title: String, action: @escaping () -> Void) {
        addButton(title,
                  backgroundColor: DarkTheme.error.uiColor,
                  textColor: LightTheme.base(.primary).uiColor,
                  showDurationStatus: false,
                  action: action)
    }
    
    func addCloseButton(_ title: String) {
        addButton(title,
                  backgroundColor: DarkTheme.error.uiColor,
                  textColor: LightTheme.base(.primary).uiColor,
                  showDurationStatus: false,
                  action: { self.hideView() })
    }
}
