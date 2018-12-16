//
//  Type.swift
//  SwiftDemangler
//
//  Created by Yuta Saito on 2018/12/16.
//

import Foundation

indirect enum Type: Equatable {
    case tuple
    case list([Type])
    case shortenType(ShortenType)

    enum ShortenType: String, Equatable {
        case int = "Si"
        case bool = "Sb"
    }

    struct Tuple: Equatable {
        let element: Type
    }
}
