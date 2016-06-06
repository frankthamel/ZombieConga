//
//  MyUtils.swift
//  ZombieConga
//
//  Created by Frank Thamel on 6/5/16.
//  Copyright © 2016 co.talene. All rights reserved.
//  Practice project. Orginal source included in the book "2D IOS and tvOS Games by Tutorials" - by
//  https://www.raywenderlich.com
//

import Foundation
import CoreGraphics
import AVFoundation

func + (left : CGPoint , right : CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x , y: left.y + right.y)
}

func += (inout left : CGPoint , right : CGPoint) {
    left = left + right
}

func - (left : CGPoint , right : CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x , y: left.y - right.y)
}

func -= (inout left : CGPoint , right : CGPoint) {
    left = left - right
}

func * (left : CGPoint , right : CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x , y: left.y * right.y)
}

func *= (inout left : CGPoint , right : CGPoint) {
    left = left * right
}

func * (point : CGPoint , scalar : CGFloat) -> CGPoint{
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func *= (inout point : CGPoint , scalar : CGFloat) {
    point = point * scalar
}

func / (left : CGPoint , right : CGPoint) -> CGPoint {
    return CGPoint(x: left.x / right.x , y: left.y / right.y)
}

func /= (inout left : CGPoint , right : CGPoint) {
    left = left / right
}

func / (point : CGPoint , scalar : CGFloat) -> CGPoint{
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

func /= (inout point : CGPoint , scalar : CGFloat) {
    point = point / scalar
}

#if !(arch(x86_64) || arch(arm64))
    func atan2(y: CGFloat, x: CGFloat) -> CGFloat {
        return CGFloat(atan2f(Float(y), Float(x)))
    }
    
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
    
    var angle: CGFloat {
        return atan2(y, x)
    }
}

let π = CGFloat(M_PI)

func shortestAngleBetween(angle1: CGFloat,
    angle2: CGFloat) -> CGFloat {
        let twoπ = π * 2.0
        var angle = (angle2 - angle1) % twoπ
        if (angle >= π) {
            angle = angle - twoπ
        }
        if (angle <= -π) {
            angle = angle + twoπ
        }
        return angle
}

extension CGFloat {
    func sign() -> CGFloat {
        return (self >= 0.0) ? 1.0 : -1.0
    }
}

extension CGFloat {
    
    /*generates a random number between 0 and 1*/
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UInt32.max))
    }
    
    /*generates a random number between min and max*/
    static func random(min min : CGFloat , max : CGFloat) ->CGFloat {
        assert(min < max)
        return CGFloat.random() * (max - min) + min
    }
}

var backgroundMusicPlayer : AVAudioPlayer!

func playBackgroundMusic(filename : String) {
    let resourceUrl = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
    guard let url = resourceUrl else {
        print("Could not find file : \(filename)")
        return
    }
    
    do{
        try backgroundMusicPlayer = AVAudioPlayer(contentsOfURL : url)
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
    } catch{
        print("Could not create audio player!")
        return
    }
}














