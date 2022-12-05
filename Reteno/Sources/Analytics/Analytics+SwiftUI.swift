//
//  Analytics+SwiftUI.swift
//  Reteno
//
//  Created by Anna Sahaidak on 01.10.2022.
//

#if canImport(SwiftUI)
import SwiftUI

/// Custom view modifier for easily logging screen view events.
@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, *)
@available(watchOS, unavailable)
struct LoggedAnalyticsModifier: ViewModifier {

    let screenClass: String
    let extraParameters: [Event.Parameter]

    func body(content: Content) -> some View {
        content.onAppear {
            var parameters = extraParameters
            parameters.append(Event.Parameter(name: ScreenClass, value: screenClass))
            Reteno.logEvent(eventTypeKey: ScreenViewEvent, parameters: parameters)
        }
    }
}

@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, *)
@available(watchOS, unavailable)
public extension View {
    /// Logs `screen_view` events when this view appears on screen.
    /// - Parameters:
    ///   - class: Current screen class or struct logged with the `screen_view` event.
    /// - Returns: A view with a custom `ViewModifier` used to log `screen_view` events when this view appears on screen.
    func analyticsScreen(class: String = "View", extraParameters: [Event.Parameter] = []) -> some View {
        modifier(LoggedAnalyticsModifier(screenClass: `class`, extraParameters: extraParameters))
    }
}
#endif
