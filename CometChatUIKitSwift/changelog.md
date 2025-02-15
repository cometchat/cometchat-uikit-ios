# Changelog

All notable changes to the **CometChatUIKit SampleApp** will be documented in this file.



# [5.0.0-beta.4] - 2025-02-15

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
- Fixed an issue where an admin could not see the **"Delete and Exit"** option after being promoted in a group.
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

---


