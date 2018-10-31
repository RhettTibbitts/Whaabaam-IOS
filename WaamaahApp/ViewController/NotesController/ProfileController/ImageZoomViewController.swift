//
//  ImageZoomViewController.swift
//  WaamaahApp
//
//  Created by Ashish on 22/10/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class ImageZoomViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollImageView: UIImageView!
    @IBOutlet weak var scrollViewContainer: UIView!
    
    var imageURl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.scrollView.isScrollEnabled = true
        self.scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        
        scrollImageView.sd_setImage(with: URL.init(string: imageURl), placeholderImage: #imageLiteral(resourceName: "placeholder"), options: .continueInBackground, completed: nil)
        
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return scrollImageView
    }
    
    @IBAction func closeScrollView(_ sender: Any) {

        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
