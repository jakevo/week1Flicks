//
//  MovieViewController.swift
//  Flicks
//
//  Created by Jake Vo on 2/1/17.
//  Copyright © 2017 Jake Vo. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import SystemConfiguration


class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    let searchBar = UISearchBar()
    
    //var movie: [NSDictionary] = []
    var movieSearch: [NSDictionary] = []
    var filterMovie: [MovieModel] = []
    var movieSearch1: [MovieModel] = []
    var refresher: UIRefreshControl!
    @IBOutlet weak var tableView: UITableView!
    func refresh() {
        getData()
        filterMovie.removeAll()
    }

    
    @IBAction func onTap(_ sender: Any) {
        
        view.endEditing(true)
        
    }
    
    func checkInternet() {
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK")
        } else {
            print("Internet connection FAILED")
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your devide is connected to internet", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkInternet()
        searchBarFunc()
        customNavBar()
        tableView.dataSource = self
        tableView.delegate = self
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(MovieViewController.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        refresh()
    }
    
    
    
    func getData() {
        
        
        let apiKey = "05d4c5aa7a9a732d6c86856efd017c55"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let retValue = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    self.movieSearch = retValue["results"] as! [NSDictionary]
                    //remove everything before uploading new data to movieSearch1
                    self.movieSearch1.removeAll()
                    for x in self.movieSearch {
                        if let poster_path = x["poster_path"] as? String {
                            let base_url = "https://image.tmdb.org/t/p/w342/"
                            let posterURL = URL(string: base_url + poster_path)!
                            self.filterMovie.append(MovieModel(title: x["original_title"] as! String, overview: x["overview"] as! String, imageURL: posterURL))
                            self.movieSearch1.append(MovieModel(title: x["original_title"] as! String, overview: x["overview"] as! String, imageURL: posterURL))
                        }
                    }
                }
            }
            

            self.tableView.reloadData()
            self.refresher.endRefreshing()
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        
        task.resume()
        
    }
    
    func searchBarFunc() {
        
        let searchBar = UISearchBar(frame: CGRect(x:0,y:0,width:(UIScreen.main.bounds.width),height:70))
        searchBar.delegate = self
        searchBar.enablesReturnKeyAutomatically = true
        searchBar.sizeToFit()
        //searchBar.showsCancelButton = true
        //searchBar.searchBarStyle = UISearchBarStyle.minimal
    
        self.tableView.tableHeaderView = searchBar
        //self.navigationItem.titleView = searchBar

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty == false {
            self.movieSearch1 = filterMovie.filter({ (mod) -> Bool in
                return mod.title.lowercased().contains(searchText.lowercased())
            })
        } else {
            self.movieSearch1 = self.filterMovie
            
        }
        self.tableView.reloadData()
        self.refresher.endRefreshing()
    }
    
    func customNavBar() {
        self.edgesForExtendedLayout = []
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black // I then set the color using:
        
        self.navigationController?.navigationBar.barTintColor   = UIColor(red: 204/255, green: 47/255, blue: 40/255, alpha: 1.0) // a lovely red
        
        self.navigationController?.navigationBar.tintColor = UIColor.white // for titles, buttons, etc.
        
        let navigationTitleFont = UIFont(name: "Avenir", size: 20)!
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: navigationTitleFont]

    }
    
    
    //@available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieSearch1.count
    }
    
    
    //@available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as! MovieCell
        let model = movieSearch1[indexPath.row]
        
        cell.title.text = model.title
        cell.overview.text = model.overview
        
        let imageRequest = NSURLRequest(url: model.imageURL)
        
            cell.poster.setImageWith(
            imageRequest as URLRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    print("Image was NOT cached, fade in image")
                    cell.poster.alpha = 0.0
                    cell.poster.image = image
                    UIView.animate(withDuration: 1, animations: { () -> Void in
                        cell.poster.alpha = 1.0
                    })
                } else {
                    print("Image was cached so just update the image")
                    cell.poster.image = image
                }
        },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })
        //cell.poster.setImageWith(model.imageURL)
        return cell
    }
}
