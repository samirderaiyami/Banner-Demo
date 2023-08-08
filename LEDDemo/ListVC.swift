//
//  ListVC.swift
//  LEDDemo
//
//  Created by Mac-0006 on 28/07/23.
//

import UIKit
import ImageIO
import MobileCoreServices
import Photos
import MessageUI

enum ColorFrom {
    case bannerText
    case bannerBackground
}

class ListVC: UIViewController {

    var bannerData: BannerData? = nil
    
    var colorFrom: ColorFrom = .bannerBackground
    
    
    @IBOutlet weak var btnBannerBackgroundColor: UIButton!
    @IBOutlet weak var btnBannerTextColor: UIButton!
    
    @IBOutlet weak var switchGlowing: UISwitch!
    @IBOutlet weak var switchBlinking: UISwitch!
    @IBOutlet weak var switchMirroring: UISwitch!

    @IBOutlet weak var txtBannerTextSize: UITextField!
    @IBOutlet weak var txtBannerName: UITextField!

    @IBOutlet weak var lblFontName: UILabel!


    @IBOutlet weak var btnBold: UIButton!
    @IBOutlet weak var btnItalic: UIButton!
    @IBOutlet weak var btnLeftToRight: UIButton!
    @IBOutlet weak var btnRightToLeft: UIButton!

    @IBOutlet weak var bannerColorView: RSColourSlider!
    @IBOutlet weak var bannerTextColorView: RSColourSlider!

    var neededColour = UIColor.blue
    
    @IBOutlet weak var switchStopOption: UISwitch!
    @IBOutlet weak var switchLockingOption: UISwitch!

    @IBOutlet weak var finishSegment: UISegmentedControl!
    
    @IBOutlet weak var blinkingSpeed: UISlider!
    @IBOutlet weak var blinkingDensity: UISlider!
    @IBOutlet weak var scrollingSpeed: UISlider!

    @IBOutlet weak var bannerBackgroundBrightness: UISlider!
    @IBOutlet weak var bannerTextBrightness: UISlider!

    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setDefaultData()

