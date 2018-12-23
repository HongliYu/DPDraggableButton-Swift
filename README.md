# DPDraggableButton-Swift
Drag or tap the button to trigger Gesture event

[![Cocoapods](https://img.shields.io/cocoapods/v/DPDraggableButton.svg)](http://cocoapods.org/?q=DPDraggableButton)
[![Pod License](http://img.shields.io/cocoapods/l/DPDraggableButton.svg)](https://github.com/HongliYu/DPDraggableButton-Swift/blob/master/LICENSE)

![screenshot](https://github.com/HongliYu/DPDraggableButton-Swift/blob/master/DPDraggableButton.gif?raw=true)

# Usage

```  swift
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

