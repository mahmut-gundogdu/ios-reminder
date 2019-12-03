//
//  ViewController.swift
//  com.mahmutgundogdu.remider
//
//  Created by Macbook on 3.12.2019.
//  Copyright © 2019 Mahmut Gundogdu. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {

    @IBOutlet weak var btnStartStop: UIButton!
    @IBOutlet weak var timeLabel: UITextField!
    
    @IBOutlet weak var circleProgressView: CircleProgressView!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .short
        
        // Do any additional setup after loading the view.
        if let finishTime = getStartTime(){
            timeLeft = finishTime.timeIntervalSinceNow
            if(timeLeft >  0 ){
                resume()
                updateData()
            }
        }
    }
    var status:TimerStatus = .stopped
    var timer: Timer?
    let totalTime = 30.0 * 60 // minutes
    var timeLeft = 0.0
    let formatter = DateComponentsFormatter()
 
    
    @IBAction func BtnClick(_ sender: UIButton) {
         if(status == .started ){
             stop()
        }
        else {
            start()
        }
        
    }
 
    @objc func onTimerFires()
    {

        updateData()
        
        if timeLeft <= 0 {
            stop()
        }
    }
    func updateData(){
        timeLeft -= 1
        let progress = (timeLeft / totalTime)
        timeLabel.text = intervalToTime(interval: timeLeft)
        
        circleProgressView.progress = progress
    }
    
    func stop(){
        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: [pushNotificationIdentifier])
        
        btnStartStop.setTitle("Start", for: .normal )
        circleProgressView.progress = 0
        timeLabel.text = "Süre Doldu"
        timeLeft = 0
        timer?.invalidate()
        timer = nil
        status  = .stopped;
        deleteStartTime()
    }
    
    func start (){
    
        timeLeft = Double(totalTime)
        resume()
       
    }
    
    func resume(){
        if let text = intervalToTime(interval: (timeLeft)) {
            timeLabel.text = text
        }
        circleProgressView.progress = 1
        btnStartStop.setTitle("Stop", for: .normal )
        
        startTimer()
        fireLocalNotification()
        status  = .started
        let date = Date().addingTimeInterval(totalTime)
        
        saveStartTime(date: date)
    }
    
    func fireLocalNotification(){
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
        
        let content = UNMutableNotificationContent()
      
        let time:String = getTimeFromFinishDate()
        content.title =  "Süre \(time) de doldu"
        content.body =  "Yemek yiyebilir veya içebilirsin."
        
        
        // Deliver the notification in five seconds.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: totalTime, repeats: false)
        
        let request = UNNotificationRequest(identifier: pushNotificationIdentifier, content: content, trigger: trigger) // Schedule the notification.
        
        center.add(request) { (error : Error?) in
            if let theError = error {
                print(theError)
            }
        }
    }
    let pushNotificationIdentifier:String = "30Minutes"
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
    }

    func intervalToTime(interval:Double?) -> String?{
        if let safeInterval = interval {
            let formattedString = formatter.string(from: TimeInterval(safeInterval))
            return formattedString
        }
        return nil
    }
    
    let storageKeyName:String = "startTime"
    func saveStartTime(date:Date){
        print(date)
         UserDefaults.standard.set(date, forKey: storageKeyName)
    }
    
    func deleteStartTime(){
        UserDefaults.standard.removeObject(forKey: storageKeyName)
    }
    
    func getStartTime() -> Date?{
       return  UserDefaults.standard.object(forKey: storageKeyName) as? Date
    }
    func getTimeFromFinishDate() -> String{
        
       let finishDate:Date? = getStartTime()
        guard finishDate != nil else {
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.string(from: finishDate!)
    }
    
   
}

