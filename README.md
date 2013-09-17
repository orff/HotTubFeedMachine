HotTubFeedMachine
=================

A feed recorder and playback app for mac OS X

- install CocoaPods
- run #pod install

- USING THE APP:

 -recording:
    - put in your feed URL and click "use" button to verify this feed
    - hit the record button to record the feed
    - save with CMD-S or menu
 
 -playback:
    - open old session
    - click "start web server"
    - hit play button for "realtime" playback
    - click / scrub on scrubber to move around in the session during playback
  
- TODO:
  - auto start / stop web server on playback / exit app ( multiple versions of NSDocument a problem )
  - detect fileType ( json / xml ) for output when writing
  - implement FF 2x, FF 4x, FF 8x, etc
  - be able to trim recording start / end points
  
- DONE:
  - more work with autolayout to get things looking better when window is resized
  - implement button under "scrubber" to skip ahead / forward in time during playback
  - clean up UI around showing new data
  - get saving / loading back finished up ( NSDocuments ) 
  - get playback working
  
  
