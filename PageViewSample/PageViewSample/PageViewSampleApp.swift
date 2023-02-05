//
//  PageViewSampleApp.swift
//  PageViewSample
//
//  Created by Photon Juniper on 2023/1/7.
//

import SwiftUI

@main
struct PageViewSampleApp: App {
    var body: some Scene {
        WindowGroup {
            PageViewSample()
#if os(macOS)
                .frame(minWidth: 600, minHeight: 500)
#endif
        }
        
    }
}
