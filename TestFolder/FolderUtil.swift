//
//  FolderUtils.swift
//  TestFolder
//
//  Created by bebe on 5/1/25.
//

import Foundation

class FolderUtils: ObservableObject {
    @Published var result = ""
    
    private let fileManager = FileManager.default
    private let baseURL: URL
    
    var prefix = "untitled "
    var maxNum: Int
    var origNums: Set<Int>
    
    init(path: String = "", max: Int = 99) {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        maxNum = max
        baseURL = documentsURL.appendingPathComponent(path)
        origNums = Set(0...max)
    }
    
    func createFolders() {
        var failFolders: [String] = []
        for i in 0...maxNum {
            let folder = prefix + String(i)
            let folderURL = baseURL.appendingPathComponent(folder)
            do {
                try createFolder(at: folderURL)
            } catch {
                print(error)
                failFolders.append(folder)
            }
        }
        if (failFolders.isEmpty) {
            result = "Folders created successfully"
        } else {
            result = "Error creating folder \(failFolders)"
        }
    }
    
    func createFolderOnEmpty() {
        let empty = getEmptyFoldersNum()
        guard empty.isEmpty == false else {
            result = "No empty folder to create"
            return
        }
        let folder = prefix + String(empty.min()!)
        let folderURL = baseURL.appendingPathComponent(folder)
        do {
            try createFolder(at: folderURL)
            result = "Folder \(folder) created successfully"
        } catch {
            result = "Error creating folder \(folder)"
        }
    }
    
    private func listDirs(url: URL) -> [URL] {
        var files: [URL] = []
        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants]) {
            for case let fileURL as URL in enumerator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isDirectoryKey])
                    if fileAttributes.isDirectory == true {
                        files.append(fileURL)
                    }
                } catch { print(error, fileURL) }
            }
        }
        return files
    }
    
    private func extractDigits(from url: URL) -> Int? {
        let lastComponent = url.lastPathComponent.removingPercentEncoding ?? ""
        guard lastComponent.starts(with: prefix) else { return nil }
        let digits = lastComponent.dropFirst(prefix.count)
        guard digits.allSatisfy({ $0.isNumber }) else {
            print("Invalid folder name: \(lastComponent)")
            return nil
        }
        return Int(digits)
    }
    
    func getEmptyFoldersNum() -> Set<Int> {
        let dirs = listDirs(url: baseURL)
        var existDirs: Set<Int> = []
        for item in dirs {
            guard let digits = extractDigits(from: item) else { continue }
            existDirs.insert(digits)
        }
        let empty = origNums.subtracting(existDirs)
        result = "Empty folders: \(empty)"
        return empty
    }
    
    func removeFolder(at num: Int) {
        let folder = prefix + String(num)
        let folderURL = baseURL.appendingPathComponent(folder)
        do {
            try deleteFolder(at: folderURL)
            result = "Folder \(folder) deleted successfully"
        } catch {
            result = "Error deleting folder \(folder)"
        }
    }
    
    private func createFolder(at url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    }
    
    private func deleteFolder(at url: URL) throws {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print(error)
            throw error
        }
    }
}
