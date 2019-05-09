//
//  ViewController.swift
//  CircularLoader
//
//  Created by Gokhan Demirer on 26/06/2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import UIKit

class ViewController: UIViewController, URLSessionDownloadDelegate {
    
    var shapeLayer: CAShapeLayer!
    var pulsatingLayer: CAShapeLayer!
    var trackLayer: CAShapeLayer!
    
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = "Start"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 38)
        return label
    }()
    
    let urlString = "http://file-examples.com/wp-content/uploads/2017/04/file_example_MP4_480_1_5MG.mp4"
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.backgroundColor
        
        setupShapeLayers()
        pulsateAnimate()
        setupPercentageLabel()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
    }
    
    @objc func handleEnterForeground() {
        pulsateAnimate()
    }
    
    fileprivate func setupShapeLayers() {
        pulsatingLayer = createShapeLayer(fillColor: UIColor.pulsatingFillColor, strokeColor: UIColor.clear)
        trackLayer = createShapeLayer(fillColor: UIColor.backgroundColor, strokeColor: UIColor.trackStrokeColor)
        shapeLayer = createShapeLayer(fillColor: UIColor.clear, strokeColor: UIColor.outlineStrokeColor)
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        shapeLayer.strokeEnd = 0
        
        view.layer.addSublayer(pulsatingLayer)
        view.layer.addSublayer(trackLayer)
        view.layer.addSublayer(shapeLayer)
    }
    
    fileprivate func setupPercentageLabel() {
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = view.center
        
        view.addSubview(percentageLabel)
    }
    
    fileprivate func createShapeLayer(fillColor: UIColor, strokeColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = 20
        layer.lineCap = kCALineCapRound
        layer.fillColor = fillColor.cgColor
        layer.position = view.center
        
        return layer
    }
    
    fileprivate func pulsateAnimate() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.3
        animation.duration = 1.2
        animation.repeatCount = Float.infinity
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        pulsatingLayer.add(animation, forKey: "pulsate")
    }
    
    fileprivate func beginDownloadingFile() {
        print("Attempting to download file")
        
        shapeLayer.strokeEnd = 0
        
        let configuration = URLSessionConfiguration.default
        let operationQueue = OperationQueue()
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)
        
        guard let url = URL(string: urlString) else { return }
        
        let downloadTask = session.downloadTask(with: url)
        downloadTask.resume()
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Finished downloading")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let percentage = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        print(percentage)
        
        DispatchQueue.main.async {
            self.percentageLabel.text = "\(Int(percentage * 100))%"
            self.shapeLayer.strokeEnd = percentage
        }
        
    }
    
    fileprivate func circleAnimate() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.duration = 2
        basicAnimation.toValue = 1
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.isRemovedOnCompletion = false
        
        shapeLayer.add(basicAnimation, forKey: "")
    }
    
    @objc private func handleTap() {
        beginDownloadingFile()
    }
}

