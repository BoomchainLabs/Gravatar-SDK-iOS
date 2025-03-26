import SwiftUI
import GravatarUI

struct DemoProfileEditorView: View {

    @AppStorage("pickerEmail") private var email: String = ""
    @AppStorage("pickerContentLayoutOptions") private var contentLayoutOptions: QELayoutOptions = .verticalLarge
    // You can make this `true` by default to easily test the picker
    @State private var isPresentingPicker: Bool = false
    @State private var hasSession: Bool = false
    @State private var selectedScheme: UIUserInterfaceStyle = .unspecified
    @Environment(\.oauthSession) var oauthSession

    @State private var profileConfiguration: ProfileViewConfiguration = Self.initialConfiguration()
    @State private var oneTimeAvatarForceRefresh: Bool = false

    private static func initialConfiguration() -> ProfileViewConfiguration {
        var config: ProfileViewConfiguration = .summary()
        config.padding = .init(top: 8, left: 0, bottom: 8, right: 0)
        return config
    }

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 5) {
                TextField("Email", text: $email)
                    .font(.callout)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
                Divider()
                ProfileViewRepresentable(configuration: $profileConfiguration, oneTimeAvatarForceRefresh: $oneTimeAvatarForceRefresh)
                if #available(iOS 16.0, *) {
                    QEContentLayoutPickerRow(contentLayoutOptions: $contentLayoutOptions)
                }
                Divider()

                QEColorSchemePickerRow(selectedScheme: $selectedScheme)
            }
            .padding(.horizontal)
                Button("Open Profile Editor with OAuth flow") {
                    isPresentingPicker.toggle()
                }
                .modifier { view in
                    if #available(iOS 16.0, *) {
                        view
                            .gravatarQuickEditorSheet(
                                isPresented: $isPresentingPicker,
                                email: email,
                                scope: .avatarPicker(.init(contentLayout: contentLayoutOptions.contentLayout)),
                                avatarUpdatedHandler: {
                                    self.oneTimeAvatarForceRefresh = true
                                },
                                onDismiss: {
                                    updateHasSession(with: email)
                                }
                        )
                    }
                    else {
                        view
                            .gravatarQuickEditorSheet(
                                isPresented: $isPresentingPicker,
                                email: email,
                                scope: .avatarPicker,
                                avatarUpdatedHandler: {
                                    self.oneTimeAvatarForceRefresh = true
                                },
                                onDismiss: {
                                    updateHasSession(with: email)
                                }
                            )
                    }
                }

            if hasSession {
                Button("Log out") {
                    oauthSession.deleteSession(with: .init(email))
                    updateHasSession(with: email)
                }
            }

            Spacer()
        }
        .onAppear() {
            updateHasSession(with: email)
            requestProfile()
        }
        .onChange(of: email) { newValue in
            updateHasSession(with: newValue)
            requestProfile()
        }
        .preferredColorScheme(ColorScheme(selectedScheme))
    }

    func requestProfile() {
        Task {
            let service = ProfileService()
            let profile = try await service.fetch(with: .email(email))
            var newConfig = self.profileConfiguration
            newConfig.avatarIdentifier = profile.avatarIdentifier
            newConfig.model = profile
            newConfig.summaryModel = profile
            self.profileConfiguration = newConfig
        }
    }

    func updateHasSession(with email: String) {
        hasSession = oauthSession.hasSession(with: .init(email))
    }
}

#Preview {
    DemoProfileEditorView()
}
