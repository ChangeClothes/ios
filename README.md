### Demo To Do Items

- Randy
  - [x] update icons
  - Profile
    - [ ] placeholders
    - [ ] swipe left to go to previous picture, right to go to next picture, and then there needs to be a way to return to the main profile
    - [x] remove client name
    - [x] make buttons able to be tinted so they're obviously clickable
    - [x] general design (not color choices, just layout)

- Matt
  - [ ] Profile Picture Upload: Get Off Main Thread
  - [ ] Splash Page
  - [ ] Icon
  - Color Scheme for All Pages + Navbar
    - [ ] Design

- Morgan
  - Notification
    - [ ] app starts and notification background exists; hide it
    - [ ] profile pic appears instead of email icon
    - [ ] change animation to sliding and then wee bounce

- Grab Bag
  - while in msging receive a msg, when you exit that msg will still be visible
  - on first sign in, the focus color box on nav bar comes sliding in from off screen
  - focus color box on nav bar should be circle or have rounded edges or something: better design
  - hit boxes are too small

###What Armoire Does
Armoire aims to be a CRM for personal shoppers running their own small businesses, as well as providing a platform for their clients to track their service and communicate with them in one location using the "profile" page and related communication pages provided. 

The core feature set for the stylist's is a list of their clients, profile pages that allow quick access to the most relevant facts about their clients (measurements, price range for different types of clothing, along with basic demographic data), a communication platform that provides an easy to follow history, notes for future reference about what works and doesn't work for the client, a camera that creates photos that are associated with the appropriate client, and the ability to create appointments (including providing a history of past appointments and notifying both client and stylist about upcoming appointments).

The client will only be able to access their own profile page, the communication page (with access only to their stylists), and the appointment tool. 

The above is the bare minimum that needs to be provided to ensure value is added through the Armoire application; further enhancements such as reminder notifications related to clients that are primed for further engagement, a billing feature, and a shipping feature would further establish the Armoire app as a valuable tool in this space.

###Features

####Required (MVP)

- Business
  - [ ] SquareSpace.com/logo or some other icon
  - [ ] Choose tagline
  - [ ] Choose font
- (Personal Shopper's View) Client Management
  - Sign Up Page
    - [x] Designer can sign up
    - [x] Client can log in
    - [ ] If the client was invited they will have a text sent with code and url to download
      OR
    - [ ] the link to download auto-sets the email field
  - Clients Page
    - [x] list of clients which show their names
    - [x] click cell leads to individual profile page
  - Client Profile Page
    - [] include pic, phone, email, and other basic data (next time seen, money spent, began working with, etc)
    - [x] include measurements that can be modified by user (name, measurement, price range)
    - [x] can access and edit personal notes
  - Scheduler
    - [x] should see upcoming appointments and past appointment with time, location, and customer
    - [x] should be added to their phone calendar
    - [x] remind of upcoming appointments
  - Messaging
    - [x] message capacity in realtime between client and designer
    - [x] history of messaging history
  - Add Client
    - [x] Add a client which sends email to client with link to download the Armoire App
    - [ ] First check if client already exists, in which case notify them and allow process to associate them with the designer attempting to claim them
    - [x] If no client exists, create client and text them with a code that will confirm their identity and association to designer
  - Photo
    - [ ] Take Photo and associate it with a client
    - [ ] Icon on photo to indicate stylist took it


- (Client's View) Fashion Notes/History - Kind of like a medical record for clothes, but with ability to interact with personal shopper.
  - [x] same as above except limited to their specific profile page with specific components (like amount spent and personal stylist notes not available, though they should be able to create their own notes)

###Stretch Goals

- Notes 
  - [ ] can be associated with specific meeting, for both customer and client 
  - [ ] Notes shareable
- Billing
  - [ ] start a timer with an associated hourly rate -> calculate final fee
  - [ ] send a request for payment to client
  - [ ] see history of payments and outstanding requests
- Reminders
  - [ ] reminder system that has toggles for common concern
  - [ ] haven't spoken to them in a while, but they logged in recently so reach out
  - [ ] bill overdue
  - [ ] sales
- Shipping
  - [ ] ships to clients seamlessly
    - [ ] print label option
    OR
    - [ ] integrate with ship or something similar



### Demo Workflow
- Let's see how a typical Armoire user, Veronica Corningstone, uses the app.  This is a typical morning in Veronica's day.  Veronica is sitting at the local Blue Bottle Coffee, sipping her favorite single origin cappucino with a rosetta pattern on top.
- She opens up the Armoire app, and checks her schedule for the day.  As an independent personal stylist, her work revolves around both in-person appointments and direct communication with her clients.
- In order to stay on track, she messages her first client, Zayn, to remind him of his appointment.
- Veronica: "Hi Zayn! Are we still on for 10am today?"
- Zayn: "Hi Veronica! Actually, can we do 9 instead?"
- Veronica jumps back to the calendar feature of the Armoire app to check her availability and change the appointment time, which Zayn sees in his app.
- Veronica: "Sure, I just updated our appointment time, please check your calendar to make sure the location and time is correct.  See you later!"
- Zayn: "emoji - thumbs up"
- Because Veronica hasn't seen Zayn in a while, she refreshes her memory by looking through Zayn's Armoire profile.
- Veronica looks at her notes on Zayn and notices that he is looking for a new job.
- Veronica: "Did you see the new pictures of clothes I uploaded last week?"
- Zayn: "Yes, they look great"
- Zayn: "Can we look for shoes today too?  I'm a 11.5 W."
- Veronica: "Of course!"
- Veronica adds Zayn's shoe size to Zayn's measurements.
- Beyonce: "Hey can we meet up today?"
- Veronica looks at Beyonce's previous meetings and notices she only shops at Burberry.  She checks her notes on Beyonce.
- Veronica: "Sure, I have an opening at 4-5pm.  Burberry on Market again?"
- Beyonce: "I'll be there."
- Veronica adds the appointment to her calendar.

- Just to give a peak at what the client sees, we'll sign in as Zayn.

- present some of the slides; high level
  - reference market size, problem, and solution space
- present , one stylist who exists in the space we just outlined
- she wakes up in the morning and prepares for the day with Armoire; the first thing she does is check her work schedule
- as an independent personal stylist, her work revolves around both in-person appointments and direct communication with her clients
- she opens Armoire, which has kept her logged in through the night
- finds her first appointment is with Tim Face
- jumps onto messaging to confirm appointment; search for Tim
- he wants to go earlier
- she updates the calendar
- she wants to refresh her memory on Tim and goes to his profile
  - notes say he is looking for new job
  - goes on messaging from client workflow -> did you see the new dress shirts I uploaded last week?
    - yes they look perfect, he responds, so we can look for shoes today too? I'm 11 1/2 W.
    - sound great
  - adds to measurements

- sees a new message icon
  - hey can we meet up?
  - checks for meetings, sees only BR
  - checks notes to figure out WTF
  - gets confirmation for time and location for BR
  - creates meeting at BR at the time agreed
  - says it's been added to calendar

- show client workflow quickly

###![Video Walkthrough](151020_ArmoireApp_Walkthrough.gif)
