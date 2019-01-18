//
//  ViewController.swift
//  TwitterCheckApp
//
//  Created by Patryk Aloueichek on 12/01/2019.
//  Copyright © 2019 Patryk Aloueichek. All rights reserved.
//

import UIKit

struct TwitterConstants {
    static let baseUrl = "https://api.twitter.com/"
}
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        requestToken()
    }

    private func requestToken() {

        let cc = (key: "gtcjwPuDs3uLdeX5dnfCF8lm9", secret: "TDmJBnyVVrrvDxZIncuSnIkRWcdV7WTlLLJG01hYypJYjaR8z3")
        let uc = (key: "725257982766931969-HZsWzQvWf9ee2HUJlrft826w4fsX0Xi", secret: "eqS6jiPtQkBnBZvBcgGWZeLPI99WAOdtbcMq2Vlj8ZHDT")
        
        var req = URLRequest(url: URL(string: "https://api.twitter.com/oauth/request_token")!)
        req.oAuthSign(method: "POST", urlFormParameters: [:], consumerCredentials: cc, userCredentials: uc)
        
        let task = URLSession(configuration: .ephemeral).dataTask(with: req) { (data, response, error) in
            if let error = error {
                print(error)
            
                
            }
            else if let data = data {
                print(String(data: data, encoding: .utf8) ?? "Does not look like a utf8 response :(")
            }
        }.resume()
        
        
        // 2
//        let url = TwitterConstants.baseUrl + "oauth/request_token"
//        let accessToken = AccessToken(token: "725257982766931969-HZsWzQvWf9ee2HUJlrft826w4fsX0Xi",
//                                      secret: "eqS6jiPtQkBnBZvBcgGWZeLPI99WAOdtbcMq2Vlj8ZHDT")
//        let oauthParams = OAuth1aParameters(consumerKey: "gtcjwPuDs3uLdeX5dnfCF8lm9", consumerSecret: "TDmJBnyVVrrvDxZIncuSnIkRWcdV7WTlLLJG01hYypJYjaR8z3", accessToken: accessToken, callBack: "twittersdk://callback", method: "POST", url: url, postParams: nil)
//        oauthParams.oAuthSign()
        

    }
}

