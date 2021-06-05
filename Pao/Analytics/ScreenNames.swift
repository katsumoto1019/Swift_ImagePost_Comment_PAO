//
//  ScreenNames.swift
//  Pao
//
//  Created by kant on 12.05.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

import Foundation

enum ScreenNames: String {
    
    // MARK - Main screen
    
    case theWorld = "The World"
    case yourPeople = "Your People"
    
    // MARK: - Playlists
    
    case unique = "Unique"                  // user clicks the Unique Play list button within the world feed
    case outdoors = "Outdoors"              // user clicks the Outdoors Play list button within the world feed
    case treatYourself = "Treat_Yourself"  // user clicks the Treat Yourself Play list button within the world feed
    case artCulture = "Art_Culture"        // user clicks the Art/culture Play list button within the world feed
    case eat = "Eat"                        // user clicks the Eat Play list button within the world feed
    case idk = "IDK"                        // user clicks the IDK Play list button within the world feed
    
    
    // MARK: - Profile
    
    // Image
    
    case editCoverPhoto = "Edit Cover Photo"
    case editProfilePhoto = "Edit Profile Photo"
    
    // Counter
    
    case visitedCities = "Visited Cities"
    case visitedCountries = "Visited Countries"
    case followedPeople = "Followed People"
    
    // Edit
    
    case locationEditProfile = "Location EditProfile"
    
    // MARK: - About Me TableViewController
    
    case locationAboutMe = "Location About Me"
    case myProfileAbout = "My Profile About"
    case othersProfileAbout = "Other's Profile About"
    
    // MARK: - Notifications
    
    case notifications = "Notifications"
    
    // MARK: - Email contact service
    
    case contact = "Contact"
    
    // MARK: - Location
    
    case locationUpload = "Location Upload"
}
