import Foundation
import UIKit

public typealias ImageCompletion = (UIImage?) -> Void
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
public class owner  {
    var name:String!
    var image:UIImage!
}

public final class feedContant {
    
 public typealias feedContantClosure = (feedContant) -> ()
  public  var thumb:String!
  public  var media:String!
   public var time:String!
  public var mediaType:mediaType!
  public  var owner:owner!
    
    
    public init(feedClosure: feedContantClosure) {
        feedClosure(self)
    }
    
}
public final class ImageViewerConfiguration {
    public var image: UIImage?
    public var imageView: UIImageView?
    public var imageBlock: ImageBlock?
    
    public typealias ConfigurationClosure = (ImageViewerConfiguration) -> ()
    
    public init(configurationClosure: ConfigurationClosure) {
        configurationClosure(self)
    }
}
