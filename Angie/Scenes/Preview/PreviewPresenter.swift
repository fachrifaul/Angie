//
//  PreviewPresenter.swift
//  Angie
//
//  Created by Suhendra Ahmad on 7/5/17.
//  Copyright (c) 2017 Suhendra Ahmad. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol PreviewPresentationLogic
{
    func presentPhoto(response: Preview.Photo.Response)
}

class PreviewPresenter: PreviewPresentationLogic
{
    weak var viewController: PreviewDisplayLogic?
    
    // MARK: Do something
    
    func presentPhoto(response: Preview.Photo.Response)
    {
        let viewModel = Preview.Photo.ViewModel(photo: response.photo)
        viewController?.displayPhoto(viewModel: viewModel)
    }
}
