# Changelog

All notable changes to the CometChat iOS UI Kit, generated from the
[GitHub releases](https://github.com/cometchat/cometchat-uikit-ios/releases) (newest first).

## 5.1.23 — 2026-09-17

### New
- None

### Enhancements
- None

### Fixes
- Fixed the UI Kit requiring every integrator to link `CometChatCallsSDK` even when calling was not used. The shipped module interface emitted an unconditional `import CometChatCallsSDK`, breaking the build of any app that did not include the Calls SDK.

## 5.1.22 — 2026-09-09


### New
- Added pinned messages. A new `CometChatPinnedMessages` component lists a conversation's pinned messages, and Pin / Unpin actions were added to the message options. Because pinning is conversation-wide, the `onMessagePinned` and `onMessageUnpinned` events fire on every participant's device.
- Added saved messages. A new `CometChatSavedMessages` component lists the messages a user has bookmarked, and Save / Unsave actions were added to the message options. Saving is private, so the `onMessageSaved` and `onMessageUnsaved` events reach only the saving user.
- Added pinned conversations. `CometChatConversations` now supports pinning a conversation to the top of the list via a swipe action, enabled with `enablePinConversation` and hideable with `hidePinConversationOption`.
- Added thread following. A follow/unfollow control was added to the threaded message header and the message action sheet, kept in sync through the new `CometChatThreadEvents`. The feature is off by default and opt-in through `UIKitSettings.enable(threadSubscription:)`.
- Added `CometChatToast`, a lightweight toast view used to confirm pin, save, and follow actions.

### Enhancements
- Added localization for all new pin, save, and thread-following strings across the kit's 19 supported languages.

### Fixes
- Fixed the compact message composer not calling `onSendButtonClick` for text messages and voice notes, so hosts that own the send were never notified.
- Fixed a second open threaded message header silencing live replies in the first, by giving each header a distinct message-listener registration.

## 5.1.21 — 2026-09-04


### New
- Added independent customization for URL, phone number, and email colors through `textLinkColor`, `textPhoneNumberColor`, and `textEmailColor` in `TextBubbleStyle` and `LinkPreviewBubbleStyle`.

### Enhancements
- Improved message text rendering to apply link, phone number, and email colors consistently across plain, formatted, and link preview messages.

### Fixes
- Fixed an issue where a phone number was only recognised as tappable when it made up the entire message, so a number written alongside other text could not be tapped.
- Fixed an issue where tapping a recognised phone number failed to open the dialler.
- Fixed an issue where bold and italic formatting applied to links or email addresses was lost when sending messages.
- Fixed an issue where mentions could appear as raw placeholders instead of resolved user names.
- Fixed an issue where long titles or subtitles could hide the date in the conversation and search lists.

## 5.1.20 — 2026-08-26


### New
- None

### Enhancements
- None

### Fixes
- Fixed an issue where customized `textColor` values were not applied to Markdown, code block, and inline code content.
- Fixed an issue where `deleteImageTintColor` was ignored and replaced by the default color when a custom value was provided.

## 5.1.19 — 2026-08-15


### New
- Added a `hideUnreadSeparator` property to `CometChatMessageList` that hides the "New" unread separator row in the message list.

### Enhancements
- None

### Fixes
- Fixed text message bubbles ignoring a custom `TextBubbleStyle.textColor`, which was overridden by the default color.
- Fixed duplicate rows appearing in the conversation list when list fetches overlapped.
- Fixed voice calls being labeled as video calls in the call log.
- Fixed missed calls rendering as a blank row in the call log.
- Fixed two message listener leaks, in the users list and message header, where a listener outlived its screen and was never released.

## 5.1.18 — 2026-08-03


### New
- None

### Enhancements
- None

### Fixes
- Fixed an iOS compatibility issue that could prevent applications from launching on iOS 15–17 when using UIKit builds created with the latest iOS SDK. This release also requires `CometChatCardsSwift` v1.2.0 to ensure compatibility.

## 5.1.17 — 2026-07-24

### New
- Added support for multiple attachments, allowing users to send images, videos, audio files, and documents together in a single message with an optional caption.

- Added rich multi-attachment rendering with dedicated layouts for images, videos, audio, and files, along with inline audio preview before sending.

- Added support for pasting media directly into the message composer and a new `enableMultipleAttachments` option to configure the multi-attachment experience.

### Enhancements
- Improved video attachments with generated thumbnails and duration indicators for a richer media experience.

- Enhanced attachment uploads with clearer progress, retry, and failure states, along with validation based on server-configured file size and attachment count limits.

- Improved conversation previews and search results for multi-attachment messages with summarized content and media thumbnails.

### Fixes
- Fixed media playback so opening videos no longer interrupts background audio, and background playback resumes correctly after the media viewer is dismissed.

- Fixed attachment sharing to prevent corrupt or incorrect files from being shared when download links expire or files have duplicate names.

- Fixed message list scrolling issues that could cause stuttering, jitter, or unexpected jumps while navigating conversations.

## 5.1.16 — 2026-07-02

### New
- Added support for AI agents in group conversations, including agent badges, customizable agent UI, handoff states, and theme support through `AgentUIConfiguration`.

- Added `CometChatStreamBubble` to render AI agent responses as they stream, supporting mixed text and Card Message content.

- Added native support for Card Messages with `CometChatCardBubble`, including graceful fallback rendering and global card action events through `CometChatCardEvents`.

### Enhancements
- Improved AI conversations with responsive card layouts, quoted-reply previews, enhanced message search for developer and AI-generated Card Messages, and refined AI chat history handling.

- Improved the messaging experience with updates to audio playback, voice recording, image previews, report dialogs, UI polish, and localized strings for AI features.

### Fixes
- Fixed crashes related to stale mention selections and streamed AI message updates.

- Fixed issues affecting mention text styling, image previews from search results, AI conversation history, outgoing AI message appearance, and AI option selection.

- Fixed an issue where reply previews could scroll to the wrong message when the conversation contained hidden action messages or an unread separator.

## 5.1.15 — 2026-06-17

### New

- Added `CometChatMessageList.set(loadLastAgentConversation:)` for AI agent chats. When enabled, the message list automatically loads the user's most recent conversation with the agent instead of starting a new chat session. The `onLastAgentConversationLoaded` callback provides the parent message ID, allowing the message composer to continue the conversation thread seamlessly.

### Enhancements
- None

### Fixes
- None

## 5.1.14 — 2026-05-29

### New
- Added the `CometChatNotificationFeed` component, providing a full-screen notification feed for displaying campaign and promotional notifications.
- Added support for customizable feed behavior through props such as `notificationFeedRequestBuilder`, `notificationCategoriesRequestBuilder`, `onItemClick`, and `onActionClick`.
- Added customizable UI support with `HeaderView`, `EmptyView`, `ErrorView`, `LoadingView`, `style`, `cardThemeMode`, and `cardThemeOverride` props for advanced theming and layout control.
- Added category-based filtering with unread badge counts, allowing users to quickly navigate notifications by category.

### Enhancements
- None

### Fixes
- Fixed an issue where underscores in URLs (e.g., product_id, sku_id) were incorrectly interpreted as italic markdown formatting in the message composer and text bubbles.

## 5.1.13 — 2026-05-07

### New
- None

### Enhancements
- None

### Fixes
- Fixed an issue where newly created users displayed an incorrect last seen timestamp.
- Resolved an issue where notifications were displayed without proper Markdown formatting, causing message content to appear as plain text instead of the expected formatted output.
- Fixed a crash that occurred when opening a chat while messages were being sent, caused by inconsistent table view section updates during concurrent operations.

## 5.1.12 — 2026-04-01

### New
- Added **CometChatCompactMessageComposer**, a compact single-line message input component that supports rich text formatting, attachments, message editing, mentions, stickers, and voice recording.
- Introduced **rich text formatting**, enabling users to style messages with bold, italic, strikethrough, code, code blocks, blockquotes, lists, and links. In **CometChatCompactMessageComposer**, this feature is enabled by default, with options available to customize its behavior if needed.

### Enhancements
- None

### Fixes
- None

## 5.1.10 — 2026-03-26

### New
- Added badge count support in the iOS Sample App for better visibility of unread messages.
- Introduced MIME type permission enforcement for media messages to ensure only supported and authorised file types are sent.

### Enhancements
- Improved overall stability of `CometChatMessageList` with comprehensive end-to-end testing, ensuring smoother performance and reliable behaviour across scenarios.
- Enhanced message synchronisation to ensure all message states remain consistent across devices and sessions.
- Improved network recovery handling for a more seamless messaging experience during connectivity changes.
- Optimised UI consistency across devices for a uniform user experience.
- Enhanced poll creation experience by allowing users to re-add options after reaching and reducing from the maximum limit.

### Fixes
- Fixed a crash when a non-creator sent the first reply in a group chat.
- Resolved incorrect voice recording duration display after first app install.
- Fixed voice playback continuing when starting a new recording.

## 5.1.9 — 2026-02-23

### New
- None

### Enhancements
- None

### Fixes
- Fixed endless loading shimmer when starting a new one-to-one conversation in `CometChatMessageList`.


### Deprecations
- None

### Removals
- None

## 5.1.8 — 2026-02-11

### New
- None

### Enhancements
- None

### Fixes
- Fixed an issue on iOS 26 (Xcode 16+) where `CometChatMessageEvents.ccMessageSent()` did not trigger the `.success` callback after message delivery confirmation.


### Deprecations
- None

### Removals
- None

## 5.1.7 — 2026-02-02

### New
- Added the "Mark as Unread" option, allowing users to mark previously read messages as unread for better message management.
- Introduced a new message indicator UI that visually separates unread messages from read ones, improving the user experience and making unread messages more noticeable.

### Enhancements
- Implemented the `startFromUnreadMessages` property, enabling the message list to start from the unread messages when set to `true`. This feature provides a more seamless experience for users who want to focus on new messages.

### Fixes
- None

### Deprecations
- None

### Removals
- None

## 5.1.6 — 2026-01-28

### New
- None

### Enhancements
- None

### Fixes
- Fixed an issue where the `hideSearch` property was not working correctly in `CometChatConversations`, causing the search bar to remain visible even when set to true.
- Fixed a UI layout issue where the composer view appeared at the top of the screen and messages were not visible when opening a chat screen with `CometChatMessageComposer` and `CometChatMessageList`.
- Fixed an app crash that occurred when sending multiple messages rapidly within a thread in `CometChatMessageList`.
- Fixed UI conflicts when resizing the app window on iPad with iOS 26.2 and flexible window resizing enabled.

### Deprecations
- None

### Removals
- None

## 5.1.5 — 2026-01-16

### New
- None

### Enhancements
- None

### Fixes
- Fixed an issue where incorrect dates were displayed in the `CometChatGroups`, causing confusion when viewing recent activity.
- Fixed an issue where applied themes did not reflect correctly in the `CometChatConversations` and `CometChatMessageComposer`.
- Fixed an app crash that occurred when sending multiple messages rapidly in `CometChatMessageList`.
- Fixed an issue where users could send an edited message without making any actual changes.
- Fixed a UI layout issue where the call detail page broke when the device was in landscape mode.
- Fixed a problem where the call end button was not displayed correctly in landscape orientation in `CometChatOutgoingCall`.
- Resolved an issue where the send button remained disabled in `CometChatMessageComposer` after attaching a photo using the camera.
- Fixed a crash that occurred when deleting a message from the message list using iPad.
- Fixed an issue in group details screen where the block and delete chat options were not visible in landscape mode.

### Deprecations
- None

### Removals
- None

## v5.1.4 — 2025-12-16

### New
- Introduced `@all` mention feature, enabling users to notify all group members at once.
- Enhanced the mention all feature by introducing new methods like `setDisableMentionAll` and `setMentionAllLabelId`, giving developers greater flexibility in managing mentions.

### Enhancements
- None

### Fixes

- None

### Deprecations
- None

### Removals
- None

## v5.1.3 — 2025-12-11

### New
- Introduced `CometChatSearch` component, enabling users to search across conversations, messages, or both. Users can also apply filters such as:
  - Conversation filters: Unread, Group.
  - Message filters: Audio, Video, Photo, File, and Link.
- Added `showSearchBar` and `searchView` props to `CometChatConversations` to control search bar visibility and allow custom search views. Also introduced `onSearchBarClicked` callback to handle interactions with the default search bar.
- Added `goToMessageId` prop in `CometChatMessageList` to launch the list with a specific message highlighted—useful when navigating from search results.
- Introduced `CometChatSearchScope` enum to define whether the search should be performed in conversations, messages, or both.
- Introduced `CometChatSearchFilter` enum to support setting an `initialSearchFilter` or to provide a custom list of filters for the `CometChatSearch` component.

- Introduced the **Reply Message** feature, enabling users to reply directly to a specific message within a chat.
  - Added a new `hideReplyOption` property in the message list, allowing developers to hide the option to reply to a message. By default, the reply option is visible.
  - Introduced a new message event `ccReplyToMessage`, which displays a preview of the message being replied to in the composer.
  - Added a new `replyView` section in `CometChatMessageTemplate` to show a message preview inside the message bubble for the message being replied to.

- Added a new feature that allows users to report a specific message for moderation purposes.
  - Added `hideFlagMessageOption` — to hide the **Flag Message** option from the message actions menu.
  - Added `hideFlagRemarkField` — to hide the remark text area in the flag dialog.

### Enhancements
- None

### Fixes

- Added missing `delete chat` option Group's screen.

### Deprecations
- None

### Removals
- None

## 5.1.2 — 2025-11-19

### New
- None

### Enhancements
- None

### Fixes
- Fixed crash in `CometChatMessageList` when **hidegroupactionmessages** was set to true
- Fixed crash in `CometChatConversations` while deleting conversation in **iPad**
- Fixed issue in `CometChatMessageList` where the message bubble theme changes after setting custom templates
- Fixed issue in `CometChatMessageComposer` where action sheets did not update theme mode with respect to its parent view controller.
                                                                
### Deprecations
- None

### Removals
- None

## 5.1.1 — 2025-11-12

### New
- Introduced `CometChatAIAssistantChat`, a composite component that integrates a message header, message list, and composer to deliver a seamless and interactive AI agent chat experience.
- Added `CometChatAIAssistantBubble` with **Markdown rendering**, enabling clear, formatted, and user-friendly display of AI agent messages for enhanced readability.
- Introduced **quick starter suggestions** in the empty state, helping users initiate conversations with the AI agent more efficiently.
- Added a **"New Chat" button** to reset the conversation context and provide easy access to previous chat sessions.
- Enabled **comprehensive customization** through props, allowing developers to configure:
  - Streaming speed
  - Custom header, empty state, and error views
  - Visibility of suggestions, history, and new chat options
### Enhancements
- None
### Fixes
- Fixed issue while setting custom `UserRequestBuilder` in `CometChatUsers`.
- Fixed search bar placement on the Add Group Members screen ensuring consistent UI across all iOS versions
### Deprecations
- None
### Removals
- None

## 5.0.10 — 2025-11-06

### New
- None

### Enhancements
- None

### Fixes
- Fixed issue in `CometChatThreadedMessageHeader` where user was unable to dismiss keyboard in landscape mode.
- Fixed issue where a blank screen appeared when user navigated to `CometChatThreadedMessageHeader`.
- Fixed issue where user was unable to set custom trail view in `CometChatGroups`.

### Deprecations
- None

### Removals
- None

## 5.0.9 — 2025-10-08

### New
- None

### Enhancements
- Added separate attachment options for **Photo** and **Video** library in message attachment options.
- Allowed overriding of font values from `CometChatTypography` at the app level.
- Enabled setting a new language in `CometChatLocalize`.

### Fixes
- Fixed issue where stickers were duplicated in the `CometChatStickerKeyboard`.
- Fixed warning while uploading build to App Store regarding missing **dSYM** files.
- Fixed issue with `CometChatStickerKeyboard` where sticker properties were not accessible when overriding at app level.
- Fixed crash in `CometChatMessageList` when creating a poll on iOS 26.
- Handled busy call state of the user and displayed "Call Busy" status in `CometChatMessageList`.

### Deprecations
- None

### Removals
- None

## 5.0.8 — 2025-08-25

### New
- Added a **Moderation View** in the default bottom view of the message bubble. This view appears for messages that are disapproved based on their moderation status.
- Introduced a new prop `hideModerationView` in the **MessageList** component, allowing developers to hide the Moderation View when needed.
- Added a new prop `cometchatModerationViewStyle` in **CometChatOutgoingMessageBubbleStyle** to customize the background color and text appearance of the Moderation View.

### Enhancements
- Added support to change all fonts in `CometChatTypography` using one `setFont` method

### Fixes

- Fixed a bug where navigating to Call Details occurred twice on double-tapping `CometChatCallLogs`.
- Updated the group leave confirmation button icon from ✓ to "Done" for consistency.
- Resolved an issue where, after blocking/unblocking a user while the keyboard was open in `CometChatMessageComposer`, navigating away and returning to the screen caused a blank space to appear with the keyboard not visible.
- Fixed an issue where blocked users' online/offline were still visible in Call Details.
- Added error message when trying to add a user to `CometChatGroup` who is already a group member.
- Fixed an issue where action messages were not excluded from the list after filtering them in `CometChatMessageList` .
- Fixed a flickering issue where navigation text briefly appeared after a VOIP call attempt.
- Ensured consistency in call icons between `CometChatCallLogs` and Call Details screens.
- Resolved a crash that occurred when searching for a non-existent group in `CometChatGroups`.
- Fixed an issue where conversations with deleted users remained visible in `CometChatConversations`.
- Fixed flickering "no members" error while searching in the banned members list, even when banned users were present.
- Fixed a delay where Polls, Collaborative Document, and Whiteboard messages were not immediately rendered in `CometChatMessageList`.


### Deprecations
- None

### Removals
- None

## 5.0.6 — 2025-06-11

### New
• None

### Enhancements
- Added support for `hideShareMessageOption` property in the `CometChatMessageList` to align with other message option visibility controls in iOS V5 UIKit.

### Fixes

- Fixed an issue where unexpected space appeared below the `CometChatMessageComposer` on smaller iOS devices.
- Resolved a layout overflow issue where the `CometChatStickerKeyboard` would extend beyond view when opened inside a threaded message on smaller iOS devices.
- Corrected translation behavior where same text appeared for similar languages, now respecting exact locale preferences.
- Fixed a logout issue where the user had to tap the logout option twice to log out successfully.
- Addressed an issue where the search bar was not fixed in the Add Members screen during scrolling.
- Resolved a bug where last seen status in `CometChatMessageHeader` and User details screen incorrectly showed "a minute ago" instead of the accurate timestamp.
- Improved scroll performance of `CometChatMessageList` to prevent freezing when multiple `CometChatAudioBubble` messages were sent in chat, ensuring a smoother user experience.
- Resolved text overlapping issue in loading state when navigating to the `CometChatCallLogs`.
- Fixed an issue where users received duplicate stickers when sending and receiving sticker messages simultaneously in `CometChatMessageList`, and stickers disappeared after being sent.
- Fixed flickering of `CometChatAvatar` while reloading data in `CometChatListBase`.
- Fixed behavior where the sticker panel remained open when switching between `CometChatMessageComposer` options (e.g., ai, attachments).
- Resolved an issue where messages disappeared in `CometChatMessageList` after changing the device orientation.
- Fixed repeated "Oops! Something went wrong" error that appeared when unbanning members on Banned members screen multiple times in quick succession.

### Deprecations
- None

### Removals
- None

## 5.0.5 — 2025-05-21

### New
• None

### Enhancements
• None

### Fixes

- Fixed an issue where the edit message preview in `CometChatMessageComposer` persisted when navigating back from the thread messages screen to the main message screen, instead of resetting appropriately.
- Fixed an issue where admin and moderator controls disappeared after group member activity like joining or leaving a group in the group details screen.
- Fixed incorrect display of group action messages inside `CometChatMessageList` in threaded messages screen.
- Fixed an issue where the sticker panel failed to open after multiple edits and navigation events between screens with `CometChatMessageComposer`.
- Fixed issue where the `CometChatReactionList` would not scroll between tabs after the last reaction was removed.
- Fixed an issue where the `CometChatMessageBubble would disappear when multiple touches occured on it in `CometChatMessageList`.
- Fixed a bug where the `CometChatCallButton` didn’t work on the second attempt to initiate call from the call detail screen.
- Fixed an issue where reactions were added to wrong `CometChatMessageBubble` in `CometChatMessageList`.
- Fixed the issue where `MediaRecorderStyle` properties were not applying correctly to the `CometChatMediaRecorder`.
- Resolved a bug that caused group calls to start separate 1-on-1 calls for group members instead of a single group session.
- Fixed incorrect user status display where users appeared offline in the user details screen instead of showing the last seen time of the user.
- Fixed animation issue which caused reactions to slide away while removing the reaction from `CometChatReactionList`.
- Fixed a UI bug where owner or admin controls were incorrectly visible to participants.

### Deprecations
• None

### Removals
• None
                    

## 4.3.21 — 2025-05-14

### New
• None

### Enhancements
• None

### Fixes

- Fixed an issue where scroll to bottom in the `CometChatMessageList` was not functioning correctly when collaborative whiteboard message was sent.
- Fixed as issue where the **tableViewStyle** property in `ContactStyle` of `CometChatContacts` was not applying the intended style to the table view.
- Fixed a navigation bar alignment issue in `CometChatListBase`.
- Fixed an issue that caused offline users to appear online when navigating manually to `CometChatMessages`.

### Deprecations
• None

### Removals
• None

## 5.0.4 — 2025-05-07

### New
• None

### Enhancements
• None

### Fixes
- Fixed time stamp issue in `CometChatMessageList` where incorrect time was displayed for messages.

### Deprecations
• None

### Removals
• None

## 5.0.3 — 2025-05-06

### New
- None

### Enhancements

- Added support for the following new languages in iOS UIKit:
  - English (UK)
  - Dutch
  - Japanese
  - Korean
  - Turkish
  - Malay

- Introduced a new `CometChatDateTimeFormatter` class to enable full customization of how date and time are displayed across the CometChat UI Kit.

### Fixes

- Fixed a crash issue occurring when integrating CometChatUIKitSwift v5.0.2 with the latest version of CometChatSDK.

### Deprecations
- None

### Removals
- None

## 5.0.2 — 2025-04-21

### New
- None

### Enhancements
- None

### Fixes
- Fixed an issue where avatar was visible in user-to-user chats in `CometChatMessageList` iOS UIKit v5 (Release 5.0.1).
- Fixed a UI bug where the back button appeared on the left side for a few seconds after ending a call in `CometChatMessageHeader`.
- Fixed an issue where a member was unable to re-enter a group after being removed in `CometChatGroups`.
- Resolved an issue related to audio recording in the `CometChatMediaRecorder`.
- Fixed an issue where the "Go to Latest Message" button did not scroll to the last message in `CometChatMessageList`.
- Fixed navigation issue from create conversation screen to the `CometChatMessageList`.
- Resolved a bug where the avatar displayed incorrectly in user-to-user in `CometChatThreadedMessageHeader`.
- Fixed blocking/unblocking user behavior that incorrectly displayed online status in `CometChatMessageHeader.
- Fixed an issue where sticker options were not visible after the first attempt to attach media in `CometChatMessageComposer`.
- Fixed a bug where the attach button and options would hide when scrolling stickers in `CometChatMessageComposer`.
- Resolved a crash issue when banning a group member in `CometChatGroupMembers`.
- Fixed the overlap issue where the search box covered user/group buttons in `CreateConversations` screen.
- Fixed incorrect "No Replies" label for threads with 0 replies in `CometChatThreadedMessageHeader`.
- Resolved incorrect loading state display when scrolling the `CometChatGroupMembers` screen.
- Fixed an issue where deleted groups remained visible in the `CometChatGroups` after performing `exit and delete group` action.
- Fixed a bug where no error message was shown when searching for an invalid username in the `CometChatGroupMembers` section of a group.
- Corrected incorrect pluralization in the group member count in group detail screen.
- Resolved a crash issue when removing a member from a group in `CometChatGroups`.
- Fixed duplicate back options being displayed on the user details screen.
- Fixed an issue where users could log out of the app without internet connection.

## 4.3.20 — 2025-04-02

### New
• None

### Enhancements
• None

### Fixes
• Fixed an issue where the custom navigation bar height of `CometChatConversationWithMessages` increased after returning from the `CometChatMessages` screen.
• Resolved an issue where the `hideSectionSeparator` property in `UsersConfiguration` was not working in `CometChatContacts`.
• Fixed an issue where `messageListConfiguration.show(avatar: false)` did not work in `CometChatMessages`.
• Fixed a bug where unread messages were incorrectly marked as read when viewing a different chat screen in `CometChatConversations`.
• Fixed `.setDatePattern(datePattern)` not working in `MessageListConfiguration`.
• Resolved an issue where disabling calling did not remove the info button from `CometChatMessageHeader`.
• Fixed a blank space issue when hiding the search bar in `CometChatGroups()`.
• Fixed an issue with audio record player button customization of `CometChatMediaRecorder`.
• Addressed missing string translations in localization files.

### Deprecations
• None

### Removals
• None

## 5.0.1 — 2025-03-21

### New

- None

### Enhancements

- Mapped all strings to the localization file, cleaned up existing entries, and added new translations for newly introduced strings.
- Renamed `Remove` to `Kick` in `CometChatGroupMembers` options for better clarity.
- Updated the UI for `CometChatMessageComposer` in case of blocked user and added the option to unblock the user.

### Fixes

- Fixed an issue where the "No Calls" message persisted on `CometChatCallLogs` screen even after making a call and refreshing the screen.
- Fixed an issue where calling a blocked user shows `Something went wrong` instead of indicating that the user is blocked.
- Fixed an issue where call notifications were still being shown for logged-out users.
- Fixed a UI issue where message bubbles were visible behind the shimmer loading effect in `CometChatMessageList`.
- Fixed an issue while setting custom template for `CometChatMessageBubble`.
- Fixed an issue where deleted groups remained visible in the `CometChatConversations` screen and allowed members to send messages.
- Fixed a bug where the `CometChatGroups` screen would freeze while the user joins a group and internet was turned off.
- Fixed an issue where leaving a group did not redirect the user back to the `CometChatGroups` screen.
- Resolved an issue where leaving a group multiple times caused the member count on `GroupDetails` screen to go negative.
- Fixed an issue where users could log out of the app while offline, causing unexpected behavior.
- Addressed real-time user status issues on iOS v5 where online/offline status was not updating correctly.
- Fixed an issue where incorrect message bubble view would show in case of call bubbles.

### Deprecations

- None

### Removals

- None

## v5.0.0 — 2025-02-24

## Release Notes
### New
  - **New Development Methods & Renaming for Components**
  - **Groups Component** – Added new methods and improved naming conventions.
  - **User Component** – Introduced new API methods for better usability.
  - **Conversations Component** – Updated with new methods and structured improvements.
  - **Outgoing Call Component** – Added enhancements for call handling.
  - **Group Members Component** – Introduced improved member management methods.
  - **Thread Header Component** – Implemented new thread-specific functionalities.
  - **Message Composer Component** – Added new styling and message composition methods.
  - **Message List Component** – Enhanced message display with new development methods.
  - **Message Header Component** – Introduced improved customization options.
  - **Call Buttons Component** – Updated for better UI customization.
  - **Incoming Call Component** – New methods added for incoming call handling.
  - **Call Logs Component** – Introduced structured improvements for call log management.
### Enhancements
- None
### Fixes
- Style props issues.
### Deprecations
- None
### Removals
- None

## 5.0.0-beta.4 — 2025-02-15

### New
- None

### Enhancements
- None

### Fixes
- Fixed an issue where reacting to a message did not work in **CometChatMessageList** when zero message options were passed from **CometChatMessageTemplate**.
- Resolved an issue where disabling reactions was not working in **CometChatMessageList**.
- Fixed an issue where disabling mentions was not working in **CometChatMessageComposer**.
- Resolved a crash in **CometChatUsers** when the user list was empty.
- Fixed a crash occurring during **CometChatUIKit** initialization when an error occurred.
- Corrected an issue in **CometChatMessageList** where editing a message did not display the "edited" text.
- Fixed an issue where the user's last seen status was incorrect when going offline in real time.
- Fixed real-time updates for deleted messages in **CometChatConversations**, particularly for **collaborative whiteboards, collaborative documents, and stickers**.
- Fixed an issue where all messages were not being fetched when scrolling up in **CometChatMessageList**.
- Resolved a UI issue in the **Add Member** screen that occurred when a user was selected and an error appeared.
- Fixed a theming issue where deleted messages were not displayed correctly in dark mode.
- Fixed an issue where leaving a group did not remove it from the CometChatConversations.
- Addressed a UI issue where the **message composer alignment** became unstable when mentioning more than 10 users.
- Resolved an issue where the **Smart Replies** panel incorrectly opened when sending or receiving a text message.

### Deprecations
- None

### Removals
- None

## 4.3.19 — 2025-02-11

### New
- Added a missing "Restart Audio Recording" button in the MessageComposer Component when sending an audio message. This button was already available on other platforms.

### Enhancements
- Compressed incoming and outgoing message tones to reduce the final build size of UIKit.

### Fixes
- Fixed a view overlapping issue when overriding the bubble view from `CometChatTemplate` for a message.
- Fixed a crash that occurred when overriding the send button click using the `setOnSendButtonClick` function from `messageComposerConfiguration`.
- Fixed an issue in `CometChatConversation` where overriding the conversation type to a specific user or group using `ConversationRequestBuilder` still displayed real-time messages from other types.
- Fixed an issue in `CometChatGroupMember` where, when scrolling through a large number of members, avatars were mismatched with other users.
- Fixed a crash in `CometChatContacts` when `tabVisibility` was set to "user" or "group".
- Fixed multiple localization issues in the Hungarian language.
- Fixed an issue where, when an image message was sent with a caption, the caption overlapped with the image preview.
- Fixed an issue in `CometChatGroupMember` and `CometChatBannedMember` where a "No User Found" error was displayed when the search mode was canceled.

## v5.0.0-beta.3 — 2025-01-28

### New
- None

### Enhancements
- None

### Fixes
- Addressed a crash when opening certain chats with Smart Replies enabled.

## 5.0.0-beta.2 — 2025-01-07

### New
- **Revamped UI**: Experience a fresh, modern design for improved visual appeal and consistency. The updated look enhances usability and engagement.
- **Restructured Components**: Enjoy a redesigned component architecture that improves scalability, making it easier to build and maintain modular designs.

### Enhancements
- **Optimized User Experience**: Interactions have been streamlined to provide a smoother, more intuitive experience, reducing friction during use.
- **Advanced Styling and Theming**: Gain greater flexibility with enhanced customization options, allowing you to tailor appearances to suit your brand effortlessly.
- **Simplified Integration**: Set up faster and with ease thanks to a more intuitive, streamlined integration process.

### Fixes
- None

### Removals
- **Style Props Removed**: Style-specific props have been deprecated to encourage the use of modern theming practices, which offer more robust and scalable customization options.

## 4.3.18 — 2024-12-02

#### New
- None

#### Enhancements
- None

#### Fixes  
- Resolved an issue where the custom `MessageRequestBuilder` was not working with `CometChatMessageList`.  
- Corrected reaction alignment in `CometChatMessageList` when messages were aligned to the left; reactions now align properly.  
- Fixed a bug where `MessagesConfiguration` in `CometChatConversationsWithMessages` was not applied to `CometChatMessages` when accessed via the "Message Privately" option in group chat.  
- Fixed an animation issue when transitioning between `CometChatMessages` views using the "Message Privately" option.  
- Ensured the global navigation style now applies correctly to the `CometChatDetails` component.
- Addressed an issue where the initial characters of user and group names were incorrectly capitalized in `CometChatMessageHeader`, `CometChatConversations`, `CometChatUsers`, and `CometChatGroup` components.    
- Resolved a bug (introduced in v4.3.17) where all users incorrectly appeared as online in the `CometChatReactionList`.  
- Fixed the `disable(userPresence: Bool)` property in `CometChatMessageHeader` and `CometChatDetails`.  
- Fixed the `hide(headerView: Bool)` property to ensure it works correctly with custom header views in `CometChatMessageList`.  
- Resolved an issue where the `disable(reaction: Bool)` property in `ThreadedMessageConfiguration` was not working.

## 4.3.17 — 2024-08-21

#### New
- Added a new prop `hideReceipt` to hide the receipt in the message bubble and conversation’s last message.

#### Enhancements
- If `isIncludeBlockedUsers` is set to true in the `ConversationsRequestBuilder` and the logged-in user blocks another user, the conversation is not removed from the list.

#### Fixes
- Fixed an issue with the empty view not being replaced when search ends in an empty result in `CometChatGroup`, `CometChatUsers`, and `CometChatAddMember`.
- Resolved an issue where the thread icon was not visible after replying to a message and returning to the message list.
- Resolved the navigation bar overlapping issue in `CometChatMessages` when a new view controller is opened or when the user navigates back to the previous screen.
- Fixed an issue with the corner radius of the status indicator in `CometChatMessageHeader`.
- Fixed a crash when trying to send documents on an iPad in `CometChatMessageComposer`.
- Added the following properties that were missing in `MessageComposerConfiguration`:
  - `deleteIconTint`
  - `submitIconTint`
  - `timerTextColor`
  - `timerTextFont`
  - `pauseIconTint`
  - `stopIconTint`
  - `playIconTint`
  - `infoIcon`
  - `onSuggestionItemClick`
  - `setAIOptions`
  - `aiOptionsStyle`
  - `onClickSuggestionListView`
- Added the following properties that were missing in `MessageComposerStyle`:
  - `separatorTint`
  - `actionSheetSeparatorTint`
  - `actionSheetBackground`
  - `voiceRecordingIconTint`
  - `taiIconTint`
  - `infoTextColor`
  - `infoTextAppearance`
  - `infoIconTintColor`
  - `infoBackgroundColor`
  - `infoSeparatorColor`
  - `inputBorderColor`
  - `inputBorderWidth`
  - `inputCornerRadius`
- Fixed the following properties that were not working in `MessageComposerStyle`:
  - `placeHolderTextFont`
  - `actionSheetTitleFont`
  - `actionSheetLayoutModelIconTint`
  - `actionSheetCancelButtonIconFont`
  - `actionSheetCancelButtonIconTint`
  - `textFont`
  - `textColor`
  - `separatorTint`
  - `actionSheetSeparatorTint`
  - `actionSheetBackground`
  - `voiceRecordingIconTint`
  - `infoTextColor`
  - `infoIconTintColor`
  - `infoBackgroundColor`
  - `infoSeparatorColor`

#### Deprecations
- Deprecated `disableReceipt` prop from `CometChatMessageList` & `CometChatConversations` components.

## 4.3.16 — 2024-08-09

#### New
- The sender of a message will now see a double tick on a group message to indicate that the message has been successfully delivered to all users within that group, and a double blue tick once it has been read by all participants in the group.

## 4.3.15 — 2024-08-02

#### Fixes

- Added the following missing properties in `ConversationsStyle`:
  - emptyTextFont
  - lastMessageTextFont
  - typingIndicatorTextFont
  - threadIndicatorTextFont
  - separatorColor
  - emptyTextColor
  - errorTextColor
  - lastMessageTextColor
  - typingIndicatorTextColor
  - threadIndicatorTextColor
- Added the following missing properties in `ConversationsConfiguration`:
  - tailView
  - disableMentions
- Added the following missing properties in `MessageHeaderConfiguration`:
  - statusIndicatorStyle
  - listItemView
  - backIconView
- Added the following missing properties in `MessageListConfiguration`:
  - reactionListConfiguration
  - emptyStateText
  - errorStateText
  - actionSheetStyle
  - disableMentions
  - hideAddReactionsIcon
- Fixed issue with the following properties not working in `MessageHeaderStyle`:
  - border
  - borderColor
  - borderRadius
  - typingIndicatorTextColor
  - typingIndicatorTextFont
  - detailIconTint
  - subtitleTextColorForOffline
  - subtitleTextColor
- Fixed issue with the following properties not working in `MessageListConfiguration`:
  - errorStateText
  - emptyStateText
  - actionSheetStyle
  - disableMentions
  - hideAddReactionsIcon
  - waitIcon
  - messageBubbleStyle
  - EmojiKeyboardStyle
  - setDatePattern
  - Fixed issue with customising status indicator background color in `CometChatMessageHeader` component
- Added the following missing properties in `CometChatListBase`:
  - lastMessageTextFont
  - typingIndicatorTextFont
  - threadIndicatorTextFont
  - separatorColor
  - errorTextColor
  - lastMessageTextColor
  - typingIndicatorTextColor
  - threadIndicatorTextColor
  - privateGroupIconBackgroundColor
  - protectedGroupIconBackgroundColor
- Added the missing property titleTextColor in `MessageHeaderStyle`.
- Added the missing property threadReplyIconTint in `MessageListStyle`.
- Fixed issue with custom error text in the `CometChatMessageList`.
- Fixed issue with custom error text and status indicator color in `CometChatConversations`.
- Fixed issue with status indicator background and title color in `CometChatMessageHeader` for group conversation.
- Fixed issues with the textFormatters property not working in `CometChatConversations`.
- Fixed issue with custom error text in `ConversationsConfiguration`.
- Fixed issue with overriding privateGroupIcon and protectedGroupIcon in `CometChatMessageHeader`.

## 4.3.14 — 2024-07-18

#### Fixes
- Fixed an issue where the UI navigation bar of the `CometChatConversations` component was transparent.
- Fixed an issue where the reply count of a message was incremented when sending a message in a thread, even if the user was blocked by the logged-in user.
- Fixed an issue where the UI swap actions in the `CometChatConversations` component could not be overridden.
- Fixed a bug where the prop to customize `avatarStyle` in `MessageHeaderConfiguration` was missing.
- Fixed a bug where the prop to customize `avatarStyle` in `MessageListConfiguration` was missing.
- Fixed a bug where the prop to customize `reactionStyle` in `ReactionsConfiguration` was missing.
- Fixed a crash that occurred when opening the detail page with a custom profile view set.
- Fixed an issue where disabling sound for messages in the `CometChatMessageList` and `CometChatMessageComposer` was not working.
- Fixed a crash that occurred when selecting and then deselecting a list item in the `CometChatContacts` component.

## 4.3.13 — 2024-07-15

#### Enhancements
- Addressed high memory usage causing performance degradation in long-running applications, ensuring stable and predictable memory consumption for improved overall application stability and user experience.
- Made all the callback protocol methods optional, simplifying the development process by allowing developers to implement only the necessary functions. This change reduces boilerplate code and makes the codebase cleaner and more maintainable.
- Improved internal management of the connect and disconnect methods in all components. Developers no longer need to manually call these methods, as the connection lifecycle is now handled automatically, leading to a more seamless integration and reduced risk of connection issues.
- Improved handling of multiple internal events for updating components in response to local actions, ensuring smoother and more responsive user interactions.

#### Fixes
- Fixed an issue where dark mode toggle in CometChatConversations resulted in elements becoming invisible.
- Fixed read/delivered receipts behaving inconsistently in multiple cases, such as:
  - When the same user is logged in on two devices, reading a message on one device does not update its read status on the other device.
  - Addressed issues where the last message was not marked as read in CometChatMessages when it is opened from CometChatConversationsWithMessages.

## 4.3.12 — 2024-07-10

**Fixes**
- Fixed an issue where the date separator in `CometChatMessageList` could not be styled, allowing customization of its appearance.
- Fixed a bug where the prop to hide the send button in the `CometChatMessageComposer` component was missing.
- Updated the group conversation typing indicator to display the name of the user who is typing.
- Fixed an issue where the status of blocked users (online/typing) was still visible in the `CometChatMessageHeader` and `CometChatConversation` components.
- Fixed an issue in the `CometChatAddMembers` component where the add button was not visible after performing a search.
- Fixed a crash that occurred when opening an image preview on an iPad.

## 4.3.11 — 2024-07-02

**New**

- Added `ThreadedMessagesStyle` to customize the UI of `CometChatThreadedMessages`.

**Enhancements**

- Added logic to manually clear active call object using `CometChat.clearActiveCall()` when a call ends unexpectedly, allowing subsequent call initiation.
- Added the ability to configure a custom icon for the done button shown in `CometChatThreadedMessages`.
- Updated `CometChatSDK` to `4.0.49` for better performance.

**Fixes**

- Fixed video thumbnail and image preview taking very long to be visible in the sending state of messages.
- Fixed issue of duplication of conversations shown in `CometChatConversations` observed in the situation where a call is accepted when the `CometChatConversations` view is in the navigation stack and after ending that call.
- Resolved issue where messages were not fetched when a custom `MessagesRequestBuilder` is passed to `CometChatMessageList` and uid or guid is not explicitly provided in that `MessagesRequestBuilder` object.
- Fixed issue of inability to customize the color and font of the text in the done button shown in `CometChatThreadedMessages`.

## 4.3.10 — 2024-06-19

**Fixes**
- Resolved issue where the title text for the `CometChatGroups` and `CometChatCreateGroup` components could not be modified.
- Fixed problem preventing developers from updating the styling of the `CometChatGroups` and `CometChatCreateGroup` components.
- Corrected issue where `CometChatConversations` displayed duplicate data upon refresh.

## 4.3.9 — 2024-06-10

**New**
- Introduced real-time updates for the last message and unread count in conversations based on App setting configured via dashboard, ensuring up-to-date information is displayed.

**Enhancements**
- Added mentionsType `Users` and `UsersAndGroupMembers` to define visible mentions in one-on-one and group conversations.
- Added visibility `usersConversationOnly`, `groupConversationOnly` and `both` with the parameter name visible In to control the visibility of the mentions type.

**Fixes**
- Fixed background colour styling for `CometChatListItem`.
- Fixed issue where hiding live reactions wasn't working as expected in `CometChatMessageComposer`.
- Fixed styling for ListItem being absent in `MessageHeaderConfiguration`.
- Fixed issue where ReactionsRequestBuilder was not working in `CometChatReactionList`.
- Fixed crash that occurred when sending multiple messages and leaving the app open for 20-30 minutes.

## 3.0.921-1 — 2024-06-09

**Fixes**
- Fixed a crash that occurred when opening the user or group info screen.

## 4.3.8 — 2024-05-15

**Enhancements** 
- Improved the UI of Poll Messages for better user experience and readability.

**Fixes**
- Added missing function `hideVoiceRecording` in `CometChatComposerConfiguration` for hiding voice recording button.
- Fixed an issue where options to add members were not displayed correctly when the scope of a group is changed while the user is on the conversation screen.
- Resolved an issue with the Profanity Filter not functioning properly in `CometChatConversation`'s last messages.
- Addressed an issue where the `CometChatJoinProtectedGroup` view would open up when clicking on a public group which the logged-in user has not joined, in `CometChatGroupsWithMessages`.
- Resolved an issue where the voice message icon appeared larger than intended on smaller-sized iPhones in `CometChatMessageComposer`, ensuring consistent visual presentation across devices.
- Corrected the behavior of the openChat event in `CometChatUIEventListener`, ensuring its functionality is consistent and reliable.

## 4.3.7 — 2024-05-07

**Enhancements**
- Revamped the message options naming and their sequence for better usability.
- Incoming call screen will now close automatically when the call is picked up by a user from a different device, ensuring a consistent user experience across devices.


**Fixes**
- Fixed an issue where Link Preview was not working occasionally within messages.
- Addressed a problem on the Call History page where a random circular indicator appeared during a pull-to-refresh action.
- Resolved an issue with the incoming call screen being visible to the user who initiated the call from a different device.
- Fixed a bug in CometChatThreadedMessages where some attachment options were non-functional from the message list.
- Corrected an issue with CometChatConversations list cells displaying twice upon pull-to-refresh.
- Resolved a styling issue with CometChatNewMessageIndicator's icon tint not applying.
- Fixed alignment issues in CometChatMessageInformation for messages, improving visual consistency and readability.

## 3.0.920-1 — 2024-05-02

**Enhancements**
- Enhanced the "scroll up to fetch new messages" feature in the Message List, improving the loading behavior and user interaction experience.

## 4.3.6 — 2024-04-30

**New**
- Exposed `tableView` in all components that utilize tableViews to provide greater flexibility and control for customization.

**Enhancements**
- Scroll events for tableView are now overrideable, allowing developers to inherit and extend the component for more detailed scroll position tracking and custom behaviors.
- In the `CometChatMessageList` component, the `scrollToBottomOnNewMessages` configuration was initially defaulted to true, instigating an auto-scroll to the latest message upon its receipt. This default has now been updated to false. Consequently, rather than auto-scrolling, a `newMessageIndicator` will be displayed with a count of the new messages. A tap on this indicator will scroll to the bottom of the list.

## 4.3.5 — 2024-04-26

**New**
- Added `PrivacyInfo.xcprivacy` file that complies with the latest Apple guidelines for SDKs.
- Updated CometChatUIKit with the latest CometChatSDK version 4.0.45, bringing in new features and improvements for better performance and compatibility.

## 4.3.4 — 2024-04-16

**Fixes**
- Rectified an issue in CometChatMessageList where the sending state wasn't visible when the message list was open for a Group.
- Improved the behavior of Smart Replies Extensions by rectifying the distorted cross button and enhancing the appearance and removal of Smart Replies.
- Addressed an issue where the Delete Message bubble would occasionally display the count of threaded messages and the date-time receipt.
- Eliminated flickering in ConversationWithMessages after fetching or reframing the conversation.
- CometChatCreateGroup's create button visibility issue has been resolved, now displaying an activity indicator when the group is in the process of creation.

## 4.3.3 — 2024-04-09

#### **Enhancements:**
- The **CometChatUIKit** class now automatically designates the logged-in user as the sender for message objects passed as arguments to all send message methods, overriding any other sender values set. This includes setting the sender UID and sender object.
- Message objects passed to all send message methods of the **CometChatUIkit** class will now have a random muid automatically assigned if not already set, along with the sender UID and sender object.

#### **Fixes:**
- In the **CometChatMessageList**, pulling to refresh previous messages now occurs simply by scrolling up, with the scroll position fixed.
- Replying to a message no longer causes the parent message's view to become intermittently invisible.
- Within **CometChatMessageTemplate**, it is now possible to remove a single message option by matching that option's ID.
- The **MentionFormatter** class has been renamed to **CometChatMentionsFormatter**.
- Closing smart replies in **CometChatMessageList** no longer results in a visible white strip at that location.
- Constants Classes are now made public to ensure matching IDs at multiple locations.

## 4.3.2 — 2024-04-02

**Fixes:**
- Fixed a localization issue where changes to localized text were not properly reflected at the app level.
- Addressed an issue in CometChatMessageComposer where modifying or editing Composer AttachmentOptions resulted in duplicates.
- Resolved a crash in CometChatMessageList that occurred when sending multiple messages at a high frequency.

## 3.0.919-4 — 2024-04-02

### Fixes

- Resolved a scrolling issue where fetching previous messages inaccurately scrolled users to the top of the conversation, disrupting the message view in `MessageList`.
- Addressed a bug in the `ConversationList` where the typing indicator was erroneously displayed for other users or groups if one user began typing at the same moment another user refreshed the page, ensuring accurate typing status visibility.

## 4.3.1 — 2024-03-21

**Fixed**
- Fixed CometChatTextFormatter issues

## 4.3.0 — 2024-03-21

**New**
- Introduced UI components for adding reactions to messages as a core chat feature:
  - Added CometChatReactions component to display reactions for messages, enhancing user interaction.
  - Added CometChatReactionList component to group and list users by their message reactions.
- Introduced CometChatTextFormatter Class designed to format text matching specific patterns.
- Launched UI components for mentioning users as a foundational chat feature
  - Introduced CometChatMentionsTextFormatter class, an extension of CometChatTextFormatter, to specifically format user mentions within messages and provide the user suggestions when used with CometChatMessageComposer.

**Enhancements**
- Updated CometChatMessageList, CometChatMessageComposer, and CometChatConversations Components to accept an array of CometChatTextFormatter, providing a flexible text formatting system based on various regex patterns, such as differentiating between user mentions and URLs within a message.
- Implemented a callback in CometChatMessages to handle header menu interactions.

**Fixed**
- Fixed the issue with the **Send Form Message** function in CometChatUIKit  class.
- Fixed the problem with the **Card Message** function in CometChatUIKit  class

## 4.2.11 — 2024-02-26

Bug Fix: 
- Randomly crashing on new messages received on iOS version 17.2 and above. 

## 3.0.919-3 — 2024-02-21

Bug Fixed
Crash while sending multiple messages from both sender and receiver.
When a Message is in a sending state and a new message is received then the same date spreader is visible.

## 4.2.1 — 2024-02-13

1. Fixed Threaded Message Count update.
2. Removed sending options for polls, collaborative document in threaded message.
3. Solved listeners issues in CometChatMessageList 
4. Solved Live Reaction getting in all chat window bug. 

## 4.2.0 — 2024-02-05

1. Added **Scheduler Message**, which is a part of interactive messages. **Scheduler Message** lets you schedule meeting.
2. Added  Date and Time Picker in **Form Message**.

## 3.0.919-2 — 2024-01-24

Fixed a crash while sending messages continuously. 

## 4.1.0 — 2023-12-15

Added Features 
- Call Logs 
- AI Conversation Summary 
- AI Assist Bot 

Bugs Fixed 
- CometChatMessages Configuration function not settings solved 
- Hide VideoCall button issue solved
- Disable create group removed
- setOnSendButtonClick not working solved
- Message order issue solved
- Attachment option not visible on iOS 17.1 solved
- Auth token login function issue in CometChatUIKit Class solved
- App crashes when theme color change in CometChatTheme solved
- Navigation bar not visible when coming back from a view controller through sliding gesture in CometChatConversationWithMessages issue solved.
- Delay in sending message issue solved.

## 3.0.919 — 2023-12-14

Fixed issue with Polls options are getting merged.
Fixed issue with delay in sending message

## 4.0.3 — 2023-11-14

Added Interactive message feature

## 4.0.2 — 2023-11-03

- Bug fixes

## 4.0.1 — 2023-10-18

**Added** 
Two new AI features: Conversation Starter and Smart Replies.

**Changed** 
Dependency upgraded to CometChatSDK - 4.0.1 (https://github.com/cometchat-pro/ios-chat-sdk)

**Fix** 
Fixed iOS 17 conversation list opening crash.

## 4.0.0 — 2023-09-05

Added 

- Support for handling events received when disconnected websocket connection is reestablished in CometChatUsers, CometChatGroups, CometChatConversations and CometChatMessageList.
- All Extension classes conform to the updated ExtensionsDataSource class by implementing new methods addExtension and getExtensionId.

Changed 
- Dependency upgraded to CometChatSDK - 4.0.1 (https://github.com/cometchat-pro/ios-chat-sdk)
- Order of options shown for a message in CometChatMessageList
- Replaced implementation of SoundManager with CometChatUIKit.soundManager.
- Replaced implementation of ChatConfigurator.getDataSource() with CometChatUIKit.getDataSource().

Removed 
- Property hideCreateGroup from CometChatGroupsWithMessages.

## v3.0.914-2 — 2023-06-23

#### Fixes
- Added a fix for wrong time stamp


**Full Changelog**: https://github.com/cometchat-pro/cometchat-chat-uikit-ios-swift/compare/v3.0.914-1...v3.0.914-2

## v4.0.0-beta.1.1 — 2023-06-15

#### Improved
- Integration code

**Full Changelog**: https://github.com/cometchat-pro/cometchat-chat-uikit-ios-swift/compare/v4.0.0-beta.1...v4.0.0-beta.1.1

## v4.0.0-beta.1 — 2023-06-07

#### Updated 
- Package name 
- Updated Readme file

**Full Changelog**: https://github.com/cometchat-pro/ios-swift-chat-ui-kit/compare/3.0.914-pluto.beta.2.1...v4.0.0-beta.1

## 3.0.914-pluto.beta.2.1 — 2023-06-02

### Added
- Support for Chat SDK version 3.0.914

### Fixes
- Fixed crash on sending multiple messages  continuously.
- Fixed camera clicked image bubble issue.
- Fixed recursion issue on corner radius style.
- Minor bug fixes and performance improvements.

**Full Changelog**: https://github.com/cometchat-pro/ios-swift-chat-ui-kit/compare/v3.0.912-pluto.beta.2.0...3.0.914-pluto.beta.2.1

## v3.0.914-1 — 2023-04-27

### Added
- Support for Chat SDK version 3.0.914
- Support for Calling SDK version 3.0.0

### Fixes
- Fixed crash on sending video message.
- Resolve activity indicator issue.
- Resolved crash for white board on WebView.

**Full Changelog**: https://github.com/cometchat-pro/ios-swift-chat-ui-kit/compare/v3.0.912-1...v3.0.914-1

## v3.0.912-1 — 2023-04-12

#### Added 
- Support for Chat SDK version 3.0.912
- Support for Calling SDK version 3.0.0

#### Fixes
- Addressed the issue related to whiteboard crash.

## v3.0.912-pluto.beta.2.0 — 2023-04-11

#### Added 
- Support for Chat SDK 3.0.912 
- Support for Calls SDK 3.0.0
- Added calling functionality in UIKit
- Added support for styling components in UIKit
#### Fixed
- Improved overall architecture
- Improved flow for configurations 
- Minor bug fixes and performance improvements

**Full Changelog**: https://github.com/cometchat-pro/ios-swift-chat-ui-kit/compare/v3.0.909-pluto.beta.1.1...v3.0.912-pluto.beta.2.0

## v3.0.911-1 — 2023-02-02

#### Added
- SDK support for v3.0.911
- Minor performance improvements for generating thumbnails
#### Fixed
- Addressed the issue where thumbnails are not generating for images and videos.
- Addressed the issue where media messages were not able to send in the threaded messages.
- Addressed the issue with the reply count in threaded messages.

**Full Changelog**: https://github.com/cometchat-pro/ios-swift-chat-ui-kit/compare/v3.0.910-2...v3.0.911-1

## v3.0.910-2 — 2022-12-27

#### Fixed: 

1. Addressed an issue where now the user will be able to see all lists of groups.
2. Addressed an issue where in the eastern timezone (EST)  date in the header was incorrect. 
3.  Optimised the logic for the message date header where earlier it was showing duplicate entries for the date header.
4. Minor performance improvements

**Full Changelog**: https://github.com/cometchat-pro/ios-swift-chat-ui-kit/compare/v3.0.910-1...v3.0.910-2

## v3.0.910-1 — 2022-10-27

#### Added
- Added support for SDK `v3.0.910`
- Added prefix `CometChatPro.` for SDK classes such as `User, Group, Call, GroupMember` etc

#### Fixed
- Addressed the issue related to the link preview
- Addressed the issue related to the message reactions
- Addressed the issue related to the keyboard appearance
- Minor performance improvements

**Full Changelog**: https://github.com/cometchat-pro/ios-swift-chat-ui-kit/compare/v3.0.909-1...v3.0.910-1

## v3.0.909-1 — 2022-10-18

#### Added:
- SDK version support for 3.0.909

#### Fixed:
- Addressed the issue related to location forwarding in CometChatForwardMessageList
- Addressed the issue for unable to play vibration in sound manager while other applications are playing media
- Addressed the issue where during incoming call voice/video names and surnames are half cut for long names
- Addressed the issue regarding send button where while chatting if the keyboard disappears during the text view is not empty at that time - send button was getting disappeared.

**Full Changelog**: https://github.com/cometchat-pro/ios-swift-chat-ui-kit/compare/v3.0.905-1...v3.0.909-1

## v3.0.909-pluto.beta.1.1 — 2022-09-05

Fixed:
- Addressed the issue related to an unread count in the conversation list
- Addressed the issue related to cancel button in the message composer
- Addressed the issue related to empty states in the message list
- Addressed the issue related to disabling the textView in the message composer
- Changed access specifiers to the public from internal or private for several components
- Optimizations in smart replies component
- Theme optimizations in message composer and other components

## v3.0.908-pluto.beta.1 — 2022-08-12

#### First Beta Release for Pluto UI Kit

## v3.0.908-pluto.alpha.1 — 2022-08-12

#### First Alpha Release for Pluto UIKit

## v3.0.905-1 — 2022-06-22

#### Added:

- Messaging SDK support for v3.0.905
- Calling SDK support for v2.2.0

#### Fixed:

- Addressed the issue where the application crashes randomly while sending a video message.





**Full Changelog**: https://github.com/cometchat-pro/ios-swift-chat-ui-kit/compare/v3.0.900-2...v3.0.905-1

## v3.0.900-2 — 2022-04-30

#### Added: 
 -  Added support for Chat SDK `v3.0.900`
 - Added support for Call SDK `v2.1.1-xc`
 

#### Fixed: 
-  Fixed localization for `Tap to start a conversation`
- Addressed the issue where When a user is scrolling the content of the conversation list is shuffling. 
- Added limit to characters in Group Name and Group Password While creating a group.
- Addressed the issue related to the link preview
- Addressed the issue related to the image thumbnails
- Addressed the issue where the message list is getting crashed sometimes
- Addressed the issue where memory increases with scrolling  in-group member list
- Removed CometChatKingfisher dependency

**Full Changelog**: https://github.com/cometchat-pro/ios-swift-chat-ui-kit/compare/v3.0.900-1...v3.0.900-2

## v3.0.900-1 — 2022-03-23

Added:
- SDK support for v3.0.900

**Full Changelog**: https://github.com/cometchat-pro/ios-swift-chat-ui-kit/compare/v3.0.8-1...v3.0.900-1

## v3.0.8-1 — 2022-01-18

Added:
- Added support for SDK v3.0.8

Fixed:
- Changes for handling multiple device sessions for one-to-one calls.

## v2.4.2-1 — 2022-01-12

Fixed: 
- Changes for handling multiple device sessions for one-to-one calls.

## v3.0.5-1 — 2021-11-24

#### Added

- SDK support for v3.0.5

#### Improvements
- Fixed real-time chat is not working when the user is coming from a background state

>  1.  Improved the real-time messaging experience where users will be able to fetch the latest messages when they are constantly switching from background to foreground state when the conversation list is opened.
>  2. Improved the real-time messaging experience where users will be able to fetch the latest messages when they are constantly switching from background to foreground state when the message list is opened.

## v3.0.3-1 — 2021-09-24

**Added:** 
- Compatibility support for Xcode 13
- Added support for Messaging SDK version 3.0.3. 
- Added support for calling SDK version 2.1.1

## v2.4.1-3 — 2021-09-24

**Added:** 
- Compatibility support for Xcode 13

## v3.0.1-2 — 2021-09-07

**Added:** 

- Added localization for Hungarian
- Added new keywords for localization in other languages

**Fixed:** 
- Fixed the issue related to duplicate entries in NewCallList when reloaded.

## v2.4.1-2 — 2021-09-07

**Added:** 

- Added localization for Hungarian
- Added new keywords for localization in other languages

**Fixed:** 
- Fixed the issue related to duplicate entries in NewCallList when reloaded.

## v3.0.1-1 — 2021-08-16

Added:
- Added SDK support for v3.0.1
- Added  transient message for live reaction
- Added localization for the German language
- Added localization for the Spanish language

Modified:
- Changed status indicator color for online and offline state
- Minor Performance Improvements

## v2.4.1-1 — 2021-08-18

Added:
- Added SDK support for v2.4.1
- Added localization for the German language
- Added localization for the Spanish language

Modified:
- Changed status indicator color for online and offline state
- Minor Performance Improvements

## v3.0.0-beta5-2 — 2021-06-30

Added: 
- Start a conversation from Chats 

Modified:
- Updated New Icons
- Minor changes for Transfer Ownership, leave and delete group confirmation popup.

Fixed:
- Issue related to reply count in threaded chats
- Minor performance improvements

## v2.3.7-2 — 2021-06-30

Added: 
- Start a conversation from Chats 

Modified:
- Updated New Icons
- Minor changes for Transfer Ownership, leave and delete group confirmation popup.

Fixed:
- Issue related to reply count in threaded chats
- Minor performance improvements

## v3.0.0-beta5-1 — 2021-06-15

Added: 
- Support for SDK v3.0.0-beta5
- Reply in private form groups
- Unread count for custom messages
- Localization for the Hungarian language

Modified:
- Enhancements in Location sharing
- Enhancements in reply to message
- Localization for the Russian language
- Minor UI Improvements

## v2.3.7-1 — 2021-06-15

Added: 
- Support for SDK v2.3.7
- Reply in private form groups
- Unread count for custom messages
- Localization for the Hungarian language

Modified:
- Enhancements in Location sharing
- Enhancements in reply to message
- Localization for the Russian language
- Minor UI Improvements

## v3.0.0-beta4-1 — 2021-05-31

Added: 
- Added SDK support for 3.0.0-beta4
- Added toggle to filter user and group conversations in recent chats
- Added view profile in CometChatUserDetailList when the user has value in link parameter
- Added option to hide deleted messages. 
- Added 1-1 private messaging from Group
- Added Delete Conversation from Chats

Modified: 
- Optimized layout for CometChatMessageList, CometChatUserDetailList, CometChatGroupDetailList
- Updated Error Messages

Fixed:
- Addressed the issue where the user list screen is freezing when scrolling
- Addressed the issue where  user list order is not sorted in alphabetical order sometimes
- Fixed the last word is cutting issue in the Arabic language. 
- Fixed layout issues in the Arabic Language
- Fixed data order in the contact list
- Addressed the issue where app crash occurs when a push notification is clicked on the second time

## v3.0.0-beta1-1 — 2021-04-07

Added:
- Support for SDK v3.0.0-beta1
- Suppport for new websokets
- Localization for error messages
- Added localization for swidish and lithuanian language.
- Confirmation popup during delete and leave group
- Transfer ownership in groups
- Added realtime indicators for Connection Listeners.

Modified:
- Replaced CometChatSnackBar with CometChatSnackBoard
- UI for Error, Success, Warning & Info Messages
- Corrected localization for German language.

Fixed:
- Addressed the issue with threads - the reply button is not updating in real-time.
- Addressed the issue for reply message issue with cross-platform
- Fixed the issue to show delete and leave for admins in the group
- Added fix for search results not showing proper results (Not showing empty list if the searched text is different).
- Added fix for text messages when data masking extension is enabled
- Addressed the issue where If you post a link without https:// at the start, once clicked the app/chat will crash.
- Addressed the issue where CometChatMessageList is crashing when multiple messages appended at the same time.

## v2.3.5-1 — 2021-05-31

Added: 
- Added SDK support for 2.3.5
- Added toggle to filter user and group conversations in recent chats
- Added view profile in CometChatUserDetailList when the user has value in link parameter
- Added option to hide deleted messages. 
- Added 1-1 private messaging from Group
- Added Delete Conversation from Chats

Modified: 
- Optimized layout for CometChatMessageList, CometChatUserDetailList, CometChatGroupDetailList
- Updated Error Messages

Fixed:
- Addressed the issue where the user list screen is freezing when scrolling
- Addressed the issue where  user list order is not sorted in alphabetical order sometimes
- Fixed the last word is cutting issue in the Arabic language. 
- Fixed layout issues in the Arabic Language
- Fixed data order in the contact list
- Addressed the issue where app crash occurs when a push notification is clicked on the second time

## v2.3.0-1 — 2021-04-07

Added:
- Support for SDK v2.3.0
- Localization for error messages
- Added localization for Swedish and Lithuanian languages.
- Confirmation popup during delete and leave group
- Transfer ownership in groups
- Added real-time indicators for Connection Listeners.

Modified:
- Replaced CometChatSnackBar with CometChatSnackBoard
- UI for Error, Success, Warning & Info Messages
- Corrected localization for the German language.

Fixed:
- Addressed the issue with threads - the reply button is not updating in real-time.
- Addressed the issue for reply message issue with cross-platform
- Fixed the issue to show delete and leave for admins in the group
- Added fix for search results not showing proper results (Not showing empty list if the searched text is different).
- Added fix for text messages when data masking extension is enabled
- Addressed the issue where If you post a link without https:// at the start, once clicked the app/chat will crash.
- Addressed the issue where CometChatMessageList is crashing when multiple messages appended at the same time.

## v2.2.1-1 — 2021-03-03

Added:
- Support for SDK v2.2.1

Fixed:
- Addressed the issue where when the search bar is enabled, searched users are not navigating to the chat screen.
- Added changes for the unread count.
- Addressed the issue for online/offline indicators in the message list.
- Minor performance improvements

## v2.2.0 — 2021-02-22

Added:
- Support for v2.2.0 SDK
- Minor Performace Improvements

## v2.1.14 — 2021-02-08

Fixed:
 
- Added changes for polls V2
- Addressed message reactions issue where messages scroll to the top when updating reaction

## v2.1.13 — 2021-02-03

Added:
- Tab shuffling in UIKit Settings

Fixed:
- Change date format for message header from (01/01/2021) to (1 Jan, 2021)
- Modified localization text for some keywords
- Minor performance improvements

## v2.1.12 — 2021-01-19

Added: 
- Support for Direct calling in groups
- Minor performance improvements
- SDK support for v2.1.6-beta2

## v2.1.11 — 2021-01-05

Added:
- Support for Message Translation Extension
- Localization for group actions
- Additional support files related to privacy, security, and License.

## v2.1.10 — 2020-12-28

Added:
- SDK support for 2.1.5
- Localisation support for English, French (Française), Hindi (हिंदी), Arabic (عربى), German(Deutsche), Spanish(Española), Malay(Bahasa Melayu), Portuguese(Português), Russian(русский), Chinese-Simplified (简体中文), Chinese -Traditional(中國傳統的)

Fixed:
- Minor Performance improvements

Revised:
- Documentation & Readme files.

## v2.1.9 — 2020-12-03

Added: 
- SDK support for v2.1.4
- Support for Collaborative Whiteboard
- Support for Collaborative Document
- Support for Data Masking

## v2.1.8 — 2020-11-26

Added: 
- Message Reaction support

Fixed:
- Minor performance improvements

## v2.1.7 — 2020-11-13

Added: 
- SDK support for v2.1.3
- Stickers support

Fixed:
- Issue with missing reply message icon
- Minor performance improvements

## v2.1.6 — 2020-10-30

Added: 
- Support for SDK v2.1.3
- setMode(mode: MODE_SINGLE)  for one-on-one calls 
- Missing status indicator for Group Members.

Fixed:
- Addressed the issue with endTyping. 
- Minor performance improvements.

## v2.1.5 — 2020-10-21

Added: 
- Hyperlink support for Messages
- Multivalue Filters for Message Categories & Message Types.
- Customization settings for UIKit
- Minor Performace Improvements

## v2.1.4 — 2020-10-12

Added:
- SDK support for v2.1.2
- Multiline TextView for sending text messages

Fixed:
- Minor performance improvements

## v2.1.2 — 2020-09-25

Added: 
- Polls Extension
- Support for SF symbols for devices below iOS 12 

Fixed: 
- Optimisation for conversation list to load quicker 
- Minor Performance improvements

## v2.1.1 — 2020-09-02

Added: 

- Location Sharing
- Message Receipt Information

Fixed:

- Addressed issue where the message bubble turns white when selected on devices below iOS 12.

## v2.1.0 — 2020-08-19

Added: 

- Support for SDK v2.1.0
- Support for .xcframework
- Support for bitcode enabled
- New Calling Component i.e. CometChatProCalls

## v2.0.7 — 2020-07-27

Added: 
- SDK support for v2.0.12
- Threaded Conversations
- Swipeable modal for message Actions
- Emoji resizing up to 3 emojis

## v2.0.6 — 2020-07-09

Added: 
- Live Reactions
- Minor performance improvements

## v2.0.5 — 2020-07-01

**Added:** 

- Support for Image Moderation Extension
- Support for Thumbnail Generation Extension
- Support for Profanity Filter Extension
- Support for Sentiment Analysis Extension
- Support for Reply on Message 

## v2.0.4 — 2020-06-22

**Added:**

- Support for SDK v2.0.11
- Support for Private, Password-protected Groups.
- Ban Member in Group, Unban members in Group. 
- Support for Moderator and its actions. 
- Ability to Edit/Delete Messages for Moderator. 

**Replaced:**

-  Restructured member count using a new parameter in the `Group` object.
-  Group Subtitle with member count. 

## v2.0.3 — 2020-06-09

Added: 
- SDK support for v2.0.9
- Update User

Fixed: 
- Addressed the issue related to memory consumption

## v2.0.2 — 2020-05-18

Added: 
- Audio Note Recording

Fixed: 
- Issue with multiple instance of CometChatCallManager()

## v2.0.1 — 2020-04-09

Added: 
- Support for SDK v2.0.8
- Support for Xcode 11.4

## v2.0.0 — 2020-04-01

Added: 
1. Support for Audio/Video Calling.
2. Support for Video Message Type.
3. Shared Media. 
4. Empty states.
5. Support for share images from a camera.
6. Ringtones for real-time activities.
7. Added support for Objective C. 

Fixed: 
1. Fixed Selection color for MesssageList in Dark Mode.
2. Fixed Background color for CreateGroup in Dark Mode.
3. Minor performance improvement.

## v1.0.1-beta — 2020-03-05

Added: 

- Forward Message, Share Message. 
- Date headers.
- Copy - Paste: Single & Multiple Messages.

Replaced: 
- Toast with Snackbar. 
- CometFisher with CometChatKingfisher. 

Other: 
- Minor performance improvements. 

## v1.0.0 — 2020-02-18

**Added:** 
1. Link Preview Extension Support
2. Smart Replies Extension Support
3.  Open image, files, docs such as PDF, PPT on tap on media files.
4. Open app or browser on tap on links in the link preview. 

**Fixed:**
1.  Fixed scroll to bottom messages in CometChatMessageList.
2. Fixed issue with opening action sheet on iPad. 
3. Minor performance improvements.

## v1.0.0-beta2 — 2020-01-27

Added: 
1. Edit & Delete Message
2. Minor optimizations.

Fixed: 
1. Addressed the issue where tapping on the `Send Message` button in CometChatUserDetail Screen, it was creating a hierarchy of view controllers.
2. Removed view more cell in the CometChatGroupDetail screen. 
3. Addressed the issue where a user opens a chat window, by default it should be on the bottom in CometChatMessageList Screen.
4. Addressed the issue to show the unblock button instead of a blocked button if the user is blocked in the user detail screen.

## v1.0.0-beta1 — 2020-01-14

- Added: 

1. Group detail screen for CometChatGroupList. 
2. User detail screen for CometChatUserList. 
3. Create a group,  Leave group, Delete group.
4. Add Member, Remove Member. 
5. Assign as  Administrator, Dismiss as Administrator. 
6. Block user, Unblock user. 
7. Search in Chats.
8. Added version support for Xcode 11.3

## v1.0.0-beta — 2019-12-23

- First Release

