//
//  ChatInfoToolbar.swift
//  SimpleX
//
//  Created by Evgeny Poberezkin on 11/02/2022.
//  Copyright © 2022 SimpleX Chat. All rights reserved.
//

import SwiftUI
import SimpleXChat

struct ChatInfoToolbar: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var theme: AppTheme
    @EnvironmentObject var m: ChatModel
    @ObservedObject var chat: Chat
    var imageSize: CGFloat = 32
    var showsAvatar = true

    var body: some View {
        let cInfo = chat.chatInfo
        return HStack {
            if (cInfo.incognito) {
                Image(systemName: "theatermasks").frame(maxWidth: 24, maxHeight: 24, alignment: .center).foregroundColor(.indigo)
                Spacer().frame(width: 16)
            }
            if showsAvatar {
                ZStack(alignment: .bottomTrailing) {
                    ChatInfoImage(
                        chat: chat,
                        size: imageSize,
                        color: Color(uiColor: .tertiaryLabel)
                    )
                    if chat.chatStats.reportsCount > 0 {
                        Image(systemName: "flag.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .red)
                    } else if chat.supportUnreadCount > 0 {
                        Image(systemName: "flag.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, theme.colors.primary)
                    }
                }
                .padding(.trailing, 4)
            }
            let t = Text(cInfo.displayName).font(.headline)
            VStack(alignment: .leading, spacing: 0) {
                NameWithBadge((cInfo.contact?.verified == true ? contactVerifiedShield + t : t), cInfo.nameBadge, .headline)
                    .lineLimit(1)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            if let contact = chat.chatInfo.contact,
               contact.ready && contact.active,
               let chatSubStatus = m.chatSubStatus,
               chatSubStatus != .active {
                SubStatusView(status: chatSubStatus)
                    .padding(.leading, 4)
            }
        }
        .foregroundColor(theme.colors.onBackground)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var subtitle: String? {
        let info = chat.chatInfo
        var parts: [String] = []
        if !info.fullName.isEmpty && info.fullName != info.displayName { parts.append(info.fullName) }
        if let count = channelSubscriberCount { parts.append(subscriberCountStr(count)) }
        return parts.isEmpty ? nil : parts.joined(separator: " \u{00B7} ")
    }

    private var channelSubscriberCount: Int64? {
        if case let .group(groupInfo, _) = chat.chatInfo,
           groupInfo.useRelays,
           let count = groupInfo.groupSummary.publicMemberCount,
           count > 0 {
            count
        } else {
            nil
        }
    }

    private var contactVerifiedShield: Text {
        (Text(Image(systemName: "checkmark.shield")) + textSpace)
            .font(.caption)
            .foregroundColor(theme.colors.secondary)
            .baselineOffset(1)
            .kerning(-2)
    }

    struct SubStatusView: View {
        @Environment(\.dynamicTypeSize) private var userFont: DynamicTypeSize
        @EnvironmentObject var theme: AppTheme
        var status: SubscriptionStatus

        var body: some View {
            switch status {
            case .active: EmptyView()
            case .pending: ProgressView()
            case .removed: subStatusError()
            case .noSub: subStatusError()
            }
        }

        @ViewBuilder private func subStatusError() -> some View {
            let dynamicChatInfoSize = dynamicSize(userFont).chatInfoSize
            Image(systemName: "exclamationmark.circle")
                .resizable()
                .scaledToFit()
                .frame(width: dynamicChatInfoSize, height: dynamicChatInfoSize)
                .foregroundColor(theme.colors.secondary)
        }
    }
}

public func subscriberCountStr(_ count: Int64) -> String {
    count == 1
        ? String.localizedStringWithFormat(NSLocalizedString("%d subscriber", comment: "channel subscriber count"), count)
        : String.localizedStringWithFormat(NSLocalizedString("%d subscribers", comment: "channel subscriber count"), count)
}

public func ownersContributorsCountStr(_ count: Int, withContributors: Bool) -> String {
    if withContributors {
        return String.localizedStringWithFormat(NSLocalizedString("%d owners & contributors", comment: "channel members count"), count)
    }
    return count == 1
        ? String.localizedStringWithFormat(NSLocalizedString("%d owner", comment: "channel owners count"), count)
        : String.localizedStringWithFormat(NSLocalizedString("%d owners", comment: "channel owners count"), count)
}

struct ChatInfoToolbar_Previews: PreviewProvider {
    static var previews: some View {
        ChatInfoToolbar(chat: Chat(chatInfo: ChatInfo.sampleData.direct, chatItems: []))
            .environmentObject(CurrentColors.toAppTheme())
    }
}
