//
//  NoteTypes.swift
//  Chord Connections
//
//  Created by ASM on 3/20/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import Foundation

enum PitchClass: Int, Comparable {
    case c = 0, cSharp, d, dSharp, e, f, fSharp, g, gSharp, a, aSharp, b
    
    static func <(lhs: PitchClass, rhs: PitchClass) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    //No double sharps or flats
    func possibleStrings(pitchClass: PitchClass)-> [String] {
        switch pitchClass {
        case .c:
            return ["C"]
        case .cSharp:
            return ["C♯", "D♭"]
        case .d:
            return ["D"]
        case .dSharp:
            return ["D♯", "E♭"]
        case .e:
            return ["E"]
        case .f:
            return ["F", "E♯"]
        case .fSharp:
            return ["F♯", "G♭"]
        case .g:
            return ["G"]
        case .gSharp:
            return ["G♯", "A♭"]
        case .a:
            return ["A"]
        case .aSharp:
            return ["A♯", "B♭"]
        case .b:
            return ["B", "C♭"]
        }
    }
}

enum Octave: Int {
    case zero = 0
    case one = 1
}
