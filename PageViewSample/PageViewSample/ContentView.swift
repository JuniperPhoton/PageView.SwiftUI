//
//  ContentView.swift
//  PageViewSample
//
//  Created by Photon Juniper on 2023/1/7.
//

import SwiftUI
import PageView
import NukeUI

enum Page: String, Equatable, Identifiable, Hashable, CaseIterable {
    case new = "New"
    case featured = "Featured"
    case random = "Random"
    case search = "Search"
    
    var id: String {
        return self.rawValue
    }
}

enum Tabs: String, Hashable, CaseIterable {
    case new = "New"
    case downloaded = "Downloaded"
    case profile = "Profile"
}

struct PageViewSample: View {
    @State var selectedTab = Tabs.new
    
    var body: some View {
        BannerView()
    }
}

class Banner: Equatable, Identifiable, Hashable {
    static func == (lhs: Banner, rhs: Banner) -> Bool {
        return lhs.imageUrl == rhs.imageUrl
    }
    
    let imageUrl: String
    let name: String
    
    init(imageUrl: String, name: String) {
        self.imageUrl = imageUrl
        self.name = name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(imageUrl)
    }
}

struct BannerView: View {
    @State var items: [Banner] = [
        Banner(imageUrl: "https://images.unsplash.com/photo-1672824528354-784dea42edaa?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1675&q=80", name: "Snow land"),
        Banner(imageUrl: "https://images.unsplash.com/photo-1672207163711-d57124315946?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2091&q=80", name: "Landscape"),
        Banner(imageUrl: "https://images.unsplash.com/photo-1667569700688-dca9fa7430a8?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2054&q=80", name: "Island"),
        Banner(imageUrl: "https://images.unsplash.com/photo-1667298026326-bf93f52460e0?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1675&q=80", name: "Viliage"),
        Banner(imageUrl: "https://images.unsplash.com/photo-1662555320245-0c113fe1b87c?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2832&q=80", name: "Road"),
        Banner(imageUrl: "https://images.unsplash.com/photo-1661256195466-abf9df7d3e2c?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2178&q=80", name: "Morning"),
    ]
    
    @State var pageIndex: Int = 0
    
    @Namespace var namespace
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Gallery")
                    .bold().font(.largeTitle)
                
                HStack(spacing: 0) {
                    ZStack {
                        Text("\(pageIndex + 1)")
                            .tracking(4)
                            .font(.title.bold())
                            .foregroundColor(Color.accentColor)
                            .id(pageIndex)
                            .transition(.move(edge: .bottom))
                    }.clipped()
                    
                    Text("/\(items.count)")
                        .tracking(4)
                        .font(.title.bold())
                        .foregroundColor(Color.accentColor)
                }
                
            }.padding()
            
            ZStack {
                PageView(items: items,
                         pageIndex: $pageIndex,
                         disablePaging: Binding.constant(false), spacing: 8) { item in
                    ImageItemView(item: item)
                }
                
                indicatorView
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private var indicatorView: some View {
        HStack {
            ForEach(items, id: \.id) { item in
                Circle().fill(Color.white.opacity(0.3))
                    .frame(width: 12, height: 12)
                    .background {
                        if item == items[pageIndex] {
                            Circle().fill(Color.white)
                                .matchedGeometryEffect(id: "indicator", in: namespace)
                        }
                    }
                    .onTapGesture {
                        pageIndex = items.firstIndex(of: item)!
                    }
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding()
    }
}

struct ImageItemView: View {
    let item: Banner
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                LazyImage(source: ImageRequest(url: URL(string: item.imageUrl)!)) { state in
                    if state.isLoading {
                        Rectangle().fill(Color.gray.opacity(0.5))
                    } else if let image = state.image {
                        image.scaledToFill()
                            .frame(width: reader.size.width, height: reader.size.height)
                    }
                }
                    .frame(width: reader.size.width, height: reader.size.height)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                
                Text(item.name)
                    .foregroundColor(Color.white)
                    .font(.largeTitle.bold())
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .shadow(radius: 4)
            }
        }.padding(.horizontal)
    }
}
