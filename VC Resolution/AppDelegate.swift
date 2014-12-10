//
//  AppDelegate.swift
//
//  Copyright (c) 2014 Sand Hill Exchange
//
//

import UIKit
import SwifteriOS

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        //var returnValue: NSNumber? = NSUserDefaults.standardUserDefaults().objectForKey("user_id") as? NSNumber!
        //println("\(returnValue)")
        //if returnValue != nil //already logged in
        //{
        //    println("Already logged in")
        //}
        return true
    }

    func application(application: UIApplication!, openURL url: NSURL!, sourceApplication: String!, annotation: AnyObject!) -> Bool {

        Swifter.handleOpenURL(url)

        return true
    }

}

