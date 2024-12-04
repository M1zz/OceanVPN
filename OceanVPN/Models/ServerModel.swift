//
//  ServerModel.swift
//  VigilSecVPN
//
//  Created by hyunho lee on 10/2/23.
//

import CoreData
import ParseSwift
import Foundation

/// A model to represent a server
struct ServerModel {
    let countryId: Int
    let address: String
    let password: String
    let username: String
    let preSharedKey: String

    /// Check if the model is valid
    var isValid: Bool {
        !address.trimmingCharacters(in: .whitespaces).isEmpty
        && !password.trimmingCharacters(in: .whitespaces).isEmpty
        && !username.trimmingCharacters(in: .whitespaces).isEmpty
        && !preSharedKey.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

/// Build a server model from CoreData entity
extension ServerModel {

    /// Build a server model from entity
    /// - Parameter entity: CoreData entity
    /// - Returns: returns the model if possible
    static func from(_ entity: ServerEntity) -> ServerModel? {
        guard let address = entity.address, let username = entity.username,
              let password = entity.password, let psk = entity.preSharedKey
        else { return nil }
        return .init(countryId: 0, address: address, password: password, username: username, preSharedKey: psk)
    }
}

/// VPNServer - parse object
struct VPNServer: ParseObject {
    var originalData: Data?
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseSwift.ParseACL?
    var countryId: Int?
    var address: String?
    var username: String?
    var password: String?
    var preSharedKey: String?

    /// ServerModel - local object
    var model: ServerModel? {
        guard let id = countryId, let server = address,
              let name = username, let psk = preSharedKey, let vpnPassword = password
        else { return nil }
        return .init(countryId: id, address: server, password: vpnPassword, username: name, preSharedKey: psk)
    }
}
