//
//  ContentView.swift
//  TestFolder
//
//  Created by bebe on 5/1/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var folderUtils = FolderUtils(path: "testf", max: 999)
    
    var body: some View {
        VStack(spacing: 30) {
            Button("Create Folders") {
                folderUtils.createFolders()
            }
            Button("remove Folders") {
                folderUtils.removeFolder(at: 235)
                folderUtils.removeFolder(at: 22)
                folderUtils.removeFolder(at: 511)
            }
            Button("Check empty spot") {
                _ = folderUtils.checkFolders()
            }
            Button("Create on empty") {
                folderUtils.createFolderOnEmpty()
            }
            Text(folderUtils.result)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
