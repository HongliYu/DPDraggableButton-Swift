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
  @IBOutlet var draggableButton: DPDraggableButton!
  
  private var logInfo: String = "Log:"

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    UIApplication.shared.keyWindow?.bringSubviewToFront(draggableButton)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    draggableButton.tapBlock = {
      [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.refreshLog("[single tap]")
    }
    
    draggableButton.doubleTapBlock = {
      [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.refreshLog("[double tap]")
    }
    
    draggableButton.longPressBlock = {
      [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.refreshLog("[longpress]")
    }
    
    draggableButton.draggingBlock = {
      [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.refreshLog("[dragging]")
    }
    
    draggableButton.dragDoneBlock = {
      [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.refreshLog("[drag done]")
    }
    
    draggableButton.autoDockingBlock = {
      [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.refreshLog("[auto docking]")
    }
    
    draggableButton.autoDockingDoneBlock = {
      [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.refreshLog("[auto docking done]")
    }
  }
  
  @IBAction func cleanLogs(_ sender: AnyObject) {
    logInfo = "Log: "
    consoleLabel.text = logInfo
  }

  func refreshLog(_ info: String) {
    guard logSwitch.isOn else { return }
    logInfo += info
    consoleLabel.text = logInfo
  }
  
}
