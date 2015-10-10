//
//  ViewController.swift
//  CanvasViewExample
//
//  Created by Danny Yassine on 2015-10-09.
//  Copyright © 2015 Danny Yassine. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var canvasView: CanvasView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonPressed(sender: UIButton) {
        let image = self.canvasView.extractDrawing()
        let imageView = UIImageView(frame: CGRect(x: 50.0, y: 50.0, width: self.view.frame.width - 100.0, height: self.view.frame.height - 100.0))
        imageView.image = image
        self.view.addSubview(imageView)
    }

    @IBAction func unduButton(sender: UIButton) {
        self.canvasView.undo()
    }

    @IBAction func redo(sender: UIButton) {
        self.canvasView.redo()
    }
}

