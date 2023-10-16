//
//  ZaraRickAndMortyTests.swift
//  ZaraRickAndMortyTests
//
//  Created by Marc on 09/10/2023.
//

import XCTest
@testable import ZaraRickAndMorty

class ViewControllerTests: XCTestCase {
    
    var viewController: ViewController!

    override func setUpWithError() throws {
        
        super.setUp()
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ViewController")
        viewController.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {

        viewController = nil
        super.tearDown()
    }

    func testShowBookmarkedCharactersOnly() throws {
        
        viewController.filterSelectedScope = .name
        viewController.filterName = "Rick"
        
        viewController.showBookmarkedCharactersOnly = true
        viewController.searchBar.showsBookmarkButton = true
        //XCTAssertEqual(viewController.searchBar.searchTextField.rightView?.tintColor, #colorLiteral(red: 1, green: 0.5960784314, blue: 0, alpha: 1))
        XCTAssertEqual(viewController.searchBar.text,  "")
        XCTAssertEqual(viewController.searchBar.placeholder, "Bookmarked characters")
        
        viewController.showBookmarkedCharactersOnly = false
        //XCTAssertEqual(viewController.searchBar.searchTextField.rightView?.tintColor, #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1))
        XCTAssertEqual(viewController.searchBar.placeholder, "Name")
        XCTAssertEqual(viewController.searchBar.text, "Rick")
    }
    
    func testPaginationButton() throws {
        
        viewController.currentPage = 3
        viewController.charactersInfo = APICharacterResponseInfo(count: 50, pages: 5, next: "https://rickandmortyapi.com/api/character/?page=4", prev: "https://rickandmortyapi.com/api/character/?page=2")
        
        viewController.previousPageButtonAction(0)
        XCTAssertEqual(viewController.currentPage, 2)
        
        viewController.nextPageButtonAction(0)
        XCTAssertEqual(viewController.currentPage, 3)
        
        viewController.firstPageButtonAction(0)
        XCTAssertEqual(viewController.currentPage, 1)
        
        viewController.lastPageButtonAction(0)
        XCTAssertEqual(viewController.currentPage, 5)
    }
    
    func testHandleScopeSelection() throws {
        
        viewController.filterName = "Rick"
        
        viewController.handleScopeSelection(selectedScope: .name)
        XCTAssertEqual(viewController.searchBar.placeholder, "Name")
        XCTAssertEqual(viewController.searchBar.text, "Rick")
    }
    
    func testGetCharacters() throws {
        
        viewController.showBookmarkedCharactersOnly = false
        viewController.getCharacters(
            completionHandler: {
                
                info, characters in
            
                XCTAssertTrue(characters?.count ?? 0 > 0)
            }
        )
    }
    
    func testHandlePagination() throws {
        
        viewController.handlePagination(currentPage: 1, pages: 5)
        XCTAssertFalse(viewController.firstPageButton.isEnabled)
        XCTAssertFalse(viewController.previousPageButton.isEnabled)
        XCTAssertTrue(viewController.nextPageButton.isEnabled)
        XCTAssertTrue(viewController.lastPageButton.isEnabled)
        
        viewController.handlePagination(currentPage: 3, pages: 5)
        XCTAssertTrue(viewController.firstPageButton.isEnabled)
        XCTAssertTrue(viewController.previousPageButton.isEnabled)
        XCTAssertTrue(viewController.nextPageButton.isEnabled)
        XCTAssertTrue(viewController.lastPageButton.isEnabled)
        
        viewController.handlePagination(currentPage: 5, pages: 5)
        XCTAssertTrue(viewController.firstPageButton.isEnabled)
        XCTAssertTrue(viewController.previousPageButton.isEnabled)
        XCTAssertFalse(viewController.nextPageButton.isEnabled)
        XCTAssertFalse(viewController.lastPageButton.isEnabled)
    }
}
