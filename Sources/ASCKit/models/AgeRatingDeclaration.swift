import Foundation

public struct AgeRatingDeclaration: IdentifiableModel {
    public var id: String
    public var type: String
    public var attributes: Attributes

    public var name: String {
        id
    }
}

public extension AgeRatingDeclaration {

    enum KidsAgeBand: String, CaseIterable, Model {
        case fiveAndUnder = "FIVE_AND_UNDER"
        case sixToEight = "SIX_TO_EIGHT"
        case nineToEleven = "NINE_TO_ELEVEN"
    }

    enum AgeRatingOverrideValue: String, CaseIterable, Model {
        case none = "NONE"
        case ninePlus = "NINE_PLUS"
        case thirteenPlus = "THIRTEEN_PLUS"
        case sixteenPlus = "SIXTEEN_PLUS"
        case eighteenPlus = "EIGHTEEN_PLUS"
        case unrated = "UNRATED"
    }

    enum KoreaAgeRatingOverrideValue: String, CaseIterable, Model {
        case none = "NONE"
        case fifteenPlus = "FIFTEEN_PLUS"
        case nineteenPlus = "NINETEEN_PLUS"
    }

    enum Frequency: String, CaseIterable, Model {
        case none = "NONE"
        case infrequentOrMild = "INFREQUENT_OR_MILD"
        case frequentOrIntense = "FREQUENT_OR_INTENSE"
        case infrequent = "INFREQUENT"
        case frequent = "FREQUENT"
    }

    struct Attributes: Model {
        public var alcoholTobaccoOrDrugUseOrReferences: Frequency?
        public var kidsAgeBand: KidsAgeBand?
        public var medicalOrTreatmentInformation: Frequency?
        public var profanityOrCrudeHumor: Frequency?
        public var sexualContentOrNudity: Frequency?
        public var unrestrictedWebAccess: Bool?
        public var gamblingSimulated: Frequency?
        public var horrorOrFearThemes: Frequency?
        public var matureOrSuggestiveThemes: Frequency?
        public var sexualContentGraphicAndNudity: Frequency?
        public var violenceCartoonOrFantasy: Frequency?
        public var violenceRealistic: Frequency?
        public var violenceRealisticProlongedGraphicOrSadistic: Frequency?
        public var contests: Frequency?
        public var gambling: Bool?
        public var advertising: Bool?
        public var ageAssurance: Bool?
        public var ageRatingOverrideV2: AgeRatingOverrideValue?
        public var developerAgeRatingInfoUrl: URL?
        public var gunsOrOtherWeapons: Frequency?
        public var healthOrWellnessTopics: Bool?
        public var koreaAgeRatingOverride: KoreaAgeRatingOverrideValue?
        public var lootBox: Bool?
        public var messagingAndChat: Bool?
        public var parentalControls: Bool?
        public var userGeneratedContent: Bool?
    }
}
