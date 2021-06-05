//
//  EventAction.swift
//  Pao
//
//  Created by Exelia Technologies on 20/07/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation

public enum EventAction: String {
    case buttonPress = "button_press";
    case pickFilterValue = "pick_filter_value";
    
    case tapYourPeople = "your_people"
    case tapDiscover = "discover"
    case tapSearch = "search"
    case tapUpload = "upload"
    case tapNotifications = "notifications"
    case tapMyProfile = "own_profile"
    
    
    case tabTheWorld = "the_world"
    
    case spotSwipe = "swipe"
    case spotScrollImages = "scroll_images"
    //    case theWorldSwipe = "the_world_swipe"
    //    case theWorldScrollImages = "the_world_scroll_images"
    //    case yourPeopleSwipe = "your_people_swipe";
    //    case yourPeopleScrollImages = "your_people_scroll_images";
    
    case tapTip = "tip"
    case feedClickProfile = "feed_click_profile"
    case clickProfileIcon = "click_profile"
    
    case clickGo = "go"
    case bizNotifyGo = "biz_notify_go"
    case clickSaveIcon = "save"
    case clickUnSaveIcon = "unsave"
    case clickCommentIcon = "comment"
    case editPostFeed = "edit_post_feed"
    case deletePostFeed = "delete_post_feed"
    case editPost = "edit_post"
    case deletePost = "delete_post"
    case sharePost = "share_post"
    case blockUser = "block_user" //
    case spotInappropriate = "spot_inappropriate" //
    case spotSpam = "spot_spam" //
    case deleteComment = "delete_comment" //
    case commentInappropriate = "comment_inappropriate" //
    case commentSpam = "comment_spam" //
    case tabSearchPeople = "search_people"
    case tabSearchLocations = "search_locations"
    case tabSearchSpots = "search_spots"
    case searchBubblePeople = "search_people_bubble"
    case searchBubbleLocation = "search_location_bubble"
    case searchBubbleSpot = "search_spots_bubble"
    case searchBarPeople  = "search_bar_people"
    case searchBarLocation  = "search_bar_location"
    case searchBarSpot  = "search_bar_spot"
    
    case hiddenGems = "hidden_gems"
        
    case addUser = "add_user"
    case addTopPaoUser = "add_top_pao_user"
    case searchCurrentLocation = "search_current_loc"
    case searchTopCity = "search_top_city"
    case searchTopSpot = "search_top_spot"
    case searchTopUser = "search_top_user"
    
    case topSpotsTab = "top_spots_tab"
    case yourPeopleSearchTab = "your_people_search_tab"
    
    case listViewSearch = "list_view_search"
    case mapViewSearch = "map_view_search"
    case scrollViewSearch = "scroll_view_search"
    
    case filter = "filter"
    case eatFilter = "eat_filter"
    case stayFilter = "stay_filter"
    case playFilter = "play_filter"
    
    case selectPhotos = "select_photos"
    case selectLocation = "upload_location"
    case enterTip = "enter_tip"
    case selectCategory = "upload_cat"
    case spotPreview = "spot_preview"
    case uploadNow = "final_upload_spot"
    case editTip = "edit_tip"
    case editCategory = "edit_category"
    case mapZoom = "map_zoom"
    case mapClickSpot = "map_click_spot"
    case mapOpenSpot = "map_open_spot"
    
    case notifyToSpot = "notify_to_spot"
    case bizNotificationToSpot = "biz_notification_to_spot"
    case notifyToProfile = "notify_to_profile"
    
    case goDirections = "directions"
    case goWebsite = "website"
    case goPhone = "phone"
    
    case goPagePhotos = "go_page_photos"
    case goPageInfo = "go_page_info" //This is still yet to approve
    case goPageViewSpot = "go_page_spot";
    
    case editProfile = "edit_profile"
    case editCoverPhoto = "edit_cover_photo"
    case editProfilePhoto = "edit_profile_photo"
    case editHomeTown = "edit_hometown"
    case editCurrently = "edit_currently"
    case editNextStop = "edit_next_stop"
    case profileTags = "profile_tags"
    case editBio = "edit_bio"
    case howManyCities = "how_many_cities"
    case howManyCountries = "how_many_countries"
    case howManyFriends = "how_many_friends"
    case tapAboutTab = "select_about_tab"
    case tapSavesBoardTab = "saves_tab"
    case tapUploadsBoardTab = "uploads_tab"
    
    case selectUploadsBoard = "profile_uploads_board"
    case selectSavesBoard = "profile_saves_board"
    case selectUploadsBoardSpot = "select_uploads_spot"
    case selectSavesBoardSpot = "select_saves_spot"
    case searchSaves = "search_saves"
    case searchUploads = "search_uploads"
    case starSpot = "star_spot"
    case clickSettings = "settings"
    case deleteAccount = "delete_account"
    case makePrivate  = "private"
    case dataDownload  = "data_download"
    case toggleNitifications  = "toggle_notifications"
    case abountApp = "abount_app"
    case contactEmail = "contact_email"
    case emojiSetting = "emoji_setting"
    
    case heartEmoji = "heart_emoji"
    case clapEmoji = "clap_emoji"
    case droolEmoji = "drool_emoji"
    case verifySpot = "verify"
    case gemEmoji = "gem_emoji"
    case pressEmoji = "press_emoji"
    case deselectHeartEmoji = "deselect_heart_emoji"
    case deselectClapEmoji = "deselect_clap_emoji"
    case deselectDroolEmoji = "deselect_drool_emoji"
    case unverifySpot = "unverify"
    case deselectGemEmoji = "deselect_gem_emoji"
}
