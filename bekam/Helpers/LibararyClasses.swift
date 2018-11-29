import UIKit

public protocol LiquidLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat
}

public class LiquidCollectionViewLayout: UICollectionViewLayout {
    
    var delegate: LiquidLayoutDelegate!
    var cellPadding: CGFloat = 10.0
    var cellWidth: CGFloat = 150.0
    var cachedWidth: CGFloat = 0.0
    
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    fileprivate var contentHeight: CGFloat  = 0.0
    fileprivate var contentWidth: CGFloat {
        if let collectionView = collectionView {
            let insets = collectionView.contentInset
            return collectionView.bounds.width - (insets.left + insets.right)
        }
        return 0
    }
    fileprivate var numberOfItems = 0
    
    override public var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override public func prepare() {
        
        guard let collectionView = collectionView else { return }
        
        let numberOfColumns = Int(contentWidth / cellWidth) // #3
        let totalSpaceWidth = contentWidth - CGFloat(numberOfColumns) * cellWidth
        let horizontalPadding = totalSpaceWidth / CGFloat(numberOfColumns + 1)
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        
        if (contentWidth != cachedWidth || self.numberOfItems != numberOfItems) { // #1
            cache = []
            contentHeight = 0
            self.numberOfItems = numberOfItems
        }
        
        if cache.isEmpty { // #2
            cachedWidth = contentWidth
            var xOffset = [CGFloat]()
            for column in 0 ..< numberOfColumns {
                xOffset.append(CGFloat(column) * cellWidth + CGFloat(column + 1) * horizontalPadding)
            }
            var column = 0
            var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
            
            for row in 0 ..< numberOfItems {
                
                let indexPath = IndexPath(row: row, section: 0)
                
                let cellHeight = delegate.collectionView(collectionView: collectionView, heightForCellAtIndexPath: indexPath, width: cellWidth)
                let height = cellPadding +  cellHeight + cellPadding
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: cellWidth, height: height)
                let insetFrame = frame.insetBy(dx: 0, dy: cellPadding)
                
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath as IndexPath) // #4
                attributes.frame = insetFrame // #5
                cache.append(attributes) // #6
                contentHeight = max(contentHeight, frame.maxY)
                yOffset[column] = yOffset[column] + height
                
                if column >= (numberOfColumns - 1) {
                    column = 0
                } else {
                    column = column + 1
                }
            }
        }
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache { // #7
            if attributes.frame.intersects(rect) { // #8
                layoutAttributes.append(attributes) // #9
            }
        }
        return layoutAttributes
    }
}

@IBDesignable
class EdgeInsetLabel: UILabel {
    
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return textRect.inset(by:invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by:textInsets))
    }
}

extension EdgeInsetLabel {
    
    @IBInspectable
    var leftTextInset: CGFloat {
        set { textInsets.left = newValue }
        get { return textInsets.left }
    }
    
    @IBInspectable
    var rightTextInset: CGFloat {
        set { textInsets.right = newValue }
        get { return textInsets.right }
    }
    
    @IBInspectable
    var topTextInset: CGFloat {
        set { textInsets.top = newValue }
        get { return textInsets.top }
    }
    
    @IBInspectable
    var bottomTextInset: CGFloat {
        set { textInsets.bottom = newValue }
        get { return textInsets.bottom }
    }
}

protocol KeyboardPusherDelegate {
    func keyboardWillShow(_ notification : Notification)
    func keyboardWillHide(_ notification : Notification)
    func addKeyboardObservers()
    func getContainer()->UIViewController
    func getExtraPush()->CGFloat
}

class KeyboardTextFieldPusher {
    

    var kbheight:CGFloat?
    var pushAmount:CGFloat?
    var container:UIViewController!
    var extraPush:CGFloat!
    var delegate:KeyboardPusherDelegate?
    
    init(delegate:KeyboardPusherDelegate){
        
        self.delegate = delegate
        self.container = delegate.getContainer()
        self.extraPush = delegate.getExtraPush()
        self.delegate?.addKeyboardObservers()
    }
    
    public func keyboardWillShow(_ notification : Notification){
        
        print("KB SHOWED FROM PUSHER")
        
        // push content
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            if container.view.frame.origin.y == 0{
                kbheight = keyboardSize.height
                pushAmount = getPushAmount(kbheight:kbheight!)
                container.view.frame.origin.y -= pushAmount!
                
            }
        }
    }
    
    public func keyboardWillHide(_ notification : Notification){
        
        print("KB SHOWED FROM PUSHER")
        
        // push content
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if container.view.frame.origin.y != 0{
                kbheight = keyboardSize.height
                container.view.frame.origin.y += pushAmount ?? 0
            }
        }
        
    }
    
    func getPushAmount(kbheight:CGFloat) -> CGFloat{
        
        guard let item = container.view.firstResponder else {
            return 0
        }
        
        let safeLine = container.view.frame.maxY - kbheight - extraPush
        let itemY = item.frame.minY + item.superview!.frame.minY
        
        let offset = itemY - safeLine + item.frame.height + 16
        
        if( offset < 0 ){
            return 0
        }
        
        return offset
        
    }
    
    
    
}