        switchGlowing.addTarget(self, action: #selector(self.switchGlowing(sender:)), for: UIControl.Event.valueChanged)
        switchBlinking.addTarget(self, action: #selector(self.switchBlinking(sender:)), for: UIControl.Event.valueChanged)
        switchMirroring.addTarget(self, action: #selector(self.switchMirroring(sender:)), for: UIControl.Event.valueChanged)

        switchGlowing.addTarget(self, action: #selector(self.switchGlowing(sender:)), for: UIControl.Event.valueChanged)
        switchGlowing.addTarget(self, action: #selector(self.switchGlowing(sender:)), for: UIControl.Event.valueChanged)
        
        switchStopOption.addTarget(self, action: #selector(self.switchStopOption(sender:)), for: UIControl.Event.valueChanged)
        switchLockingOption.addTarget(self, action: #selector(self.switchLockingOption(sender:)), for: UIControl.Event.valueChanged)

        
        bannerColorView.delegate = self
        bannerTextColorView.delegate = self

    }
    
    func setDefaultData() {
        bannerData = BannerData()
        
        bannerData?.glwoing = false
        bannerData?.blinking = false
        bannerData?.text = "SAMIR"
        
        //..Message
        txtBannerName.text = bannerData?.text
        txtBannerName.backgroundColor = .white
        txtBannerName.textColor = .black
        
        bannerData?.isBold = false
        bannerData?.isItalic = false
        btnBold.backgroundColor = .white
        btnItalic.backgroundColor = .white
        bannerData?.isRightToLeft = true
        bannerData?.isLeftToRight = false
        btnRightToLeft.backgroundColor = .white
        btnLeftToRight.backgroundColor = .white
        
        //..Banner Background Color
        
        //.. Banner Text Fonts
        lblFontName.text = Fonts.SFProRoundedRegular
        bannerData?.bannerTextFont = Fonts.SFProRoundedRegular
        bannerData?.bannerTextFontSize = 100
        txtBannerTextSize.text = "100"
        
        //.. Banner Text Color
        
        bannerColorView.colourChosen = .white
        bannerTextColorView.colourChosen = .white
        
        bannerBackgroundBrightness.value = Float(bannerData?.bannerBackgroundBrightness ?? 0.5)
        bannerTextBrightness.value = Float(bannerData?.bannerTextBrightness ?? 0.5)
        
        //.. Banner Type
        
        
        //.. Banner Effects
        
        bannerData?.glwoing = false
        switchGlowing.isOn = false

        bannerData?.blinking = false
        switchBlinking.isOn = false

        bannerData?.blinkingSpeed = 0.4
        blinkingSpeed.value = Float(bannerData?.blinkingSpeed ?? 0.4)
        bannerData?.blinkingDensity = 0.0
        blinkingDensity.value = 0.0

        //.. Banner Controls
        bannerData?.mirroring = false
        switchMirroring.isOn = false
        
        finishSegment.selectedSegmentIndex = 0
        bannerData?.finishEvent = FinishEvent.none.rawValue

        bannerData?.stopOption = false
        switchStopOption.isOn = false
        
        bannerData?.lockingOption = false
        switchLockingOption.isOn = false

        bannerData?.scrollingSpeed = 10.0
        scrollingSpeed.value = bannerData?.scrollingSpeed ?? 10.0

        blinkingSpeed.value = Float(bannerData?.blinkingSpeed ?? 1.0)
        blinkingDensity.value = Float(bannerData?.blinkingDensity ?? 0.0)

    }
    
    @objc func switchGlowing(sender: UISwitch) {
        let value = sender.isOn
        // Do something
        bannerData?.glwoing = value
    }
    
    @objc func switchBlinking(sender: UISwitch) {
        let value = sender.isOn
        // Do something
        bannerData?.blinking = value
    }
    
    @objc func switchMirroring(sender: UISwitch) {
        let value = sender.isOn
        // Do something
        bannerData?.mirroring = value
    }
    
    @objc func switchStopOption(sender: UISwitch) {
        bannerData?.stopOption = sender.isOn
    }

    @objc func switchLockingOption(sender: UISwitch) {
        bannerData?.lockingOption = sender.isOn
    }

    @IBAction func bannerBackgroundBrightness(_ sender: UISlider) {
        bannerColorView.brightness = CGFloat(sender.value)
        neededColour = bannerColorView.colourChosen
        getCurrentValues()
        bannerColorView.backgroundColor = neededColour
        txtBannerName.backgroundColor = neededColour
        bannerData?.bannerBackgroundColor = neededColour.hexStringFromColor()
    }
    
    @IBAction func bannerTextBrightness(_ sender: UISlider) {
        bannerTextColorView.brightness = CGFloat(sender.value)
        neededColour = bannerTextColorView.colourChosen
        getCurrentValues()
        bannerTextColorView.backgroundColor = neededColour
        txtBannerName.textColor = neededColour
        bannerData?.bannerTextColor = bannerTextColorView.colourChosen.hexStringFromColor()
    }
    
    @IBAction func bannerTextBlinkingSlider(_ sender: UISlider) {
        
        let value = 10.0 / Double(sender.value)  /// 1000
        let finalVal = value.rounded(toPlaces: 2)
        print(finalVal)
        bannerData?.blinkingSpeed = value
    }
    
    @IBAction func bannerTextBlinkingDensity(_ sender: UISlider) {
        print(Double(sender.value))
        bannerData?.blinkingDensity = Double(sender.value)
    }

    @IBAction func scrollingSpeed(_ sender: UISlider) {
        print(sender.value)
        bannerData?.scrollingSpeed = sender.value
    }

    @IBAction func btnPlay(sender: UIButton) {
        
        bannerData?.bannerTextFontSize = Int(self.txtBannerTextSize.text ?? "100") ?? 100
        bannerData?.text = txtBannerName.text ?? "SAMIR"

        
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewController") as? ViewController
        vc?.bannerData = self.bannerData
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func btnBannerBackgroundColor(sender: UIButton) {
        colorFrom = .bannerBackground
        presentPicker()
    }
    
    @IBAction func btnBannerTextColor(sender: UIButton) {
        colorFrom = .bannerText
        presentPicker()
    }
    
    
    
    @IBAction func finishSegmentValueChange(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        if sender.selectedSegmentIndex == 0 {
            bannerData?.finishEvent = FinishEvent.none.rawValue
        } else if sender.selectedSegmentIndex == 1 {
            bannerData?.finishEvent = FinishEvent.vibrate.rawValue
        } else {
            bannerData?.finishEvent = FinishEvent.flash.rawValue
        }
        
    }
    
    func presentPicker() {
        // Initializing Color Picker
        let picker = UIColorPickerViewController()
        
        // Setting the Initial Color of the Picker
        picker.selectedColor = self.view.backgroundColor!
        
        // Setting Delegate
        picker.delegate = self
        
        // Presenting the Color Picker
        self.present(picker, animated: true, completion: nil)

    }
    
    @IBAction func selectFontFamily(sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: "Please Select an font", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: Fonts.LEDCounter7, style: .default , handler:{ (UIAlertAction)in
            self.bannerData?.bannerTextFont = Fonts.LEDCounter7
            self.lblFontName.text = Fonts.LEDCounter7
        }))
        
        alert.addAction(UIAlertAction(title: Fonts.SFProRoundedRegular, style: .default , handler:{ (UIAlertAction)in
            self.bannerData?.bannerTextFont = Fonts.SFProRoundedRegular
            self.lblFontName.text = Fonts.SFProRoundedRegular

        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }

    @IBAction func topButtonsClick(_ sender: UISlider) {
        if sender.tag == 1 {
            bannerData?.isBold.toggle()
            bannerData?.isItalic = false
            
            btnBold.backgroundColor = .lightGray
            btnItalic.backgroundColor = .white
            
            
        } else if sender.tag == 2 {
            bannerData?.isItalic.toggle()
            bannerData?.isBold = false
            
            btnBold.backgroundColor = .white
            btnItalic.backgroundColor = .lightGray

        } else if sender.tag == 3 {
            bannerData?.isRightToLeft = false
            bannerData?.isLeftToRight = true
            btnRightToLeft.backgroundColor = .white
            btnLeftToRight.backgroundColor = .lightGray

        } else {
            bannerData?.isRightToLeft = true
            bannerData?.isLeftToRight = false
            btnRightToLeft.backgroundColor = .lightGray
            btnLeftToRight.backgroundColor = .white

        }
    }
   
    @IBAction func btnShare(sender: AnyObject) {
        let alert = UIAlertController(title: nil, message:
                                        """
            What do you want to do with this "LED Banner Pro" presentation?
            """, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Reset To Default", style: .destructive , handler:{ (UIAlertAction)in
            print("Reset To Default")
            self.setDefaultData()
        }))
        
        alert.addAction(UIAlertAction(title: "Save as Template", style: .default , handler:{ (UIAlertAction)in
            print("Save as Template")
            
            self.bannerData?.bannerTextFontSize = Int(self.txtBannerTextSize.text ?? "100") ?? 100
            self.bannerData?.text = self.txtBannerName.text ?? "SAMIR"
            self.bannerData?.saveGif = true
            self.bannerData?.timestamp = Date().currentTimeMillis()

            if let banner = self.bannerData {
                BannerData.saveUserEditedVideos(VideoModel: banner)
                self.presentAlertViewWithOneButton(alertTitle: nil, alertMessage: "Template saved!", btnOneTitle: "Okay", btnOneTapped: nil)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Send as Template", style: .default , handler:{ (UIAlertAction)in
            print("Send as Template")
            self.sendBanner()
        }))
        
        alert.addAction(UIAlertAction(title: "Save as animated GIF", style: .default , handler:{ (UIAlertAction)in
            print("Save as animated GIF")
            
            self.bannerData?.bannerTextFontSize = Int(self.txtBannerTextSize.text ?? "100") ?? 100
            self.bannerData?.text = self.txtBannerName.text ?? "SAMIR"
            self.bannerData?.saveGif = true
            
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewController") as? ViewController
            vc?.bannerData = self.bannerData
            vc?.delegate = self
            self.navigationController?.pushViewController(vc!, animated: true)

        }))
        
        alert.addAction(UIAlertAction(title: "Send as animated GIF", style: .default , handler:{ (UIAlertAction)in
            print("Send as animated GIF")
            
            self.bannerData?.bannerTextFontSize = Int(self.txtBannerTextSize.text ?? "100") ?? 100
            self.bannerData?.text = self.txtBannerName.text ?? "SAMIR"
            self.bannerData?.sendGif = true

            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewController") as? ViewController
            vc?.bannerData = self.bannerData
            vc?.delegate = self
            self.navigationController?.pushViewController(vc!, animated: true)

        }))
        
        alert.addAction(UIAlertAction(title: "Save as Movie", style: .default , handler:{ (UIAlertAction)in
            print("Save as Movie")
            
            self.bannerData?.bannerTextFontSize = Int(self.txtBannerTextSize.text ?? "100") ?? 100
            self.bannerData?.text = self.txtBannerName.text ?? "SAMIR"
            self.bannerData?.saveMovie = true
            
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewController") as? ViewController
            vc?.bannerData = self.bannerData
            vc?.delegate = self
            self.navigationController?.pushViewController(vc!, animated: true)

        }))
        
        alert.addAction(UIAlertAction(title: "Send as Movie", style: .default , handler:{ (UIAlertAction)in
            self.bannerData?.bannerTextFontSize = Int(self.txtBannerTextSize.text ?? "100") ?? 100
            self.bannerData?.text = self.txtBannerName.text ?? "SAMIR"
            self.bannerData?.sendMovie = true
            
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewController") as? ViewController
            vc?.bannerData = self.bannerData
            vc?.delegate = self
            self.navigationController?.pushViewController(vc!, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        
        //uncomment for iPad Support
        //alert.popoverPresentationController?.sourceView = self.view
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    @IBAction func btnMenu(sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SavedBannersVC") as? SavedBannersVC
        vc?.delegate = self
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    private func sendBanner() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("""
            LED Banner Pro" Message
            """)
            
            let messageBody = """
            Hey, check this "LED Banner Pro" message!\n\n
            """
            
            mail.setMessageBody(messageBody, isHTML: false)
            present(mail, animated: true)
        } else {
            self.presentAlertViewWithOneButton(alertTitle: "", alertMessage: "Device not found.", btnOneTitle: "Okay", btnOneTapped: nil)
        }
    }
}

extension ListVC: UIColorPickerViewControllerDelegate {
    
    //  Called once you have finished picking the color.
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        
        if colorFrom == .bannerBackground {
            bannerData?.bannerBackgroundColor = viewController.selectedColor.hexStringFromColor()
            btnBannerBackgroundColor.backgroundColor = UIColor.hexStringToUIColor(hex: bannerData?.bannerBackgroundColor ?? "")
            
        } else {
            bannerData?.bannerTextColor = viewController.selectedColor.hexStringFromColor()
            btnBannerTextColor.backgroundColor = UIColor.hexStringToUIColor(hex: bannerData?.bannerTextColor ?? "")
        }
        
    }
    
    //  Called on every color selection done in the picker.
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        if colorFrom == .bannerBackground {
            bannerData?.bannerBackgroundColor = viewController.selectedColor.hexStringFromColor()
            btnBannerBackgroundColor.backgroundColor = UIColor.hexStringToUIColor(hex: bannerData?.bannerBackgroundColor ?? "")
            
        } else {
            bannerData?.bannerTextColor = viewController.selectedColor.hexStringFromColor()
            btnBannerTextColor.backgroundColor = UIColor.hexStringToUIColor(hex: bannerData?.bannerTextColor ?? "")
        }
    }
}

extension ListVC: RSColourSliderDelegate {
    ///Optional delegate method that returns RGBA values when the slider changes them
    func colourValuesChanged(to red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
//        updateRGBALabel(r: red, g: green, b: blue, a: alpha)
    }
    
    ///Optional delegate method that returns HSBA values when the slider changes them
    func colourValuesChanged(to hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
//        updateHSBALabel(h: hue, s: saturation, b: brightness, a: alpha)
    }
    //MARK: - Getting current values from the colour slider
    
    func getCurrentValues(){
        ///Get slider values whenever you need
//        let valuesRGBA = colourSlider.getCurrentRGBAValues()
//        let valuesHSBA = colourSlider.getCurrentHSBAValues()
        
    }
    
    func colourGotten(colour: UIColor) {
        bannerData?.bannerBackgroundColor = bannerColorView.colourChosen.hexString ?? ""
        txtBannerName.backgroundColor = bannerColorView.colourChosen
        
        bannerData?.bannerTextColor = bannerTextColorView.colourChosen.hexString ?? ""
        txtBannerName.textColor = bannerTextColorView.colourChosen
    }
}

extension ListVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

extension ListVC: ViewControllerDelegate {
    func didFinishGenerateMovie(url: URL?) {
        print(url?.absoluteString ?? "")

        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            if self.bannerData?.saveMovie ?? false {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url!)
                }) { saved, error in
                    if saved {
                        DispatchQueue.main.async {
                            self.presentAlertViewWithOneButton(alertTitle: nil, alertMessage: "Video Saved in Photos!", btnOneTitle: "Okay", btnOneTapped: nil)
                        }
                    } else {
                        print(error?.localizedDescription ?? "")
                    }
                }
            } else {
                if let url = url {
                    let activityViewController = UIActivityViewController(
                        activityItems: [url],
                        applicationActivities: nil)
                    activityViewController.popoverPresentationController?.sourceView = self.view
                    activityViewController.popoverPresentationController?.sourceRect = self.view.frame
                    self.present(activityViewController, animated: true, completion: nil)
                }
            }
        })
        
    }
    
    func didFinishGenerateGif(url: URL?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            
            if self.bannerData?.saveGif ?? false {
                PHPhotoLibrary.shared().performChanges({
                    let request = PHAssetCreationRequest.forAsset()
                    if let url = url {
                        request.addResource(with: .photo, fileURL: url, options: nil)
                    }
                    
                }) { (success, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("GIF has saved")
                        DispatchQueue.main.async {
                            self.presentAlertViewWithOneButton(alertTitle: nil, alertMessage: "GIF Saved in Photos!", btnOneTitle: "Okay", btnOneTapped: nil)
                        }
                    }
                }
            } else {
                
                
                if let url = url {
                    let activityViewController = UIActivityViewController(
                        activityItems: [url],
                        applicationActivities: nil)
                    activityViewController.popoverPresentationController?.sourceView = self.view
                    activityViewController.popoverPresentationController?.sourceRect = self.view.frame
                    self.present(activityViewController, animated: true, completion: nil)
                }
            }
        })
    }
}
extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

extension ListVC: SavedBannersVCDelegate {
    func selectedBanner(bannerData: BannerData) {
        //.. Set the values from the banner.
        
        txtBannerName.text = bannerData.text
                
        //..Message
        txtBannerName.text = bannerData.text
        txtBannerName.backgroundColor = UIColor.hexStringToUIColor(hex: bannerData.bannerBackgroundColor)
        txtBannerName.textColor = UIColor.hexStringToUIColor(hex: bannerData.bannerTextColor)
        
        if bannerData.isBold {
            btnBold.backgroundColor = .lightGray
            btnItalic.backgroundColor = .white
        } else if bannerData.isItalic {
            btnItalic.backgroundColor = .lightGray
            btnBold.backgroundColor = .white
        } else {
            btnItalic.backgroundColor = .white
            btnBold.backgroundColor = .white
        }
        
        if bannerData.isLeftToRight {
            btnRightToLeft.backgroundColor = .white
            btnLeftToRight.backgroundColor = .lightGray
        } else {
            btnRightToLeft.backgroundColor = .lightGray
            btnLeftToRight.backgroundColor = .white
        }
        
        //..Banner Background Color
        
        //.. Banner Text Fonts
        lblFontName.text = bannerData.bannerTextFont
        txtBannerTextSize.text = "\(bannerData.bannerTextFontSize)"
        
        //.. Banner Text Color
        
        bannerColorView.colourChosen = UIColor.hexStringToUIColor(hex: bannerData.bannerBackgroundColor)
        bannerTextColorView.colourChosen = UIColor.hexStringToUIColor(hex: bannerData.bannerTextColor)
        
        bannerBackgroundBrightness.value = Float(bannerData.bannerBackgroundBrightness)
        bannerTextBrightness.value = Float(bannerData.bannerTextBrightness)
        
        //.. Banner Type
        
        
        //.. Banner Effects
        
        switchGlowing.isOn = bannerData.glwoing
        
        switchBlinking.isOn = bannerData.blinking
        
        blinkingSpeed.value = Float(bannerData.blinkingSpeed)
        blinkingDensity.value = Float(bannerData.blinkingDensity)
        
        //.. Banner Controls
        switchMirroring.isOn = bannerData.mirroring
        
        if bannerData.finishEvent == FinishEvent.none.rawValue {
            finishSegment.selectedSegmentIndex = 0
        } else if bannerData.finishEvent == FinishEvent.vibrate.rawValue {
            finishSegment.selectedSegmentIndex = 1
        } else {
            finishSegment.selectedSegmentIndex = 2
        }
        
        switchStopOption.isOn = bannerData.stopOption
        
        switchLockingOption.isOn = bannerData.lockingOption
        
        scrollingSpeed.value = bannerData.scrollingSpeed
        
        blinkingSpeed.value = Float(bannerData.blinkingSpeed)
        blinkingDensity.value = Float(bannerData.blinkingDensity)
        
    }
}
// MARK: -
// MARK: -  MFMailComposeViewControllerDelegate Method
extension ListVC: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
