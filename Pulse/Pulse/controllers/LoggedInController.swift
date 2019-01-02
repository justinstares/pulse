//
//  LoggedInController.swift
//  Pulse
//
//  Created by Team Pulse on 11/9/18.
//  Copyright © 2018 Team Pulse. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreLocation

class LoggedInController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate  {
    
    
    // outlet variables
    @IBOutlet var dayHeadingStack: UIStackView!
    @IBOutlet var greetingLabel: UILabel!
    @IBOutlet var sadButtonOutlet: UIButton!
    @IBOutlet var neutralButtonOutlet: UIButton!
    @IBOutlet var happyButtonOutlet: UIButton!
    @IBOutlet var emotionStackView: UIStackView!
    @IBOutlet var calendarJawn: UICollectionView!
    @IBOutlet var monthLabel: UILabel!
    @IBOutlet var totalLogs: UILabel!
    @IBOutlet var lastLogLabel: UILabel!
    //appDelegate for reminders
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    
// LOCATION SERVICES MANAGEMENT
    // instantiate location variable
    let locationMgr = CLLocationManager()
    // fetch current location (starts the chain to ask for and get user location)
    func fetchCurrLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .denied || authStatus == .restricted {
            print("\nlocation restricted")
            presentLocationNotification()
            return
        } else if authStatus == .notDetermined {
            setCode(postCode: "94105")
            print("\nlocation not determined")
            locationMgr.requestWhenInUseAuthorization()
            return
        } else {
            print("\nstarting update location...")
            locationMgr.delegate = self
            locationMgr.startUpdatingLocation()
        }
        return
    }
    // loc notification presents to user
    func presentLocationNotification() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "To view local weather, change your preferences.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    // finds zipcode
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("\nstarting location manager...")
        let lastLoc = locations.last!
        convertLocPlacemark(location: lastLoc) { (placeMarker) -> () in
            let postCode = placeMarker?.postalCode
//            print(String(postCode!))
            self.setCode(postCode: postCode!)

        }
    }
    
    var postal = ""
// sets your zip code
    func setCode(postCode: String) {
        postal = postCode
//        let alert = UIAlertController(title: "Updated Current Location", message: "Your Zip Code is \(String(postCode))", preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//
//        self.present(alert, animated: true)
    }
// final location stub, stops updating location when done
    func convertLocPlacemark(location: CLLocation, completionHandler: @escaping (CLPlacemark?) -> ()) {
        print("\nconversion function successfully called")
        let geo = CLGeocoder()
        geo.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            if error == nil {
                print("\nconversion received no error")
                completionHandler(placemarks?[0])
            } else {
                print("\nconversion received error: \(String(describing: error))")
                completionHandler(nil)
            }
        })
        locationMgr.stopUpdatingLocation()
    }
// error case or location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: "Uh-oh", message: "Something went wrong while trying to retrieve your location.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        let retryAction = UIAlertAction(title: "Retry", style: .default, handler: {(action: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
//            self.getTaxInfo(nil)
        })
        alert.addAction(retryAction)
        present(alert, animated: true, completion: nil)
    }

// END OF LOCATION MANAGEMENT
    
    
    // data management variables
    var monthData = [Int: LogDay]()
    var currDate = Date()
    var currMonth = Date()
    var currCal = Calendar.current
    var numDaysInMonth: Int {
        return (currCal.range(of: .day, in: .month, for: currDate)?.count)!
    }
// advances calendar by one month
    @IBAction func nextButton(_ sender: Any) {
        // adds one month to curr date
        currDate = currCal.date(byAdding: .month, value: +1, to: currDate)!
        reloadLabels()
        self.calendarJawn.reloadData()
        self.view.screenLoading()
// fetch curr dates
        let month = currCal.component(.month, from: currDate)
        let year = currCal.component(.year, from: currDate)
// fetch moods from newly designated month and fill month data
        User.moodsFromMonth(year, month, postal) { s in
            guard let x: [Int: LogDay] = s else { return }
            self.monthData = x
            self.calendarJawn.reloadData()
            // run loading screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.view.screenLoaded()
            }
        }
    }
 // same as next date but for previous month
    @IBAction func prevButton(_ sender: Any) {
        currDate = currCal.date(byAdding: .month, value: -1, to: currDate)!
        reloadLabels()
        self.calendarJawn.reloadData()
        self.view.screenLoading()
        
        let month = currCal.component(.month, from: currDate)
        let year = currCal.component(.year, from: currDate)
        User.moodsFromMonth(year, month, postal) { s in
            guard let x: [Int: LogDay] = s else { return }
            self.monthData = x
            self.calendarJawn.reloadData()
            // run loading screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.view.screenLoaded()
            }
        }
    }
