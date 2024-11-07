//
//  ThreadProject.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/11/07.
//

import Foundation

struct ThreadProject {
    var threadProject: [String: Any]
    
    init(threadProject: [String : Any]) {
        self.threadProject = threadProject
    }
    
    static func == (lhs: ThreadProject, rhs: ThreadProject) -> Bool {
        return NSDictionary(dictionary: lhs.threadProject).isEqual(to: rhs.threadProject)
    }
}
