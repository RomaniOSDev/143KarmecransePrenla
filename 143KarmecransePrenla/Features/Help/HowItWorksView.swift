import SwiftUI

struct HowItWorksView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("How it works")
                    .screenTitleStyle()
                Text("Short guides for each lane. Everything stays on the device—no accounts, no microphone.")
                    .bodyTextStyle()

                guideBlock(
                    title: "Beat Sync",
                    symbol: "waveform.path.ecg",
                    lines: [
                        "Watch the bead glide along the curved lane.",
                        "Tap when it lines up with the bright columns—timing tolerance depends on difficulty.",
                        "Tempo can lift after a few clean hits. Stay loose and breathe."
                    ]
                ) {
                    Canvas { context, size in
                        let midY = size.height * 0.55
                        var path = Path()
                        for i in 0...20 {
                            let x = CGFloat(i) / 20 * size.width
                            let y = midY + sin(CGFloat(i) * 0.35) * 14
                            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                            else { path.addLine(to: CGPoint(x: x, y: y)) }
                        }
                        context.stroke(path, with: .color(Color.appAccent.opacity(0.9)), lineWidth: 2)
                        let dot = Path(ellipseIn: CGRect(x: size.width * 0.55 - 6, y: midY + sin(11 * 0.35) * 14 - 6, width: 12, height: 12))
                        context.fill(dot, with: .color(Color.appPrimary))
                    }
                    .frame(height: 72)
                    .appSoftInsetPlate(cornerRadius: 14)
                }

                guideBlock(
                    title: "Melody Match",
                    symbol: "square.grid.3x3.fill",
                    lines: [
                        "Watch the highlighted cells in order.",
                        "Tap a cell for a single tone. Drag slightly farther to chain a neighbor in one motion.",
                        "Finish the full lane before judging your stars."
                    ]
                ) {
                    HStack(spacing: 6) {
                        ForEach(0..<4, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(i == 1 ? Color.appPrimary.opacity(0.85) : Color.appSurface.opacity(0.8))
                                .frame(height: 40)
                        }
                    }
                    .padding(10)
                    .appSoftInsetPlate(cornerRadius: 14)
                }

                guideBlock(
                    title: "Rhythm Puzzle",
                    symbol: "rectangle.3.group.fill",
                    lines: [
                        "Drag rows using the reorder control on the right.",
                        "Listen to the kit order in your head—align tiles top to bottom.",
                        "You can lock early if you are confident; otherwise the timer closes the lane."
                    ]
                ) {
                    VStack(spacing: 6) {
                        ForEach(0..<3, id: \.self) { row in
                            HStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.appSurface.opacity(0.85))
                                    .frame(height: 12)
                                Image(systemName: "line.3.horizontal")
                                    .foregroundStyle(Color.appTextSecondary)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(10)
                    .appSoftInsetPlate(cornerRadius: 14)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Label("Comfort", systemImage: "hand.tap.fill")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("Turn on Larger tap targets in Settings for wider note pads and difficulty rows. Optional Visual metronome pulse adds a soft ring during Beat Sync only.")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(8)
                        .minimumScaleFactor(0.75)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appElevatedPlate(cornerRadius: 18)
            }
            .screenPadding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func guideBlock<Diagram: View>(
        title: String,
        symbol: String,
        lines: [String],
        @ViewBuilder diagram: () -> Diagram
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: symbol)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.appAccent)
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
            }
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                Text("· \(line)")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(5)
                    .minimumScaleFactor(0.75)
            }
            diagram()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedPlate(cornerRadius: 20)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.appAccent.opacity(0.22), lineWidth: 1)
        )
    }
}
