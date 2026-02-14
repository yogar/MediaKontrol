import CoreGraphics

enum NXKeyType {
    static let play: Int32 = 16
    static let next: Int32 = 17
    static let previous: Int32 = 18
    // Not used for interception but documented for completeness
    static let soundUp: Int32 = 0
    static let soundDown: Int32 = 1
    static let mute: Int32 = 7
}

enum BundleID {
    static let spotify = "com.spotify.client"
}

enum MediaKeyConstants {
    static let systemDefinedEventSubtype: Int64 = 8
    static let defaultVolumeStep = 6
    static let volumeMin = 0
    static let volumeMax = 100
}
