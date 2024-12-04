//
//  CountryModel.swift
//  VigilSecVPN
//
//  Created by hyunho lee on 10/2/23.
//

import ParseSwift
import Foundation

/// A simple model for a country
struct CountryModel: Identifiable {
    let id: Int
    let name: String
    let flagName: String
    let isPremium: Bool
}

/// VPNCountry - parse object
struct VPNCountry: ParseObject {
    var originalData: Data?
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseSwift.ParseACL?
    var name: String?
    var flagName: String?
    var countryId: Int?
    var isPremium: Bool?

    /// CountryModel - local object
    var model: CountryModel? {
        guard let id = countryId,
                let countryName = name,
                let flag = flagName else { return nil }
        return .init(id: id, name: countryName, flagName: flag, isPremium: isPremium ?? false)
    }
}
