//
//  TwitterCheckAppTests.swift
//  TwitterCheckAppTests
//
//  Created by Patryk Aloueichek on 12/01/2019.
//  Copyright © 2019 Patryk Aloueichek. All rights reserved.
//

import XCTest
@testable import TwitterCheckApp

class TwitterCheckAppTests: XCTestCase {

    var sut: OAuth1aParameters?

    override func setUp() {
        super.setUp()
        let url = TwitterConstants.baseUrl + "oauth/request_token"

        let accessToken = AccessToken(token: "725257982766931969-HZsWzQvWf9ee2HUJlrft826w4fsX0Xi",
                                      secret: "eqS6jiPtQkBnBZvBcgGWZeLPI99WAOdtbcMq2Vlj8ZHDT")

        sut = OAuth1aParameters(consumerKey: "gtcjwPuDs3uLdeX5dnfCF8lm9",
                                consumerSecret: "TDmJBnyVVrrvDxZIncuSnIkRWcdV7WTlLLJG01hYypJYjaR8z3",
                                accessToken: accessToken,
                                callBack: nil,
                                method: "POST",
                                url: url,
                                postParams: nil)
    }


    func testOAuthParametersSigningKey() {
        XCTAssertEqual(sut?.signingKey, "TDmJBnyVVrrvDxZIncuSnIkRWcdV7WTlLLJG01hYypJYjaR8z3&eqS6jiPtQkBnBZvBcgGWZeLPI99WAOdtbcMq2Vlj8ZHDT")
    }
}
