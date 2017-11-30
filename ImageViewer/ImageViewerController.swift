import UIKit
import AVFoundation
import AVKit
import Kingfisher
public final class ImageViewerController: UIViewController {
    @IBOutlet fileprivate var scrollView: UIScrollView!
    @IBOutlet fileprivate var imageView: UIImageView!
    @IBOutlet fileprivate var activityIndicator: UIActivityIndicatorView!
    var playerController : AVPlayerViewController?
    @IBOutlet weak var topArea: UIView!
    var playerLayer: AVPlayerLayer?
    @IBOutlet weak var imgOwner: UIImageView!
    @IBOutlet weak var lblOwnerName: UILabel!
    @IBOutlet weak var lblFeedTime: UILabel!
    //private let images : [UIImage]?
    fileprivate var transitionHandler: ImageViewerTransitioningHandler?
    var item : AVPlayerItem?
    fileprivate let feedcontant: feedContant?
    fileprivate var spb: SegmentedProgressBar!
    fileprivate let configuration: ImageViewerConfiguration?
    
    @IBOutlet weak var bottomGradiant: UIView!
    @IBOutlet weak var lblDiscription: UILabel!
    @IBOutlet weak var lblcmt: UILabel!
    @IBOutlet weak var lblLike: UILabel!
    @IBOutlet weak var activateStoryBottom: UIView!
    @IBOutlet weak var bottomArea: UIView!
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public init(configuration: ImageViewerConfiguration?,contant:feedContant?) {
        self.configuration = configuration
        self.feedcontant = contant
        super.init(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        modalPresentationCapturesStatusBarAppearance = true
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupBottom()
        stupeOwnerDetail()
        setupFeedDetail()
        imageView.image = configuration?.imageView?.image ?? configuration?.image
        
        setupScrollView()
        setupGestureRecognizers()
        setupTransitions()
        setupActivityIndicator()
    }
    @IBAction func btntestA(_ sender: UIButton) {
        
        if self.configuration?.actiondelegate != nil {
            self.configuration?.actiondelegate?.actionTrigered(action: actionType(rawValue: sender.tag)!, feedId: (self.feedcontant?.feedId)!)
        }
    }
    @IBAction func swichAction(_ sender: UISwitch) {
        print(sender.isOn)
        if self.configuration?.actiondelegate != nil {
            self.configuration?.actiondelegate?.shouldMakeIt(active: sender.isOn, feedId: (self.feedcontant?.feedId)!)
        }
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    public override func viewWillAppear(_ animated: Bool) {
        setupSegmentedProgressBar()
        DispatchQueue.main.async {
           self.setupGradiant()
        }
        
    }
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayerItem {
            switch keyPath {
            case "playbackBufferEmpty"?:
                // Show loader
                self.activityIndicator.startAnimating()
                if self.feedcontant?.type != .feed {
                    spb.isPaused = true
                }
                
                print("buffer")
            case "playbackLikelyToKeepUp"? :
               
                if self.feedcontant?.type != .feed {
                     spb.isPaused = false
                }
                self.activityIndicator.stopAnimating()
                // Hide loader
                print("playing")
            case "playbackBufferFull"? :
                
                if self.feedcontant?.type != .feed {
                    spb.isPaused = false
                }
                self.activityIndicator.stopAnimating()
                // Hide loader
                print("playing")
            case .none:
                break
            case .some(_):
                break
            }
        }
    }
    func dismissAll()  {
        if item != nil {
            item?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            item?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
            item?.removeObserver(self, forKeyPath: "playbackBufferFull")
        }
         self.dismiss(animated: true)
    }
}

extension ImageViewerController: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard let image = imageView.image else { return }
        let imageViewSize = Utilities.aspectFitRect(forSize: image.size, insideRect: imageView.frame)
        let verticalInsets = -(scrollView.contentSize.height - max(imageViewSize.height, scrollView.bounds.height)) / 2
        let horizontalInsets = -(scrollView.contentSize.width - max(imageViewSize.width, scrollView.bounds.width)) / 2
        scrollView.contentInset = UIEdgeInsets(top: verticalInsets, left: horizontalInsets, bottom: verticalInsets, right: horizontalInsets)
    }
}

extension ImageViewerController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return scrollView.zoomScale == scrollView.minimumZoomScale
    }
}

