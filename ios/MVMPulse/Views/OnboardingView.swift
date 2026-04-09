import SwiftUI

struct OnboardingView: View {
    @State private var currentPage: Int = 0
    @State private var firstName: String = ""
    @State private var selectedRole: UserRole = .individual
    @State private var selectedIndustry: Industry = .technology
    @State private var selectedCompanySize: CompanySize = .solo
    @State private var appeared: Bool = false

    let storage: StorageService
    let onComplete: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            switch currentPage {
            case 0: welcomePage
            case 1: valuePage
            case 2: profilePage
            default: EmptyView()
            }
        }
        .animation(reduceMotion ? .none : .smooth(duration: 0.4), value: currentPage)
    }

    private var welcomePage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                Text("Welcome to")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                    .tracking(1.5)
                    .textCase(.uppercase)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)

                VStack(spacing: 12) {
                    Text("MVM Pulse")
                        .font(.system(size: 40, weight: .bold))
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)

                    RoundedRectangle(cornerRadius: 1)
                        .fill(PulseTheme.primaryTeal)
                        .frame(width: appeared ? 40 : 0, height: 3)
                }

                Text("The diagnostic tool for\nyour business and life.")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)

                HStack(spacing: 24) {
                    welcomeFeature(icon: "chart.bar.fill", label: "8 Dimensions")
                    welcomeFeature(icon: "clock.fill", label: "~3 Minutes")
                    welcomeFeature(icon: "lock.shield.fill", label: "Private")
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 15)
            }
            .padding(.horizontal, 32)
            .onAppear {
                withAnimation(.easeOut(duration: 0.7).delay(0.1)) {
                    appeared = true
                }
            }

            Spacer()

            Button {
                currentPage = 1
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(PulseTheme.primaryTeal)
            .padding(.horizontal, 24)
            .padding(.bottom, 8)

            Text("Built by M5CAIRO")
                .font(.caption2)
                .foregroundStyle(.quaternary)
                .padding(.bottom, 28)
        }
    }

    private func welcomeFeature(icon: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(PulseTheme.primaryTeal)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var valuePage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 40) {
                VStack(spacing: 16) {
                    Text("Get your score\nin under 3 minutes.")
                        .font(.system(size: 30, weight: .bold))
                        .multilineTextAlignment(.center)

                    Text("A quick diagnostic across 8 dimensions\nof your business and life.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 0) {
                    valueStep(icon: "waveform.path.ecg", title: "Diagnose", subtitle: "Answer quick\nquestions")
                    
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.quaternary)
                    
                    valueStep(icon: "chart.bar.doc.horizontal", title: "Understand", subtitle: "See your\nbreakdown")
                    
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.quaternary)
                    
                    valueStep(icon: "arrow.up.right", title: "Improve", subtitle: "Follow your\nroadmap")
                }
                .padding(.horizontal, 8)

                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.subheadline)
                    Text("Takes about 2\u{2013}3 minutes")
                        .font(.subheadline)
                }
                .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 32)

            Spacer()

            Button {
                currentPage = 2
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(PulseTheme.primaryTeal)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private func valueStep(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(PulseTheme.primaryTeal)
                .frame(width: 52, height: 52)
                .background(PulseTheme.primaryTeal.opacity(0.1))
                .clipShape(.circle)

            Text(title)
                .font(.footnote.weight(.semibold))

            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var profilePage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Set up your profile")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.top, 20)

                VStack(alignment: .leading, spacing: 8) {
                    Text("First name")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    TextField("Your first name", text: $firstName)
                        .textContentType(.givenName)
                        .padding(14)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 12))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Role")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Picker("Role", selection: $selectedRole) {
                        ForEach(UserRole.allCases, id: \.self) { role in
                            Text(role.rawValue).tag(role)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Industry")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Menu {
                        ForEach(Industry.allCases, id: \.self) { industry in
                            Button(industry.rawValue) { selectedIndustry = industry }
                        }
                    } label: {
                        HStack {
                            Text(selectedIndustry.rawValue)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                        .padding(14)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 12))
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Company size")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Menu {
                        ForEach(CompanySize.allCases, id: \.self) { size in
                            Button(size.rawValue) { selectedCompanySize = size }
                        }
                    } label: {
                        HStack {
                            Text(selectedCompanySize.rawValue)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                        .padding(14)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 12))
                    }
                }

                Spacer(minLength: 20)

                Button {
                    completeOnboarding()
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(PulseTheme.primaryTeal)
                .disabled(firstName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func completeOnboarding() {
        storage.userProfile.firstName = firstName.trimmingCharacters(in: .whitespaces)
        storage.userProfile.role = selectedRole
        storage.userProfile.industry = selectedIndustry
        storage.userProfile.companySize = selectedCompanySize
        storage.userProfile.hasCompletedOnboarding = true
        onComplete()
    }
}
