// Modified for Sunder on 2026-10-28: neutral embedded sample image data.
//
//  ProfileImage.swift
//  SimpleX
//
//  Created by Evgeny on 23/03/2022.
//  Copyright © 2022 SimpleX Chat. All rights reserved.
//

import SwiftUI
import SimpleXChat

struct ProfileImage: View {
    @EnvironmentObject var theme: AppTheme
    var imageStr: String? = nil
    var iconName: String = "person.crop.circle.fill"
    var size: CGFloat
    var color = Color(uiColor: .tertiarySystemGroupedBackground)
    var backgroundColor: Color? = nil
    var blurred = false
    @AppStorage(DEFAULT_PROFILE_IMAGE_CORNER_RADIUS) private var radius = defaultProfileImageCorner

    var body: some View {
        if let uiImage = imageFromBase64(imageStr) {
            clipProfileImage(Image(uiImage: uiImage), size: size, radius: radius, blurred: blurred)
        } else {
            let c = color.asAnotherColorFromSecondaryVariant(theme)
            Image(systemName: iconName)
                .resizable()
                .foregroundColor(c)
                .scaledToFit()
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(backgroundColor != nil ? backgroundColor! : .clear)
                        .frame(width: size - 2, height: size - 2) // less than size of Image to avoid slightly visible border
                )
        }
    }
}

extension Color {
    func asAnotherColorFromSecondary(_ theme: AppTheme) -> Color {
        return self
    }

    func asAnotherColorFromSecondaryVariant(_ theme: AppTheme) -> Color {
        let s = theme.colors.secondaryVariant
        let l = theme.colors.isLight
        return switch self {
        case Color(uiColor: .tertiaryLabel): // ChatView title
            l ? s.darker(0.05) : s.lighter(0.2)
        case Color(uiColor: .tertiarySystemFill): // SettingsView, ChatInfoView
            l ? s.darker(0.065) : s.lighter(0.085)
        case Color(uiColor: .quaternaryLabel): // ChatListView user picker
            l ? s.darker(0.1) : s.lighter(0.1)
        case Color(uiColor: .tertiarySystemGroupedBackground): // ChatListView items, forward view
            s.asGroupedBackground(theme.base.mode)
        default: self
        }
    }
}

struct ProfileImage_Previews: PreviewProvider {
    static var previews: some View {
        ProfileImage(imageStr: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAAFklEQVR42mO49+Q1SYhhVMOohuGrAQAbh60f9sW+IwAAAABJRU5ErkJggg==", size: 63)
            .previewLayout(.fixed(width: 63, height: 63))
            .background(.black)
    }
}
