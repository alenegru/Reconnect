//
//  Event.swift
//  Reconnect
//
//  Created by Alexandra Negru on 22/11/2021.
//

import Foundation
import CalendarKit


public struct Eventt : Encodable {

    let startDate: String
    let endDate: String
    let isAllDay: Bool
    let text: String
    
    enum CodingKeys: String, CodingKey {
        case startDate
        case endDate
        case isAllDay
        case text
    }

}



