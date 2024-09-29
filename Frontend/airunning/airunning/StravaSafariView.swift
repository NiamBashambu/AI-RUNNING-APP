import SwiftUI
import SafariServices

struct StravaSafariView: UIViewControllerRepresentable {
    let url: URL
    var onDismiss: () -> Void // Closure to call on dismiss

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        var parent: StravaSafariView

        init(_ parent: StravaSafariView) {
            self.parent = parent
        }

        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            // Notify parent that the view controller was dismissed
            parent.onDismiss()
        }
    }
}
