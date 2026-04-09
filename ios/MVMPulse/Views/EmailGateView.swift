import SwiftUI

struct EmailGateView: View {
    @State private var email: String = ""
    let storage: StorageService
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Image(systemName: "envelope.badge.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(PulseTheme.primaryTeal)

                VStack(spacing: 8) {
                    Text("Get your full results")
                        .font(.title2.bold())

                    Text("Enter your work email to view your Pulse Score and personalized analysis.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                TextField("Work email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding(14)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 12))

                Button {
                    storage.userProfile.email = email.trimmingCharacters(in: .whitespaces)
                    onContinue()
                } label: {
                    Text("View Results")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(PulseTheme.primaryTeal)

                Button {
                    onContinue()
                } label: {
                    Text("Skip for now")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text("Your email is stored locally on your device only.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .scrollDismissesKeyboard(.interactively)
    }
}
