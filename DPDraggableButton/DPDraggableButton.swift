//
//  DPDraggableButton.swift
//  DPDraggableButtonDemo
//
//  Created by Hongli Yu on 8/11/16.
//  Copyright © 2016 Hongli Yu. All rights reserved.
//

import Foundation
import UIKit

public enum DPDraggableButtonType {
  case DPDraggableRect
  case DPDraggableRound
  var description: String {
    switch self {
    case .DPDraggableRect:
      return "DPDraggableRect"
    case .DPDraggableRound:
      return "DPDraggableRound"
    }
  }
}

let kDPAutoDockingDuration: Double = 0.2
let kDPDoubleTapTimeInterval: Double = 0.36

public class DPDraggableButton: UIButton {
  var draggable: Bool = true
  var dragging: Bool = false
  var autoDocking: Bool = true
  var singleTapBeenCanceled: Bool = false
  var draggableButtonType: DPDraggableButtonType = .DPDraggableRect
  
  var beginLocation: CGPoint?
  var longPressGestureRecognizer: UILongPressGestureRecognizer?
  
  // actions call back
  var tapBlock:(()->Void)? { // computed
    set(tapBlock) {
      if let aTapBlock = tapBlock {
        self.tapBlockStored = aTapBlock
        self.addTarget(self, action: #selector(tapAction(_:)),
                       forControlEvents: .TouchUpInside)
      }
    }
    get {
      return self.tapBlockStored!
    }
  }
  private var tapBlockStored:(()->Void)?
  
