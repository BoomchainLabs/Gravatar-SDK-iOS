import SwiftUI

struct LoadingIndicatorView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: .DS.Padding.large)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .controlSize(.regular)
        }
    }
}

#Preview {
    LoadingIndicatorView()
}
