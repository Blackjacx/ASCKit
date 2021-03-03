//
//  BetaTesterInvitationResponse.swift
//  ASCKit
//
//  Created by Stefan Herold on 16.11.20.
//

import Foundation

struct BetaTesterInvitationResponse: IdentifiableModel {
    var id: String
    var type: String

    public var name: String { "" }
}
