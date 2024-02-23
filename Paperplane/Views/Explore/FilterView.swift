//
//  FilterView.swift
//  Paperplane
//
//  Created by tyler on 2/22/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct FilterView: View {
    @Binding var tags: [String]
    @Binding var selectedTags: Set<String>
    @Binding var sheetVisible: Bool

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let _ = print(width)
            let tagsPerRow = calculateTagsPerRow(forWidth: width, tagWidth: 200)

            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(chunkTags(tags, into: tagsPerRow), id: \.self) { rowTags in
                            HStack(spacing: 50) {
                                ForEach(rowTags, id: \.self) { tag in
                                    Button(action: {
                                        toggleTagSelection(tag: tag)
                                    }) {
                                        Text(tag)
                                            .foregroundColor(.white)
                                    }
                                    .background(selectedTags.contains(tag) ? Color.blue : Color.gray)
                                }
                            }
                        }
                    }
                    .padding(50)
                }
                Spacer()
                Button("Confirm") {
                    sheetVisible = false
                }
                .padding(.bottom, 50)
                .frame(alignment: .center)
            }
        }
        .frame(minWidth: 500, maxWidth: 500, minHeight: 500, maxHeight: 500)
        .glassBackgroundEffect()
    }

    func toggleTagSelection(tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }

    func calculateTagsPerRow(forWidth width: CGFloat, tagWidth: CGFloat) -> Int {
        // Subtract some padding or margins you expect between tags
        let adjustedWidth = width - 100// Example padding
        let tagsPerRow = Int(adjustedWidth / tagWidth)
        return max(tagsPerRow, 1) // Ensure at least one tag per row
    }

    func chunkTags(_ tags: [String], into chunks: Int) -> [[String]] {
        // Your dynamic chunking logic based on 'chunks'
        return stride(from: 0, to: tags.count, by: chunks).map {
            Array(tags[$0..<min($0 + chunks, tags.count)])
        }
    }
}

struct FilterViewPreviewContainer : View {
    @State private var tags: [String] = ["Sci-Fi", "Fantasy", "Mystery", "Romance", "Horror", "Non-Fiction", "Biography"]
    @State private var selected: Set<String> = []
    
    var body: some View {
        FilterView(tags: $tags, selectedTags: $selected, sheetVisible: .constant(true))
    }
}

struct FilterPreview_Previews : PreviewProvider {
    static var previews: some View {
        FilterViewPreviewContainer()
    }
}
