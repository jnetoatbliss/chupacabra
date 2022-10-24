//
//  File.swift
//  
//
//  Created by José Neto on 23/10/2022.
//

import Foundation
import Vapor

struct Sms: Content {
    var phoneNumber: String?
    var otpCode: String?

    init() {
        phoneNumber = nil
        otpCode = nil
    }
}
