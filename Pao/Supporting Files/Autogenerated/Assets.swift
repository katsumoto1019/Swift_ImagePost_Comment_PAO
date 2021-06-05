// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Assets {
    internal enum Alert {
      internal static let alertCoverPhoto = ImageAsset(name: "alertCoverPhoto")
    }
    internal enum Backgrounds {
      internal static let splashScreen = ImageAsset(name: "Splash Screen")
      internal static let background = ImageAsset(name: "background")
      internal static let defaultCoverPhoto = ImageAsset(name: "defaultCoverPhoto")
      internal static let emptySpotBackground = ImageAsset(name: "emptySpotBackground")
      internal static let locationNotificationHeader = ImageAsset(name: "locationNotificationHeader")
    }
    internal enum Icons {
      internal static let addEmoji = ImageAsset(name: "addEmoji")
      internal static let addPhoto = ImageAsset(name: "addPhoto")
      internal static let albumCover = ImageAsset(name: "albumCover")
      internal static let approveRequest = ImageAsset(name: "approveRequest")
      internal static let arrowdown = ImageAsset(name: "arrowdown")
      internal static let arrowup = ImageAsset(name: "arrowup")
      internal static let arrowupblack = ImageAsset(name: "arrowupblack")
      internal static let bell = ImageAsset(name: "bell")
      internal static let bookmark = ImageAsset(name: "bookmark")
      internal static let camera = ImageAsset(name: "camera")
      internal static let checkBox = ImageAsset(name: "checkBox")
      internal static let checkboxselected = ImageAsset(name: "checkboxselected")
      internal static let clockIcon = ImageAsset(name: "clockIcon")
      internal static let close = ImageAsset(name: "close")
      internal static let comment = ImageAsset(name: "comment")
      internal static let deleteRequest = ImageAsset(name: "deleteRequest")
      internal static let emojiClappingHands = ImageAsset(name: "emojiClappingHands")
      internal static let emojiDiamond = ImageAsset(name: "emojiDiamond")
      internal static let emojiDrooling = ImageAsset(name: "emojiDrooling")
      internal static let emojiHeartEyes = ImageAsset(name: "emojiHeartEyes")
      internal static let emojiRedPin = ImageAsset(name: "emojiRedPin")
      internal static let eye = ImageAsset(name: "eye")
      internal static let filter = ImageAsset(name: "filter")
      internal static let leftArrow = ImageAsset(name: "leftArrow")
      internal static let leftArrowNav = ImageAsset(name: "leftArrowNav")
      internal static let locationPin = ImageAsset(name: "locationPin")
      internal static let locationPinIcon = ImageAsset(name: "locationPinIcon")
      internal static let map = ImageAsset(name: "map")
      internal static let menu = ImageAsset(name: "menu")
      internal static let notificationCheck = ImageAsset(name: "notification-check")
      internal static let notificationUnchecked = ImageAsset(name: "notification-unchecked")
      internal static let phoneIcon = ImageAsset(name: "phoneIcon")
      internal static let play = ImageAsset(name: "play")
      internal static let plus = ImageAsset(name: "plus")
      internal static let point = ImageAsset(name: "point")
      internal static let postNowIcon = ImageAsset(name: "postNowIcon")
      internal static let question = ImageAsset(name: "question")
      internal static let refresh = ImageAsset(name: "refresh")
      internal static let rightArrowNav = ImageAsset(name: "rightArrowNav")
      internal static let save = ImageAsset(name: "save")
      internal static let saved = ImageAsset(name: "saved")
      internal static let savedGo = ImageAsset(name: "savedGo")
      internal static let searchTeal = ImageAsset(name: "search-teal")
      internal static let settings = ImageAsset(name: "settings")
      internal static let star = ImageAsset(name: "star")
      internal static let starselected = ImageAsset(name: "starselected")
      internal static let upload = ImageAsset(name: "upload")
      internal static let user = ImageAsset(name: "user")
      internal static let users = ImageAsset(name: "users")
      internal static let verified = ImageAsset(name: "verified")
      internal static let websiteIcon = ImageAsset(name: "websiteIcon")
    }
    internal enum Logos {
      internal static let logo = ImageAsset(name: "logo")
      internal static let logoIcon = ImageAsset(name: "logoIcon")
    }
    internal enum Old {
      internal static let first = ImageAsset(name: "first")
      internal static let second = ImageAsset(name: "second")
    }
    internal enum PlayListPopUp {
      internal static let playListPopUpCenterImage = ImageAsset(name: "playListPopUpCenterImage")
      internal static let playListPopUpLeftImage = ImageAsset(name: "playListPopUpLeftImage")
      internal static let playListPopUpRightImage = ImageAsset(name: "playListPopUpRightImage")
    }
    internal enum TabBar {
      internal static let discoverTabIcon = ImageAsset(name: "discoverTabIcon")
      internal static let feedTabBar = ImageAsset(name: "feed-tabBar")
      internal static let homeTabBar = ImageAsset(name: "home-tabBar")
      internal static let notificationTabBar = ImageAsset(name: "notification-tabBar")
      internal static let searchTabBar = ImageAsset(name: "search-tabBar")
      internal static let userTabBar = ImageAsset(name: "user-tabBar")
    }
    internal enum Texts {
      internal static let categories = DataAsset(name: "categories")
      internal static let uploadTexts = DataAsset(name: "uploadTexts")
    }
    internal enum Onboarding3 {
      internal static let _1 = ImageAsset(name: "1")
      internal static let _1237064010749973358842381335951188977962746O = ImageAsset(name: "12370640_1074997335884238_1335951188977962746_o")
      internal static let _2634420321642724102659035117566649737674752N = ImageAsset(name: "26344203_2164272410265903_5117566649737674752_n")
      internal static let _418632791656916643492054493378219386339328N = ImageAsset(name: "41863279_165691664349205_4493378219386339328_n")
      internal static let img5365Jpeg = ImageAsset(name: "IMG_5365.jpeg")
      internal static let img6A5Ad64688781 = ImageAsset(name: "IMG_6A5AD6468878-1")
      internal static let imgA5754Ec181A81 = ImageAsset(name: "IMG_A5754EC181A8-1")
      internal static let imgDe0E0A89099F1 = ImageAsset(name: "IMG_DE0E0A89099F-1")
      internal static let screenShot20180827At25619PM = ImageAsset(name: "Screen Shot 2018-08-27 at 2.56.19 PM")
      internal static let screenShot20180827At25656PM = ImageAsset(name: "Screen Shot 2018-08-27 at 2.56.56 PM")
      internal static let screenShot20180827At25727PM = ImageAsset(name: "Screen Shot 2018-08-27 at 2.57.27 PM")
      internal static let screenShot20180827At25811PM = ImageAsset(name: "Screen Shot 2018-08-27 at 2.58.11 PM")
      internal static let screenShot20180827At25841PM = ImageAsset(name: "Screen Shot 2018-08-27 at 2.58.41 PM")
      internal static let screenShot20180827At30102PM = ImageAsset(name: "Screen Shot 2018-08-27 at 3.01.02 PM")
      internal static let screenShot20180827At30451PM = ImageAsset(name: "Screen Shot 2018-08-27 at 3.04.51 PM")
      internal static let screenShot20180827At30525PM = ImageAsset(name: "Screen Shot 2018-08-27 at 3.05.25 PM")
      internal static let screenShot20180827At30655PM = ImageAsset(name: "Screen Shot 2018-08-27 at 3.06.55 PM")
      internal static let screenShot20180827At30808PM = ImageAsset(name: "Screen Shot 2018-08-27 at 3.08.08 PM")
      internal static let screenShot20180827At30834PM = ImageAsset(name: "Screen Shot 2018-08-27 at 3.08.34 PM")
      internal static let screenShot20180827At30909PM = ImageAsset(name: "Screen Shot 2018-08-27 at 3.09.09 PM")
      internal static let screenShot20180828At25002PM = ImageAsset(name: "Screen Shot 2018-08-28 at 2.50.02 PM")
      internal static let screenShot20180828At34324PM = ImageAsset(name: "Screen Shot 2018-08-28 at 3.43.24 PM")
      internal static let screenShot20180828At34815PM = ImageAsset(name: "Screen Shot 2018-08-28 at 3.48.15 PM")
      internal static let screenShot20180828At35225PM = ImageAsset(name: "Screen Shot 2018-08-28 at 3.52.25 PM")
      internal static let screenShot20180828At40616PM = ImageAsset(name: "Screen Shot 2018-08-28 at 4.06.16 PM")
      internal static let screenShot20180828At41649PM = ImageAsset(name: "Screen Shot 2018-08-28 at 4.16.49 PM")
      internal static let screenShot20180904At22355PM = ImageAsset(name: "Screen Shot 2018-09-04 at 2.23.55 PM")
      internal static let screenShot20180904At22457PM = ImageAsset(name: "Screen Shot 2018-09-04 at 2.24.57 PM")
      internal static let screenShot20180904At22737PM = ImageAsset(name: "Screen Shot 2018-09-04 at 2.27.37 PM")
      internal static let screenShot20180904At22908PM = ImageAsset(name: "Screen Shot 2018-09-04 at 2.29.08 PM")
      internal static let screenShot20180904At22948PM = ImageAsset(name: "Screen Shot 2018-09-04 at 2.29.48 PM")
      internal static let screenShot20180904At23840PM = ImageAsset(name: "Screen Shot 2018-09-04 at 2.38.40 PM")
      internal static let screenShot20180904At23902PM = ImageAsset(name: "Screen Shot 2018-09-04 at 2.39.02 PM")
      internal static let screenShot20180904At24003PM = ImageAsset(name: "Screen Shot 2018-09-04 at 2.40.03 PM")
      internal static let screenShot20180904At24408PM = ImageAsset(name: "Screen Shot 2018-09-04 at 2.44.08 PM")
      internal static let screenShot20180904At25215PM = ImageAsset(name: "Screen Shot 2018-09-04 at 2.52.15 PM")
      internal static let screenShot20180904At25340PM = ImageAsset(name: "Screen Shot 2018-09-04 at 2.53.40 PM")
      internal static let screenShot20180904At25416PM = ImageAsset(name: "Screen Shot 2018-09-04 at 2.54.16 PM")
      internal static let screenShot20180904At25527PM = ImageAsset(name: "Screen Shot 2018-09-04 at 2.55.27 PM")
      internal static let screenShot20180904At25614PM = ImageAsset(name: "Screen Shot 2018-09-04 at 2.56.14 PM")
      internal static let screenShot20180904At25821PM = ImageAsset(name: "Screen Shot 2018-09-04 at 2.58.21 PM")
      internal static let screenShot20180904At25952PM = ImageAsset(name: "Screen Shot 2018-09-04 at 2.59.52 PM")
      internal static let screenShot20180904At44107PM = ImageAsset(name: "Screen Shot 2018-09-04 at 4.41.07 PM")
    }
  }
  internal enum Boarding {
    internal enum Frame {
      internal static let frame = ImageAsset(name: "frame")
    }
    internal enum First {
      internal static let alexandra1 = ImageAsset(name: "Alexandra1")
      internal static let benteStumpel1 = ImageAsset(name: "BenteStumpel1")
      internal static let claraVulpisi1 = ImageAsset(name: "ClaraVulpisi1")
      internal static let jaydenRandazzo1 = ImageAsset(name: "JaydenRandazzo1")
      internal static let jorgeSala1 = ImageAsset(name: "JorgeSala1")
      internal static let spots = DataAsset(name: "Spots")
      internal enum Users {
        internal static let alexandra = ImageAsset(name: "Alexandra")
        internal static let benteStumpel = ImageAsset(name: "BenteStumpel")
        internal static let claraVulpisi = ImageAsset(name: "ClaraVulpisi")
        internal static let jaydenRandazzo = ImageAsset(name: "JaydenRandazzo")
        internal static let jorgeSala = ImageAsset(name: "JorgeSala")
      }
    }
    internal enum Locations {
      internal static let location1 = ImageAsset(name: "location1")
      internal static let location10 = ImageAsset(name: "location10")
      internal static let location11 = ImageAsset(name: "location11")
      internal static let location12 = ImageAsset(name: "location12")
      internal static let location13 = ImageAsset(name: "location13")
      internal static let location14 = ImageAsset(name: "location14")
      internal static let location15 = ImageAsset(name: "location15")
      internal static let location16 = ImageAsset(name: "location16")
      internal static let location17 = ImageAsset(name: "location17")
      internal static let location18 = ImageAsset(name: "location18")
      internal static let location19 = ImageAsset(name: "location19")
      internal static let location2 = ImageAsset(name: "location2")
      internal static let location20 = ImageAsset(name: "location20")
      internal static let location21 = ImageAsset(name: "location21")
      internal static let location3 = ImageAsset(name: "location3")
      internal static let location4 = ImageAsset(name: "location4")
      internal static let location5 = ImageAsset(name: "location5")
      internal static let location6 = ImageAsset(name: "location6")
      internal static let location7 = ImageAsset(name: "location7")
      internal static let location8 = ImageAsset(name: "location8")
      internal static let location9 = ImageAsset(name: "location9")
    }
    internal enum Login {
      internal static let login1 = ImageAsset(name: "login1")
      internal static let login10 = ImageAsset(name: "login10")
      internal static let login11 = ImageAsset(name: "login11")
      internal static let login12 = ImageAsset(name: "login12")
      internal static let login13 = ImageAsset(name: "login13")
      internal static let login14 = ImageAsset(name: "login14")
      internal static let login15 = ImageAsset(name: "login15")
      internal static let login16 = ImageAsset(name: "login16")
      internal static let login17 = ImageAsset(name: "login17")
      internal static let login18 = ImageAsset(name: "login18")
      internal static let login19 = ImageAsset(name: "login19")
      internal static let login2 = ImageAsset(name: "login2")
      internal static let login20 = ImageAsset(name: "login20")
      internal static let login21 = ImageAsset(name: "login21")
      internal static let login22 = ImageAsset(name: "login22")
      internal static let login23 = ImageAsset(name: "login23")
      internal static let login24 = ImageAsset(name: "login24")
      internal static let login25 = ImageAsset(name: "login25")
      internal static let login26 = ImageAsset(name: "login26")
      internal static let login27 = ImageAsset(name: "login27")
      internal static let login28 = ImageAsset(name: "login28")
      internal static let login29 = ImageAsset(name: "login29")
      internal static let login3 = ImageAsset(name: "login3")
      internal static let login30 = ImageAsset(name: "login30")
      internal static let login31 = ImageAsset(name: "login31")
      internal static let login32 = ImageAsset(name: "login32")
      internal static let login33 = ImageAsset(name: "login33")
      internal static let login34 = ImageAsset(name: "login34")
      internal static let login35 = ImageAsset(name: "login35")
      internal static let login36 = ImageAsset(name: "login36")
      internal static let login37 = ImageAsset(name: "login37")
      internal static let login38 = ImageAsset(name: "login38")
      internal static let login39 = ImageAsset(name: "login39")
      internal static let login4 = ImageAsset(name: "login4")
      internal static let login40 = ImageAsset(name: "login40")
      internal static let login41 = ImageAsset(name: "login41")
      internal static let login42 = ImageAsset(name: "login42")
      internal static let login43 = ImageAsset(name: "login43")
      internal static let login44 = ImageAsset(name: "login44")
      internal static let login45 = ImageAsset(name: "login45")
      internal static let login5 = ImageAsset(name: "login5")
      internal static let login6 = ImageAsset(name: "login6")
      internal static let login7 = ImageAsset(name: "login7")
      internal static let login8 = ImageAsset(name: "login8")
      internal static let login9 = ImageAsset(name: "login9")
    }
    internal enum Second {
      internal static let users = DataAsset(name: "Users")
    }
    internal enum Third {
      internal static let people1 = ImageAsset(name: "people1")
      internal static let people10 = ImageAsset(name: "people10")
      internal static let people11 = ImageAsset(name: "people11")
      internal static let people12 = ImageAsset(name: "people12")
      internal static let people13 = ImageAsset(name: "people13")
      internal static let people14 = ImageAsset(name: "people14")
      internal static let people15 = ImageAsset(name: "people15")
      internal static let people16 = ImageAsset(name: "people16")
      internal static let people17 = ImageAsset(name: "people17")
      internal static let people18 = ImageAsset(name: "people18")
      internal static let people19 = ImageAsset(name: "people19")
      internal static let people2 = ImageAsset(name: "people2")
      internal static let people20 = ImageAsset(name: "people20")
      internal static let people21 = ImageAsset(name: "people21")
      internal static let people22 = ImageAsset(name: "people22")
      internal static let people23 = ImageAsset(name: "people23")
      internal static let people24 = ImageAsset(name: "people24")
      internal static let people25 = ImageAsset(name: "people25")
      internal static let people26 = ImageAsset(name: "people26")
      internal static let people27 = ImageAsset(name: "people27")
      internal static let people3 = ImageAsset(name: "people3")
      internal static let people4 = ImageAsset(name: "people4")
      internal static let people5 = ImageAsset(name: "people5")
      internal static let people6 = ImageAsset(name: "people6")
      internal static let people7 = ImageAsset(name: "people7")
      internal static let people8 = ImageAsset(name: "people8")
      internal static let people9 = ImageAsset(name: "people9")
    }
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct DataAsset {
  internal fileprivate(set) var name: String

  #if os(iOS) || os(tvOS) || os(macOS)
  @available(iOS 9.0, macOS 10.11, *)
  internal var data: NSDataAsset {
    return NSDataAsset(asset: self)
  }
  #endif
}

#if os(iOS) || os(tvOS) || os(macOS)
@available(iOS 9.0, macOS 10.11, *)
internal extension NSDataAsset {
  convenience init!(asset: DataAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(name: asset.name, bundle: bundle)
    #elseif os(macOS)
    self.init(name: NSDataAsset.Name(asset.name), bundle: bundle)
    #endif
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image named \(name).")
    }
    return result
  }
}

internal extension ImageAsset.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
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
