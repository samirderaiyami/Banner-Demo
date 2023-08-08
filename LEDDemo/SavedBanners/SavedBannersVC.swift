//
//  SavedBannersVC.swift
//  LEDDemo
//
//  Created by Mac-0006 on 08/08/23.
//

import UIKit

protocol SavedBannersVCDelegate {
    func selectedBanner(bannerData: BannerData)
}

class SavedBannersVC: UIViewController {
    
    @IBOutlet weak var tblBanners: UITableView!
    
    var delegate: SavedBannersVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func btnBack(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func convertTimeStampToString(_ timeStamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeStamp / 1000) // Convert milliseconds to seconds
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy h:mm a"
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: date)
    }
}

extension SavedBannersVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BannerData.getUserEditedVideos().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BannerTblCell") as! BannerTblCell
        let obj = BannerData.getUserEditedVideos()[indexPath.row]
        cell.lblMessage.text = obj.text
        
        let timeStamp: TimeInterval = TimeInterval(obj.timestamp) // Replace this with your timestamp value
        cell.lblDate.text = convertTimeStampToString(timeStamp)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectedBanner(bannerData: BannerData.getUserEditedVideos()[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
}
extension Date {
    
    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        
        // 1) Get the current TimeZone's seconds from GMT. Since I am in Chicago this will be: 60*60*5 (18000)
        let timezoneOffset = TimeZone.current.secondsFromGMT()
        
        // 2) Get the current date (GMT) in seconds since 1970. Epoch datetime.
        let epochDate = self.timeIntervalSince1970
        
        // 3) Perform a calculation with timezoneOffset + epochDate to get the total seconds for the
        //    local date since 1970.
        //    This may look a bit strange, but since timezoneOffset is given as -18000.0, adding epochDate and timezoneOffset
        //    calculates correctly.
        let timezoneEpochOffset = (epochDate + Double(timezoneOffset))
        
        
        // 4) Finally, create a date using the seconds offset since 1970 for the local date.
        return Date(timeIntervalSince1970: timezoneEpochOffset)
    }
    
}
