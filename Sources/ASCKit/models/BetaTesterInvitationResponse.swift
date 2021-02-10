//
//  BetaTesterInvitationResponse.swift
//  ASCKit
//
//  Created by Stefan Herold on 16.11.20.
//

import Foundation

struct BetaTesterInvitationResponse: Model {
    var id: String
    var type: String
}

extension BetaTesterInvitationResponse: IdentifiableModel {
    public var name: String { "" }
}
