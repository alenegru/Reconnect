//
//  DailyViewController.swift
//  Reconnect
//
//  Created by Danciu Vasi on 30/12/2021.
//

import UIKit

var selectedDate = Date()
class DailyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var hourTableView: UITableView!
    @IBOutlet weak var dayOfWeekLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    var hours = [Int]()
    
    var currentUser: String = "a-b-com"
    
    override func viewDidLoad()
    {
        getEventsForUserFromFirebase()
        super.viewDidLoad()
        initTime()
        setDayView()
    }
    
    func initTime()
    {
        for hour in 0...23
        {
            hours.append(hour)
        }
    }
    
    func setDayView()
    {
        dayLabel.text = CalendarHelper().monthDayString(date: selectedDate)
        dayOfWeekLabel.text = CalendarHelper().weekDayAsString(date: selectedDate)
        hourTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hours.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellDailyID") as! DailyCell
        
        let hour  = hours[indexPath.row]
        cell.time.text = formatHour(hour: hour)
        
        //let events = Event().eventsForDateAndTime(date: selectedDate, hour: hour)
        let events = eventsForDateAndTime(startDate: selectedDate, hour: hour)
        setEvents(cell, events)
        
        return cell
    }
    
    func setEvents(_ cell: DailyCell, _ events: [Event])
    {
        hideAll(cell)
        switch events.count
        {
        case 1:
            setEvent1(cell, events[0])
        case 2:
            setEvent1(cell, events[0])
            setEvent2(cell, events[1])
        case 3:
            setEvent1(cell, events[0])
            setEvent2(cell, events[1])
            setEvent3(cell, events[2])
        
        case let count where count > 3:
            setEvent1(cell, events[0])
            setEvent2(cell, events[1])
            setMoreEvents(cell, events.count - 2)
        default:
            break
        }
    }
    
    
    func setMoreEvents(_ cell: DailyCell, _ count: Int)
    {
        cell.event3.isHidden = false
        cell.event3.text = String(count) + " More Events"
    }
    
    func setEvent1(_ cell: DailyCell, _ event: Event)
    {
        cell.event1.isHidden = false
        cell.event1.text = event.name
    }
    
    func setEvent2(_ cell: DailyCell, _ event: Event)
    {
        cell.event2.isHidden = false
        cell.event2.text = event.name
    }
    
    func setEvent3(_ cell: DailyCell, _ event: Event)
    {
        cell.event3.isHidden = false
        cell.event3.text = event.name
    }
    
    func hideAll(_ cell: DailyCell)
    {
        cell.event1.isHidden = true
        cell.event2.isHidden = true
        cell.event3.isHidden = true
    }
    
    
    func formatHour(hour: Int) -> String
    {
        return String(format: "%02d:%02d", hour, 0)
    }
    
    @IBAction func nextDayAction(_ sender: Any)
    {
        selectedDate = CalendarHelper().addDays(date: selectedDate, days: 1)
        setDayView()
    }
    
    @IBAction func previousDayAction(_ sender: Any)
    {
        selectedDate = CalendarHelper().addDays(date: selectedDate, days: -1)
        setDayView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setDayView()
    }
    
    func eventsForDate(date: Date) -> [Event]
    {
        var daysEvents = [Event]()
        for event in eventsList
        {
            if(Calendar.current.isDate(event.startDate, inSameDayAs:date))
            {
                
                daysEvents.append(event)
            }
        }
        return daysEvents
    }
    
    func eventsForDateAndTime(startDate: Date, hour: Int) -> [Event]
    {
        var daysEvents = [Event]()
        for event in eventsList
        {
            if(Calendar.current.isDate(event.startDate, inSameDayAs:startDate))
            {
                let startEventHour = CalendarHelper().hourFromDate(date: event.startDate)
                let endEventHour = CalendarHelper().hourFromDate(date: event.endDate)
                if startEventHour <= hour && endEventHour > hour
                {
                    daysEvents.append(event)
                }
            }
        }
        return daysEvents
    }
    
    var eventsList = [Event]()
    var events = [UserEvent]()
    func getEventsForUserFromFirebase() {
      
        events = []
        DatabaseManager.shared.getAllEvents(for: currentUser, completion: {[weak self] result in
            switch result {
            case .success(let events):
                guard !events.isEmpty else {
                    print("no events")
                    return
                }
                print("got events")
                self?.events = events
                print(events)
                self?.addAllEventsInEventList()
            case .failure(let error):
                print("failed to get events: \(error)")
            }
        })
    }
    private func userEventToDailyEvent(at event: UserEvent) -> Event {
        let newEvent = Event()
        let endDate_  = CalendarViewController.dateFormatter.date(from: event.endDate)!
        
        let startDate_ = CalendarViewController.dateFormatter.date(from: event.startDate)!
        newEvent.startDate = startDate_
        newEvent.endDate = endDate_
       // newEvent.isAllDay = event.isAllDay
        
        //let privateColor = UIColor(ciColor: .red)
        if(event.color == "pink"){
            newEvent.name = "Busy"
        }
        else{
            newEvent.name = event.text
        }
        return newEvent
    }
    func getAllEventList() -> [Event]{
          return eventsList
    }
    func addAllEventsInEventList() {
        
        for event in events{
            let newEvent = userEventToDailyEvent(at: event)
            eventsList.append(newEvent)
        }
            print(eventsList.count)
         
    }
    


}
