import UIKit

final class AnimatableImageView: UIView {
    fileprivate let imageView = UIImageView()
    override var contentMode: UIViewContentMode {
        didSet { update() }
    }
    
    override var frame: CGRect {
        didSet { update() }
    }
    
    var image: UIImage? {
        didSet {
            imageView.image = image
            update()
        }
    }
    
    init() {
        super.init(frame: .zero)
        clipsToBounds = true
        addSubview(imageView)
        imageView.contentMode = .scaleToFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension AnimatableImageView {
    func update() {
        guard let image = image else { return }
        
        switch contentMode {
        case .scaleToFill:
            imageView.bounds = Utilities.rect(forSize: bounds.size)
            imageView.center = Utilities.center(forSize: bounds.size)
        case .scaleAspectFit:
            imageView.bounds = Utilities.aspectFitRect(forSize: image.size, insideRect: bounds)
            imageView.center = Utilities.center(forSize: bounds.size)
        case .scaleAspectFill:
            imageView.bounds = Utilities.aspectFillRect(forSize: image.size, insideRect: bounds)
            imageView.center = Utilities.center(forSize: bounds.size)
        case .redraw:
            imageView.bounds = Utilities.aspectFillRect(forSize: image.size, insideRect: bounds)
            imageView.center = Utilities.center(forSize: bounds.size)
        case .center:
            imageView.bounds = Utilities.rect(forSize: image.size)
            imageView.center = Utilities.center(forSize: bounds.size)
        case .top:
            imageView.bounds = Utilities.rect(forSize: image.size)
            imageView.center = Utilities.centerTop(forSize: image.size, insideSize: bounds.size)
        case .bottom:
            imageView.bounds = Utilities.rect(forSize: image.size)
            imageView.center = Utilities.centerBottom(forSize: image.size, insideSize: bounds.size)
        case .left:
            imageView.bounds = Utilities.rect(forSize: image.size)
            imageView.center = Utilities.centerLeft(forSize: image.size, insideSize: bounds.size)
        case .right:
            imageView.bounds = Utilities.rect(forSize: image.size)
            imageView.center = Utilities.centerRight(forSize: image.size, insideSize: bounds.size)
        case .topLeft:
            imageView.bounds = Utilities.rect(forSize: image.size)
            imageView.center = Utilities.topLeft(forSize: image.size, insideSize: bounds.size)
        case .topRight:
            imageView.bounds = Utilities.rect(forSize: image.size)
            imageView.center = Utilities.topRight(forSize: image.size, insideSize: bounds.size)
        case .bottomLeft:
            imageView.bounds = Utilities.rect(forSize: image.size)
            imageView.center = Utilities.bottomLeft(forSize: image.size, insideSize: bounds.size)
        case .bottomRight:
            imageView.bounds = Utilities.rect(forSize: image.size)
            imageView.center = Utilities.bottomRight(forSize: image.size, insideSize: bounds.size)
        }
        imageView.frame.size.height = imageView.frame.size.width
        imageView.image = imageView.image?.circle
        
        
        
        
        //        self.imageView.frame.size.height =  self.imageView.frame.width
        ////        DispatchQueue.main.async {
        //            self.imageView.layer.cornerRadius = self.imageView.frame.size.height/2
        //            self.imageView.clipsToBounds = true
        ////        }
        
        
        //        let path = CGMutablePath()
        //        path.addArc(center: CGPoint(x: imageView.frame.size.width/2, y: imageView.frame.size.height/2), radius: imageView.frame.size.width/2, startAngle: 0.0, endAngle: 2.0 * CGFloat.pi, clockwise: false)
        //        path.addRect(CGRect(origin: .zero, size: imageView.frame.size))
        //
        //        let maskLayer = CAShapeLayer()
        //        maskLayer.backgroundColor = UIColor.black.cgColor
        //        maskLayer.path = path
        //        maskLayer.fillRule = kCAFillRuleEvenOdd
        //
        //        layerView.frame = imageView.frame
        //        layerView.backgroundColor = UIColor.black
        //        layerView.layer.mask = maskLayer
        //        layerView.clipsToBounds = true
        
        
        //        let layer = CAShapeLayer()
        //        layer.path = UIBezierPath(arcCenter: CGPoint(x: imageView.frame.size.width/2, y: imageView.frame.size.height/2), radius: imageView.frame.size.width/2, startAngle: 0.0, endAngle: 2.0 * CGFloat.pi, clockwise: false).cgPath
        //        layer.fillColor = UIColor.red.cgColor
        //        layer.backgroundColor = UIColor.black.cgColor
        //        imageView.layer.addSublayer(layer)
        //
        
        
        //        let outerRect = imageView.frame
        //        let innerRect: CGRect = outerRect.insetBy(dx: 30, dy: 30)
        //        let path = UIBezierPath(roundedRect: outerRect, cornerRadius: 0)
        //        path.append(UIBezierPath(roundedRect: innerRect, cornerRadius: imageView.frame.size.width/2).reversing())
        //        path.usesEvenOddFillRule = true
        //        UIColor.orange.set()
        //        path.fill()
        //
        //        let layer = CAShapeLayer()
        //        layer.path = path.cgPath
        //        imageView.layer.addSublayer(layer)
        
    }
}



extension UIImage {
    var circle: UIImage {
        let square = size.width < size.height ? CGSize(width: size.width, height: size.width) : CGSize(width: size.height, height: size.height)
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
}

