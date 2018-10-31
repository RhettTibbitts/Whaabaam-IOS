//
//  SocialSharingHelper.swift
//  MeClub
//
//  Created by Ashish Kumar singh on 03/08/18.
//  Copyright © 2017 Ashish Kumar singh. All rights reserved.
//

import Foundation

class SocialSharingHelper: NSObject,SFSafariViewControllerDelegate,FBSDKSharingDelegate {
    
    class func facebookSharing(type : String, shareImg : String, shareText : String, shareUrl : String, controller : UIViewController, delegate: FBSDKSharingDelegate) {
        
        if type == kFacebook {
            let shareImageView = UIImageView.init()
            
            var img = UIImage()
            if shareImg == kPlaceholder {
                img = UIImage.init(named: shareImg)!
            } else {
//                shareImageView.sd_setImag
//                shareImageView.sd_setImage(with: imageURL(str: imgURL)!, placeholderImage:  imageLiteral(resourceName: "placeholder.png"))
                shareImageView.af_setImage(withURL: URL.init(string: shareImg)!)
                self.getDataFromUrl(url:  URL.init(string: shareImg)!, completion: { (data, response, error) in
                    if error == nil {
                        let imgData  = data
                        img = UIImage.init(data: imgData!)!
                        let photo:FBSDKSharePhoto = FBSDKSharePhoto()
                        
                        photo.image = img
                        photo.isUserGenerated = true
                        photo.caption = shareText
                        
                        let content : FBSDKSharePhotoContent = FBSDKSharePhotoContent()
                        content.photos = [photo]
                        content.contentURL = URL.init(string: shareUrl)
                        delay(0.0, completion: {
                            let shareDialog: FBSDKShareDialog = FBSDKShareDialog()
                            shareDialog.mode = .native
                            shareDialog.shareContent = content
                            shareDialog.delegate = delegate
                            shareDialog.fromViewController = controller
                            shareDialog.show()
                        })
                    }
                })
            }
        }
    }
    
    class func sharingContent(type : String, shareImg : String, shareText : String, shareUrl : String, controller : UIViewController) {
        