// holds moods for a particular day
    var dayArr: [Mood] = []
// holds weather api results
    var weatherResults: Weather? = nil
    // e.g. if the first of the month is a Thursday, startingWeekdayIndexed = 4
    var startingWeekdayIndexed: Int {
        var dc = DateComponents()
        dc.year = currCal.component(.year, from: currDate)
        dc.month = currCal.component(.month, from: currDate)
        return currCal.component(.weekday, from: currCal.date(from: dc)!) - 1
    }
    
    // to settings
    @IBAction func goSettings(_ sender: Any) {
        self.navigationController?.pushViewController(UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "settings"), animated: true)
    }
// runs on view did load
    override func viewDidLoad() {
        // populate initial variables
        super.viewDidLoad()
        self.populateLocalUser()
        self.setupButtons()
        self.setupCellConstraints()
        calendarJawn.delegate = self
        calendarJawn.dataSource = self
        reloadLabels()
        startReminding()
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        // initialize periodic refreshes
        
        fetchCurrLocation()
        // checks to see if location has been authorized or not
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationMgr.requestWhenInUseAuthorization()
        }
    }
    
    // necessary for signup flow (since onboarding profile form blocks data)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !(isBeingPresented || isMovingToParentViewController) {
            self.populateLocalUser()
        }
        startReminding()
        self.reloadLabels()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "key"), object: nil, queue: .main) { (notification) in
            print("recieved info as Oberserver")
            self.reloadLabels()

        }
    }
    // notification stub to get started
    func startReminding(){
        print("trying to start reminding")
        appDelegate?.scheduleNotification()
    }
    
    // set the names for a user object if we need to
    /**
     Populates the static User object names if necessary, using the flow specified in Discussion section
        - if User.firstName.exists, just reload the labels
        - else if remote database has User.firstName, populate User object with names and reload labels
        - else prompt user for names, then reload labels via viewWillAppear
    */
    func populateLocalUser() {
        if User.firstName == nil {
            self.view.screenLoading()
            // getNamesFromID checks firebase for name info and sets the User static variables firstName and lastName
            User.getNamesFromID((Auth.auth().currentUser?.uid)!) { success in
                if success {
                    // User is successfully updated, so reload the labels accordingly
                    self.reloadLabels()
                } else {
                    self.view.screenLoaded()
                    // present profile form
                    let p = UIStoryboard(name: "OnboardingTest", bundle: nil).instantiateViewController(withIdentifier: "profile")
                    p.modalTransitionStyle = .coverVertical
                    self.present(p, animated: true, completion: nil)
                }
            }
        } else {
            reloadLabels()
        }
    }
    // reload all labels
    func reloadLabels() {
        greetingLabel.text = Messages.getWelcome()
        monthLabel.text = Calendar.current.monthSymbols[Calendar.current.component(.month, from: currDate) - 1]
        User.totalLogs { result in self.totalLogs.text = result < 0 ? "?" : String(result) }
        Messages.getLastLog() { m in self.lastLogLabel.text = m }
        self.getCalendarIfNeeded() { self.view.screenLoaded() }
    }
    
    /**
     Reloads calendar data for month, getting data from server if necessary
         */
    func getCalendarIfNeeded(_ completion: @escaping () -> Void) {
        if monthData.count > 0 {
            self.calendarJawn.reloadData()
            completion()
            return
        }
        
        let month = currCal.component(.month, from: currDate)
        let year = currCal.component(.year, from: currDate)
        
        User.moodsFromMonth(year, month, postal) { s in
            completion()
            guard let x: [Int: LogDay] = s else { return }
            self.monthData = x
            self.calendarJawn.reloadData()
        }
    }
    // fill the array of your data
    func fillDayArr(day: Int) -> [Mood] {
        if monthData[day] != nil {
            dayArr = (monthData[day]?.moods!)!
            return dayArr
        }
        // empty day arr if not
        dayArr = []
        return dayArr
    }
    // define a mood
    @objc func registerMood(_ sender: UIButton) {
        currDate = Date()
        // defines a mood passes in necessary aprams (value, date, zip)
        let m = Mood(sender.tag - 60, Date(), postal)
        self.view.screenLoading()
        
        m.upload({ b in
            if !b {
                // TODO: alert upload error
            }
        }, { b in
            if b {
                // append mood to month data arr
                let dayInt = self.currCal.component(.day, from: self.currDate)
                let d = self.monthData[dayInt]
                d?.moods.append(m)
                print(self.monthData[dayInt]?.moods[0].zipCode)
     // no longer necessary snip
//                if let d = self.monthData[dayInt] {
//                    print("INHEREEEE")
//                    d.moods.append(m)
//                } else {
//                    let d = LogDay()
//                    print(d)
//                    d.moods.append(m)
//                    self.monthData[dayInt] = d
//                }
                self.reloadLabels()
            } else {
                // TODO: alert update error
            }
        })
    }
    
    // instantiate mood buttons
    func setupButtons() {
        sadButtonOutlet.imageView?.contentMode = .scaleAspectFit
        neutralButtonOutlet.imageView?.contentMode = .scaleAspectFit
        happyButtonOutlet.imageView?.contentMode = .scaleAspectFit
        
        for b:UIButton in [sadButtonOutlet, neutralButtonOutlet, happyButtonOutlet] {
            b.addTarget(self, action: #selector(registerMood(_:)), for: .touchUpInside)
        }
    }
    
    /// self-explanatory - but sets constraints
    func setupCellConstraints() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let size: CGFloat = floor((calendarJawn.frame.width - 12) / 7)
        layout.itemSize = CGSize(width: size, height: size)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        calendarJawn.collectionViewLayout = layout
    }
    
    
