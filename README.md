# DPDraggableButton-Swift
Drag or tap the button to trigger Gesture event

[![Cocoapods](https://img.shields.io/cocoapods/v/DPDraggableButton.svg)](http://cocoapods.org/?q=DPDraggableButton)
[![Pod License](http://img.shields.io/cocoapods/l/DPDraggableButton.svg)](https://github.com/HongliYu/DPDraggableButton-Swift/blob/master/LICENSE)

![screenshot](https://github.com/HongliYu/DPDraggableButton-Swift/blob/master/DPDraggableButton.gif?raw=true)

# Usage

```  swift
    draggableButton.tapBlock = {
        print("[single tap]")
    }
    
    draggableButton.doubleTapBlock = {
        print("[double tap]")
    }
    
    draggableButton.longPressBlock = {
        print("[longpress]")
    }
    
    draggableButton.draggingBlock = {
        print("[dragging]")
    }
    
    draggableButton.dragDoneBlock = {
        print("[drag done]")
    }
    
    draggableButton.autoDockingBlock = {
        print("[auto docking]")
    }
    
    draggableButton.autoDockingDoneBlock = {
        print("[auto docking done]")
    }
