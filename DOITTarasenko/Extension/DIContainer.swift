//
//  DIContainer.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/11/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Swinject

private let _container = Container()

public struct DIContainer {
    // MARK: - Public
    
    public static var defaultResolver: Container {
        return _container
    }
}
