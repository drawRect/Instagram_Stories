import UIKit
import SDWebImage

enum ImageLoaderError: Error {
    case invalidURL(String)
}

enum Result<T> {
    case success(T)
    case failure(Error?)
}

enum ImageStyle: Int {
    case squared
    case rounded
}

extension UIImageView {
    typealias imageFetchCompletion = ((Result<Bool>) -> ())?

    func lookImagefor(url: String,
                      style: ImageStyle = .rounded,
                      completion: imageFetchCompletion = nil) {
        image = nil
        
        if url.isEmpty {
            return completion!(Result.failure(ImageLoaderError.invalidURL(url)))
        }
        backgroundColor = UIColor.rgb(from: 0xEDF0F1)
        setShowActivityIndicator(true)
        setIndicatorStyle(.gray)
        
        layer.cornerRadius = style == .rounded ? frame.height/2 : 0.0
        
        let _url = URL.init(string: url)
        if SDWebImageManager.shared().cachedImageExists(for: _url) {
            backgroundColor = .clear
            sd_setImage(with: URL.init(string: url), completed: { image, error, _, _ in
                DispatchQueue.main.async { [weak self] in
                    self?.clipsToBounds = true
                    guard let c = completion else { return }
                    return self?.image != nil && error == nil ?
                        c(Result.success(true)) : c(Result.failure(error))
                }
            })
        }else {
            self.sd_setImage(with: _url,
                             placeholderImage: nil,
                             options:[.avoidAutoSetImage,.highPriority,.retryFailed,.delayPlaceholder,.continueInBackground],
                             completed: { [weak self] (image, error, cacheType, url) in
                                if (error != nil) {
                                    DispatchQueue.main.async {
                                        self?.backgroundColor = .clear
                                        self?.alpha = 0;
                                        self?.image = image
                                        self?.clipsToBounds = true
                                        UIView.animate(withDuration: 0.5, animations: {
                                            self?.alpha = 1
                                        }, completion: { (done) in
                                            if let c = completion { return c(Result.success(true)) }
                                        })
                                    }}else{
                                    if let c = completion {
                                        c(Result.failure(error))
                                    }
                                }
            })
        }
    }
}
