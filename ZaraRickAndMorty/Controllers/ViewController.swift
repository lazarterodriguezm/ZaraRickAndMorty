    //
    //  ViewController.swift
    //  ZaraRickAndMorty
    //
    //  Created by Marc on 09/10/2023.
    //

    import Foundation
    import UIKit
    import CoreData

    enum FilterScope: Int {
        
        case name
        case status
        case species
        case type
        case gender
    }

    class ViewController: UIViewController {
        
        // MARK: - IBOutlets
        @IBOutlet weak var searchBar: UISearchBar!
        @IBOutlet weak var tableView: UITableView!
        @IBOutlet weak var progressView: UIProgressView!
        @IBOutlet weak var firstPageButton: UIButton!
        @IBOutlet weak var previousPageButton: UIButton!
        @IBOutlet weak var nextPageButton: UIButton!
        @IBOutlet weak var lastPageButton: UIButton!
        
        // MARK: - API fetched variables
        var characters: [APICharacterResponseCharacter]?
        var charactersInfo: APICharacterResponseInfo?
        
        // MARK: - Filter variables
        var filterSelectedScope: FilterScope = .name
        var filterName: String = ""
        var filterStatus: String = ""
        var filterSpecies: String = ""
        var filterType: String = ""
        var filterGender: String = ""

        // MARK: - Persistent Variables
        var currentPage: Int = 1 {
            
            didSet {
                
                PersistentContainer.saveAppData(
                    value: currentPage,
                    key: "currentPage",
                    errorHandler: {
                    
                        error in
                    
                        self.present(UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert), animated: true)
                    }
                )
            }
        }
        
        var showBookmarkedCharactersOnly = false {
            
            didSet {
                
                searchBar.searchTextField.rightView?.tintColor = showBookmarkedCharactersOnly ? #colorLiteral(red: 1, green: 0.5960784314, blue: 0, alpha: 1) : #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1)
                
                if showBookmarkedCharactersOnly {

                    searchBar.text = ""
                    searchBar.placeholder = "Bookmarked characters"
                } else {
                    
                    handleScopeSelection(selectedScope: filterSelectedScope)
                }
                
                PersistentContainer.saveAppData(
                    value: showBookmarkedCharactersOnly,
                    key: "showBookmarkedCharactersOnly",
                    errorHandler: {
                    
                        error in
                    
                        self.present(UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert), animated: true)
                    }
                )
            }
        }
        
        var bookmarkedCharactersIDs: Set<Int> = [] {
            
            didSet {
                
                PersistentContainer.saveAppData(
                    value: bookmarkedCharactersIDs,
                    key: "bookmarkedCharactersIDs",
                    errorHandler: {
                    
                        error in
                    
                        self.present(UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert), animated: true)
                    }
                )
            }
        }
        
        // MARK: - Lifecycle functions
        override func viewDidLoad() {
            
            super.viewDidLoad()
            
            searchBar.delegate = self
            
            searchBar.selectedScopeButtonIndex = filterSelectedScope.rawValue
            handleScopeSelection(selectedScope: filterSelectedScope)
            
            tableView.register(UINib(nibName: "CardTableViewCell", bundle: nil), forCellReuseIdentifier: "CardTableViewCell")
            tableView.delegate = self
            tableView.dataSource = self
            
            progressView.progress = 1.0
            
            PersistentContainer.getAppData(
                completionHandler: {
                    
                    currentPage, showBookmarkedCharactersOnly, bookmarkedCharactersIDs in
                    
                    if let currentPage = currentPage {
                        
                        self.currentPage = currentPage
                    }
                    
                    if let showBookmarkedCharactersOnly = showBookmarkedCharactersOnly {
                        
                        self.showBookmarkedCharactersOnly = showBookmarkedCharactersOnly
                    }
                    
                    if let bookmarkedCharactersIDs = bookmarkedCharactersIDs {
                        
                        self.bookmarkedCharactersIDs = bookmarkedCharactersIDs
                    }
                },
                errorHandler: {
                    
                    error in
                    
                    self.present(UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert), animated: true)
                }
            )
            
            getCharacters()
        }
        
        // MARK: - IBActions
        @IBAction func firstPageButtonAction(_ sender: Any) {
            
            currentPage = 1
            
            getCharacters()
        }
        
        @IBAction func previousPageButtonAction(_ sender: Any) {
            
            currentPage -= 1
            
            if (currentPage < 1) {
                
                currentPage = 1
            }
            
            getCharacters()
        }
        
        @IBAction func nextPageButtonAction(_ sender: Any) {
            
            if let pages = charactersInfo?.pages {
                
                currentPage += 1
                
                if (currentPage > pages) {
                    
                    currentPage = pages
                }
            }
            
            getCharacters()
        }
        
        @IBAction func lastPageButtonAction(_ sender: Any) {
            
            if let pages = charactersInfo?.pages {
                
                currentPage = pages
            }
            
            getCharacters()
        }
        
        // MARK: - Utility functions
        func handleScopeSelection(selectedScope: FilterScope) {
            
            switch selectedScope {
            
            case .name:
                
                searchBar.placeholder = "Name"
                searchBar.text = filterName
            case .status:
                
                searchBar.placeholder = "Alive, dead, unknown..."
                searchBar.text = filterStatus
            case .species:
                
                searchBar.placeholder = "Species"
                searchBar.text = filterSpecies
            case .type:
                
                searchBar.placeholder = "Type"
                searchBar.text = filterType
            case .gender:
                
                searchBar.placeholder = "Male, female, genderless, unknown..."
                searchBar.text = filterGender
            }
        }
        
        func getCharacters(completionHandler: (@escaping (APICharacterResponseInfo?, [APICharacterResponseCharacter]?) -> Void) = { _, _ in }, errorHandler: (@escaping (Error?) -> Void) = { _ in }) {
            
            if showBookmarkedCharactersOnly {
                
                if bookmarkedCharactersIDs.count > 0 {
                    
                    APIRequests.fetchCharacters(
                        ids: bookmarkedCharactersIDs,
                        completionHandler: {
                            
                            info, characters in
                        
                            self.charactersInfo = info
                            self.characters = characters
                            
                            self.handlePagination(currentPage: self.currentPage, pages: info?.pages ?? 1)
                            
                            self.tableView.reloadData()
                            
                            completionHandler(info, characters)
                        },
                        errorHandler: {
                            
                            error in
                            
                            self.present(UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert), animated: true)
                            
                            errorHandler(error)
                        }
                    )
                } else {
                    
                    // TO-DO: Add a cell that informs the user that they do not have any bookmarked character
                    
                    charactersInfo = nil
                    characters = nil
                    
                    handlePagination(currentPage: 1, pages: 1)
                    
                    tableView.reloadData()
                    
                    completionHandler(nil, nil)
                }
            } else {
                
                APIRequests.fetchCharacters(
                    page: currentPage,
                    name: filterName,
                    status: filterStatus,
                    species: filterSpecies,
                    type: filterType,
                    gender: filterGender,
                    completionHandler: {
                        
                        info, characters in
                    
                        self.charactersInfo = info
                        self.characters = characters
                        
                        self.handlePagination(currentPage: self.currentPage, pages: info?.pages ?? 1)
                        
                        self.tableView.reloadData()
                        
                        completionHandler(info, characters)
                    },
                    errorHandler: {
                        
                        error in
                        
                        self.present(UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert), animated: true)
                        
                        errorHandler(error)
                    }
                )
            }
        }
        
        func handlePagination(currentPage: Int, pages: Int) {
            
            progressView.progress = 1.0
            
            firstPageButton.isEnabled = true
            previousPageButton.isEnabled = true
            nextPageButton.isEnabled = true
            lastPageButton.isEnabled = true
            
            if currentPage == 1 {
                
                firstPageButton.isEnabled = false
                previousPageButton.isEnabled = false
            }
            
            progressView.progress = Float(self.currentPage) * 1.0 / Float(pages)
            
            if currentPage == pages {
                
                nextPageButton.isEnabled = false
                lastPageButton.isEnabled = false
            }
        }
    }

    // MARK: - SearchBar extensions
    extension ViewController: UISearchBarDelegate {
        
        func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
            
            return !showBookmarkedCharactersOnly
        }
        
        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            
            switch filterSelectedScope {
            
            case .name:
                
                filterName = searchBar.text ?? ""
            case .status:
                
                filterStatus = searchBar.text ?? ""
            case .species:
                
                filterSpecies = searchBar.text ?? ""
            case .type:
                
                filterType = searchBar.text ?? ""
            case .gender:
                
                filterGender = searchBar.text ?? ""
            }
            
            currentPage = 1
            
            getCharacters()
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            
            searchBar.endEditing(true)
        }

        func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
            
            showBookmarkedCharactersOnly = !showBookmarkedCharactersOnly
            
            getCharacters()
        }

        func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
            
            switch self.filterSelectedScope {
            
            case .name:
                
                filterName = searchBar.text ?? ""
            case .status:
                
                filterStatus = searchBar.text ?? ""
            case .species:
                
                filterSpecies = searchBar.text ?? ""
            case .type:
                
                filterType = searchBar.text ?? ""
            case .gender:
                
                filterGender = searchBar.text ?? ""
            }
            
            if let selectedScope = FilterScope(rawValue: selectedScope) {
                
                handleScopeSelection(selectedScope: selectedScope)
                
                self.filterSelectedScope = selectedScope
            }
        }
    }

    // MARK: - TableView extensions
    extension ViewController: UITableViewDelegate {
        
    }

    extension ViewController: UITableViewDataSource {
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            return characters?.count ?? 0
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cardTableViewCell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "CardTableViewCell", for: indexPath)
            
            if let cardTableViewCell: CardTableViewCell = cardTableViewCell as? CardTableViewCell, let character: APICharacterResponseCharacter = characters?[indexPath.row] {
                
                if let imageURL: String = character.image, let url: URL = URL(string: imageURL) {
                    
                    cardTableViewCell.characterImageView.setImageFrom(
                        url: url,
                        completionHandler: {
                        
                        },
                        errorHandler: {
                            
                            error in
                            
                            self.present(UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert), animated: true)
                        }
                    )
                } else {
                    
                    present(UIAlertController(title: "Error", message: String(describing: NSError(domain: "", code: 452, userInfo: [NSLocalizedDescriptionKey : "Invalid URL"])), preferredStyle: .alert), animated: true)
                }
                    
                cardTableViewCell.characterNameLabel.text = character.name ?? "Unknown"
                
                if let status = character.status {
                    
                    switch status {
                    
                    case .alive:
                        
                        cardTableViewCell.characterStatusImageView.tintColor = #colorLiteral(red: 0.3333333333, green: 0.8, blue: 0.2666666667, alpha: 1)
                    case .dead:
                        
                        cardTableViewCell.characterStatusImageView.tintColor = #colorLiteral(red: 0.8392156863, green: 0.2392156863, blue: 0.1803921569, alpha: 1)
                    case .unknown:
                        
                        cardTableViewCell.characterStatusImageView.tintColor = #colorLiteral(red: 0.6196078431, green: 0.6196078431, blue: 0.6196078431, alpha: 1)
                    }
                } else {
                    
                    cardTableViewCell.characterStatusImageView.tintColor = #colorLiteral(red: 0.6196078431, green: 0.6196078431, blue: 0.6196078431, alpha: 1)
                }
                   
                cardTableViewCell.characterStatusAndSpeciesLabel.text = "\(character.status?.rawValue ?? "Unknown") - \(character.species ?? "Unknown")"

                cardTableViewCell.characterLocationLabel.text = character.location?.name ?? "Unknown"
            
                cardTableViewCell.characterOriginLabel.text = character.origin?.name ?? "Unknown"
                
                if let id = character.id {
                    
                    cardTableViewCell.bookmarkButtonFilled = bookmarkedCharactersIDs.contains(id)
                }
                
                cardTableViewCell.bookmarkButtonActionCallback = {
                    
                    sender, filled in
                    
                    if let id = character.id {
                        
                        if filled {
                            
                            self.bookmarkedCharactersIDs.insert(id)
                        } else {
                            
                            self.bookmarkedCharactersIDs.remove(id)
                        }
                    }
                    
                    if self.showBookmarkedCharactersOnly {
                        
                        self.getCharacters()
                    }
                }
                
                cardTableViewCell.infoButtonActionCallback = {
                    
                    sender in
                    
                    let alert: UIAlertController = UIAlertController(
                        title: "ID \(character.id ?? 0) - \(character.name ?? "Unknown")",
                        message: """
                        Status: \(character.status?.rawValue ?? "Unknown")
                        Species: \(character.species ?? "Unknown")
                        Type: \(character.type ?? "Unknown")
                        Gender: \(character.gender?.rawValue ?? "Unknown")
                        Origin: \(character.origin?.name ?? "Unknown")
                        Location: \(character.location?.name ?? "Unknown")
                        Episodes: \(character.episode?.joined(separator: ", ").replacingOccurrences(of: "https://rickandmortyapi.com/api/episode/", with: "") ?? "Unknown")
                        Added to database on: \(character.created ?? "Unknown")
                        """,
                        preferredStyle: .actionSheet
                    )
                    
                    alert.addAction(
                        UIAlertAction(
                            title: "OK",
                            style: .default
                        )
                    )
                    
                    self.present(alert, animated: true)
                }
            }
            
            return cardTableViewCell
        }
    }
