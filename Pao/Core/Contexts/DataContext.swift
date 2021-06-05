//
//  DataContext.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/8/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation
import Firebase
import Payload

import RocketData

class DataContext {
    static let cache = DataContext()
    
    // MARK: - Internal properties
    
    var user: User!
    var categories: [Category]?
    
    // MARK: - Lifecycle
    
    private init() { }
    
    // MARK: - Internal methods
    
    func load() {
        loadUser()
        loadCategories()
    }
    
    func loadUser() {
        
        if !App.transporter.isTokenThere, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.refreshToken { [weak self] isSuccess in
                guard let self = self, isSuccess else { return }
                self.getUser()
            }
        } else {
            getUser()
        }
    }
    
    func loadCategories() {
        bfprint("-= SOS =- loadCategories")
        
        let url = App.transporter.getUrl([Category].self, httpMethod: .get)
        APIManager.callAPIForWebServiceOperation(model: Category(), urlPath: url, methodType: "GET") { (apiStatus, result: [Category]?, responseObject, statusCode) in
            if(apiStatus){
                if let result = result  {
                    self.categories = result
                }
            }else{
                print("-= PN =- Something went wrong, Please try again later.")
            }
        }
        /*
         DataContext.categories.getDocument { (documentSnapshot, error) in
         guard let document = documentSnapshot, document.data() != nil else {
         print("Error fetching document: \(error!)")
         return
         }
         
         self.categories = try! document.convert(CategoriesDictionary.self)
         }
         */
    }
    
    func updateBoard(board: Board) {
        //        if let spotsCount = board.spotsCount, spotsCount > 0 {
        //            DataModelManager.sharedInstance.updateModel(board)
        //        } else {
        //            DataModelManager.sharedInstance.deleteModel(board)
        //        }
        //
        //        if let parentBoardId = board.parentBoardId {
        //            App.transporter.get(Board.self, pathVars: parentBoardId) { (board) in
        //                if let board = board {
        //                    self.updateBoard(board: board)
        //                }
        //            }
        //        }
        
        //TEMP SOLUTION / HACK
        NotificationCenter.default.post(name: .newSpotUploaded, object: nil)
    }
    
    // Modified this function which was storing mypeople Id's previously so now it will store the whole object of mypeople.
    func addToMyPeople(userObj: User) {
        guard let userId = userObj.id else { return }
        
        let users = self.user.myPeople?.filter({ $0.id == userId })
        if users?.count ?? 0 > 0 {} else {
            if self.user.myPeople == nil {
                self.user.myPeople = []
            }
            self.user.myPeopleCount? += 1
            self.user.myPeople?.append(MyPeopleUser(user: userObj))
        }
    }
    
    // Passed the unfollowed user object and remove it from the logged in user myPeople array.
    func removeFromMyPeople(userObj: User) {
        guard let userId = userObj.id else { return }
        
        let users = self.user.myPeople?.filter({ $0.id == userId })
        if users?.count ?? 0 > 0 {
            if let index = self.user.myPeople!.firstIndex(where: { $0.id == userId }) {
                self.user.myPeopleCount? -= 1
                self.user.myPeople?.remove(at: index)
            }
        }
    }
    
    func isSelectedInMyPeople(userId: String?) -> Bool {
        guard let userId = userId else { return false }
        
        let users = self.user.myPeople?.filter({ $0.id == userId })
        if users?.count ?? 0 > 0 {
            return true
        }
        return false
    }
    
    // MARK: - Private methods
    
    private func getUser() {
        bfprint("-= SOS =- getUser")
        
        let params = UserGMTParams(gmt: TimeZone.offsetStringFromGMT)
        let url = App.transporter.getUrl(User.self, for: nil, httpMethod: .get, queryParams: params)
        APIManager.callAPIForWebServiceOperation(model: User(), urlPath: url, methodType: "GET") { (apiStatus, user: User?, responseObject, statusCode) in
            if(apiStatus){
                if user != nil {
                    let dataProvider = DataProvider<User>()
                    dataProvider.setData(user)
                    
                    self.user = user
                    
                    AmplitudeAnalytics.setUserProperties(user: user)
                } else {
                    if DataContext.cache.user == nil {
                        //TODO: This needs to be well tested before re-enabled.
                        //NotificationCenter.default.post(name: .userUpdateError, object: nil)
                    }
                }
                
                //HACK: loadUser gets called when endpoints don't have fid
                if DataContext.cache.user != nil {
                    NotificationCenter.default.post(name: .initialDataLoaded, object: nil)
                    NotificationCenter.default.post(name: .userUpdate, object: nil)
                    self.setCrashlyticUserIdentifiers()
                }
            }else{
                print("-= PN =- Something went wrong, Please try again later.")
            }
        }
    }
    
    private func setCrashlyticUserIdentifiers() {
        guard let uid = DataContext.cache.user.id else { return }
        Crashlytics.crashlytics().setUserID(uid)
    }
}

extension DataContext {
    static var randomId: String {
        return Firestore.firestore().collection("ids").document().documentID
    }
    
    static var userUID: String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    static var userEmail: String {
        return Auth.auth().currentUser?.email ?? ""
    }
    
    static var users: CollectionReference {
        return Firestore.firestore().collection(DataCollections.users.rawValue)
    }
    
    static var user: DocumentReference {
        return users.document(userUID)
    }
    
    static var userSettings: DocumentReference {
        return Firestore.firestore().collection(DataCollections.userSettings.rawValue).document(userUID)
    }
    
    static var userSpots: Query {
        return spots.whereField("userId", isEqualTo: userUID)
    }
    
    static var spots: CollectionReference {
        return Firestore.firestore().collection(DataCollections.spots.rawValue)
    }
    
    static var incompleteSpots: CollectionReference {
        return Firestore.firestore().collection(DataCollections.incompleteSpots.rawValue)
    }
    
    static var userFeed: CollectionReference {
        return user.collection("userFeed")
    }
    
    static var notifications: CollectionReference {
        return user.collection(DataCollections.notifications.rawValue)
    }
    
    static var categories: DocumentReference {
        return Firestore.firestore().document("configurations/categories")
    }
    
    static var metadata: CollectionReference {
        return user.collection("metadata")
    }
    
    static var saveBoards: Query {
        return Firestore.firestore().collection("saveBoards")
    }
    
    static var uploadBoards: Query {
        return Firestore.firestore().collection("uploadBoards")
    }
    
    
    static var userSaveBoards: Query {
        return Firestore.firestore().collection("saveBoards").whereField("user.id", isEqualTo: userUID)
    }
    
    static var userUploadBoards: Query {
        return Firestore.firestore().collection("uploadBoards").whereField("user.id", isEqualTo: userUID)
    }
}
