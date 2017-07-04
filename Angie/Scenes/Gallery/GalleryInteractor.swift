//
//  GalleryInteractor.swift
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

protocol GalleryBusinessLogic
{
    func doSomething(request: Gallery.Photo.Request)
}

protocol GalleryDataStore
{
    //var name: String { get set }
}

class GalleryInteractor: GalleryBusinessLogic, GalleryDataStore
{
    var presenter: GalleryPresentationLogic?
    var worker: GalleryWorker?
    //var name: String = ""
    
    // MARK: Do something
    
    func doSomething(request: Gallery.Photo.Request)
    {
        worker = GalleryWorker()
        worker?.doSomeWork()
        
        let response = Gallery.Photo.Response()
        presenter?.presentSomething(response: response)
    }
}
