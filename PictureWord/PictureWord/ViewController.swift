//
//  ViewController.swift
//  PictureWord
//
//  Created by ApplePie on 20.12.17.
//  Copyright © 2017 ApplePie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

        @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchImage(text: "panda")
    }
    
    func convert(farm: Int, server: String, id: String, secret: String) -> URL? {
        let url = URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_c.jpg")
        print(url!)
        return url
    }

    func searchImage(text: String) {
        
        // How to get this url:
        // 1. go to www.flickr.com
        // 2. fall down to 'Developers'
        // 3. Home -> API -> Step 4 (The App Garden)
        // 4. find 'flickr.photos.search', click here
        // 5. click 'API Explorer'
        // 6. choose your params
        // 7. output: JSON
        // 8. choose 'Do not sign call'
        // 9. push the button 'Call Method'
        // 10. fall down the page and get your url
        //
        // Example: https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=1440e50ba9cc0e7e99ca535ec69e1ffc&text=zebra&format=json&nojsoncallback=1
        
        let base = "https://api.flickr.com/services/rest/?method=flickr.photos.search"
        let key = "&api_key=1440e50ba9cc0e7e99ca535ec69e1ffc"
        let format = "&format=json&nojsoncallback=1"
        let textToSearch = "&text=\(text)"
        let sort = "&sort=relevance"
        
        let searchUrl = base + key + format + textToSearch + sort
        
        let url = URL(string: searchUrl)!
        
        URLSession.shared.dataTask(with: url) { (data, _, _ ) in
            
            guard let jsonData = data else {
                print("ERROR: data is nothing")
                return
            }
            
            guard let jsonAny = try? JSONSerialization.jsonObject(with: jsonData, options: []) else {
                return
            }
            
            guard let json = jsonAny as? [String: Any] else {
                return
            }
            
            guard let photos = json["photos"] as? [String: Any] else {
                return
            }
            
            guard let photoArray = photos["photo"] as? [Any] else {
                return
            }
            
            guard photoArray.count > 0 else {
                print("ERROR: np photos in response")
                return
            }
            
            guard let firstPhoto = photoArray[0] as? [String: Any] else {
                return
            }
            
            let farm = firstPhoto["farm"] as! Int
            let server = firstPhoto["server"] as! String
            let secret = firstPhoto["secret"] as! String
            let id = firstPhoto["id"] as! String
            
            let pictureUrl = self.convert(farm: farm, server: server, id: id, secret: secret)
            
            URLSession.shared.dataTask(with: pictureUrl!, completionHandler: { (data, _, _) in
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data!)
                }
            }).resume()
            
            
        }.resume()
        
    }
}

