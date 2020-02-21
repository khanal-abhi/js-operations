//
//  JumboMessage.swift
//  JSOperations
//
//  Created by Abhinash Khanal on 2/21/20.
//  Copyright © 2020 abhinash.com. All rights reserved.
//

/// Domain model for JumboMessage
struct JumboMessage: Encodable, Decodable {
    
    var id: String
    var message: String
    var progress: Int?
    var state: String?
    
    init(id: String, message: String, progress: Int?, state: String?) {
        self.id = id
        self.message = message
        self.progress = progress
        self.state = state
    }
    
    init(id: String, message: String) {
        self.id = id
        self.message = message
    }
    
    
    /// Decode json data to JumboMessage
    /// - Parameter decoder: JsonDecoder
    init(from decoder: Decoder) throws {
        let allValues = try decoder.container(keyedBy: CodingKeys.self)
        // The contract said that id was of String type, so doing manual
        // decoding since the message returns a number instead of a string
        // {"id":4,"message":"progress","progress":0} - Was a payload
        let _id = try allValues.decode(Int.self, forKey: .id)
        id = "\(_id)"
        message = try allValues.decode(String.self, forKey: .message)
        progress = try? allValues.decode(Int?.self, forKey: .progress)
        state = try? allValues.decode(String?.self, forKey: .state)
    }
}
