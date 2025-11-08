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
                            FormatToolbar()
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
    
    public init(_ style: ToolbarStyle.Style? = nil, contents: ToolbarContents? = nil, markupDelegate: MarkupDelegate? = nil, withKeyboardButton: Bool = false, accentColor: UIColor? = nil) {
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


