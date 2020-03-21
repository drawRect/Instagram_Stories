import UIKit

enum ImageStyle: Int {
    case squared, rounded
}

typealias SetImageRequester = (Result<UIImage, Error>) -> Void

extension UIImageView: IGImageRequestable {
    func requestImage(
        url: String,
        style: ImageStyle = .rounded,
        completion: SetImageRequester? = nil
    ) {
        self.enableLoaderAndProps(onStyle: style)
        requestImage(urlString: url) { (response) in
            if let completion = completion {
                switch response {
                case .success(let imgRaw):
                    guard let image = UIImage(data: imgRaw) else {
                        return completion(
                            Result.failure(IGImageLoadError.downloadError)
                        )
                    }
                    IGCache.default.setObject(imgRaw as AnyObject, forKey: url as AnyObject)
                    completion(Result.success(image))
                case .failure(let error):
                    completion(Result.failure(error))
                }
            }
        }
    }
    private func enableLoaderAndProps(onStyle: ImageStyle) {
           image = nil

           //The following stmts are in SEQUENCE. before changing the order think twice :P
           isActivityEnabled = true
           layer.masksToBounds = false
           if onStyle == .rounded {
               layer.cornerRadius = frame.height/2
               if #available(iOS 13.0, *) {
                   activityStyle = .white
                   activityIndicator.color = .white
               } else {
                   activityStyle = .white
               }
           } else if onStyle == .squared {
               layer.cornerRadius = 0
               if #available(iOS 13.0, *) {
                   activityStyle = .large
                   activityIndicator.color = .white
               } else {
                   activityStyle = .whiteLarge
               }
           }
           clipsToBounds = true
       }
}
