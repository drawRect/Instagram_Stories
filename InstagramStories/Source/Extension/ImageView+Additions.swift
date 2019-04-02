import UIKit

enum ImageStyle: Int {
    case squared,rounded
}

extension UIImageView {
    func setImage(url: String,
                  style: ImageStyle = .rounded,
                  completion: ((_ result:Bool, _ error:Error?) -> Void)? = nil) {
        image = nil
        
        self.isActivityEnabled = true
        if style == .rounded {
            layer.masksToBounds = false
            layer.cornerRadius = frame.height/2
            self.clipsToBounds = true
            self.activityStyle = .white
        } else if style == .squared {
            layer.masksToBounds = false
            layer.cornerRadius = 0
            self.clipsToBounds = true
            self.activityStyle = .whiteLarge
        }
        self.ig_setImage(urlString: url) { (response) in
            if let completion = completion {
                switch response {
                case .success(_):
                    return completion (true, nil)
                case .failure(let error):
                    return completion(false, error)
                }
            }
        }
    }
    /*func setImage(url: String,
                  style: ImageStyle = .rounded,
                  completion: ((_ result:Bool,_ error:Error?)->Void)?=nil) {
        
        image = nil
        
        if url.count < 1 {
            return
        }
        //backgroundColor = UIColor.rgb(from: 0xEDF0F1)
        backgroundColor = .black
        if(style == .rounded) {
            layer.cornerRadius = frame.height/2
            setIndicatorStyle(.white)
        }else if(style == .squared){
            layer.cornerRadius = 0.0
            setIndicatorStyle(.whiteLarge)
        }
        
        setShowActivityIndicator(true)
        
        if SDWebImageManager.shared().cachedImageExists(for: URL.init(string: url) ) {
            backgroundColor = .clear
            sd_setImage(with: URL.init(string: url), completed: { (image, error, _, _) in
                DispatchQueue.main.async { [weak self] in
                    self?.clipsToBounds = true
                    if let completion = completion {
                        if (self?.image != nil) && error == nil {
                            completion(true,nil)
                        }else {
                            completion(false,error)
                        }
                    }
                }
            })
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
    }*/
}
