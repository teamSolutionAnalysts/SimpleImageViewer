import UIKit
import AVFoundation
import AVKit
import Kingfisher
public final class ImageViewerController: UIViewController {
    
    @IBOutlet weak var imgPrivate: UIImageView!
    @IBOutlet weak var imgPrivacy: UIImageView!
    var observerHandler = false
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
    @IBOutlet weak var proghreshBarYpos: NSLayoutConstraint!
    @IBOutlet weak var btnLiveViewer: UIButton!
    fileprivate var spb: SegmentedProgressBar!
    fileprivate let configuration: ImageViewerConfiguration?
    fileprivate var shouldAppear = true
    fileprivate var viewed = false
    fileprivate var currentIndex = 0
    @IBOutlet weak var swichActive: UISwitch!
    @IBOutlet weak var lblActiveSory: UILabel!
    @IBOutlet weak var switchWidth: NSLayoutConstraint!
    @IBOutlet weak var btnViews: UIButton!
    fileprivate let feedList:[feed]?
    @IBOutlet weak var bottomGradiant: UIView!
    @IBOutlet weak var lblDiscription: UILabel!
    @IBOutlet weak var lblcmt: UILabel!
    @IBOutlet weak var lblLike: UILabel!
    @IBOutlet weak var activateStoryBottom: UIView!
    @IBOutlet weak var bottomArea: UIView!
    
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnComment: UIButton!
    
    
    public init(configuration: ImageViewerConfiguration?,contant:feedContant?) {
        self.configuration = configuration
        self.feedcontant = contant
        self.feedList = self.feedcontant?.feedList
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
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(ImageViewerController.updateCounters(_:)), name: NSNotification.Name(rawValue: "updateCounters"), object: nil)
        setupScrollView()
        setupGestureRecognizers()
        setupTransitions()
        setupActivityIndicator()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = false
        
        
        if self.player != nil {
            self.player.pause()
        }
    }
    
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        proghreshBarYpos.constant = isIphoneX() ? 60 : 40
        if shouldAppear {
            shouldAppear = false
            setupSegmentedProgressBarForFeed()
            setupeOwnerDetail(user: (self.feedcontant?.owner)!)
            setupBottom()
            display(selectedFeed: self.feedList![0])
            setUpNavigationBar()
            DispatchQueue.main.async {
                self.setupGradiant()
            }
        }
        
        if self.player != nil {
            self.player.play()
        }
    }
    
    func setUpNavigationBar()  {
        UIApplication.shared.isStatusBarHidden = true
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        navigationController?.navigationItem.hidesBackButton = true
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.view.backgroundColor = .clear
    }
    
    func setupSegmentedProgressBarForFeed()  {
        if self.feedcontant?.feedType  == .story {
            self.spb = SegmentedProgressBar(numberOfSegments: self.feedList!.count, durations: (self.feedList?.map({$0.duration}))!)
            self.spb.frame = CGRect(x: 15, y: (isIphoneX() ?50:30), width: UIScreen.main.bounds.size.width - 30, height: 3)
            self.spb.delegate = self
            self.spb.topColor = UIColor.white
            self.spb.bottomColor = UIColor.white.withAlphaComponent(0.25)
            self.spb.padding = 2
            self.view.addSubview(self.spb)
            self.view.bringSubview(toFront: self.spb)
            self.spb.startAnimation()
            self.spb.isPaused = true
        }
    }
    
    
    
    func setupBottom()  {
        
        if self.feedcontant?.bottomtype == .feed {//
            self.bottomArea.isHidden = false
            btnLike.isHidden = false
            lblLike.isHidden = false
            lblcmt.isHidden = false
            btnComment.isHidden = false
            btnShare.isHidden = false
            btnLiveViewer.isHidden = false
            self.activateStoryBottom.isHidden = true
            btnShare.isHidden =  self.feedList![currentIndex].branchLink.count > 0 ? false : true
        }else if self.feedcontant?.bottomtype == .activateStory {
            self.bottomArea.isHidden = true
            self.activateStoryBottom.isHidden = false
            self.btnViews.isHidden = true
            self.lblActiveSory.text = "Activate this story"
            switchWidth.constant = 51
            swichActive.isHidden = false
        } else if self.feedcontant?.bottomtype == .activateStoryWithEye {//own story
            self.bottomArea.isHidden = false
            self.activateStoryBottom.isHidden = false
            self.lblActiveSory.text = "Activate this story"
            self.btnViews.isHidden = false
            switchWidth.constant = 51
            swichActive.isHidden = false
            btnLike.isHidden = true
            lblLike.isHidden = true
            lblcmt.isHidden = true
            btnComment.isHidden = true
            btnShare.isHidden = true
            btnLiveViewer.isHidden = true
        } else if self.feedcontant?.bottomtype == .eye {//own story
            self.bottomArea.isHidden = false
            btnLike.isHidden = true
            lblLike.isHidden = true
            lblcmt.isHidden = true
            btnComment.isHidden = true
            btnShare.isHidden = true
            btnLiveViewer.isHidden = true
            self.activateStoryBottom.isHidden = false
            switchWidth.constant = 0
            self.lblActiveSory.text = ""
            self.btnViews.isHidden = false
            swichActive.isHidden = true
        } else {//other story
            self.bottomArea.isHidden = false
            btnLike.isHidden = true
            lblLike.isHidden = true
            lblcmt.isHidden = true
            btnComment.isHidden = true
            btnShare.isHidden = true
            btnLiveViewer.isHidden = true
            self.activateStoryBottom.isHidden = false
            switchWidth.constant = 0
            self.lblActiveSory.text = ""
            self.btnViews.isHidden = true
            swichActive.isHidden = true
        }
    }
    
    func setupeOwnerDetail(user:owner)  {
        self.imgOwner.layer.cornerRadius = self.imgOwner.frame.size.width/2
        self.imgOwner.clipsToBounds = true
        self.lblOwnerName.text = user.name!
        if user.originalImage == "" {
            self.imgOwner.image = user.image
        } else {
            self.imgOwner.kf.indicatorType = .activity
            self.imgOwner.kf.setImage(with: URL(string:(user.originalImage)! ))
        }
    }
    func display(selectedFeed:feed)  {
        UIApplication.shared.isStatusBarHidden = true
        if  self.spb != nil{
            self.spb.isPaused = true
        }
        if selectedFeed.mediaType == .image{
            imageView.isUserInteractionEnabled = true
            activityIndicator.startAnimating()
            imageView.kf.setImage(with: URL(string: (selectedFeed.orignalMedia)!), placeholder: nil, options: [.transition(.fade(0.5)), .forceTransition], progressBlock: nil, completionHandler: { image ,erroe, cash ,options in
                if image != nil{
                    self.activityIndicator.stopAnimating()
                    if self.configuration?.actiondelegate != nil {
                        if !self.viewed{
                            self.viewed = true
                            self.configuration?.actiondelegate?.markAsViewed(feedId: selectedFeed.feedId)
                        }
                        
                    }
                    if  self.spb != nil{
                        self.spb.isPaused = false
                    }
                }
            })
        } else {
            if (self.feedcontant?.turnSoket)! {
                if self.configuration?.actiondelegate != nil {
                    self.configuration?.actiondelegate?.startListen(action: .Listen, feedId: self.feedList![currentIndex].feedId)
                }
            }
            activityIndicator.startAnimating()
            if  self.spb != nil{
                self.spb.isPaused = true
            }
            if selectedFeed.thumb.count > 0 {
                imageView.kf.setImage(with: URL(string: (selectedFeed.thumb)!), placeholder: nil, options: [.transition(.fade(0.5)), .forceTransition], progressBlock: nil, completionHandler: { image ,erroe, cash ,options in
                })
            }
            self.preParevideofor(userFeed: selectedFeed, compilation: { (ready) in
                self.imageView.isUserInteractionEnabled = true
                if !self.viewed{
                    self.viewed = true
                    self.configuration?.actiondelegate?.markAsViewed(feedId: selectedFeed.feedId)
                }
                self.playVideo()
            })
        }
        setupFeedDetail(userFeed: selectedFeed)
    }
    @objc func updateCounters(_ notification: Notification)  {
        print(notification.object as Any , notification.userInfo as Any)
        if ( notification.object! as! [String:Any])["type"] as! actionType == .like && ( notification.object! as! [String:Any])["feedId"] as! String == self.feedList![currentIndex].feedId  {
            let totalLit = (notification.object! as! [String:Any])["lits"] as! Int
            self.lblLike.text = "\(totalLit) Lits"
        }else  if ( notification.object! as! [String:Any])["type"] as! actionType == .more && ( notification.object! as! [String:Any])["feedId"] as! String == self.feedList![currentIndex].feedId {
            dismissAll()
        } else if ( notification.object! as! [String:Any])["type"] as! actionType == .Listen {
            let total = (notification.object! as! [String:Any])["users"] as! String
            
            self.btnLiveViewer.isHidden = false
            self.btnLiveViewer.setTitle("   \(total)", for: .normal)
            
        } else if ( notification.object! as! [String:Any])["type"] as! actionType == .comment {
            let total = (notification.object! as! [String:Any])["count"] as! Int
            self.lblcmt.text = "\(total) Comments"
            
        }
    }
    func setupFeedDetail(userFeed:feed)   {
        
        self.lblFeedTime.text =  userFeed.time
        self.lblLike.text = "\(userFeed.lits!) Lits"
        self.lblcmt.text = "\(userFeed.comments!) Comments"
        self.lblDiscription.text = userFeed.discription!
        if userFeed.individualFeedType == .liveStreamVideo{
            self.btnLiveViewer.setTitle(" \(userFeed.viewers!)", for: .normal)
        }
        self.btnViews.setTitle(" \(userFeed.viewers!)", for: .normal)
        if self.feedcontant?.feedType  == .story {
            if userFeed.privacyLevel == .publicFeed {
                self.imgPrivacy.isHidden = false
                self.imgPrivate.isHidden = true
            } else {
                self.imgPrivacy.isHidden = true
                self.imgPrivate.isHidden = false
            }
        } else {
            self.imgPrivate.isHidden = true
            self.imgPrivacy.isHidden = true
        }
        //         self.imgPrivacy.isHidden = (self.feedcontant?.feedType  == .story ? false : true)
        //        self.imgPrivacy.image = (userFeed.privacyLevel == .publicFeed ? #imageLiteral(resourceName: "public") : #imageLiteral(resourceName: "private"))
        
    }
    func preParevideofor(userFeed:feed, compilation: @escaping videoHandler)  {
        
        self.item = AVPlayerItem(url: URL(string: (userFeed.orignalMedia)!)!)
        
        //        self.item?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        //        self.item?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        //        self.item?.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
        observerHandler = true
        compilation(true)
    }
    func playVideo(){
        player = AVPlayer(playerItem: item)
        player.actionAtItemEnd = .none
        
        NotificationCenter.default.addObserver(self, selector: #selector(ImageViewerController.playerItemDidReachEnd(notification:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        
        playerController = AVPlayerViewController()
        playerController?.view.contentMode = UIViewContentMode.scaleAspectFill
        playerController?.view.isUserInteractionEnabled = false
        playerController?.showsPlaybackControls = false
        
        playerController?.player = player
        playerController?.view.frame = scrollView.frame
        self.addChildViewController(playerController!)
        self.imageView.addSubview((playerController?.view)!)
        
        player.play()
        self.observer = player.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 600), queue: DispatchQueue.main) {
            [weak self] time in
            
            if self?.player.currentItem?.status == AVPlayerItemStatus.readyToPlay {
                
                if let isPlaybackLikelyToKeepUp = self?.player.currentItem?.isPlaybackLikelyToKeepUp {
                    print(isPlaybackLikelyToKeepUp)
                    //do what ever you want with isPlaybackLikelyToKeepUp value, for example, show or hide a activity indicator.
                    self?.activityIndicator.stopAnimating()
                    if self?.spb != nil {
                        if (self?.spb.isPaused)! {
                            self?.spb.isPaused = false
                        }
                        
                    }
                } else {
                    self?.activityIndicator.startAnimating()
                    if self?.spb != nil {
                        if !(self?.spb.isPaused)! {
                            self?.spb.isPaused = true
                        }
                    }
                }
            } else {
                self?.activityIndicator.startAnimating()
                
                if self?.spb != nil {
                    if !(self?.spb.isPaused)! {
                        self?.spb.isPaused = true
                    }
                }
            }
        }
    }
    var observer:Any!
    var player : AVPlayer!
    private var observerContext = 0
    
    //    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    //        if object is AVPlayerItem {
    //            switch keyPath {
    //            case "playbackBufferEmpty"?:
    //                // Show loader
    //                self.activityIndicator.startAnimating()
    //                if self.spb != nil {
    //                    spb.isPaused = true
    //                }
    //
    //                print("playbackBufferEmpty")
    //            case "playbackLikelyToKeepUp"? :
    //
    //                if self.spb != nil {
    //                    spb.isPaused = false
    //                }
    //                self.activityIndicator.stopAnimating()
    //                // Hide loader
    //                print("playbackLikelyToKeepUp")
    //            case "playbackBufferFull"? :
    //
    //                if self.spb != nil {
    //                    spb.isPaused = false
    //                }
    //                self.activityIndicator.stopAnimating()
    //                // Hide loader
    //                print("playbackBufferFull")
    //            case .none:
    //                break
    //            case .some(_):
    //                break
    //            }
    //        }
    //    }
    func dismissAll()  {
        if observerHandler {
            if self.observer != nil {
                self.player.removeTimeObserver(self.observer)
                self.observer = nil
            }
        }
        self.dismiss(animated: true, completion: {
            UIApplication.shared.isStatusBarHidden = false
            if (self.feedcontant?.turnSoket)! {
                if self.configuration?.actiondelegate != nil {
                    self.configuration?.actiondelegate?.startListen(action: .Listen, feedId: "")
                }
            }
            
        })
    }
    @IBAction func btntestA(_ sender: UIButton) {
        if self.configuration?.actiondelegate != nil {
            
            
            self.configuration?.actiondelegate?.actionTrigered(action: actionType(rawValue: sender.tag)!, masterIndex: self.feedList![currentIndex].masterIndex , index: self.feedList![currentIndex].index , feedId: self.feedList![currentIndex].feedId, mediaUrl: self.feedList![currentIndex].branchLink , base: self, baseFeedType: (self.feedcontant?.feedType)!)
        }
    }
    @IBAction func swichAction(_ sender: UISwitch) {
        print(sender.isOn)
        sender.isUserInteractionEnabled = false
        if self.configuration?.actiondelegate != nil {
            self.configuration?.actiondelegate?.shouldMakeIt(active: sender.isOn, feedId: self.feedList![currentIndex].feedId)
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    func isIphoneX() -> Bool {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
                return false
                
            case 1334:
                print("iPhone 6/6S/7/8")
                return false
                
            case 2208:
                print("iPhone 6+/6S+/7+/8+")
                return false
                
            case 2436:
                print("iPhone X")
                return true
                
            default:
                print("unknown")
                return false
                
            }
        } else {
            return false
        }
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
        //        let tapGestureRecognizer = UITapGestureRecognizer()
        //        tapGestureRecognizer.numberOfTapsRequired = 2
        //        tapGestureRecognizer.addTarget(self, action: #selector(imageViewDoubleTapped))
        //        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.addTarget(self, action: #selector(imageViewPanned(_:)))
        panGestureRecognizer.delegate = self
        imageView.addGestureRecognizer(panGestureRecognizer)
        
        
        let panGestureRecognizerbottomArea = UIPanGestureRecognizer()
        panGestureRecognizerbottomArea.addTarget(self, action: #selector(imageViewPanned(_:)))
        panGestureRecognizerbottomArea.delegate = self
        
        bottomArea.addGestureRecognizer(panGestureRecognizerbottomArea)
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewtappedView(_:))))
    }
    
    func setupTransitions() {
        guard let imageView = configuration?.imageView else { return }
        
        transitionHandler = ImageViewerTransitioningHandler(fromImageView: imageView, toImageView: self.imageView)
        transitioningDelegate = transitionHandler
    }
    
    func setupActivityIndicator() {
        self.imageView.image = nil
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
    
    
    
    
    //    func setupVideoPlayerfor(userFeed:feed)  {
    //        item = AVPlayerItem(url: URL(string: (userFeed.orignalMedia)!)!)
    //        let duration : CMTime = item!.asset.duration
    //        item?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
    //        item?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
    //        item?.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
    //        let seconds : Float64 = CMTimeGetSeconds(duration)
    //        let player = AVPlayer(playerItem: item)
    //        player.actionAtItemEnd = .none
    //        if userFeed.type != .feed {
    //            spb = SegmentedProgressBar(numberOfSegments: 1, duration: seconds)
    //            spb.frame = CGRect(x: 15, y: 15, width: scrollView.frame.width - 30, height: 4)
    //            spb.delegate = self
    //            spb.topColor = UIColor.white
    //            spb.bottomColor = UIColor.white.withAlphaComponent(0.25)
    //            spb.padding = 2
    //            view.addSubview(spb)
    //            view.bringSubview(toFront: spb)
    //        }
    //        NotificationCenter.default.addObserver(self, selector: #selector(ImageViewerController.playerItemDidReachEnd(notification:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: item)
    //
    //        playerController = AVPlayerViewController()
    //        playerController?.view.contentMode = UIViewContentMode.scaleAspectFill
    //        playerController?.view.isUserInteractionEnabled = false
    //        playerController?.showsPlaybackControls = false
    //
    //        playerController?.player = player
    //        playerController?.view.frame = scrollView.frame
    //        self.addChildViewController(playerController!)
    //        self.imageView.addSubview((playerController?.view)!)
    //        //self.view.sendSubview(toBack: (playerController?.view)!)
    //
    //
    //        //        playerLayer = AVPlayerLayer(player: player)
    //        //        playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill //AVLayerVideoGravity.resizeAspectFill
    //        //        playerLayer?.frame = self.view.frame
    //        //        playerLayer!.use
    //        //        self.view.layer.insertSublayer(playerLayer!, at: 0)
    //        player.play()
    //        if userFeed.type != .feed {
    //            self.spb.startAnimation()
    //            self.spb.isPaused = true
    //        }
    //    }
    
    func setupGradiant()  {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: self.topArea.frame.size)
        gradient.colors = [UIColor.black.withAlphaComponent(0.8).cgColor,UIColor.clear.cgColor]
        topArea.layer.insertSublayer(gradient, at: 0)
        let gradientbottm = CAGradientLayer()
        gradientbottm.frame =  CGRect(origin: .zero, size: self.bottomGradiant.frame.size)
        
        gradientbottm.colors = [UIColor.black.withAlphaComponent(0.8).cgColor,UIColor.clear.cgColor]
        gradientbottm.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientbottm.endPoint = CGPoint(x: 0.0, y: 0.0)
        self.bottomGradiant.layer.insertSublayer(gradientbottm, at: 0)
    }
    
    
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        print("Stop")
        if self.feedcontant?.feedType  != .story {
            dismissAll()
        }
        //guard let playerItemq = notification.object as? AVPlayerItem else { return }
        //playerItem.seek(to: kCMTimeZero)
    }
    @IBAction func closeButtonPressed() {
        DispatchQueue.main.async {
            self.dismissAll()
        }
        
        
    }
    
    @objc func imageViewDoubleTapped() {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
    @objc func imageViewtappedView(_ recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .recognized
        {
            let touchedPpoint = recognizer.location(in: imageView)
            if touchedPpoint.x < self.imageView.frame.size.width/2 {
                if self.spb != nil {
                    imageView.isUserInteractionEnabled = false
                    self.spb.rewind()
                }
                print("rewi")
            } else if touchedPpoint.x > self.imageView.frame.size.width/2 {
                if self.spb != nil {
                    imageView.isUserInteractionEnabled = false
                    self.spb.skip()
                }
                print("skip")
            }
            print(recognizer.location(in: imageView))
        }
    }
    @objc func imageViewPanned(_ recognizer: UIPanGestureRecognizer) {
        guard transitionHandler != nil else { return }
        
        let translation = recognizer.translation(in: imageView)
        let velocity = recognizer.velocity(in: imageView)
        
        switch recognizer.state {
        case .began:
            transitionHandler?.dismissInteractively = true
            //            DispatchQueue.main.async {
            self.dismissAll()
        //            }
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
        
        currentIndex = index
        print("Now showing index: \(index)")
        
        
        
        //
        changeSetup { (ready) in
            self.viewed = false
            
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.updateImage(index: index)
            //            })
            
        }
        //
        
        
    }
    func changeSetup(complition:@escaping videoHandler)  {
        DispatchQueue.main.async {
            if  self.spb != nil{
                
                self.spb.isPaused = true
                
            }
        }
        complition(true)
    }
    func segmentedProgressBarFinished() {
        //       playerController?.view.removeFromSuperview()
        //
        //            self.dismiss(animated: true)
        //        }
        dismissAll()
        print("Finished!")
    }
    private func updateImage(index: Int) {
        
        if self.observer != nil {
            self.player.removeTimeObserver(self.observer)
            self.observer = nil
        }
        
        self.playerController?.view.removeFromSuperview()
        self.playerController?.removeFromParentViewController()
        self.item = nil
        self.playerController = nil
        self.player = nil
        self.display(selectedFeed: (self.feedList?[index])!)
    }
}



