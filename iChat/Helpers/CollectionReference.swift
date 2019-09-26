//
//  CollectionReference.swift
//  iChat
//
//  Created by Peter Centellini on 2019-09-18.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import Foundation
import FirebaseFirestore


enum FCollectionReference: String {
    case User
    case Typing
    case Recent
    case Message
    case Group
    case Call
}


func reference(_ collectionReference: FCollectionReference) -> CollectionReference{
    return Firestore.firestore().collection(collectionReference.rawValue)
}
