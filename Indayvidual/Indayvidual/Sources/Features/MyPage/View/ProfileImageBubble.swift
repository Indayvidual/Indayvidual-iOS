//
//  ProfileImageBubble.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/18/25.
//

import SwiftUI
import PhotosUI
import UIKit

struct ProfileImageBubble: View {
    let localPreview: UIImage?
    let imageUrl: String?

    var body: some View {
        Group {
            if let preview = localPreview {
                Image(uiImage: preview)
                    .resizable()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            } else if let urlStr = imageUrl, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().frame(width: 80, height: 80)
                    case .success(let img):
                        img.resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    default:
                        Image("profile")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    }
                }
            } else {
                Image("profile")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            }
        }
    }
}
