# UI Unified

![Studio Guide](https://github.com/cometchat-pro/ios-chat-uikit/blob/master/Screenshots/UIUnified.png) 

**UI Unified** is a way to launch a fully working chat application using the **CometChat Kitchen Sink**.In UI Unified all the UI Screens and UI Components working together to give the full experience of a chat application with minimal coding effort. 

To use Unified UI one has to launch `CometChatUnified` class.  `CometChatUnified` is a subclass of  `UITabbarController`.

```
let unfiedUI = CometChatUnified()
unfiedUI.setup(withStyle: .fullScreen)
self.present(unfiedUI, animated: true, completion: nil)

```

![Studio Guide](https://github.com/cometchat-pro/ios-chat-uikit/blob/master/Screenshots/UIUnified.gif) 

`CometChatUnified` provides below method to present this activity: 

1. `setup(withStyle: .fullScreen)` : This will present the window in Full screen.

2. `setup(withStyle: .popover)` : This will present the window as a popover.
---









