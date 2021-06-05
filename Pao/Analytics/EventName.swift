//
//  EventName.swift
//  Pao
//
//  Created by Waseem Ahmed on 29/01/2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

import Foundation

enum EventName: String {
    //Group: on boarding
    case chooseRegister = "choose to register"
    case enterUserName = "enter name and username"
    case successfulLogin = "successful login"
    case completeTutorial = "complete tutorial"
    
    //Group: view spot
    case discover = "discover"
    case yourPeople = "your people"
    case theWorld = "the world"
    case playList = "play list"
    case playListSwipe = "play list swipe"
    case saveFromPlayList = "save from play list"
    case yourPeopleSwipe = "your people swipe"
    case theWorldSwipe = "the world swipe"
    case scroll = "scroll"
    case swipeCount = "swipe count"
    case feedClickProfile = "feed click profile"
    case hiddenGems = "hidden gems"
    case hiddenGemSwipe = "hidden gem swipe"
    
    // The World playlists
        
    case unique = "unique"                              // user clicks the Unique Play list button within the world feed
    case outdoors = "outdoors"                          // user clicks the Outdoors Play list button within the world feed
    case treatYourself = "treat_yourself"               // user clicks the Treat Yourself Play list button within the world feed
    case artCulture = "art_culture"                     // user clicks the Art/culture Play list button within the world feed
    case eat = "eat"                                    // user clicks the Eat Play list button within the world feed
    case idk = "IDK"                                    // user clicks the IDK Play list button within the world feed
    case uniqueSwipe = "unique swipe"                   // user swipes left or right within the unique play list
    case outdoorsSwipe = "outdoors swipe"               // user swipes left or right within the outdoors play list
    case treatYourselfSwipe = "treat_yourself swipe"    // user swipes left or right within the treat yourself play list
    case artCultureSwipe = "art_culture swipe"          // user swipes left or right within the art_culture play list
    case eatSwipe = "eat swipe"                         // user swipes left or right within the eat play list
    case idkSwipe = "IDK swipe"                         // user swipes left or right within the IDK play list
    
    //Group: Spot
    case tip = "tip"
    case go = "go"
    case save = "save"
    case saveOnGoPage = "save from go page"
    case enterComment = "enter comment"
    case tagComment = "tag in comment"
    case directions = "directions"
    case website = "website"
    case phone = "phone"
    case goPhotoTab = "go page photos tab"
    case goClickSpot = "go page spot"
    case editPostFromFeed = "edit post from feed"
    case deletePostFromFeed = "delete post from feed"
    case editPostFromProfile = "edit post profile"
    case deletePostFromProfile = "delete post profile"
    case sharePost = "share post"
    case completeShare = "complete share"
    case spotInappropriate = "spot inappropriate"
    case spotSpam = "spot spam"
    case commentInappropriate = "comment inappropriate"
    case commentSpam = "comment spam"
    case deleteComment = "delete comment"
    case blockUser = "block user"
    case heartEmoji = "heart emoji"
    case clapEmoji = "clap emoji"
    case droolEmoji = "drool emoji"
    case verifySpot = "verify a spot"
    case gemEmoji = "gem emoji"
    case pressEmoji = "press emoji"
    case emojiFromHiddenGems = "emoji from hidden gems"
    case emojiFromPlayList = "emoji from play list"
    case emojiFromSearch = "emoji from search"
    case emoji = "emoji"
        
    //Group: add people
    case friendSearchText = "add friend from search bar text"
    case friendTopUser = "add friend from top user list"
    case friendFromProfile = "add friend from their profile"
    
    //Group: search
    case searchIcon = "search icon"
    case clickSearchBar = "click search bar"
    case searchPeopleTab = "search people tab"
    case clickPeopleBubble = "search people bubble"
    case searchBarPeople = "search bar people"
    case searchPeopleSelectSpecific = "search bar specific people select"
    case searchPeopleSelectTopUser = "search bar people click user"
    case searchLocationTab = "search locations tab"
    case clickLocationBubble = "search location bubble"
    case searchLocRecent = "city search view of recent spots"
    case searchLocTopSpots = "city search view of top spots"
    case searchBarLocation = "search bar location"
    case searchLocationSelectSpecific = "search bar specific location  select"
    case searchLocationSelectCurrent = "search bar current location"
    case searchLocationSelectTopCity = "search bar select top city"
    case searchLocTopSpotTab = "search loc view top spots tab"
    case searchLocRecentTab = "search loc view recent tab"
    case selectSpotFromCitySearchResult = "select spot from city search result"
    case filter = "filter"
    case searhLocMapView = "map view"
    case searchLocScrollView = "scroll view"
    case mapZoom = "map zoom"
    case mapMove = "map move"
    case mapClickSpot = "map click spot"
    case mapCarouselSpot = "map carousel spot"
    case searchSpotTab = "search spots tab"
    case clickSpotBubble = "search spots bubble"
    case swipeTopSpotsFeed = "swipe top spots feed"
    case searchBarSpots = "search bar spots"
    case searchSpotSelectTopSpot = "search bar select top pao spot"
    case searchSpotSlectSpecific = "search bar specific spot select"
    
