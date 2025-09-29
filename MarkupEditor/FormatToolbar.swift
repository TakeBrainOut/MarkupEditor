//
//  FormatToolbar.swift
//  MarkupEditor
//
//  Created by Steven Harris on 4/7/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import SwiftUI

public struct FormatToolbar: View {
    @EnvironmentObject private var toolbarStyle: ToolbarStyle
    @ObservedObject private var observedWebView: ObservedWebView = MarkupEditor.observedWebView
    @ObservedObject private var selectionState: SelectionState = MarkupEditor.selectionState
    private let contents: FormatContents = MarkupEditor.toolbarContents.formatContents
    @State private var hoverLabel: Text = Text("Text Format")

    public init() {}

    public var body: some View {
        LabeledToolbar(label: hoverLabel) {
            
            // H1, H2 and etc
            if contents.paragraph {
                if #available(iOS 16, macCatalyst 16, *) {
                    Menu {
                        ForEach(StyleContext.StyleCases, id: \.self) { styleContext in
                            Button(action: { observedWebView.selectedWebView?.replaceStyle(selectionState.style, with: styleContext) }) {
                                Text(styleContext.name)
                                    .font(.system(size: styleContext.fontSize))
                            }
                        }
                    } label: {
                        // Note foreground color is black on Mac Catalyst, which
                        // doesn't seem to be settable at all with "Optimized for Mac"
                        Text(selectionState.style.name)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .frame(width: 88, height: toolbarStyle.buttonHeight(), alignment: .center)
                    }
                    .buttonStyle(.borderless)
                    .menuStyle(.button)         // Not available until iOS 16
//                    .frame(width: 88, height: toolbarStyle.buttonHeight())
                    .frame(width: 88, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.1, green: 0.1, blue: 0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke( Color.clear, lineWidth: 1)
                            )
                    )
                    .disabled(!selectionState.canStyle)
                } else {
                    Menu {
                        ForEach(StyleContext.StyleCases, id: \.self) { styleContext in
                            Button(action: { observedWebView.selectedWebView?.replaceStyle(selectionState.style, with: styleContext) }) {
                                Text(styleContext.name)
                                    .font(.system(size: styleContext.fontSize))
                            }
                        }
                    } label: {
                        Text(selectionState.style.name)
                            .frame(width: 64, height: toolbarStyle.buttonHeight(), alignment: .center)
                    }
                    .menuStyle(.borderlessButton)   // Deprecated as of iOS14
                    .frame(width: 88, height: toolbarStyle.buttonHeight())
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.1, green: 0.1, blue: 0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke( Color.clear, lineWidth: 1)
                            )
                    )
                    .disabled(!selectionState.canStyle)
                }
            }

            ToolbarImageButton(
                systemName: "bold",
                action: { observedWebView.selectedWebView?.bold() },
                active: $selectionState.bold,
                onHover: { over in hoverLabel = Text(over ? "Bold" : "Text Format") }
            )
            ToolbarImageButton (
                systemName: "italic",
                action: { observedWebView.selectedWebView?.italic() },
                active: $selectionState.italic,
                onHover: { over in hoverLabel = Text(over ? "Italic" : "Text Format") }
            )
            ToolbarImageButton(
                systemName: "underline",
                action: { observedWebView.selectedWebView?.underline() },
                active: $selectionState.underline,
                onHover: { over in hoverLabel = Text(over ? "Underline" : "Text Format") }
            )
            if contents.code {
                ToolbarImageButton(
                    systemName: "curlybraces",
                    action: { observedWebView.selectedWebView?.code() },
                    active: $selectionState.code,
                    onHover: { over in hoverLabel = Text(over ? "Code" : "Text Format") }
                )
            }
            if contents.strike {
                ToolbarImageButton(
                    systemName: "strikethrough",
                    action: { observedWebView.selectedWebView?.strike() },
                    active: $selectionState.strike,
                    onHover: { over in hoverLabel = Text(over ? "Strikethrough" : "Text Format") }
                )
            }
            if contents.subSuper {
                ToolbarImageButton(
                    systemName: "textformat.subscript",
                    action: { observedWebView.selectedWebView?.subscriptText() },
                    active: $selectionState.sub,
                    onHover: { over in hoverLabel = Text(over ? "Subscript" : "Text Format") }
                )
                ToolbarImageButton(
                    systemName: "textformat.superscript",
                    action: { observedWebView.selectedWebView?.superscript() },
                    active: $selectionState.sup,
                    onHover: { over in hoverLabel = Text(over ? "Superscript" : "Text Format") }
                )
            }
        }
    }
}

struct FormatToolbar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            HStack {
                FormatToolbar()
                    .environmentObject(ToolbarStyle.compact)
                Spacer()
            }
            HStack {
                FormatToolbar()
                    .environmentObject(ToolbarStyle.labeled)
                Spacer()
            }
            Spacer()
        }
    }
}
