//
//  ViewController.swift
//  LEDDemo
//
//  Created by Mac-0006 on 27/07/23.
//

import UIKit
import AVKit
import ReplayKit
import MobileCoreServices
import Photos

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
let gifType = UTType.gif.identifier as CFString
#else
let gifType = kUTTypeGIF
#endif

struct Fonts {
    
    //.. Used In App
    static let SFProRoundedBold = "SFProRounded-Bold"
    static let SFProRoundedRegular = "SFProRounded-Regular"
    static let LEDCounter7 = "LEDCounter7"
    static let SFProTextRegularItalic = "SFProText-RegularItalic"
}

protocol ViewControllerDelegate {
    func didFinishGenerateGif(url: URL?)
    func didFinishGenerateMovie(url: URL?)
}
class ViewController: UIViewController {
    
    @IBOutlet weak var mainView: UIView!

    @IBOutlet weak var marqueeLabel: UILabel!
    @IBOutlet weak var collMain: UIView!
    let greenLabel = UILabel()
    @IBOutlet weak var btnUnlock: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var lblText: UILabel!

    var bannerData: BannerData?
    var delegate: ViewControllerDelegate?
    
    var isGlowOn = false
    var isBlinkingOn = false
    var isMirroringOn = false
    
    var scrollingAnimationDelay = 0.5

    var scrollingSpeed: TimeInterval {
        return TimeInterval(self.bannerData?.scrollingSpeed ?? 0.0)
    }
    
    var pause = false
    var timer: Timer?
    var screenshotImages: [UIImage] = []
    
    let recorder = RPScreenRecorder.shared()
    private var isRecording = false

    var isLock = false

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // This will remove all animations from the view
        self.greenLabel.layer.removeAllAnimations()
        timer = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainView.backgroundColor = UIColor.hexStringToUIColor(hex: bannerData?.bannerBackgroundColor ?? "") 

