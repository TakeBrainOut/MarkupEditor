//
//  LabeledToolbar.swift
//  MarkupEditor
//
//  Created by Steven Harris on 4/29/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import SwiftUI

/// The standard way to display one of the toolbars with a label above. Typically ToobarImageButtons are provided as its content.
public struct LabeledToolbar<Content: View>: View {
    @EnvironmentObject private var toolbarStyle: ToolbarStyle
    @Environment(\.colorScheme) private var colorScheme
    private let label: Text
    private let content: Content
    
    private var labelColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.7) : Color(UIColor.secondaryLabel)
    }
    
    public init(label: Text, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }
    
    public var body: some View {
        switch toolbarStyle.style {
        case .labeled:
            VStack(spacing: 2) {
                label
                    .font(.system(size: 10, weight: .light))
                    .foregroundColor(labelColor)
                HStack (alignment: .bottom) {
                    content
                }
                .padding([.bottom], 2)
                // The following fixes a problem with the individual buttons only being partially
                // tappable, while preserving the .onHover behavior.
                .gesture(TapGesture(), including: .subviews)
            }
        case .compact:
            HStack(alignment: .center) {
                content
            }
            .padding([.top, .bottom], 2)
            // The following fixes a problem with the individual buttons only being partially
            // tappable, while preserving the .onHover behavior.
            .gesture(TapGesture(), including: .subviews)
        }
    }
}

struct LabeledToolbar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            HStack {
                LabeledToolbar(label: Text("Test Label")) {
                    ToolbarImageButton(
                        systemName: "square.and.arrow.up.fill",
                        action: { print("up") }
                    )
                    ToolbarImageButton(
                        systemName: "square.and.arrow.down.fill",
                        action: { print("down") }
                    )
                }
                .environmentObject(ToolbarStyle.compact)
                Spacer()
            }
            HStack {
                LabeledToolbar(label: Text("Test Label")) {
                    ToolbarImageButton(
                        systemName: "square.and.arrow.up.fill",
                        action: { print("up") }
                    )
                    ToolbarImageButton(
                        systemName: "square.and.arrow.down.fill",
                        action: { print("down") }
                    )
                }
                .environmentObject(ToolbarStyle.labeled)
                Spacer()
            }
            Spacer()
        }
    }
}
