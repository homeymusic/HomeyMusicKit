import SwiftUI

public struct RowsColsPickerView: View {
    let keyboardInstrument: any KeyboardInstrument    
    public init(keyboardInstrument: KeyboardInstrument) {
        self.keyboardInstrument = keyboardInstrument
    }
    public var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                keyboardInstrument.moreRows()
                buzz()
            }) {
                ZStack {
                    Color.clear.overlay(
                        Image(systemName: "arrow.up.and.line.horizontal.and.arrow.down")
                            .foregroundColor(keyboardInstrument.moreRowsAreAvailable ? .white : .gray)
                            .font(Font.system(size: .leastNormalMagnitude, weight: keyboardInstrument.moreRowsAreAvailable ? .regular : .thin))
                    )
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(width: 44)
                }
            }
            .disabled(!keyboardInstrument.moreRowsAreAvailable)
            
            Divider()
                .frame(width: 1, height: 17.5)
                .overlay(Color.systemGray4)
            
            Button(action: {
                keyboardInstrument.fewerRows()
                buzz()
            }) {
                ZStack {
                    Color.clear.overlay(
                        Image(systemName: "arrow.down.and.line.horizontal.and.arrow.up")
                            .foregroundColor(keyboardInstrument.fewerRowsAreAvailable ? .white : .gray)
                            .font(Font.system(size: .leastNormalMagnitude, weight: keyboardInstrument.fewerRowsAreAvailable ? .regular : .thin))
                    )
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(width: 44)
                }
            }
            .disabled(!keyboardInstrument.fewerRowsAreAvailable)
            
            Divider()
                .frame(width: 1, height: 17.5)
                .overlay(Color.systemGray4)
            
            Button(action: {
                keyboardInstrument.resetRowsCols()
                buzz()
            }) {
                ZStack {
                    Color.clear.overlay(
                        Image(systemName: "gobackward")
                            .foregroundColor(keyboardInstrument.rowColsAreDefault ? .gray : .white)
                            .font(Font.system(size: .leastNormalMagnitude, weight: keyboardInstrument.rowColsAreDefault ? .thin : .regular))
                    )
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(width: 44)
                }
            }
            .disabled(keyboardInstrument.rowColsAreDefault)
            
            Divider()
                .frame(width: 1, height: 17.5)
                .overlay(Color.systemGray4)
            
            Button(action: {
                keyboardInstrument.fewerCols()
                buzz()
            }) {
                ZStack {
                    Color.clear.overlay(
                        Image(systemName: "arrow.right.and.line.vertical.and.arrow.left")
                            .foregroundColor(keyboardInstrument.fewerColsAreAvailable ? .white : .gray)
                            .font(Font.system(size: .leastNormalMagnitude, weight: keyboardInstrument.fewerColsAreAvailable ? .regular : .thin))
                    )
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(width: 44)
                }
            }
            .disabled(!keyboardInstrument.fewerColsAreAvailable)
            
            Divider()
                .frame(width: 1, height: 17.5)
                .overlay(Color.systemGray4)
            
            Button(action: {
                keyboardInstrument.moreCols()
                buzz()
            }) {
                ZStack {
                    Color.clear.overlay(
                        Image(systemName: "arrow.left.and.line.vertical.and.arrow.right")
                            .foregroundColor(keyboardInstrument.moreColsAreAvailable ? .white : .gray)
                            .font(Font.system(size: .leastNormalMagnitude, weight: keyboardInstrument.moreColsAreAvailable ? .regular : .thin))
                    )
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(width: 44)
                }
            }
            .disabled(!keyboardInstrument.moreColsAreAvailable)
        }
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.systemGray6)
        )
    }
}
