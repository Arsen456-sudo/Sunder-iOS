// Modified for Sunder on 2026-10-28: neutral embedded sample image data.
//
//  FramedItemView.swift
//  SimpleX
//
//  Created by Evgeny Poberezkin on 04/02/2022.
//  Copyright © 2022 SimpleX Chat. All rights reserved.
//
// Spec: spec/client/chat-view.md

import SwiftUI
import SimpleXChat

// Spec: spec/client/chat-view.md#FramedItemView
struct FramedItemView: View {
    @EnvironmentObject var m: ChatModel
    @EnvironmentObject var theme: AppTheme
    @ObservedObject var chat: Chat
    @ObservedObject var im: ItemsModel
    var chatItem: ChatItem
    var scrollToItem: (ChatItem.ID) -> Void
    @Binding var scrollToItemId: ChatItem.ID?
    var preview: UIImage?
    var maxWidth: CGFloat = .infinity
    @State var msgWidth: CGFloat = 0
    var imgWidth: CGFloat? = nil
    var videoWidth: CGFloat? = nil
    @State private var useWhiteMetaColor: Bool = false
    @State var showFullScreenImage = false
    @Binding var allowMenu: Bool
    @State private var showFullscreenGallery: Bool = false

    var body: some View {
        let v = ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                if chatItem.isReport {
                    if chatItem.meta.itemDeleted == nil {
                        let txt = chatItem.chatDir.sent ?
                        Text("Only you and moderators see it") :
                        Text("Only sender and moderators see it")
                        
                        framedItemHeader(icon: "flag", iconColor: .red, caption: txt.italic())
                    } else {
                        framedItemHeader(icon: "flag", caption: Text("archived report").italic())
                    }
                } else if let di = chatItem.meta.itemDeleted {
                    switch di {
                    case let .moderated(_, byGroupMember):
                        framedItemHeader(icon: "flag", caption: Text("moderated by \(byGroupMember.displayName)").italic())
                    case .blocked:
                        framedItemHeader(icon: "hand.raised", caption: Text("blocked").italic())
                    case .blockedByAdmin:
                        framedItemHeader(icon: "hand.raised", caption: Text("blocked by admin").italic())
                    case .deleted:
                        framedItemHeader(icon: "trash", caption: Text("marked deleted").italic())
                    }
                } else if chatItem.meta.isLive {
                    framedItemHeader(caption: Text("LIVE"))
                }

                if let qi = chatItem.quotedItem {
                    ciQuoteView(qi)
                        .simultaneousGesture(TapGesture().onEnded {
                            if let ci = im.reversedChatItems.first(where: { $0.id == qi.itemId }) {
                                withAnimation {
                                    scrollToItem(ci.id)
                                }
                            } else if let id = qi.itemId {
                                if (chatItem.isReport && im.secondaryIMFilter != nil) {
                                    scrollToItemId = id
                                } else {
                                    scrollToItem(id)
                                }
                            } else {
                                showQuotedItemDoesNotExistAlert()
                            }
                        })
                } else if let itemForwarded = chatItem.meta.itemForwarded {
                    framedItemHeader(icon: "arrowshape.turn.up.forward", caption: Text(itemForwarded.text(chat.chatInfo.chatType)).italic(), pad: true)
                }

                ChatItemContentView(chat: chat, im: im, chatItem: chatItem, msgContentView: framedMsgContentView)
                    .padding(chatItem.content.msgContent != nil ? 0 : 4)
                    .overlay(DetermineWidth())
            }

