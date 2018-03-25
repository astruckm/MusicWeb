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
    let whiteKeyBottomWidthToBlackKeyWidthRatio: CGFloat = (23.5 / 13.7) //23.5 / 13.7 according to wikipedia, double check at work
    let numberOfWhiteKeys = 12
    let spaceBetweenKeys: CGFloat = 0.5
    
    var whiteKeyHeight: CGFloat { return bounds.height }
    var blackKeyHeight: CGFloat { return bounds.height / 1.5 }

    var whiteKeyBottomWidth: CGFloat { return ((bounds.width - (CGFloat(numberOfWhiteKeys-1) * spaceBetweenKeys))  /  CGFloat(numberOfWhiteKeys)) } //Octave plus a fifth, encompasses bounds' whole span
    var whiteKeyTopWidthCDE: CGFloat { return whiteKeyBottomWidth - (blackKeyWidth * 2 / 3) }
    var whiteKeyTopWidthFGAB: CGFloat { return whiteKeyBottomWidth - (blackKeyWidth * 3 / 4) }
    var blackKeyWidth: CGFloat { return whiteKeyBottomWidth / whiteKeyBottomWidthToBlackKeyWidthRatio }
    
    //All the notes in the view.
    let arrayOfKeys = [(PitchClass.c, Octave.zero), (PitchClass.cSharp, Octave.zero), (PitchClass.d, Octave.zero), (PitchClass.dSharp, Octave.zero), (PitchClass.e, Octave.zero), (PitchClass.f, Octave.zero), (PitchClass.fSharp, Octave.zero), (PitchClass.g, Octave.zero), (PitchClass.gSharp, Octave.zero), (PitchClass.a, Octave.zero), (PitchClass.aSharp, Octave.zero), (PitchClass.b, Octave.zero), (PitchClass.c, Octave.one), (PitchClass.cSharp, Octave.one), (PitchClass.d, Octave.one), (PitchClass.dSharp, Octave.one), (PitchClass.e, Octave.one), (PitchClass.f, Octave.one), (PitchClass.fSharp, Octave.one), (PitchClass.g, Octave.one)]
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
                        if let note = noteByPathArea[path]?.0 {
                            let possibleStrings = note.possibleStrings(pitchClass: note)
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
        var numberOfWhiteKeysDrawn = 0
        var startingXValue: CGFloat = bounds.minX
        var incrementer: CGFloat = 0.0
        var leftMostX: CGFloat = 0.0
        
        for key in arrayOfKeys[0..<(arrayOfKeys.count-1)] {
            currentPath = nil
            switch key.0 {
            case .c, .f:
                leftMostX = CGFloat(numberOfWhiteKeysDrawn) * (whiteKeyBottomWidth + CGFloat(spaceBetweenKeys))
                startingXValue = leftMostX //Align it back with bottom of keyboard counter
                
                let topWidth = key.0 == .c ? whiteKeyTopWidthCDE : whiteKeyTopWidthFGAB
                drawWhiteKeysCF(startingX: startingXValue, topWidth: topWidth)
                numberOfWhiteKeysDrawn += 1
                incrementer = topWidth + spaceBetweenKeys
            case .d, .g, .a:
                let topWidth = key.0 == .d ? whiteKeyTopWidthCDE : whiteKeyTopWidthFGAB
                leftMostX = CGFloat(numberOfWhiteKeysDrawn) * (whiteKeyBottomWidth + CGFloat(spaceBetweenKeys))
                drawWhiteKeysDGA(startingX: startingXValue, topWidth: topWidth, leftMostX: leftMostX)
                numberOfWhiteKeysDrawn += 1
                incrementer = topWidth + spaceBetweenKeys
            case .e, .b:
                let topWidth = key.0 == .e ? whiteKeyTopWidthCDE : whiteKeyTopWidthFGAB
                leftMostX = CGFloat(numberOfWhiteKeysDrawn) * (whiteKeyBottomWidth + CGFloat(spaceBetweenKeys))
                drawWhiteKeysEB(startingX: startingXValue, topWidth: topWidth, leftMostX: leftMostX)
                numberOfWhiteKeysDrawn += 1
                incrementer = topWidth + spaceBetweenKeys
            default:
                drawBlackKey(startingX: startingXValue)
                incrementer = blackKeyWidth + spaceBetweenKeys
            }
            if let path = currentPath {
                noteByPathArea[path] = key
            }
            startingXValue += incrementer
        }
        //make final G fill out view
        leftMostX = CGFloat(numberOfWhiteKeysDrawn) * (whiteKeyBottomWidth + CGFloat(spaceBetweenKeys))
        drawWhiteKeysEB(startingX: startingXValue, topWidth: whiteKeyTopWidthCDE, leftMostX: leftMostX)
        if let path = currentPath {
            noteByPathArea[path] = arrayOfKeys[arrayOfKeys.count-1]
        }
    }

    //MARK: Drawing (sub)functions
    func drawBlackKey(startingX: CGFloat) {
        let startingPoint = CGPoint(x: startingX, y: bounds.minY)
        let path = UIBezierPath()
        
        path.move(to: startingPoint)
        path.addLine(to: CGPoint(x: startingPoint.x, y: startingPoint.y + blackKeyHeight))
        path.addLine(to: CGPoint(x: startingPoint.x + blackKeyWidth, y: startingPoint.y + blackKeyHeight))
        path.addLine(to: CGPoint(x: startingPoint.x + blackKeyWidth, y: startingPoint.y))
        path.addLine(to: startingPoint)
        path.close()
        currentPath = path
        
        UIColor.black.setFill()
        path.fill()
    }
    
    func drawWhiteKeysCF(startingX: CGFloat, topWidth: CGFloat) {
        let startingPoint = CGPoint(x: startingX, y: bounds.minY)
        let path = UIBezierPath()
        
        path.move(to: startingPoint)
        path.addLine(to: CGPoint(x: startingPoint.x, y: whiteKeyHeight))
        path.addLine(to: CGPoint(x: startingPoint.x + whiteKeyBottomWidth, y: whiteKeyHeight))
        path.addLine(to: CGPoint(x: startingPoint.x + whiteKeyBottomWidth, y: blackKeyHeight + spaceBetweenKeys))
        path.addLine(to: CGPoint(x: startingPoint.x + topWidth, y: blackKeyHeight + spaceBetweenKeys))
        path.addLine(to: CGPoint(x: startingPoint.x + topWidth, y: startingPoint.y))
        path.addLine(to: startingPoint)
        path.close()
        currentPath = path
        
        strokeAndFillPath(path)
    }
    
    func drawWhiteKeysDGA(startingX: CGFloat, topWidth: CGFloat, leftMostX: CGFloat) {
        let startingPoint = CGPoint(x: startingX, y: bounds.minY)
        let path = UIBezierPath()
        
        path.move(to: startingPoint)
        path.addLine(to: CGPoint(x: startingPoint.x, y: blackKeyHeight + spaceBetweenKeys))
        path.addLine(to: CGPoint(x: leftMostX, y: blackKeyHeight + spaceBetweenKeys))
        path.addLine(to: CGPoint(x: leftMostX, y: whiteKeyHeight))
        path.addLine(to: CGPoint(x: leftMostX + whiteKeyBottomWidth, y: whiteKeyHeight))
        path.addLine(to: CGPoint(x: leftMostX + whiteKeyBottomWidth, y: blackKeyHeight + spaceBetweenKeys))
        path.addLine(to: CGPoint(x: startingPoint.x + topWidth, y: blackKeyHeight + spaceBetweenKeys))
        path.addLine(to: CGPoint(x: startingPoint.x + topWidth, y: startingPoint.y))
        path.addLine(to: startingPoint)
        path.close()
        currentPath = path
        
        strokeAndFillPath(path)
    }
    
    func drawWhiteKeysEB(startingX: CGFloat, topWidth: CGFloat, leftMostX: CGFloat) {
        let startingPoint = CGPoint(x: startingX, y: bounds.minY)
        let path = UIBezierPath()
        
        path.move(to: startingPoint)
        path.addLine(to: CGPoint(x: startingPoint.x, y: blackKeyHeight + spaceBetweenKeys))
        path.addLine(to: CGPoint(x: leftMostX, y: blackKeyHeight + spaceBetweenKeys))
        path.addLine(to: CGPoint(x: leftMostX, y: whiteKeyHeight))
        path.addLine(to: CGPoint(x: leftMostX + whiteKeyBottomWidth, y: whiteKeyHeight))
        path.addLine(to: CGPoint(x: leftMostX + whiteKeyBottomWidth, y: startingPoint.y))
        path.addLine(to: startingPoint)
        path.close()
        currentPath = path
        
        strokeAndFillPath(path)
    }
    
    //Helper function
    private func strokeAndFillPath(_ path: UIBezierPath) {
        path.lineWidth = 0.3
        UIColor.black.setStroke()
        UIColor.white.setFill()
        path.fill()
        path.stroke()
    }
    
}