        if self.bannerData?.saveMovie ?? false || self.bannerData?.sendMovie ?? false {
            btnBack.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.startRecording()
            })
        } else {
            configure()
        }
        
    }
    
    func configure() {
        addGreenLabel()
        setupAutoLayout()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            if self.bannerData?.isRightToLeft ?? false {
                self.rightToLeft()
            } else {
                self.leftToRight()
            }
        })
        
        if bannerData?.blinking ?? false {
            greenLabel.startBlink(withSpeed: bannerData?.blinkingSpeed ?? 0.05, withDensity: bannerData?.blinkingDensity ?? 1.0)
        } else {
            greenLabel.stopBlink()
        }
        
        self.greenLabel.transform = CGAffineTransform(scaleX: (bannerData?.mirroring ?? false) ? -1 : 1, y: 1);
        
        if bannerData?.lockingOption ?? false {
            btnUnlock.isHidden = false
        } else {
            btnUnlock.isHidden = true
        }
        
        if bannerData?.stopOption ?? false {
            btnPlayPause.isHidden = false
            btnPlayPause.setImage(UIImage(named: "pause"), for: .normal)
        }
        
        if self.bannerData?.saveGif ?? false || self.bannerData?.sendGif ?? false {
            btnBack.isHidden = true
            timer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        }
    }
    
    @objc func update() {
        // Something cool
        print("Done")
        screenshotImages.append(self.mainView.snapshot())
    }

    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        let layer = greenLabel.layer
        pause = !pause
        if pause {
            pauseLayer(layer: layer)
        } else {
            resumeLayer(layer: layer)
        }
    }
    
    func addGreenLabel() {
        greenLabel.translatesAutoresizingMaskIntoConstraints = false
        greenLabel.textColor = UIColor.hexStringToUIColor(hex: bannerData?.bannerTextColor ?? "")
        greenLabel.text = bannerData?.text
        
        if (bannerData?.isBold ?? false ) {
            if bannerData?.bannerTextFont.contains("SFPro") ?? false {
                greenLabel.font = UIFont(name: Fonts.SFProRoundedBold, size: CGFloat(bannerData?.bannerTextFontSize ?? 0))
            } else {
                greenLabel.font = UIFont(name: bannerData?.bannerTextFont ?? "", size: CGFloat(bannerData?.bannerTextFontSize ?? 0))
            }
        } else if (bannerData?.isItalic ?? false ) {
            if bannerData?.bannerTextFont.contains("SFPro") ?? false {
                greenLabel.font = UIFont(name: Fonts.SFProTextRegularItalic, size: CGFloat(bannerData?.bannerTextFontSize ?? 0))
            } else {
                greenLabel.font = UIFont(name: bannerData?.bannerTextFont ?? "", size: CGFloat(bannerData?.bannerTextFontSize ?? 0))
            }
        } else {
            greenLabel.font = UIFont(name: bannerData?.bannerTextFont ?? "", size: CGFloat(bannerData?.bannerTextFontSize ?? 0))
        }

        if bannerData?.glwoing ?? false {
            greenLabel.layer.shadowOffset = .zero
            greenLabel.layer.shadowRadius = 7
            greenLabel.layer.shadowOpacity = 1
            greenLabel.layer.masksToBounds = false
            greenLabel.layer.shouldRasterize = true
            greenLabel.layer.shadowColor = UIColor.hexStringToUIColor(hex: bannerData?.bannerTextColor ?? "").cgColor
        }
        
        mainView.addSubview(greenLabel)
    }
    
    func rightToLeft() {
        
        DispatchQueue.main.async(execute: {
            
            let originalCenter = self.greenLabel.center

            UIView.animate(withDuration: Double(100 / self.scrollingSpeed), delay: 0.0, options: ([.curveLinear]), animations: {() -> Void in
                
                
                self.greenLabel.center = CGPoint(x: 0 - self.greenLabel.bounds.size.width / 2, y: self.greenLabel.center.y)
                
            }, completion:  { finished in
                
                // Check if the animation was actually finished
                if finished {
                    
                    let url = self.createGif(screenshots: self.screenshotImages, frameDelay: 0.5, loopCount: 0)
                    
                    if self.bannerData?.saveGif ?? false || self.bannerData?.sendGif ?? false {
                        self.delegate?.didFinishGenerateGif(url: url)
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                    if self.bannerData?.saveMovie ?? false || self.bannerData?.sendMovie ?? false {
                        self.stopRecording()
                    }

                    self.timer = nil
                    
                    self.doShowFinishEvent()
                    
                    // Reset the center position of the label
                    self.greenLabel.center = originalCenter
                    
                    // Call the same function to run the animation again
                    self.rightToLeft()
                }

            })
        })
    }
    
    func leftToRight() {
        
        // Initial position of label, far left beyond the visible view
        let originalCenter = CGPoint(x: 0 - self.greenLabel.bounds.size.width / 2, y: self.greenLabel.center.y)
        self.greenLabel.center = originalCenter
        
        DispatchQueue.main.async(execute: {
            
            UIView.animate(withDuration: Double(100 / self.scrollingSpeed), delay: 0, options: ([.curveLinear]), animations: {() -> Void in
                
                // Animate to the right of the view, off screen
                self.greenLabel.center = CGPoint(x: self.mainView.bounds.size.width + self.greenLabel.bounds.size.width / 2, y: self.greenLabel.center.y)
                
            }, completion:  { finished in
                
                // Check if the animation was actually finished
                if finished {
                    
                    self.doShowFinishEvent()
                    
                    // Reset the center position of the label
                    self.greenLabel.center = originalCenter
                    
                    // Call the same function to run the animation again
                    self.leftToRight()
                }
            })
        })
    }

    func doShowFinishEvent() {
        if bannerData?.finishEvent == FinishEvent.vibrate.rawValue {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)

        } else if bannerData?.finishEvent == FinishEvent.flash.rawValue {
            flashlight()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.flashlight()
            })
        }
    }
    
    func flashlight() {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else{
            return
        }
        if (device.hasTorch) {
            do {
                try device.lockForConfiguration()
                if (device.torchMode == .on) {
                    device.torchMode = .off
                } else {
                    device.torchMode = .on
                    
                }
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
        else{
            print("Torch is not available")
        }
    }

    func setupAutoLayout() {
                
        greenLabel.leftAnchor.constraint(equalTo: mainView.rightAnchor).isActive = true
        greenLabel.centerYAnchor.constraint(equalTo: mainView.centerYAnchor).isActive = true
        greenLabel.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
    }
        
    @IBAction func back(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnUnlock(sender: UIButton) {
        isLock = !isLock
        
        btnUnlock.setImage(UIImage(named: isLock ? "lock" : "unlock"), for: .normal)
        
        if !isLock {
            btnBack.isHidden = false
        } else {
            btnBack.isHidden = true
        }
    }
    
    @IBAction func btnPlayPause(sender: UIButton) {
        // handling code
        let layer = greenLabel.layer
        pause = !pause
        if pause {
            btnPlayPause.setImage(UIImage(named: "play"), for: .normal)
            pauseLayer(layer: layer)
        } else {
            btnPlayPause.setImage(UIImage(named: "pause"), for: .normal)
            resumeLayer(layer: layer)
        }
    }
    
    func pauseLayer(layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }
    
    func resumeLayer(layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
    
    

}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
extension ViewController {
    func createGif(screenshots: [UIImage], frameDelay: Double, loopCount: Int) -> URL? {
        let fileProperties = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFLoopCount: loopCount
            ]
        ] as CFDictionary
        
        let frameProperties = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFDelayTime: frameDelay
            ]
        ] as CFDictionary
        
        let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let path = documentsDirectoryPath.appending("/animated.gif")
        
        let url = URL(fileURLWithPath: path)
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.gif.identifier as CFString, screenshots.count, nil) else { return nil }
        CGImageDestinationSetProperties(destination, fileProperties)
        
        for i in 0..<screenshots.count {
            guard let image = screenshots[i].cgImage else { continue }
            CGImageDestinationAddImage(destination, image, frameProperties)
        }
        
        if !CGImageDestinationFinalize(destination) {
            print("Failed to finalize image destination")
            return nil
        }
        
        return url
    }
    
}
extension UIView {
    func snapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

// MARK: -
// MARK: -  Recording Methods
extension ViewController: RPPreviewViewControllerDelegate {
    
    // MARK: RPPreviewViewControllerDelegate
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true, completion: {
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    
    func startRecording() {
        
        guard recorder.isAvailable else {
            print("Recording is not available at this time.")
            return
        }
        
        recorder.startRecording{ [unowned self] (error) in
            
            print("Started Recording Successfully")
            self.isRecording = true
            
            DispatchQueue.main.async {
                self.configure()
            }
            
            
            guard error == nil else {
                print("There was an error starting the recording.")
                self.isRecording = false
                navigationController?.popViewController(animated: true)
                return
            }
                        
        }
        
    }
    
    func stopRecording() {
        
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("LED-BANNER-APP-\(Int(Date().timeIntervalSince1970)).mp4")

        self.recorder.stopRecording(withOutput: outputURL) { error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                print("Success")
                if self.bannerData?.saveMovie ?? false || self.bannerData?.sendMovie ?? false {
                    self.delegate?.didFinishGenerateMovie(url: outputURL)
                    
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }

        
    }
    
    func saveVideo(url: URL) {
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { saved, error in
            if saved {
                //.. Do Operation if you want
                DispatchQueue.main.async {
                    self.isRecording = false
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                print(error?.localizedDescription ?? "")
            }
        }
        
    }
}
