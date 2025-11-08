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
    @State private var showStylePicker: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    
    private var accentColor: Color {
        // Get accent color from MarkupToolbar if available, otherwise use default green
        if let uiColor = MarkupToolbar.sharedAccentColor {
            return Color(uiColor: uiColor)
        }
        return Color(red: 0.4, green: 0.8, blue: 0.2)
    }
    
    private var styleButtonBackgroundColor: Color {
        colorScheme == .dark 
            ? Color(red: 0.1, green: 0.1, blue: 0.1)
            : Color(UIColor.systemGray5)
    }
    
    private var styleButtonTextColor: Color {
        colorScheme == .dark ? Color.white : Color(UIColor.label)
    }

    public init() {}

    public var body: some View {
        LabeledToolbar(label: hoverLabel) {
            
            // H1, H2 and etc
            if contents.paragraph {
                Button(action: {
                    showStylePicker = true
                }) {
                    Text(selectionState.style.name)
                        .foregroundColor(styleButtonTextColor)
                        .fontWeight(.bold)
                        .frame(width: 88, height: 40, alignment: .center)
                }
                .buttonStyle(.borderless)
                .frame(width: 88, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(styleButtonBackgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.clear, lineWidth: 1)
                        )
                )
                .disabled(!selectionState.canStyle)
                .sheet(isPresented: $showStylePicker) {
                    StylePickerSheet(
                        selectedStyle: selectionState.style,
                        accentColor: accentColor,
                        onStyleSelected: { styleContext in
                            observedWebView.selectedWebView?.replaceStyle(selectionState.style, with: styleContext)
                            showStylePicker = false
                        }
                    )
                    .presentationDetents([.height(CGFloat(StyleContext.StyleCases.count * 50 + 20))])
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

// MARK: - Style Picker Sheet

struct StylePickerSheet: View {
    let selectedStyle: StyleContext
    let accentColor: Color
    let onStyleSelected: (StyleContext) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Style options
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(StyleContext.StyleCases, id: \.self) { styleContext in
                        Button(action: {
                            onStyleSelected(styleContext)
                        }) {
                            HStack {
                                Text(styleContext.name)
                                    .font(.system(size: styleContext.fontSize))
                                    .foregroundColor(.primary)
                                Spacer()
                                if styleContext == selectedStyle {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(accentColor)
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(styleContext == selectedStyle ? accentColor.opacity(0.1) : Color(UIColor.systemBackground))
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        if styleContext != StyleContext.StyleCases.last {
                            Divider()
                                .padding(.leading, 20)
                        }
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
        }
        .background(Color(UIColor.systemBackground))
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