  var doubleTapBlock:(()->Void)?
  var longPressBlock:(()->Void)?
  var draggingBlock:(()->Void)?
  var dragDoneBlock:(()->Void)?
  var autoDockingBlock:(()->Void)?
  var autoDockingDoneBlock:(()->Void)?
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
    self.translatesAutoresizingMaskIntoConstraints = true // TODO: // warnings, fixed constraints by ib
    self.configDefaultSettingWithType(.DPDraggableRect)
  }
  
  public init() {
    super.init(frame: CGRectZero)
  }
  
  public init(frame: CGRect,
              draggableButtonType: DPDraggableButtonType) {
    super.init(frame: frame)
    self.addButtonToKeyWindow()
    self.configDefaultSettingWithType(draggableButtonType)
  }
  
  public init(view: AnyObject, frame: CGRect,
              draggableButtonType: DPDraggableButtonType) {
    super.init(frame: frame)
    view.addSubview(self)
    self.configDefaultSettingWithType(draggableButtonType)
  }
  
  public func addButtonToKeyWindow() {
    if let keyWindow = UIApplication.sharedApplication().keyWindow {
      keyWindow.addSubview(self)
    } else if (UIApplication.sharedApplication().windows.first != nil) {
      UIApplication.sharedApplication().windows.first?.addSubview(self)
    }
  }
  
  private func configDefaultSettingWithType(type: DPDraggableButtonType) {
    // type
    self.draggableButtonType = type
    
    // shape
    switch (type) {
    case .DPDraggableRect:
      break
    case .DPDraggableRound:
      self.layer.cornerRadius = self.frame.size.height / 2.0
      self.layer.borderColor = UIColor.lightGrayColor().CGColor
      self.layer.borderWidth = 0.5
      self.layer.masksToBounds = true
    }
    
    // gestures
    self.longPressGestureRecognizer = UILongPressGestureRecognizer.init()
    if let longPressGestureRecognizer = self.longPressGestureRecognizer {
      longPressGestureRecognizer.addTarget(self, action:#selector(longPressHandler(_:)) )
      longPressGestureRecognizer.allowableMovement = 0
      self.addGestureRecognizer(longPressGestureRecognizer)
    }
  }
  
  // MARK: Gestures Handler
  func longPressHandler(gesture: UILongPressGestureRecognizer) {
    switch gesture.state {
    case .Began:
      if let longPressBlock = self.longPressBlock {
        longPressBlock()
      }
      break
    default:
      break
    }
  }
  
  // MARK: Actions
  func tapAction(sender: AnyObject) {
    let delayInSeconds: Double = (self.doubleTapBlock != nil ? kDPDoubleTapTimeInterval : 0)
    let popTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,
                                                 (Int64)(delayInSeconds * (Double)(NSEC_PER_SEC)))
    dispatch_after(popTime, dispatch_get_main_queue()) {
      if let tapBlock = self.tapBlock {
        if (!self.singleTapBeenCanceled
          && !self.dragging) {
          tapBlock();
        }
      }
    }
  }
  
  // MARK: Touch
  public override func touchesBegan(touches: Set<UITouch>,
                                    withEvent event: UIEvent?) {
    self.dragging = false
    super.touchesBegan(touches, withEvent: event)
    let touch: UITouch? = (touches as NSSet).anyObject() as? UITouch
    if touch?.tapCount == 2 {
      self.doubleTapBlock?()
      self.singleTapBeenCanceled = true
    } else {
      self.singleTapBeenCanceled = false
    }
    self.beginLocation = (touches as NSSet).anyObject()?.locationInView(self)
  }
  
  public override func touchesMoved(touches: Set<UITouch>,
                                    withEvent event: UIEvent?) {
    if self.draggable  {
      self.dragging = true
      let touch: UITouch? = (touches as NSSet).anyObject() as? UITouch
      let currentLocation: CGPoint? = touch?.locationInView(self)
      
      let offsetX: CGFloat? = (currentLocation?.x)! - (self.beginLocation?.x)!
      let offsetY: CGFloat? = (currentLocation?.y)! - (self.beginLocation?.y)!
      self.center = CGPointMake(self.center.x + offsetX!, self.center.y + offsetY!)
      
      let superviewFrame: CGRect? = self.superview?.frame
      let frame: CGRect = self.frame
      let leftLimitX: CGFloat = frame.size.width / 2.0
      let rightLimitX: CGFloat? = (superviewFrame?.size.width)! - leftLimitX
      let topLimitY: CGFloat = frame.size.height / 2.0
      let bottomLimitY: CGFloat? = (superviewFrame?.size.height)! - topLimitY
      
      if (self.center.x > rightLimitX) {
        self.center = CGPointMake(rightLimitX!, self.center.y)
      } else if (self.center.x <= leftLimitX) {
        self.center = CGPointMake(leftLimitX, self.center.y)
      }
      
      if (self.center.y > bottomLimitY) {
        self.center = CGPointMake(self.center.x, bottomLimitY!)
      } else if (self.center.y <= topLimitY) {
        self.center = CGPointMake(self.center.x, topLimitY)
      }
      
      self.draggingBlock?()
    }
  }
  
  public override func touchesEnded(touches: Set<UITouch>,
                                    withEvent event: UIEvent?) {
    super.touchesEnded(touches, withEvent: event)
    
    if (self.dragging && self.dragDoneBlock != nil) {
      self.dragDoneBlock!()
      self.singleTapBeenCanceled = true;
    }
    if (self.dragging && self.autoDocking) {
      let superviewFrame: CGRect? = self.superview?.frame
      let frame: CGRect = self.frame
      let middleX: CGFloat? = (superviewFrame?.size.width)! / 2.0
      if (self.center.x >= middleX!) {
        UIView.animateWithDuration(kDPAutoDockingDuration,
                                   animations: {
                                    self.center = CGPointMake((superviewFrame?.size.width)! - frame.size.width / 2.0, self.center.y)
                                    self.autoDockingBlock?()
          },
                                   completion: { (finished) in
                                    self.autoDockingDoneBlock?()
        })
      } else {
        UIView.animateWithDuration(kDPAutoDockingDuration,
                                   animations: {
                                    self.center = CGPointMake(frame.size.width / 2, self.center.y)
                                    self.autoDockingBlock?()
          },
                                   completion: { (finished) in
                                    self.autoDockingDoneBlock?()
        })
      }
    }
    self.dragging = false
  }
  
  public override func touchesCancelled(touches: Set<UITouch>?,
                                        withEvent event: UIEvent?) {
    self.dragging = false
    super.touchesCancelled(touches, withEvent:event)
  }
  
  // MARK: Remove
  class func removeAllFromKeyWindow() {
    if let subviews = UIApplication.sharedApplication().keyWindow?.subviews {
      for view: AnyObject in subviews {
        if view.isKindOfClass(DPDraggableButton) {
          view.removeFromSuperview()
        }
      }
    }
  }
  
  class func removeAllFromView(superView : AnyObject) {
    if let subviews = superView.subviews {
      for view: AnyObject in subviews {
        if view.isKindOfClass(DPDraggableButton) {
          view.removeFromSuperview()
        }
      }
    }
  }
}
