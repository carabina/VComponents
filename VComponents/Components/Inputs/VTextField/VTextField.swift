//
//  VTextField.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/19/21.
//

import SwiftUI

// MARK:- V Text Field
/// Input component that displays an editable text interface
///
/// Model, type, highlight, palceholder, header, footer, and event callbacks can be passed as parameters
///
/// By default, component type is standard.
/// If secure type is used, visiblity button would replace clear button. When text field is secure, clear and cancel buttons are not visible.
/// If search type is used, a magnification glass icon would appear on the left.
///
/// It is possible to override actions of return, clear, and cancel buttons by passing them as a parameter
///
/// # Usage Example #
///
/// ```
/// @State var state: VTextFieldState = .focused
/// @State var text: String = "Lorem ipsum"
///
/// var body: some View {
///     VTextField(
///         state: $state,
///         placeholder: "Lorem ipsum",
///         headerTitle: "Lorem ipsum dolor sit amet",
///         footerTitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
///         text: $text
///     )
///         .padding()
/// }
/// ```
///
/// Full use of overriden actions and event callbacks:
/// ```
/// let model: VTextFieldModel = {
///     var model: VTextFieldModel = .init()
///
///     model.misc.returnButton = .default
///     model.misc.clearButton = true
///     model.misc.cancelButton = "Cancel"
///
///     return model
/// }()
///
/// @State private var state: VTextFieldState = .enabled
/// @State private var text: String = "Lorem ipsum"
///
/// var body: some View {
///     VTextField(
///         model: model,
///         state: $state,
///         placeholder: "Lorem ipsum",
///         headerTitle: "Lorem ipsum dolor sit amet",
///         footerTitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
///         text: $text,
///         onBegin: { print("Editing Began") },
///         onChange: {  print("Editing Changed") },
///         onEnd: { print("Editing Ended") },
///         onReturn: .returnAndCustom({ print("Returned and ...") }),
///         onClear: .clearAndCustom({ print("Cleared and ...") }),
///         onCancel: .clearAndCustom({ print("Cancelled and ...") })
///     )
///         .padding()
/// }
/// ```
///
/// Secure text field:
/// ```
/// @State var state: VTextFieldState = .enabled
/// @State var text: String = "Lorem ipsum"
///
/// var body: some View {
///     VTextField(
///         type: .secure,
///         state: $state,
///         placeholder: "Lorem ipsum",
///         headerTitle: "Lorem ipsum dolor sit amet",
///         footerTitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
///         text: $text
///     )
///         .padding()
/// }
/// ```
///
/// Search text field:
/// ```
/// @State var state: VTextFieldState = .enabled
/// @State var text: String = "Lorem ipsum"
///
/// var body: some View {
///     VTextField(
///         type: .search,
///         state: $state,
///         placeholder: "Lorem ipsum",
///         headerTitle: "Lorem ipsum dolor sit amet",
///         footerTitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
///         text: $text
///     )
///         .padding()
/// }
/// ```
///
public struct VTextField: View {
    private let model: VTextFieldModel
    private let textFieldType: VTextFieldType
    
    @Binding private var state: VTextFieldState
    private let highlight: VTextFieldHighlight
    
    private let placeholder: String?
    private let headerTitle: String?
    private let footerTitle: String?
    @Binding private var text: String
                
    private let beginHandler: (() -> Void)?
    private let changeHandler: (() -> Void)?
    private let endHandler: (() -> Void)?
    
    private let returnButtonAction: VTextFieldReturnButtonAction
    private let clearButtonAction: VTextFieldClearButtonAction
    private let cancelButtonAction: VTextFieldCancelButtonAction
    
    @State private var nonEmptyText: Bool = false
    @State private var secureFieldIsVisible: Bool = false

    // MARK: Initialiers
    public init(
        model: VTextFieldModel = .init(),
        type textFieldType: VTextFieldType = .default,
        state: Binding<VTextFieldState>,
        highlight: VTextFieldHighlight = .default,
        placeholder: String? = nil,
        headerTitle: String? = nil,
        footerTitle: String? = nil,
        text: Binding<String>,
        onBegin beginHandler: (() -> Void)? = nil,
        onChange changeHandler: (() -> Void)? = nil,
        onEnd endHandler: (() -> Void)? = nil,
        onReturn returnButtonAction: VTextFieldReturnButtonAction = .default,
        onClear clearButtonAction: VTextFieldClearButtonAction = .default,
        onCancel cancelButtonAction: VTextFieldCancelButtonAction = .default
    ) {
        self.model = model
        self.textFieldType = textFieldType
        self._state = state
        self.highlight = highlight
        self.placeholder = placeholder
        self.headerTitle = headerTitle
        self.footerTitle = footerTitle
        self._text = text
        self.beginHandler = beginHandler
        self.changeHandler = changeHandler
        self.endHandler = endHandler
        self.returnButtonAction = returnButtonAction
        self.clearButtonAction = clearButtonAction
        self.cancelButtonAction = cancelButtonAction
    }
}

// MARK:- Body
extension VTextField {
    public var body: some View {
        performStateSets()
        
        return VStack(alignment: .leading, spacing: model.layout.headerFooterSpacing, content: {
            headerView
            textFieldView
            footerView
        })
    }
    
