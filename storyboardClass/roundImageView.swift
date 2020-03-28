



import UIKit

@IBDesignable
class RoundImgaeView:UIImageView{

    
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }

    
    public enum State {
        case inactive
        case active
        case error
    }
    
    @IBInspectable var inactiveColor: UIColor = UIColor.clear {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var activeColor: UIColor = UIColor.gray {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var errorColor: UIColor = UIColor.red {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var round: CGFloat = 8.0 {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var borderWidth1: CGFloat = 8.0 {
        didSet {
            setupView()
        }
    }
    
    
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        setupView()
    }
    
    override var intrinsicContentSize : CGSize {
        
        return CGSize(width: 16, height: 16)
    }
    
    
    
    override var backgroundColor: UIColor? {
        didSet {
        }
    }
    
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        //backgroundColor = UIColor.gray
        
    }
    
    fileprivate func setupView() {
        
        layer.cornerRadius = round
        layer.borderWidth = borderWidth1
        layer.borderColor = activeColor.cgColor
        layer.masksToBounds = true
        
        
        self.backgroundColor = inactiveColor
        
        
        
    }
    
        override func draw(_ rect: CGRect)
    {
        
        
        
    }
    
    fileprivate func colorsForState(_ state: State) -> (backgroundColor: UIColor, borderColor: UIColor) {
        
        switch state {
        case .inactive: return (inactiveColor, activeColor)
        case .active: return (activeColor, activeColor)
        case .error: return (errorColor, errorColor)
        }
    }
    
    func animateState(_ state: State) {
        
        let colors = colorsForState(state)
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                
                self.backgroundColor = colors.backgroundColor
                self.layer.borderColor = colors.borderColor.cgColor
                
        },
            completion: nil
        )
    }
}
