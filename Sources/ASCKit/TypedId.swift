// MARK: - ID Type

/// Used to access resources by different kinds of IDs.
///
/// For example you can list all ``AppInfo`` objects for an app by specifying
/// `appId:<app-id>` or you can fetch one specific using
/// `appInfoId:<app-info-id>`.
public enum TypedId: CustomStringConvertible, CaseIterable {
    case appId(String)
    case appInfoId(String)

    // Required for ArgumentParser help output
    public var description: String {
        switch self {
        case .appId(let id):
            "appId:\(id)"
        case .appInfoId(let id):
            "apInfoId:\(id)"
        }
    }

    // CaseIterable

    public static var allCases: [TypedId] {
        [.appId("<dummy-id>"), .appInfoId("<dummy-id>")]
    }

    // ExpressibleByArgument

    public init?(argument: String) {
        // 1. Split the argument by the first colon to separate the case
        // name from the value.
        let comps = argument.split(
            separator: ":",
            maxSplits: 1,
            omittingEmptySubsequences: false
        )
        let caseName = comps[0]
        let associatedValue = comps.count > 1 ? String(comps[1]) : nil

        switch caseName {
        case "appId":
            // Associated value is expected to be an ID (String)
            guard let id = associatedValue, !id.isEmpty else { return nil }
            self = .appId(id)

        case "appInfoId":
            // Associated value is expected to be an ID (String)
            guard let id = associatedValue, !id.isEmpty else { return nil }
            self = .appInfoId(id)

        default:
            // Input does not match any known enum case
            return nil
        }
    }
}