    //Group: upload
    case uploadTab = "upload tab"
    case selectPhotos = "select photos"
    case uploadLocation = "upload location"
    case enterTip = "enter tip"
    case uploadCat = "upload cat"
    case completeUploadSpot = "complete upload spot"
    
    //Group: upload events
    case accessDeniedToPhoto = "access denied to photo"
    case tooLargeVideo = "too large video"
    case tooGeneralLocation = "too general location"
    case postIsTooLarge = "post is too large"
    case couldNotGetVideo = "could not get video"
    case couldNotGetMimeType = "could not get mime type"
    case couldNotGetImage = "could not get image"
    case checkInternetConnection = "check internet connection"
    case uploadSuccess = "upload success"
    
    //Group: notification
    case acceptNotifPermission = "accept push notifications"
    case declineNotifPermission = "decline push notifications"
    case allowNotifPermission = "allow push notifications"
    case dontAllowNotifPermission = "don't allow push notifications"
    case notifications = "notifications"
    case yourLocations = "your locations"
    case notifyToProfile = "notify to profile"
    case notifyToSpot = "notify to spot"
    case bizNotificationToSpot = "biz notification to spot"
    
    //Group: my profile
    case myProfile = "my profile"
    case clickEditProfile = "edit profile button"
    case editProfileItems = "edit profile items"
    case profileAboutTab = "profile about tab"
    case profileSearchUploads = "search uploads"
    case starSpot = "star spots"
    case profileUploadsTab = "my profile uploads tab"
    case selectUploadBoard = "select my uploads board"
    case selectUploadBoardSpot = "select a spot in my uploads"
    case profileSavesTab = "my profile saves tab"
    case profileSearchSaves = "search my saves"
    case selectSavedBoard = "select my saves board"
    case selectSavedBoardSpot  = "select a spot in my saves"
    //case = "select about tab"
    case myFriends = "how many friends"
    case myCities = "how many cities"
    case myCountries = "how many countries"
    
    //Group: other profile
    case viewOtherFromFeed = "view other from feed"
    case viewOtherFromTopUsers = "view other from user list"
    case viewOtherFromSearch = "view other from people search"
    case viewOtherFromLocSearch = "view other from locations search"
    case viewOtherFromSpotSearch = "view other from spots search"
    case othersAboutTab = "view others about"
    
    case othersUploadsTab = "view other's upload tab"
    case othersSavesTab = "view other's saves tab"
    
    case othersUploadBoard = "view other's upload boards"
    case othersSavedBoard = "view other's saves boards"
    case othersUploadBoardSpot = "view other's uploaded spots"
    case othersSavedBoardSpot = "view other's saved spots"
    case othersSearchUploads = "search others uploads"
    case othersSearchSaves = "search others saves"
    case enlargeOthersProfilePicture = "click to expand profile picture"
    
    //Group: settings
    case clickSettings = "settings"
    case deleteAccount = "delete account"
    case settingsPrivate = "private"
    case dataDownload = "data download"
    case toggleNotification = "toggle notifications"
    case settingsAboutApp = "about app"
    case contactEmail = "contact email"
    case settingsEmojis = "emojis"
    
    //Group: external notification
    case plain = "plain"
    case saved = "saved"
    case checklist = "checklist"
    case comment = "comment"
    case follow = "follow"
    case followRequest = "follow request"
    case verify = "verify"
    case spotComment = "spot comment"
    case acceptRequest = "accept request"
    case custom = "custom"
    case reactHeartEyes = "react heart eyes"
    case reactGem = "react gem"
    case reactDroolingFace = "react drooling face"
    case reactClap = "react clap"
    case reactRoundPushpin = "react round pushpin"
    case location = "location"
}
