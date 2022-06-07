import UIKit

// swiftlint:disable all
extension UIImageView {
    /// Loads image from web asynchronosly and caches it, in case you have to load url
    /// again, it will be loaded from cache if available
    public func load(url: URL, placeholder: UIImage?, cache: URLCache? = nil, shouldCacheImage: Bool = true, completion:(( _ downloadedImage: UIImage?) -> Void)?) {
        let cache = cache ?? URLCache.shared
        let request = URLRequest(url: url)
        if shouldCacheImage {
            if let data = cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                    if let callback = completion {
                        callback(image)
                    }
                }
            }
        } else {
            self.image = placeholder
            let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { data, response, _ in
                if let data = data, let response = response, ((response as? HTTPURLResponse)?.statusCode ?? 500) < 300, let image = UIImage(data: data) {
                    let cachedData = CachedURLResponse(response: response, data: data)
                    cache.storeCachedResponse(cachedData, for: request)
                    
                    DispatchQueue.main.async {
                        self.image = image
                        if let callback = completion {
                            callback(image)
                        }
                    }
                }
            })
            dataTask.resume()
        }
    }
}
