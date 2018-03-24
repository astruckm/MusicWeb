//
//  NoteModel.swift
//  Chord Connections
//
//  Created by ASM on 2/24/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import Foundation

struct HarmonyModel {
    
    //MARK: Types
    enum PitchIntervalClass: Int {
        case unison = 0, minorSecond, majorSecond, minorThird, majorThird, perfectFourth, tritone, perfectFifth, minorSixth, majorSixth, minorSeventh, majorSeventh
    }
    
    enum TriadChordQuality {
        case major, minor, diminished, augmented
    }
    
    //input notes in a chord, output all possible inversions
    func allInversions(notes: [PitchClass]) -> [[(PitchClass)]] {
        var allInversionsOfCollection = [[PitchClass]]()
        var inversion = notes.sorted(by: <)
        for _ in 0..<(notes.count-1) {
            allInversionsOfCollection.append(inversion)
            let firstNote = inversion.remove(at: 0)
            inversion.append(firstNote)
        }
        return allInversionsOfCollection
    }
    
    //MARK: Convert Types
    //Int value for a key
    func keyValue(pitch: (PitchClass, Octave)) -> Int {
        return pitch.0.rawValue + (pitch.1.rawValue * 12)
    }
    
    //Make any Int a PitchClass
    func putInRange(keyValue: Int) -> PitchClass {
        if keyValue < 12 && keyValue >= 0 {
            return PitchClass(rawValue: keyValue)!
        }
        
        var newPitchValue = keyValue
        while newPitchValue >= 12 || newPitchValue < 0 {
            if newPitchValue >= 12 { newPitchValue -= 12 }
            if newPitchValue < 0 { newPitchValue += 12 }
        }
        return PitchClass(rawValue: newPitchValue)!
    }

    
    mutating func intervalBetweenKeys(keyOne: (PitchClass, Octave), keyTwo: (PitchClass, Octave)) -> PitchIntervalClass {
        var rawInterval = abs(keyValue(pitch: keyOne) - keyValue(pitch: keyTwo))
        //Put keys in same octave
        rawInterval %= 12
        return PitchIntervalClass(rawValue: rawInterval)!
    }
    
    //MARK: Set Theory
    //Using Joseph N. Straus' "Introduction to Post-Tonal Theory"
    func getIntervalClass(_ pitchIntervalClass: PitchIntervalClass) -> Int {
        let pIC = pitchIntervalClass.rawValue
        return pIC <= 6 ? pIC : (12 - pIC)
    }
    
    func pitchCollectionInversion(_ set: [PitchClass]) -> [PitchClass] {
        let rawInvertedValues = set.map({ element -> Int in
            return 12 - element.rawValue })
        let invertedValues = rawInvertedValues.map({ element -> PitchClass in
            return putInRange(keyValue: element) })
        return invertedValues
    }
    
    //Use on a collection's allInversions(notes:) output
    mutating func normalForm(pitchCollectionInversions: [[PitchClass]]) ->  [PitchClass] {
        var shortestCollections = [[PitchClass]]()
        
        //Storage variable initialized with value guaranteed to be larger than first intervalSpan
        var shortestDistance = 12
        //Find inversions with shortest first to last distance
        //Put top key (keyOne) an octave above bottom key (keyTwo) to properly account for span
        for collection in pitchCollectionInversions {
            let intervalSpan = intervalBetweenKeys(keyOne: (collection[collection.count-1], Octave.one), keyTwo: (collection[0], Octave.zero))
            if intervalSpan.rawValue < shortestDistance {
                shortestCollections = [[PitchClass]]()
                shortestCollections.append(collection)
                shortestDistance = intervalSpan.rawValue
            } else if intervalSpan.rawValue == shortestDistance {
                shortestCollections.append(collection)
            }
        }
        
        if shortestCollections.count == 1 {
            return shortestCollections[0]
        }
        
        //Loop at least once through length of pitch collections checking span between second-to-last, then third-to-last, etc.
        for loopIndex in 1...(shortestCollections[0].count-2) {
            var shortestCollection = [[PitchClass]]() //singular
            for collection in shortestCollections {
                let intervalSpan = intervalBetweenKeys(keyOne: (collection[collection.count-1-loopIndex], Octave.one), keyTwo: (collection[0], Octave.zero))
                if intervalSpan.rawValue < shortestDistance {
                    shortestCollection = [[PitchClass]]()
                    shortestCollection.append(collection)
                    shortestDistance = intervalSpan.rawValue
                } else if intervalSpan.rawValue == shortestDistance {
                    shortestCollection.append(collection)
                }
            }
            if shortestCollection.count == 1 {
                return shortestCollection[0]
            }
        }
        
        //Since pitchCollectionInversions should already be sorted to have lowest pitch class inversion first by allInversions(notes:), just return first if still a tie (e.g. augmented or fully diminished
        return pitchCollectionInversions[0]
    }
    
    //Use on a collections normalForm(pitchCollectionInversions:) output
    mutating func primeForm(pitchCollection: [PitchClass]) -> [Int] {
        let pcNormalForm = normalForm(pitchCollectionInversions: [pitchCollection])
        let transposedToZero = pcNormalForm.map({
            element -> PitchClass in
            let transposingInt = element.rawValue - pitchCollection[0].rawValue
            if let transposedElement = PitchClass(rawValue: transposingInt) {
                return transposedElement
            } else if let transposedElementPlusOctave = PitchClass(rawValue: transposingInt+12) {
                return transposedElementPlusOctave
            } else {
                return PitchClass(rawValue: element.rawValue)!
            }
        })

        let inversion = pitchCollectionInversion(pcNormalForm)
        let inversionTransposedToZero = inversion.map({
            element -> PitchClass in
            let transposingInt = element.rawValue - pitchCollection[0].rawValue
            if let transposedElement = PitchClass(rawValue: transposingInt) {
                return transposedElement
            } else if let transposedElementPlusOctave = PitchClass(rawValue: transposingInt+12) {
                return transposedElementPlusOctave
            } else {
                return PitchClass(rawValue: element.rawValue)!
            }
        })

        //Use Forte method, packed to left
        var counter = 1
        while counter < transposedToZero.count {
            if transposedToZero[counter] > inversionTransposedToZero[counter] {
                return transposedToZero.map({element -> Int in return element.rawValue})
            } else if transposedToZero[counter] < inversionTransposedToZero[counter] {
                return inversionTransposedToZero.map({element -> Int in return element.rawValue})
            }
            counter += 1
        }
        
        print("\n \n The collection is symmetrical \n \n")
        return transposedToZero.map({element -> Int in return element.rawValue})
    }
    
    
    
    
    
    
//    mutating func pitchSetFromTwoKeys(keyOne: (PitchClass, Octave), keyTwo: (PitchClass, Octave)) -> [Int] {
//            let pitchIntervalClass = intervalBetweenKeys(keyOne: keyOne, keyTwo: keyTwo)
//            let intervalClass = getIntervalClass(pitchIntervalClass)
//            return [intervalClass]
//    }
//
//    mutating func pitchSetFromThreeKeys(keyOne: (PitchClass, Octave), keyTwo: (PitchClass, Octave), keyThree: (PitchClass, Octave)) -> [Int] {
//
//        let pIC1 = intervalBetweenKeys(keyOne: keyOne, keyTwo: keyTwo)
//        let pIC2 = intervalBetweenKeys(keyOne: keyTwo, keyTwo: keyThree)
//        let intervalClass1 = getIntervalClass(pIC1)
//        let intervalClass2 = getIntervalClass(pIC2)
//
//        return [1, 2]
//    }
    
    
        
}




