//
//  TableView.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 30/01/2021.
//

import Foundation
import UIKit
import SwiftUI
import Combine

struct TableView: UIViewRepresentable {
    @Binding var messages: [Message]
    @Binding var showScrollToBottom: Bool
    
    let shouldScrollObservable: AnyPublisher<Void, Never>
    let color: String
    
    let responseSelected: (BotOption) -> Void
    let videoSelected: (URL) -> Void
    let showMoreCards: ([BotCard]) -> Void
    let retryMessage: (UUID) -> Void
    let showPhoto: (UIImage) -> Void
    let writingMessage: String
        
    init(
        messages: Binding<[Message]>,
        showScrollToBottom: Binding<Bool>,
        shouldScrollObservable: AnyPublisher<Void, Never>,
        color: String,
        writingMessage: String,
        responseSelected: @escaping (BotOption) -> Void,
        showMoreCards: @escaping ([BotCard]) -> Void,
        videoSelected: @escaping (URL) -> Void,
        retryMessage: @escaping (UUID) -> Void,
        showPhoto: @escaping (UIImage) -> Void
    ) {
        self._showScrollToBottom = showScrollToBottom
        self.responseSelected = responseSelected
        self.showMoreCards = showMoreCards
        self.color = color
        self._messages = messages
        self.videoSelected = videoSelected
        self.shouldScrollObservable = shouldScrollObservable
        self.retryMessage = retryMessage
        self.showPhoto = showPhoto
        self.writingMessage = writingMessage
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView()
        let coordinator = context.coordinator
        
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 250
        tableView.backgroundColor = .clear
        
        tableView.register(TextCell.self)
        tableView.register(ImageCell.self)
        tableView.register(CardCell.self)
        tableView.register(VideoCell.self)
        tableView.register(WritingCell.self)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(sender:)))
        tapGesture.cancelsTouchesInView = true
        
        tableView.addGestureRecognizer(tapGesture)
        
        coordinator.scrollActionCancellable = shouldScrollObservable.sink {
            tableView.setContentOffset(.zero, animated: true)
        }
        
        coordinator.dataSource = .init(
            tableView: tableView,
            cellProvider: { [unowned coordinator] a, b, c in
                coordinator.cellProvider(a, b, c)
            }
        )
        coordinator.dataSource?.defaultRowAnimation = .none
        
        tableView.dataSource = coordinator.dataSource
        tableView.delegate = coordinator
        
        return tableView
    }
    
    func updateUIView(_ uiView: UITableView, context: Context) {
        context.coordinator.writingMessage = writingMessage
        context.coordinator.scrollActionCancellable = shouldScrollObservable.sink {
            uiView.setContentOffset(.zero, animated: true)
        }
        
        let newState = messages.hashValue
        
        if newState != context.coordinator.currentStateHash {
            context.coordinator.currentStateHash = newState
            context.coordinator.update(messages)
        }
    }

    final class Coordinator: NSObject, UITableViewDelegate {
        fileprivate var currentStateHash = -1
        fileprivate var dataSource: UITableViewDiffableDataSource<Section, Message>?
        fileprivate var cancellables = Set<AnyCancellable>()
        fileprivate var scrollActionCancellable: AnyCancellable?
        fileprivate var writingMessage: String {
            didSet {
                writingCell?.caption.text = writingMessage
            }
        }
        fileprivate var writingCell: WritingCell?

        let tableview: TableView
        
        @objc func handleTap(sender: UITapGestureRecognizer) {
            sender.view?.superview?.superview?.endEditing(true)
        }

        init(_ tableview: TableView) {
            self.tableview = tableview
            self.writingMessage = tableview.writingMessage
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            tableview.showScrollToBottom = scrollView.contentOffset.y > 200
        }
        
        func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
            return false
        }
        
        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            
            (cell as? BubbleCell).map {
                $0.bubble.layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
                $0.bubble.layer.shadowOpacity = 1
                $0.bubble.layer.shadowOffset = .init(width: 0, height: 1)
                $0.bubble.layer.shadowRadius = 1
            }
        }
                
        func cellProvider(
            _ tableView: UITableView,
            _ indexPath: IndexPath,
            _ message: Message
        ) -> UITableViewCell? {
            switch message {
            case let .user(userMsg, _):
                return tableView.textCell(userMsg.message.text, fromUser: message.fromUser, over: message.firstOfMany, color: tableview.color, status: userMsg.status, id: message.id, retry: tableview.retryMessage)
                
            case let .bot(botMsg, _):
                switch botMsg {
                case .writing:
                    let cell = writingCell ?? tableView.dequeueing(WritingCell.self)
                    cell?.touch(writingMessage: writingMessage)
                    if writingCell == nil { writingCell = cell }
                    return cell
                    
                case let .text(_, text: text):
                    return tableView.textCell(text, fromUser: message.fromUser, over: message.firstOfMany, color: tableview.color, status: .success, id: message.id, retry: tableview.retryMessage)

                case let .image(_, url: url, _):
                    return tableView.dequeueing(ImageCell.self) {
                        $0.update(
                            url: url,
                            over: message.firstOfMany,
                            completion: { size in
                                self.changeCell(
                                    at: indexPath.row,
                                    size: size
                                )
                            },
                            showPhoto: tableview.showPhoto
                        )
                    }
                    
                case let .cards(_, cards: cards):
                    return tableView.dequeueing(CardCell.self) {
                        $0.update(
                            with: cards,
                            color: tableview.color,
                            over: message.firstOfMany,
                            tableview.responseSelected,
                            tableview.showMoreCards,
                            tableview.showPhoto
                        )
                    }
                    
                case let .video(_, thumbnail: thumbnail, videoUrl: videoUrl):
                    return tableView.dequeueing(VideoCell.self) {
                        $0.update(
                            with: thumbnail,
                            color: tableview.color,
                            over: message.firstOfMany
                        ) { [unowned self] in
                            self.tableview.videoSelected(videoUrl)
                        }
                    }
                }
            }
        }
        
        func update(_ messages: [Message], animate: Bool = true) {
            var snapshot = NSDiffableDataSourceSnapshot<Section, Message>()
            snapshot.appendSections([Section.main])
            snapshot.appendItems(messages, toSection: .main)
            self.dataSource?.apply(snapshot, animatingDifferences: animate)
        }
        
        func changeCell(at index: Int, size: CGSize) {
            guard !tableview.messages.isEmpty,
                  let message = .some(tableview.messages[index]),
                  message.size != size else {
                return
            }

            tableview.messages[index] = message.withSize(size)
        }
    }
}

fileprivate enum Section {
    case main
}
