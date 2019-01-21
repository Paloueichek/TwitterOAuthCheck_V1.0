//
//  OAuth1aParameters.swift
//  TwitterCheckAppTests
//
//  Created by Patryk Aloueichek on 17/01/2019.
//  Copyright © 2019 Patryk Aloueichek. All rights reserved.
//


import Foundation
import WebKit

class OAuth1aParameters {
    
    private struct OAuthConstants {
        static let paramCallback = "oauth_callback"
        static let paramConsumerKey = "oauth_consumer_key"
        static let paramNonce = "oauth_nonce"
        static let paramSignature = "oauth_signature"
        static let paramSignatureMethod =  "oauth_signature_method"
        static let paramTimeStamp = "oauth_timestamp"
        static let paramAccesToken = "oauth_token"
        static let paramVersion = "oauth_version"
        
        static let signatureMethod = "HMAC-SHA1"
        static let version = "1.0"
    }
    
    var oauthToken: String?
    var consumerKey: String
    var consumerSecret: String
    var accessToken: AccessToken?
    var callBack: String?
    var method: String
    var url: String
    var postParams: [String: String]?
    
    var nonce = {
        return UUID().uuidString
    }()
    
    var timestamp = {
        return String(Int(Date().timeIntervalSince1970))
    }()
    
    lazy var authorizationHeader: String = {
        let signatureBase = constructSignatureBase(nonce: nonce, timestamp: timestamp)
        let signature = calculateSignature(signatureBase: signatureBase)
        return constructAuthorizationHeader(nonce: nonce, timestamp: timestamp, signature: signature)
    }()
    
    var signingKey: String {
        guard let accessTokenSecret = accessToken?.secret else { return "" }
        let encodedConsumerSecret = rfc3986encode(consumerSecret)
        let encodedAccessTokenSecret = rfc3986encode(accessTokenSecret)
        return  encodedConsumerSecret + "&" + encodedAccessTokenSecret
    }
    
    init(consumerKey: String,
         consumerSecret: String,
         accessToken: AccessToken,
         callBack: String?,
         method: String,
         url: String,
         postParams: [String: String]?) {
        
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        self.accessToken = accessToken
        self.callBack = callBack
        self.method = method
        self.url = url
        self.postParams = postParams
    }
    
    private func rfc3986encode(_ str: String) -> String {
        let allowed = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-._~"
        let allowedSet = CharacterSet(charactersIn: allowed)
        
        return str.addingPercentEncoding(withAllowedCharacters: allowedSet) ?? str
    }
    
    private func constructSignatureBase(nonce: String, timestamp: String) -> String {
        
        guard let uri = URL(string: url) else { return "" }
        var params = uri.queryParameters()
        
        if !params.isEmpty {
            postParams = params
        }
        
        if callBack != nil {
            params[OAuthConstants.paramCallback] = callBack
        }
        
        params[OAuthConstants.paramConsumerKey] = consumerKey
        params[OAuthConstants.paramNonce] = nonce
        params[OAuthConstants.paramSignatureMethod] = OAuthConstants.signatureMethod
        params[OAuthConstants.paramTimeStamp] = timestamp
        
        if accessToken != nil {
            params[OAuthConstants.paramAccesToken] = accessToken?.token
        }
        params[OAuthConstants.paramVersion] = OAuthConstants.version
        
        guard let uriScheme = uri.scheme,
            let uriHost = uri.host else { return "" }
        let baseUrl = uriScheme + "://" + uriHost + uri.path
        let signatureBase = method + "&" + rfc3986encode(baseUrl) + "&" + getEncodedQueryParams(params)
        return signatureBase
    }
    
    private func getEncodedQueryParams(_ params: [String: String]) -> String {
        var paramsBuf = ""
        let numParams = params.count
        var current = 0
        let sortedParams = params.sorted(by: {
            return $0.key < $1.key
        })
        for (key, value) in sortedParams {
            paramsBuf += rfc3986encode(key) + "%3D" + rfc3986encode(value)
            current += 1
            if current < numParams {
                paramsBuf += "%26"
            }
        }
        return paramsBuf
    }
    
    private func calculateSignature(signatureBase: String) -> String {
        let hmac = HMAC()
        let binarySignature = hmac.calculate(algorithm: .sha1, key: signingKey, message: signatureBase)
        
        return binarySignature.base64EncodedString()
    }
    
    func oAuthSign(completion: @escaping(String) ->()) {
        guard let requestTokenUrl = URL(string: "https://api.twitter.com/oauth/request_token") else { return }
        var urlRequest = URLRequest(url: requestTokenUrl)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        urlRequest.addValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print(error)
            }
            else if let data = data {
                //print(String(data: data, encoding: .utf8) ?? "Does not look like a utf8 response :(")
                let oauthToken = String(data: data, encoding: .utf8)
                guard let componentWithoutAndPercing = oauthToken?.components(separatedBy: "&") else { return }
            
                self.oauthToken = componentWithoutAndPercing.first
              
                guard let getOauth = self.oauthToken else { return }
                completion(getOauth)
            }
            
        }.resume()
    }
    
    func getOAuthToken(input: URL) -> String {
       var oauthVerifier = ""
       let stringFromURL = input.absoluteString
        
        if stringFromURL.starts(with: "http://oauthswift.herokuapp.com/") {
            let separatorSet = CharacterSet(charactersIn: "?, &")
            let result = stringFromURL.components(separatedBy: separatorSet)
            print(result)
            oauthVerifier = result[2]
        }
        return oauthVerifier
    }
    
    func sendAccessToken() {
        guard let requestAccessTokenUrl = URL(string: "https://api.twitter.com/oauth/access_token") else { return }
        var urlRequest = URLRequest(url: requestAccessTokenUrl)
        
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        urlRequest.addValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
            }
            else if let data = data {
                let accessToken = String(data: data, encoding: .utf8)
                
            }
        }
    }
    
    
    private func constructAuthorizationHeader(nonce: String, timestamp: String, signature: String) -> String {
        var string = "OAuth"
        appendParameter(string: &string, name: OAuthConstants.paramCallback, value: callBack)
        appendParameter(string: &string, name: OAuthConstants.paramConsumerKey, value: consumerKey)
        appendParameter(string: &string, name: OAuthConstants.paramNonce, value: nonce)
        appendParameter(string: &string, name: OAuthConstants.paramSignature, value: signature)
        appendParameter(string: &string, name: OAuthConstants.paramSignatureMethod, value: OAuthConstants.signatureMethod)
        appendParameter(string: &string, name: OAuthConstants.paramTimeStamp, value: timestamp)
        appendParameter(string: &string, name: OAuthConstants.paramAccesToken, value: accessToken?.token)
        appendParameter(string: &string, name: OAuthConstants.paramVersion, value: OAuthConstants.version)
        string.removeLast()
        return string
    }
    
    private func appendParameter(string: inout String, name: String, value: String?) {
        if let value = value {
            string += "" + rfc3986encode(name) + "=\"" + rfc3986encode(value) + "\","
        }
    }
}

extension URL {
    func queryParameters() -> [String: String] {
        var result: [String: String] = [:]
        for queryItem in URLComponents(url: self, resolvingAgainstBaseURL: true)?.queryItems ?? [] {
            result[queryItem.name] = queryItem.value ?? ""
        }
        return result
    }
}

