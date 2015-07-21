//
//  TimeUtils.swift
//  JMS Video QC Tool
//
//  Created by Matthieu Collé on 21/07/2015.
//  Copyright © 2015 JohnMcNeil Studio. All rights reserved.
//

import Foundation

class Utils {
    
    /**
        @function   secondsToMinSec
    
        @param      totalSeconds    total number of seconds
        @return     (minutes, seconds)
    */
    static func secondsToMinSec(totalSeconds: Int64) -> (minutes: Int64, seconds: Int64) {
        
        let calcMinutes: Int64 = totalSeconds / 60
        let calcSeconds: Int64 = totalSeconds - calcMinutes * 60
        
        return (minutes: calcMinutes, seconds: calcSeconds)
        
    }
    
    
    /**
        @function   padZero
    
        @param      value           value you want to pad with zeros
        @return     String
    */
    static func padZeros(val: Int64, finalLength: Int16 = 2) -> String {
        
        var strValue = String(val)
        
        while Int16(strValue.characters.count) < finalLength {
            strValue = "0" + strValue
        }
        
        return strValue
        
    }
    
}