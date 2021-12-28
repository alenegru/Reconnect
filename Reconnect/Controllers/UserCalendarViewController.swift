//
//  UserCalendarViewController.swift
//  Reconnect
//
//  Created by Danciu Vasi on 03/12/2021.
//

import UIKit
import CalendarKit
import EventKit
import EventKitUI
import FirebaseFirestore

class UserCalendarViewController: DayViewController {
    private var events: [UserEvent] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UserCalendar"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "UserCalendar"
    }
}