    private var textFieldView: some View {
        HStack(spacing: model.layout.contentSpacing, content: {
            HStack(spacing: model.layout.contentSpacing, content: {
                searchIcon
                textFieldContentView
                clearButton
                visibilityButton
            })
                .padding(.horizontal, model.layout.contentMarginHorizontal)
                .frame(height: model.layout.height)
                .background(background)
            
            cancelButton
        })
            .frame(height: model.layout.height)
    }
    
    @ViewBuilder private var headerView: some View {
        if let headerTitle = headerTitle, !headerTitle.isEmpty {
            VText(
                type: .oneLine,
                font: model.fonts.header,
                color: model.colors.header.for(state, highlight: highlight),
                title: headerTitle
            )
                .padding(.horizontal, model.layout.headerFooterMarginHor)
                .opacity(model.colors.content.for(state))
        }
    }
    
    @ViewBuilder private var footerView: some View {
        if let footerTitle = footerTitle, !footerTitle.isEmpty {
            VText(
                type: .multiLine(limit: nil, alignment: .leading),
                font: model.fonts.footer,
                color: model.colors.footer.for(state, highlight: highlight),
                title: footerTitle
            )
                .padding(.horizontal, model.layout.headerFooterMarginHor)
                .opacity(model.colors.content.for(state))
        }
    }
    
    @ViewBuilder private var searchIcon: some View {
        if textFieldType.isSearch {
            ImageBook.search
                .resizable()
                .frame(dimension: model.layout.searchIconDimension)
                .foregroundColor(model.colors.searchIcon.for(state, highlight: highlight))
                .opacity(model.colors.content.for(state))
        }
    }
    
    private var textFieldContentView: some View {
        UIKitTextFieldRepresentable(
            model: model.baseTextFieldSubModel(state: state, isSecureTextEntry: textFieldType.isSecure && !secureFieldIsVisible),
            state: $state,
            placeholder: placeholder,
            text: $text,
            onBegin: beginHandler,
            onChange: changeHandler,
            onEnd: endHandler,
            onReturn: returnButtonAction
        )
            .onChange(of: text, perform: textChanged)
    }
    
    @ViewBuilder private var clearButton: some View {
        if !textFieldType.isSecure && nonEmptyText && model.misc.clearButton {
            VCloseButton(
                model: model.clearSubButtonModel(state: state, highlight: highlight),
                state: state.clearButtonState,
                action: runClearAction
            )
        }
    }
    
    @ViewBuilder private var visibilityButton: some View {
        if textFieldType.isSecure {
            VSquareButton(
                model: model.visibilityButtonSubModel(state: state, highlight: highlight),
                state: state.visiblityButtonState,
                action: { secureFieldIsVisible.toggle() },
                content: {
                    visiblityIcon
                        .resizable()
                        .frame(dimension: model.layout.visibilityButtonIconDimension)
                        .foregroundColor(model.colors.visibilityButtonIcon.for(state, highlight: highlight))
                }
            )
        }
    }
    
    @ViewBuilder private var cancelButton: some View {
        if !textFieldType.isSecure, nonEmptyText, state.isFocused, let cancelButton = model.misc.cancelButton, !cancelButton.isEmpty {
            VPlainButton(
                model: model.cancelButtonSubModel,
                state: state.cancelButtonState,
                action: runCancelAction,
                title: cancelButton
            )
        }
    }
    
    private var background: some View {
        ZStack(content: {
            RoundedRectangle(cornerRadius: model.layout.cornerRadius)
                .foregroundColor(model.colors.background.for(state, highlight: highlight))
            
            RoundedRectangle(cornerRadius: model.layout.cornerRadius)
                .strokeBorder(model.colors.border.for(state, highlight: highlight), lineWidth: model.layout.borderWidth)
        })
    }
}

// MARK:- State Sets
private extension VTextField {
    func performStateSets() {
        DispatchQueue.main.async(execute: {
            self.nonEmptyText = !text.isEmpty
            
            if self.secureFieldIsVisible && !textFieldType.isSecure { self.secureFieldIsVisible = false }
        })
    }
}

// MARK:- Visiblity Icon
private extension VTextField {
    var visiblityIcon: Image {
        switch secureFieldIsVisible {
        case false: return ImageBook.visibilityOff
        case true: return ImageBook.visibilityOn
        }
    }
}

// MARK:- Actions
private extension VTextField {
    func textChanged(_ text: String) {
        withAnimation(model.animations.buttonsAppearDisAppear, { nonEmptyText = !text.isEmpty })
    }
    
    func runClearAction() {
        switch clearButtonAction {
        case .clear: zeroText()
        case .custom(let action): action()
        case .clearAndCustom(let action): zeroText(); action()
        }
    }
    
    func runCancelAction() {
        switch cancelButtonAction {
        case .clear: zeroText()
        case .custom(let action): action()
        case .clearAndCustom(let action): zeroText(); action()
        }
    }
    
    func zeroText() {
        text = ""
        withAnimation(model.animations.buttonsAppearDisAppear, { nonEmptyText = false })
    }
}

// MARK:- Preview
struct VTextField_Previews: PreviewProvider {
    @State private static var state: VTextFieldState = .enabled
    @State private static var text: String = "Lorem ipsum"

    static var previews: some View {
        VStack(spacing: 50, content: {
            ForEach(VTextFieldType.allCases, id: \.self, content: { type in
                VTextField(
                    type: type,
                    state: $state,
                    placeholder: "Lorem ipsum",
                    headerTitle: "Lorem ipsum dolor sit amet",
                    footerTitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
                    text: $text
                )
            })
        })
            .padding()
    }
}
