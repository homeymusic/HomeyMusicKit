public class ModePicker: KeyboardInstrument {
    
    public init() {
        super.init(pickerChoice: .modePicker,
                   defaultRows: 0, minRows: 0, maxRows: 0,
                   defaultCols: 6, minCols: 6, maxCols: 6)
    }
    
}