            if let content = chatItem.content.msgContent {
                CIMetaView(
                    chat: chat,
                    chatItem: chatItem,
                    metaColor: theme.colors.secondary,
                    invertedMaterial: useWhiteMetaColor
                )
                .padding(.horizontal, 12)
                .padding(.bottom, 6)
                .overlay(DetermineWidth())
                .accessibilityLabel("")
            }
        }
            .background { chatItemFrameColorMaybeImageOrVideo(chatItem, theme).modifier(ChatTailPadding()) }
            .onPreferenceChange(DetermineWidth.Key.self) { msgWidth = $0 }

        if let (title, text) = chatItem.meta.itemStatus.statusInfo ?? chatItem.meta.msgVerified?.sigMissingInfo {
            v.simultaneousGesture(TapGesture().onEnded {
                AlertManager.shared.showAlert(
                    Alert(
                        title: Text(title),
                        message: Text(text)
                    )
                )
            })
        } else {
            v
        }
    }

    @ViewBuilder private func framedMsgContentView() -> some View {
        if chatItem.formattedText == nil && chatItem.file == nil && !chatItem.meta.isLive && isShortEmoji(chatItem.content.text) {
            VStack {
                emojiText(chatItem.content.text)
                Text("")
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .overlay(DetermineWidth())
            .frame(minWidth: msgWidth, alignment: .center)
            .padding(.bottom, 2)
        } else {
            switch (chatItem.content.msgContent) {
            case let .image(text, _):
                CIImageView(chatItem: chatItem, senderProfile: ciSenderProfile(chatItem, chat.chatInfo), scrollToItem: scrollToItem, preview: preview, maxWidth: maxWidth, imgWidth: imgWidth, showFullScreenImage: $showFullscreenGallery)
                    .overlay(DetermineWidth())
                if text == "" && !chatItem.meta.isLive {
                    Color.clear
                        .frame(width: 0, height: 0)
                        .onAppear {
                            useWhiteMetaColor = true
                        }
                        .onDisappear {
                            useWhiteMetaColor = false
                        }
                } else {
                    ciMsgContentView(chatItem)
                }
            case let .video(text, _, duration):
                CIVideoView(chatItem: chatItem, senderProfile: ciSenderProfile(chatItem, chat.chatInfo), preview: preview, duration: duration, maxWidth: maxWidth, videoWidth: videoWidth, showFullscreenPlayer: $showFullscreenGallery)
                .overlay(DetermineWidth())
                if text == "" && !chatItem.meta.isLive {
                    Color.clear
                    .frame(width: 0, height: 0)
                    .onAppear {
                        useWhiteMetaColor = true
                    }
                    .onDisappear {
                        useWhiteMetaColor = false
                    }
                } else {
                    ciMsgContentView(chatItem)
                }
            case let .voice(text, duration):
                FramedCIVoiceView(chat: chat, chatItem: chatItem, recordingFile: chatItem.file, duration: duration, allowMenu: $allowMenu)
                    .overlay(DetermineWidth())
                if text != "" {
                    ciMsgContentView(chatItem)
                }
            case let .file(text):
                ciFileView(chatItem, text)
            case let .report(text, reason):
                ciMsgContentView(chatItem, txtPrefix: reason.attrString)
            case let .link(_, preview):
                CILinkView(linkPreview: preview, maxWidth: maxWidth)
                ciMsgContentView(chatItem)
            case let .chat(text, chatLink, ownerSig):
                let hasText = text != chatLink.connLinkStr
                CIChatLinkHeader(chatItem: chatItem, chatLink: chatLink, ownerSig: ownerSig, hasText: hasText)
                    .overlay(DetermineWidth())
                    .simultaneousGesture(TapGesture().onEnded {
                        planAndConnect(chatLink.connLinkStr, linkOwnerSig: ownerSig, theme: theme, dismiss: false)
                    })
                if hasText {
                    ciMsgContentView(chatItem, stripLink: chatLink.connLinkStr)
                }
            case let .unknown(_, text: text):
                if chatItem.file == nil {
                    ciMsgContentView(chatItem)
                } else {
                    ciFileView(chatItem, text)
                }
            default:
                ciMsgContentView(chatItem)
            }
        }
    }

    @ViewBuilder func framedItemHeader(icon: String? = nil, iconColor: Color? = nil, caption: Text, pad: Bool = false) -> some View {
        let v = HStack(spacing: 6) {
            if let icon = icon {
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 14, height: 14)
                    .foregroundColor(iconColor ?? theme.colors.secondary)
            }
            caption
                .font(.caption)
                .lineLimit(1)
        }
        .foregroundColor(theme.colors.secondary)
        .padding(.horizontal, 12)
        .padding(.top, 6)
        .padding(.bottom, pad || (chatItem.quotedItem == nil && chatItem.meta.itemForwarded == nil) ? 6 : 0)
        .overlay(DetermineWidth())
        .frame(minWidth: msgWidth, alignment: .leading)
        .background(chatItemFrameContextColor(chatItem, theme))
        if let mediaWidth = maxMediaWidth(), mediaWidth < maxWidth {
            v.frame(maxWidth: mediaWidth, alignment: .leading)
        } else {
            v
        }
    }

    @ViewBuilder private func ciQuoteView(_ qi: CIQuote) -> some View {
        let backgroundColor = chatItemFrameContextColor(chatItem, theme)
        let v = ZStack(alignment: .topTrailing) {
            switch (qi.content) {
            case let .image(_, image):
                if let uiImage = imageFromBase64(image) {
                    ciQuotedMsgView(qi)
                        .padding(.trailing, 70).frame(minWidth: msgWidth, alignment: .leading)
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 68, height: 68)
                        .clipped()
                } else {
                    ciQuotedMsgView(qi)
                }
            case let .video(_, image, _):
                if let uiImage = imageFromBase64(image) {
                    ciQuotedMsgView(qi)
                    .padding(.trailing, 70).frame(minWidth: msgWidth, alignment: .leading)
                    Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 68, height: 68)
                    .clipped()
                } else {
                    ciQuotedMsgView(qi)
                }
            case .file:
                ciQuotedMsgView(qi)
                    .padding(.trailing, 20).frame(minWidth: msgWidth, alignment: .leading)
                ciQuoteIconView("doc.fill")
            case .voice:
                ciQuotedMsgView(qi)
                    .padding(.trailing, 20).frame(minWidth: msgWidth, alignment: .leading)
                ciQuoteIconView("mic.fill")
            case let .chat(text, chatLink, _):
                let prefix = NSAttributedString(string: chatLink.displayName + (text != chatLink.connLinkStr ? " - " : ""))
                ciQuotedMsgView(qi, stripLink: chatLink.connLinkStr, prefix: prefix)
                    .padding(.trailing, 20).frame(minWidth: msgWidth, alignment: .leading)
                ciQuoteIconView(chatLink.smallIconName)
            default:
                ciQuotedMsgView(qi)
            }
        }
            // if enable this always, size of the framed voice message item will be incorrect after end of playback
            .overlay { if case .voice = chatItem.content.msgContent {} else { DetermineWidth() } }
            .frame(minWidth: msgWidth, alignment: .leading)
            .background(backgroundColor)
            .environment(\.containerBackground, UIColor(backgroundColor))
        if let mediaWidth = maxMediaWidth(), mediaWidth < maxWidth {
            v.frame(maxWidth: mediaWidth, alignment: .leading)
        } else {
            v
        }
    }
    
    private func ciQuotedMsgView(_ qi: CIQuote, stripLink: String? = nil, prefix: NSAttributedString? = nil) -> some View {
        Group {
            if let sender = qi.getSender(membership()) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(sender)
                        .font(.caption)
                        .foregroundColor(qi.chatDir == .groupSnd ? .accentColor : theme.colors.secondary)
                        .lineLimit(1)
                    ciQuotedMsgTextView(qi, lines: 2, stripLink: stripLink, prefix: prefix)
                }
            } else {
                ciQuotedMsgTextView(qi, lines: 3, stripLink: stripLink, prefix: prefix)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.top, 6)
        .padding(.horizontal, 12)
    }

    @inline(__always)
    private func ciQuotedMsgTextView(_ qi: CIQuote, lines: Int, stripLink: String? = nil, prefix: NSAttributedString? = nil) -> some View {
        MsgContentView(chat: chat, text: qi.text, formattedText: qi.formattedText, textStyle: .subheadline, prefix: prefix, stripLink: stripLink)
            .lineLimit(lines)
            .padding(.bottom, 6)
    }

    private func ciQuoteIconView(_ image: String) -> some View {
        Image(systemName: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(Color(uiColor: .tertiaryLabel))
            .frame(width: 18, height: 18)
            .padding(.top, 6)
            .padding(.trailing, 6)
    }
    
    private func membership() -> GroupMember? {
        switch chat.chatInfo {
        case let .group(groupInfo: groupInfo, _): return groupInfo.membership
        default: return nil
        }
    }
    
    @ViewBuilder private func ciMsgContentView(_ ci: ChatItem, txtPrefix: NSAttributedString? = nil, stripLink: String? = nil) -> some View {
        let text = ci.meta.isLive ? ci.content.msgContent?.text ?? ci.text : ci.text
        let rtl = isRightToLeft(text)
        let ft = text == "" ? [] : ci.formattedText
        let v = MsgContentView(
            chat: chat,
            text: text,
            formattedText: ft,
            textStyle: .body,
            meta: ci.meta,
            mentions: ci.mentions,
            userMemberId: chat.chatInfo.groupInfo?.membership.memberId,
            rightToLeft: rtl,
            prefix: txtPrefix,
            stripLink: stripLink
        )
        .environment(\.containerBackground, UIColor(chatItemFrameColor(ci, theme)))
        .multilineTextAlignment(rtl ? .trailing : .leading)
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .overlay(DetermineWidth())
        .frame(minWidth: 0, alignment: .leading)

        if let mediaWidth = maxMediaWidth(), mediaWidth < maxWidth {
            v.frame(maxWidth: mediaWidth, alignment: .leading)
        } else {
            v
        }
    }

    @ViewBuilder private func ciFileView(_ ci: ChatItem, _ text: String) -> some View {
        CIFileView(chat: chat, file: chatItem.file, meta: chatItem.meta, senderProfile: ciSenderProfile(chatItem, chat.chatInfo))
            .overlay(DetermineWidth())
        if text != "" || ci.meta.isLive {
            ciMsgContentView (chatItem)
        }
    }

    private func maxMediaWidth() -> CGFloat? {
        if let imgWidth = imgWidth, let videoWidth = videoWidth {
            return imgWidth > videoWidth ? imgWidth : videoWidth
        } else if let imgWidth = imgWidth {
            return imgWidth
        } else {
            return videoWidth
        }
    }

    private func showQuotedItemDoesNotExistAlert() {
        AlertManager.shared.showAlertMsg(
            title: "No message",
            message: "This message was deleted or not received yet."
        )
    }
}

