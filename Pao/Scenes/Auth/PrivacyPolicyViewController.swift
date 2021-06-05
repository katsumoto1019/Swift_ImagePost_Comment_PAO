//
//  PrivacyPolicyViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 5/4/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import PDFKit

class PrivacyPolicyViewController: BaseViewController {
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var dismissButton: UIButton!
    
    private static var privacyPolicy: PDFDocument?;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDismissButton();
        setupPDFView();
    }
    
    private func setupDismissButton() {
        dismissButton.layer.shadowColor = UIColor.black.cgColor;
        dismissButton.layer.shadowRadius = 10.0;
        dismissButton.layer.shadowOpacity = 1.0;
    }
    
    private func setupPDFView() {
        pdfView.interpolationQuality = .low;
        pdfView.displayMode = .singlePageContinuous;
        
        loadPrivacyPolicy();
    }
    
    private func loadPrivacyPolicy() {
        if (PrivacyPolicyViewController.privacyPolicy == nil) {
            downloadPrivacyPolicy();
        } else {
            pdfView.document = PrivacyPolicyViewController.privacyPolicy;
            // NOTE: Scale factor settings must be set after setting document
            pdfView.autoScales = true;
            pdfView.maxScaleFactor = 4.0;
            pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit;
        }
    }
    
    // REF: https://stackoverflow.com/questions/45717813/pdfkits-pdfdocument-initurl-url-does-not-work-with-https
     func downloadPrivacyPolicy() {
        guard PrivacyPolicyViewController.privacyPolicy == nil else { return; }
        
        startActivityIndicator();
        
        let url = Bundle.main.apiUrl.appendingPathComponent("assets/docs/tos.pdf");
        
        URLSession.shared.downloadTask(with: url) { (tempLocalURL, urlResponse, error) in
            DispatchQueue.main.async {
                self.stopActivityIndicator();
            
                guard let pdfTempLocalURL = tempLocalURL else { return; }
                PrivacyPolicyViewController.privacyPolicy = PDFDocument(url: pdfTempLocalURL);
                self.loadPrivacyPolicy();
            }
        }.resume();
    }

    @IBAction func dismissViewController(_ sender: Any) {
        dismiss(animated: true, completion: nil);
    }
}
