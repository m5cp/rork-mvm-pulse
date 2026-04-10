import SwiftUI
import Photos

struct ShareCardComposerView: View {
    let result: AssessmentResult
    let storage: StorageService
    @State private var selectedStyle: ShareCardStyle = .dark
    @State private var showingSaveSuccess: Bool = false
    @State private var showingSaveError: Bool = false
    @State private var saveErrorMessage: String = ""
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
                ShareLink(item: renderedImage, preview: SharePreview("MVM Pulse Score", image: renderedImage)) {
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
        .alert("Saved!", isPresented: $showingSaveSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your Pulse Score card has been saved to Photos.")
        }
        .alert("Unable to Save", isPresented: $showingSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(saveErrorMessage)
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
    private var renderedImage: Image {
        let cardView = ShareCardView(result: result, style: selectedStyle, strongestCategory: result.strongestCategory?.category.rawValue ?? "")
            .frame(width: 390, height: 400)
        let renderer = ImageRenderer(content: cardView)
        renderer.scale = 3.0
        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "photo")
    }

    @MainActor
    private func renderUIImage() -> UIImage? {
        let cardView = ShareCardView(result: result, style: selectedStyle, strongestCategory: result.strongestCategory?.category.rawValue ?? "")
            .frame(width: 390, height: 400)
        let renderer = ImageRenderer(content: cardView)
        renderer.scale = 3.0
        return renderer.uiImage
    }

    private func saveCard() {
        guard let image = renderUIImage() else { return }

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            Task { @MainActor in
                switch status {
                case .authorized, .limited:
                    PHPhotoLibrary.shared().performChanges {
                        let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                        request.creationDate = Date()
                    } completionHandler: { success, error in
                        Task { @MainActor in
                            if success {
                                showingSaveSuccess = true
                            } else {
                                saveErrorMessage = error?.localizedDescription ?? "Could not save image."
                                showingSaveError = true
                            }
                        }
                    }
                case .denied, .restricted:
                    saveErrorMessage = "Please allow photo access in Settings to save your score card."
                    showingSaveError = true
                default:
                    saveErrorMessage = "Photo library access is required to save images."
                    showingSaveError = true
                }
            }
        }
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
