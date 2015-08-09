# TURecipientBar CHANGELOG

### 2.0.2

- Fixed crash related to removing from superview.
- Fixed crash related to a nil placeholder.
- Added delegate hook for custom search tableView layout.
- Added option to show multiple lines while searching.
- Exposed toLabel, lineView, addButton, and summaryLabel.
- Fixed multistage text input (#31 Thanks [YuAo](https://github.com/davbeck/TURecipientBar/pull/32)).

### 2.0.1

- Fixed crash related to offscreen views.
- Fixed searchFieldTextAttributes (#24).
- Fixed retain cycle (#18).

## 2.0.0

- Added support for Cocoapods 0.36/frameworks. Images are now referenced by the classes bundle.
- Updated recipient images to be more flat and thin to match the style of iOS 8. They also now use tintColor.
- Reduced the shadow over the search table view and changed the background to the default white.
- Added support for a visual effect background that matches the navigation bar.

In order to keep the source code clean and take advantage of UIVisualEffectView, **the minimum version was changed to iOS 8.0**.

### 1.1.2

- [Fixed placeholder label layout.](https://github.com/davbeck/TURecipientBar/commit/2c8980a84f1712f5cbdfbfe7d5d960e5514dfe7b)

- [Added search field attributes control.](https://github.com/davbeck/TURecipientBar/commit/cf1cca09c7947ef1b987275eb0c94b44b38743b8)

- [Fixed bug where recipients are added before title attributes are set.](https://github.com/davbeck/TURecipientBar/commit/adddbac929f575aa5faa127a76dd9e3ea2990f50)

- [Added ability to get the selected recipient.](https://github.com/davbeck/TURecipientBar/commit/99abbfb39ee89291797cc5988d8607f2517a149d)

- [Added better support for showing the table view.](https://github.com/davbeck/TURecipientBar/commit/c1556f28592a2785810e8096ad9ab33d39490807)

- [Added ability to hide the drop shadow that appears during search.](https://github.com/davbeck/TURecipientBar/pull/22)

  Thanks to [Matthew Crenshaw](https://github.com/sgtsquiggs) for the pull request.



### 1.1.1

- Fixed keyboard insets.

- Fixed Core Animation warnings.

- Fixed crash related to setting the label text to nil.

- Fixed removing recipients when animations are disabled.

- Automatically added recipients now include the entered text as the address.

## 1.1.0

- Improved performance with more than a dozen recipients.

  Previously, when the recipients bar had more than a handful of recipients, adding a recipient would hang the app for a few seconds. After a few dozens, it could take up to a minute to add a participant.

  This was because internally, we were recreating every single constraint when the recipients array changed. While it may have been possible to solve this issue by only adding new constraints, I switched to manual layout instead. I have tested this on an iPhone 4 running iOS 7 and was able to load 200 recipients without lag. Please do not use `TURecipientBar` to spam large numbers of recipients.

- Added optional animations for recipients.

  Now, by default recipients will animate in and out. You can disable this by setting `animatedRecipientsInAndOut` to `NO`.

- Added documentation.

  Now all the methods are commented with AppleDoc style documentation. CocoaDocs should generate more detailed documentation at http://cocoadocs.org/docsets/TURecipientBar.

- Made `TURecipient` a protocol.

  Now you can use your own models as recipients. `TURecipient` the class can still be used and there are no plans to deprecate it, mainly because `CoreFoundation` classes can't be extended with a category (*cough* ABPerson *cough*).

- Added customization for summary and placeholder text.

  See `summaryTextAttributes` and `placeholderTextAttributes`.

- Fixed a bug that kept the list of recipients from scrolling to the bottom when added outside the bar.

- Fixed bug that caused the bar to go blank when the user ended editing when not scrolled to the bottom.

- Fixed priority of the height constraint when created internally.

  Now the height constraint that is created internally has a default priority so that it will not conflict with height restricting constraints.