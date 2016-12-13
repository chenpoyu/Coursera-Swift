//
//  Card+CoreDataProperties.swift
//  BusinessCard
//
//  Created by poyuchen on 2016/12/13.
//  Copyright © 2016年 poyuchen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Card {

    @NSManaged var timeStamp: NSDate?
    @NSManaged var name: String?
    @NSManaged var phone: String?
    @NSManaged var address: String?
    @NSManaged var email: String?
    @NSManaged var desc: String?
    @NSManaged var picture: NSData?

}
