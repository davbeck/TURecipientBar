# TURecipientBar CHANGELOG

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