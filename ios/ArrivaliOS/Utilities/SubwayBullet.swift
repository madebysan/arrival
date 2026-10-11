import SwiftUI

// SwiftUI view for a subway bullet circle
struct SubwayBullet: View {
    let route: String
    var size: CGFloat = 22

    var body: some View {
        ZStack {
            Circle()
                .fill(SubwayColors.color(for: route))
                .frame(width: size, height: size)
            Text(route.uppercased())
                .font(.system(size: size * 0.5, weight: .bold))
                .foregroundColor(SubwayColors.textColor(for: route))
        }
    }
}
