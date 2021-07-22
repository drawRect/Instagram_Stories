import UIKit

public enum ImageStyle: Int {
    case squared,rounded
}

public typealias SetImageRequester = (IGResult<Bool,Error>) -> Void

extension UIImageView: IGImageRequestable {
    public func setImage(url: String,
                         withHeaders headers: [String: String] = [:],
                         style: ImageStyle = .rounded,
                         completion: SetImageRequester? = nil) {
        image = nil

        //The following stmts are in SEQUENCE. before changing the order think twice :P
        isActivityEnabled = true
        layer.masksToBounds = false
        if style == .rounded {
            layer.cornerRadius = frame.height/2
            activityStyle = .medium
        } else if style == .squared {
            layer.cornerRadius = 0
            activityStyle = .large
        }
        
        clipsToBounds = true
        setImage(urlString: url, withHeaders: headers) { (response) in
            if let completion = completion {
                switch response {
                case .success(_):
                    completion(IGResult.success(true))
                case .failure(let error):
                    completion(IGResult.failure(error))
                }
            }
        }
    }
}
