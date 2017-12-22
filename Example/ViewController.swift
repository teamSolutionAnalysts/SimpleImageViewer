import UIKit
import SimpleImageViewer
import AVFoundation
import AVKit
class ViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    fileprivate let contentModes: [UIViewContentMode] = [.scaleToFill,
                                                         .scaleAspectFit,
                                                         .scaleAspectFill,
                                                         .center,
                                                         .top,
                                                         .bottom,
                                                         .left,
                                                         .right,
                                                         .topLeft,
                                                         .topRight,
                                                         .bottomLeft,
                                                         .bottomRight]
    
    fileprivate let images = [UIImage(named: "1"),
                              UIImage(named: "2"),
                              UIImage(named: "3"),
                              UIImage(named: "4"),
                              UIImage(named: "5"),
                              UIImage(named: "6")]

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return contentModes.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.imageView.image = images[indexPath.row]
        cell.imageView.contentMode = contentModes[indexPath.section]
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ImageCell
        let feedOwner = owner.init(name: "Dhaval", image: cell.imageView.image!, originalImage: "")
      
        let  feedq = feedContant{ feeds in
            if indexPath.row == 0{
                let feed1 = feed.init(thumb: "", orignalMedia: "https://dev-itzlit.s3.amazonaws.com/story/941ecab0-cf87-11e7-b5fb-0f80c7125ff0/9-jxYN6y2vRF2mSBj7eRGGrh.jpg", feedId: "", time: "100 years ago", discription: "Awesome Image", lits: "50", comments: "100", mediaType: .image, owner: feedOwner, type: .feed,duration: 5, viewers: 50)
                let feed2 = feed.init(thumb: "", orignalMedia: "https://d24lih7hes6i11.cloudfront.net/story/e1134d90-e581-11e7-8c84-69462caf78c2/Xazkp8mgKOd06rts5Tq0GdCV.mp4", feedId: "", time: "100 years ago", discription: "Awesome Video", lits: "50", comments: "100", mediaType: .video, owner: feedOwner, type: .feed,duration: 7, viewers: 50)
//              let  item = AVPlayerItem(url: URL(string: "http://techslides.com/demos/sample-videos/small.mp4")!)
//                let duration : CMTime = item.asset.duration
//let seconds : Float64 = CMTimeGetSeconds(duration)
                
                //http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4
                feeds.feedList = [feed2,feed2,feed2,feed1,feed1]
                feeds.bottomtype = .activateStoryWithEye
                feeds.feedType = .story
                feeds.owner = feedOwner
//                feeds.owner = feedOwner
//                feeds.type = .feed
//                feeds.mediaType = mediaType.image
//                feeds.orignalMedia = "https://dev-itzlit.s3.amazonaws.com/story/941ecab0-cf87-11e7-b5fb-0f80c7125ff0/9-jxYN6y2vRF2mSBj7eRGGrh.jpg"
//                feeds.time = "100 years ago"
//                feeds.lits = "50"
//                feeds.comments = "100"
//                feeds.discription = "Awesome Image"
//                feeds.feedId = ""
            } else {
                
//                feeds.feedId = ""
//                feeds.owner = feedOwner
//                feeds.type = .activateStory
//                feeds.mediaType = mediaType.video
//                feeds.orignalMedia = "http://techslides.com/demos/sample-videos/small.mp4"
//                feeds.time = "100 years ago"
//                feeds.lits = "500"
//                feeds.comments = "100"
//                feeds.discription = "Awesome Video"
            }
            
        }
        
        let configuration = ImageViewerConfiguration { config in
           config.imageView = cell.imageView
            config.actiondelegate = self
           
        }
        
        present(ImageViewerController(configuration: configuration, contant: feedq), animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", for: indexPath) as! HeaderView
        headerView.titleLabel.text = contentModes[indexPath.section].name
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width / 3 - 8
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
private extension UIViewContentMode {
    var name: String {
        switch self {
        case .scaleToFill:
            return "scaleToFill"
        case .scaleAspectFit:
            return "scaleAspectFit"
        case .scaleAspectFill:
            return "scaleAspectFill"
        case .redraw:
            return "redraw (not animatable)"
        case .center:
            return "center"
        case .top:
            return "top"
        case .bottom:
            return "bottom"
        case .left:
            return "left"
        case .right:
            return "right"
        case .topLeft:
            return "topLeft"
        case .topRight:
            return "topRight"
        case .bottomLeft:
            return "bottomLeft"
        case .bottomRight:
            return "bottomRight"
        }
    }
}
extension ViewController:ActionDelegate{
    
    func actionTrigered(action: actionType, feedId: String, mediaUrl: String, base: UIViewController) {
        print(action,feedId)
    }
    
    func markAsViewed(feedId: String) {
        
    }
    
   
    
    func shouldMakeIt(active: Bool, feedId: String) {
        
    }
    
  
    
   
}
