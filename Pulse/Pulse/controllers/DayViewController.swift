//
//  DayViewController.swift
//  Pulse
//
//  Created by Team Pulse on 11/30/18.
//  Copyright © 2018 Team Pulse. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class DayViewController: UIViewController, UIScrollViewDelegate, UITableViewDataSource{
    // DEFINE OUTLETS FOR DAY VIEW
    var backgroundColor: UIColor!
    @IBOutlet weak var viewer: UIView!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var dayTitle: UINavigationItem!
    @IBOutlet var zipLabel: UILabel!
    
    // VARIABLES PASSED THROUGH
    var maxTemp: String!
    var minTemp: String!
    var zip: String! 
    var rows: Int!
    var moodArr: [Mood] = []
    

    
    // this viewcontroller was created programmatically so several lines of formatting included
    // everything called in viewdidload so it loads every time user pulls up the movie details
    override func viewDidLoad() {
        super.viewDidLoad()
        // sets background color, text labels, and zip code (all passed in loggedInController)
        viewer.backgroundColor = backgroundColor
        maxTempLabel.text = maxTemp
        minTempLabel.text = minTemp
        zipLabel.text = "Zip Code: " + "\(zip!)"

        tableView.dataSource = self
        // sets the date on the title
        if moodArr.count > 0 {
            let date = moodArr[0].dateTime!
            let dateString = ("\(date)")
            // basic date formatting
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMM d"
            if let date = dateFormatterGet.date(from: dateString) {
                dayTitle.title = dateFormatterPrint.string(from: date)
                print(dateFormatterPrint.string(from: date))
            } else {
                print("There was an error decoding the string")
            }
            
        }

    }
    override func viewWillAppear(_ animated: Bool) {
//        self.populateData()
    }
    

    // # of rows in section for table view is just length of the moodArr
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moodArr.count
    }
    // table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")!
        
        let val = moodArr[indexPath.row].value
        let time = moodArr[indexPath.row].dateTime!
        var cleanDate: String!
        
        
        let timeString = ("\(time)")
        // formatting date for the time a mood was logged
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM d, h:mm a"

        if let date = dateFormatterGet.date(from: timeString) {
            cleanDate = dateFormatterPrint.string(from: date)
        } else {
            print("There was an error decoding the string")
        }
        
        // filling list of previous moods
        switch val {
        case 0:
            cell.textLabel?.text = "☹️ recorded on: " + "\(cleanDate!)"
        case 1:
            cell.textLabel?.text = "😐 recorded on: " + "\(cleanDate!)"
        case 2:
            cell.textLabel?.text = "😃 recorded on: " + "\(cleanDate!)"
        default:
            print("nada exists in this jawn")
        }
        
        return cell
    }
    
    
    // back button takes you home 
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLayoutSubviews() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
