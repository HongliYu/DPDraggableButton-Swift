//
//  DPDraggableButton.swift
//  DPDraggableButtonDemo
//
//  Created by Hongli Yu on 8/11/16.
//  Copyright © 2016 Hongli Yu. All rights reserved.
//

import Foundation
import UIKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

public enum DPDraggableButtonType {
  case dpDraggableRect
  case dpDraggableRound
  var description: String {
    switch self {
    case .dpDraggableRect:
      return "DPDraggableRect"
    case .dpDraggableRound:
      return "DPDraggableRound"
    }
  }
}

let kDPAutoDockingDuration: Double = 0.2
let kDPDoubleTapTimeInterval: Double = 0.36

open class DPDraggableButton: UIButton {
  var draggable: Bool = true
  var dragging: Bool = false
  var autoDocking: Bool = true
  var singleTapBeenCanceled: Bool = false
  var draggableButtonType: DPDraggableButtonType = .dpDraggableRect
  
  var beginLocation: CGPoint?
  var longPressGestureRecognizer: UILongPressGestureRecognizer?
  
  // actions call back
  var tapBlock:(()->Void)? { // computed
    set(tapBlock) {
      if let aTapBlock = tapBlock {
        self.tapBlockStored = aTapBlock
        self.addTarget(self, action: #selector(tapAction(_:)),
                       for: .touchUpInside)
      }
    }
    get {
      return self.tapBlockStored!
    }
  }
  fileprivate var tapBlockStored:(()->Void)?
  
  var doubleTapBlock:(()->Void)?
  var longPressBlock:(()->Void)?
  var draggingBlock:(()->Void)?
  var dragDoneBlock:(()->Void)?
  var autoDockingBlock:(()->Void)?
  var autoDockingDoneBlock:(()->Void)?
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
    self.translatesAutoresizingMaskIntoConstraints = true // TODO: // warnings, fixed constraints by ib
    self.configDefaultSettingWithType(.dpDraggableRect)
  }
  
  public init() {
    super.init(frame: CGRect.zero)
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
  
  open func addButtonToKeyWindow() {
    if let keyWindow = UIApplication.shared.keyWindow {
      keyWindow.addSubview(self)
    } else if (UIApplication.shared.windows.first != nil) {
      UIApplication.shared.windows.first?.addSubview(self)
    }
  }
  
  fileprivate func configDefaultSettingWithType(_ type: DPDraggableButtonType) {
    // type
    self.draggableButtonType = type
    
    // shape
    switch (type) {
    case .dpDraggableRect:
      break
    case .dpDraggableRound:
      self.layer.cornerRadius = self.frame.size.height / 2.0
      self.layer.borderColor = UIColor.lightGray.cgColor
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
  func longPressHandler(_ gesture: UILongPressGestureRecognizer) {
    switch gesture.state {
    case .began:
      if let longPressBlock = self.longPressBlock {
        longPressBlock()
      }
      break
    default:
      break
    }
  }
  
  // MARK: Actions
  func tapAction(_ sender: AnyObject) {
    let delayInSeconds: Double = (self.doubleTapBlock != nil ? kDPDoubleTapTimeInterval : 0)
    let popTime: DispatchTime = DispatchTime.now() + Double((Int64)(delayInSeconds * (Double)(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: popTime) {
      if let tapBlock = self.tapBlock {
        if (!self.singleTapBeenCanceled
          && !self.dragging) {
          tapBlock();
        }
      }
    }
  }
  
  // MARK: Touch
  open override func touchesBegan(_ touches: Set<UITouch>,
                                    with event: UIEvent?) {
    self.dragging = false
    super.touchesBegan(touches, with: event)
    let touch: UITouch? = (touches as NSSet).anyObject() as? UITouch
    if touch?.tapCount == 2 {
      self.doubleTapBlock?()
      self.singleTapBeenCanceled = true
    } else {
      self.singleTapBeenCanceled = false
    }
    self.beginLocation = ((touches as NSSet).anyObject() as? UITouch)?.location(in: self)
  }
  
  open override func touchesMoved(_ touches: Set<UITouch>,
                                    with event: UIEvent?) {
    if self.draggable  {
      self.dragging = true
      let touch: UITouch? = (touches as NSSet).anyObject() as? UITouch
      let currentLocation: CGPoint? = touch?.location(in: self)
      
      let offsetX: CGFloat? = (currentLocation?.x)! - (self.beginLocation?.x)!
      let offsetY: CGFloat? = (currentLocation?.y)! - (self.beginLocation?.y)!
      self.center = CGPoint(x: self.center.x + offsetX!, y: self.center.y + offsetY!)
      
      let superviewFrame: CGRect? = self.superview?.frame
      let frame: CGRect = self.frame
      let leftLimitX: CGFloat = frame.size.width / 2.0
      let rightLimitX: CGFloat? = (superviewFrame?.size.width)! - leftLimitX
      let topLimitY: CGFloat = frame.size.height / 2.0
      let bottomLimitY: CGFloat? = (superviewFrame?.size.height)! - topLimitY
      
      if (self.center.x > rightLimitX) {
        self.center = CGPoint(x: rightLimitX!, y: self.center.y)
      } else if (self.center.x <= leftLimitX) {
        self.center = CGPoint(x: leftLimitX, y: self.center.y)
      }
      
      if (self.center.y > bottomLimitY) {
        self.center = CGPoint(x: self.center.x, y: bottomLimitY!)
      } else if (self.center.y <= topLimitY) {
        self.center = CGPoint(x: self.center.x, y: topLimitY)
      }
      
      self.draggingBlock?()
    }
  }
  
  open override func touchesEnded(_ touches: Set<UITouch>,
                                    with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    if (self.dragging && self.dragDoneBlock != nil) {
      self.dragDoneBlock!()
      self.singleTapBeenCanceled = true;
    }
    if (self.dragging && self.autoDocking) {
      let superviewFrame: CGRect? = self.superview?.frame
      let frame: CGRect = self.frame
      let middleX: CGFloat? = (superviewFrame?.size.width)! / 2.0
      if (self.center.x >= middleX!) {
        UIView.animate(withDuration: kDPAutoDockingDuration,
                                   animations: {
                                    self.center = CGPoint(x: (superviewFrame?.size.width)! - frame.size.width / 2.0, y: self.center.y)
                                    self.autoDockingBlock?()
          },
                                   completion: { (finished) in
                                    self.autoDockingDoneBlock?()
        })
      } else {
        UIView.animate(withDuration: kDPAutoDockingDuration,
                                   animations: {
                                    self.center = CGPoint(x: frame.size.width / 2, y: self.center.y)
                                    self.autoDockingBlock?()
          },
                                   completion: { (finished) in
                                    self.autoDockingDoneBlock?()
        })
      }
    }
    self.dragging = false
  }
  
  open override func touchesCancelled(_ touches: Set<UITouch>,
                                        with event: UIEvent?) {
    self.dragging = false
    super.touchesCancelled(touches, with:event)
  }
  
  // MARK: Remove
  class func removeAllFromKeyWindow() {
    if let subviews = UIApplication.shared.keyWindow?.subviews {
      for view: AnyObject in subviews {
        if view.isKind(of: DPDraggableButton.self) {
          view.removeFromSuperview()
        }
      }
    }
  }
  
  class func removeAllFromView(_ superView : AnyObject) {
    if let subviews = superView.subviews {
      for view: AnyObject in subviews {
        if view.isKind(of: DPDraggableButton.self) {
          view.removeFromSuperview()
        }
      }
    }
  }
}
