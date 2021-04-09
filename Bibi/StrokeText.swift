//
//  StrokeText.swift
//  Bibi
//
//  Created by Shahar Melamed on 12/25/20.
//

import SwiftUI

struct StrokeText: View {
    let text: String
    let width: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            ZStack {
                Text(text).offset(x: width, y: width)
                Text(text).offset(x: -width, y: -width)
                Text(text).offset(x: -width, y: width)
                Text(text).offset(x: width, y: -width)
            }
            .foregroundColor(color)
            Text(text)
        }
    }
}

struct StrokeText_Previews: PreviewProvider {
    static var previews: some View {
        StrokeText(text: "X", width: 5, color: .red)
    }
}
