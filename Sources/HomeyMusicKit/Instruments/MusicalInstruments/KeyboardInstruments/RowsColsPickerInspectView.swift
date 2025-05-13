import SwiftUI

public struct RowsColsPickerInspectView: View {
    let keyboardInstrument: any KeyboardInstrument

    public init(keyboardInstrument: KeyboardInstrument) {
        self.keyboardInstrument = keyboardInstrument
    }

    public var body: some View {
        VStack(spacing: 10) {
            // ROWS
            HStack {
                Button(action: {
                    keyboardInstrument.moreRows()
                    buzz()
                }) {
                    Image(systemName: "arrow.up.and.line.horizontal.and.arrow.down")
                        .foregroundColor(keyboardInstrument.moreRowsAreAvailable ? .white : .gray)
                        .font(.body.weight(keyboardInstrument.moreRowsAreAvailable ? .regular : .thin))
                }
                .disabled(!keyboardInstrument.moreRowsAreAvailable)

                Button(action: {
                    keyboardInstrument.fewerRows()
                    buzz()
                }) {
                    Image(systemName: "arrow.down.and.line.horizontal.and.arrow.up")
                        .foregroundColor(keyboardInstrument.fewerRowsAreAvailable ? .white : .gray)
                        .font(.body.weight(keyboardInstrument.fewerRowsAreAvailable ? .regular : .thin))
                }
                .disabled(!keyboardInstrument.fewerRowsAreAvailable)
            }

            // COLUMNS
            HStack {
                Button(action: {
                    keyboardInstrument.moreCols()
                    buzz()
                }) {
                    Image(systemName: "arrow.left.and.line.vertical.and.arrow.right")
                        .foregroundColor(keyboardInstrument.moreColsAreAvailable ? .white : .gray)
                        .font(.body.weight(keyboardInstrument.moreColsAreAvailable ? .regular : .thin))
                }
                .disabled(!keyboardInstrument.moreColsAreAvailable)

                Button(action: {
                    keyboardInstrument.fewerCols()
                    buzz()
                }) {
                    Image(systemName: "arrow.right.and.line.vertical.and.arrow.left")
                        .foregroundColor(keyboardInstrument.fewerColsAreAvailable ? .white : .gray)
                        .font(.body.weight(keyboardInstrument.fewerColsAreAvailable ? .regular : .thin))
                }
                .disabled(!keyboardInstrument.fewerColsAreAvailable)
            }

            Button(action: {
                keyboardInstrument.resetRowsCols()
                buzz()
            }) {
                Image(systemName: "gobackward")
                    .foregroundColor(keyboardInstrument.rowColsAreDefault ? .gray : .white)
                    .font(.body.weight(keyboardInstrument.rowColsAreDefault ? .thin : .regular))
            }
            .disabled(keyboardInstrument.rowColsAreDefault)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.systemGray6)
        )
    }
}
