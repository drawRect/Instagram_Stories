import UIKit
import SDWebImage

enum ImageStyle:Int {
    case squared
    case rounded
}

extension UIImageView {
    
    func RK_setImage(urlString:String,imageStyle:ImageStyle = .rounded) {
        
        image = nil
        
        if urlString.characters.count < 1 {
            return
        }
        backgroundColor = UIColor.rgb(from: 0xEDF0F1)
        
        if(imageStyle == .rounded) {
            layer.cornerRadius = frame.height/2
        }else if(imageStyle == .squared){
            layer.cornerRadius = 0.0
        }
        
        setShowActivityIndicator(true)
        setIndicatorStyle(.gray)
        
        if SDWebImageManager.shared().cachedImageExists(for: URL.init(string: urlString) ) {
            backgroundColor = .clear
            sd_setImage(with: URL.init(string: urlString))
            clipsToBounds = true
        }
        else {
            self.sd_setImage(with: URL.init(string: urlString), placeholderImage:nil, options: [.avoidAutoSetImage,.highPriority,.retryFailed,.delayPlaceholder], completed: { (image, error, cacheType, url) in
                if error == nil {
                    DispatchQueue.main.async {
                        self.backgroundColor = .clear
                        self.alpha = 0;
                        self.image = image
                        self.clipsToBounds = true
                        UIView.animate(withDuration: 0.5, animations: {
                            self.alpha = 1
                        })
                    }
                }
            })
        }
    }
}


