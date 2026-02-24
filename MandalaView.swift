import SwiftUI

enum MandalaStyle {
    case lotus   // Shanti — 8-petal flowers, jaal grid
    case yantra  // Dharana — 6-pointed stars, geometric grid
    case chandra // Nidra — crescent arcs with dots, wave grid
}

/// Full-card block-print pattern — tiles small motifs across the entire surface
/// like traditional Indian fabric printing (Jaipur block print style).
struct MandalaView: View {

    var style: MandalaStyle
    var color: Color = .white
    var opacity: Double = 0.09

    var body: some View {
        Canvas { ctx, size in
            switch style {
            case .lotus:   drawLotus(ctx, size)
            case .yantra:  drawYantra(ctx, size)
            case .chandra: drawChandra(ctx, size)
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Lotus — Single large 8-petal flower

    private func drawLotus(_ ctx: GraphicsContext, _ size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) / 2 * 0.85
        let petalR = radius

        // 8 petals
        for i in 0..<8 {
            let a1 = CGFloat(i) / 8 * .pi * 2 - .pi / 2
            let a2 = CGFloat(i + 1) / 8 * .pi * 2 - .pi / 2
            let mid = (a1 + a2) / 2
            var p = Path()
            p.move(to: center)
            p.addLine(to: pt(center, petalR * 0.3, a1))
            p.addQuadCurve(to: pt(center, petalR * 0.3, a2),
                           control: pt(center, petalR, mid))
            p.closeSubpath()
            ctx.stroke(p, with: .color(color.opacity(opacity)), lineWidth: 1.5)
        }
        
        // Inner ring
        var ring = Path()
        ring.addEllipse(in: CGRect(x: center.x - radius * 0.2, y: center.y - radius * 0.2, width: radius * 0.4, height: radius * 0.4))
        ctx.stroke(ring, with: .color(color.opacity(opacity)), lineWidth: 1.0)

        // Centre dot
        dot(ctx, center, r: radius * 0.08)
    }

    // MARK: - Yantra — Single 6-pointed star (two triangles)

    private func drawYantra(_ ctx: GraphicsContext, _ size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) / 2 * 0.8
        
        // Outer concentric circles
        for scale in [1.0, 0.85, 0.7] {
            let r = radius * scale
            var c = Path()
            c.addEllipse(in: CGRect(x: center.x - r, y: center.y - r, width: r*2, height: r*2))
            ctx.stroke(c, with: .color(color.opacity(opacity * (scale == 1.0 ? 0.8 : 1.8))), lineWidth: scale == 1.0 ? 1.5 : 2.0)
        }

        let innerR = radius * 0.7
        // Upward triangle
        triangle(ctx, center, r: innerR, rotation: -.pi / 2, baseOpacity: opacity)
        // Downward triangle
        triangle(ctx, center, r: innerR, rotation: .pi / 2, baseOpacity: opacity)
        
        // Centre dot
        dot(ctx, center, r: radius * 0.08)
    }

    // MARK: - Chandra — Interlocking Lunar Orbit (Torus/Seed style)

    private func drawChandra(_ ctx: GraphicsContext, _ size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) / 2 * 0.85

        // Draw 12 overlapping, rotating orbital rings to create a complex web
        let numberOfRings = 12
        let ringRadius = radius * 0.6
        
        for i in 0..<numberOfRings {
            let angle = CGFloat(i) / CGFloat(numberOfRings) * .pi * 2
            let cx = center.x + cos(angle) * (radius * 0.35)
            let cy = center.y + sin(angle) * (radius * 0.35)
            
            var c = Path()
            c.addEllipse(in: CGRect(x: cx - ringRadius, y: cy - ringRadius, width: ringRadius * 2, height: ringRadius * 2))
            ctx.stroke(c, with: .color(color.opacity(opacity * 0.9)), lineWidth: 1.2)
        }
        
        // Outer containing ring
        var outer = Path()
        outer.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
        ctx.stroke(outer, with: .color(color.opacity(opacity * 0.6)), lineWidth: 1.5)

        // Central bindu (dot)
        dot(ctx, center, r: radius * 0.1)
    }

    // MARK: - Primitives

    private func pt(_ c: CGPoint, _ r: CGFloat, _ a: CGFloat) -> CGPoint {
        CGPoint(x: c.x + r * cos(a), y: c.y + r * sin(a))
    }

    private func dot(_ ctx: GraphicsContext, _ center: CGPoint, r: CGFloat) {
        var p = Path()
        p.addEllipse(in: CGRect(x: center.x - r, y: center.y - r,
                                width: r * 2, height: r * 2))
        ctx.fill(p, with: .color(color.opacity(opacity)))
    }

    private func triangle(_ ctx: GraphicsContext, _ center: CGPoint,
                           r: CGFloat, rotation: CGFloat, baseOpacity: Double) {
        var p = Path()
        for i in 0..<3 {
            let a = CGFloat(i) / 3 * .pi * 2 + rotation
            let point = pt(center, r, a)
            if i == 0 { p.move(to: point) } else { p.addLine(to: point) }
        }
        p.closeSubpath()
        // Boosted baseOpacity multiplier to make Yantra triangles much more visible
        ctx.stroke(p, with: .color(color.opacity(baseOpacity * 2.2)), lineWidth: 2.2)
    }
}
