//
//  ToggleButton.swift
//  Aspirin
//
//  Created by HamGuy on 8/30/16.
//
//

import UIKit

class ToggleButton: UIButton {
    
    fileprivate var onImage: UIImage?
    fileprivate var offImage: UIImage?
    fileprivate var highlightedImage: UIImage?
    fileprivate var isOn: Bool = false

    @IBInspectable var onStatusTextForAccessibility:String!
    @IBInspectable var offStatusTextForAccessibility:String!

    var autotoggleEnabled: Bool = true
    var on:Bool{
        get{
            return isOn
        }
        set{
            if isOn == newValue{
                return
            }
            
            isOn = newValue
            accessibilityLabel = isOn ? onStatusTextForAccessibility : offStatusTextForAccessibility
            setImage(isOn ? onImage : offImage, for: UIControlState())
            if let hImage = highlightedImage{
                setImage(hImage, for: .highlighted)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autotoggleEnabled = true
        onImage = image(for: .selected)
        offImage = image(for: UIControlState())
        highlightedImage = image(for: .highlighted)
        if let hImage = highlightedImage{
            setImage(hImage, for: .highlighted)
        }
        accessibilityLabel = on ? onStatusTextForAccessibility : offStatusTextForAccessibility
        setImage(nil, for: .selected)
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        if isTouchInside && autotoggleEnabled{
            toggle()
        }
    }
    
    func toggle() -> Bool{
        on = !on
        return on
    }
}

extension ToggleButton{
    class func buttonWithOnImage(_ onImage: UIImage?, offImage: UIImage?, highlightedImage: UIImage?) -> ToggleButton{
        let button = ToggleButton(type: .custom)
        button.onImage = onImage
        button.offImage = offImage
        button.highlightedImage = highlightedImage
        button.setImage(offImage, for: UIControlState())
        if let hImage = highlightedImage{
            button.setImage(hImage, for: .highlighted)
        }else{
            button.setImage(onImage, for: .highlighted)
        }
        return button
    }
}
