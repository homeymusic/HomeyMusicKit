import SwiftUI

public typealias TouchCallback = ([CGPoint]) -> Void

#if os(macOS)
import AppKit

struct PitchMultitouchView: NSViewRepresentable {
    var callback: TouchCallback = { _ in }
    
    func makeNSView(context: Context) -> PitchMultitouchViewMac {
        let view = PitchMultitouchViewMac()
        view.callback = callback
        return view
    }
    
    func updateNSView(_ nsView: PitchMultitouchViewMac, context: Context) {
        nsView.callback = callback
    }
}

class PitchMultitouchViewMac: NSView {
    
    override var isFlipped: Bool { return true }
    
    var callback: TouchCallback = { _ in }
    
    // When the mouse is pressed, call the callback with the location.
    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        callback([point])
    }
    
    // As the mouse is dragged, send updates.
    override func mouseDragged(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        callback([point])
    }
    
    // When the mouse is released, send an empty array.
    override func mouseUp(with event: NSEvent) {
        callback([])
    }
}
#else
import UIKit

class PitchMultitouchViewIOS: UIView {
    var callback: TouchCallback = { _ in }
    var touches = Set<UITouch>()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touches.formUnion(touches)
        callback(self.touches.map { $0.location(in: self) })
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        callback(self.touches.map { $0.location(in: self) })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touches.subtract(touches)
        callback(self.touches.map { $0.location(in: self) })
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touches.subtract(touches)
        callback(self.touches.map { $0.location(in: self) })
    }
}

struct PitchMultitouchView: UIViewRepresentable {
    var callback: TouchCallback = { _ in }
    
    func makeUIView(context: Context) -> PitchMultitouchViewIOS {
        let view = PitchMultitouchViewIOS()
        view.callback = callback
        view.isMultipleTouchEnabled = true
        return view
    }
    
    func updateUIView(_ uiView: PitchMultitouchViewIOS, context: Context) {
        uiView.callback = callback
    }
}
#endif
