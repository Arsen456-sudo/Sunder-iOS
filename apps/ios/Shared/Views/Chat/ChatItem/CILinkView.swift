// Modified for Sunder on 2026-10-28: neutral embedded sample image data.
//
//  LargeLinkPreviewView.swift
//  SimpleX
//
//  Created by Ian Davies on 07/04/2022.
//  Copyright © 2022 SimpleX Chat. All rights reserved.
//
// Spec: spec/client/chat-view.md

import SwiftUI
import SimpleXChat

// Spec: spec/client/chat-view.md#CILinkView
struct CILinkView: View {
    @EnvironmentObject var theme: AppTheme
    let linkPreview: LinkPreview
    let maxWidth: CGFloat
    @State private var blurred: Bool = UserDefaults.standard.integer(forKey: DEFAULT_PRIVACY_MEDIA_BLUR_RADIUS) > 0

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            if let uiImage = imageFromBase64(linkPreview.image) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: maxWidth, height: maxWidth * heightRatio(uiImage.size))
                    .clipped()
                    .modifier(PrivacyBlur(blurred: $blurred))
                    .if(!blurred) { v in
                        v.simultaneousGesture(TapGesture().onEnded {
                            openBrowserAlert(uri: linkPreview.uri)
                        })
                    }
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(linkPreview.title)
                    .lineLimit(3)
                Text(linkPreview.uri)
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundColor(theme.colors.secondary)
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .simultaneousGesture(TapGesture().onEnded {
                openBrowserAlert(uri: linkPreview.uri)
            })
        }
    }
}

func openBrowserAlert(uri: String) {
    let (url, err) = sanitizeUri(uri)
    if let url {
        let uriStr = url.uri.absoluteString
        showAlert(
            NSLocalizedString("Open link?", comment: "alert title"),
            message: uriStr.count > 160 ? "\(uriStr.prefix(160))…" : uriStr,
            actions: {
                if let sanitizedUri = url.sanitizedUri {
                    [
                        cancelAlertAction,
                        UIAlertAction(
                            title: NSLocalizedString("Open full link", comment: "alert action"),
                            style: .default,
                            handler: { _ in UIApplication.shared.open(url.uri) }
                        ),
                        UIAlertAction(
                            title: NSLocalizedString("Open clean link", comment: "alert action"),
                            style: .default,
                            handler: { _ in UIApplication.shared.open(sanitizedUri) }
                        )
                    ]
                } else {
                    [
                        cancelAlertAction,
                        UIAlertAction(
                            title: NSLocalizedString("Open", comment: "alert action"),
                            style: .default,
                            handler: { _ in UIApplication.shared.open(url.uri) }
                        )
                    ]
                }
            }
        )
    } else {
        showInvalidLinkAlert(uri, error: err)
    }
}

func showInvalidLinkAlert(_ uri: String, error: String? = nil) {
    let message = if let error, !error.isEmpty {
        error + "\n" + uri
    } else {
        uri
    }
    showAlert(
        NSLocalizedString("Invalid link", comment: "alert title"),
        message: message,
        actions: {[okAlertAction]}
    )
}

func sanitizeUri(_ s: String) -> (url: (uri: URL, sanitizedUri: URL?)?, error: String?) {
    let parsed = parseSanitizeUri(s, safe: false)
    return if let uri = URL(string: s), let uriInfo = parsed?.uriInfo {
        (url: (uri: uri, sanitizedUri: uriInfo.sanitized.flatMap { URL(string: $0) }), error: nil)
    } else {
        (url: nil, error: parsed?.parseError)
    }
}

struct LargeLinkPreview_Previews: PreviewProvider {
    static var previews: some View {
        let preview = LinkPreview(
            uri: "http://DuckDuckGo.com",
            title: "Privacy, simplified.",
            description: "",
            image: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAAFklEQVR42mO49+Q1SYhhVMOohuGrAQAbh60f9sW+IwAAAABJRU5ErkJggg=="
        )
        CILinkView(linkPreview: preview, maxWidth: 360)
            .previewLayout(.fixed(width: 360, height: 200))
    }
}
