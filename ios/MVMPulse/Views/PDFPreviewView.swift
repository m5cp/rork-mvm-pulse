import SwiftUI
import PDFKit

struct PDFPreviewView: View {
    let result: AssessmentResult
    let storage: StorageService
    @State private var pdfData: Data?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            if let pdfData {
                PDFKitView(data: pdfData)
            } else {
                ProgressView("Generating report...")
            }
        }
        .navigationTitle("PDF Report")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Done") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if pdfData != nil {
                    Button {
                        shareReport()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .task {
            pdfData = PDFReportService.generateReport(
                result: result,
                profile: storage.userProfile,
                roadmap: storage.roadmap
            )
        }
    }

    private func shareReport() {
        guard let pdfData else { return }
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("MVM_Pulse_Report.pdf")
        try? pdfData.write(to: tempURL)
        let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.document = PDFDocument(data: data)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}
