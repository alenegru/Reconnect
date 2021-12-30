//
//  Event.swift
//  Reconnect
//
//  Created by Danciu Vasi on 30/12/2021.
//


import Foundation


//var events = [UserEvent]()
//func getEventsForUserFromFirebase() {
//
//    events = []
//    DatabaseManager.shared.getAllEvents(for: "a-b-com", completion: {[weak self] result in
//        switch result {
//        case .success(let events):
//            guard !events.isEmpty else {
//                print("no events")
//                return
//            }
//            print("got events")
//            self?.events = events
//            print(events)
//            self?.addAllEventsInEkEvents()
//        case .failure(let error):
//            print("failed to get events: \(error)")
//        }
//    })
//}
//private func userEventToDailyEvent(at event: UserEvent) -> Event {
//    let newEvent = Event()
//   // let endDate_  = CalendarViewController.dateFormatter.date(from: event.endDate)!
//
//    let startDate_ = CalendarViewController.dateFormatter.date(from: event.startDate)!
//    newEvent.date = startDate_
//   // newEvent.endDate = endDate_
//   // newEvent.isAllDay = event.isAllDay
//
//    //let privateColor = UIColor(ciColor: .red)
//    if(event.color == "pink"){
//        newEvent.name = "busy"
//    }
//    else{
//        newEvent.name = event.text
//    }
//    return newEvent
//}
//func addAllEventsInEventList() {
//
//    for event in events{
//        let newEvent = userEventToDailyEvent(at: event)
//        eventsList.append(newEvent)
//    }
//        print(eventsList.count)
//}
//var eventsList : [Event] = 
class Event
{
    var id: Int!
    var name: String!
    var startDate: Date!
    var endDate: Date!
    
//    func eventsForDate(date: Date) -> [Event]
//    {
//        var daysEvents = [Event]()
//        for event in eventsList
//        {
//            if(Calendar.current.isDate(event.date, inSameDayAs:date))
//            {
//                daysEvents.append(event)
//            }
//        }
//        return daysEvents
//    }
//
//    func eventsForDateAndTime(date: Date, hour: Int) -> [Event]
//    {
//        var daysEvents = [Event]()
//        for event in eventsList
//        {
//            if(Calendar.current.isDate(event.date, inSameDayAs:date))
//            {
//                let eventHour = CalendarHelper().hourFromDate(date: event.date)
//                if eventHour == hour
//                {
//                    daysEvents.append(event)
//                }
//            }
//        }
//        return daysEvents
//    }
}
