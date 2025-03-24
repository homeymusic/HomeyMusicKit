import SwiftUI

public typealias TouchCallback = ([CGPoint]) -> Void

#if os(macOS)
import AppKit

struct PitchKeyMultitouchView: NSViewRepresentable {
    var callback: TouchCallback = { _ in }
    
    func makeNSView(context: Context) -> PitchKeyMultitouchViewMac {
        let view = PitchKeyMultitouchViewMac()
        view.callback = callback
        return view
    }
    
    func updateNSView(_ nsView: PitchKeyMultitouchViewMac, context: Context) {
        nsView.callback = callback
    }
}

class PitchKeyMultitouchViewMac: NSView {
    
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

class PitchKeyMultitouchViewIOS: UIView {
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

struct PitchKeyMultitouchView: UIViewRepresentable {
    var callback: TouchCallback = { _ in }
    
    func makeUIView(context: Context) -> PitchKeyMultitouchViewIOS {
        let view = PitchKeyMultitouchViewIOS()
        view.callback = callback
        view.isMultipleTouchEnabled = true
        return view
    }
    
    func updateUIView(_ uiView: PitchKeyMultitouchViewIOS, context: Context) {
        uiView.callback = callback
    }
}
#endif
