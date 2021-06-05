//
//  NewSpotPreviewViewController.swift
//  Pao
//
//  Created by Developer on 3/8/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Photos
import Firebase
import Payload
import RocketData


import MobileCoreServices

class NewSpotPreviewViewController: BaseViewController {
    
    @IBOutlet weak var carouselContainerView: UIView!
    @IBOutlet weak var uploadProgressLabel: UILabel!
    @IBOutlet weak var uploadSpotImageView: UIImageView! {
        didSet {
            uploadSpotImageView.layer.borderWidth = 0.8
            uploadSpotImageView.layer.borderColor = UIColor.white.cgColor
        }
    }
    @IBOutlet weak var uploadSpotLabel: UILabel!
    //@IBOutlet weak var shareButton: GradientButton!
    
    var spotCollectionViewController: SpotPreviewCollectionViewController!
    let taskGroup = DispatchGroup()
    var spot: Spot!
    var phAssets: [PHAsset] = []
    let spotId = DataContext.randomId
    var incompleteSpotListener: ListenerRegistration?
    
    
    var shapeLayer: CAShapeLayer!
    var pulsatingLayer: CAShapeLayer!
    
    var task: URLSessionTask?
    //var phAssetsDictionary = [String: PHAsset]()
    //var uploadImagesDictionary = [String:UIImage]()
    var cropDataList = [PHAsset:CropData]()
    
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.SpotCollectionViewCell.labelUploading
        label.textAlignment = .center
        label.set(fontSize: UIFont.sizes.veryLarge)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = "Upload Preview"
        
        title = L10n.NewSpotPreviewViewController.title
        initialize()
        
        spot.uploadStatus = SpotUploadStatus.preview.rawValue
        spot.user = SpotUser(id: DataContext.userUID)
        spot.user?.name = DataContext.cache.user.name
        spot.user?.profileImage = DataContext.cache.user.profileImage
        
        App.transporter.get(UploadMessgae.self) { (uploadMessage) in
            if (uploadMessage != nil) {
                self.uploadProgressLabel.text = uploadMessage?.text
            }
        }
    }
    
    private func initialize() {
        applyStyle()
        setupCarouselViewController()
        
        uploadSpotImageView.contentMode = .center
        uploadSpotImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(uploadButtonTap(sender:))))
        
        uploadSpotLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(uploadButtonTap(sender:))))
    }
    
    override func applyStyle() {
        super.applyStyle()
        uploadProgressLabel.set(fontSize: UIFont.sizes.normal)
        
        uploadProgressLabel.layer.masksToBounds = true
        uploadProgressLabel.layer.cornerRadius = self.uploadProgressLabel.bounds.size.height / 2
        uploadProgressLabel.textColor = ColorName.accent.color

        uploadSpotLabel.set(fontSize: UIFont.sizes.normal)

        uploadSpotImageView.layer.cornerRadius = uploadSpotImageView.frame.size.height / 2
        //shareButton.layer.cornerRadius = shareButton.frame.height / 2
        //shareButton.layer.masksToBounds = true
        //shareButton.titleLabel?.font = UIFont.appBold.withSize(UIFont.sizes.small)
    }
    
    func setupCarouselViewController() {
        spotCollectionViewController = SpotPreviewCollectionViewController(spot: spot, phAssets: phAssets,cropDataList: cropDataList)
        spotCollectionViewController.centerSpinnerView = nil
        
        self.addChild(spotCollectionViewController)
        spotCollectionViewController.view.frame = carouselContainerView.bounds
        carouselContainerView.addSubview(spotCollectionViewController.view)
        spotCollectionViewController.didMove(toParent: self)
    }
    
    //@IBAction @objc private func uploadButtonTap(sender: Any) {
    @objc private func uploadButtonTap(sender: UITapGestureRecognizer) {
        uploadSpotLabel.isHidden = true
        uploadSpotImageView.isUserInteractionEnabled = false
        setupCircleLayers()
        animatePulsatingLayer()
        createSpotAndTryUpload()
    }
    
    @objc func dismissViewController() {
        task?.cancel()
        UploadBoardCollectionViewController.uploadInProgress = false
        App.transporter.delete(Spot.self, pathVars: spot.id) { (success) in
            print("success: \(String(describing: success))")
        }
        navigationController?.dismiss(animated: true)
    }
    
    func createSpotAndTryUpload() {
        FirbaseAnalytics.logEvent(.uploadNow)
        
        spot.id = spotId
        var spotMediaDictionary = SpotMediaDictionary()
        var phAssetsDictionary = [String: PHAsset]()
        var uploadImagesDictionary = [String:UIImage]()
        
        phAssets.forEach { (phAsset) in
            let spotMediaItem = SpotMediaItem()
            spotMediaItem.id = DataContext.randomId
            spotMediaItem.index = phAssets.firstIndex(of: phAsset)
            spotMediaItem.type = phAsset.mediaType == .video ? 1 : 0
            spotMediaItem.placeholderColor = "#ffffff"
            spotMediaDictionary[spotMediaItem.id!] =  spotMediaItem
            
            phAssetsDictionary[spotMediaItem.id!] =  phAsset
            if let asset = cropDataList[phAsset] {
                uploadImagesDictionary[spotMediaItem.id!] = asset.cropedImage
            }
        }
        
        spot.isMediaServed = false
        spot.timestamp = Date()
        spot.mediaCount = spotMediaDictionary.count
        spot.imagesCount = spotMediaDictionary.values.filter({$0.type == 0}).count
        spot.videosCount = spotMediaDictionary.values.filter({$0.type == 1}).count
        spot.media = spotMediaDictionary
        
        upload(spot: spot, phAssetsDictionary: phAssetsDictionary,uploadImagesDictionary: uploadImagesDictionary)
    }
    
