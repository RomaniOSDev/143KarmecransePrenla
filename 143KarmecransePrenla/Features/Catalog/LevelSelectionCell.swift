import SwiftUI

/// Custom level pick row: badge, stars, lane progress, activity accent, lock overlay.
struct LevelSelectionCell: View {
    let kind: ActivityKind
    let level: Int
    let stars: Int
    let locked: Bool

    private var stageProgress: Double {
        Double(level) / Double(ActivityProgress.levelCount)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appSurface.opacity(locked ? 0.5 : 0.98),
                            Color.appSurface.opacity(locked ? 0.32 : 0.68),
                            Color.appBackground.opacity(locked ? 0.4 : 0.52)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [accent.opacity(0.9), Color.appPrimary.opacity(0.35)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: locked ? 1 : 1.5
                )

            HStack(alignment: .center, spacing: 14) {
                levelBadge

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Level")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.appTextSecondary)
                            .textCase(.uppercase)
                            .tracking(0.6)
                        Text("\(level)")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Spacer(minLength: 0)
                        activityGlyph
                    }

                    starRow

                    laneProgressBar

                    decorativeLane
                        .frame(height: 22)
                        .opacity(locked ? 0.25 : 0.9)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            if locked {
                lockOverlay
            }
        }
        .frame(maxWidth: .infinity, minHeight: 118)
        .appDepthShadowMedium()
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var accent: Color {
        switch kind {
        case .beatSync: return Color.appAccent
        case .melodyMatch: return Color.appPrimary
        case .rhythmPuzzle: return Color.appAccent
        }
    }

    private var activityGlyph: some View {
        Image(systemName: kind.symbolName)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(accent.opacity(locked ? 0.4 : 1))
            .frame(width: 36, height: 36)
            .background(
                Circle()
                    .fill(Color.appBackground.opacity(0.55))
            )
    }

    private var levelBadge: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.appBackground.opacity(0.9), Color.appSurface.opacity(0.95)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            Circle()
                .strokeBorder(
                    AngularGradient(
                        gradient: Gradient(colors: [accent, Color.appPrimary, accent.opacity(0.55), accent]),
                        center: .center,
                        angle: .degrees(0)
                    ),
                    lineWidth: 3
                )
                .rotationEffect(.degrees(locked ? 0 : 12))

            Text("\(level)")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundStyle(locked ? Color.appTextSecondary : Color.appTextPrimary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(width: 64, height: 64)
        .shadow(color: accent.opacity(locked ? 0 : 0.35), radius: locked ? 0 : 8, y: 2)
    }

    private var starRow: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                let filled = index < stars
                Image(systemName: filled ? "star.fill" : "star")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(filled ? Color.appAccent : Color.appTextSecondary.opacity(0.35))
                    .shadow(color: filled ? Color.appAccent.opacity(0.55) : .clear, radius: 4)
            }
            Spacer(minLength: 0)
            Text(starsLabel)
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private var starsLabel: String {
        switch stars {
        case 0: return "Not cleared"
        case 1: return "One star"
        case 2: return "Two stars"
        default: return "Three stars"
        }
    }

    private var laneProgressBar: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.appBackground.opacity(0.65))
                    .frame(height: 6)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.appAccent, Color.appPrimary.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(8, w * stageProgress), height: 6)
            }
        }
        .frame(height: 6)
    }

    private var decorativeLane: some View {
        Canvas { context, size in
            let midY = size.height * 0.5
            let count = 24
            for index in 0..<count {
                let x = CGFloat(index) / CGFloat(count - 1) * size.width
                let phase = Double(level) * 0.15 + Double(index) * 0.08
                let h = 4 + sin(phase) * 6 + (index < Int(stageProgress * Double(count)) ? 4.0 : 0)
                let rect = CGRect(x: x - 1.5, y: midY - CGFloat(h) * 0.5, width: 3, height: CGFloat(h))
                let path = Path(roundedRect: rect, cornerRadius: 1.5)
                let opacity = index < Int(stageProgress * Double(count)) ? 0.85 : 0.28
                context.fill(path, with: .color(accent.opacity(opacity)))
            }
        }
    }

    private var lockOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.appBackground.opacity(0.52))

            VStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Text("Clear previous")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(12)
        }
        .allowsHitTesting(false)
    }
}
