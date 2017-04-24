//
//  Either.swift
//  ConvexHull
//
//  Created by Ariel Rodriguez on 3/4/17.
//  Copyright © 2017 VolonBolon. All rights reserved.
//

import Foundation

enum Either<T1, T2> {
    case Left(T1)
    case Right(T2)
}
