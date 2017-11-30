import Foundation
import UIKit

public typealias ImageCompletion = (UIImage?) -> Void
public typealias videoHandler = (Bool) -> Void
public typealias ImageBlock = (@escaping ImageCompletion) -> Void
public enum mediaType : Int{
    case image = 0
    case video = 1
}
public enum bottomType : Int{
    case feed = 0
    case activateStory = 1
    case none = 2
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
    func actionTrigered(action:actionType,feedId:String)
    func shouldMakeIt(active:Bool,feedId:String)
}
public enum actionType:Int{
    case like = 0
    case comment = 1
    case share = 2
    case more = 3
}
public final class feedContant {
    
 public typealias feedContantClosure = (feedContant) -> ()
  public  var thumb:String!
  public  var orignalMedia:String!
    public var feedId:String!
    public var time:String!
     public var discription:String!
     public var lits:String!
     public var comments:String!
  public var mediaType:mediaType!
  public  var owner:owner!
public var type:bottomType = .none
    
    public init(feedClosure: feedContantClosure) {
        feedClosure(self)
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
