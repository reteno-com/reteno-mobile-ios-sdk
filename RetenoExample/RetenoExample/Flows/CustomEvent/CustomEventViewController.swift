//
//  CustomEventViewController.swift
//  RetenoExample
//
//  Copyright © 2026 Yalantis. All rights reserved.
//

import UIKit
import SnapKit
import Reteno

final class CustomEventViewController: KeyboardHandlingViewController {
    
    private let contentView = UIView()
    private let stack = UIStackView()
    private let eventNameTextField = CommonTextField()
    private let parametersStack = UIStackView()
    private let addParameterButton = CommonButton()
    private let repeatModeControl = UISegmentedControl(items: ScheduleRepeatMode.allCases.map { $0.title })
    private let timePicker = UIDatePicker()
    private let scheduleEventButton = CommonButton()
    private let scheduledEventsStack = UIStackView()
    private let logEventButton = CommonButton()
    
    private var parameterRows: [ParameterRow] = []
    
    private var selectedRepeatMode: ScheduleRepeatMode {
        let modes = ScheduleRepeatMode.allCases
        guard modes.indices.contains(repeatModeControl.selectedSegmentIndex) else { return .once }
        
        return modes[repeatModeControl.selectedSegmentIndex]
    }
    
    private let viewModel: CustomEventViewModel
    
    init(viewModel: CustomEventViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupHandlers()
        reloadScheduledEvents()
    }
    
    // MARK: - Actions
    
    @objc
    private func addParameterAction() {
        addParameterRow()
    }
    
    @objc
    private func logEventAction() {
        view.endEditing(true)
        
        guard let eventName = validatedEventName() else { return }
        
        viewModel.logEvent(eventTypeKey: eventName, parameters: mapParameters())
    }
    
    @objc
    private func scheduleEventAction() {
        view.endEditing(true)
        
        guard let eventName = validatedEventName() else { return }
        
        let time = Calendar.current.dateComponents([.hour, .minute], from: timePicker.date)
        guard
            let scheduledEvent = viewModel.scheduleEvent(
                eventTypeKey: eventName,
                parameters: mapParameters(),
                hour: time.hour ?? 0,
                minute: time.minute ?? 0,
                repeatMode: selectedRepeatMode
            )
        else { return }
        
        reloadScheduledEvents()
        presentAlert(
            message: String(
                format: NSLocalizedString("custom_event_screen.scheduled_alert.message", comment: ""),
                scheduledEvent.scheduleDescription
            )
        )
    }
    
    // MARK: - Helpers
    
    private func validatedEventName() -> String? {
        guard let eventName = eventNameTextField.text, !eventName.isEmpty else {
            presentAlert(message: NSLocalizedString("custom_event_screen.validation.missed_event_name", comment: ""))
            return nil
        }
        
        return eventName
    }
    
    private func mapParameters() -> [CustomEventParameter] {
        parameterRows.compactMap { row in
            guard let name = row.name, !name.isEmpty else { return nil }
            
            return CustomEventParameter(name: name, value: row.value)
        }
    }
    
    @discardableResult
    private func addParameterRow() -> ParameterRow {
        let row = ParameterRow()
        row.onRemove = { [weak self] removedRow in
            self?.removeParameterRow(removedRow)
        }
        parameterRows.append(row)
        parametersStack.addArrangedSubview(row)
        
        return row
    }
    
    private func removeParameterRow(_ row: ParameterRow) {
        parameterRows.removeAll { $0 === row }
        parametersStack.removeArrangedSubview(row)
        row.removeFromSuperview()
    }
    
