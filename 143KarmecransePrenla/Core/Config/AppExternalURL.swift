import Foundation
import UIKit

/// Central place for outbound URLs (privacy, terms, etc.).
enum AppExternalURL: String, CaseIterable {
    case privacyPolicy = "https://karmecranse143prenla.site/privacy/117"
    case termsOfUse = "https://karmecranse143prenla.site/terms/117"

    var url: URL? {
        URL(string: rawValue)
    }

    /// Opens Safari (or default browser) when the URL is valid.
    static func open(_ link: AppExternalURL) {
        guard let url = link.url else { return }
        UIApplication.shared.open(url)
    }
}
