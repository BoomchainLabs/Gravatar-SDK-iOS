import SwiftUI

struct LoadingIndicatorView: View {
    var body: some View {
        VStack(spacing: 0) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .controlSize(.regular)
        }
        .padding(.top, .DS.Padding.large)
    }
}

#Preview {
    LoadingIndicatorView()
}