private extension ImageViewerController {
    func setupScrollView() {
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
    }
    
    func setupGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.numberOfTapsRequired = 2
        tapGestureRecognizer.addTarget(self, action: #selector(imageViewDoubleTapped))
        imageView.addGestureRecognizer(tapGestureRecognizer)
    
        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.addTarget(self, action: #selector(imageViewPanned(_:)))
        panGestureRecognizer.delegate = self
        imageView.addGestureRecognizer(panGestureRecognizer)
        
        
        let panGestureRecognizerbottomArea = UIPanGestureRecognizer()
        panGestureRecognizerbottomArea.addTarget(self, action: #selector(imageViewPanned(_:)))
        panGestureRecognizerbottomArea.delegate = self

        bottomArea.addGestureRecognizer(panGestureRecognizerbottomArea)

    }
    
    func setupTransitions() {
        guard let imageView = configuration?.imageView else { return }
        transitionHandler = ImageViewerTransitioningHandler(fromImageView: imageView, toImageView: self.imageView)
        transitioningDelegate = transitionHandler
    }
    
    func setupActivityIndicator() {
        guard let block = configuration?.imageBlock else { return }
        activityIndicator.startAnimating()
        block { [weak self] image in
            guard let image = image else { return }
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.imageView.image = image
            }
        }
    }
    func stupeOwnerDetail()  {
        self.imgOwner.layer.cornerRadius = self.imgOwner.frame.size.width/2
        self.imgOwner.clipsToBounds = true
        
        self.lblOwnerName.text = self.feedcontant?.owner.name!
        if self.feedcontant?.owner.originalImage == "" {
            self.imgOwner.image = self.feedcontant?.owner.image
        } else {
            self.imgOwner.kf.indicatorType = .activity
            self.imgOwner.kf.indicator?.startAnimatingView()
            self.imgOwner.kf.setImage(with: URL(string:(self.feedcontant?.owner.originalImage)! ))
        }
        
    }
    
    func setupFeedDetail()   {
      self.lblFeedTime.text =  self.feedcontant?.time
        self.lblLike.text = "\(self.feedcontant!.lits!) Lits"
        self.lblcmt.text = "\(self.feedcontant!.comments!) Comments"
        self.lblDiscription.text = self.feedcontant?.discription!
    }

    func setupVideoPlayer()  {
        item = AVPlayerItem(url: URL(string: (self.feedcontant?.orignalMedia)!)!)
        let duration : CMTime = item!.asset.duration
        item?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        item?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        item?.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
        let seconds : Float64 = CMTimeGetSeconds(duration)
        let player = AVPlayer(playerItem: item)
        player.actionAtItemEnd = .none
        if self.feedcontant?.type != .feed {
        spb = SegmentedProgressBar(numberOfSegments: 1, duration: seconds)
        spb.frame = CGRect(x: 15, y: 15, width: scrollView.frame.width - 30, height: 4)
        spb.delegate = self
        spb.topColor = UIColor.white
        spb.bottomColor = UIColor.white.withAlphaComponent(0.25)
        spb.padding = 2
        view.addSubview(spb)
        view.bringSubview(toFront: spb)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(ImageViewerController.playerItemDidReachEnd(notification:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: item)
       
        playerController = AVPlayerViewController()
        playerController?.view.contentMode = UIViewContentMode.scaleAspectFill
       playerController?.view.isUserInteractionEnabled = false
        playerController?.showsPlaybackControls = false
        
        playerController?.player = player
        playerController?.view.frame = scrollView.frame
        self.addChildViewController(playerController!)
        self.imageView.addSubview((playerController?.view)!)
        //self.view.sendSubview(toBack: (playerController?.view)!)

        
//        playerLayer = AVPlayerLayer(player: player)
//        playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill //AVLayerVideoGravity.resizeAspectFill
//        playerLayer?.frame = self.view.frame
//        playerLayer!.use
//        self.view.layer.insertSublayer(playerLayer!, at: 0)
        player.play()
        if self.feedcontant?.type != .feed {
            self.spb.startAnimation()
            self.spb.isPaused = true
        }
    }
    func setupGradiant()  {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: self.topArea.frame.size)
        gradient.colors = [UIColor.black.withAlphaComponent(0.8).cgColor,UIColor.clear.cgColor]
        topArea.layer.insertSublayer(gradient, at: 0)
//        DispatchQueue.main.async {
            let gradientbottm = CAGradientLayer()
        gradientbottm.frame =  CGRect(origin: .zero, size: self.bottomGradiant.frame.size)

            gradientbottm.colors = [UIColor.black.withAlphaComponent(0.8).cgColor,UIColor.clear.cgColor]
            gradientbottm.startPoint = CGPoint(x: 0.0, y: 1.0)
            gradientbottm.endPoint = CGPoint(x: 0.0, y: 0.0)
            self.bottomGradiant.layer.insertSublayer(gradientbottm, at: 0)
//        }
        
    }
    func setupBottom()  {
        if self.feedcontant?.type == .feed {
            self.bottomArea.isHidden = false
            self.activateStoryBottom.isHidden = true
        }else if self.feedcontant?.type == .activateStory {
            self.bottomArea.isHidden = true
            self.activateStoryBottom.isHidden = false
        } else {
            self.bottomArea.isHidden = true
            self.activateStoryBottom.isHidden = true
        }
    }
    func setupSegmentedProgressBar()  {
        
        if self.feedcontant?.mediaType != mediaType.image{
             self.activityIndicator.startAnimating()
//            self.preParevideo(compilation: { (ready) in
//                self.playVideo()
//            })
            DispatchQueue.main.async {
                self.setupVideoPlayer()
            }
            
        } else {
            if self.feedcontant?.type != .feed {
            spb = SegmentedProgressBar(numberOfSegments: 1, duration: 3)
            spb.frame = CGRect(x: 15, y: 15, width: scrollView.frame.width - 30, height: 4)
            spb.delegate = self
            spb.topColor = UIColor.white
            spb.bottomColor = UIColor.white.withAlphaComponent(0.25)
            spb.padding = 2
            view.addSubview(spb)
                
                
            }
            activityIndicator.startAnimating()
            imageView.kf.setImage(with: URL(string: (self.feedcontant?.orignalMedia)!), placeholder: configuration?.imageView?.image ?? configuration?.image, options: [.transition(.fade(0.5)), .forceTransition], progressBlock: nil, completionHandler: { image ,erroe, cash ,options in
                self.activityIndicator.stopAnimating()
                if  self.spb != nil{
                   self.spb.startAnimation()
                }
                
            })
            
        }
        
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        //guard let playerItemq = notification.object as? AVPlayerItem else { return }
        //playerItem.seek(to: kCMTimeZero)
    }
    @IBAction func closeButtonPressed() {
        dismissAll()
        
        //dismiss(animated: true)
    }
    
    @objc func imageViewDoubleTapped() {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
    
    @objc func imageViewPanned(_ recognizer: UIPanGestureRecognizer) {
        guard transitionHandler != nil else { return }
            
        let translation = recognizer.translation(in: imageView)
        let velocity = recognizer.velocity(in: imageView)
        
        switch recognizer.state {
        case .began:
            transitionHandler?.dismissInteractively = true
           dismissAll()
        case .changed:
            let percentage = abs(translation.y) / imageView.bounds.height
            transitionHandler?.dismissalInteractor.update(percentage: percentage)
            transitionHandler?.dismissalInteractor.update(transform: CGAffineTransform(translationX: translation.x, y: translation.y))
        case .ended, .cancelled:
            transitionHandler?.dismissInteractively = false
            let percentage = abs(translation.y + velocity.y) / imageView.bounds.height
            if percentage > 0.25 {
                transitionHandler?.dismissalInteractor.finish()
            } else {
                transitionHandler?.dismissalInteractor.cancel()
            }
        default: break
        }
    }
}
extension ImageViewerController:SegmentedProgressBarDelegate{

    
    func segmentedProgressBarChangedIndex(index: Int) {
        print("Now showing index: \(index)")
        updateImage(index: index)
    }
    
    func segmentedProgressBarFinished() {
//       playerController?.view.removeFromSuperview()
//        DispatchQueue.main.async {
//            self.dismiss(animated: true)
//        }
dismissAll()
        print("Finished!")
    }
    private func updateImage(index: Int) {
       // iv.image = images[index]
    }
}
