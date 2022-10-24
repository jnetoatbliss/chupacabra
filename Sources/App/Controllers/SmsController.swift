//
//  SmsController.swift
//  
//
//  Created by José Neto on 23/10/2022.
//

import Foundation
import SwifterSwift
import Vapor
import Kanna

struct SmsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("sms", use: sms)
    }

    func sms(req: Request) throws -> EventLoopFuture<Response> {
        let url: URI = URI(string: "https://ql-digi9-tkns.azurewebsites.net/Sms")
        var returnItems: [Sms] = []

        return req.client.get(url).flatMap { res in
            do {
                if let body = res.body {
                    if let bytesBuffer: Data = body.getData(at: 0, length: body.readableBytes) {
                        let content = try? HTML(html: bytesBuffer, encoding: .utf8)

                        for i in 1...10 {
                            var currentItem: Sms = Sms()
                            let path: String = "/html/body/div/main/table/tbody/tr[\(i.string)]/"
                            for j in 1...2 {
                                let rowItem: String = path + "td[\(j.string)]"
                                var phoneNumber = content?.at_xpath(rowItem)?.text
                                phoneNumber = phoneNumber?.replacingOccurrences(of: "\n", with: "")
                                phoneNumber = phoneNumber?.replacingOccurrences(of: "\r", with: "")
                                phoneNumber?.trim()

                                if j == 1 {
                                    currentItem.phoneNumber = phoneNumber
                                } else {
                                    currentItem.otpCode = phoneNumber
                                    returnItems.append(currentItem)
                                }
                            }
                        }
                    }
                }
                
                var bodyData: Data
                if let phoneNumber: String = try req.query.get(String?.self, at: "phoneNumber") {
                    let sms = returnItems.first { item in
                        item.phoneNumber == phoneNumber
                    }
                    bodyData = try JSONEncoder().encode(sms)
                } else {
                    bodyData = try JSONEncoder().encode(returnItems)
                }
                
                let response = Response(status: .ok)
                response.body = Response.Body(data: bodyData)
                response.headers.add(name: "Content-Type", value: "application/json")
                let promise = req.eventLoop.makePromise(of: Response.self)
                promise.succeed(response)
                return promise.futureResult
            } catch {
                return req.eventLoop.makeFailedFuture(error)
            }
        }
    }
}
