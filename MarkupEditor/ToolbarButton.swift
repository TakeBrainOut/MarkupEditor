//
//  ToolbarButton.swift
//  MarkupEditor
//
//  Created by Steven Harris on 4/5/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import SwiftUI

/// A square button typically used with a system image in the toolbar.
///
/// These RoundedRect buttons show text and outline in activeColor (.accentColor by default), with the
/// backgroundColor of UIColor.systemBackground. When active, the text and background switch.
public struct ToolbarImageButton<Content: View>: View {
    private let image: Content
    private let systemName: String?
    private let action: ()->Void
    @Binding private var active: Bool
    private let activeColor: Color
    private let onHover: ((Bool)->Void)? 
    private let notActiveBackground: Color?
    private let forceWhiteForeground: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    // Theme-aware colors
    private var buttonForegroundColor: Color {
        if active {
            return activeColor
        }
        // If forceWhiteForeground is true, always use white color
        if forceWhiteForeground {
            return Color.white
        }
        return colorScheme == .dark ? Color.white : Color(UIColor.label)
    }
    
    private var buttonBackgroundColor: Color {
        if active {
            return colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color(UIColor.systemGray6)
        }
        // If custom background is provided, use it; otherwise use theme-aware default
        if let customBg = notActiveBackground {
            return customBg
        }
        return colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color(UIColor.systemGray5)
    }
    
    private var buttonBorderColor: Color {
        return active ? activeColor : Color.clear
    }
    
    public var body: some View {
        Button(action: action, label: {
            label()
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(buttonForegroundColor)
                .frame(width: MarkupEditor.toolbarStyle.buttonHeight(), height: MarkupEditor.toolbarStyle.buttonHeight())
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(buttonBackgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(buttonBorderColor, lineWidth: 1)
                        )
                )
        })
        .onHover { over in onHover?(over) }
        .contentShape(RoundedRectangle(cornerRadius: 8))
        .buttonStyle(PlainButtonStyle())
    }

    /// Initialize a button using content. See the extension where Content == EmptyView for the systemName style initialization.
    public init(
        action: @escaping ()->Void,
        active: Binding<Bool> = .constant(false),
        activeColor: Color? = nil,
        notActiveBackground: Color? = nil,
        forceWhiteForeground: Bool = false,
        onHover: ((Bool)->Void)? = nil,
        @ViewBuilder content: ()->Content) {
            self.systemName = nil
            self.image = content()
            self.action = action
            _active = active
            // Use shared accent color if available, otherwise use provided or default green
            if let sharedAccent = MarkupToolbar.sharedAccentColor {
                self.activeColor = Color(uiColor: sharedAccent)
            } else {
                self.activeColor = activeColor ?? Color(red: 0.2, green: 0.8, blue: 0.2)
            }
            self.onHover = onHover
            self.notActiveBackground = notActiveBackground
            self.forceWhiteForeground = forceWhiteForeground
    }
    
    private func label() -> AnyView {
        // Return either the image derived from content or the properly-sized systemName image based on style
        if systemName == nil {
            return AnyView(image)
        } else {
            return AnyView(
                Image(systemName: systemName!)
                .imageScale(.large)
                .fontWeight(.bold)
            )
        }
    }

}

extension ToolbarImageButton where Content == EmptyView {
    
    /// Initialize a button using a systemImage which will override content, even if passed-in. Intended for use without a content block.
    public init(
        systemName: String,
        action: @escaping ()->Void,
        active: Binding<Bool> = .constant(false),
        activeColor: Color? = nil,
        notActiveBackground: Color? = nil,
        forceWhiteForeground: Bool = false,
        onHover: ((Bool)->Void)? = nil,
        @ViewBuilder content: ()->Content = { EmptyView() }
    ) {
        self.systemName = systemName
        self.image = content()
        self.action = action
        _active = active
        // Use shared accent color if available, otherwise use provided or default green
        if let sharedAccent = MarkupToolbar.sharedAccentColor {
            self.activeColor = Color(uiColor: sharedAccent)
        } else {
            self.activeColor = activeColor ?? Color(red: 0.2, green: 0.8, blue: 0.2)
        }
        self.notActiveBackground = notActiveBackground
        self.forceWhiteForeground = forceWhiteForeground
        self.onHover = onHover
    }
    
}

public struct ToolbarTextButton: View {
    let title: String
    let action: ()->Void
    let width: CGFloat?
    @Binding var active: Bool
    let activeColor: Color
    @Environment(\.colorScheme) private var colorScheme
    
    // Theme-aware colors
    private var textForegroundColor: Color {
        if active {
            return activeColor
        }
        return colorScheme == .dark ? Color.white : Color(UIColor.label)
    }
    
    private var textBackgroundColor: Color {
        if active {
            return colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color(UIColor.systemGray6)
        }
        return colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color(UIColor.systemGray5)
    }
    
    private var textBorderColor: Color {
        return active ? activeColor : Color.clear
    }
    
    public var body: some View {
        Button(action: action, label: {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(textForegroundColor)
                .frame(width: width ?? 60, height: MarkupEditor.toolbarStyle.buttonHeight())
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(textBackgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(textBorderColor, lineWidth: 1)
                        )
                )
        })
        .contentShape(RoundedRectangle(cornerRadius: 8))
        .buttonStyle(PlainButtonStyle())
    }
    
    public init(title: String, action: @escaping ()->Void, width: CGFloat? = nil, active: Binding<Bool> = .constant(false), activeColor: Color? = nil) {
        self.title = title
        self.action = action
        self.width = width
        _active = active
        // Use shared accent color if available, otherwise use provided or default green
        if let sharedAccent = MarkupToolbar.sharedAccentColor {
            self.activeColor = Color(uiColor: sharedAccent)
        } else {
            self.activeColor = activeColor ?? Color(red: 0.2, green: 0.8, blue: 0.2)
        }
    }
    
}

public struct ToolbarButtonStyle: ButtonStyle {
    @Binding var active: Bool
    let activeColor: Color
    
    public init(active: Binding<Bool>, activeColor: Color) {
        _active = active
        self.activeColor = activeColor
    }
    
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
