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

@IBDesignable class PianoView: UIView {
    //MARK: Properties
    let whiteKeyBottomWidthToBlackKeyWidthRatio: CGFloat = (23.5 / 13.7) //According to wikipedia, double check at work
    var whiteKeyBottomWidth: CGFloat { return bounds.width / 12 } //Octave plus a fifth, encompasses bounds' whole span
    var whiteKeyTopWidth: CGFloat { return whiteKeyBottomWidth - (blackKeyWidth / 2) }
    var blackKeyWidth: CGFloat { return whiteKeyBottomWidth / whiteKeyBottomWidthToBlackKeyWidthRatio }
    var blackKeyHeight: CGFloat { return bounds.height / 1.5 }
        
    //All the notes in the view
    let arrayOfKeys = [NoteModel.PitchClassName.c, NoteModel.PitchClassName.cSharp, NoteModel.PitchClassName.d, NoteModel.PitchClassName.dSharp, NoteModel.PitchClassName.e, NoteModel.PitchClassName.f, NoteModel.PitchClassName.fSharp, NoteModel.PitchClassName.g, NoteModel.PitchClassName.gSharp, NoteModel.PitchClassName.a, NoteModel.PitchClassName.aSharp, NoteModel.PitchClassName.b, NoteModel.PitchClassName.c, NoteModel.PitchClassName.cSharp, NoteModel.PitchClassName.d, NoteModel.PitchClassName.dSharp, NoteModel.PitchClassName.e, NoteModel.PitchClassName.f, NoteModel.PitchClassName.fSharp, NoteModel.PitchClassName.g]
    //To map a touch's area in layer to its note
    var currentPath: UIBezierPath? = nil
    var noteByPathArea = [UIBezierPath: NoteModel.PitchClassName]()
    var noteNameDelegate: DisplaysNoteName?
    
    //MARK: Touch events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1 {
            let touch = touches.first
            let location = touch?.location(in: self)
            if let location = location {
                for path in noteByPathArea.keys {
                    if path.contains(location) {
                        print(noteByPathArea[path])
                        noteNameDelegate?.noteName = String(describing: noteByPathArea[path])
                        break
                    }
                }
            }
        } else if touches.count > 1 {
            for touch in touches {
                let location = touch.location(in: self)
                for path in noteByPathArea.keys {
                    if path.contains(location) {
                        print(noteByPathArea[path])
                        noteNameDelegate?.noteName = String(describing: noteByPathArea[path])
                        break
                    }
                }
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        return
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        return
    }
    
    override func draw(_ rect: CGRect) {
        var startingXValue: CGFloat = bounds.minX
        var incrementer: CGFloat = 0.0
        for key in arrayOfKeys[0...(arrayOfKeys.count-2)] {
            switch key {
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
        drawWhiteKeysEB(startingX: startingXValue, topWidth: whiteKeyTopWidth, shortHeight: blackKeyHeight)
        if let path = currentPath {
            noteByPathArea[path] = arrayOfKeys[arrayOfKeys.count-1]
        }
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
        UIColor.black.setFill()
        path.fill()
        currentPath = path
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
    func strokePath(_ path: UIBezierPath) {
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




