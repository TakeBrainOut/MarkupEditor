//
//  MarkupToolbar.swift
//  MarkupEditor
//
//  Created by Steven Harris on 2/28/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import SwiftUI

/// The MarkupToolbar shows the current selectionState and acts on the selectedWebView held
/// by the observedWebView.
///
/// The MarkupToolbar observes the selectionState so that its display reflects the current state.
/// For example, when selectedWebView is nil, the toolbar is disabled, and when the selectionState shows
/// that the selection is inside of a bolded element, then the bold (B) button is active and filled-in.
/// The MarkupToolbar contains multiple other toolbars, such as StyleToolbar and FormatToolbar
/// which invoke methods in the selectedWebView, an instance of MarkupWKWebView.
public struct MarkupToolbar: View {
    
    public static var managed: MarkupToolbar?   // The toolbar created when using MarkupEditorView or MarkupEditorUIView
    public static var sharedAccentColor: UIColor?  // Shared accent color for use in other components
    public let toolbarStyle: ToolbarStyle
    private let withKeyboardButton: Bool
    @ObservedObject private var observedWebView = MarkupEditor.observedWebView
    @ObservedObject private var selectionState = MarkupEditor.selectionState
    @ObservedObject private var searchActive = MarkupEditor.searchActive
    private var contents: ToolbarContents
    public var markupDelegate: MarkupDelegate?
    private var accentColor: UIColor?
    @Environment(\.colorScheme) private var colorScheme
    @State private var showFormatPopover: Bool = false
    
    var mappedAccentColor: Color {
        accentColor.flatMap { Color(uiColor: $0) } ?? Color(red: 0.4, green: 0.8, blue: 0.2)
    }
    
    // Theme-aware colors
    private var toolbarBackgroundColor: Color {
        colorScheme == .dark 
            ? Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.85)
            : Color(UIColor.systemGray6).opacity(0.95)
    }
    
    private var toolbarShadowColor: Color {
        colorScheme == .dark 
            ? Color.black.opacity(0.3)
            : Color.black.opacity(0.12)
    }
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            HStack {
                ScrollView(.horizontal) {
                    HStack {
                        
                        ToolbarImageButton(
                            systemName: "mic.fill",
                            action: { markupDelegate?.markupDidTapVoiceInToolbar() },
                            notActiveBackground: mappedAccentColor,
                            forceWhiteForeground: true
                        )
                        
                        if contents.leftToolbar {
                            MarkupEditor.leftToolbar!
                        }
                        if contents.correction {
                            CorrectionToolbar()
                        }
                        if contents.format {
                            ToolbarImageButton(
                                systemName: "textformat",
                                action: { showFormatPopover = true }
                            )
                            .forcePopover(isPresented: $showFormatPopover) {
                                FormatPopoverContent(showing: $showFormatPopover)
                                    .environmentObject(toolbarStyle)
                            }
                        }
                        if contents.style {
                            StyleToolbar()
                        }
                        if contents.insert {
                            InsertToolbar()
                        }
                        if contents.rightToolbar {
                            MarkupEditor.rightToolbar!
                        }
                        Spacer()                // Push everything to the left
                    }
                    .environmentObject(toolbarStyle)
                    .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                    .disabled(observedWebView.selectedWebView == nil || !selectionState.isValid || searchActive.value)
                }
                .onTapGesture {}    // To make the buttons responsive inside of the ScrollView
                if withKeyboardButton {
                    Spacer()
                    Divider()
                    ToolbarImageButton(
                        systemName: "keyboard.chevron.compact.down",
                        action: {
                            _ = MarkupEditor.selectedWebView?.resignFirstResponder()
                        }
                    )
                    Spacer()
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(toolbarBackgroundColor)
                .shadow(color: toolbarShadowColor, radius: 4, x: 0, y: 2)
        )
        // Because the icons in toolbars are sized based on font, we need to limit their dynamicTypeSize
        // or they become illegible at very large sizes.
        .dynamicTypeSize(.small ... .xLarge)
        .frame(height: MarkupEditor.toolbarStyle.height())
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 4)
        .zIndex(999)
    }
    
    public init(_ style: ToolbarStyle.Style? = nil, contents: ToolbarContents? = nil, markupDelegate: MarkupDelegate? = nil, withKeyboardButton: Bool = true, accentColor: UIColor? = nil) {
        let toolbarStyle = style == nil ? MarkupEditor.toolbarStyle : ToolbarStyle(style!)
        self.toolbarStyle = toolbarStyle
        let toolbarContents = contents == nil ? MarkupEditor.toolbarContents : contents!
        self.contents = toolbarContents
        self.withKeyboardButton = withKeyboardButton
        self.markupDelegate = markupDelegate
        self.accentColor = accentColor
        // Store accent color in static variable for use in other components
        if let accentColor = accentColor {
            MarkupToolbar.sharedAccentColor = accentColor
        }
    }
    
    public func makeManaged() -> MarkupToolbar {
        MarkupToolbar.managed = self
        return self
    }

}

