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
    private let notActiveBackground: Color
    
    public var body: some View {
        Button(action: action, label: {
            label()
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(active ? Color(red: 0.2, green: 0.8, blue: 0.2) : Color.white)
                .frame(width: MarkupEditor.toolbarStyle.buttonHeight(), height: MarkupEditor.toolbarStyle.buttonHeight())
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(active ? Color(red: 0.15, green: 0.15, blue: 0.15) : notActiveBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(active ? Color(red: 0.2, green: 0.8, blue: 0.2) : Color.clear, lineWidth: 1)
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
        activeColor: Color = .accentColor,
        notActiveBackground: Color = Color(red: 0.1, green: 0.1, blue: 0.1),
        onHover: ((Bool)->Void)? = nil,
        @ViewBuilder content: ()->Content) {
            self.notActiveBackground = notActiveBackground
            self.systemName = nil
            self.image = content()
            self.action = action
            _active = active
            self.activeColor = activeColor
            self.onHover = onHover
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
        activeColor: Color = .accentColor,
        notActiveBackground: Color = Color(red: 0.1, green: 0.1, blue: 0.1),
        onHover: ((Bool)->Void)? = nil,
        @ViewBuilder content: ()->Content = { EmptyView() }
    ) {
        self.systemName = systemName
        self.image = content()
        self.action = action
        _active = active
        self.activeColor = activeColor
        self.notActiveBackground = notActiveBackground
        self.onHover = onHover
    }
    
}

public struct ToolbarTextButton: View {
    let title: String
    let action: ()->Void
    let width: CGFloat?
    @Binding var active: Bool
    let activeColor: Color
    
    public var body: some View {
        Button(action: action, label: {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(active ? Color(red: 0.2, green: 0.8, blue: 0.2) : Color.white)
                .frame(width: width ?? 60, height: MarkupEditor.toolbarStyle.buttonHeight())
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(active ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color(red: 0.1, green: 0.1, blue: 0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(active ? Color(red: 0.2, green: 0.8, blue: 0.2) : Color.clear, lineWidth: 1)
                        )
                )
        })
        .contentShape(RoundedRectangle(cornerRadius: 8))
        .buttonStyle(PlainButtonStyle())
    }
    
    public init(title: String, action: @escaping ()->Void, width: CGFloat? = nil, active: Binding<Bool> = .constant(false), activeColor: Color = .accentColor) {
        self.title = title
        self.action = action
        self.width = width
        _active = active
        self.activeColor = activeColor
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
