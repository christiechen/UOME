//
//  ProfilePageViewController.swift
//  U.O.ME
//
//  Created by Jiwoo Seo on 7/21/20.
//  Copyright © 2020 Christie Chen. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Firebase
import FirebaseStorage
import SDWebImage


class ProfilePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let ref = Database.database().reference()
    let uid = FirebaseAuth.Auth.auth().currentUser!.uid
    let storageRef = Storage.storage().reference(forURL: "gs://final-project-591d1.appspot.com/")
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    var currentUserFriends: [String:Double] = [:]
    var currentUserFriendsNames: [String] = []
    var groups:[String] = []
    var currentUserName = ""
    var currentUser = "/friends/"
    var numFriends = 0
    var refreshControl = UIRefreshControl()

    
    
    
    
    //Christie Chen
    override func viewDidLoad() {
        super.viewDidLoad()
        circularProfilePic()
        loadProfileImage()
        
        guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid else { return }
        

        scrollView.contentSize = tableView.contentSize
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
       refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
       tableView.addSubview(refreshControl)

        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none

    
    }
    

    //Christie Chen
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        currentUserFriends = [:]
        currentUserFriendsNames = []
        groups = []
        currentUserName = ""
        currentUser = "/friends/"
        numFriends = 0
        loadCurrentUserData()
        updateResultAll()
    }


    //Jiwoo Seo
    func circularProfilePic() {
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
    }

    //Christie Chen
    override func viewDidAppear(_ animated: Bool) {
        loadProfileImage()
        print("view did appear")
    }
    
    
    //Christie Chen
    override func viewWillAppear(_ animated: Bool) {
        print("willappear")
        currentUserFriends = [:]
        currentUserFriendsNames = []
        groups = []
        currentUserName = ""
        currentUser = "/friends/"
        numFriends = 0
        updateResultAll()
        Data()
    }
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    //Christie Chen
    //loads all data for the current user
    func loadCurrentUserData(){
        
        print ("loading current data")
        let ref = Database.database().reference()
        let test = ref.child("/users/" + uid + "/username").observeSingleEvent(of: .value){
            (snapshot) in
            self.currentUserName = snapshot.value as! String
            self.currentUser = self.currentUser + self.currentUserName
            ref.child("/friends/" + self.currentUserName).observeSingleEvent(of: .value){
                (snapshot) in
                
                let friends = snapshot.value as! [String:Any]
                self.numFriends = 0
                
                let friendNames = friends.keys
                print(self.numFriends)
                for name in friendNames{
                    print(name)
                    if(name == "default"){
                        continue
                    }
                    self.currentUserFriends[name] = friends[name] as! Double
                    self.currentUserFriendsNames.append(name)
                    self.numFriends = self.numFriends + 1
                }
                print(self.currentUserFriends)
                self.tableView.reloadData()
            }
        }
    }
    
    //Jiwoo Seo
    func loadProfileImage() {
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let username = value?["username"] as? String ?? ""
            let profilePicURL = value?["profilePicURL"] as? String ?? ""
            let fileUrl = URL(string: profilePicURL)
            // UIImageView in your ViewController
           
            let placeholderImage = UIImage(named: "noPhoto")
            // Load the image using SDWebImage
            self.profileImageView.sd_setImage(with: fileUrl, placeholderImage: placeholderImage)
            self.usernameLabel.text = username
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }
    //Jiwoo Seo
    @IBAction func logOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavigationController")

        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(numFriends)
        return numFriends
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseCell")! as UITableViewCell
        
        let subviews = cell.subviews
        for view in subviews{
            view.removeFromSuperview()
        }
        
        print(currentUserFriends)
        let sortedFriends = currentUserFriends.sorted(by: <)
        print(numFriends)
        print(indexPath.row-1)
        let name = sortedFriends[indexPath.row].key
        let price = sortedFriends[indexPath.row].value
        let priceFormatted = String(format: "%.2f", price)
        
        
        cell.backgroundColor = UIColor(red: 0.85, green: 0.92, blue: 0.91, alpha: 1.00)
        cell.layer.borderColor = CGColor.init(srgbRed: 1, green: 1, blue: 1, alpha: 1)
        cell.layer.borderWidth = 2
        
        cell.layer.cornerRadius = 10
        
        let friendFrame = CGRect(x:10, y:0, width:100, height: cell.frame.height)
        let friendLabel = UILabel(frame: friendFrame)
        friendLabel.text = name
        cell.addSubview(friendLabel)
        
        let priceFrame = CGRect(x:225, y: -3, width:100, height: 50)
        let priceLabel = UILabel(frame: priceFrame)
        priceLabel.text = priceFormatted
        cell.addSubview(priceLabel)
        
        let img = CGRect(x:190, y:12, width:20, height: 20)
        let imgView = UIImageView(frame:img)
        imgView.image = UIImage(named: "money")
        cell.addSubview(imgView)

        cell.textLabel?.text = name + currentUserFriends[name]!.description
        

        
        return cell
        
        
    }
    
    
    //Christie Chen
    //with every refresh, searches the database and updates how much the current user owes all their friends
    //individually/ how much each friend individually owes the current user.
    //The if the user has already paid their friend/ has already been paid, the amount owed updates to reflect such
    func updateResultAll(){
             
             let ref = Database.database().reference()
             
             groups = []
//             get all the groups and parse through them
             ref.child("/groupData").observeSingleEvent(of: .value){
                 (snapshot) in
                 let data = snapshot.value as! [String:[String:Any]]
                 let dataKeys = data.keys //groups
                var payData: [String: [String: Double]] = [:]

                 //for every group
                 for keys in dataKeys{
                     let people = data[keys]?["people"] as! String

                    var receiptList: [String:[String:String]] = [:]

                     
                     //set group members
                     let groupMembers = people.components(separatedBy: ", ")
                     if(data[keys]?["receipts"] == nil){
                         continue
                     }

                     
                     let allReceipts = data[keys]?["receipts"] as! [String:[String:Any]]
                     
                     //all the individual receipts
                     let receiptNumbers = allReceipts.keys
                     var count = 0 //how many receipts have been processed thus far
                     for receipt in receiptNumbers{
                    
                        //for each receipt:
                         ref.child("/groupData/" + keys + "/receipts/" + receipt).observeSingleEvent(of: .value){
                             (snapshot) in
                             let value = snapshot.value as! [String:Any]

                            let hasPayed = value["payed"] as! [String:String]
                            let processed = value["processed"] as! String
                            receiptList[receipt] = hasPayed
                            receiptList[receipt]!["generalProcess"] = processed
                            for (name, payed) in hasPayed{
                                receiptList[receipt]![name] = payed
                            }
                         }
                         count = count + 1

                         if( count == receiptNumbers.count){ //all receipts saved
                                             //get everyone's original owed values

                                 for member in groupMembers{

                                     ref.child("/friends/" + member).observeSingleEvent(of: .value){
                                        (snapshot) in
                                         
                                         let friendsList = snapshot.value as! [String:Double]
                                         let friendKeys = friendsList.keys
                                         var allFriends: [String:Double] = [:]
                                             for friendName in friendKeys{

                                                if(friendName == "default"){
                                                    continue
                                                }
                                                 allFriends[friendName] = friendsList[friendName]

                                             }
                                         payData[member] = allFriends

                                         if(member == groupMembers.last){ //payData is finalized
                                             for receipt in receiptList.keys{
                                                 ref.child("/groupData/" + keys + "/receipts/" + receipt).observeSingleEvent(of: .value){
                                                     (snapshot) in
                                                     let receiptInfo = snapshot.value as! [String:Any]
                 
                                                     let payedBy = receiptInfo["payedBy"] as! String
                
                                                     let priceSplit = receiptInfo["priceSplit"] as! Double
                 

                                                         for member in groupMembers{
                 
                 
                                                             if(member == payedBy){ //everyone owes this person money, updates all fields in the person's friends list

                                                                 let friends = payData[member]!.keys
                                                                 for friend in friends{ //go through friends again and update all values
                                                                    if(!groupMembers.contains(friend)){

                                                                        continue
                                                                    }

                                                                   if(receiptList[receipt]![friend] == "false" && receiptList[receipt]!["generalProcess"] == "false"){ //friend still has to pay and the receipt has not even been processed
                  

                                                                        var origOwed = payData[member]![friend]!
                                                                        var newOwed = origOwed - priceSplit


                                                                        payData[member]![friend] = newOwed

                                                                        
                                                                    }
                                                                   else if(receiptList[receipt]![friend] == "true" && receiptList[receipt]!["generalProcess"] == "true"){ //the receipt has been processed (so initial values are in) and the friend has paid
                    
                                                                        var origOwed = payData[member]![friend]!
                                                                        var newOwed = origOwed + priceSplit //this expense is removed
                
                                                                        payData[member]![friend] = newOwed
                                                                    }
                                                                    
                                                                }
                                                             }
                                                         else{ //this member owes someone else money, updates the single field in that person's friends list
                                                                let friends = payData[member]!.keys
                                                                if(!friends.contains(payedBy)){
                                                                    continue
                                                                }

                                                                if(receiptList[receipt]![member] == "false" && receiptList[receipt]!["generalProcess"] == "false"){ //friend still has to pay and the receipt needs to be processed
                                                                    var origOwed = payData[member]![payedBy]!

                                                                    var newOwed = origOwed + priceSplit
                                                                    payData[member]![payedBy] = newOwed

                                                                }
                                                                
                                                                else if(receiptList[receipt]![member] == "true" && receiptList[receipt]!["generalProcess"] == "true"){  //the receipt has been processed (so initial values are in) and the friend has paid
                                                                     var origOwed = payData[member]![payedBy]!
                                                                    var newOwed = origOwed - priceSplit
                                                                    payData[member]![payedBy] = newOwed
                                                                }

                                                             }
                                                         }

                                                         for person in payData.keys{
                                                             for friend in payData[person]!.keys{
                                                                 ref.child("/friends/" + person + "/" + friend).setValue(payData[person]![friend]!)

                                                                

                                                             }
                                                            if(person == self.currentUserName){
                                                                for friend in payData[person]!.keys{
                                                                self.currentUserFriends[friend] = payData[person]![friend]!
                                                                }

                                                            }
                                                            self.tableView.reloadData()

                                                         }
                                                    for hasPayedGroupMember in receiptList[receipt]!.keys{
                                                        print(hasPayedGroupMember)
                                                        print(receiptList[receipt]![hasPayedGroupMember])
                                                        if(hasPayedGroupMember == "generalProcess"){
                                                            continue
                                                        }
                                                        if(receiptList[receipt]![hasPayedGroupMember] == "true"){
                                                            ref.child("/groupData/" + keys + "/receipts/" + receipt + "/payed/" + hasPayedGroupMember).setValue("paid") //updates everything to true if the person has payed and everything has been processed
                                                        }
                                                    }

                                                 }
                                                ref.child("/groupData/" + keys + "/receipts/" + receipt + "/processed").setValue("true")

                                                         
                             
                                                     }
                             
                                                 }
                                             }
                                        }
                             
                         }
                     }


             }
         }
                self.loadCurrentUserData()
                self.tableView.reloadData()
                refreshControl.endRefreshing()

     }

    
   
    @IBAction func addFriends(_ sender: Any) {
        self.performSegue(withIdentifier: "findFriends", sender: self)
    }
    
}