// MARK: - Format Popover Content

/// A popover view containing all format options (bold, italic, underline, styles, etc.)
struct FormatPopoverContent: View {
    @EnvironmentObject private var toolbarStyle: ToolbarStyle
    @ObservedObject private var observedWebView: ObservedWebView = MarkupEditor.observedWebView
    @ObservedObject private var selectionState: SelectionState = MarkupEditor.selectionState
    private let contents: FormatContents = MarkupEditor.toolbarContents.formatContents
    private let styleContents: StyleContents = MarkupEditor.toolbarContents.styleContents
    @Binding var showing: Bool
    @State private var showStylePicker: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    
    private var accentColor: Color {
        if let uiColor = MarkupToolbar.sharedAccentColor {
            return Color(uiColor: uiColor)
        }
        return Color(red: 0.4, green: 0.8, blue: 0.2)
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark 
            ? Color(red: 0.15, green: 0.15, blue: 0.15)
            : Color(UIColor.systemBackground)
    }
    
    private var styleButtonBackgroundColor: Color {
        colorScheme == .dark 
            ? Color(red: 0.1, green: 0.1, blue: 0.1)
            : Color(UIColor.systemGray5)
    }
    
    private var styleButtonTextColor: Color {
        colorScheme == .dark ? Color.white : Color(UIColor.label)
    }
    
    private var sectionTitleColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.6) : Color(UIColor.secondaryLabel)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Style selector (H1, H2, etc.)
            if contents.paragraph {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Paragraph Style")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(sectionTitleColor)
                    
                    Button(action: {
                        showStylePicker = true
                    }) {
                        HStack {
                            Text(selectionState.style.name)
                                .foregroundColor(styleButtonTextColor)
                                .fontWeight(.bold)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(sectionTitleColor)
                                .font(.system(size: 12))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderless)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(styleButtonBackgroundColor)
                    )
                    .disabled(!selectionState.canStyle)
                    .forcePopover(isPresented: $showStylePicker) {
                        StylePickerSheet(
                            selectedStyle: selectionState.style,
                            accentColor: accentColor,
                            showing: $showStylePicker,
                            onStyleSelected: { styleContext in
                                observedWebView.selectedWebView?.replaceStyle(selectionState.style, with: styleContext)
                            }
                        )
                    }
                }
            }
            
            // Text formatting buttons
            VStack(alignment: .leading, spacing: 8) {
                Text("Text Format")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(sectionTitleColor)
                
                HStack(spacing: 8) {
                    ToolbarImageButton(
                        systemName: "bold",
                        action: { observedWebView.selectedWebView?.bold() },
                        active: $selectionState.bold
                    )
                    ToolbarImageButton(
                        systemName: "italic",
                        action: { observedWebView.selectedWebView?.italic() },
                        active: $selectionState.italic
                    )
                    ToolbarImageButton(
                        systemName: "underline",
                        action: { observedWebView.selectedWebView?.underline() },
                        active: $selectionState.underline
                    )
                    if contents.strike {
                        ToolbarImageButton(
                            systemName: "strikethrough",
                            action: { observedWebView.selectedWebView?.strike() },
                            active: $selectionState.strike
                        )
                    }
                }
            }
            
            // Code, subscript/superscript, and indent
            if contents.code || contents.subSuper || styleContents.dent {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Additional")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(sectionTitleColor)
                    
                    HStack(spacing: 8) {
                        if contents.code {
                            ToolbarImageButton(
                                systemName: "curlybraces",
                                action: { observedWebView.selectedWebView?.code() },
                                active: $selectionState.code
                            )
                        }
                        if contents.subSuper {
                            ToolbarImageButton(
                                systemName: "textformat.subscript",
                                action: { observedWebView.selectedWebView?.subscriptText() },
                                active: $selectionState.sub
                            )
                            ToolbarImageButton(
                                systemName: "textformat.superscript",
                                action: { observedWebView.selectedWebView?.superscript() },
                                active: $selectionState.sup
                            )
                        }
                        if styleContents.dent {
                            ToolbarImageButton(
                                systemName: "increase.quotelevel",
                                action: { observedWebView.selectedWebView?.indent() },
                                active: Binding<Bool>(get: { selectionState.quote }, set: { _ = $0 })
                            )
                            ToolbarImageButton(
                                systemName: "decrease.quotelevel",
                                action: { observedWebView.selectedWebView?.outdent() },
                                active: Binding<Bool>(get: { selectionState.quote }, set: { _ = $0 })
                            )
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(backgroundColor)
        .frame(width: 220)
    }
}

//MARK: Previews

struct MarkupToolbar_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack(alignment: .leading) {
            MarkupToolbar(.compact)
            MarkupToolbar(.labeled)
            Spacer()
        }
        .onAppear {
            MarkupEditor.selectedWebView = MarkupWKWebView()
            MarkupEditor.selectionState.valid = true
        }
    }
}


