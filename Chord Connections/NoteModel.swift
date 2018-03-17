//
//  NoteModel.swift
//  Chord Connections
//
//  Created by ASM on 2/24/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import Foundation


struct NoteModel {
    //MARK: Types
    enum PitchClassName: Int {
        case c = 0, cSharp, d, dSharp, e, f, fSharp, g, gSharp, a, aSharp, b
    }
    
    private enum PitchIntervalClass: Int {
        case unison = 0, minorSecond, majorSecond, minorThird, majorThird, perfectFourth, tritone, perfectFifth, minorSixth, majorSixth, minorSeventh, majorSeventh
    }
    
    private enum TriadChordQuality {
        case major, minor, diminished, augmented
    }
    
    //MARK: Properties
    private let root: PitchClassName
    private let third: PitchClassName
    private let fifth: PitchClassName
    
    private var intervalOne: PitchIntervalClass {
        let intervalClass = abs(third.rawValue - root.rawValue)
        return PitchIntervalClass(rawValue: intervalClass)!
    }
    private var intervalTwo: PitchIntervalClass {
        let intervalClass = abs(fifth.rawValue - third.rawValue)
        return PitchIntervalClass(rawValue: intervalClass)!
    }
    private var chordQuality: TriadChordQuality? {
        if intervalOne == .majorThird && intervalTwo == .majorThird {
            return TriadChordQuality.augmented
        }
        if intervalOne == .tritone || intervalTwo == .tritone || (intervalOne == .minorThird && intervalTwo == .minorThird) {
            return TriadChordQuality.diminished
        }
        
        let intervals = [intervalOne, intervalTwo]
        //Inversions
        if intervals.contains(.perfectFourth) {
            if intervalOne == .minorThird || intervalTwo == .majorThird {
                return TriadChordQuality.major
            }
            if intervalTwo == .majorThird || intervalTwo == .minorThird {
                return TriadChordQuality.minor
            }
        }
        //Root position
        if intervals.contains(.minorThird) && intervals.contains(.majorThird) {
            return intervalOne == .majorThird ? TriadChordQuality.major : TriadChordQuality.minor
        }
        
        return nil
    }
    
}




