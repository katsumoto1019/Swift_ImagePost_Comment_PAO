// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSColor
  internal typealias Color = NSColor
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIColor
  internal typealias Color = UIColor
#endif

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Colors

// swiftlint:disable identifier_name line_length type_body_length
internal struct ColorName {
  internal let rgbaValue: UInt32
  internal var color: Color { return Color(named: self) }

  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#00ffc0"></span>
  /// Alpha: 100% <br/> (0x00ffc0ff)
  internal static let accent = ColorName(rgbaValue: 0x00ffc0ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#000000"></span>
  /// Alpha: 85% <br/> (0x000000d9)
  internal static let alertOVerlayBacoground = ColorName(rgbaValue: 0x000000d9)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#000000"></span>
  /// Alpha: 100% <br/> (0x000000ff)
  internal static let background = ColorName(rgbaValue: 0x000000ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#131313"></span>
  /// Alpha: 100% <br/> (0x131313ff)
  internal static let backgroundDark = ColorName(rgbaValue: 0x131313ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#3a3a3a"></span>
  /// Alpha: 100% <br/> (0x3a3a3aff)
  internal static let backgroundHighlight = ColorName(rgbaValue: 0x3a3a3aff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#202020"></span>
  /// Alpha: 100% <br/> (0x202020ff)
  internal static let backgroundOld = ColorName(rgbaValue: 0x202020ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#40c99d"></span>
  /// Alpha: 100% <br/> (0x40c99dff)
  internal static let buttonAccent = ColorName(rgbaValue: 0x40c99dff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#555555"></span>
  /// Alpha: 100% <br/> (0x555555ff)
  internal static let circleShapeLayer = ColorName(rgbaValue: 0x555555ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#000000"></span>
  /// Alpha: 80% <br/> (0x000000cc)
  internal static let coachMarksBackground = ColorName(rgbaValue: 0x000000cc)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#04d29e"></span>
  /// Alpha: 100% <br/> (0x04d29eff)
  internal static let coachMarksBorderGradientFirst = ColorName(rgbaValue: 0x04d29eff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#028e6e"></span>
  /// Alpha: 100% <br/> (0x028e6eff)
  internal static let coachMarksBorderGradientSecond = ColorName(rgbaValue: 0x028e6eff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#000000"></span>
  /// Alpha: 73% <br/> (0x000000bb)
  internal static let coachMarksPlaylistsBackground = ColorName(rgbaValue: 0x000000bb)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ffffe6"></span>
  /// Alpha: 100% <br/> (0xffffe6ff)
  internal static let defaultiOSPlaceholder = ColorName(rgbaValue: 0xffffe6ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#2c2c2c"></span>
  /// Alpha: 100% <br/> (0x2c2c2cff)
  internal static let emojiButtonBackground = ColorName(rgbaValue: 0x2c2c2cff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#206755"></span>
  /// Alpha: 100% <br/> (0x206755ff)
  internal static let emojiButtonSelectedBackground = ColorName(rgbaValue: 0x206755ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#01a883"></span>
  /// Alpha: 100% <br/> (0x01a883ff)
  internal static let gradientBottom = ColorName(rgbaValue: 0x01a883ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#00ffc0"></span>
  /// Alpha: 100% <br/> (0x00ffc0ff)
  internal static let gradientTop = ColorName(rgbaValue: 0x00ffc0ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#363636"></span>
  /// Alpha: 100% <br/> (0x363636ff)
  internal static let grayBorder = ColorName(rgbaValue: 0x363636ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#019671"></span>
  /// Alpha: 100% <br/> (0x019671ff)
  internal static let greenAlertGradinentEnd = ColorName(rgbaValue: 0x019671ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#03d5a1"></span>
  /// Alpha: 100% <br/> (0x03d5a1ff)
  internal static let greenAlertGradinentStart = ColorName(rgbaValue: 0x03d5a1ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ffffff"></span>
  /// Alpha: 100% <br/> (0xffffffff)
  internal static let navigationBarText = ColorName(rgbaValue: 0xffffffff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#111111"></span>
  /// Alpha: 100% <br/> (0x111111ff)
  internal static let navigationBarTint = ColorName(rgbaValue: 0x111111ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#272727"></span>
  /// Alpha: 100% <br/> (0x272727ff)
  internal static let navigationBarTintOld = ColorName(rgbaValue: 0x272727ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#acacac"></span>
  /// Alpha: 100% <br/> (0xacacacff)
  internal static let permissionAlertButton = ColorName(rgbaValue: 0xacacacff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#8e8d8d"></span>
  /// Alpha: 100% <br/> (0x8e8d8dff)
  internal static let placeholder = ColorName(rgbaValue: 0x8e8d8dff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#111111"></span>
  /// Alpha: 100% <br/> (0x111111ff)
  internal static let pulsatingLayer = ColorName(rgbaValue: 0x111111ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#0ca27d"></span>
  /// Alpha: 100% <br/> (0x0ca27dff)
  internal static let reachabilityMessageView = ColorName(rgbaValue: 0x0ca27dff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#02a179"></span>
  /// Alpha: 100% <br/> (0x02a179ff)
  internal static let reactionTextBackground = ColorName(rgbaValue: 0x02a179ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#eb302a"></span>
  /// Alpha: 100% <br/> (0xeb302aff)
  internal static let redText = ColorName(rgbaValue: 0xeb302aff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#272727"></span>
  /// Alpha: 100% <br/> (0x272727ff)
  internal static let textDarkGray = ColorName(rgbaValue: 0x272727ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#b6b6b6"></span>
  /// Alpha: 100% <br/> (0xb6b6b6ff)
  internal static let textEmptyView = ColorName(rgbaValue: 0xb6b6b6ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#7f7f7f"></span>
  /// Alpha: 100% <br/> (0x7f7f7fff)
  internal static let textGray = ColorName(rgbaValue: 0x7f7f7fff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#aaaaaa"></span>
  /// Alpha: 100% <br/> (0xaaaaaaff)
  internal static let textLightGray = ColorName(rgbaValue: 0xaaaaaaff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ffffff"></span>
  /// Alpha: 100% <br/> (0xffffffff)
  internal static let textWhite = ColorName(rgbaValue: 0xffffffff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#333333"></span>
  /// Alpha: 100% <br/> (0x333333ff)
  internal static let trackLayer = ColorName(rgbaValue: 0x333333ff)
}
// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

internal extension Color {
  convenience init(rgbaValue: UInt32) {
    let components = RGBAComponents(rgbaValue: rgbaValue).normalized
    self.init(red: components[0], green: components[1], blue: components[2], alpha: components[3])
  }
}

private struct RGBAComponents {
  let rgbaValue: UInt32

  private var shifts: [UInt32] {
    [
      rgbaValue >> 24, // red
      rgbaValue >> 16, // green
      rgbaValue >> 8,  // blue
      rgbaValue        // alpha
    ]
  }

  private var components: [CGFloat] {
    shifts.map {
      CGFloat($0 & 0xff)
    }
  }

  var normalized: [CGFloat] {
    components.map { $0 / 255.0 }
  }
}

internal extension Color {
  convenience init(named color: ColorName) {
    self.init(rgbaValue: color.rgbaValue)
  }
}
