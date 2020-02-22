//
//  JumboMessage.swift
//  JSOperations
//
//  Created by Abhinash Khanal on 2/21/20.
//  Copyright © 2020 abhinash.com. All rights reserved.
//

/// Domain model for JumboMessage
struct JumboMessage: Codable {
    
    var id: Int
    var message: String
    var progress: Int?
    var state: String?
    
    init(id: Int, message: String, progress: Int? = nil, state: String? = nil) {
        self.id = id
        self.message = message
        self.progress = progress
        self.state = state
    }
}
