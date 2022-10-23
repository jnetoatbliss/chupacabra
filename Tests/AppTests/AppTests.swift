@testable import App
import XCTVapor


final class AppTests: XCTestCase {
    var app: Application!
    var defaultHeader: HTTPHeaders!
    override func setUpWithError() throws {
            // Local
            defaultHeader = ["Content-Type": "application/json"]
            
            // App
            app = Application(.testing)
            try configure(app)
        }
        
        override func tearDown() {
            app.shutdown()
        }
    
    func testGetSms() throws {
        try app.test(.GET, "sms", headers: defaultHeader, afterResponse: { res in
            let sms = try? JSONDecoder().decode([Sms].self, from: res.body)
            XCTAssertEqual(res.status, .ok)
            XCTAssertNotNil(sms)
            XCTAssertEqual(10, sms?.count)
        })
    }
}
