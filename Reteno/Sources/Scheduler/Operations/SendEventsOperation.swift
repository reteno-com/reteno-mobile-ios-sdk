//
//  SendEventsOperation.swift
//
//  Created by Serhii Prykhodko on 20.10.2022.
//

import Foundation

final class SendEventsOperation: DateOperation, @unchecked Sendable {

    static let maxBatchSize = 100

    private let requestService: MobileRequestService
    private let storage: KeyValueStorage
    private let events: [Event]
    /// Identity the events were logged under; checked before every batch, so a multi-account switch
    /// in the middle of the operation does not send the rest with the next account's device id.
    private let identity: RequestIdentity?

    init(requestService: MobileRequestService, storage: KeyValueStorage, events: [Event], identity: RequestIdentity? = nil) {
        self.requestService = requestService
        self.storage = storage
        self.events = events
        self.identity = identity

        super.init(date: events.first?.date ?? Date())
    }

    override func main() {
        super.main()

        guard !isCancelled else {
            finish()

            return
        }

        /// The operation is built from a snapshot taken when the sequence was prepared, which can be
        /// older than the storage by the time it runs. Events already acknowledged by another sync
        /// are gone from the storage - dropping them here is what keeps them from being sent twice.
        let storedIds = Set(storage.getEvents().map { $0.id })
        let pendingEvents = events.filter { storedIds.contains($0.id) }

        sendNextBatch(from: pendingEvents[...])
    }

    private func sendNextBatch(from remainingEvents: ArraySlice<Event>) {
        let batch = Array(remainingEvents.prefix(Self.maxBatchSize))

        guard !isCancelled, batch.isNotEmpty else {
            finish()

            return
        }

        requestService.pinned(to: identity).sendEvents(batch) { [storage] result in
            let isBatchHandled: Bool
            switch result {
            case .success:
                isBatchHandled = true

            case .failure(let error):
                let responseCode = (error as? APIStatusError)?.statusCode ?? 0
                isBatchHandled = (400...499).contains(responseCode)
            }

            guard isBatchHandled else {
                self.finish()

                return
            }

            storage.clearEvents(batch)
            self.sendNextBatch(from: remainingEvents.dropFirst(batch.count))
        }
    }

}
