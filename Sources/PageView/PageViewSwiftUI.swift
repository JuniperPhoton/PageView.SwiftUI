import SwiftUI

/// Provide information about paging.
///
/// You use the ``currentIndex`` to get the current paging index. The ``currentIndex`` won't be updated until the swiping ends.
/// You use the ``nextIndex`` to get the predicated next index. The framework guarantees that the ``nextIndex`` will be safe to use and won't cause out-of-bounds issues.
/// In the LTR context, If the ``currentIndex`` is 0 and the user is swiping to the right, the ``nextIndex`` should be 0 too.
///
/// You use the ``progress`` to get the swiping progress between pages. Useful when you building a indicator which follows the paging progress.
public struct PagingTranslation: CustomStringConvertible, Equatable {
    let currentIndex: Int
    let nextIndex: Int
    let progress: CGFloat
    
    public init(currentIndex: Int, nextIndex: Int, progress: CGFloat) {
        self.currentIndex = currentIndex
        self.nextIndex = nextIndex
        self.progress = progress
    }
    
    public var description: String {
        return "\(currentIndex) -> \(nextIndex), Progress: \(progress)"
    }
}

/// A container view providing paging  with virtualization feature.
///
/// PageView takes care of the views displaying in the screen, and will discard the views offscreen(which is defined by ``offscreenCountPerSide``.
///
/// Users can swipe horizontally to switch pages. You provides ``pageIndex`` binding to get or set the current page.
/// To get more paging info like paging progress, you pass the ``onPageTranslationChanged`` block and you will get noticed when paging translation changed.
///
/// See the initializer to know more customations.
public struct PageView<Content: View, C: RandomAccessCollection>: View where C.Element: Identifiable & Equatable {
    let items: C
    let itemContent: (C.Element) -> Content
    let pageIndex: Binding<Int>
    
    let disablePaging: Binding<Bool>
    
    var onPageTranslationChanged: ((PagingTranslation) -> Void)? = nil
    
    @GestureState var dragTranslationX: CGFloat = 0
    
    @State var translationX: CGFloat = 0
    @State var virtualPageIndex: CGFloat = 0
    
    @State var displayedItemId: C.Element.ID? = nil {
        didSet {
            if let originalIndex = items.firstIndex(where: { v in
                v.id == displayedItemId
            }) as? Int {
                pageIndex.wrappedValue = originalIndex
            }
        }
    }
    
    @State var displayedItems: [C.Element] = []
    @State var width: CGFloat = 0.0
    
    private let offscreenCountPerSide: Int
    private let spacing: CGFloat
    private let scrollSlop: CGFloat
    private let animationDuration: CGFloat
    
    /// - Parameter items: items to be populated, should be a ``RandomAccessCollection``
    /// - Parameter pageIndex: a binding to the current page index
    /// - Parameter disablePaging: a binding to disable the paging. Set this to true will disable the gesture, you can still set the ``pageIndex`` to navigate to the specified page
    /// - Parameter spacing: spacing between pages, horizontally. Note that the spacing won't be see until users start swiping
    /// - Parameter scrollSlop: how much pts the user swipe to navigate to the next page, default to 20pt
    /// - Parameter animationDuration: animation duration, default to 0.3 seconds
    /// - Parameter onPageTranslationChanged: when the user start swiping, this block will be invoked to provide information about paging translation. See ``PagingTranslation`` to know more.
    /// - Parameter itemContent: provides ``View`` given a ``C.Element`` you passed in the ``items``
    public init(items: C,
                pageIndex: Binding<Int>,
                disablePaging: Binding<Bool>,
                offscreenCountPerSide: Int = 2,
                spacing: CGFloat = 20,
                scrollSlop: CGFloat = 20,
                animationDuration: CGFloat = 0.3,
                onPageTranslationChanged: ((PagingTranslation) -> Void)? = nil,
                @ViewBuilder itemContent: @escaping (C.Element) -> Content) {
        self.items = items
        self.itemContent = itemContent
        self.pageIndex = pageIndex
        self.disablePaging = disablePaging
        self.offscreenCountPerSide = offscreenCountPerSide
        self.spacing = spacing
        self.scrollSlop = scrollSlop
        self.animationDuration = animationDuration
        self.onPageTranslationChanged = onPageTranslationChanged
        print("dwccc start page index \(pageIndex), disable paging \(disablePaging)")
    }
    
    private func calculateDisplayItems(originalIndex: Int) {
        displayedItems.removeAll()
        
        var start = originalIndex - 1
        if start < 0 {
            start = 0
        }
        var end = start + offscreenCountPerSide * 2
        if end >= items.count {
            end = items.count - 1
        }
        for i in start...end {
            if let index = items.index(items.startIndex, offsetBy: i, limitedBy: items.endIndex) {
                displayedItems.append(items[index])
            }
        }
        
        print("dwccc calculateDisplayItems \(start)...\(end), virtualPageIndex \(virtualPageIndex), current input \(originalIndex)")
    }
    
