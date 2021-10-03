//
//  SLImageLoad.swift
//  rpc
//
//  Created by => Jerry4539 on 2021/3/2.
//  Copyright © 2021 by Jerry4539 . All rights reserved.
//
import UIKit
let SLMedia_identifier = "com.slni.SLMedia"
class SLImageLoad: NSObject {
    static func load(name:String) -> UIImage?{
      let bundle = Bundle.init(identifier: SLMedia_identifier)
      //let bundle = Bundle.main
      return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
}
