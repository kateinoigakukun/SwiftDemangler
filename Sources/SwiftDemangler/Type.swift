//
//  Type.swift
//  SwiftDemangler
//
//  Created by Yuta Saito on 2018/12/16.
//

import Foundation

indirect enum Type: Equatable, SwiftExpressible {
    case list([Type])
    case shortenType(ShortenType)

    enum ShortenType: String, Equatable, SwiftExpressible {
        case int = "Si"
        case bool = "Sb"
        case float = "Sf"
        case string = "SS"

        var swiftExpression: String {
            switch self {
            case .int: return "Swift.Int"
            case .bool: return "Swift.Bool"
            case .float: return "Swift.Float"
            case .string: return "Swift.String"
            }
        }
    }

    struct Tuple: Equatable {
        let element: Type
    }

    var list: [Type]? {
        switch self {
        case .list(let list): return list
        default: return nil
        }
    }

    var swiftExpression: String {
        switch self {
        case .list(let types):
            fatalError()
        case .shortenType(let shortenType):
            return shortenType.swiftExpression
        }
    }
}
