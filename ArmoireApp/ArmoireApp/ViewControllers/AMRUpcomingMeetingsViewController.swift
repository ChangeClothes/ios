//
//  AMRUpcomingMeetingsViewController.swift
//  ArmoireApp
//
//  Created by Randy Ting on 10/17/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

class AMRUpcomingMeetingsViewController: UIViewController {
    
    // MARK: - Constants
    private let meetingTableViewCellReuseIdentifier = "com.armoireapp.meetingTableViewCellReuseIdentifier"
    private let eventStore = EventStore.defaultEventStore
    
    // MARK: - Properties
    var events: [EKEvent]!
    var calendarIdentifier: String?
    var stylist: PFUser?
    var client: PFUser?
    private var isAuthorized: Bool! {
        get {
            let status = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
            
            switch (status) {
            case EKAuthorizationStatus.NotDetermined:
                return false
            case EKAuthorizationStatus.Authorized:
                return true
            case EKAuthorizationStatus.Restricted, EKAuthorizationStatus.Denied:
                return false
            }
        }
    }
    
    // MARK: - Outlets
    //  @IBOutlet weak var needPermissionView: UIView!
    @IBOutlet weak var meetingsTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // BEGIN For Testing
        PFUser.logInWithUsernameInBackground("randy", password: "abc123", block: { (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                self.stylist = user
            }
            let query = PFUser.query()
            query!.whereKey("username" , equalTo:"brian")
            query?.getFirstObjectInBackgroundWithBlock({ (user: PFObject?, error: NSError?) -> Void in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.client = user as? PFUser
                }
                
                if self.isAuthorized == true{
                    self.loadEvents()
                }
                
            })
            
        })
        // END For Testing
        
        setupNavigationBar()
        setupTableView(meetingsTableView)
    }
    
    override func viewWillAppear(animated: Bool) {
        checkCalendarAuthorizationStatus()
    }
    
    // MARK: - Initial Setup
    private func setupNavigationBar(){
        title = "Upcoming Meetings"
        // Use this for testing
        let newEventButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "createNewEvent:")
        navigationItem.rightBarButtonItem = newEventButton
        // End
        // Use this for production.  It hows the add event button only when the client is filtered.
        /*
        if let _ = client{
        let newEventButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "createNewEvent:")
        navigationItem.rightBarButtonItem = newEventButton
        }
        */
    }
    
    private func setupTableView(tableView: UITableView){
        tableView.delegate = self
        tableView.dataSource = self
        let cellNib = UINib(nibName: "AMRUpcomingMeetingsTableViewCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: meetingTableViewCellReuseIdentifier)
    }
    
    // MARK: - Behavior
    func createNewEvent(sender: UIBarButtonItem){
        let newEventVC = EKEventEditViewController()
        newEventVC.eventStore = EventStore.defaultEventStore
        newEventVC.editViewDelegate = self
        presentViewController(newEventVC, animated: true, completion: nil)
    }
    
    // MARK: - Authorization
    private func checkCalendarAuthorizationStatus() {
        let status = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        
        switch (status) {
        case EKAuthorizationStatus.NotDetermined:
            requestAccessToCalendar()
        case EKAuthorizationStatus.Authorized:
            loadLocalCalendar()
            loadEvents()
        case EKAuthorizationStatus.Restricted, EKAuthorizationStatus.Denied:
            break
            // We need to help them give us permission
            //      needPermissionView.fadeIn()
        }
    }
    
    private func requestAccessToCalendar() {
        eventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
            (accessGranted: Bool, error: NSError?) in
            
            if accessGranted == true {
                dispatch_async(dispatch_get_main_queue(), {
                    self.loadLocalCalendar()
                    self.loadEvents()
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    //          self.needPermissionView.fadeIn()
                })
            }
        })
    }
    
    // MARK: - Utility
    private func  getEventsforCalendarIdentifier(calendarIdentifier: String) -> [EKEvent]{
        
        let calendar = calendarForIdentifier(calendarIdentifier)
        
        let calendarArray: [EKCalendar] = Array.init(arrayLiteral: calendar)
        let yearSeconds: NSTimeInterval = 365 * (60 * 60 * 24);
        let predicate = eventStore.predicateForEventsWithStartDate(NSDate(timeIntervalSinceNow: -yearSeconds), endDate: NSDate(timeIntervalSinceNow: yearSeconds), calendars: calendarArray)
        var eventsArray = eventStore.eventsMatchingPredicate(predicate)
        eventsArray.sortInPlace { (event1, event2) -> Bool in
            switch event1.startDate.compare(event2.startDate){
            case .OrderedAscending:
                return false
            case .OrderedDescending:
                return true
            case .OrderedSame:
                return true
            }
        }
        
        return eventsArray
    }
    
    private func calendarForIdentifier(calendarIdentifier: String) -> EKCalendar {
        // let calendar = eventStore.calendarWithIdentifier(calendarIdentifier) <- outputs error on console
        let allCalendars : [EKCalendar] = eventStore.calendarsForEntityType(.Event) as [EKCalendar]
        return (allCalendars.filter { $0.calendarIdentifier == calendarIdentifier }).first!
    }
    
    private func loadEvents(){
        AMRMeeting.meetingArrayForStylist(self.stylist, client: self.client, completion: { (meetings: [AMRMeeting]?, error: NSError?) -> Void in
            if let error = error {
                print(error.localizedDescription)
            } else {
                var allCalendarEvents = self.getEventsforCalendarIdentifier(self.calendarIdentifier!)
                let unmatchedMeetingsArray = self.unmatchedMeetings(meetings, events: allCalendarEvents)
                self.createEventsForUnmatchedMeetings(unmatchedMeetingsArray) // Add events if missing from local calendar, but exist in database.
                allCalendarEvents = self.getEventsforCalendarIdentifier(self.calendarIdentifier!)
                self.events = self.eventsMatchingMeetings(meetings, events: allCalendarEvents)
                self.refreshTableView()
            }
            
        })
    }
    
    private func createEventsForUnmatchedMeetings(unmatchedMeetings: [AMRMeeting]) {
        for meeting in unmatchedMeetings {
            let event = EKEvent(eventStore: eventStore)
            event.calendar = calendarForIdentifier(calendarIdentifier!)
            event.notes = meeting.objectId
            event.title = meeting.title
            event.startDate = meeting.startDate
            event.endDate = meeting.endDate
            event.location = meeting.location
            try! eventStore.saveEvent(event, span: EKSpan.ThisEvent)
        }
    }
    
    private func eventsMatchingMeetings(meetings: [AMRMeeting]?, events: [EKEvent]) -> [EKEvent] {
        
        var matchedEvents = [EKEvent]()
        
        for meeting in meetings! {
            for event in events {
                if meeting.objectId == event.notes {
                    matchedEvents.append(event)
                }
            }
        }
        
        return matchedEvents
    }
    
    private func unmatchedMeetings(meetings: [AMRMeeting]?, events: [EKEvent]) -> [AMRMeeting] {
        var unmatchedMeetings = [AMRMeeting]()
        var matched = false
        
        for meeting in meetings! {
            for event in events {
                if meeting.objectId == event.notes {
                    matched = true
                }
            }
            if matched == false {
                unmatchedMeetings.append(meeting)
            } else {
                matched = false
            }
        }
        
        return unmatchedMeetings
    }
    
    private func loadLocalCalendar(){
        calendarIdentifier = eventStore.defaultCalendarForNewEvents.calendarIdentifier
    }
    
    private func refreshTableView() {
        meetingsTableView.reloadData()
    }
    
    @IBAction func goToSettingsButtonTapped(sender: UIButton) {
        let openSettingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(openSettingsUrl!)
    }
    
    // MARK: - Types
    struct EventStore {
        static let defaultEventStore = EKEventStore()
    }
    
}

