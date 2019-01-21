//
//  ViewController.swift
//  TwitterCheckApp
//
//  Created by Patryk Aloueichek on 12/01/2019.
//  Copyright © 2019 Patryk Aloueichek. All rights reserved.
//

import UIKit
import WebKit

struct TwitterConstants {
    static let baseUrl = "https://api.twitter.com/"
}

class ViewController: UIViewController, WKNavigationDelegate  {
    
    var webView: WKWebView!
    var oauth: OAuth1aParameters!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
      
        webView.allowsBackForwardNavigationGestures = true
        requestToken()
    }

    private func requestToken() {
        let url = TwitterConstants.baseUrl + "oauth/request_token"
        let accessToken = AccessToken(token: "725257982766931969-HZsWzQvWf9ee2HUJlrft826w4fsX0Xi",
                                      secret: "eqS6jiPtQkBnBZvBcgGWZeLPI99WAOdtbcMq2Vlj8ZHDT")
        self.oauth = OAuth1aParameters(consumerKey: "gtcjwPuDs3uLdeX5dnfCF8lm9", consumerSecret: "TDmJBnyVVrrvDxZIncuSnIkRWcdV7WTlLLJG01hYypJYjaR8z3", accessToken: accessToken, callBack: nil, method: "POST", url: url, postParams: nil)
        oauth.oAuthSign { [weak self] getToken in
            
             let url = TwitterConstants.baseUrl + "oauth/authenticate?" + getToken
            self?.webView.load(URLRequest(url: URL(string: url)!))
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        oauth.getOAuthToken(input: webView.url!)
        
    }
}
