# Full Screen video in Mac Catalyst

A demo app showing how to resize AppKit window when putting an AVPlayerViewController in full screen.

⚠️ **NOTE**: This is just a proof-of-concept, not all edgecases are handled properly.

Private UIKit APIs are used to toggle player full screen. AppKit APIs are used to interact with NSWindow.

Uses [Dynamic](https://github.com/mhdhejazi/Dynamic) library to conveniently call AppKit from Catalyst app.

Read [blog post](http://tom.lokhorst.eu/2020/08/full-screen-video-in-mac-catalyst) for background information.
