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
    var tags: [String]
    @Binding var selectedTags: Set<String>
    @Binding var sheetVisible: Bool
    
    /*
    TODO: actually get the tag width using .background, as seen here: https://stackoverflow.com/questions/56505043/how-to-make-view-the-size-of-another-view-in-swiftui
     */

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let tagsPerRow = calculateTagsPerRow(forWidth: width, tagWidth: 100)

            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        ForEach(chunkTags(tags, into: tagsPerRow), id: \.self) { rowTags in
                            HStack(spacing: 25) {
                                ForEach(rowTags, id: \.self) { tag in
                                    Button(action: {
                                        toggleTagSelection(tag: tag)
                                    }) {
                                        Text(tag)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .overlay(
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color.clear, lineWidth: 2))
                                    }
                                    .background(TagBorder(show: selectedTags.contains(tag)))
                                }
                            }
                        }
                        Spacer()
                    }
                }
                HStack{
                    Spacer()
                    Button("Confirm Filters") {
                        sheetVisible = false
                    }
                    .font(.title)
                    .frame(alignment: .center)
                    .background(RoundedRectangle(cornerRadius: 30).foregroundStyle(Color.blue))
                    Spacer()
                }
            }
        }
        .padding(50)
        .frame(minWidth: 500, maxWidth: 500, minHeight: 500, maxHeight: .infinity)
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

struct TagBorder: View {
    let show: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .stroke(lineWidth: 3.0).foregroundColor(show ? Color.blue : Color.clear)
            .onTapGesture {
                withAnimation(Animation.easeInOut(duration: 0.3)) {
                    
                }
            }
    }
}

struct FilterViewPreviewContainer : View {
    @State private var tags: [String] = ["Sci-Fi", "Fantasy", "Mystery", "Romance", "Horror", "Non-Fiction", "Biography"]
    @State private var selected: Set<String> = []
    
    var body: some View {
        FilterView(tags: tags, selectedTags: $selected, sheetVisible: .constant(true))
    }
}

struct FilterPreview_Previews : PreviewProvider {
    static var previews: some View {
        FilterViewPreviewContainer()
    }
}