    public var body: some View {
        let gesture = DragGesture()
            .onEnded { value in
                onGestureEnd(value: value)
            }
            .updating($dragTranslationX) { v, state, _ in
                state = v.translation.width
            }
        GeometryReader { proxy in
            HStack(spacing: spacing) {
                ForEach(displayedItems, id: \.id) { item in
                    itemContent(item)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .offset(x: (-CGFloat(virtualPageIndex) * (proxy.size.width + spacing)) + translationX)
        }
        .contentShape(Rectangle())
        .simultaneousGesture(gesture, including: disablePaging.wrappedValue ? .subviews : .all)
        .onAppear {
            calculateDisplayItems(originalIndex: pageIndex.wrappedValue)
            updateVirtualPageIndex(originalIndex: pageIndex.wrappedValue)
        }
        .onChange(of: dragTranslationX) { newValue in
            translationX = newValue
            
            let progress: CGFloat = abs(translationX) / self.width
            if progress == 0 {
                return
            }
            
            let currentIndex = pageIndex.wrappedValue
            var nextIndex = translationX < 0 ? currentIndex + 1 : currentIndex - 1
            nextIndex = nextIndex.clamp(to: 0...items.count - 1)
            
            let translation = PagingTranslation(currentIndex: currentIndex,
                                                nextIndex: nextIndex, progress: progress)
            self.onPageTranslationChanged?(translation)
        }
        .onChange(of: pageIndex.wrappedValue, perform: { newValue in
            withEastOutAnimation(duration: animationDuration) {
                updateVirtualPageIndex(originalIndex: newValue)
            }
        })
        .listenWidthChanged { width in
            self.width = width
        }
    }
    
    private func onGestureEnd(value: DragGesture.Value) {
        withEastOutAnimation(duration: animationDuration) {
            var newVirtualIndex = virtualPageIndex
            if translationX > scrollSlop {
                var index = virtualPageIndex - 1
                if index < 0 {
                    index = 0
                }
                newVirtualIndex = index
            } else if translationX < -scrollSlop {
                var index = virtualPageIndex + 1
                if index >= CGFloat(displayedItems.count) {
                    index = CGFloat(displayedItems.count) - 1
                }
                newVirtualIndex = index
            }
            
            print("dwccc on gesture end newVirtualIndex: \(newVirtualIndex), from virtualPageIndex \(virtualPageIndex)")
            
            self.virtualPageIndex = newVirtualIndex
            self.translationX = 0
            
            let currentItem = displayedItems[Int(self.virtualPageIndex)]
            let nextOriginalIndex = items.firstIndex { id in
                id == currentItem
            } as! Int
            
            let translation = PagingTranslation(currentIndex: pageIndex.wrappedValue,
                                                nextIndex: nextOriginalIndex, progress: 1.0)
            
            self.onPageTranslationChanged?(translation)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                withEastOutAnimation(duration: animationDuration) {
                    calculateDisplayItems(originalIndex: nextOriginalIndex)
                    updateVirtualPageIndex(originalIndex: nextOriginalIndex)
                }
            }
        }
    }
    
    private func updateVirtualPageIndex(originalIndex: Int) {
        if originalIndex != 0 && originalIndex != items.count - 1  {
            virtualPageIndex = 1
        } else if originalIndex == 0 {
            virtualPageIndex = 0
        } else if originalIndex == items.count - 1 {
            virtualPageIndex = CGFloat(displayedItems.count) - 1
        }
        
        displayedItemId = displayedItems[Int(virtualPageIndex)].id
    }
}

fileprivate func withEastOutAnimation<Result>(duration: Double = 0.3,
                                         _ delay: Double = 0.0,
                                         _ body: () throws -> Result) -> Result? {
    return try? withAnimation(Animation.easeOut(duration: duration).delay(delay)) {
        try body()
    }
}

fileprivate extension View {
    /// Listen the width changed of this view.
    /// - Parameter onWidthChanged: invoked on width changed
    func listenWidthChanged(onWidthChanged: @escaping (CGFloat) -> Void) -> some View {
        self.overlay(GeometryReader(content: { proxy in
            Color.clear.onChange(of: proxy.size.width) { newValue in
                onWidthChanged(newValue)
            }.onAppear {
                onWidthChanged(proxy.size.width)
            }
        }))
    }
}

fileprivate extension Comparable {
    func clamp(to range: ClosedRange<Self>) -> Self {
        if self < range.lowerBound {
            return range.lowerBound
        }
        if self > range.upperBound {
            return range.upperBound
        }
        return self
    }
}
