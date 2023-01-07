# PageView.SwiftUI

![](./Doc/hero-image.gif)

A container view providing paging  with virtualization feature.

PageView takes care of the views displaying in the screen, and will discard the views offscreen(which is defined by ``offscreenCountPerSide``.

Users can swipe horizontally to switch pages. You provides ``pageIndex`` binding to get or set the current page.

To get more paging info like paging progress, you pass the ``onPageTranslationChanged`` block and you will get noticed when paging translation changed.

## Import using Swift Package

![](./Doc/xcode-setup.jpg)

Add as package dependencies in your Xcode, like below.

```
https://github.com/JuniperPhoton/PageView.SwiftUI
```

Before using PageView, remember to import: 

```swift
import PageView
```

## Example

The first look:

```swift
PageView(items: items,
         pageIndex: $pageIndex,
         disablePaging: Binding.constant(false), spacing: 8) { item in
    ZStack {
        AsyncImage(...)
        
        Text(...)
    }
}
```

The example above achieve the following feature:

![](./Doc/preview-banner.jpg)

The indicator uses the binding `pageIndex` to update itself:

```swift
HStack {
    ForEach(items, id: \.id) { item in
        Circle().fill(Color.white)
            .opacity(items.firstIndex(of: item) == pageIndex ? 1.0 : 0.5)
            .frame(width: 12, height: 12)
    }
}.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    .padding()
```

## Customization 

First please refer to the initializer of the ``PageView``.

- Parameter `items`: items to be populated, should be a ``RandomAccessCollection``
- Parameter `pageIndex`: a binding to the current page index
- Parameter `disablePaging`: a binding to disable the paging. Set this to true will disable the gesture, you can still set the ``pageIndex`` to navigate to the specified page
- Parameter `spacing`: spacing between pages, horizontally. Note that the spacing won't be see until users start swiping
- Parameter `scrollSlop`: how much pts the user swipe to navigate to the next page, default to 20pt
- Parameter `animationDuration`: animation duration, default to 0.3 seconds
- Parameter `onPageTranslationChanged`: when the user start swiping, this block will be invoked to provide information about paging translation. See ``PagingTranslation`` to know more.
- Parameter `itemContent`: provides ``View`` given a ``C.Element`` you passed in the ``items``

```swift
    public init(items: C,
                pageIndex: Binding<Int>,
                disablePaging: Binding<Bool>,
                offscreenCountPerSide: Int = 2,
                spacing: CGFloat = 20,
                scrollSlop: CGFloat = 20,
                animationDuration: CGFloat = 0.3,
                onPageTranslationChanged: ((PagingTranslation) -> Void)? = nil,
                @ViewBuilder itemContent: @escaping (C.Element) -> Content)
```

The example of `onPageTranslationChanged` will output when swiping from `page0` to `page1`. You can use this progress to update your indicator progressively.

```
app current translation is 0 -> 1, Progress: 0.028837985361502068
app current translation is 0 -> 1, Progress: 0.03816793893129771
app current translation is 0 -> 1, Progress: 0.05173874872028069
app current translation is 0 -> 1, Progress: 0.05597964376590331
app current translation is 0 -> 1, Progress: 0.057675970723004136
app current translation is 0 -> 1, Progress: 0.05937233650654024
app current translation is 0 -> 1, Progress: 0.06446139503071327
app current translation is 0 -> 1, Progress: 0.07803220481969625
app current translation is 0 -> 1, Progress: 0.09499574617575143
app current translation is 0 -> 1, Progress: 0.11535198027244355
app current translation is 0 -> 1, Progress: 0.14079727289330868
app current translation is 0 -> 1, Progress: 0.15521628498727735
app current translation is 0 -> 1, Progress: 0.1798133753031568
app current translation is 0 -> 1, Progress: 0.20610687022900764
app current translation is 0 -> 1, Progress: 0.24173027989821882
app current translation is 0 -> 1, Progress: 1.0
```