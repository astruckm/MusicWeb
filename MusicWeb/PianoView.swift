//
//  PianoView.swift
//  Chord Connections
//
//  Created by ASM on 3/4/18.
//  Copyright © 2018 ASM. All rights reserved.
//
//White key short widths of 3/4 and 2/3 uses "B/12 solution" from:
//http://www.mathpages.com/home/kmath043.htm
//set c=d=e=(W-2B/3) and f=g=a=b=(W-3B/4)
//Decided not to use for now, and just used all=(W-B/2)
//

import UIKit

protocol DisplaysNoteName {
    var noteName: String { get set }
}

class PianoView: UIView {
    //MARK: Properties
    let whiteKeyBottomWidthToBlackKeyWidthRatio: CGFloat = (23.5 / 13.7) //According to wikipedia, double check at work
    let numberOfWhiteKeys = 12
    
    var whiteKeyBottomWidth: CGFloat { return bounds.width / CGFloat(numberOfWhiteKeys) } //Octave plus a fifth, encompasses bounds' whole span
    var whiteKeyTopWidth: CGFloat { return whiteKeyBottomWidth - (blackKeyWidth / 2) }
    var blackKeyWidth: CGFloat { return whiteKeyBottomWidth / whiteKeyBottomWidthToBlackKeyWidthRatio }
    var blackKeyHeight: CGFloat { return bounds.height / 1.5 }
        
    //All the notes in the view
    let arrayOfKeys = [(PitchClass.c, Octave.zero), (PitchClass.cSharp, Octave.zero), (PitchClass.d, Octave.zero), (PitchClass.dSharp, Octave.zero)/*, (PitchClass.e, Octave.zero), (PitchClass.f, Octave.zero), (PitchClass.fSharp, Octave.zero), (PitchClass.g, Octave.zero), (PitchClass.gSharp, Octave.zero), (PitchClass.a, Octave.zero), (PitchClass.aSharp, Octave.zero), (PitchClass.b, Octave.zero), (PitchClass.c, Octave.one), (PitchClass.cSharp, Octave.one), (PitchClass.d, Octave.one), (PitchClass.dSharp, Octave.one), (PitchClass.e, Octave.one), (PitchClass.f, Octave.one), (PitchClass.fSharp, Octave.one), (PitchClass.g, Octave.one)*/]
    //To map a touch's area in layer to its note
    var currentPath: UIBezierPath? = nil
    var noteByPathArea = [UIBezierPath: (PitchClass, Octave)]()
    var noteNameDelegate: DisplaysNoteName?
    
