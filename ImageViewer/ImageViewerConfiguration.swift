import Foundation
import UIKit

public typealias ImageCompletion = (UIImage?) -> Void
public typealias videoHandler = (Bool) -> Void
public typealias ImageBlock = (@escaping ImageCompletion) -> Void






public enum mediaType : Int{
    case image = 0
    case video = 1
}



public enum privacyLevel : String{
    case privateFeed = "Private"
    case publicFeed = "Public"
}
public enum bottomType : Int{
    case feed = 0
    case activateStory = 1
    case none = 2
    case eye = 3
    case activateStoryWithEye = 4
    
}
public class owner {
    var name:String!
    var image:UIImage!
    var originalImage: String!
    public init(name:String,image:UIImage,originalImage:String) {
        self.name = name
        self.image = image
        self.originalImage = originalImage
    }
}
public protocol ActionDelegate {
    func actionTrigered(action: actionType, masterIndex: Int?, index: Int?,feedId: String,mediaUrl:String,base:UIViewController,baseFeedType:feedType)
    
    func shouldMakeIt(active:Bool,feedId:String)
    func markAsViewed(feedId:String)
    func startListen(action:actionType,feedId:String)
}
public enum feedType:Int{
    case story = 0
    case live = 1
    
}
public enum OwnerType:Int{
    case me = 0
    case other = 1
    
}
public enum individualFeedType:String {
    case storyImage = "StoryImage"
    case storyVideo = "StoryVideo"
    case liveStreamVideo = "LiveStreamVideo"
    case liveStream = "LiveStream"
}
public enum actionType:Int{
    case like = 0
    case comment = 1
    case share = 2
    case more = 3
    case viewerList = 4
    case Listen = 5
}
public final class feedContant {
    
    public typealias feedContantClosure = (feedContant) -> ()
    public var turnSoket:Bool!
    public  var feedList:[feed]!
    public var feedType:feedType!
    public var bottomtype:bottomType = .none
    public  var owner:owner!
    public  var ownerType:OwnerType!
    public init(feedClosure: feedContantClosure) {
        feedClosure(self)
    }
    
}
public class feed {
    public var duration:TimeInterval
    public var thumb:String!
    public var orignalMedia:String!
    public var feedId:String!
    public var time:String!
    public var discription:String!
    public var lits:String!
    public var comments:String!
    public var mediaType:mediaType!
    public var privacyLevel:privacyLevel!
    public var viewers : Int!
    public var branchLink:String!
    public var individualFeedType:individualFeedType!
    
    public var masterIndex : Int!
    public var index : Int!
    public init(thumb:String,orignalMedia:String,feedId:String,time:String,discription:String,lits:String,comments:String,mediaType:mediaType,owner:owner,type:bottomType,duration:TimeInterval,viewers:Int,branchLink:String,masterIndex:Int?,index:Int?,individualFeedType:individualFeedType,privacyLevel:privacyLevel){
        self.individualFeedType = individualFeedType
        self.thumb = thumb
        self.orignalMedia = orignalMedia
        self.feedId = feedId
        self.time = time
        self.discription = discription
        self.lits = lits
        self.comments = comments
        self.mediaType = mediaType
        self.duration = duration
        self.viewers = viewers
        self.branchLink = branchLink
        self.masterIndex = masterIndex
        self.index = index
        self.privacyLevel = privacyLevel
    }
    
    
}
public final class ImageViewerConfiguration {
    public var image: UIImage?
    public var imageView: UIImageView?
    public var imageBlock: ImageBlock?
    public var actiondelegate:ActionDelegate?
    public typealias ConfigurationClosure = (ImageViewerConfiguration) -> ()
    
    public init(configurationClosure: ConfigurationClosure) {
        configurationClosure(self)
    }
}

