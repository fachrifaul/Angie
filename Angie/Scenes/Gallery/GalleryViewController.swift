//
//  GalleryViewController.swift
//  Angie
//
//  Created by Suhendra Ahmad on 7/4/17.
//  Copyright (c) 2017 Suhendra Ahmad. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import ALThreeCircleSpinner
import SnapKit
import Kingfisher
import Hue

protocol GalleryDisplayLogic: class
{
    func displayPhotos(viewModel: Gallery.Photo.ViewModel)
}

class GalleryViewController: UICollectionViewController, GalleryDisplayLogic
{
    var interactor: GalleryBusinessLogic?
    var router: (NSObjectProtocol & GalleryRoutingLogic & GalleryDataPassing)?
    
    // MARK: MemVars & Properties
    
    private let cellIdentifier = "Cell"
    private let photoCellIdentifier = "photoCell"
    
    // Photos and Gallery margins
    fileprivate let photosPerRow: CGFloat = 1
    fileprivate let sectionInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    fileprivate var searchBar: UISearchBar!
    fileprivate var cancelSearchButton: UIBarButtonItem!
    fileprivate var searchButton: UIBarButtonItem!
    fileprivate var searchText: String = ""
    
    private let spinner = ALThreeCircleSpinner(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
    var displayedPhotos = [FlickrPhoto]()
    
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup()
    {
        let viewController = self
        let interactor = GalleryInteractor()
        let presenter = GalleryPresenter()
        let router = GalleryRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // Setup the spinner for loading indicator here
    private func setupUI() {
        
        // Register our cell and other setups regarding collection view
        self.collectionView?.backgroundColor = UIColor.black
        self.collectionView?.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: self.photoCellIdentifier)
        
        // Setup loading spinner
        self.view.addSubview(spinner)
        spinner.snp.remakeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        
        // Prepare search related UI
        prepareSearchUI()
        
        // Setup navigation bar
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(refreshAction))
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupUI()
        
        loadPhotos()
    }
    
    // MARK: - UICollectionView Data Source and Delegate
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.displayedPhotos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifier, for: indexPath) as! PhotoCell
        
        let photo = self.displayedPhotos[indexPath.row]
        
        let url = URL(string: photo.media.m)!
        
        let resource = ImageResource(downloadURL: url, cacheKey: photo.media.m)
        cell.photoImageView.kf.indicatorType = .activity
        cell.photoImageView.kf.setImage(with: resource)
        
        cell.authorLabel.text = photo.author
        cell.locationLabel.text = photo.title
        let tags = photo.tags.characters.count > 0 ? "#\(photo.tags)" : photo.tags
        cell.tagsLabel.text = tags.replacingOccurrences(of: " ", with: " #")
        
        // Configure the cell
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = self.displayedPhotos[indexPath.row]
        
        router?.routeToPreview(photo: photo as AnyObject, segue: nil)
    }
    
    // MARK: Gallery Events
    
    @objc func refreshAction()
    {
        loadPhotos()
    }
    
    func loadPhotos(_ tags: String = "")
    {
        spinner.startAnimating()
        
        let request = Gallery.Photo.Request(tags: tags)
        interactor?.fetchPhotos(request: request)
    }
    
    
    // Present the photos sent from the presenter
    func displayPhotos(viewModel: Gallery.Photo.ViewModel)
    {
        spinner.stopAnimating()
        
        // If we failed to load the first time, retry it
        if viewModel.photos.count == 0 {
            self.loadPhotos()
        }
        else {
            print("photos: \(viewModel.photos)")
            self.displayedPhotos = viewModel.photos
            
            self.collectionView?.reloadData()
        }
    }
}

// Adjust the insets and item size for the gallery with flow layout delegate

extension GalleryViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (photosPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / photosPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return sectionInsets.left
    }
}

// Search related extension

extension GalleryViewController : UISearchBarDelegate {
    
    func prepareSearchUI() {
        searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(handleSearchAction))
        
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Search your tags"
        
        self.navigationItem.rightBarButtonItem = searchButton
    }
    
    @objc func handleSearchAction() {
        if let _ = self.navigationItem.titleView {
            self.navigationItem.titleView = nil
        }
        else {
            self.navigationItem.titleView = searchBar
            searchBar.becomeFirstResponder()
        }
    }
    
    func handleCancelSearchAction() {
        
    }
    
    // MARK: - Search Bar delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("tag search: \(searchText)")
        self.searchText = searchText
        
        // Do not reload immediately, it will become slow
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
            self.loadSearch(tags: searchText)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.loadSearch(tags: self.searchText)
        self.searchBar.resignFirstResponder()
    }
    
    func loadSearch(tags: String) {
        let search = tags.replacingOccurrences(of: " ", with: ", ")
        self.loadPhotos(search.lowercased())
    }
}
