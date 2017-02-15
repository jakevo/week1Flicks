//
//  movieDetailView.swift
//  Flicks
//
//  Created by Jake Vo on 2/11/17.
//  Copyright © 2017 Jake Vo. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import youtube_ios_player_helper

class MovieDetailView: UIViewController, YTPlayerViewDelegate {
    @IBOutlet weak var poster: UIImageView!

    //@IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var smallPoster: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var rating: UILabel!
    var movieID: Int?
    var movie: [NSDictionary] = []
    var youtubeLink: String?
    //@IBOutlet strong var videoView: YTPlayerView
    var temp: String?
    @IBOutlet var videoView: YTPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoView.isHidden = true
        videoView.delegate = self
        self.tabBarController?.tabBar.isHidden = true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        getData(idMovie: movieID!)
    }
    @IBAction func playVideo(_ sender: Any) {
        print("the movie ID is \(temp!)")
        videoView.load(withVideoId: temp!)
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        videoView.isMultipleTouchEnabled = false
        videoView.playVideo()
        
    }
    
    func getData(idMovie: Int) {
        //var temp: String = "somthing"
        //let apiKey = "05d4c5aa7a9a732d6c86856efd017c55"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(idMovie)/videos?api_key=05d4c5aa7a9a732d6c86856efd017c55&language=en-US")
        let request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        // MBProgressHUD.showAdded(to: self.view, animated: true)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil {
                
            } else {
                
                if let data = data {
                    if let retValue = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        self.movie = retValue["results"] as! [NSDictionary]
                        if let videoUrl = self.movie[0]["key"] as? String {
                            self.temp = videoUrl
                        } else {
                            print("this video has no trailer")
                        }
                    }
                }
                
            }
        }
        
        task.resume()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
