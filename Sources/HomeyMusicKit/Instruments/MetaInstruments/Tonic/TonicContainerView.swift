import SwiftUI

public struct TonicContainerView: View {
    var pitch: Pitch
    
    var zIndex: Int
    var pitchView: PitchView
    var containerType: ContainerType
    
    init(
        pitch: Pitch,
        zIndex: Int = 0
    )
    {
        self.pitch = pitch
        self.zIndex = zIndex
        self.containerType = .tonicPicker
        self.pitchView = PitchView(
            pitch: pitch,
            containerType: containerType
        )
    }
    
    func rect(rect: CGRect) -> some View {
        pitchView
            .preference(key: TonicRectsKey.self,
                        value: [TonicRectInfo(rect: rect,
                                              midiNoteNumber: pitch.midiNote.number,
                                              zIndex: zIndex)])
    }
    
    public var body: some View {
        GeometryReader { proxy in
            rect(rect: proxy.frame(in: .named("TonicPickerSpace")))
        }
    }
}


