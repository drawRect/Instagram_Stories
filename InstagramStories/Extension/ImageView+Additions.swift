import UIKit
import SDWebImage

enum ImageStyle:Int {
    case squared
    case rounded
}

extension UIImageView {
 
    func setImage(url:String,style:ImageStyle = .rounded,
                  completion:((_ result:Bool,_ error:Error?)->Void)?=nil) {
        
        image = nil
        
        if url.characters.count < 1 {
            return
        }
        backgroundColor = UIColor.rgb(from: 0xEDF0F1)
        if(style == .rounded) {
            layer.cornerRadius = frame.height/2
        }else if(style == .squared){
            layer.cornerRadius = 0.0
        }
        
        setShowActivityIndicator(true)
        setIndicatorStyle(.gray)
        
        if SDWebImageManager.shared().cachedImageExists(for: URL.init(string: url) ) {
            backgroundColor = .clear
            sd_setImage(with: URL.init(string: url))
            clipsToBounds = true
            if let completion = completion {
                 completion(true,nil)
            }
        }
        else {
            self.sd_setImage(with: URL.init(string: url), placeholderImage:nil, options: [.avoidAutoSetImage,.highPriority,.retryFailed,.delayPlaceholder,.continueInBackground], completed: { (image, error, cacheType, url) in
                if error == nil {
                    DispatchQueue.main.async {
                        self.backgroundColor = .clear
                        self.alpha = 0;
                        self.image = image
                        self.clipsToBounds = true
                        UIView.animate(withDuration: 0.5, animations: { 
                            self.alpha = 1
                        }, completion: { (done) in
                            if let completion = completion {
                                 completion(true,error)
                            }
                        })
                    }
                }else {
                    if let completion = completion {
                         completion(false,error)
                    }
                }
            })
        }
    }
}
