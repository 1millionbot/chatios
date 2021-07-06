//
//  MoreCards.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 08/02/2021.
//

import Foundation
import SwiftUI
import Introspect

struct MoreCardsHeight: PreferenceKey {
    static var defaultValue: [UUID: CGFloat] = [:]
    static func reduce(value: inout [UUID: CGFloat], nextValue: () -> [UUID: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

struct MoreCards: View {
    @State var currentPage: Int = 0
    @State var heights: [UUID: CGFloat] = [:]
    @Binding var cards: [BotCard]
    
    var color: String
    let sendAction: (BotOption) -> Void
    let showPhoto: (UIImage) -> Void
    
    init(
        color: String,
        cards: Binding<[BotCard]>,
        sendAction: @escaping (BotOption) -> Void,
        showPhoto: @escaping (UIImage) -> Void
    ) {
        self.color = color
        self._cards = cards
        self.sendAction = sendAction
        self.showPhoto = showPhoto
    }
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(cards) { card in
                            ZStack {
                                ScrollView(.vertical, showsIndicators: false) {
                                    UIViewContainer(
                                        {
                                            let cardView = CardView()
                                            cardView.update(
                                                with: card,
                                                reformButtons: true,
                                                selectedOption: sendAction,
                                                showPhoto: showPhoto
                                            )
                                            return cardView
                                        },
                                        layout: .fixedWidth(
                                            width: proxy.size.width * 0.9
                                        )
                                    )
                                    .fixedSize()
                                    .cornerRadius(kCR)
                                    .clipped()
                                    .overlay(GeometryReader {
                                        Color.clear.preference(
                                            key: MoreCardsHeight.self,
                                            value: [card.id: $0.size.height]
                                        )
                                    })
                                }
                                .frame(maxHeight: heights[card.id])
                                .onPreferenceChange(MoreCardsHeight.self) { new in
                                    heights = new
                                }
                            }
                            .padding()
                        }
                        .frame(
                            width: proxy.size.width,
                            height: proxy.size.height
                        )
                    }
                }
                .didScroll { point in
                    currentPage = Int(point.x/proxy.size.width).clamped(to: 0...Int.max)
                }
                .introspectScrollView {
                    $0.isPagingEnabled = true
                }
            }.background(Color(UIColor.mainBubbleBackground))
            
            PageControl(
                numberOfPages: cards.count,
                currentPage: $currentPage,
                color: color
            )
            .frame(maxWidth: .infinity, maxHeight: 40)
            .background(
                Color(UIColor.mainBubbleBackground)
                    .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            )
        }
    }
}

fileprivate struct PageControl: UIViewRepresentable {
    var numberOfPages: Int
    @Binding var currentPage: Int
    var color: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = numberOfPages
        control.pageIndicatorTintColor = UIColor(hexString: color).withAlphaComponent(0.5)
        control.currentPageIndicatorTintColor = .init(hexString: color)
        control.addTarget(
            context.coordinator,
            action: #selector(Coordinator.updateCurrentPage(sender:)),
            for: .valueChanged)
        
        return control
    }
    
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
    }
    
    class Coordinator: NSObject {
        var control: PageControl
        
        init(_ control: PageControl) {
            self.control = control
        }
        
        @objc func updateCurrentPage(sender: UIPageControl) {
            control.currentPage = sender.currentPage
        }
    }
}