func isRightToLeft(_ s: String) -> Bool {
    if let lang = CFStringTokenizerCopyBestStringLanguage(s as CFString, CFRange(location: 0, length: min(s.count, 80))) {
        return NSLocale.characterDirection(forLanguage: lang as String) == .rightToLeft
    }
    return false
}

func onlyImageOrVideo(_ ci: ChatItem) -> Bool {
    if case let .image(text, _) = ci.content.msgContent {
        return ci.meta.itemDeleted == nil && !ci.meta.isLive && ci.quotedItem == nil && ci.meta.itemForwarded == nil && text == ""
    } else if case let .video(text, _, _) = ci.content.msgContent {
        return ci.meta.itemDeleted == nil && !ci.meta.isLive && ci.quotedItem == nil && ci.meta.itemForwarded == nil && text == ""
    }
    return false
}

func chatItemFrameColorMaybeImageOrVideo(_ ci: ChatItem, _ theme: AppTheme) -> Color {
    onlyImageOrVideo(ci)
    ? Color.clear
    : chatItemFrameColor(ci, theme)
}

func chatItemFrameColor(_ ci: ChatItem, _ theme: AppTheme) -> Color {
    ci.chatDir.sent
    ? theme.appColors.sentMessage
    : theme.appColors.receivedMessage
}