//    func createSpotAndTryUpload() {
//        FirbaseAnalytics.logEvent(.uploadNow)
//
//        spot.id = spotId
//        spot.uploadStatus = SpotUploadStatus.uploading.rawValue
//
//        if let tabBarController = UIApplication.shared.delegate?.window??.rootViewController as? TabBarController {
//            tabBarController.showFeed()
//
//            // Start upload in background
//            tabBarController.upload(spot: spot, phAssetsDictionary: phAssetsDictionary, uploadImagesDictionary: uploadImagesDictionary)
//            self.navigationController?.dismiss(animated: true, completion: nil)
//        }
//    }
    
    private func spotUploaded(spot: Spot?) {
        UploadBoardCollectionViewController.uploadInProgress = true
        
        guard let spot = spot else {
            let message = L10n.TabBarController.UploadError.checkInternetConnectioin
            showMessagePrompt(message: message, handler: { (alertAction) in
                self.navigationController?.dismiss(animated: true)
            })
            AmplitudeAnalytics.logEvent(.checkInternetConnection, group: .uploadEvents, properties: ["error": message])
            UploadBoardCollectionViewController.uploadInProgress = false
            return
        }
        
        let dataProvider = CollectionDataProvider<Spot>()
        dataProvider.fetchDataFromCache(withCacheKey: "Feed", completion: { (spots, error) in
            // Crash fix: Logout -> New Account -> Upload
            if spots?.count ?? 0 < 1 {
                dataProvider.setData([spot], cacheKey: "Feed")
            } else {
                dataProvider.insert([spot], at: 0)
            }
        })
        AmplitudeAnalytics.logEvent(.uploadSuccess, group: .uploadEvents)
        AmplitudeAnalytics.addUserValue(property: .uploads, value: 1)

        navigationController?.dismiss(animated: true)
        (UIApplication.shared.delegate?.window??.rootViewController as? TabBarController)?.showFeed()
    }
    
    private func setupPercentageLabel() {
        view.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = view.center
    }
    
    private func setupCircleLayers() {
        pulsatingLayer = createCircleShapeLayer(strokeColor: .clear, fillColor: ColorName.pulsatingLayer.color)
        self.view.layer.addSublayer(pulsatingLayer)
        
        let trackLayer = createCircleShapeLayer(strokeColor: ColorName.trackLayer.color, fillColor: ColorName.trackLayer.color)
        self.view.layer.addSublayer(trackLayer)
        
        shapeLayer = createCircleShapeLayer(strokeColor: ColorName.circleShapeLayer.color, fillColor: .clear)
        
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        shapeLayer.strokeEnd = 0
        self.view.layer.addSublayer(shapeLayer)
        self.view.bringSubviewToFront(uploadSpotImageView)
    }
    
    private func createCircleShapeLayer(strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 35, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = 7
        layer.fillColor = fillColor.cgColor
        layer.lineCap = CAShapeLayerLineCap.round
        layer.position = self.uploadSpotImageView.center
        return layer
    }
    
    private func animatePulsatingLayer() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.25
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        pulsatingLayer.add(animation, forKey: "pulsing")
    }
    
    private func updateProgress(_ progress: Double) {
        shapeLayer.strokeEnd = CGFloat(progress)
        uploadProgressLabel.isHidden = false
    }
}

