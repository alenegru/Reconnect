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
    private var ekEvents: [EKEvent] = []
    private var eventStore2 = EKEventStore()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UserCalendar"
        //navigationController?.navigationBar.prefersLargeTitles = true
        //navigationItem.title = "UserCalendar"
        getEventsForUserFromFirebase()
        saveEkEvtensToStore()
    
    }

    func getEventsForUserFromFirebase() {
      
        events = []
        DatabaseManager.shared.getAllEvents(for: "a-b-com", completion: {[weak self] result in
            switch result {
            case .success(let events):
                guard !events.isEmpty else {
                    print("no events")
                    return
                }
                print("got events")
                self?.events = events
                print(events)
                self?.addAllEventsInEkEvents()
            case .failure(let error):
                print("failed to get events: \(error)")
            }
        })
    }
    private func userEventToEkEvent(at event: UserEvent) -> EKEvent {
        
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        
        let newEKEvent = EKEvent(eventStore: eventStore2)
        newEKEvent.calendar = eventStore2.defaultCalendarForNewEvents
        
       // print(event.endDate)
       // let date = CalendarViewController.dateFormatter.date(from: //event.endDate)!
        //print(CalendarViewController.dateFormatter.string(from: date))
        let endDate_  = CalendarViewController.dateFormatter.date(from: event.endDate)!
        //print(CalendarViewController.dateFormatter.string(from: endDate_))
        let startDate_ = CalendarViewController.dateFormatter.date(from: event.startDate)!
        newEKEvent.startDate = startDate_
        newEKEvent.endDate = endDate_
        newEKEvent.isAllDay = event.isAllDay
        
        //let privateColor = UIColor(ciColor: .red)
        if(event.color == "pink"){
            newEKEvent.title = "busy"
        }
        else{
            let title_ = event.text
            newEKEvent.title = title_
        }
        
        //newEKEvent.calendar. = event.color
        
       // let color = UIColor(ciColor: .red)
       // newEKEvent.calendar.cgColor = color.cgColor
        
        let newEKWrapper = EKWrapper(eventKitEvent: newEKEvent)
//newEKWrapper.editedEvent = newEKWrapper
        create(event: newEKWrapper, animated: true)
        return newEKEvent
    }
    func addAllEventsInEkEvents() {
        
        for event in events{
            let newEkEvent = userEventToEkEvent(at: event)
            ekEvents.append(newEkEvent)
            print(newEkEvent.title + CalendarViewController.dateFormatter.string(from: newEkEvent.endDate))
        }
            print(ekEvents.count)
        
          
    }
    func saveEkEvtensToStore(){
        for ekEvent in ekEvents{
            
            do {
                try eventStore2.save(ekEvent, span: .thisEvent)
            }
            catch {
                print("Save failed")
           }
        }
    }
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        // The `date` always has it's Time components set to 00:00:00 of the day requested
        let startDate = Date()
        var oneDayComponents = DateComponents()
        oneDayComponents.day = 1
        // By adding one full `day` to the `startDate`, we're getting to the 00:00:00 of the *next* day
        let endDate = calendar.date(byAdding: oneDayComponents, to: startDate)!

        let predicate = eventStore2.predicateForEvents(withStart: startDate, // Start of the current day
                                                      end: endDate, // Start of the next day
                                                      calendars: nil) // Search in all calendars

        let eventKitEvents = eventStore2.events(matching: predicate) // All events happening on a given day
        let calendarKitEvents = eventKitEvents.map(EKWrapper.init)

        return calendarKitEvents
    }
    func eventsForDate2(_ date: Date) -> [EventDescriptor] {
        // The `date` always has it's Time components set to 00:00:00 of the day requested
        let startDate = date
        var oneDayComponents = DateComponents()
        oneDayComponents.day = 1
        // By adding one full `day` to the `startDate`, we're getting to the 00:00:00 of the *next* day
        let endDate = calendar.date(byAdding: oneDayComponents, to: startDate)!

        let predicate = eventStore2.predicateForEvents(withStart: startDate, // Start of the current day
                                                      end: endDate, // Start of the next day
                                                      calendars: nil) // Search in all calendars

        let eventKitEvents = eventStore2.events(matching: predicate) // All events happening on a given day
        let calendarKitEvents = eventKitEvents.map(EKWrapper.init)

        return calendarKitEvents
    }
}

