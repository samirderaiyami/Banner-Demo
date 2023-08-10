//
//  BannerData.swift
//  LEDDemo
//
//  Created by Mac-0006 on 01/08/23.
//

import Foundation
import UIKit

enum FinishEvent: String {
    case none = "none"
    case vibrate = "vibrate"
    case flash = "flash"
}

class BannerData: Codable {
    
    var id: Int = 0
    var text = "SAMIR"
    var bannerBackgroundColor: String = "ffffff"
    var bannerBackgroundBrightness = 0.5
    
    var bannerTextFont = Fonts.SFProRoundedRegular
    var bannerTextFontSize: Int = 100
    
    var bannerTextColor: String = "000000"
    var bannerTextBrightness = 0.5
    
    var glwoing = false
    var blinking = true
    var mirroring = false
    var blinkingSpeed = 1.0
    var blinkingDensity = 0.0
    
    var isBold = false
    var isItalic = false
    var isLeftToRight = false
    var isRightToLeft = true
    
    var scrollingSpeed: Float = 10.0
    
    var lockingOption = false
    var stopOption = false

    var saveGif = false
    var sendGif = false
    
    var saveMovie = false
    var sendMovie = false

    var finishEvent: String = FinishEvent.none.rawValue
    
    var timestamp: Int64 = 0
    
    public static func saveUserEditedVideos(VideoModel: BannerData){
        var videosArray:[BannerData] = []
        videosArray.append(contentsOf: getUserEditedVideos())
        videosArray.insert(VideoModel, at: 0)
        let videosData = try! JSONEncoder().encode(videosArray)
        UserDefaults.standard.set(videosData, forKey: CUserDefaultsKey.UserSavedBanners)
    }
    
    public static func saveGetUsersEditedVideos(videoArray: [BannerData]){
        let videosData = try! JSONEncoder().encode(videoArray)
        UserDefaults.standard.set(videosData, forKey: CUserDefaultsKey.UserSavedBanners)
    }
    
    public static func getUserEditedVideos() -> [BannerData] {
        let placeData = UserDefaults.standard.data(forKey:CUserDefaultsKey.UserSavedBanners)
        
        if let placeData = UserDefaults.standard.data(forKey:CUserDefaultsKey.UserSavedBanners) {
            let placeArray = try! JSONDecoder().decode([BannerData].self, from: placeData)
            return placeArray
        }
        return []
    }
    
    public static func updateUserEditedVideos(VideoModel: BannerData){
        var userVideos = getUserEditedVideos()
        if let index = userVideos.firstIndex(where: {$0.id == VideoModel.id}) {
            userVideos[index] = VideoModel
        }
        let videosData = try! JSONEncoder().encode(userVideos)
        UserDefaults.standard.set(videosData, forKey: CUserDefaultsKey.UserSavedBanners)
    }
}

///... UserDefaults Constants.
struct CUserDefaultsKey {
    static let UserSavedBanners = "UserSavedBanners"
}