// MARK: - TableViewDelegate and Datasource
extension AMRUpcomingMeetingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let events = events {
            return events.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(meetingTableViewCellReuseIdentifier)!
        
        if let events = events {
            let eventName = events[indexPath.row].title
            cell.textLabel?.text = eventName
        } else {
            cell.textLabel?.text = "Unknown Event Name"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let meetingDetailVC = EKEventViewController()
        meetingDetailVC.event = events[indexPath.row]
        meetingDetailVC.allowsEditing = true
        meetingDetailVC.delegate = self
        meetingDetailVC.navigationItem.hidesBackButton = true
        
        navigationController?.pushViewController(meetingDetailVC, animated: true)
    }
}

// MARK: - EKEventViewControllerDelegate
extension AMRUpcomingMeetingsViewController: EKEventViewDelegate {
    func eventViewController(controller: EKEventViewController, didCompleteWithAction action: EKEventViewAction) {
        
        switch action {
        case .Done:
            print("Done")
            updateEventInDatabase(controller.event)
        case .Deleted:
            print("Deleted from event view")
            // EKEventViewController handles deleting from calendar for us.  We just need to update our database.
            deleteEventFromDatabase(controller.event)
        case .Responded:
            print("Responded")
            break
        }
        navigationController?.popViewControllerAnimated(true)
    }
    
    private func deleteEventFromDatabase(event: EKEvent){
        AMRMeeting.deleteMeetingWithObjectId(event.notes!)
    }
    
    private func updateEventInDatabase(event: EKEvent){
        AMRMeeting.meetingWithObjectId(event.notes) { (meeting: AMRMeeting?, error: NSError?) -> Void in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let meeting = meeting {
                    meeting.title = event.title
                    meeting.startDate = event.startDate
                    meeting.endDate = event.endDate
                    meeting.stylist = self.stylist!
                    meeting.client = self.client!
                    meeting.location = event.location
                    meeting.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            self.loadEvents()
                        }
                    }
                }
            }
        }
    }
    
}

// MARK: - EKEventEditViewControllerDelegate
extension AMRUpcomingMeetingsViewController: EKEventEditViewDelegate{
    
    func eventEditViewController(controller: EKEventEditViewController, didCompleteWithAction action: EKEventEditViewAction) {
        switch action {
        case .Canceled:
            print("Cancelled")
        case .Deleted:
            print("Deleted from edit view")
            deleteEventFromDatabase(controller.event!)
        case .Saved:
            addEventToDatabase(controller.event!)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func addEventToDatabase(event: EKEvent){
        
        // Add event to database
        let newMeeting = AMRMeeting()
        newMeeting.title = event.title
        newMeeting.startDate = event.startDate
        newMeeting.endDate = event.endDate
        newMeeting.stylist = stylist!
        newMeeting.client = client!
        newMeeting.location = event.location
        newMeeting.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if let error = error {
                print(error.localizedDescription)
            } else {
                // Update EKEvent note to store objectID of meeting in database
                event.notes = newMeeting.objectId
                try! self.eventStore.saveEvent(event, span: EKSpan.ThisEvent)
                self.loadEvents()
            }
        }
    }
    
}