#### 3.0.9
###### Friday September 9, 2016

- Added support for Japanese, Portuguese (Brazil), Turkish, and Chinese
- Added debug logging for print layout
- Rename reachability constant to avoid conflicts 
- Fix crashes related to print queue

#### 3.0.8
###### Wednesday July 27, 2016

- Fix compiler warnings
- Fix handling of bundle when using frameworks

#### 3.0.7
###### Tuesday May 17, 2016

- Fixing prints on printers that create bordered prints

#### 3.0.6
###### Friday May 13, 2016

- Adding support for multi-tasking (split screen) functionality
- iOS7 is no longer supported

#### 3.0.5
###### Wednesday April 27, 2016

- Fixing landscape page range keyboard on iOS 7
- Renaming MPReachability to MPMobilePrintSDKReachability to avoid naming conflicts
- Fixing page selection icon placement in iOS 7 device rotation
- Fixes to print metrics handling
- International paper sizes are properly selected by the printer at print-time
- No longer relying on default value for the lastOptions black-and-white value
- Allow custom data in print metrics

#### 3.0.4
###### Friday April 1, 2016

- Update pod to support integration into Swift projects via `use_frameworks!` directive in Podfile
- Fix "Printer not Available" text and icon placement
- Ensuring that numCopies metrics are correct when printing from the queue
- Ensuring that new print queue entries don't overwrite entries from previous pod versions
- Forcing a printer status check whenever wifi status changes (while on Page Settings screen)
- Updated German translation of "Copy" and "Copies"

#### 3.0.3
###### Thursday March 3, 2016

- Add backward compatibilty to print queue to support print later jobs saved with SDK version prior to 3.x
- Add support for multiple images in single print job

#### 3.0.2
###### Tuesday February 9, 2016

- Fixes to layout logic consistency between preview and print
- Fix crashes related to print queue
- Add multi-job print preview (scroll through jobs)
- Page number indicator for multi-page and multi-job previews
- Localization improvements
- Print metrics updates

#### 3.0.1
###### Thursday December 17, 2015

- Change handling of multi-page PDF documents optimize loading and memory use 
- Localization into various languages
- Print Queue screen now displays accurate job list after deleting a job(s)
- Fix device rotation bugs on multi-page view(s)
- Fix zoom bug on multi-page view(s)
- Fix metrics bug related to sublcassing share activity

#### 3.0.0
###### Tuesday, November 10, 2015

- Initial relase of public CocoaPod (no new features)

---
Transition to public CocoaPod

#### 2.6.11
###### Tuesday, November 10, 2015

- Restored HPPPPrintDelegate and HPPPAddPrintLaterDelegate callbacks to the 'Cancel' button functionality on the Page Settings, Add Print, and Print Settings screens.

#### 2.6.10
###### Thursday, November 5, 2015

- Added ability to move the 'Cancel' button from the right side of the navigation bar to the left side (only on Page Settings, Add Print, and Print Settings screens).
- Fixed bug where the print item for the wrong paper size was used in the Add Print screen.

#### 2.6.9
###### Wednesday, November 4, 2015

- Fix bug in layout logic causing preview/print rotation mismatch
- Remove "Number of Copies" option for iOS 7
- Updated reported library version to use a constant rather than inspecting cocoapod version

#### 2.6.8
###### Tuesday, October 28, 2015

- Fix UI bug causing scroll jitter in print preview

#### 2.6.7
###### Wednesday, October 21, 2015

- Resolve iPad split view issue with Xcode 6

#### 2.6.6
###### Monday, October 19, 2015

- Minor bug fixes related to iPad split layout, international paper list, and device ID processing

#### 2.6.5
###### Friday, October 16, 2015

- Add feature to support bordered layouts
- Update device ID handling in print metrics

#### 2.6.4
###### Tuesday, October 13, 2015

- Improved iPad experience for print, add-to-queue, and settings view
- Enhancements and fixes to add print job name editing

#### 2.6.3
###### Friday, October 2, 2015

- Fix appearance of settings table view rows (print, add-to-queue, and settings views)
- Fix iPad crash when adding job to print queue
- Added utility methods for building US and international paper lists

#### 2.6.2
###### Friday, September 25, 2015

- Fix bug in printer paper size calculation 
- Improved table view cell alignment in page settings view

#### 2.6.1
###### Wednesday, September 23, 2015

- Wi-Fi messaging improvements
- Minor print metrics fixes

#### 2.6.0
###### Monday, September 21, 2015

- Refactor `HPPPPaper` to support international and custom sizes
  - International papers now included in standard list of available papers
  - Ability to register any arbitrary custom paper size
- Add `HPPPPrintPaperDelegate` to provide support for roll printers
  - e.g. specify cut length
- XCode 7 support in project files

#### 2.5.12
###### Tuesday, September 15, 2015

- Fix memory leak in `HPPPPageSettingsTableViewController`
- Minor UI improves to page settings view

#### 2.5.11
###### Friday, September 11, 2015

- Improvements to appearance settings and documentation

#### 2.5.10
###### Thursday, September 3, 2015

- Minor style fix in print settings UI

#### 2.5.9
###### Thursday September 3, 2015

- Proper handling of print settings when printing multiple jobs at once from print queue
  - e.g. number of copies, page range, color vs. black and white for each job

#### 2.5.8
###### Tuesday September 1, 2015

- Various additions to new style functionality
- Various fixes to print metrics

#### 2.5.7
###### Thursday August 27, 2015

- Refactor handling of custom styling 
  - e.g. fonts, colors, sizes, etc.
  - Update Sample app to demonstrate new style configuration capabilities
- Remove layout type enum and replace with string layout type names
- Add `HPPPLayoutFactoryDelegate` for specifying client-provided layout type

#### 2.5.4
###### Tuesday August 25, 2015

- Another minor print metrics fix

#### 2.5.3
###### Tuesday August 25, 2015

- More fixes to print metrics

#### 2.5.2
###### Monday August 24, 2015

- Refactor print settings in `HPPPPrintSettingsDelegateManager`
- Print metrics fixes to improve accuracy

#### 2.5.1
###### Tuesday August 18, 2015

- Update Sample app to demonstrate print and print later as `UIBarButtonItem`
  - Implement A/B testing functionality for print icons in Sample app
- Minor style fixes

#### 2.5.0
###### Friday August 14, 2015

- First version to establish release notes. 
- Page range functionality for multi-page documents
- Added "direct print" capability to print directly with no UI
  - See `HPPPPrintManager`

---
Only high-level summary of major releases included before 2.5.0

#### 2.4.0
###### Friday July 17, 2015

- Support for multi-page documents
- Overhauled Sample app

#### 2.3.4
###### Friday June 19, 2015

- Record bundle ID and print library version in metrics

#### 2.3.1
###### Tuesday June 16, 2015

- Page layout improvements

#### 2.2.1
###### Tuesday June 2, 2015

- Refactor to use new `HPPPPrintItem` class

#### 2.1.1
###### Monday May 18, 2015

- Initial PDF support 

#### 2.0.1
###### Wednesday May 6, 2015

- Introduce localization
- Initial Lumberjack logging