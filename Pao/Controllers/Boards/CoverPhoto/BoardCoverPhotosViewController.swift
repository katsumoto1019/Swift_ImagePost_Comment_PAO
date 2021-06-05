//
//  BoardCoverPhotoViewController.swift
//  Pao
//
//  Created by Waseem Ahmed on 22/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload

import Firebase
import CropViewController
import Kingfisher
import NVActivityIndicatorView

class BoardCoverPhotosViewController: CollectionViewController<ImageCollectionViewCell> {

    var needUpdateCoverPhotoCallback: (() -> Void)?

    private var boardId: String!
    private var imageUrls = [URL]()

    private var taskGroup = DispatchGroup()
    private let pickedImageView = UIImageView()

    init(boardId: String) {
        super.init()
        title = L10n.BoardCoverPhotosViewController.title

        self.boardId = boardId
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder : aDecoder)
    }
    
    override func getPayloads(completionHandler: @escaping ([ImageCollectionViewCell.PayloadType]?) -> Void) -> PayloadTask? {
        let params = CoverListParams(skip: imageUrls.count, take: 30, fid: DataContext.cache.user.id)
        let vars = BoardsVars(boardId: boardId)

        App.transporter.get([String].self, for: type(of: self), pathVars: vars, queryParams: params) { [weak self] data in
            guard data != nil else {
                completionHandler([])
                return
            }
            let newURLs = data.flatMap { $0.compactMap{ item in URL(string: item) }} ?? []
            self?.imageUrls.append(contentsOf: newURLs)
            completionHandler(newURLs)
        }
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cropImage(index: indexPath.row)
    }

    private func save(image: UIImage, completion: @escaping ((BoardMediaRequestItem?) -> Void)) {
        let vars = BoardSpotsVars(boardId: boardId)
        let params = FidParams(fid: DataContext.cache.user.id)

        let url = App.transporter.getUrl(BoardMediaItem.self, for: type(of: self), httpMethod: .put, pathVars: vars, queryParams: params)
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethod.put.rawValue
        let boundary = UUID().uuidString
        request.addValue(String(format: "multipart/form-data; boundary=%@", boundary), forHTTPHeaderField: "Content-Type")

        let imageData = image.jpegData(compressionQuality: 0.75) ?? image.pngData()

        guard let imgData = imageData else  { return }

        request.httpBody = createBodyWithParameters(parameters: nil, filePathKey: "file", imageDataKey: imgData, boundary: boundary) as Data

        App.transporter.executeRequest(request) { (result: BoardMediaRequestItem?) in
            completion(result)
        }
    }

    private func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: Data, boundary: String) -> Data {
        var body = Data()

        if parameters != nil {
            for (key, value) in parameters! {
                body.append(string: "--\(boundary)\r\n")
                body.append(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append(string: "\(value)\r\n")
            }
        }

        let filename = "user-profile.jpg"
        let mimetype = "image/jpg"

        body.append(string: "--\(boundary)\r\n")
        body.append(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.append(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.append(string: "\r\n")

        body.append(string: "--\(boundary)--\r\n")

        return body
    }
}

extension BoardCoverPhotosViewController: CropViewControllerDelegate {

    func cropImage(index: Int) {
        taskGroup.enter()
        
        pickedImageView.kf.setImage(with: imageUrls[index], placeholder: nil, options: nil) { (result) in
            self.taskGroup.leave()
            if let image = try? result.get().image {
                let cropViewController = CropViewController(image: image)
                cropViewController.aspectRatioPickerButtonHidden = true
                cropViewController.rotateButtonsHidden = true
                cropViewController.resetAspectRatioEnabled = false
                cropViewController.aspectRatioLockEnabled = true
                cropViewController.delegate = self
                cropViewController.setAspectRatioPreset(.presetSquare, animated: true)
                cropViewController.modalPresentationStyle = .fullScreen
                self.present(cropViewController, animated: true, completion: nil)
            }
        }
    }

    func cropViewController(_ cropViewController: CropViewController,
                            didCropToImage image: UIImage,
                            withRect cropRect: CGRect,
                            angle: Int) {
        pickedImageView.image = image
        cropViewController.dismiss(animated: true)

        let frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        let activityIndicatorView = NVActivityIndicatorView(
            frame: frame,
            type: .circleStrokeSpin,
            color: ColorName.greenAlertGradinentStart.color,
            padding: 8
        )

        self.view.isUserInteractionEnabled = false
        activityIndicatorView.startAnimating()

        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        save(image: image) { [weak self] result in
            self?.view.isUserInteractionEnabled = true
            activityIndicatorView.stopAnimating()
            if result?.updatedBoard?.modifiedCount == 1 {
                self?.navigationController?.popToRootViewController(animated: true)
                self?.needUpdateCoverPhotoCallback?()
            } else {
                self?.showMessagePrompt(
                    message: L10n.CoverViewController.Alert.Error.text,
                    title: L10n.Common.Error.title,
                    customized: true,
                    handler: nil)
            }
        }
    }
}
