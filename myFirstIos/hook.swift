//
//  hook.swift
//  myFirstIos
//
//  Created by 김명준 on 11/14/23.
//

import Foundation
import Alamofire

class hook: ObservableObject {
    init() {
        fetchTodos()
    }
    
    func fetchTodos() {
        let url = "https://let.team-alt.com/api/openapi/meal?date=20230824"
        AF.request(url).response { response in
            debugPrint("Response: \(response)")
        }
    }
}
