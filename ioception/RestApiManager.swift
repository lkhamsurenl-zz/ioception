import Foundation
import UIKit

// Manager for all the rest API calls.
class RestAPIManager {
    
    // Make Post API Call.
    func makePostAPICall(image: UIImage) {
        
        // Create new post
        let postsEndpoint: String = "http://jsonplaceholder.typicode.com/posts"
        let postsUrlRequest = NSMutableURLRequest(URL: NSURL(string: postsEndpoint)!)
        // POST.
        postsUrlRequest.HTTPMethod = "POST"
        
        let newPost: NSDictionary = ["image": image]
        
        do {
            let jsonPost = try NSJSONSerialization.dataWithJSONObject(newPost, options: [])
            postsUrlRequest.HTTPBody = jsonPost
            
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: config)
            
            let task = session.dataTaskWithRequest(postsUrlRequest, completionHandler: {
                (data, response, error) in
                guard let responseData = data else {
                    print("Error: did not receive data")
                    return
                }
                guard error == nil else {
                    print("error calling POST on /posts/1")
                    print(error)
                    return
                }
                
                // parse the result as JSON, since that's what the API provides
                do {
                    if let post = try NSJSONSerialization.JSONObjectWithData(responseData, options: []) as? [String: AnyObject] {
                        // now we have the post, let's just print it to prove we can access it
                        print("The post is: " + post.description)
                        
                        // the post object is a dictionary
                        // so we just access the title using the "title" key
                        // so check for a title and print it if we have one
                        if let postID = post["id"] as? Int
                        {
                            print("The ID is: \(postID)")
                        }
                    } else {
                        print("JSON isn't a [String: AnyObject]")
                    }
                } catch  {
                    print("error parsing response from POST on /posts")
                }
            })
            task.resume()
        } catch {
            print("Error: cannot create JSON from post")
        }
    }
}


