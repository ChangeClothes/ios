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

class AMRUpcomingMeetingsViewController: AMRViewController, AMRViewControllerProtocol {
  
  // MARK: - Constants
  private let meetingTableViewCellReuseIdentifier = "com.armoireapp.meetingTableViewCellReuseIdentifier"
  private let eventStore = EventStore.defaultEventStore
  
  // MARK: - Properties
  var events: [EKEvent]!
  var calendarIdentifier: String?
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
  
  var sections: [NSDate: [EKEvent]]!
  var sortedDays: [NSDate]!
  
  // MARK: - Outlets
  //  @IBOutlet weak var needPermissionView: UIView!
  @IBOutlet weak var meetingsTableView: UITableView!
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDidLogin:", name: kUserDidLoginNotification, object: nil)
    
    setUpNavBar()
    setupTableView(meetingsTableView)
    defineFilter()
    if isAuthorized == true {
      loadEvents()
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    checkCalendarAuthorizationStatus()
  }
  
  func exitModal(){
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func onSettingsTap(){
    self.showSettings()
  }
  
  // MARK: - Initial Setup
  private func defineFilter() {
    if let isStylist = AMRUser.currentUser()?.isStylist where isStylist == true {
      stylist = AMRUser.currentUser()
    } else {
      client = AMRUser.currentUser()
    }
  }
  
  
  private func setupTableView(tableView: UITableView){
    tableView.delegate = self
    tableView.dataSource = self
    let cellNib = UINib(nibName: "AMRUpcomingMeetingsTableViewCell", bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: meetingTableViewCellReuseIdentifier)
  }
  
  internal func setVcData(stylist: AMRUser?, client: AMRUser?) {
    self.stylist = stylist
    self.client = client
  }
  
  private func scrollToLatestDate(){
    if sortedDays.count > 0 {
      var currentClosestInterval = fabs(sortedDays[0].timeIntervalSinceNow)
      var currentMinIndex = 0
      
      for date in sortedDays {
        if fabs(date.timeIntervalSinceNow) <= currentClosestInterval   {
          currentClosestInterval = fabs(date.timeIntervalSinceNow)
          currentMinIndex = sortedDays.indexOf(date)!
        }
      }
      let cellRect = meetingsTableView.rectForSection(currentMinIndex)
      
      // Hack because navigationController is not present sometimes
      let navBarHeight = navigationController?.navigationBar.frame.height ?? 44
      let heightOffset = cellRect.origin.y - navBarHeight - meetingsTableView.sectionHeaderHeight
      meetingsTableView.setContentOffset(CGPointMake(0, heightOffset), animated: false)
    }
  }
  
    internal func setUpNavBar(){
      title = "Upcoming Meetings"
      if stylist != nil && client != nil {
        let newEventButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "createNewEvent:")
        navigationItem.rightBarButtonItem = newEventButton
      }
      if (stylist != nil && client != nil){
        let exitModalButton: UIButton = UIButton()
        exitModalButton.setImage(UIImage(named: "undo"), forState: .Normal)
        exitModalButton.frame = CGRectMake(0, 0, 30, 30)
        exitModalButton.addTarget(self, action: Selector("exitModal"), forControlEvents: .TouchUpInside)
        
        let leftNavBarButton = UIBarButtonItem(customView: exitModalButton)
        self.navigationItem.leftBarButtonItem = leftNavBarButton
      } else {
        let settings: UIButton = UIButton()
        settings.setImage(UIImage(named: "settings"), forState: .Normal)
        settings.frame = CGRectMake(0, 0, 30, 30)
        settings.addTarget(self, action: Selector("onSettingsTap"), forControlEvents: .TouchUpInside)
        
        let leftNavBarButton = UIBarButtonItem(customView: settings)
        self.navigationItem.leftBarButtonItem = leftNavBarButton
      }
    }
    
    // MARK: - Behavior
    func createNewEvent(sender: UIBarButtonItem){
      let newEventVC = EKEventEditViewController()
      newEventVC.eventStore = EventStore.defaultEventStore
      newEventVC.editViewDelegate = self
      newEventVC.event?.title = "Armoire: " + (stylist?.firstName)! + "-" + (client?.firstName)!
      presentViewController(newEventVC, animated: true, completion: nil)
    }
    
