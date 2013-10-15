HotTubFeedMachine
=================

A feed recorder and playback app for mac OS X

- install CocoaPods
- run #pod install

- USING THE APP:

 -recording:
    - put in your feed URL and click "set" button to verify this feed
    - hit the record button to record the feed
    - (optional) hit stop
    - save with CMD-S or menu
 
 -playback:
    - open old session
    - hit play button for "realtime" playback
    - click / scrub on scrubber to move around in the session during playback
    - use http://localhost:8080 to see feed output
  
- TODO:
  - auto stop web server on exit app
  - deal with multiple versions of NSDocument a problem.  Can it easily be single doc at a time ? 
  - detect fileType ( json / xml ) for output when writing
  - implement FF 2x, FF 4x, FF 8x, etc
  - be able to trim recording start / end points
  
- DONE:
  - auto start web server on playback ( multiple versions of NSDocument a problem )  
  - more work with autolayout to get things looking better when window is resized
  - implement button under "scrubber" to skip ahead / forward in time during playback
  - clean up UI around showing new data
  - get saving / loading back finished up ( NSDocuments ) 
  - get playback working
  
  
