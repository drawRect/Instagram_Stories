import UIKit
import SDWebImage

enum ImageStyle: Int {
    case squared
    case rounded
}

extension UIImageView {
    func setImage(url: String,
                  style: ImageStyle = .rounded,
                  completion: ((_ result:Bool,_ error:Error?)->Void)?=nil) {
        
        image = nil
        
        if url.count < 1 {
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
    }
}
class retryButton:UIButton {
    var imageURL:String?
    var cell:IGStoryPreviewCell?
}
extension UIImageView {
    func addRetryButton(_ cell:UICollectionViewCell, _ url:String) {
        self.isUserInteractionEnabled = true
        let button = retryButton.init(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        button.setImage(#imageLiteral(resourceName: "ic_retry"), for: .normal)
        button.center = self.center
        button.addTarget(self, action: #selector(retryAct(sender:)), for: .touchUpInside)
        button.imageURL = url
        button.cell = cell as? IGStoryPreviewCell
        button.tag = 100
        self.addSubview(button)
    }
    func removeRetryButton() {
        self.isUserInteractionEnabled = false
        self.subviews.forEach({v in
            if(v.tag == 100){v.removeFromSuperview()}
        })
    }
    @objc func retryAct(sender:retryButton) {
        sender.cell?.imageRequest(snapView: self, with: sender.imageURL!)
    }
}