    func userDidLogin(sender: NSNotification) {
      defineFilter()
      loadEvents()
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
          return true
        case .OrderedDescending:
          return false
        case .OrderedSame:
          return false
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
          self.sections = self.sectionsForEvents(self.events)
          self.sortedDays = self.sortedDaysForUnsortedDates(Array(self.sections.keys))
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.refreshTableView()
          })
        }
      })
    }
    
    private func sectionsForEvents(events: [EKEvent]) -> [NSDate: [EKEvent]] {
      var sections = [NSDate: [EKEvent]]()
      for event in events {
        let dateRepresentingThisDay = self.dateAtBeginningOfDayForDate(event.startDate)
        
        if let eventsOnThisDay = sections[dateRepresentingThisDay] {
          var copyEventsOnThisDay = eventsOnThisDay
          copyEventsOnThisDay.append(event)
          sections[dateRepresentingThisDay] = copyEventsOnThisDay
        } else {
          var eventsOnThisDay = [EKEvent]()
          eventsOnThisDay.append(event)
          sections[dateRepresentingThisDay] = eventsOnThisDay
        }
      }
      
      return sections
    }
    
    private func sortedDaysForUnsortedDates(unsortedDates: [NSDate]) -> [NSDate] {
      return unsortedDates.sort { $0.compare($1) == NSComparisonResult.OrderedAscending }
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
      scrollToLatestDate()
    }
    
    @IBAction func goToSettingsButtonTapped(sender: UIButton) {
      let openSettingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
      UIApplication.sharedApplication().openURL(openSettingsUrl!)
    }
    
    // MARK: - Date Calculations
    
    private func dateAtBeginningOfDayForDate(inputDate: NSDate) -> NSDate {
      // Use the user's current calendar and time zone
      let calendar = NSCalendar.currentCalendar()
      let timeZone = NSTimeZone.systemTimeZone()
      calendar.timeZone = timeZone
      
      // Selectively convert the date components (year, month, day) of the input date
      let dateComps = calendar.components([.Year, .Month, .Day], fromDate: inputDate)
      
      // Set the time components manually
      dateComps.hour = 0
      dateComps.minute = 0
      dateComps.second = 0
      
      // Convert back
      let beginningOfDay = calendar.dateFromComponents(dateComps)
      return beginningOfDay!
    }
    
    // MARK: - Types
    struct EventStore {
      static let defaultEventStore = EKEventStore()
    }
    
    deinit {
      NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
  }
  
  // MARK: - TableViewDelegate and Datasource
  extension AMRUpcomingMeetingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if let sections = sections {
        let dateRepresentingThisDay = sortedDays[section]
        let eventsOnThisDay = sections[dateRepresentingThisDay]
        return (eventsOnThisDay?.count)!
      }
      
      return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      if let sections = sections {
        return sections.count
      }
      
      return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier(meetingTableViewCellReuseIdentifier)! as! AMRUpcomingMeetingsTableViewCell
      
      let dateRepresentingThisDay = sortedDays[indexPath.section]
      let eventsOnThisDay = sections[dateRepresentingThisDay]
      let event = eventsOnThisDay![indexPath.row]
      
      cell.event = event
      return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      let dateRepresentingThisDay = sortedDays[section]
      return DateFormatters.sectionDateFormatter.stringFromDate(dateRepresentingThisDay)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
      let meetingDetailVC = EKEventViewController()
      meetingDetailVC.event = sections[sortedDays[indexPath.section]]![indexPath.row]
      meetingDetailVC.allowsEditing = true
      meetingDetailVC.delegate = self
      meetingDetailVC.navigationItem.hidesBackButton = true
      
      navigationController?.pushViewController(meetingDetailVC, animated: true)
    }
    
    struct DateFormatters {
      static let sectionDateFormatter = DateFormatters.sharedSectionDateFormatter()
      
      private static func sharedSectionDateFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .NoStyle
        return dateFormatter
      }
      
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
      AMRMeeting.deleteMeetingWithObjectId(event.notes!) { (success, error) -> Void in
        if let error = error {
          print(error.localizedDescription)
        } else {
          self.loadEvents()
        }
      }
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
            if let stylist = self.stylist {
              meeting.stylist = stylist
            }
            if let client = self.client {
              meeting.client = client
            }
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