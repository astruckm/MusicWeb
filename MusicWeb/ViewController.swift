//
//  ViewController.swift
//  Chord Connections
//
//  Created by ASM on 2/24/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import UIKit


class ViewController: UIViewController, DisplaysNoteName {
    @IBOutlet weak var noteNameLabel: UILabel!
    @IBOutlet weak var piano: PianoView! {
        didSet {
            piano.draw(piano.bounds)
            piano.noteNameDelegate = self
        }
    }
    
    var noteName: String {
        get {
            if noteNameLabel.text != nil {
                return noteNameLabel.text!
            } else {
                return " "
            }
        }
        set {
            noteNameLabel.textColor = .black
            noteNameLabel.text = newValue
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(piano)
        view.addSubview(noteNameLabel)
        view.isMultipleTouchEnabled = true
        piano.isUserInteractionEnabled = true
        piano.isMultipleTouchEnabled = true
        noteNameLabel.textColor = .lightGray
        noteNameLabel.text = "Name of Note"
    }
    
//    @objc func location(from tapRecognizer: UITapGestureRecognizer) {
//        piano.getLocation(from: tapRecognizer)
//        print("gotLocation")
//    }
    
    //MARK: Touch events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        return
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        return
    }


}