    private func reloadScheduledEvents() {
        scheduledEventsStack.arrangedSubviews.forEach {
            scheduledEventsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        let scheduledEvents = viewModel.scheduledEvents
        guard !scheduledEvents.isEmpty else {
            let emptyLabel = UILabel()
            emptyLabel.text = NSLocalizedString("custom_event_screen.scheduled_events.empty", comment: "")
            emptyLabel.textColor = .gray
            emptyLabel.font = .systemFont(ofSize: 14)
            scheduledEventsStack.addArrangedSubview(emptyLabel)
            
            return
        }
        
        scheduledEvents.forEach { event in
            let row = ScheduledEventRow(event: event)
            row.onRemove = { [weak self] id in
                self?.viewModel.cancelScheduledEvent(id: id)
                self?.reloadScheduledEvents()
            }
            scheduledEventsStack.addArrangedSubview(row)
        }
    }
    
    private func presentAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("common.ok", comment: ""), style: .default))
        present(alert, animated: true)
    }
    
    private func setupHandlers() {
        addParameterButton.addTarget(self, action: #selector(addParameterAction), for: .touchUpInside)
        scheduleEventButton.addTarget(self, action: #selector(scheduleEventAction), for: .touchUpInside)
        logEventButton.addTarget(self, action: #selector(logEventAction), for: .touchUpInside)
        
        viewModel.onScheduledEventsChange = { [weak self] in
            self?.reloadScheduledEvents()
        }
    }
}

// MARK: - Layout

private extension CustomEventViewController {
    
    func setupLayout() {
        title = NSLocalizedString("custom_event_screen.title", comment: "")
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(80.0)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView)
            $0.width.equalTo(scrollView)
        }
        
        contentView.addSubview(stack)
        stack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.top.equalToSuperview().inset(20.0)
            $0.bottom.lessThanOrEqualToSuperview().inset(20.0)
        }
        stack.axis = .vertical
        stack.spacing = 16.0
        
        let eventNameLabel = makeSectionLabel(
            text: NSLocalizedString("custom_event_screen.event_name", comment: "")
        )
        stack.addArrangedSubview(eventNameLabel)
        
        eventNameTextField.placeholder = NSLocalizedString("custom_event_screen.event_name_placeholder", comment: "")
        eventNameTextField.textAlignment = .left
        stack.addArrangedSubview(eventNameTextField)
        
        let parametersLabel = makeSectionLabel(
            text: NSLocalizedString("custom_event_screen.parameters", comment: "")
        )
        stack.addArrangedSubview(parametersLabel)
        
        parametersStack.axis = .vertical
        parametersStack.spacing = 10.0
        stack.addArrangedSubview(parametersStack)
        
        addParameterButton.setTitle(
            NSLocalizedString("custom_event_screen.add_parameter_button.title", comment: ""),
            for: .normal
        )
        addParameterButton.snp.makeConstraints {
            $0.height.equalTo(45.0)
        }
        stack.addArrangedSubview(addParameterButton)
        
        setupScheduleLayout()
        
        view.addSubview(logEventButton)
        logEventButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20.0)
            $0.height.equalTo(50.0)
        }
        logEventButton.setTitle(
            NSLocalizedString("custom_event_screen.log_event_button.title", comment: ""),
            for: .normal
        )
    }
    
    func setupScheduleLayout() {
        let scheduleLabel = makeSectionLabel(
            text: NSLocalizedString("custom_event_screen.schedule", comment: "")
        )
        stack.addArrangedSubview(scheduleLabel)
        
        repeatModeControl.selectedSegmentIndex = 0
        stack.addArrangedSubview(repeatModeControl)
        
        timePicker.datePickerMode = .time
        
        let timeLabel = UILabel()
        timeLabel.text = NSLocalizedString("custom_event_screen.schedule.time", comment: "")
        timeLabel.textColor = .black
        timeLabel.font = .systemFont(ofSize: 16)
        
        if #available(iOS 13.4, *) {
            timePicker.preferredDatePickerStyle = .compact
            timePicker.setContentHuggingPriority(.required, for: .horizontal)
            timeLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
            
            let timeRow = UIStackView(arrangedSubviews: [timeLabel, timePicker])
            timeRow.axis = .horizontal
            timeRow.alignment = .center
            timeRow.spacing = 10.0
            stack.addArrangedSubview(timeRow)
        } else {
            stack.addArrangedSubview(timeLabel)
            stack.addArrangedSubview(timePicker)
            timePicker.snp.makeConstraints {
                $0.height.equalTo(160.0)
            }
        }
        
        scheduleEventButton.setTitle(
            NSLocalizedString("custom_event_screen.schedule_button.title", comment: ""),
            for: .normal
        )
        scheduleEventButton.snp.makeConstraints {
            $0.height.equalTo(45.0)
        }
        stack.addArrangedSubview(scheduleEventButton)
        
        let scheduledEventsLabel = makeSectionLabel(
            text: NSLocalizedString("custom_event_screen.scheduled_events", comment: "")
        )
        stack.addArrangedSubview(scheduledEventsLabel)
        
        scheduledEventsStack.axis = .vertical
        scheduledEventsStack.spacing = 10.0
        stack.addArrangedSubview(scheduledEventsStack)
    }
    
    func makeSectionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        
        return label
    }
}

// MARK: - ParameterRow

private final class ParameterRow: UIView {
    
    var onRemove: ((ParameterRow) -> Void)?
    
    var name: String? { nameTextField.text }
    var value: String { valueTextField.text ?? "" }
    
    private let nameTextField = CommonTextField()
    private let valueTextField = CommonTextField()
    private let removeButton = CommonButton()
    
    init() {
        super.init(frame: .zero)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func removeAction() {
        onRemove?(self)
    }
    
    private func setupLayout() {
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.spacing = 10.0
        rowStack.alignment = .center
        addSubview(rowStack)
        rowStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        nameTextField.placeholder = NSLocalizedString("custom_event_screen.parameter_name_placeholder", comment: "")
        nameTextField.textAlignment = .left
        rowStack.addArrangedSubview(nameTextField)
        
        valueTextField.placeholder = NSLocalizedString("custom_event_screen.parameter_value_placeholder", comment: "")
        valueTextField.textAlignment = .left
        rowStack.addArrangedSubview(valueTextField)
        
        nameTextField.snp.makeConstraints {
            $0.width.equalTo(valueTextField)
        }
        
        removeButton.setTitle("-", for: .normal)
        removeButton.addTarget(self, action: #selector(removeAction), for: .touchUpInside)
        removeButton.setContentHuggingPriority(.required, for: .horizontal)
        removeButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        rowStack.addArrangedSubview(removeButton)
        removeButton.snp.makeConstraints {
            $0.width.height.equalTo(30.0)
        }
    }
}

// MARK: - ScheduledEventRow

private final class ScheduledEventRow: UIView {
    
    var onRemove: ((UUID) -> Void)?
    
    private let eventId: UUID
    private let titleLabel = UILabel()
    private let removeButton = CommonButton()
    
    init(event: ScheduledCustomEvent) {
        eventId = event.id
        
        super.init(frame: .zero)
        
        setupLayout(event: event)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func removeAction() {
        onRemove?(eventId)
    }
    
    private func setupLayout(event: ScheduledCustomEvent) {
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.spacing = 10.0
        rowStack.alignment = .center
        addSubview(rowStack)
        rowStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.text = "\(event.eventName)\n\(event.scheduleDescription)"
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 14)
        rowStack.addArrangedSubview(titleLabel)
        
        removeButton.setTitle("-", for: .normal)
        removeButton.addTarget(self, action: #selector(removeAction), for: .touchUpInside)
        removeButton.setContentHuggingPriority(.required, for: .horizontal)
        removeButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        rowStack.addArrangedSubview(removeButton)
        removeButton.snp.makeConstraints {
            $0.width.height.equalTo(30.0)
        }
    }
}