// num items in the collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 35
    }
// sets light gray and regular gray for eligible items in that month's calendar
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = calendarJawn.dequeueReusableCell(withReuseIdentifier: "calendarDay", for: indexPath) as! CalendarCell
        let lastDayIndex = startingWeekdayIndexed + numDaysInMonth - 1
        cell.backgroundColor = (startingWeekdayIndexed ... lastDayIndex).contains(indexPath.row) ? UIColor(rgb: 0xe7e7e7) : UIColor(rgb: 0xf0f0f0)
        guard let day = self.monthData[indexPath.row-(startingWeekdayIndexed-1)] else { return cell }
        cell.backgroundColor = day.color()
        cell.log = day
        return cell
    }
    var tempPostal = ""
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // sets the selected date and following date (paramters for the weather api)
        let selectedDate = "\(currCal.component(.year, from: currDate))" + "-" + "\(currCal.component(.month, from: currDate))" + "-" + "\(indexPath.row-(startingWeekdayIndexed-1))"
        
        let nextDay = "\(currCal.component(.year, from: currDate))" + "-" + "\(currCal.component(.month, from: currDate))" + "-" + "\(indexPath.row-(startingWeekdayIndexed-2))"
        
        let m = currCal.component(.month, from: currDate)
        
// THESE CONDITIONALS PREVENT FROM CLICKING OUTSIDE OF DOMAIN
        if(currCal.component(.month, from: currMonth) > currCal.component(.month, from: currDate)) {
            print("prevents clicking from future months")
            return
        }
        if (self.monthData[indexPath.row-(startingWeekdayIndexed-1)]?.moods.count) == nil {
            print("this is nil")
            return
        }
        if((indexPath.row-(startingWeekdayIndexed-1) > currCal.component(.day, from: currDate)) && currCal.component(.month, from: currMonth) == m) {
            print ("this date is out of range")
            return
        }
        if((indexPath.row-(startingWeekdayIndexed))<0) {
            print("also out of range")
            return
        }


        else {

        do{
        // gathers current location
        fetchCurrLocation()
        // gets the zip code for that specific day
         tempPostal = (self.monthData[indexPath.row-(startingWeekdayIndexed-1)]?.moods[0].zipCode)!
         print(tempPostal)
            // if could not find location, set it to default (default is San Francisco) this sometimes occurs on your first attempt
            if tempPostal == "" {
                print("it null")
                tempPostal = "94108"
            }
        // makes api call passing along the relevant dates and zip
            let url = URL(string: "https://api.weatherbit.io/v2.0/history/daily?postal_code=" + "\(tempPostal)" + "&country=US&start_date=" + "\(selectedDate)" + "&end_date=" + "\(nextDay)" + "&units=I&key=0d89f91dbfe44f9591d38429d21110e3")
            // stores results of the api call
            print(url)
            let info = try Data(contentsOf: url!)
            self.weatherResults = try! JSONDecoder().decode(Weather.self, from: info)
        }
        catch{
            self.weatherResults = nil
        }
        
        let data = weatherResults?.data
        
            
        
            
        // set max and min temps
        let maxTempValue = "High Temp: " + "\(data![0].max_temp!)" + "°"
        let minTempValue = "Low Temp: " + "\(data![0].min_temp!)" + "°"
        // create new storyboard for day view
        let storyboard = UIStoryboard(name: "DayView", bundle: nil)
        // passes variables to day view controller
        let vc = storyboard.instantiateViewController(withIdentifier: "dayview") as! DayViewController
        vc.backgroundColor = UIColor.clear
        vc.maxTemp = maxTempValue
        vc.minTemp = minTempValue
        vc.zip = tempPostal
        // passes mood arr over
        vc.moodArr = fillDayArr(day: indexPath.row-(startingWeekdayIndexed-1))

        self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
