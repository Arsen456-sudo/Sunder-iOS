// Modified for Sunder on 2026-10-28: neutral embedded sample image data.
//
//  LinkPreview.swift
//  SimpleX
//
//  Created by Ian Davies on 04/04/2022.
//  Copyright © 2022 SimpleX Chat. All rights reserved.
//

import SwiftUI
import LinkPresentation
import SimpleXChat

struct ComposeLinkView: View {
    @EnvironmentObject var theme: AppTheme
    let linkPreview: LinkPreview?
    var cancelPreview: (() -> Void)? = nil
    let cancelEnabled: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            if let linkPreview {
                linkPreviewView(linkPreview)
            } else {
                ProgressView()
                    .padding(.leading, 12)
                    .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60, alignment: .leading)
            }
            if let cancelPreview = cancelPreview, cancelEnabled {
                Button { cancelPreview() } label: {
                    Image(systemName: "multiply")
                }
            }
        }
        .padding(.vertical, 1)
        .padding(.trailing, 12)
        .background(theme.appColors.sentMessage)
        .frame(minHeight: 54)
        .frame(maxWidth: .infinity)
    }

    private func linkPreviewView(_ linkPreview: LinkPreview) -> some View {
        HStack(alignment: .center, spacing: 8) {
            if let uiImage = imageFromBase64(linkPreview.image) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 80, maxHeight: 60)
            }
            VStack(alignment: .center, spacing: 4) {
                Text(linkPreview.title)
                    .lineLimit(1)
                Text(linkPreview.uri)
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundColor(theme.colors.secondary)
            }
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, minHeight: 60)
        }
    }
}

struct SmallLinkPreview_Previews: PreviewProvider {
    static var previews: some View {
        let preview = LinkPreview(
            uri: "http://DuckDuckGo.com",
            title: "Privacy, simplified.",
            description: "",
            image: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAAFklEQVR42mO49+Q1SYhhVMOohuGrAQAbh60f9sW+IwAAAABJRU5ErkJggg=="
        )
        Group {
            ComposeLinkView(linkPreview: preview, cancelPreview: {}, cancelEnabled: true)
                .previewLayout(.fixed(width: 360, height: 200))
            ComposeLinkView(linkPreview: nil, cancelPreview: {}, cancelEnabled: true)
                .previewLayout(.fixed(width: 360, height: 200))
        }
    }
}
