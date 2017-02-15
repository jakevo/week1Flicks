//
//  CollectionViewController.swift
//  Flicks
//
//  Created by Jake Vo on 2/7/17.
//  Copyright © 2017 Jake Vo. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import SystemConfiguration

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var barNav: UINavigationItem!
    

    //@IBOutlet weak var poster: UIImageView!
    var movieSearch: [NSDictionary] = []
    var movieSearch1: [MovieModel] = []
    var filterMovie: [MovieModel] = []
    var refresher: UIRefreshControl!
    var searchText: String!
    var endPoint: String = "now_playing"
    var barTitle: String = "Now Playing"
    //var check: Int = 1
    @IBOutlet weak var searchButton: UIBarButtonItem!
    //var searchBar: UISearchController!
    
    var searchController: UISearchController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.barTintColor = UIColor.black
        testingConnection()
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(CollectionViewController.refresh), for: UIControlEvents.valueChanged)
        collectionView.addSubview(refresher)
        refresh()
        collectionView.dataSource = self
        collectionView.delegate = self
        getData()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    func refresh() {
        getData()
        filterMovie.removeAll()
    }

    
    func checkInternet() -> Bool{
        if Reachability.isConnectedToNetwork() == true {
            return true
        } else {
            return false
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //searchBar.resignFirstResponder()
        searchText = searchBar.text!
        self.navigationItem.title = searchText.uppercased()
    }
    

    @IBAction func searchAction(_ sender: Any) {
        //searchText = nil
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        
        searchController.searchBar.text = searchText
        searchController.searchBar.barTintColor = UIColor.black
        self.present(searchController, animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText.isEmpty == false {
            self.movieSearch1 = filterMovie.filter({ (mod) -> Bool in
                return mod.title.lowercased().contains(searchText.lowercased())
            })
        } else {
            self.movieSearch1 = self.filterMovie
            
        }
        self.collectionView.reloadData()
        self.refresher.endRefreshing()
    }

    func testingConnection() {
        if checkInternet() {
            customNavBar(signal: 0)
        } else {
            customNavBar(signal: 1)
        }
    }

    func customNavBar(signal: Int) {
        self.edgesForExtendedLayout = []
        
        var titleColor: NSDictionary = [:]
        if signal == 0 {
            self.navigationController?.navigationBar.topItem?.title = barTitle
            
            self.navigationController?.navigationBar.barTintColor   = UIColor.clear
            
            let navigationTitleFont = UIFont(name: "Avenir", size: 20)!
            titleColor = [NSForegroundColorAttributeName: UIColor.red]
            self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: navigationTitleFont]
            
        } else {
            titleColor = [NSForegroundColorAttributeName: UIColor.black]
            self.navigationController?.navigationBar.topItem?.title = "Networking Error!"
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = titleColor as? [String : Any]
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        getData()
        //return back to the title
        customNavBar(signal: 0)
    }
   

    //@available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return movieSearch1.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showDetail" {
            
            let indexPath = collectionView.indexPath(for: sender as! UICollectionViewCell)
            let vc = segue.destination as! MovieDetailView

            let movie = movieSearch1[(indexPath?.row)!]
           // print(movie.imageURL)
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: movie.imageURL) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    vc.poster.image = UIImage(data: data!)
                    vc.smallPoster.image = UIImage(data: data!)
                    vc.overview.text = movie.overview
                    vc.overview.sizeToFit()
                    vc.movieTitle.text = movie.title
                    let rating = (self.movieSearch[(indexPath?.row)!]["vote_average"] as? Double)!
                    vc.rating.text = "\(rating)"
                    let movId = (self.movieSearch[(indexPath?.row)!]["id"] as? Int)
                    vc.movieID = movId!
                }
            }
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.red

    }
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    //@available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! MovieCollectionViewCell
        let dataMovie = movieSearch1[indexPath.row]
        
        
        let imageRequest = NSURLRequest(url: dataMovie.imageURL)
    
        cell.poster.setImageWith(
            imageRequest as URLRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    cell.poster.alpha = 0.0
                    cell.poster.image = image
                    UIView.animate(withDuration: 1.2, animations: { () -> Void in
                        cell.poster.alpha = 1.0
                    })
                } else {
                    cell.poster.image = image
                }
                //cell.backgroundColor = UIColor(red:1.00, green:0.68, blue:0.40, alpha:1.0)
        },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })

        return cell
    }
    
    
    func getData() {
        
        let apiKey = "05d4c5aa7a9a732d6c86856efd017c55"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endPoint)?api_key=\(apiKey)")
        let request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
       // MBProgressHUD.showAdded(to: self.view, animated: true)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let retValue = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    self.movieSearch = retValue["results"] as! [NSDictionary]
                    
                    //remove everything before uploading new data to movieSearch1
                    self.movieSearch1.removeAll()
                    self.filterMovie.removeAll()
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
            
            
            self.collectionView.reloadData()
            self.refresher.endRefreshing()
           // MBProgressHUD.hide(for: self.view, animated: true)
        }
        
        task.resume()
        
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
