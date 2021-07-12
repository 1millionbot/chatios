//
//  AttributedText.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 22/05/2021.
//

import Foundation
import SwiftUI
import Atributika

final class MaxWidthAttributedLabel: AttributedLabel
{
    var maxWidth: CGFloat! {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    public override var intrinsicContentSize: CGSize
    {
        sizeThatFits(
            CGSize(width: maxWidth, height: .infinity)
        )
    }
}

struct AttributedLabelView: UIViewRepresentable {
    private let all = Style.font(.roboto(.body))
    private let link = Style("a")
        .foregroundColor(.cardButton, .highlighted)
        .foregroundColor(.cardButton, .normal)
    
    private let b = Style("b").font(.robotoMedium(.body))
    private let u = Style("u").underlineStyle(.single)
    private let i = Style("i").font(.robotoItalic(.body))
    private let strong = Style("strong").font(.robotoMedium(.body))
    private let transformers = [TagTransformer(tagName: "br", tagType: .start, replaceValue: "\n")]
    
    var maxWidth: CGFloat
    var text: String
    
    init(text: String, maxWidth: CGFloat) {
        self.text = text
        self.maxWidth = maxWidth
    }
    
    func makeUIView(context: Self.Context) -> MaxWidthAttributedLabel {
        let label = MaxWidthAttributedLabel()
        label.maxWidth = maxWidth
        label.numberOfLines = 0
        label.textColor = .black
        label.font = .roboto(.body)

        styleLb(text, label)
        
        return label
    }

    func updateUIView(_ uiView: MaxWidthAttributedLabel, context: Self.Context) {
        styleLb(text, uiView)
        uiView.maxWidth = maxWidth
    }
    
    private func styleLb(_ htmlText: String, _ label: MaxWidthAttributedLabel) {
        label.attributedText = htmlText
            .style(tags: [link, b, u, i, strong], transformers: transformers)
            .styleLinks(link)
            .styleAll(all)
    }
}

struct TextViewWidth: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct HTMLTextView: View {
    var text: String
    var padding: CGFloat
    
    @State var maxWidth: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { proxy in
                Color.clear.preference(key: TextViewWidth.self, value: min(UIScreen.main.bounds.width - padding*2, proxy.size.width))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 0)
            
            AttributedLabelView(
                text: text,
                maxWidth: maxWidth
            )
        }
        .onPreferenceChange(TextViewWidth.self) { width in
            maxWidth = width
        }
    }
}
