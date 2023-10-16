//
//  APIRequests.swift
//  ZaraRickAndMorty
//
//  Created by Marc on 15/10/2023.
//

import Foundation

class APIRequests {
    
    // MARK: - Fetch Characters
    static func fetchCharacters(page: Int = 1, name: String = "", status: String = "", species: String = "", type: String = "", gender: String = "", completionHandler: @escaping (APICharacterResponseInfo?, [APICharacterResponseCharacter]?) -> Void, errorHandler: @escaping (Error?) -> Void) {
        
        if let url: URL = URL(string: "https://rickandmortyapi.com/api/character/?page=\(page)&name=\(name)&status=\(status)&species=\(species)&type=\(type)&gender=\(gender)") {
            
            URLSession.shared.dataTask(
                with: url,
                completionHandler: {
                    
                    data, response, error in
                        
                    if let data: Data = data {
                        
                        do {
                            
                            let apiCharacterResponse: APICharacterResponse = try JSONDecoder().decode(APICharacterResponse.self, from: data)
                            
                            DispatchQueue.main.async(
                                execute: {
                                    
                                    completionHandler(apiCharacterResponse.info, apiCharacterResponse.results)
                                }
                            )
                        } catch let error {

                            DispatchQueue.main.async(
                                execute: {
                                    
                                    errorHandler(error)
                                }
                            )
                        }
                    } else {
                        
                        errorHandler(NSError(domain: "", code: 452, userInfo: [NSLocalizedDescriptionKey : "Invalid URL"]))
                    }
                }
            ).resume()
        } else {
            
            errorHandler(NSError(domain: "", code: 452, userInfo: [NSLocalizedDescriptionKey : "Invalid URL"]))
        }
    }
    
    static func fetchCharacters(ids: Set<Int>, completionHandler: @escaping (APICharacterResponseInfo?, [APICharacterResponseCharacter]?) -> Void, errorHandler: @escaping (Error?) -> Void) {
        
        if let url: URL = URL(string: "https://rickandmortyapi.com/api/character/\(ids.map({id in return "\(id),"}).joined())") {
            
            URLSession.shared.dataTask(
                with: url,
                completionHandler: {
                    
                    data, response, error in
                        
                    if let data: Data = data {
                        
                        do {
                            
                            let characters: [APICharacterResponseCharacter] = try JSONDecoder().decode([APICharacterResponseCharacter].self, from: data)
                            
                            DispatchQueue.main.async(
                                execute: {
                                    
                                    completionHandler(nil, characters)
                                }
                            )
                        } catch let error {

                            DispatchQueue.main.async(
                                execute: {
                                    
                                    errorHandler(error)
                                }
                            )
                        }
                    }
                }
            ).resume()
        } else {
            
            errorHandler(NSError(domain: "", code: 452, userInfo: [NSLocalizedDescriptionKey : "Invalid URL"]))
        }
    }
}