        if type == kFacebook {
            let shareImageView = UIImageView.init()

            var img = UIImage()
            if shareImg == kPlaceholder {
                img = UIImage.init(named: shareImg)!
            } else {
                shareImageView.af_setImage(withURL: URL.init(string: shareImg)!)
                let imgData  = UIImageJPEGRepresentation(shareImageView.image!, 0.25)
                img = UIImage.init(data: imgData!)!
            }
            let photo:FBSDKSharePhoto = FBSDKSharePhoto()

            photo.image = img
            photo.isUserGenerated = true
            photo.caption = shareText
            
            let content : FBSDKSharePhotoContent = FBSDKSharePhotoContent()
            content.photos = [photo]
            content.contentURL = URL.init(string: shareUrl)
            let shareDialog: FBSDKShareDialog = FBSDKShareDialog()
            shareDialog.mode = .native
            shareDialog.shareContent = content
            shareDialog.delegate = controller as! FBSDKSharingDelegate
            shareDialog.fromViewController = controller
            shareDialog.show()

        } else if type == kTwitter {
            if (Twitter.sharedInstance().sessionStore.hasLoggedInUsers()) {
                var img = UIImage()
                if shareImg == kPlaceholder {
                    img = UIImage.init(named: shareImg)!
                } else {
                    
                    self.getDataFromUrl(url:  URL.init(string: shareImg)!, completion: { (data, response, error) in
                        if error == nil {
                            let imgData  = data
                            img = UIImage.init(data: imgData!)!
                            
                            delay(0.0, completion: {
//                                let composer = TWTRComposer()
//
//                                composer.setText(shareText)
//                                composer.setImage(img)
                                let twtrController = TWTRComposerViewController.init(initialText: shareText, image: img, videoURL: nil)
                                twtrController.delegate = controller as? TWTRComposerViewControllerDelegate
                                controller.present(twtrController, animated: true, completion: nil)
                                // Called from a UIViewController
//                                composer.show(from: controller, completion: { (result) in
//                                    for obj in controller.view.subviews {
//                                        if obj.isKind(of: TWTRComposer.self)  {
//                                            obj.removeFromSuperview()
//                                        }
//                                    }
//                                    if (result == .done) {
//                                        MCCustomAlertController.alert(title: "", message: "Shared Successfully.", buttons: ["OK"], tapBlock: { (action, index) in
//                                            //
//                                        })
//                                    } else {
//                                        MCCustomAlertController.alert(title: "", message: "Something went wrong.", buttons: ["OK"], tapBlock: { (action, index) in
//                                            //
//                                        })
//                                    }
//                                })
                            })
                        }
                    })
                }
                
            } else {
                // Log in, and then check again
                Twitter.sharedInstance().logIn { session, error in
                    if session != nil { // Log in succeeded
                        let shareImageView = UIImageView.init()
                        var img = UIImage()
                        if shareImg == kPlaceholder {
                            img = UIImage.init(named: shareImg)!
                        } else {
                            shareImageView.af_setImage(withURL: URL.init(string: shareImg)!)
                            let imgData  = UIImageJPEGRepresentation(shareImageView.image!, 0.25)
                            img = UIImage.init(data: imgData!)!
                        }
                        let composer = TWTRComposer()
                        
                        composer.setText(shareText)
                        composer.setImage(img)
                    
                        // Called from a UIViewController
                        composer.show(from: controller, completion: { (result) in
                            for obj in controller.view.subviews {
                                if obj.isKind(of: TWTRComposer.self)  {
                                    obj.removeFromSuperview()
                                }
                            }
                            if (result == .done) {
                                MCCustomAlertController.alert(title: "", message: "Shared Successfully.", buttons: ["OK"], tapBlock: { (action, index) in
                                    //
                                })
                            } else {
                                MCCustomAlertController.alert(title: "", message: "Something went wrong.", buttons: ["OK"], tapBlock: { (action, index) in
                                    //
                                })
                            }
                        })
                        
                    } else {
                        MCCustomAlertController.alert(title: "", message: "Something went wrong.", buttons: ["OK"], tapBlock: { (action, index) in
                            //
                        })
                    }
                }
            }
            
        } else if type == "pinterest" {
            PDKClient.configureSharedInstance(withAppId: "4936306679565269529")
            if(PDKClient.sharedInstance().authorized == false)
            {
                PDKClient.sharedInstance().authenticate(withPermissions: [PDKClientReadPublicPermissions,PDKClientReadPublicPermissions,PDKClientReadRelationshipsPermissions,PDKClientWritePublicPermissions,PDKClientWritePublicPermissions,PDKClientWriteRelationshipsPermissions], from: controller, withSuccess: { (response : PDKResponseObject!) -> Void in
                    self.showHud()
                    PDKClient.sharedInstance().getAuthenticatedUserBoards(withFields: ["id", kName,"url","description",kImage], success: { (response) in
                        if response != nil {
                            
                            var boardID  = ""
                            var boardName = ""
                            for dict in (response?.parsedJSONDictionary[kData] as? Array<[AnyHashable : Any]>)! {
                                if (dict[kName] as? String)! == "MeClub" {
                                    boardID = (dict["id"] as? String)!
                                    boardName = (dict[kName] as? String)!
                                    break
                                }
                            }
                            if boardName == "MeClub" {
                                let shareImageView = UIImageView.init()
                                
                                var img = UIImage()
                                if shareImg == kPlaceholder {
                                    img = UIImage.init(named: shareImg)!
                                } else {
                                    shareImageView.af_setImage(withURL: URL.init(string: shareImg)!)
                                    img = shareImageView.image!
                                }
                                PDKClient.sharedInstance().createPin(with: img, link: URL.init(string: shareUrl), onBoard: boardID, description: shareText, progress: { (progress) in
                                }, withSuccess: { (success) in
                                    self.hideHud()
                                    MCCustomAlertController.alert(title: "", message: "Shared successfully.", buttons: ["OK"], tapBlock: { (action, index) in
                                        //
                                    })
                                }, andFailure: { (error) in
                                    self.hideHud()
                                    MCCustomAlertController.alert(title: "", message: (error?.localizedDescription)!, buttons: ["OK"], tapBlock: { (action, index) in
                                        //
                                    })
                                })
                            } else {
                                PDKClient.sharedInstance().createBoard("MeClub", boardDescription: "Loyalty Base App", withSuccess: { (response) in
                                    boardID = ((response?.parsedJSONDictionary as! Dictionary<AnyHashable,Any>)[kData]  as! Dictionary<AnyHashable,Any>)["id"] as! String
                                    let shareImageView = UIImageView.init()
                                    
                                    var img = UIImage()
                                    if shareImg == kPlaceholder {
                                        img = UIImage.init(named: shareImg)!
                                    } else {
                                        shareImageView.af_setImage(withURL: URL.init(string: shareImg)!)
                                        img = shareImageView.image!
                                    }
                                    PDKClient.sharedInstance().createPin(with: img, link: URL.init(string: shareUrl), onBoard: boardID, description: shareText, progress: { (progress) in
                                    }, withSuccess: { (success) in
                                        self.hideHud()
                                        MCCustomAlertController.alert(title: "", message: "Shared successfully.", buttons: ["OK"], tapBlock: { (action, index) in
                                            //
                                        })
                                    }, andFailure: { (error) in
                                        self.hideHud()
                                        MCCustomAlertController.alert(title: "", message: (error?.localizedDescription)!, buttons: ["OK"], tapBlock: { (action, index) in
                                            //
                                        })
                                    })
                                }, andFailure: { (error) in
                                    MCCustomAlertController.alert(title: "", message: (error?.localizedDescription)!, buttons: ["OK"], tapBlock: { (action, index) in
                                        //
                                    })
                                })
                            }
                        }
                    }, andFailure: { (error) in
                        
                        MCCustomAlertController.alert(title: "", message: (error?.localizedDescription)!, buttons: ["OK"], tapBlock: { (action, index) in
                            //
                        })
                    })
                    
                }, andFailure: { error in
                    MCCustomAlertController.alert(title: "", message: (error?.localizedDescription)!, buttons: ["OK"], tapBlock: { (action, index) in
                        //
                    })
                })
            }
        } else if type == kGooglePlus {
            let urlstring = shareUrl
            
            let shareURL = NSURL(string: urlstring)
            
            let urlComponents = NSURLComponents(string: "https://plus.google.com/share")
            
            urlComponents!.queryItems = [NSURLQueryItem(name: "url", value: shareURL!.absoluteString) as URLQueryItem]
            
            let url = urlComponents!.url!
            
            let svc = SFSafariViewController(url: url)
            svc.delegate = controller as? SFSafariViewControllerDelegate
            controller.present(svc, animated: true, completion: nil)
        }
    }
    
    class func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    //MARK : Helper Methods
    class func showHud() {
        let attribute = RappleActivityIndicatorView.attribute(style: RappleStyleCircle, tintColor: .white, screenBG: nil, progressBG: .black, progressBarBG: .lightGray, progreeBarFill: .yellow)
        RappleActivityIndicatorView.startAnimating(attributes: attribute)
    }
    
    class func hideHud() {
        RappleActivityIndicatorView.stopAnimation()
        RappleActivityIndicatorView.stopAnimation(completionIndicator: .none, completionLabel: "", completionTimeout: 1.0)
    }
    
    //MARK : SafariController Delegate Method
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //MARK : Facebook Delegate
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        MCCustomAlertController.alert(title: "", message: "Shared successfully.", buttons: ["OK"], tapBlock: { (action, index) in
            //
        })
    }
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        MCCustomAlertController.alert(title: "", message: "Something went wrong.", buttons: ["OK"], tapBlock: { (action, index) in
            //
        })
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        //
    }
}
