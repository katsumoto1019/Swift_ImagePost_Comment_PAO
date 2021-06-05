//
//  Endpoints.swift
//  Pao
//
//  Created by Parveen Khatkar on 30/10/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation


class Endpoint: EndpointProtocol {
    var apiUrl: URL { return Bundle.main.apiUrl }
    
    let segments: [Segment] = [
        
        //Version Check
        Segment("api", modelType: ApiVersion.typeName, httpMethods: [.get]),

        // Account
        Segment("admin/user/exists", modelType: AccountTaken.typeName),
        Segment("accounts", modelType: Account.typeName, httpMethods: [.post]),
        
        // User
        Segment("me", modelType: User.typeName, httpMethods: [.get, .delete]),
        Segment("v2/me", modelType: User.typeName, httpMethods: [.post]),
        Segment("me/profile", modelType: UserProfile.typeName, httpMethods: [.post]),
        
        Segment("users", modelType: [User].typeName),
        Segment("users/v2", modelType: [User].typeName, controllerType: PeopleSearchCollectionViewController.typeName),
        Segment("users/%@", modelType: User.typeName, controllerType: UserProfileViewController.typeName),
        
        Segment("following", modelType: [User].typeName, controllerType: FollowingsTableViewController.typeName),
        
        Segment("spots/%@/savers", modelType: [User].typeName, controllerType: SaversTableViewController.typeName),
        Segment("spots/%@/reactersAndSavers", modelType: ReactersAndSaversDictionary.typeName, controllerType: SpotUsersViewController.typeName),
        Segment("users/tag", modelType: [User].typeName, controllerType: TagsDataSource.typeName),
    
        Segment("follow", modelType: User.typeName, action: FollowAction.follow, httpMethods: [.post]),
        Segment("unfollow", modelType: User.typeName, action: FollowAction.unfollow, httpMethods: [.post]),
        
        Segment("accept", modelType: FollowRequest.typeName, action: FollowAction.accept, httpMethods: [.post]),
        Segment("reject", modelType: FollowRequest.typeName, action: FollowAction.reject, httpMethods: [.post]),
        
        // Location
        Segment("location", modelType: MyPlace.typeName, httpMethods: [.put]),
        Segment("locations/related", modelType: LocationSearch.typeName),
        Segment("locations", modelType: [Location].typeName),
        Segment("locations/v2", modelType: [Location].typeName,  controllerType: LocationsSearchCollectionViewController.typeName),
        Segment("countries", modelType: [Location].typeName,controllerType: CountriesTableViewController.typeName),
        Segment("cities", modelType: [Location].typeName,controllerType: CitiesTableViewController.typeName),

        
        // Spot
        
        // Update spot
        Segment("spots/%@", modelType: Spot.typeName, httpMethods: [.put, .delete]),
        // New spot
        Segment("spots", modelType: Spot.typeName, httpMethods: [.post]),
        
        Segment("spot?spotId=%@", modelType: Spot.typeName, httpMethods: [.get]),
        Segment("spots", modelType: [Spot].typeName, httpMethods: [.get]),
        Segment("spots/v2", modelType: [Spot].typeName, controllerType: SpotsSearchCollectionViewController.typeName, httpMethods: [.get]),
        Segment("feed", modelType: [Spot].typeName, controllerType: SpotsViewController.typeName),
        Segment("feed?type=1", modelType: [Spot].typeName, controllerType: SpotsFeedViewController.typeName),
        
        Segment("spots/save", modelType: Spot.typeName, action: SpotAction.save, httpMethods: [.post]),
        Segment("spots/unsave", modelType: Spot.typeName, action: SpotAction.unsave, httpMethods: [.post]),

        Segment("spots/favorite", modelType: Spot.typeName, action: SpotAction.favorite, httpMethods: [.post]),
        Segment("spots/unfavorite", modelType: Spot.typeName, action: SpotAction.unfavorite, httpMethods: [.post]),

        Segment("spots/%@/comments", modelType: [Comment].typeName),
        Segment("spots/%@/comments/%@", modelType: Comment.typeName, httpMethods: [.delete]),
        Segment("spots/comment", modelType: Comment.typeName, httpMethods: [.post]),
/// emoji
		Segment("spots/reactEmoji", modelType: EmojiReactModel.typeName, action: SpotAction.reactEmoji, httpMethods: [.post]),
		Segment("spots/unreactEmoji", modelType: EmojiReactModel.typeName, action: SpotAction.unreactEmoji, httpMethods: [.post]),

        // Board
        Segment("boards/%@", modelType: Board.typeName),
        Segment("boards", modelType: [Board].typeName, controllerType: UploadBoardCollectionViewController.typeName),
        Segment("boards?type=1", modelType: [Board].typeName, controllerType: SaveBoardCollectionViewController.typeName),
        
        Segment("boards/%@/nested", modelType: [Board].typeName, controllerType: NestedUploadBoardCollectionViewController.typeName),
        Segment("boards/%@/nested?type=1", modelType: [Board].typeName, controllerType: NestedSaveBoardCollectionViewController.typeName),
        
        Segment("boards/%@/spots", modelType: [Spot].typeName, controllerType: UploadBoardCollectionViewController.typeName),
        Segment("boards/%@/spots?type=1", modelType: [Spot].typeName, controllerType: SaveBoardCollectionViewController.typeName),
        Segment("boards/%@/spots", modelType: [Spot].typeName, controllerType: NestedUploadBoardCollectionViewController.typeName),
        Segment("boards/%@/spots?type=1", modelType: [Spot].typeName, controllerType: NestedSaveBoardCollectionViewController.typeName),
/// get avalable cover boards
        Segment("boards/%@/spotsCoverPhotos", modelType: [String].typeName, controllerType: BoardCoverPhotosViewController.typeName, httpMethods: [.get]),
/// upload new cover board
		Segment("boards/%@/thumbnail", modelType: BoardMediaItem.typeName, controllerType: BoardCoverPhotosViewController.typeName, httpMethods: [.put]),
        // Media        Segment("media/images/%@", modelType: [SpotMediaItem].typeName),
//        Segment("media/images/%@?fid=" + DataContext.userUID, modelType: [GoMediaItem].typeName),
        Segment("media/images/%@", modelType: [Spot].typeName, controllerType: GoPhotosCollectionViewController.typeName),

        
        // Upload Message
        Segment("uploadMessages/random", modelType: UploadMessgae.typeName),
        
        // Notificatios
        Segment("notifications", modelType: [String].typeName, controllerType: NotificationsViewController.typeName),
        Segment("notifications/checklistItem", modelType: ChecklistItem.typeName, httpMethods: [.post]),
        Segment("notifications/register", modelType: DeviceToken.typeName, httpMethods: [.post]),
        
        //GDPR data download
        Segment("sendsettingsdata", modelType: ResponseStatus.typeName ,controllerType: SettingsTableViewController.typeName, httpMethods: [.get]),
        //{{domain}}/sendsettingsdata?fid=4lbnAkDCKcNnsNpzqmIYO58nTsz1

        
        //Report
        Segment("reports/spot", modelType: SpotReport.typeName, httpMethods: [.post]),
        Segment("reports/comment", modelType: CommentReport.typeName, httpMethods: [.post]),
        Segment("blocks/user", modelType: UserBlock.typeName, httpMethods: [.post]),
        
        Segment("multiCat/all", modelType: [Category].typeName, httpMethods: [.get]),
        
        // Discover
        Segment("discover", modelType: [PlayListSection].typeName, httpMethods: [.get]),
        // PlayLists
        Segment("playlist", modelType: [PlayList].typeName, httpMethods: [.get]),
        Segment("playlist/locations", modelType: [PlayListLocation].typeName, httpMethods: [.get]),
        Segment("playlist/Spots", modelType: [Spot].typeName,controllerType: PlayListDetailsViewController.typeName, httpMethods: [.get]),
        Segment("multiCat/all", modelType: [Category].typeName, httpMethods: [.get]),
    ]
}
