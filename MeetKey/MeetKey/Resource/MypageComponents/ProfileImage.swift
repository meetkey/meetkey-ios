//
//  ProfileImage.swift
//  MeetKey
//
//  Created by sumin Kong on 2/9/26.
//
import SwiftUI

import SwiftUI

struct ProfileImage: View {
    let imageString: String?
    let size: CGFloat

    var body: some View {
        Group {
            if let imageString,
               let uiImage = loadImageFromDocuments(imageString) {

                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()

            } else if let imageString,
                      let url = URL(string: imageString),
                      imageString.hasPrefix("http") {

                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image("defaultProfile")
                        .resizable()
                        .scaledToFill()
                }

            } else {
                Image("defaultProfile")
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private func loadImageFromDocuments(_ filename: String) -> UIImage? {
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)

        return UIImage(contentsOfFile: url.path)
    }
}
