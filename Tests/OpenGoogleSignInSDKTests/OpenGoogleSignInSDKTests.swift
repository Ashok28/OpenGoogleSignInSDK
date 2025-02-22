import XCTest
@testable import OpenGoogleSignInSDK

final class OpenGoogleSignInTests: XCTestCase {
    var sharedInstance: OpenGoogleSignIn!
    var mockDelegate: MockOpenGoogleSignInDelegate!
    var session: MockURLSession!
    
    override func setUp() {
        super.setUp()

        sharedInstance = OpenGoogleSignIn.shared
        
        mockDelegate = MockOpenGoogleSignInDelegate(testCase: self)
        sharedInstance.delegate = mockDelegate
        
        session = MockURLSession()
    }
    
    override func tearDown() {
        session = nil

        super.tearDown()
    }
    
    func test_invalidCodeError_isThrown() {
        // Given
        let url = URL(string: "https://google.com")!
        mockDelegate.expectSignInFinish()
        
        // When
        sharedInstance.handle(url)
        waitForExpectations(timeout: 0.5)
        
        // Then
        XCTAssertEqual(mockDelegate.error, GoogleSignInError.invalidCode)
        XCTAssertNil(mockDelegate.user)
    }
    
    func test_invalidResponseError_isThrown() {
        // Given
        let url = URL(string: "https://google.com?code=1234")!
        mockDelegate.expectSignInFinish()
        session.data = nil
        sharedInstance.session = session
        
        // When
        sharedInstance.handle(url)
        waitForExpectations(timeout: 0.5)

        // Then
        XCTAssertEqual(mockDelegate.error, GoogleSignInError.invalidResponse)
        XCTAssertNil(mockDelegate.user)
    }
    
    func test_validUserIsReceived() {
        // Given
        let url = URL(string: "https://google.com?code=1234")!
        mockDelegate.expectSignInFinish()
        
        let user = mockUser()
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(user) else { return }
        
        session.data = data
        sharedInstance.session = session
    
        // When
        sharedInstance.handle(url)
        waitForExpectations(timeout: 0.5)
        
        // Then
        XCTAssertNil(mockDelegate.error)
        XCTAssertNotNil(mockDelegate.user)
    }
    
    // MARK: - Private helpers
    
    private func mockUser() -> GoogleUser {
        GoogleUser(
            accessToken: "accessToken",
            expiresIn: 3600,
            idToken: "idToken",
            refreshToken: "refreshToken",
            scope: "scope",
            tokenType: "tokenType"
        )
    }
}
