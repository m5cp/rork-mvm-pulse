import SwiftUI

struct ShareCardComposerView: View {
    let result: AssessmentResult
    let storage: StorageService
    @State private var selectedStyle: ShareCardStyle = .dark
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            ScrollView {
                VStack(spacing: 20) {
                    shareCardPreview
                        .padding(.top, 8)

                    Picker("Style", selection: $selectedStyle) {
                        ForEach(ShareCardStyle.allCases, id: \.self) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal, 20)
            }

            VStack(spacing: 12) {
                Button {
                    shareCard()
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(PulseTheme.primaryTeal)

                Button {
                    saveCard()
                } label: {
                    Label("Save to Photos", systemImage: "photo.on.rectangle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)
                .tint(PulseTheme.primaryTeal)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .navigationTitle("Share Score")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
    }

    @MainActor
    private var shareCardPreview: some View {
        ShareCardView(result: result, style: selectedStyle, strongestCategory: result.strongestCategory?.category.rawValue ?? "")
            .frame(height: 400)
            .clipShape(.rect(cornerRadius: 20))
            .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
    }

    @MainActor
    private func renderImage() -> UIImage? {
        let cardView = ShareCardView(result: result, style: selectedStyle, strongestCategory: result.strongestCategory?.category.rawValue ?? "")
            .frame(width: 390, height: 400)
        let renderer = ImageRenderer(content: cardView)
        renderer.scale = 3.0
        return renderer.uiImage
    }

    private func shareCard() {
        guard let image = renderImage() else { return }
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }

    private func saveCard() {
        guard let image = renderImage() else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}

struct ShareCardView: View {
    let result: AssessmentResult
    let style: ShareCardStyle
    let strongestCategory: String

    private var backgroundColor: Color {
        switch style {
        case .light: return Color(red: 246/255, green: 246/255, blue: 246/255)
        case .dark: return Color(red: 7/255, green: 16/255, blue: 30/255)
        case .bold: return PulseTheme.primaryTeal
        }
    }

    private var textColor: Color {
        switch style {
        case .light: return Color(red: 17/255, green: 17/255, blue: 17/255)
        case .dark, .bold: return .white
        }
    }

    private var secondaryTextColor: Color {
        switch style {
        case .light: return Color(red: 89/255, green: 89/255, blue: 89/255)
        case .dark: return .white.opacity(0.6)
        case .bold: return .white.opacity(0.7)
        }
    }

    private var accentColor: Color {
        switch style {
        case .light, .dark: return PulseTheme.primaryTeal
        case .bold: return .white
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(accentColor.opacity(0.2), lineWidth: 10)
                        .frame(width: 120, height: 120)

                    Circle()
                        .trim(from: 0, to: result.overallScore / 100)
                        .stroke(accentColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(result.overallScore))")
                        .font(.system(size: 40, weight: .heavy))
                        .foregroundStyle(textColor)
                }

                VStack(spacing: 4) {
                    Text(result.level.rawValue.uppercased())
                        .font(.caption.bold())
                        .foregroundStyle(accentColor)
                        .tracking(2)

                    if !strongestCategory.isEmpty {
                        Text("Strongest: \(strongestCategory)")
                            .font(.caption)
                            .foregroundStyle(secondaryTextColor)
                    }
                }
            }

            Spacer()

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("MVM Pulse")
                        .font(.caption.bold())
                        .foregroundStyle(textColor)
                    Text("Know your number.")
                        .font(.caption2)
                        .foregroundStyle(secondaryTextColor)
                }

                Spacer()

                Image(systemName: "waveform.path.ecg")
                    .font(.title3)
                    .foregroundStyle(accentColor)
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
    }
}
