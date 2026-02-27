import SwiftUI

struct ModeInfoView: View {
    let mode: BreathingMode
    @Environment(\.dismiss) var dismiss

    private var infoData: (title: String, subtitle: String, ratio: String, detail: String, specialFeature: String?) {
        switch mode {
        case .calm:
            return (
                title: "Shanti — शान्ति",
                subtitle: "Peace and absolute balance.",
                ratio: "Sama Vritti (Equal Breath)",
                detail: "A practice of absolute balance. By making the Breathe In, the pause, and the release perfectly equal, we anchor ourselves in a state of unwavering calm.",
                specialFeature: "During the release phase, the device will emit a continuous, deep vibration—mimicking the 'Humming Bee Breath' to sustain your focus."
            )
        case .focus:
            return (
                title: "Dharana — धारणा",
                subtitle: "One-pointed concentration.",
                ratio: "Inspired by Nadi Shodhana",
                detail: "A practice that balances the mind and brings steady attention through the breath.",
                specialFeature: "Follow the voice guidance or on-screen text to alternately block your nostrils as the cycle progresses."
            )
        case .sleep:
            return (
                title: "Nidra — निद्रा",
                subtitle: "Yogic sleep and profound rest.",
                ratio: "Adapted from 4–7–8 calming breath",
                detail: "An extended calming rhythm. A natural tranquilizer for the body, signaling that it is safe to surrender to rest.",
                specialFeature: "During the release phase, the device will emit a continuous, deep vibration—mimicking the 'Humming Bee Breath' to sustain your calm."
            )
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {

                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: mode.iconName)
                            .font(.system(size: 48))
                            .foregroundColor(mode.color)
                            .padding(.bottom, 8)

                        Text(infoData.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text(infoData.subtitle)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 16)

                    VStack(alignment: .leading, spacing: 12) {
                        Label(infoData.ratio, systemImage: "timer")
                            .font(.headline)
                            .foregroundColor(mode.color)

                        Text(infoData.detail)
                            .font(.body)
                            .foregroundColor(.primary.opacity(0.8))
                            .lineSpacing(6)
                    }

                    if mode == .calm {
                        shantiDiagram
                            .padding(.vertical, 16)
                    } else if mode == .focus {
                        dharanaDiagram
                            .padding(.vertical, 16)
                    } else if mode == .sleep {
                        nidraDiagram
                            .padding(.vertical, 16)
                    }

                    if let special = infoData.specialFeature {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Special Feature", systemImage: "sparkles")
                                .font(.headline)
                                .foregroundColor(mode.color)

                            Text(special)
                                .font(.body)
                                .foregroundColor(.primary.opacity(0.8))
                                .lineSpacing(6)
                        }
                    }
                }
                .padding(24)
            }
            .scrollIndicators(.hidden)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.secondary)
                            .frame(width: 32, height: 32)
                    }
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }

    private var dharanaDiagram: some View {
        VStack(spacing: 16) {
            Canvas { ctx, size in
                let w = size.width
                let h = size.height
                let midX = w / 2
                let topY = h * 0.1
                let botY = h * 0.9

                var centerPath = Path()
                centerPath.move(to: CGPoint(x: midX, y: botY))
                centerPath.addLine(to: CGPoint(x: midX, y: topY))
                ctx.stroke(centerPath, with: .color(.primary.opacity(0.15)), lineWidth: 2)

                var leftPath = Path()
                leftPath.move(to: CGPoint(x: midX - 30, y: botY))
                leftPath.addCurve(to: CGPoint(x: midX, y: h * 0.6),
                                  control1: CGPoint(x: midX - 40, y: h * 0.8),
                                  control2: CGPoint(x: midX - 40, y: h * 0.7))
                leftPath.addCurve(to: CGPoint(x: midX + 30, y: h * 0.4),
                                  control1: CGPoint(x: midX + 40, y: h * 0.5),
                                  control2: CGPoint(x: midX + 40, y: h * 0.5))
                leftPath.addCurve(to: CGPoint(x: midX - 20, y: topY),
                                  control1: CGPoint(x: midX + 20, y: h * 0.3),
                                  control2: CGPoint(x: midX - 20, y: h * 0.2))
                ctx.stroke(leftPath, with: .color(.indigo.opacity(0.7)), style: StrokeStyle(lineWidth: 3, lineCap: .round))

                var rightPath = Path()
                rightPath.move(to: CGPoint(x: midX + 30, y: botY))
                rightPath.addCurve(to: CGPoint(x: midX, y: h * 0.6),
                                   control1: CGPoint(x: midX + 40, y: h * 0.8),
                                   control2: CGPoint(x: midX + 40, y: h * 0.7))
                rightPath.addCurve(to: CGPoint(x: midX - 30, y: h * 0.4),
                                   control1: CGPoint(x: midX - 40, y: h * 0.5),
                                   control2: CGPoint(x: midX - 40, y: h * 0.5))
                rightPath.addCurve(to: CGPoint(x: midX + 20, y: topY),
                                   control1: CGPoint(x: midX - 20, y: h * 0.3),
                                   control2: CGPoint(x: midX + 20, y: h * 0.2))
                ctx.stroke(rightPath, with: .color(BreathingMode.calm.color.opacity(0.7)), style: StrokeStyle(lineWidth: 3, lineCap: .round))

                ctx.fill(Path(ellipseIn: CGRect(x: midX - 4, y: botY - 4, width: 8, height: 8)), with: .color(.primary))
                ctx.fill(Path(ellipseIn: CGRect(x: midX - 4, y: h * 0.6 - 4, width: 8, height: 8)), with: .color(.primary))
                ctx.fill(Path(ellipseIn: CGRect(x: midX - 4, y: topY - 4, width: 8, height: 8)), with: .color(.primary))
            }
            .frame(height: 140)

            HStack {
                VStack(alignment: .leading) {
                    Text("Ida")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.indigo)
                    Text("Left / Rest")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Pingala")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(BreathingMode.calm.color)
                    Text("Right / Action")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 40)
        }
        .padding()
        .background(Color.primary.opacity(0.04))
        .cornerRadius(16)
    }

    private var shantiDiagram: some View {
        VStack(spacing: 8) {
            Text("Pause Full (4s)")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(BreathingMode.calm.color)

            HStack(spacing: 24) {
                Text("Breathe In\n(4s)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Canvas { ctx, size in
                    let r: CGFloat = 4
                    let rect = CGRect(origin: CGPoint(x: r, y: r), size: CGSize(width: size.width - r*2, height: size.height - r*2))
                    let path = Path(roundedRect: rect, cornerRadius: 8)
                    ctx.stroke(path, with: .color(BreathingMode.calm.color.opacity(0.8)), style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))

                    ctx.fill(Path(ellipseIn: CGRect(x: 0, y: 0, width: r*2, height: r*2)), with: .color(.primary))
                    ctx.fill(Path(ellipseIn: CGRect(x: size.width - r*2, y: 0, width: r*2, height: r*2)), with: .color(.primary))
                    ctx.fill(Path(ellipseIn: CGRect(x: size.width - r*2, y: size.height - r*2, width: r*2, height: r*2)), with: .color(.primary))
                    ctx.fill(Path(ellipseIn: CGRect(x: 0, y: size.height - r*2, width: r*2, height: r*2)), with: .color(.primary))
                }
                .frame(width: 80, height: 80)

                Text("Release\n(4s)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Text("Pause Empty (4s)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.primary.opacity(0.04))
        .cornerRadius(16)
    }

    private var nidraDiagram: some View {
        VStack(spacing: 16) {
            Canvas { ctx, size in
                let w = size.width
                let h = 100.0
                let startX: CGFloat = 10
                let endX: CGFloat = w - 10

                let totalTime: CGFloat = 19

                let p0 = CGPoint(x: startX, y: h - 10)
                let p1 = CGPoint(x: startX + ((4/totalTime) * (endX - startX)), y: 10)
                let p2 = CGPoint(x: startX + ((11/totalTime) * (endX - startX)), y: 10)
                let p3 = CGPoint(x: endX, y: h - 10)

                var path = Path()
                path.move(to: p0)
                path.addLine(to: p1)
                path.addLine(to: p2)
                path.addLine(to: p3)

                var fillPath = path
                fillPath.addLine(to: CGPoint(x: endX, y: h))
                fillPath.addLine(to: CGPoint(x: startX, y: h))
                fillPath.closeSubpath()

                let gradient = Gradient(colors: [.purple.opacity(0.3), .clear])
                ctx.fill(fillPath, with: .linearGradient(gradient, startPoint: CGPoint(x: w/2, y: 10), endPoint: CGPoint(x: w/2, y: h)))

                ctx.stroke(path, with: .color(.purple.opacity(0.8)), style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))

                let r: CGFloat = 4
                for p in [p0, p1, p2, p3] {
                    ctx.fill(Path(ellipseIn: CGRect(x: p.x - r, y: p.y - r, width: r*2, height: r*2)), with: .color(.primary))
                }
            }
            .frame(height: 100)

            HStack {
                Text("Breathe In 4s")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Pause 7s")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                Spacer()
                Spacer()
                Text("Release 8s")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
        }
        .padding()
        .background(Color.primary.opacity(0.04))
        .cornerRadius(16)
    }
}

#Preview {
    ModeInfoView(mode: .calm)
}
