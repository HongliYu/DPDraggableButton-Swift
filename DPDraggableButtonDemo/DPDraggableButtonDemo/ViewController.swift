//
//  ViewController.swift
//  DPDraggableButtonDemo
//
//  Created by Hongli Yu on 8/9/16.
//  Copyright © 2016 Hongli Yu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  
  @IBOutlet var consoleLabel: UILabel!
  @IBOutlet var logSwitch: UISwitch!
  
  var logInfo: String = "Log:"
  var draggableButton: DPDraggableButton!

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    UIApplication.shared.keyWindow?.bringSubview(toFront: self.draggableButton)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.draggableButton = DPDraggableButton.init(frame: CGRect(x: 0, y: 120, width: 100, height: 40),
                                                  draggableButtonType: .dpDraggableRect)
    self.draggableButton.backgroundColor = UIColor.gray
    self.draggableButton.setTitleColor(UIColor.white, for: UIControlState())
    self.draggableButton.setTitle("drag me", for: UIControlState())
    
    self.draggableButton.tapBlock = {
      [weak self] in
      if let this = self {
        this.refreshLog("[single tap]")
      }
    }
    
    self.draggableButton.doubleTapBlock = {
      [weak self] in
      if let this = self {
        this.refreshLog("[double tap]")
      }
    }
    
    self.draggableButton.longPressBlock = {
      [weak self] in
      if let this = self {
        this.refreshLog("[longpress]")
      }
    }
    
    self.draggableButton.draggingBlock = {
      [weak self] in
      if let this = self {
        this.refreshLog("[dragging]")
      }
    }
    
    self.draggableButton.dragDoneBlock = {
      [weak self] in
      if let this = self {
        this.refreshLog("[drag done]")
      }
    }
    
    self.draggableButton.autoDockingBlock = {
      [weak self] in
      if let this = self {
        this.refreshLog("[auto docking]")
      }
    }
    
    self.draggableButton.autoDockingDoneBlock = {
      [weak self] in
      if let this = self {
        this.refreshLog("[auto docking done]")
      }
    }
  }
  
  @IBAction func cleanLogs(_ sender: AnyObject) {
    self.logInfo = "Log: "
    self.consoleLabel.text = self.logInfo
  }

  func refreshLog(_ logInfo: String) {
    if logSwitch.isOn {
      self.logInfo += logInfo
      self.consoleLabel.text = self.logInfo
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}

