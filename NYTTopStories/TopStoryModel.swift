//
//  TopStoryModel.swift
//  NYTTopStories
//
//  Created by Bhaskar Ghosh on 9/14/20.
//  Copyright © 2020 Bhaskar Ghosh. All rights reserved.
//

import Foundation

struct TopStory: Codable, Hashable {
    var section: String?
    var results: [TopStoryResult]?
    
    init(section: String?, results: [TopStoryResult]?) {
        self.section = section
        self.results = results
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    private let identifier = "sec\(UUID())"
}

struct TopStoryResult: Codable, Hashable {
    var section: String?
    var title: String?
    var abstract: String?
    var url: String?
    var byline: String?
    var updated_date: String?
    var created_date: String?
    var published_date: String?
    var des_facet: [String]?
    var geo_facet: [String]?
    var multimedia: [TopStoryMultimedia]?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(resultId)
    }
    
    private let resultId = "res\(UUID())"
}

struct TopStoryMultimedia: Codable, Hashable {
    var url: String?
    var height: Int?
    var width: Int?
    var type: String?
    var caption: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(multimediaID)
    }
    
    private let multimediaID = "multi\(UUID())"
}