    //MARK: Touch events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1 {
            print(touches)
            let touch = touches.first
            let location = touch?.location(in: self)
            if let location = location {
                for path in noteByPathArea.keys {
                    if path.contains(location) {
                        let note = noteByPathArea[path]?.0
                        print("White key top width is: \(whiteKeyTopWidth)")
                        print("Black key width is: \(blackKeyWidth)")
                        print("Upper left corner of starting rect is: \(path.currentPoint)")
                        print("Touch occurs at: \(location)")
                        if let note = note {
                            let possibleStrings = note.possibleStrings(pitchClass: note)
//                            print(possibleStrings[0])
                            noteNameDelegate?.noteName = possibleStrings[0]
                        }
                        break
                    }
                }
            }
        } else if touches.count > 1 {
            for touch in touches {
                let location = touch.location(in: self)
                for path in noteByPathArea.keys {
                    if path.contains(location) {
                        let note = noteByPathArea[path]?.0
                        if let note = note {
                            let possibleStrings = note.possibleStrings(pitchClass: note)
                            print(possibleStrings[0])
                            noteNameDelegate?.noteName = possibleStrings[0]
                        }
                        break
                    }
                }
            }
        }
    }
    
    //Not applicable
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        return
    }
    
    //Not applicable
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        return
    }
    
    //MARK: draw rect
    override func draw(_ rect: CGRect) {
        var startingXValue: CGFloat = bounds.minX
        var incrementer: CGFloat = 0.0
        for key in arrayOfKeys[0..<(arrayOfKeys.count-1)] {
            switch key.0 {
            case .c, .f:
                drawWhiteKeysCF(startingX: startingXValue, topWidth: whiteKeyTopWidth, shortHeight: blackKeyHeight)
                incrementer = whiteKeyTopWidth
            case .d, .g, .a:
                drawWhiteKeysDGA(startingX: startingXValue, topWidth: whiteKeyTopWidth, shortHeight: blackKeyHeight, middleWidth: whiteKeyBottomWidth - whiteKeyTopWidth)
                incrementer = whiteKeyTopWidth
            case .e, .b:
                drawWhiteKeysEB(startingX: startingXValue, topWidth: whiteKeyTopWidth, shortHeight: blackKeyHeight)
                incrementer = whiteKeyBottomWidth
            default:
                drawBlackKey(startingX: startingXValue)
                incrementer = (blackKeyWidth / 2)
            }
            if let path = currentPath {
                noteByPathArea[path] = key
            }
            startingXValue += incrementer
        }
        //make final G fill out view
        /*
        drawWhiteKeysEB(startingX: startingXValue, topWidth: whiteKeyTopWidth, shortHeight: blackKeyHeight)
        if let path = currentPath {
            noteByPathArea[path] = arrayOfKeys[arrayOfKeys.count-1]
        } */
    }

    //MARK: Drawing (sub)functions
    func drawBlackKey(startingX: CGFloat) {
        let startingPoint = CGPoint(x: startingX, y: bounds.minY)
        let rect = calculateBlackKeyRect(startingPoint: startingPoint)
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.close()
        currentPath = path
        
        UIColor.black.setFill()
        path.fill()
    }
    
    func drawWhiteKeysCF(startingX: CGFloat, topWidth: CGFloat, shortHeight: CGFloat) {
        let startingPoint = CGPoint(x: startingX, y: bounds.minY)
        let rect = calculateWhiteKeyRect(startingPoint: startingPoint)
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: shortHeight))
        path.addLine(to: CGPoint(x: rect.minX + topWidth, y: shortHeight))
        path.addLine(to: CGPoint(x: rect.minX + topWidth, y: rect.minY))
        path.close()
        currentPath = path
        
        strokePath(path)
    }
    
    func drawWhiteKeysDGA(startingX: CGFloat, topWidth: CGFloat, shortHeight: CGFloat, middleWidth: CGFloat) {
        let startingPoint = CGPoint(x: startingX, y: bounds.minY)
        let rect = calculateWhiteKeyRect(startingPoint: startingPoint)
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: rect.minX + middleWidth, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + middleWidth, y: rect.minY + shortHeight))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + shortHeight))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + shortHeight))
        path.addLine(to: CGPoint(x: rect.maxX - middleWidth, y: rect.minY + shortHeight))
        path.addLine(to: CGPoint(x: rect.maxX - middleWidth, y: rect.minY))
        path.close()
        currentPath = path
        
        strokePath(path)
    }
    
    func drawWhiteKeysEB(startingX: CGFloat, topWidth: CGFloat, shortHeight: CGFloat) {
        let startingPoint = CGPoint(x: startingX, y: bounds.minY)
        let rect = calculateWhiteKeyRect(startingPoint: startingPoint)
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: rect.maxX - topWidth, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topWidth, y: rect.minY + shortHeight))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + shortHeight))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.close()
        currentPath = path
        
        strokePath(path)
    }
    
    //Helper functions
    private func strokePath(_ path: UIBezierPath) {
        path.lineWidth = 0.2
        UIColor.black.setStroke()
        path.stroke()
    }
    
    private func calculateWhiteKeyRect(startingPoint: CGPoint) -> CGRect {
        let rect = CGRect(x: startingPoint.x, y: startingPoint.y, width: whiteKeyBottomWidth, height: bounds.height)
        return rect
    }
    
    private func calculateBlackKeyRect(startingPoint: CGPoint) -> CGRect {
        let rect = CGRect(x: startingPoint.x, y: startingPoint.y, width: blackKeyWidth, height: blackKeyHeight)
        return rect
    }

}




