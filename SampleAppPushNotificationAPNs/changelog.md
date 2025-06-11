# Changelog

All notable changes to the **CometChatUIKit SampleApp** will be documented in this file.

---

## [5.0.6]

### 🆕 New
- _None_

### ✨ Enhancements
- Added support for `hideShareMessageOption` property in the `CometChatMessageList` to align with other message option visibility controls in iOS V5 UIKit.

### 🐞 Fixes
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

### 🛑 Deprecations
- _None_

### 🗑 Removals
- _None_

---

## [5.0.5]

### 🆕 New
- _None_

### ✨ Enhancements
- _None_

### 🐞 Fixes
- Fixed an issue where the edit message preview in `CometChatMessageComposer` persisted when navigating back from the thread messages screen to the main message screen, instead of resetting appropriately.
- Fixed an issue where admin and moderator controls disappeared after group member activity like joining or leaving a group in the group details screen.
- Fixed incorrect display of group action messages inside `CometChatMessageList` in threaded messages screen.
- Fixed an issue where the sticker panel failed to open after multiple edits and navigation events between screens with `CometChatMessageComposer`.
- Fixed issue where the `CometChatReactionList` would not scroll between tabs after the last reaction was removed.
- Fixed an issue where the `CometChatMessageBubble` would disappear when multiple touches occurred on it in `CometChatMessageList`.
- Fixed a bug where the `CometChatCallButton` didn’t work on the second attempt to initiate call from the call detail screen.
- Fixed an issue where reactions were added to wrong `CometChatMessageBubble` in `CometChatMessageList`.
- Fixed the issue where `MediaRecorderStyle` properties were not applying correctly to the `CometChatMediaRecorder`.
- Resolved a bug that caused group calls to start separate 1-on-1 calls for group members instead of a single group session.
- Fixed incorrect user status display where users appeared offline in the user details screen instead of showing the last seen time of the user.
- Fixed animation issue which caused reactions to slide away while removing the reaction from `CometChatReactionList`.
- Fixed a UI bug where owner or admin controls were incorrectly visible to participants.

### 🛑 Deprecations
- _None_

### 🗑 Removals
- _None_

---

## [5.0.4]

### 🆕 New
- _None_

### ✨ Enhancements
- _None_

### 🐞 Fixes
- Fixed time stamp issue in `CometChatMessageList` where incorrect time was displayed for messages.

### 🛑 Deprecations
- _None_

### 🗑 Removals
- _None_

---

## [5.0.3]

### 🆕 New
- _None_

### ✨ Enhancements
- Added support for the following new languages in iOS UIKit:
  - English (UK)
  - Dutch
  - Japanese
  - Korean
  - Turkish
  - Malay
- Introduced a new `CometChatDateTimeFormatter` class to enable full customization of how date and time are displayed across the CometChat UI Kit.

### 🐞 Fixes
- Fixed a crash issue occurring when integrating CometChatUIKitSwift v5.0.2 with the latest version of CometChatSDK.

### 🛑 Deprecations
- _None_

### 🗑 Removals
- _None_

---

## [5.0.2]

### 🆕 New
- _None_

### ✨ Enhancements
- _None_

### 🐞 Fixes
- Fixed an issue where avatar was visible in user-to-user chats in `CometChatMessageList` iOS UIKit v5 (Release 5.0.1).
- Fixed a UI bug where the back button appeared on the left side for a few seconds after ending a call in `CometChatMessageHeader`.
- Fixed an issue where a member was unable to re-enter a group after being removed in `CometChatGroups`.
- Resolved an issue related to audio recording in the `CometChatMediaRecorder`.
- Fixed an issue where the "Go to Latest Message" button did not scroll to the last message in `CometChatMessageList`.
- Fixed navigation issue from create conversation screen to the `CometChatMessageList`.
- Resolved a bug where the avatar displayed incorrectly in user-to-user in `CometChatThreadedMessageHeader`.
- Fixed blocking/unblocking user behavior that incorrectly displayed online status in `CometChatMessageHeader`.
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

---

## [5.0.1]

### 🆕 New
- _None_

### ✨ Enhancements
- Mapped all strings to the localization file, cleaned up existing entries, and added new translations for newly introduced strings.
- Renamed `Remove` to `Kick` in `CometChatGroupMembers` options for better clarity.
- Updated the UI for `CometChatMessageComposer` in case of blocked user and added the option to unblock the user.

### 🐞 Fixes
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

### 🛑 Deprecations
- _None_

### 🗑 Removals
- _None_

---

## [5.0.0]

### 🆕 New
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

### ✨ Enhancements
- _None_

### 🐞 Fixes
- Style props issues.

### 🛑 Deprecations
- _None_

### 🗑 Removals
- _None_