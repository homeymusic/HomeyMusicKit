public class ModePicker: KeyboardInstrument {
    
    @MainActor
    public init() {        
        super.init(instrumentChoice: .modePicker,
                   defaultRows: 0, minRows: 0, maxRows: 0,
                   defaultCols: 6, minCols: 6, maxCols: 6)
    }
    
}
