// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {

  internal enum AboutMeBioTableViewCell {
    internal enum BioTextView {
      /// Here you can write any thing about yourself. Keep it simple or go all out!
      internal static let placeholder = L10n.tr("Localizable", "AboutMeBioTableViewCell.BioTextView.placeholder")
    }
  }

  internal enum AboutMeLocationTableViewCell {
    /// Currently
    internal static let currentlyTitleLabel = L10n.tr("Localizable", "AboutMeLocationTableViewCell.currentlyTitleLabel")
    /// Hometown
    internal static let hometownTitleLabel = L10n.tr("Localizable", "AboutMeLocationTableViewCell.hometownTitleLabel")
    /// Next stop
    internal static let nextStopTitleLabel = L10n.tr("Localizable", "AboutMeLocationTableViewCell.nextStopTitleLabel")
    internal enum LocationText {
      /// Add
      internal static let title = L10n.tr("Localizable", "AboutMeLocationTableViewCell.LocationText.title")
      /// (optional)
      internal static let value = L10n.tr("Localizable", "AboutMeLocationTableViewCell.LocationText.value")
    }
  }

  internal enum AboutMeStatsTableViewCell {
    /// Cities
    internal static let middleTitleLabel = L10n.tr("Localizable", "AboutMeStatsTableViewCell.middleTitleLabel")
    /// Countries
    internal static let trailingTitleLabel = L10n.tr("Localizable", "AboutMeStatsTableViewCell.trailingTitleLabel")
  }

  internal enum AboutMeTableViewController {
    /// Meet
    internal static let meetLabel = L10n.tr("Localizable", "AboutMeTableViewController.meetLabel")
    /// What they're into
    internal static let whatTheyreInto = L10n.tr("Localizable", "AboutMeTableViewController.whatTheyreInto")
    /// What you're into
    internal static let whatYoureInto = L10n.tr("Localizable", "AboutMeTableViewController.whatYoureInto")
    /// Where they're at
    internal static let whereTheyreAt = L10n.tr("Localizable", "AboutMeTableViewController.whereTheyreAt")
    /// Where you're at
    internal static let whereYoureAt = L10n.tr("Localizable", "AboutMeTableViewController.whereYoureAt")
  }

  internal enum AboutTableViewController {
    /// Privacy Policy
    internal static let labelPrivacyPolicy = L10n.tr("Localizable", "AboutTableViewController.labelPrivacyPolicy")
    /// Terms and Conditions
    internal static let labelTermsAndConditions = L10n.tr("Localizable", "AboutTableViewController.labelTermsAndConditions")
    /// Version
    internal static let labelVersion = L10n.tr("Localizable", "AboutTableViewController.labelVersion")
    /// About
    internal static let title = L10n.tr("Localizable", "AboutTableViewController.title")
  }

  internal enum AccountTableViewController {
    /// Oops! Something went wrong when deleting your account. Please try again.
    internal static let deleteAccountError = L10n.tr("Localizable", "AccountTableViewController.deleteAccountError")
    /// Are you sure you want to delete your account?
    internal static let deleteConfirmation = L10n.tr("Localizable", "AccountTableViewController.deleteConfirmation")
    /// Please enter your password
    internal static let labelEnterPassword = L10n.tr("Localizable", "AccountTableViewController.labelEnterPassword")
    /// Your password
    internal static let placeholder = L10n.tr("Localizable", "AccountTableViewController.placeholder")
    internal enum MessagePrompt {
      /// Incorrect password or something went wrong.
      internal static let message = L10n.tr("Localizable", "AccountTableViewController.MessagePrompt.message")
    }
  }

  internal enum AccountViewController {
    /// Join a community that experiences and shares\r\n\nthe coolest gems around the world.
    internal static let descriptionLabel = L10n.tr("Localizable", "AccountViewController.descriptionLabel")
    /// Join Now
    internal static let joinNowButton = L10n.tr("Localizable", "AccountViewController.joinNowButton")
    /// Log in
    internal static let logInButton = L10n.tr("Localizable", "AccountViewController.logInButton")
    /// Find your next favorite hidden gem.
    internal static let subTitleLabel = L10n.tr("Localizable", "AccountViewController.subTitleLabel")
  }

  internal enum AccountsTableViewCell {
    /// Delete Account
    internal static let actionDeleteAccount = L10n.tr("Localizable", "AccountsTableViewCell.actionDeleteAccount")
    /// Switch to Business profile
    internal static let actionSwitchToBusinessProfile = L10n.tr("Localizable", "AccountsTableViewCell.actionSwitchToBusinessProfile")
    /// View subscription options
    internal static let actionViewSubscriptionOptions = L10n.tr("Localizable", "AccountsTableViewCell.actionViewSubscriptionOptions")
    /// Account Info
    internal static let labelAccountInfo = L10n.tr("Localizable", "AccountsTableViewCell.labelAccountInfo")
    /// Created on
    internal static let labelCreatedOn = L10n.tr("Localizable", "AccountsTableViewCell.labelCreatedOn")
    /// Personal
    internal static let labelPersonal = L10n.tr("Localizable", "AccountsTableViewCell.labelPersonal")
    /// Premium
    internal static let labelPremium = L10n.tr("Localizable", "AccountsTableViewCell.labelPremium")
    /// Profile Type
    internal static let labelProfileType = L10n.tr("Localizable", "AccountsTableViewCell.labelProfileType")
    /// Subscription
    internal static let labelSubscription = L10n.tr("Localizable", "AccountsTableViewCell.labelSubscription")
  }

  internal enum BoardCoverPhotosViewController {
    /// Choose Cover Photo
    internal static let title = L10n.tr("Localizable", "BoardCoverPhotosViewController.title")
  }

  internal enum ChecklistItemTableViewCell {
    /// To do:
    internal static let todoLabel = L10n.tr("Localizable", "ChecklistItemTableViewCell.todoLabel")
  }

  internal enum CommentLocal {
    /// Couldn't post. Tap to retry
    internal static let failedMessage = L10n.tr("Localizable", "CommentLocal.failedMessage")
    /// Posting...
    internal static let postingMessage = L10n.tr("Localizable", "CommentLocal.postingMessage")
  }

  internal enum CommentsDataSource {
    /// Inappropriate comment
    internal static let inappropriateComment = L10n.tr("Localizable", "CommentsDataSource.inappropriateComment")
    /// Choose a reason for reporting this comment.
    internal static let message = L10n.tr("Localizable", "CommentsDataSource.message")
    /// Report
    internal static let reportActionTitle = L10n.tr("Localizable", "CommentsDataSource.reportActionTitle")
    /// Spam comment
    internal static let spamComment = L10n.tr("Localizable", "CommentsDataSource.spamComment")
    internal enum DeleteComment {
      /// Are you sure you want to delete this comment?
      internal static let message = L10n.tr("Localizable", "CommentsDataSource.DeleteComment.message")
    }
  }

  internal enum CommentsTableViewController {
    /// Comments
    internal static let title = L10n.tr("Localizable", "CommentsTableViewController.title")
  }

  internal enum Common {
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "Common.cancel")
    /// Delete
    internal static let delete = L10n.tr("Localizable", "Common.delete")
    /// Done
    internal static let done = L10n.tr("Localizable", "Common.done")
    /// Got it
    internal static let gotIt = L10n.tr("Localizable", "Common.gotIt")
    /// Join Pao
    internal static let joinPao = L10n.tr("Localizable", "Common.joinPao")
    /// Post
    internal static let labelPost = L10n.tr("Localizable", "Common.labelPost")
    /// Saves
    internal static let labelSaves = L10n.tr("Localizable", "Common.labelSaves")
    /// Uploads
    internal static let labelUploads = L10n.tr("Localizable", "Common.labelUploads")
    /// Let's do it!
    internal static let letsDoIt = L10n.tr("Localizable", "Common.letsDoIt")
    /// No
    internal static let no = L10n.tr("Localizable", "Common.no")
    /// Not Now
    internal static let notNow = L10n.tr("Localizable", "Common.notNow")
    /// Ok
    internal static let ok = L10n.tr("Localizable", "Common.ok")
    /// Search
    internal static let search = L10n.tr("Localizable", "Common.search")
    /// Cities
    internal static let titleCities = L10n.tr("Localizable", "Common.titleCities")
    /// Countries
    internal static let titleCountries = L10n.tr("Localizable", "Common.titleCountries")
    /// Gems
    internal static let titleGems = L10n.tr("Localizable", "Common.titleGems")
    /// Locations
    internal static let titleLocations = L10n.tr("Localizable", "Common.titleLocations")
    /// Notifications
    internal static let titleNotifications = L10n.tr("Localizable", "Common.titleNotifications")
    /// People
    internal static let titlePeople = L10n.tr("Localizable", "Common.titlePeople")
    /// Their People
    internal static let titleTheirPeople = L10n.tr("Localizable", "Common.titleTheirPeople")
    /// The World
    internal static let titleTheWorld = L10n.tr("Localizable", "Common.titleTheWorld")
    /// Top Spots
    internal static let titleTopSpots = L10n.tr("Localizable", "Common.titleTopSpots")
    /// Your Locations
    internal static let titleYourLocations = L10n.tr("Localizable", "Common.titleYourLocations")
    /// Your People
    internal static let titleYourPeople = L10n.tr("Localizable", "Common.titleYourPeople")
    /// Yes
    internal static let yes = L10n.tr("Localizable", "Common.yes")
    internal enum BackButton {
      /// Back
      internal static let text = L10n.tr("Localizable", "Common.BackButton.text")
    }
    internal enum Error {
      /// Oops!
      internal static let title = L10n.tr("Localizable", "Common.Error.title")
    }
    internal enum NextButton {
      /// Next
      internal static let text = L10n.tr("Localizable", "Common.NextButton.text")
    }
    internal enum SaveButton {
      /// Save
      internal static let text = L10n.tr("Localizable", "Common.SaveButton.text")
    }
  }

  internal enum CoverViewController {
    internal enum Alert {
      internal enum Error {
        /// Something went wrong, please try again later!
        internal static let text = L10n.tr("Localizable", "CoverViewController.Alert.Error.text")
      }
    }
  }

  internal enum Date {
    /// ago
    internal static let ago = L10n.tr("Localizable", "Date.ago")
    /// days
    internal static let days = L10n.tr("Localizable", "Date.days")
    /// d
    internal static let daysShort = L10n.tr("Localizable", "Date.daysShort")
    /// hours
    internal static let hours = L10n.tr("Localizable", "Date.hours")
    /// h
    internal static let hoursShort = L10n.tr("Localizable", "Date.hoursShort")
    /// mins
    internal static let mins = L10n.tr("Localizable", "Date.mins")
    /// m
    internal static let minsShort = L10n.tr("Localizable", "Date.minsShort")
    /// months
    internal static let months = L10n.tr("Localizable", "Date.months")
    /// mo
    internal static let monthsShort = L10n.tr("Localizable", "Date.monthsShort")
    /// secs
    internal static let secs = L10n.tr("Localizable", "Date.secs")
    /// s
    internal static let secsShort = L10n.tr("Localizable", "Date.secsShort")
    /// years
    internal static let years = L10n.tr("Localizable", "Date.years")
    /// y
    internal static let yearsShort = L10n.tr("Localizable", "Date.yearsShort")
  }

  internal enum DropDownView {
    internal enum Menu {
      internal enum CoverPhoto {
        /// Choose cover photo
        internal static let title = L10n.tr("Localizable", "DropDownView.Menu.CoverPhoto.title")
      }
    }
  }

  internal enum EditProfileAddTagsTableViewCell {
    /// Add some tags to tell your people\nwhat kinds of things you like to do
    internal static let instructionsLabel = L10n.tr("Localizable", "EditProfileAddTagsTableViewCell.instructionsLabel")
  }

  internal enum EditSpotDescriptionViewController {
    /// Edit Tip
    internal static let title = L10n.tr("Localizable", "EditSpotDescriptionViewController.title")
  }

  internal enum EditSpotLocationViewController {
    /// Edit Location
    internal static let title = L10n.tr("Localizable", "EditSpotLocationViewController.title")
  }

  internal enum EmailContactService {
    /// Topic category
    internal static let categoryAlertTitle = L10n.tr("Localizable", "EmailContactService.categoryAlertTitle")
    /// Please select the category of the topic you are contacting us about.
    internal static let message = L10n.tr("Localizable", "EmailContactService.message")
    internal enum ComposeEmail {
      /// Sending mail
      internal static let canSendMail = L10n.tr("Localizable", "EmailContactService.ComposeEmail.canSendMail")
      /// Including subjects in messages
      internal static let canSendSubject = L10n.tr("Localizable", "EmailContactService.ComposeEmail.canSendSubject")
      /// Sending text only messages
      internal static let canSendText = L10n.tr("Localizable", "EmailContactService.ComposeEmail.canSendText")
      /// Device setup
      internal static let deviceSetup = L10n.tr("Localizable", "EmailContactService.ComposeEmail.deviceSetup")
      /// Your device is not set up for the following
      internal static let message = L10n.tr("Localizable", "EmailContactService.ComposeEmail.message")
    }
  }

  internal enum EmojiList {
    internal enum Clap {
      /// Kudos!
      internal static let text = L10n.tr("Localizable", "EmojiList.Clap.text")
    }
    internal enum DroolingFace {
      /// Omg need!
      internal static let text = L10n.tr("Localizable", "EmojiList.DroolingFace.text")
    }
    internal enum Gem {
      /// Major hidden gem!
      internal static let text = L10n.tr("Localizable", "EmojiList.Gem.text")
    }
    internal enum HeartEyes {
      /// Stunning!
      internal static let text = L10n.tr("Localizable", "EmojiList.HeartEyes.text")
    }
    internal enum RoundPushpin {
      /// I've been here too!
      internal static let text = L10n.tr("Localizable", "EmojiList.RoundPushpin.text")
    }
  }

  internal enum EmojiNotificationViewCell {
    /// reacted
    internal static let reacted = L10n.tr("Localizable", "EmojiNotificationViewCell.reacted")
  }

  internal enum EmojisTableViewController {
    /// Emojis
    internal static let title = L10n.tr("Localizable", "EmojisTableViewController.title")
  }

  internal enum EmptySpotsView {
    /// To start filling it up, head to the search page and add some people!
    internal static let subTitle = L10n.tr("Localizable", "EmptySpotsView.subTitle")
    /// This will be your feed!
    internal static let title = L10n.tr("Localizable", "EmptySpotsView.title")
  }

  internal enum FilterViewController {
    /// Select Filters:
    internal static let filterLabel = L10n.tr("Localizable", "FilterViewController.filterLabel")
  }

  internal enum FollowRequestTableViewCell {
    ///  wants to add you to their people
    internal static let string = L10n.tr("Localizable", "FollowRequestTableViewCell.string")
  }

  internal enum ForgotPasswordViewController {
    /// A temporary password will be sent to your email.
    internal static let descriptionLabel = L10n.tr("Localizable", "ForgotPasswordViewController.descriptionLabel")
    /// Submit
    internal static let submitButton = L10n.tr("Localizable", "ForgotPasswordViewController.submitButton")
    /// Forgot Password
    internal static let title = L10n.tr("Localizable", "ForgotPasswordViewController.title")
    internal enum PaoAlert {
      /// An email with a password reset link has been sent to you.
      internal static let subTitle = L10n.tr("Localizable", "ForgotPasswordViewController.PaoAlert.subTitle")
      /// Sent!
      internal static let title = L10n.tr("Localizable", "ForgotPasswordViewController.PaoAlert.title")
    }
  }

  internal enum GlobalPlayListHeaderCollectionViewCell {
    /// New spots updated weekly
    internal static let subTitle = L10n.tr("Localizable", "GlobalPlayListHeaderCollectionViewCell.subTitle")
    /// Discover Hidden Gems
    internal static let title = L10n.tr("Localizable", "GlobalPlayListHeaderCollectionViewCell.title")
  }

  internal enum GoContactTableViewCell {
    /// Directions
    internal static let directions = L10n.tr("Localizable", "GoContactTableViewCell.directions")
    /// Phone
    internal static let phone = L10n.tr("Localizable", "GoContactTableViewCell.phone")
    /// Website
    internal static let website = L10n.tr("Localizable", "GoContactTableViewCell.website")
  }

  internal enum GoFactsTableViewCell {
    /// Address
    internal static let address = L10n.tr("Localizable", "GoFactsTableViewCell.address")
    /// Closed
    internal static let closed = L10n.tr("Localizable", "GoFactsTableViewCell.closed")
    /// Hours
    internal static let hours = L10n.tr("Localizable", "GoFactsTableViewCell.hours")
    /// Hours today
    internal static let hoursToday = L10n.tr("Localizable", "GoFactsTableViewCell.hoursToday")
    /// Open
    internal static let `open` = L10n.tr("Localizable", "GoFactsTableViewCell.open")
    /// Permanently Closed
    internal static let permanentlyClosed = L10n.tr("Localizable", "GoFactsTableViewCell.permanentlyClosed")
    /// Temporarily Closed
    internal static let temporarilyClosed = L10n.tr("Localizable", "GoFactsTableViewCell.temporarilyClosed")
    /// Unknown
    internal static let unknown = L10n.tr("Localizable", "GoFactsTableViewCell.unknown")
    /// Week
    internal static let week = L10n.tr("Localizable", "GoFactsTableViewCell.week")
  }

  internal enum GoSpotInfoTableViewController {
    /// Facts
    internal static let facts = L10n.tr("Localizable", "GoSpotInfoTableViewController.facts")
  }

  internal enum GoSubViewController {
    /// Photos
    internal static let photos = L10n.tr("Localizable", "GoSubViewController.photos")
    /// Spot Info
    internal static let spotInfo = L10n.tr("Localizable", "GoSubViewController.spotInfo")
  }

  internal enum HrZG25oA {
    /// Log out
    internal static let normalTitle = L10n.tr("Localizable", "HrZ-g2-5oA.normalTitle")
  }

  internal enum IdkFeedViewController {
    internal enum PlayList {
      /// A never ending list of inspiration
      internal static let description = L10n.tr("Localizable", "IdkFeedViewController.PlayList.description")
    }
  }

  internal enum ImagePickerViewController {
    /// Oops! Your video is too large to upload. Please make sure your videos are less than %@MB.
    internal static func message(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ImagePickerViewController.message", String(describing: p1))
    }
  }

  internal enum LocationHeaderView {
    /// What's happening in
    internal static let lblWhatsHappening = L10n.tr("Localizable", "LocationHeaderView.lblWhatsHappening")
  }

  internal enum LocationInteractionViewController {
    /// Locating...
    internal static let labelLocating = L10n.tr("Localizable", "LocationInteractionViewController.labelLocating")
    /// Recent
    internal static let titleRecent = L10n.tr("Localizable", "LocationInteractionViewController.titleRecent")
    /// Top
    internal static let titleTop = L10n.tr("Localizable", "LocationInteractionViewController.titleTop")
  }

  internal enum LocationService {
    /// Open Settings
    internal static let openSettings = L10n.tr("Localizable", "LocationService.openSettings")
    /// You need to enable location from the settings.
    internal static let youNeedToEnableLocation = L10n.tr("Localizable", "LocationService.youNeedToEnableLocation")
  }

  internal enum LocationsSearchCollectionViewController {
    /// Explore new cities each week on Pao!
    internal static let subTitle = L10n.tr("Localizable", "LocationsSearchCollectionViewController.subTitle")
    /// Featured Cities
    internal static let title = L10n.tr("Localizable", "LocationsSearchCollectionViewController.title")
  }

  internal enum LocationsSearchTableViewController {
    /// Current Location
    internal static let currentLocation = L10n.tr("Localizable", "LocationsSearchTableViewController.currentLocation")
    /// No one on Pao has been here yet!\nBut you should definitely be the first one to go!
    internal static let noResultText = L10n.tr("Localizable", "LocationsSearchTableViewController.noResultText")
    internal enum PermissionAlert {
      /// Do you want to get your current location?
      internal static let subTitle = L10n.tr("Localizable", "LocationsSearchTableViewController.PermissionAlert.subTitle")
      /// Location permission
      internal static let title = L10n.tr("Localizable", "LocationsSearchTableViewController.PermissionAlert.title")
    }
    internal enum Section {
      /// Related
      internal static let titleRelated = L10n.tr("Localizable", "LocationsSearchTableViewController.Section.titleRelated")
      /// Results
      internal static let titleResults = L10n.tr("Localizable", "LocationsSearchTableViewController.Section.titleResults")
      /// Top Pao Cities
      internal static let titleTopPaoCities = L10n.tr("Localizable", "LocationsSearchTableViewController.Section.titleTopPaoCities")
    }
  }

  internal enum LoginViewController {
    /// Email
    internal static let emailPlaceholder = L10n.tr("Localizable", "LoginViewController.emailPlaceholder")
    /// Can't be empty.
    internal static let errorCantBeEmpty = L10n.tr("Localizable", "LoginViewController.errorCantBeEmpty")
    /// Please enter a valid email
    internal static let errorEmail = L10n.tr("Localizable", "LoginViewController.errorEmail")
    /// Forgot Password?
    internal static let forgotPasswordButton = L10n.tr("Localizable", "LoginViewController.forgotPasswordButton")
    /// Log in
    internal static let loginButton = L10n.tr("Localizable", "LoginViewController.loginButton")
    /// It looks like there is no user associated with that email. Please check that you entered the correct email and try again.
    internal static let messagePrompt = L10n.tr("Localizable", "LoginViewController.messagePrompt")
    /// There is no user record corresponding to this identifier. The user may have been deleted.
    internal static let noUserError = L10n.tr("Localizable", "LoginViewController.noUserError")
    /// Password
    internal static let passwordPlaceholder = L10n.tr("Localizable", "LoginViewController.passwordPlaceholder")
    /// Login
    internal static let title = L10n.tr("Localizable", "LoginViewController.title")
    internal enum MessagePrompt {
      /// Oops!
      internal static let title = L10n.tr("Localizable", "LoginViewController.MessagePrompt.title")
    }
  }

  internal enum ManualSpotsViewController {
    /// 
    internal static let title = L10n.tr("Localizable", "ManualSpotsViewController.title")
  }

  internal enum NetworkViewController {
    internal enum ForceUpdateAlert {
      /// Let’s do it!
      internal static let buttonTitle = L10n.tr("Localizable", "NetworkViewController.ForceUpdateAlert.buttonTitle")
      /// Pao has some brand new features! To start using them, head to the App Store and update now!
      internal static let message = L10n.tr("Localizable", "NetworkViewController.ForceUpdateAlert.message")
      /// New Pao Update!
      internal static let title = L10n.tr("Localizable", "NetworkViewController.ForceUpdateAlert.title")
    }
  }

  internal enum NewSpotCategorySubcategoryViewController {
    /// What type of gem is this?
    internal static let headingLabel = L10n.tr("Localizable", "NewSpotCategorySubcategoryViewController.headingLabel")
    /// Category
    internal static let title = L10n.tr("Localizable", "NewSpotCategorySubcategoryViewController.title")
  }

  internal enum NewSpotDescriptionViewController {
    /// What would you tell your friends about this gem?
    internal static let headingLabel = L10n.tr("Localizable", "NewSpotDescriptionViewController.headingLabel")
    /// Tip
    internal static let title = L10n.tr("Localizable", "NewSpotDescriptionViewController.title")
  }

  internal enum NewSpotLocationViewController {
    /// Add Place
    internal static let addPlace = L10n.tr("Localizable", "NewSpotLocationViewController.addPlace")
    /// Be as specific as possible!
    internal static let beSpecific = L10n.tr("Localizable", "NewSpotLocationViewController.beSpecific")
    /// This location is too general for Pao. Please put in the exact spot name or address so anyone could get there.
    internal static let locationIsTooGeneral = L10n.tr("Localizable", "NewSpotLocationViewController.locationIsTooGeneral")
    /// Now search for your gem's location.
    internal static let searchForSpotsLocation = L10n.tr("Localizable", "NewSpotLocationViewController.searchForSpotsLocation")
    /// Location
    internal static let title = L10n.tr("Localizable", "NewSpotLocationViewController.title")
  }

  internal enum NewSpotPreviewViewController {
    /// Preview
    internal static let title = L10n.tr("Localizable", "NewSpotPreviewViewController.title")
  }

  internal enum NotificationViewCell {
    /// accepted your add request
    internal static let labelAcceptedYourRequest = L10n.tr("Localizable", "NotificationViewCell.labelAcceptedYourRequest")
    /// added you to their people
    internal static let labelAddedYouToTheirPeople = L10n.tr("Localizable", "NotificationViewCell.labelAddedYouToTheirPeople")
    /// commented on your gem
    internal static let labelCommentedOnYourGem = L10n.tr("Localizable", "NotificationViewCell.labelCommentedOnYourGem")
    /// mentioned you in a comment
    internal static let labelMentionedYouInComment = L10n.tr("Localizable", "NotificationViewCell.labelMentionedYouInComment")
    /// saved your gem
    internal static let labelSavedYourGem = L10n.tr("Localizable", "NotificationViewCell.labelSavedYourGem")
    /// verified your gem
    internal static let labelVerifiedYourGem = L10n.tr("Localizable", "NotificationViewCell.labelVerifiedYourGem")
  }

  internal enum NotificationsSettingsTableViewController {
    /// You will get notified when someone comments, saves, or verifies your post. You will also be notified if a user adds you, or requests to add you to their people.
    internal static let labelText = L10n.tr("Localizable", "NotificationsSettingsTableViewController.labelText")
    /// Notifications
    internal static let title = L10n.tr("Localizable", "NotificationsSettingsTableViewController.title")
  }

  internal enum NotificationsViewController {
    /// Notifications
    internal static let title = L10n.tr("Localizable", "NotificationsViewController.title")
    internal enum PermissionAlert {
      /// Do you want to know when someone saves/comments on your post?
      internal static let subTitle = L10n.tr("Localizable", "NotificationsViewController.PermissionAlert.subTitle")
      /// Never miss out!
      internal static let title = L10n.tr("Localizable", "NotificationsViewController.PermissionAlert.title")
    }
  }

  internal enum OnBoardingViewController {
    /// Never forget where you've been
    internal static let descriptionNeverForget = L10n.tr("Localizable", "OnBoardingViewController.descriptionNeverForget")
    /// No nameless reviewers
    internal static let descriptionNoNamelessReviewers = L10n.tr("Localizable", "OnBoardingViewController.descriptionNoNamelessReviewers")
    /// No negative reviews or tourist traps
    internal static let descriptionNoNegativeReviews = L10n.tr("Localizable", "OnBoardingViewController.descriptionNoNegativeReviews")
    /// Discover hidden gems you \nwon't find anywhere else
    internal static let titleDiscoverHiddenGems = L10n.tr("Localizable", "OnBoardingViewController.titleDiscoverHiddenGems")
    /// Join a community of \ntravel-obsessed doers
    internal static let titleJoinCommunity = L10n.tr("Localizable", "OnBoardingViewController.titleJoinCommunity")
    /// Keep track of your \nfave hidden gems
    internal static let titleKeepTrack = L10n.tr("Localizable", "OnBoardingViewController.titleKeepTrack")
  }

  internal enum OnboardingPageViewController {
    /// Swipe
    internal static let swipe = L10n.tr("Localizable", "OnboardingPageViewController.swipe")
  }

  internal enum PaoAlertController {
    internal enum CoverPhotos {
      /// You can now change the cover photo for each of your location boards! Head to your profile, select a board and click the three dots to start!
      internal static let message = L10n.tr("Localizable", "PaoAlertController.CoverPhotos.message")
      /// Change Cover Photos!
      internal static let title = L10n.tr("Localizable", "PaoAlertController.CoverPhotos.title")
      internal enum Button {
        /// Get Started!
        internal static let text = L10n.tr("Localizable", "PaoAlertController.CoverPhotos.Button.text")
      }
    }
  }

  internal enum PasswordViewController {
    /// By joining, you agree to Pao's Privacy Policy
    internal static let agree = L10n.tr("Localizable", "PasswordViewController.agree")
    /// Confirm Password
    internal static let confirmPassword = L10n.tr("Localizable", "PasswordViewController.confirmPassword")
    /// Password must be at least 8 characters with one number and a capital letter
    internal static let errorPassword = L10n.tr("Localizable", "PasswordViewController.errorPassword")
    /// The passwords do not match
    internal static let errorPasswordNotMatch = L10n.tr("Localizable", "PasswordViewController.errorPasswordNotMatch")
    /// Go time
    internal static let goButton = L10n.tr("Localizable", "PasswordViewController.goButton")
    /// Password
    internal static let password = L10n.tr("Localizable", "PasswordViewController.password")
    /// Privacy Policy
    internal static let privacyPolicy = L10n.tr("Localizable", "PasswordViewController.privacyPolicy")
    internal enum MessagePrompt {
      /// Oops! Something went wrong when creating your account. Please try again.
      internal static let message = L10n.tr("Localizable", "PasswordViewController.MessagePrompt.message")
    }
  }

  internal enum PeopleSearchCollectionViewController {
    /// Oops!\nThere is no one Pao with that name or\nusername yet.
    internal static let noResultText = L10n.tr("Localizable", "PeopleSearchCollectionViewController.noResultText")
    /// Check out today's featured users on Pao!
    internal static let subTitle = L10n.tr("Localizable", "PeopleSearchCollectionViewController.subTitle")
    /// Featured Users
    internal static let title = L10n.tr("Localizable", "PeopleSearchCollectionViewController.title")
  }

  internal enum PeopleSearchTableViewController {
    /// Oops!\nThere is no one Pao with that name or\nusername yet.
    internal static let noResultText = L10n.tr("Localizable", "PeopleSearchTableViewController.noResultText")
    internal enum Header {
      /// Top Pao Users
      internal static let title = L10n.tr("Localizable", "PeopleSearchTableViewController.Header.title")
    }
  }

  internal enum PickerImageView {
    /// You denied access to your photos. To upload a spot on Pao, please go to your phone settings and grant Pao access to your photos.
    internal static let deniedAccessToPhotos = L10n.tr("Localizable", "PickerImageView.deniedAccessToPhotos")
  }

  internal enum PlayListCollectionViewController {
    /// Discover
    internal static let title = L10n.tr("Localizable", "PlayListCollectionViewController.title")
    internal enum EmptyView {
      /// Oh snap!\nNo one on Pao has been to that spot yet.\nBut you should totally be the first one to go.
      internal static let text = L10n.tr("Localizable", "PlayListCollectionViewController.EmptyView.text")
    }
    internal enum Header {
      /// Discover Hidden Gems
      internal static let text = L10n.tr("Localizable", "PlayListCollectionViewController.Header.text")
    }
    internal enum Section {
      /// Here for today only
      internal static let subTitleHereForTodayOnly = L10n.tr("Localizable", "PlayListCollectionViewController.Section.subTitleHereForTodayOnly")
      /// New spots updated every Friday
      internal static let subTitleNewSpotsUpdatedEveryFriday = L10n.tr("Localizable", "PlayListCollectionViewController.Section.subTitleNewSpotsUpdatedEveryFriday")
      /// Best of Pao
      internal static let titleBestOfPao = L10n.tr("Localizable", "PlayListCollectionViewController.Section.titleBestOfPao")
      /// Featured Today
      internal static let titleFeaturedToday = L10n.tr("Localizable", "PlayListCollectionViewController.Section.titleFeaturedToday")
    }
  }

  internal enum PlayListDetailsViewController {
    internal enum CoachMarkBodyView {
      /// If you want to save this spot \n for later, press the bookmark!
      internal static let description = L10n.tr("Localizable", "PlayListDetailsViewController.CoachMarkBodyView.description")
      /// Save this spot
      internal static let title = L10n.tr("Localizable", "PlayListDetailsViewController.CoachMarkBodyView.title")
      internal enum HintLabel {
        /// Tap anywhere on the post to see the person's tip about the spot.
        internal static let text = L10n.tr("Localizable", "PlayListDetailsViewController.CoachMarkBodyView.HintLabel.text")
      }
    }
    internal enum PlayList {
      /// 10 spots from around the world posted by Pao users
      internal static let description = L10n.tr("Localizable", "PlayListDetailsViewController.PlayList.description")
    }
  }

  internal enum PlayListPopUpViewController {
    /// OUTDOORS
    internal static let circleLabel = L10n.tr("Localizable", "PlayListPopUpViewController.circleLabel")
    /// Think of it like a music playlist, but with new spots rather than songs. This is a fun way to discover the best hidden gems and Pao users!
    internal static let description = L10n.tr("Localizable", "PlayListPopUpViewController.description")
    /// Introducing\n“Pao Play Lists”
    internal static let title = L10n.tr("Localizable", "PlayListPopUpViewController.title")
    internal enum CheckItOutButton {
      /// Check it out
      internal static let title = L10n.tr("Localizable", "PlayListPopUpViewController.CheckItOutButton.title")
    }
  }

  internal enum PlayListTableViewController {
    /// Discover
    internal static let title = L10n.tr("Localizable", "PlayListTableViewController.title")
  }

  internal enum PreviewCarouselViewController {
    /// then choose up to 10 photos/videos of your gem!
    internal static let chooseUpto10 = L10n.tr("Localizable", "PreviewCarouselViewController.chooseUpto10")
    /// First, select your cover photo...
    internal static let selectCoverPhoto = L10n.tr("Localizable", "PreviewCarouselViewController.selectCoverPhoto")
  }

  internal enum PrivacySettingsTableViewController {
    /// When your account is private, only users you approve can access your uploads and saves, users will also not be able to discover your spots in the World feed.
    internal static let labelText = L10n.tr("Localizable", "PrivacySettingsTableViewController.labelText")
    /// Privacy
    internal static let title = L10n.tr("Localizable", "PrivacySettingsTableViewController.title")
  }

  internal enum ProfileEditTagsViewController {
    /// Your Interests:
    internal static let interestsLabel = L10n.tr("Localizable", "ProfileEditTagsViewController.interestsLabel")
    /// What You're Into
    internal static let title = L10n.tr("Localizable", "ProfileEditTagsViewController.title")
  }

  internal enum ProfileEditViewController {
    /// Your username must be at least two letters.
    internal static let editingError = L10n.tr("Localizable", "ProfileEditViewController.editingError")
    /// Edit Profile
    internal static let title = L10n.tr("Localizable", "ProfileEditViewController.title")
    /// This username is already taken. Please try a different one!
    internal static let usernameTakenError = L10n.tr("Localizable", "ProfileEditViewController.usernameTakenError")
    internal enum Header {
      /// Basic Info
      internal static let basicInfo = L10n.tr("Localizable", "ProfileEditViewController.Header.basicInfo")
      /// Bio
      internal static let bio = L10n.tr("Localizable", "ProfileEditViewController.Header.bio")
      /// What you're into
      internal static let whatYoureInto = L10n.tr("Localizable", "ProfileEditViewController.Header.whatYoureInto")
      /// Where you're at
      internal static let whereYoureAt = L10n.tr("Localizable", "ProfileEditViewController.Header.whereYoureAt")
    }
  }

  internal enum ProfileSubViewController {
    /// This user is private, you can request to add them.
    internal static let privateBoardMessage = L10n.tr("Localizable", "ProfileSubViewController.privateBoardMessage")
  }

  internal enum ReachabilityService {
    /// You are offline
    internal static let youAreOffline = L10n.tr("Localizable", "ReachabilityService.youAreOffline")
    internal enum PaoAlert {
      /// Pao is unable to connect.\n Try checking your internet or\n service connection and try again.
      internal static let subTitle = L10n.tr("Localizable", "ReachabilityService.PaoAlert.subTitle")
      /// Uh oh!
      internal static let title = L10n.tr("Localizable", "ReachabilityService.PaoAlert.title")
    }
  }

  internal enum RegisterViewController {
    /// Email
    internal static let email = L10n.tr("Localizable", "RegisterViewController.email")
    /// Please enter a valid email
    internal static let errorEmail = L10n.tr("Localizable", "RegisterViewController.errorEmail")
    /// This email is already in use
    internal static let errorEmailAlreadyInUse = L10n.tr("Localizable", "RegisterViewController.errorEmailAlreadyInUse")
    /// Please enter your full name
    internal static let errorFullName = L10n.tr("Localizable", "RegisterViewController.errorFullName")
    /// Username cannot contain special characters
    internal static let errorSpecialCharacters = L10n.tr("Localizable", "RegisterViewController.errorSpecialCharacters")
    /// Please enter your valid username
    internal static let errorUsername = L10n.tr("Localizable", "RegisterViewController.errorUsername")
    /// This username is already in use
    internal static let errorUsernameAlreadyInUse = L10n.tr("Localizable", "RegisterViewController.errorUsernameAlreadyInUse")
    /// Full Name
    internal static let fullName = L10n.tr("Localizable", "RegisterViewController.fullName")
    /// Next
    internal static let nextButton = L10n.tr("Localizable", "RegisterViewController.nextButton")
    /// Username
    internal static let username = L10n.tr("Localizable", "RegisterViewController.username")
  }

  internal enum SaveBoardCollectionViewController {
    /// Nothing here yet!\nTo save some spots, press the Pao\nicon on the menu bar below.
    internal static let emptyViewText = L10n.tr("Localizable", "SaveBoardCollectionViewController.emptyViewText")
    /// Search Saves
    internal static let searchPlaceholder = L10n.tr("Localizable", "SaveBoardCollectionViewController.searchPlaceholder")
  }

  internal enum SettingsTableViewController {
    /// About
    internal static let optionAbout = L10n.tr("Localizable", "SettingsTableViewController.optionAbout")
    /// Account
    internal static let optionAccount = L10n.tr("Localizable", "SettingsTableViewController.optionAccount")
    /// Contact
    internal static let optionContact = L10n.tr("Localizable", "SettingsTableViewController.optionContact")
    /// Data Download
    internal static let optionDataDownload = L10n.tr("Localizable", "SettingsTableViewController.optionDataDownload")
    /// Emojis
    internal static let optionEmojis = L10n.tr("Localizable", "SettingsTableViewController.optionEmojis")
    /// Logout
    internal static let optionLogout = L10n.tr("Localizable", "SettingsTableViewController.optionLogout")
    /// Notifications
    internal static let optionNotifications = L10n.tr("Localizable", "SettingsTableViewController.optionNotifications")
    /// Privacy
    internal static let optionPrivacy = L10n.tr("Localizable", "SettingsTableViewController.optionPrivacy")
    /// Settings
    internal static let title = L10n.tr("Localizable", "SettingsTableViewController.title")
    internal enum ErrorMessagePrompt {
      /// Oops! Something went wrong. Please try again.
      internal static let message = L10n.tr("Localizable", "SettingsTableViewController.ErrorMessagePrompt.message")
    }
    internal enum MessagePromptGDPR {
      /// Your GDPR data has been sent to your email.
      internal static let message = L10n.tr("Localizable", "SettingsTableViewController.MessagePromptGDPR.message")
      /// Data Sent
      internal static let title = L10n.tr("Localizable", "SettingsTableViewController.MessagePromptGDPR.title")
    }
    internal enum PaoAlert {
      /// Send email
      internal static let buttonText = L10n.tr("Localizable", "SettingsTableViewController.PaoAlert.buttonText")
      /// Please confirm you want your data sent via email per GPDR standards
      internal static let subTitle = L10n.tr("Localizable", "SettingsTableViewController.PaoAlert.subTitle")
    }
  }

  internal enum SpotCollectionViewCell {
    /// Go
    internal static let goButton = L10n.tr("Localizable", "SpotCollectionViewCell.goButton")
    /// Uploading
    internal static let labelUploading = L10n.tr("Localizable", "SpotCollectionViewCell.labelUploading")
    internal enum EmojiMeaningRevisitInstructionAlert {
      /// If you ever want to revisit \nwhat each emoji means, \ncheck out the settings \npage on your profile!
      internal static let subTitle = L10n.tr("Localizable", "SpotCollectionViewCell.EmojiMeaningRevisitInstructionAlert.subTitle")
    }
    internal enum MessageButton {
      /// View %@ comments
      internal static func title(_ p1: Any) -> String {
        return L10n.tr("Localizable", "SpotCollectionViewCell.MessageButton.title", String(describing: p1))
      }
    }
    internal enum MessageButtonEmpty {
      /// Make a comment...
      internal static let title = L10n.tr("Localizable", "SpotCollectionViewCell.MessageButtonEmpty.title")
    }
    internal enum MessageButtonOne {
      /// View 1 comment
      internal static let title = L10n.tr("Localizable", "SpotCollectionViewCell.MessageButtonOne.title")
    }
  }

  internal enum SpotCollectionViewController {
    internal enum ForceUpdateAlert {
      /// Okay!
      internal static let buttonTitle = L10n.tr("Localizable", "SpotCollectionViewController.ForceUpdateAlert.buttonTitle")
      /// Try holding down any of \nthe emojis under a post to \nsee who reacted!
      internal static let subTitle = L10n.tr("Localizable", "SpotCollectionViewController.ForceUpdateAlert.subTitle")
      /// Pro Tip!
      internal static let title = L10n.tr("Localizable", "SpotCollectionViewController.ForceUpdateAlert.title")
    }
  }

  internal enum SpotTableViewCell {
    internal enum MessagePrompt {
      /// You can only pick three favorites per board. Make sure they are the very best!
      internal static let message = L10n.tr("Localizable", "SpotTableViewCell.MessagePrompt.message")
      /// Hold up!
      internal static let title = L10n.tr("Localizable", "SpotTableViewCell.MessagePrompt.title")
    }
  }

  internal enum SpotUsersViewController {
    /// Saved
    internal static let titleSaved = L10n.tr("Localizable", "SpotUsersViewController.titleSaved")
  }

  internal enum SpotsSearchCollectionViewController {
    /// Oh snap!\nNo one on Pao has been to that spot yet.\nBut you should totally be the first one to go.
    internal static let noResultText = L10n.tr("Localizable", "SpotsSearchCollectionViewController.noResultText")
    internal enum Header {
      /// Based on quality of spot, tip, and photos.
      internal static let subTitle = L10n.tr("Localizable", "SpotsSearchCollectionViewController.Header.subTitle")
      /// Top Spots This Week
      internal static let title = L10n.tr("Localizable", "SpotsSearchCollectionViewController.Header.title")
    }
  }

  internal enum SpotsSearchTableViewController {
    /// Oh snap!\nNo one on Pao has been to that spot yet.\nBut you should totally be the first one to go.
    internal static let noResultText = L10n.tr("Localizable", "SpotsSearchTableViewController.noResultText")
    /// Top Pao Gems
    internal static let title = L10n.tr("Localizable", "SpotsSearchTableViewController.title")
  }

  internal enum SpotsViewController {
    internal enum AddUsersOption {
      /// Delete Post
      internal static let deletePost = L10n.tr("Localizable", "SpotsViewController.AddUsersOption.deletePost")
      /// Edit Post
      internal static let editPost = L10n.tr("Localizable", "SpotsViewController.AddUsersOption.editPost")
    }
    internal enum AddViewersOption {
      /// Inappropriate post
      internal static let inappropriatePost = L10n.tr("Localizable", "SpotsViewController.AddViewersOption.inappropriatePost")
      /// It's inappropriate
      internal static let itsInappropriate = L10n.tr("Localizable", "SpotsViewController.AddViewersOption.itsInappropriate")
      /// It's spam
      internal static let itsSpam = L10n.tr("Localizable", "SpotsViewController.AddViewersOption.itsSpam")
      /// Report Post
      internal static let reportPost = L10n.tr("Localizable", "SpotsViewController.AddViewersOption.reportPost")
      /// Spam post
      internal static let spamPost = L10n.tr("Localizable", "SpotsViewController.AddViewersOption.spamPost")
      internal enum BlockUser {
        /// User blocked. They will no longer be able to see you or your posts.
        internal static let message = L10n.tr("Localizable", "SpotsViewController.AddViewersOption.BlockUser.message")
        /// Block User
        internal static let title = L10n.tr("Localizable", "SpotsViewController.AddViewersOption.BlockUser.title")
      }
      internal enum CategoryAlert {
        /// Choose a reason for reporting this post.
        internal static let message = L10n.tr("Localizable", "SpotsViewController.AddViewersOption.CategoryAlert.message")
      }
    }
    internal enum DeletePostAlert {
      /// Oops! Something went wrong while deleting your post. Please try again.
      internal static let errorMessage = L10n.tr("Localizable", "SpotsViewController.DeletePostAlert.errorMessage")
      /// Are you sure you want to delete this post?
      internal static let message = L10n.tr("Localizable", "SpotsViewController.DeletePostAlert.message")
    }
    internal enum DeleteUploadingPostAlert {
      /// Are you sure you want to delete this post?
      internal static let message = L10n.tr("Localizable", "SpotsViewController.DeleteUploadingPostAlert.message")
    }
  }

  internal enum TabBarController {
    internal enum CoachMarkBodyView {
      /// Find people to add here.
      internal static let findPeopleToAdd = L10n.tr("Localizable", "TabBarController.CoachMarkBodyView.findPeopleToAdd")
      /// Share your fave spots here.
      internal static let shareYourSpot = L10n.tr("Localizable", "TabBarController.CoachMarkBodyView.shareYourSpot")
      /// Swipe through cool spots here.
      internal static let swipeSpots = L10n.tr("Localizable", "TabBarController.CoachMarkBodyView.swipeSpots")
    }
    internal enum MessagePrompt {
      /// You denied access to your photos. To upload a spot on Pao, please go to your phone settings and grant Pao access to your photos.
      internal static let message = L10n.tr("Localizable", "TabBarController.MessagePrompt.message")
    }
    internal enum NewFeatureAlert {
      /// Got it!
      internal static let buttonTitle = L10n.tr("Localizable", "TabBarController.NewFeatureAlert.buttonTitle")
      /// Want to share a gem with someone who’s not on Pao yet? Click the three dots on the top right of a post to send it via text, email, and more!
      internal static let subTitle = L10n.tr("Localizable", "TabBarController.NewFeatureAlert.subTitle")
      /// New Feature Alert!
      internal static let title = L10n.tr("Localizable", "TabBarController.NewFeatureAlert.title")
    }
    internal enum UploadError {
      /// Oops! Something went wrong when uploading your spot. Please check your service or internet connection and try again.
      internal static let checkInternetConnectioin = L10n.tr("Localizable", "TabBarController.UploadError.checkInternetConnectioin")
      /// Oops! Your post is too large for Pao. Please make sure your photos and videos total less than 60MB and try again.
      internal static let postIsTooLarge = L10n.tr("Localizable", "TabBarController.UploadError.postIsTooLarge")
    }
    internal enum UploadNotification {
      /// Post successful! Click to view.
      internal static let message = L10n.tr("Localizable", "TabBarController.UploadNotification.message")
    }
    internal enum WelcomeAlert {
      /// Start by browsing our featured hidden gems or head to search page to find gems near you!
      internal static let subTitle = L10n.tr("Localizable", "TabBarController.WelcomeAlert.subTitle")
      /// Welcome to Pao!
      internal static let title = L10n.tr("Localizable", "TabBarController.WelcomeAlert.title")
    }
  }

  internal enum TopSpotsViewController {
    /// There are no spots under this category yet!
    internal static let noResultText = L10n.tr("Localizable", "TopSpotsViewController.noResultText")
    /// List
    internal static let titleList = L10n.tr("Localizable", "TopSpotsViewController.titleList")
    /// Map
    internal static let titleMap = L10n.tr("Localizable", "TopSpotsViewController.titleMap")
    /// Scroll
    internal static let titleScroll = L10n.tr("Localizable", "TopSpotsViewController.titleScroll")
  }

  internal enum UIViewController {
    internal enum Alert {
      /// Alert
      internal static let title = L10n.tr("Localizable", "UIViewController.Alert.title")
    }
  }

  internal enum UploadBoardCollectionViewController {
    /// Nothing here yet!\nTo upload one of your favorite spots,\npress the plus button below.
    internal static let emptyViewText = L10n.tr("Localizable", "UploadBoardCollectionViewController.emptyViewText")
    /// Search Gems
    internal static let searchPlaceholder = L10n.tr("Localizable", "UploadBoardCollectionViewController.searchPlaceholder")
  }

  internal enum UserPermissionsAlertViewController {
    internal enum NewsletterLabel {
      /// I agree to receive newsletters, offers, promotions and other marketing materials from Pao.
      internal static let text = L10n.tr("Localizable", "UserPermissionsAlertViewController.NewsletterLabel.text")
    }
    internal enum PersonalDataLabel {
      /// I understand and agree that my personal data may be transferred to locations outside my country of residence and such locations may not guarantee the same level of protection for personal data as my country.
      internal static let text = L10n.tr("Localizable", "UserPermissionsAlertViewController.PersonalDataLabel.text")
    }
  }

  internal enum UserProfileViewController {
    internal enum PaoAlert {
      /// Profile not found!
      internal static let subTitle = L10n.tr("Localizable", "UserProfileViewController.PaoAlert.subTitle")
      /// Error
      internal static let title = L10n.tr("Localizable", "UserProfileViewController.PaoAlert.title")
    }
    internal enum ProfileAction {
      /// Add
      internal static let add = L10n.tr("Localizable", "UserProfileViewController.ProfileAction.add")
      /// Added
      internal static let added = L10n.tr("Localizable", "UserProfileViewController.ProfileAction.added")
    }
  }

  internal enum YourLocationViewController {
    /// What's happening in
    internal static let labelWahtsHappening = L10n.tr("Localizable", "YourLocationViewController.labelWahtsHappening")
  }

  internal enum YourPeopleSpotsViewController {
    /// None of your people have been here yet!\nBut you should definitely be the first one to go.
    internal static let noResultText = L10n.tr("Localizable", "YourPeopleSpotsViewController.noResultText")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
