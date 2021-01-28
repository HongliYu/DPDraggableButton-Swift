//
//  DPDraggableButton.swift
//  DPDraggableButtonDemo
//
//  Created by Hongli Yu on 8/11/16.
//  Copyright © 2016 Hongli Yu. All rights reserved.
//

import UIKit

public enum DPDraggableButtonType {
  case rect
  case round
}

let kDPAutoDockingDuration: Double = 0.2
let kDPDoubleTapTimeInterval: Double = 0.36

open class DPDraggableButton: UIButton {
  
  open var draggable = true
  open var dragging = false
  open var autoDocking = true
  open var singleTapBeenCanceled = false
  open var upperBoundsDistance: CGFloat = 120
  private(set) var rangeOutOfUpperBounds = false

  open var draggableButtonType = DPDraggableButtonType.rect
  
  open var beginLocation: CGPoint?
  open var longPressGestureRecognizer = UILongPressGestureRecognizer()
  
  open var tapBlock:(()->Void)? {
    set(tapBlock) {
      if let aTapBlock = tapBlock {
        self.tapBlockStored = aTapBlock
        self.addTarget(self, action: #selector(tapAction(_:)), for: .touchUpInside)
      }
    }
    get {
      return self.tapBlockStored!
    }
  }
  private var tapBlockStored:(()->Void)?
  
  open var doubleTapBlock:(()->Void)?
  open var longPressBlock:(()->Void)?
  open var draggingBlock:(()->Void)?
  open var dragDoneBlock:(()->Void)?
  open var autoDockingBlock:(()->Void)?
  open var autoDockingDoneBlock:(()->Void)?
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override open func awakeFromNib() {
    translatesAutoresizingMaskIntoConstraints = true
    super.awakeFromNib()
    config(.rect)
  }

  public init(frame: CGRect,
              draggableButtonType: DPDraggableButtonType) {
    super.init(frame: frame)
    self.config(draggableButtonType)
  }

  open func addButtonToKeyWindow() {
    if self.superview != nil {
      self.removeFromSuperview()
    }
    if let keyWindow = UIApplication.shared.keyWindow {
      keyWindow.addSubview(self)
    } else {
      UIApplication.shared.windows.first?.addSubview(self)
    }
  }

  open class func removeAllFromKeyWindow() {
    guard let subviews = UIApplication.shared.keyWindow?.subviews else { return }
    for case let button as DPDraggableButton in subviews {
      button.removeFromSuperview()
    }
  }

  open class func removeFromKeyWindow(button: DPDraggableButton) {
    guard let subviews = UIApplication.shared.keyWindow?.subviews else { return }
    subviews.filter { (view) -> Bool in
      view == button
    }.first?.removeFromSuperview()
  }

  /// During configuration, button will be added to key window,
  /// - Parameter type: DPDraggableButtonType
  private func config(_ type: DPDraggableButtonType) {
    addButtonToKeyWindow()
    draggableButtonType = type
    switch (type) {
    case .rect:
      break
    case .round:
      layer.cornerRadius = frame.size.height / 2.0
      layer.borderColor = UIColor.lightGray.cgColor
      layer.borderWidth = 0.5
      layer.masksToBounds = true
    }
    longPressGestureRecognizer.addTarget(self, action:#selector(longPressHandler(_:)) )
    longPressGestureRecognizer.allowableMovement = 0
    addGestureRecognizer(longPressGestureRecognizer)
  }
  
  // MARK: Gestures Handler
  @objc func longPressHandler(_ gesture: UILongPressGestureRecognizer) {
    switch gesture.state {
    case .began:
      longPressBlock?()
    default:
      break
    }
  }
  
  // MARK: Actions
  @objc func tapAction(_ sender: AnyObject) {
    let delayInSeconds: Double = (doubleTapBlock != nil ? kDPDoubleTapTimeInterval : 0)
    let popTime: DispatchTime = DispatchTime.now()
      + Double((Int64)(delayInSeconds * (Double)(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: popTime) { [weak self] in
      guard let strongSelf = self else { return }
      if let tapBlock = strongSelf.tapBlock,
         !strongSelf.singleTapBeenCanceled,
         !strongSelf.dragging {
        tapBlock()
      }
    }
  }
  
  // MARK: Touch
  open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    dragging = false
    super.touchesBegan(touches, with: event)
    guard let touch = touches.randomElement() else { return }
    if touch.tapCount == 2 {
      doubleTapBlock?()
      singleTapBeenCanceled = true
    } else {
      singleTapBeenCanceled = false
    }
    beginLocation = touch.location(in: self)
  }
  
  open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.randomElement(),
          let beginLocation = beginLocation,
          let superviewFrame = self.superview?.frame,
          draggable else { return }
    dragging = true

    guard self.frame.origin.y > upperBoundsDistance else {
      rangeOutOfUpperBounds = true
      return
    }

    let currentLocation = touch.location(in: self)
    let offsetX = currentLocation.x - beginLocation.x
    let offsetY = currentLocation.y - beginLocation.y
    center = CGPoint(x: center.x + offsetX, y: center.y + offsetY)

    let frame: CGRect = self.frame
    let leftLimitX: CGFloat = frame.size.width / 2.0
    let rightLimitX: CGFloat = superviewFrame.size.width - leftLimitX
    let topLimitY: CGFloat = frame.size.height / 2.0
    let bottomLimitY: CGFloat = superviewFrame.size.height - topLimitY

    if center.x > rightLimitX {
      center = CGPoint(x: rightLimitX, y: center.y)
    } else if (center.x <= leftLimitX) {
      center = CGPoint(x: leftLimitX, y: center.y)
    }

    if center.y > bottomLimitY {
      center = CGPoint(x: center.x, y: bottomLimitY)
    } else if (center.y <= topLimitY) {
      center = CGPoint(x: center.x, y: topLimitY)
    }
    draggingBlock?()
  }
  
  open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)

    if dragging, dragDoneBlock != nil {
      dragDoneBlock?()
      singleTapBeenCanceled = true
    }
    if dragging, autoDocking, let superviewFrame = self.superview?.frame {
      let frame: CGRect = self.frame
      let middleX = superviewFrame.size.width / 2.0
      
      if self.center.x >= middleX {
        UIView.animate(withDuration: kDPAutoDockingDuration, animations: { [weak self] in
          guard let strongSelf = self else { return }
          strongSelf.center = CGPoint(x: superviewFrame.size.width - frame.size.width / 2.0,
                                      y: strongSelf.center.y)
          strongSelf.autoDockingBlock?()
        },
        completion: {  [weak self] finished in
          guard let strongSelf = self else { return }
          strongSelf.autoDockingDoneBlock?()
        })
      } else {
        UIView.animate(withDuration: kDPAutoDockingDuration, animations: { [weak self] in
          guard let strongSelf = self else { return }
          strongSelf.center = CGPoint(x: frame.size.width / 2, y: strongSelf.center.y)
          strongSelf.autoDockingBlock?()
        },
        completion: {  [weak self] finished in
          guard let strongSelf = self else { return }
          strongSelf.autoDockingDoneBlock?()
        })
      }
    }
    if rangeOutOfUpperBounds {
      rangeOutOfUpperBounds.toggle()
      frame.origin.y = upperBoundsDistance + 0.5
    }
    dragging = false
  }
  
  open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    dragging = false
    super.touchesCancelled(touches, with:event)
  }

}
