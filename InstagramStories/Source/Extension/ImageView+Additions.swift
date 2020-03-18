import UIKit

enum ImageStyle: Int {
    case squared, rounded
}

typealias SetImageRequester = (IGResult<UIImage, Error>) -> Void

extension UIImageView: IGImageRequestable {
    func setImage(url: String,
                  style: ImageStyle = .rounded,
                  completion: SetImageRequester? = nil) {
        image = nil

        //The following stmts are in SEQUENCE. before changing the order think twice :P
        isActivityEnabled = true
        layer.masksToBounds = false
        if style == .rounded {
            layer.cornerRadius = frame.height/2
            if #available(iOS 13.0, *) {
                activityStyle = .white
                activityIndicator.color = .white
            } else {
                activityStyle = .white
            }
        } else if style == .squared {
            layer.cornerRadius = 0
            if #available(iOS 13.0, *) {
                activityStyle = .large
                activityIndicator.color = .white
            } else {
                activityStyle = .whiteLarge
            }
        }
        clipsToBounds = true
        setImage(urlString: url) { (response) in
            if let completion = completion {
                switch response {
                case .success(let img):
                    completion(IGResult.success(img))
                case .failure(let error):
                    completion(IGResult.failure(error))
                }
            }
        }
    }
}
