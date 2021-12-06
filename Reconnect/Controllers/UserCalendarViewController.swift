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
import FirebaseFirestoreSwift

class UserCalendarViewController: DayViewController {
    //private var events: [Eventt] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UserCalendar"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "user"
        //"\(evFirebase.username)'s username"
    
   // let db = Firestore.firestore()
    
    
    /*let event = Eventt(startDate: "2016/10/08 22:31",
                      endDate: "2016/10/08 22:31",
                     isAllDay: false,
                     text: "dentist")
    

    do {
        try db.collection("UserCalendar").document("event").setData(from: event)
    
    } catch let error {
        print("Error writing event to Firestore: \(error)")
    }
    }*/
    
    
    }
}
