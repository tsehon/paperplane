//
//  ImageLoader.swift
//  Paperplane
//
//  Created by tyler on 2/16/24.
//

import Foundation
import SwiftUI
import Combine

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cancellables = Set<AnyCancellable>()

    func load(fromURL url: URL) {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in self?.image = $0 })
            .store(in: &cancellables)
    }
}