func chatItemFrameContextColor(_ ci: ChatItem, _ theme: AppTheme) -> Color {
    ci.chatDir.sent
    ? theme.appColors.sentQuote
    : theme.appColors.receivedQuote
}

struct FramedItemView_Previews: PreviewProvider {
    static var previews: some View {
        let im = ItemsModel.shared
        Group{
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(1, .directSnd, .now, "hello"), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(1, .groupRcv(groupMember: GroupMember.sampleData), .now, "hello", quotedItem: CIQuote.getSample(1, .now, "hi", chatDir: .directSnd)), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(2, .directSnd, .now, "https://simplex.chat", .sndSent(sndProgress: .complete), quotedItem: CIQuote.getSample(1, .now, "hi", chatDir: .directRcv)), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(2, .directSnd, .now, "👍", .sndSent(sndProgress: .complete), quotedItem: CIQuote.getSample(1, .now, "Hello too", chatDir: .directRcv)), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(2, .directRcv, .now, "hello there too!!! this covers -"), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(2, .directRcv, .now, "hello there too!!! this text has the time on the same line "), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(2, .directRcv, .now, "https://simplex.chat"), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(2, .directRcv, .now, "chaT@simplex.chat"), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
        }
        .previewLayout(.fixed(width: 360, height: 200))
    }
}

