//
//  ContentView.swift
//  PageViewSample
//
//  Created by Photon Juniper on 2023/1/7.
//

import SwiftUI
import PageView

protocol Page: Equatable, Identifiable, Hashable {
    var id: String { get }
}

class PageClass: Page {
    open var id: String {
        return "base"
    }
    
    static func == (lhs: PageClass, rhs: PageClass) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class FirstPage: PageClass {
    override var id: String {
        return "first"
    }
}

class SecondPage: PageClass {
    override var id: String {
        return "second"
    }
}

class ThirdPage: PageClass {
    override var id: String {
        return "third"
    }
}

class DataViewModel: ObservableObject {
    @Published var pages: [PageClass] = [
        FirstPage(),
        SecondPage(),
        ThirdPage()
    ]
}

enum Tabs: String, Hashable {
    case new = "New"
    case downloaded = "Downloaded"
    case profile = "Profile"
}

struct PageViewSample: View {
    @State var selectedTab = Tabs.new
    
    var body: some View {
        TabView(selection: $selectedTab) {
            VStack {
                Pages()
            }.tabItem {
                Label(Tabs.new.rawValue, systemImage: "paperplane")
            }
            VStack {
                Text(Tabs.downloaded.rawValue)
            }.tabItem {
                Label(Tabs.downloaded.rawValue, systemImage: "square.and.arrow.down")
            }
            VStack {
                BannerView2()
            }.tabItem {
                Label(Tabs.profile.rawValue, systemImage: "person")
            }
        }
    }
}

struct Pages: View {
    @ObservedObject var viewModel = DataViewModel()
    
    @State var disablePaging = false
    @State var pageIndex = 0
    @State var translation = PagingTranslation(currentIndex: 0, nextIndex: 0, progress: 0)
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    ForEach(viewModel.pages, id: \.id) { page in
                        Text(page.id.uppercased()).bold()
                            .foregroundColor(Color.accentColor)
                            .opacity(viewModel.pages.firstIndex(of: page) == self.pageIndex ? 1.0 : 0.3)
                            .onTapGesture {
                                if let index = viewModel.pages.firstIndex(of: page) {
                                    self.pageIndex = index
                                }
                            }
                    }
                }.padding()
                
                PageView(items: viewModel.pages,
                         pageIndex: $pageIndex,
                         disablePaging: $disablePaging,
                         animationDuration: 0.3,
                         onPageTranslationChanged: { translation in
                    print("app current translation is \(translation)")
                    self.translation = translation
                }) { item in
                    List(0...100, id: \.self) { i in
                        NavigationLink {
                            VStack {
                                Text(String(i))
                            }.navigationTitle(Text(String(i)))
                        } label: {
                            Text(String(i))
                        }
                    }
                }
            }
        }
#if os(iOS)
        .navigationBarHidden(true)
#endif
    }
}

class Banner: Equatable, Identifiable {
    static func == (lhs: Banner, rhs: Banner) -> Bool {
        return lhs.imageUrl == rhs.imageUrl
    }
    
    let imageUrl: String
    let authorName: String
    
    init(imageUrl: String, author: String) {
        self.imageUrl = imageUrl
        self.authorName = author
    }
}

struct BannerView2: View {
    @State var items: [Banner] = [
        Banner(imageUrl: "https://images.unsplash.com/photo-1673082797735-f994d6120ded?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2071&q=80", author: "John"),
        Banner(imageUrl: "https://images.unsplash.com/photo-1671725779253-0a5a067cfac4?ixlib=rb-4.0.3&ixid=MnwxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2070&q=80", author: "Mike"),
        Banner(imageUrl: "https://images.unsplash.com/photo-1673085796350-a842999ec21f?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2070&q=80", author: "Amy"),
    ]
    
    @State var pageIndex: Int = 0
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Title")
                .bold().font(.largeTitle)
                .padding()
            
            ZStack {
                PageView(items: items,
                         pageIndex: $pageIndex,
                         disablePaging: Binding.constant(false), spacing: 8) { item in
                    ZStack {
                        AsyncImage(url: URL(string: item.imageUrl)!, transaction: Transaction(animation: .easeOut)) { phase in
                            switch phase  {
                            case .success(let image):
                                image.resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .clipped()
                            case .empty:
                                Rectangle().fill(Color.gray.opacity(0.2))
                            case .failure(_):
                                Rectangle().fill(Color.red.opacity(0.2))
                            @unknown default:
                                Rectangle().fill(Color.red.opacity(0.2))
                            }
                        }
                        
                        Text(item.authorName)
                            .foregroundColor(Color.white)
                            .font(.largeTitle.bold())
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                }
                
                HStack {
                    ForEach(items, id: \.id) { item in
                        Circle().fill(Color.white)
                            .opacity(items.firstIndex(of: item) == pageIndex ? 1.0 : 0.5)
                            .frame(width: 12, height: 12)
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
