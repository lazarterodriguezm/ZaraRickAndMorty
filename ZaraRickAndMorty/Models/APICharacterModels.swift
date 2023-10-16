//
//  APICharacterModels.swift
//  ZaraRickAndMorty
//
//  Created by Marc on 15/10/2023.
//

// MARK: - APICharacterResponse
struct APICharacterResponse: Codable {
    
    let info: APICharacterResponseInfo?
    let results: [APICharacterResponseCharacter]?
}

// MARK: - Info
struct APICharacterResponseInfo: Codable {
    
    let count: Int?
    let pages: Int?
    let next: String?
    let prev: String?
}

// MARK: - Character
struct APICharacterResponseCharacter: Codable {
    
    let id: Int?
    let name: String?
    let status: APICharacterResponseStatus?
    let species: String?
    let type: String?
    let gender: APICharacterResponseGender?
    let origin: APICharacterResponseLocation?
    let location: APICharacterResponseLocation?
    let image: String?
    let episode: [String]?
    let url: String?
    let created: String?
}

// MARK: - Gender
enum APICharacterResponseGender: String, Codable {
    
    case male = "Male"
    case female = "Female"
    case genderless = "Genderless"
    case unknown = "unknown"
}

// MARK: - Location
struct APICharacterResponseLocation: Codable {
    
    let name: String?
    let url: String?
}

// MARK: - Status
enum APICharacterResponseStatus: String, Codable {
    
    case alive = "Alive"
    case dead = "Dead"
    case unknown = "unknown"
}

