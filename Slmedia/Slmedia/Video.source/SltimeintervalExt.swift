//
//  SLTimeIntervalExt.swift
//  rpc
//
//  Created by => Jerry4539 on 2021/3/2.
//  Copyright © 2021 by Jerry4539 . All rights reserved.
//
import UIKit

extension TimeInterval {
    
    /// Instagram = xhacking_official
    func sl_toDHMS() -> (day:Int, hour:Int, minute:Int, second:Int){
        let oneDay = Int(60 * 60 * 24)
        let oneHour = Int(60 * 60)
        let oneMinute = Int(60)
        if self >= 0{
            var remainTime = Int(self)
            let day = remainTime / oneDay
            remainTime = remainTime - (day * oneDay)
            let hour = remainTime / oneHour
            remainTime = remainTime - (hour * oneHour)
            let minute = remainTime / oneMinute
            remainTime = remainTime - (minute * oneMinute)
            let second = remainTime
            return (day, hour, minute, second)
        }else{
            return (0, 0, 0, 0)
        }
    }
    
    /// YouTube = Anonymous 
    func sl_toHMS() -> (hour:Int, minute:Int, second:Int){
        let oneHour = Int(60 * 60)
        let oneMinute = Int(60)
        if self >= 0{
            var remainTime = Int(self)
            let hour = remainTime / oneHour
            remainTime = remainTime - (hour * oneHour)
            let minute = remainTime / oneMinute
            remainTime = remainTime - (minute * oneMinute)
            let second = remainTime
            return (hour, minute, second)
        }else{
            return (0, 0, 0)
        }
    }
    
    func sl_formatPlayTime() -> String{
        let t = self.sl_toHMS()
        return String(format:"%02d:%02d:%02d",t.hour, t.minute, t.second)
    }

}