struct FramedItemView_Edited_Previews: PreviewProvider {
    static var previews: some View {
        let im = ItemsModel.shared
        Group {
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(1, .directSnd, .now, "hello", .sndSent(sndProgress: .complete), itemEdited: true), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(1, .groupRcv(groupMember: GroupMember.sampleData), .now, "hello", quotedItem: CIQuote.getSample(1, .now, "hi", chatDir: .directSnd), itemEdited: true), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(2, .directSnd, .now, "https://simplex.chat", .sndSent(sndProgress: .complete), quotedItem: CIQuote.getSample(1, .now, "hi", chatDir: .directRcv), itemEdited: true), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(2, .directSnd, .now, "👍", .sndSent(sndProgress: .complete), quotedItem: CIQuote.getSample(1, .now, "Hello too", chatDir: .directRcv), itemEdited: true), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(2, .directRcv, .now, "hello there too!!! this covers -", .rcvRead, itemEdited: true), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(2, .directRcv, .now, "hello there too!!! this text has the time on the same line ", .rcvRead, itemEdited: true), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(2, .directRcv, .now, "https://simplex.chat", .rcvRead, itemEdited: true), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(2, .directRcv, .now, "chaT@simplex.chat", .rcvRead, itemEdited: true), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(1, .groupRcv(groupMember: GroupMember.sampleData), .now, "hello", quotedItem: CIQuote.getSample(1, .now, "hi there hello hello hello ther hello hello", chatDir: .directSnd, image: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAAFklEQVR42mO49+Q1SYhhVMOohuGrAQAbh60f9sW+IwAAAABJRU5ErkJggg=="), itemEdited: true), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(1, .groupRcv(groupMember: GroupMember.sampleData), .now, "hello there this is a long text", quotedItem: CIQuote.getSample(1, .now, "hi there", chatDir: .directSnd, image: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAAFklEQVR42mO49+Q1SYhhVMOohuGrAQAbh60f9sW+IwAAAABJRU5ErkJggg=="), itemEdited: true), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
        }
        .environment(\.revealed, false)
        .previewLayout(.fixed(width: 360, height: 200))
    }
}

struct FramedItemView_Deleted_Previews: PreviewProvider {
    static var previews: some View {
        let im = ItemsModel.shared
        Group {
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(1, .directSnd, .now, "hello", .sndSent(sndProgress: .complete), itemDeleted: .deleted(deletedTs: .now)), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(1, .groupRcv(groupMember: GroupMember.sampleData), .now, "hello", quotedItem: CIQuote.getSample(1, .now, "hi", chatDir: .directSnd), itemDeleted: .deleted(deletedTs: .now)), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(2, .directSnd, .now, "https://simplex.chat", .sndSent(sndProgress: .complete), quotedItem: CIQuote.getSample(1, .now, "hi", chatDir: .directRcv), itemDeleted: .deleted(deletedTs: .now)), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(2, .directSnd, .now, "👍", .sndSent(sndProgress: .complete), quotedItem: CIQuote.getSample(1, .now, "Hello too", chatDir: .directRcv), itemDeleted: .deleted(deletedTs: .now)), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(2, .directRcv, .now, "hello there too!!! this covers -", .rcvRead, itemDeleted: .deleted(deletedTs: .now)), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(2, .directRcv, .now, "hello there too!!! this text has the time on the same line ", .rcvRead, itemDeleted: .deleted(deletedTs: .now)), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(2, .directRcv, .now, "https://simplex.chat", .rcvRead, itemDeleted: .deleted(deletedTs: .now)), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(2, .directRcv, .now, "chaT@simplex.chat", .rcvRead, itemDeleted: .deleted(deletedTs: .now)), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(1, .groupRcv(groupMember: GroupMember.sampleData), .now, "hello", quotedItem: CIQuote.getSample(1, .now, "hi there hello hello hello ther hello hello", chatDir: .directSnd, image: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAAFklEQVR42mO49+Q1SYhhVMOohuGrAQAbh60f9sW+IwAAAABJRU5ErkJggg=="), itemDeleted: .deleted(deletedTs: .now)), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
            FramedItemView(chat: Chat.sampleData, im: im, chatItem: ChatItem.getSample(1, .groupRcv(groupMember: GroupMember.sampleData), .now, "hello there this is a long text", quotedItem: CIQuote.getSample(1, .now, "hi there", chatDir: .directSnd, image: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAAFklEQVR42mO49+Q1SYhhVMOohuGrAQAbh60f9sW+IwAAAABJRU5ErkJggg=="), itemDeleted: .deleted(deletedTs: .now)), scrollToItem: { _ in }, scrollToItemId: Binding.constant(nil), allowMenu: Binding.constant(true))
        }
        .environment(\.revealed, false)
        .previewLayout(.fixed(width: 360, height: 200))
    }
}
