//
//  AuthViewController.swift
//  SwifterDemoiOS
//
//  Copyright (c) 2014 Matt Donnelly.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import Accounts
import Social
import SwifteriOS

class AuthViewController: UIViewController {
    
    var swifter: Swifter
    
    @IBOutlet var emailTextField : UITextField!
    @IBOutlet var pwTextField : UITextField!

    // Default to using the iOS account framework for handling twitter auth
    let useACAccount = true

    required init(coder aDecoder: NSCoder) {
        self.swifter = Swifter(consumerKey: "RErEmzj7ijDkJr60ayE2gjSHT", consumerSecret: "SbS0CHk11oJdALARa7NDik0nty4pXvAxdt7aj0R5y1gNzWaNEx")
        super.init(coder: aDecoder)
    
    }

    @IBAction func didTouchUpInsideEmailButton(sender: AnyObject) {
        let failureHandler: ((NSError) -> Void) = {
            error in
            
            self.alertWithTitle("Error", message: error.localizedDescription)
        }
        var email = emailTextField.text
        var password = pwTextField.text
        let urlPath = "http://sandhill.exchange/account/signin"
        
        var request = NSMutableURLRequest(URL: NSURL(string: urlPath)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var params = ["email":email, "password":password] as Dictionary<String, String>
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Task completed")
            println(data)
            println(response)
            println(error)
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    var status = parseJSON["status"] as? NSString
                    if (status == "ok") {
                        //save user info
                        if let user_id = parseJSON["user_id"] as? NSNumber! {
                            NSUserDefaults.standardUserDefaults().setObject(user_id, forKey: "user_id")
                            NSUserDefaults.standardUserDefaults().synchronize()
                        }
                    
                    }
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        task.resume()
        
    }
    
    
    @IBAction func didTouchUpInsideLoginButton(sender: AnyObject) {
        let failureHandler: ((NSError) -> Void) = {
            error in

            self.alertWithTitle("Error", message: error.localizedDescription)
        }

        if useACAccount {

            let accountStore = ACAccountStore()
            let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)

            // Prompt the user for permission to their twitter account stored in the phone's settings
            accountStore.requestAccessToAccountsWithType(accountType, options: nil) {
                granted, error in
                if granted {
                    let twitterAccounts = accountStore.accountsWithAccountType(accountType)

                    if twitterAccounts?.count == 0
                    {
                        self.alertWithTitle("Error", message: "There are no Twitter accounts configured. You can add or create a Twitter account in Settings.")
                    }
                    else {
                        let twitterAccount = twitterAccounts[0] as ACAccount
                        self.swifter = Swifter(account: twitterAccount)
                        self.fetchTwitterHomeStream()
                    }
                }
                else {
                    self.alertWithTitle("Error", message: error.localizedDescription)
                }
            }
        }
        else {
            swifter.authorizeWithCallbackURL(NSURL(string: "swifter://success")!, success: {
                accessToken, response in

                self.fetchTwitterHomeStream()

                },failure: failureHandler
            )
        }
    }

    func fetchTwitterHomeStream() {
        
        let failureHandler: ((NSError) -> Void) = {
            error in
            self.alertWithTitle("Error", message: error.localizedDescription)
        }
        
        self.swifter.getStatusesHomeTimelineWithCount(20, sinceID: nil, maxID: nil, trimUser: true, contributorDetails: false, includeEntities: true, success: {
            (statuses: [JSONValue]?) in
                
            // Successfully fetched timeline, so lets create and push the table view
            let companyViewController = self.storyboard!.instantiateViewControllerWithIdentifier("CompanyViewController") as CompanyViewController
                
            if statuses != nil {
                companyViewController.tweets = statuses!
                self.presentViewController(companyViewController, animated: true, completion: nil)
            }

            }, failure: failureHandler)
        
    }

    func fetchCompanies() {
        
        let failureHandler: ((NSError) -> Void) = {
            error in
            self.alertWithTitle("Error", message: error.localizedDescription)
        }
        
        self.swifter.getStatusesHomeTimelineWithCount(20, sinceID: nil, maxID: nil, trimUser: true, contributorDetails: false, includeEntities: true, success: {
            (statuses: [JSONValue]?) in
            
            // Successfully fetched timeline, so lets create and push the table view
            let companyViewController = self.storyboard!.instantiateViewControllerWithIdentifier("CompanyViewController") as CompanyViewController
            
            if statuses != nil {
                companyViewController.tweets = statuses!
                self.presentViewController(companyViewController, animated: true, completion: nil)
            }
            
            }, failure: failureHandler)
        
    }
    
    func alertWithTitle(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

}