extension NewSpotPreviewViewController {

    func upload(spot: Spot, phAssetsDictionary: [String: PHAsset], uploadImagesDictionary: [String: UIImage]) {
        let url = App.transporter.getUrl(Spot.self, httpMethod: .post)
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 3000.0
        
        let boundary = UUID().uuidString
        request.addValue(String(format: "multipart/form-data; boundary=%@", boundary), forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = HttpMethod.post.rawValue
        
        createMultipartBody(formJson: String(bytes: try! spot.toData(), encoding: String.Encoding.utf8)!, phAssetsDictionary: phAssetsDictionary, uploadImagesDictionary:uploadImagesDictionary, boundary: boundary) { [weak self] data in
            
            guard let data = data else {
                self?.spotUploaded(spot: nil)
                return
            }

            let uploadSizeLimit = 60 * 1024 * 1024

            if data.count > uploadSizeLimit {
                let message = "Oops! Your post is too large for Pao. Please make sure your photos and videos total less than 60MB and try again."
                self?.navigationController?.topViewController?.showMessagePrompt(
                    message: message,
                    customized: true)
                AmplitudeAnalytics.logEvent(.postIsTooLarge, group: .uploadEvents, properties:["error": message])
            } else {

                self?.navigationItem.leftBarButtonItem = UIBarButtonItem(
                    barButtonSystemItem: UIBarButtonItem.SystemItem.cancel,
                    target: self,
                    action: #selector(self?.dismissViewController))

                AmplitudeAnalytics.logEvent(.completeUploadSpot, group: .upload)

                request.httpBody = data
                
                var observation: NSKeyValueObservation?
                
                self?.task = App.transporter.executeRequest(request) { (result: Spot?) in
                    self?.spotUploaded(spot: result)
                    observation?.invalidate()
                }
                
                observation = self?.task?.progress.observe(\.fractionCompleted) { progress, _ in
                    DispatchQueue.main.async {
                        self?.updateProgress(progress.fractionCompleted)
                    }
                }
            }
        }
    }
    
    func createMultipartBody(formJson: String, phAssetsDictionary: [String : PHAsset], uploadImagesDictionary: [String : UIImage], boundary: String, completion: @escaping (Data?) -> Void)
    {
        var body = Data()
        
        //boundary
        body.append(String(format:"--%@\r\n", boundary).data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"spot\"\r\n".data(using: String.Encoding.utf8)!)
        body.append(String(format:"Content-Type: application/json\r\n\r\n").data(using: String.Encoding.utf8)!)
        body.append(formJson.data(using: String.Encoding.utf8)!)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        for media in phAssetsDictionary
        {
            taskGroup.enter()
            media.value.toFormData { (data, mime) in
                if let data = data, let mime = mime {
                    body.append(String(format:"--%@\r\n", boundary).data(using: String.Encoding.utf8)!)
                    body.append(String(format:"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", media.key, media.key).data(using: String.Encoding.utf8)!)
                    body.append(String(format:"Content-Type: %@\r\n\r\n", mime).data(using: String.Encoding.utf8)!)
                    
                    var imageData: Data
                    if let croppedImage = uploadImagesDictionary[media.key], let croppedImageData = croppedImage.jpegData(compressionQuality: 0.75) ?? croppedImage.pngData() {
                        imageData = croppedImageData
                    } else {
                        imageData = data
                    }
                    
                    body.append(imageData)
                    body.append("\r\n".data(using: String.Encoding.utf8)!)
                    
                    self.taskGroup.leave()
                } else {
                    completion(nil)
                }
            }
        }
        
        taskGroup.notify(queue: .main) {
            //end boundary
            body.append(String(format:"--%@--", boundary).data(using: String.Encoding.utf8)!)
            completion(body)
        }
    }
}

extension PHAsset {
    func toFormData(imageQuality: CGFloat = 0.75, completion: @escaping (Data?, String?) -> Void) {
        let phAsset = self
        
        if phAsset.mediaType == .video {
            let videoRequestOptions = PHVideoRequestOptions()
            videoRequestOptions.deliveryMode = .highQualityFormat
            videoRequestOptions.isNetworkAccessAllowed = true
            
            PHImageManager.default().requestAVAsset(forVideo: phAsset, options: videoRequestOptions, resultHandler: { (avAsset, avAudioMix, info) in
                DispatchQueue.main.sync {
                    guard let video = avAsset as? AVURLAsset, let videoData = try? Data(contentsOf: video.url) else {
                        let message = "Could not get video!"
                        debugPrint(message)
                        AmplitudeAnalytics.logEvent(.couldNotGetVideo, group: .uploadEvents, properties:["error": message])
                        completion(nil, nil)
                        return
                    }
                    
                    let assetResource = PHAssetResource.assetResources(for: phAsset)
                    
                    //Note: just to make sure, in case if assetResource.last doen't work, then check for assetResource.first.
                    if let uiTId = assetResource.last?.uniformTypeIdentifier as CFString?, let mimeType = UTTypeCopyPreferredTagWithClass(uiTId, kUTTagClassMIMEType as CFString)?.takeRetainedValue() as String? {
                        completion(videoData, mimeType)
                    } else if let uiTId = assetResource.first?.uniformTypeIdentifier as CFString?, let mimeType = UTTypeCopyPreferredTagWithClass(uiTId, kUTTagClassMIMEType as CFString)?.takeRetainedValue() as String? {
                        completion(videoData, mimeType)
                    } else {
                        let message = "Could not get mimeType!"
                        debugPrint(message)
                        AmplitudeAnalytics.logEvent(.couldNotGetImage, group: .uploadEvents, properties:["error": message])
                        completion(nil, nil)
                    }
                }
            })
        } else {
            let imageRequestOptions = PHImageRequestOptions()
            imageRequestOptions.deliveryMode = .highQualityFormat
            imageRequestOptions.resizeMode = .fast //this is the candidate fix for the blurry uploads PPL-280
            imageRequestOptions.version = .current //asking for the current brings the edited version, but original brings unedited
            imageRequestOptions.isNetworkAccessAllowed = true //allow access to iCloud photos
            imageRequestOptions.isSynchronous = false
            
            var targetSize = PHImageManagerMaximumSize
            if phAsset.pixelWidth > 2048 || phAsset.pixelHeight > 2048 {
                targetSize = CGSize(width: 2048, height: 2048)
            }
            
            PHImageManager.default().requestImage(for: phAsset, targetSize: targetSize, contentMode: .aspectFit, options: imageRequestOptions) { (image, info) in
                guard let image = image, let imageData = image.jpegData(compressionQuality: imageQuality) ?? image.pngData() else {
                    let message = "Could not get image!"
                    debugPrint(message)
                    AmplitudeAnalytics.logEvent(.couldNotGetMimeType, group: .uploadEvents, properties:["error": message])
                    completion(nil, nil)
                    return
                }
                if let info = info, let isDegradedImage = info["PHImageResultIsDegradedKey"] as? Bool, !isDegradedImage {
                    completion(imageData, "image/jpeg")
                }
            }
        }
    }
}
