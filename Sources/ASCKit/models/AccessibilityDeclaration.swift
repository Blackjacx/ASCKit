import Foundation

public struct AccessibilityDeclaration: IdentifiableModel {
    public var id: String
    public var type: String
    public var attributes: Attributes

    public var name: String {
        id
    }
}

public extension AccessibilityDeclaration {

    enum DeviceFamily: String, CaseIterable, Model {
        case iPhone = "IPHONE"
        case iPad = "IPAD"
        case tv = "APPLE_TV"
        case watch = "APPLE_WATCH"
        case mac = "MAC"
        case vision = "VISION"
    }

    enum State: String, CaseIterable, Model {
        case draft = "DRAFT"
        case published = "PUBLISHED"
        case replaced = "REPLACED"
    }

    struct Attributes: Model {
        public var deviceFamily: DeviceFamily
        public var state: State
        public var supportsAudioDescriptions: Bool
        public var supportsCaptions: Bool
        public var supportsDarkInterface: Bool
        public var supportsDifferentiateWithoutColorAlone: Bool
        public var supportsLargerText: Bool
        public var supportsReducedMotion: Bool
        public var supportsSufficientContrast: Bool
        public var supportsVoiceControl: Bool
        public var supportsVoiceover: Bool
    }

    enum FilterKey: String, Model {
        /// Possible values, see ``DeviceFamily``
        case deviceFamily
        /// Possible values, see ``State``
        case state
    }
}

public extension Array where Element == AccessibilityDeclaration {

    func out(_ attribute: String?) {
        switch attribute {
        case "id": out(\.id, attribute: attribute)
        case "attributes": out(\.attributes, attribute: attribute)
        default: out()
        }
    }
}
