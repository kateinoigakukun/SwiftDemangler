//
//  Node.swift
//  SwiftDemangler
//
//  Created by Yuta Saito on 2018/12/16.
//

indirect enum Node: Equatable {
    case global(Global)
    case module(Module)
    case identifier(Identifier)
    case labelList([Identifier])
    case type(Type)
    case argumentTuple([Type])
    case function(Module, Identifier, [Identifier], Function)

    struct Global: Equatable, SwiftExpressible {
        let node: Node

        var module: Module? {
            return node.module
        }
        var swiftExpression: String {
            return node.swiftExpression
        }
    }

    struct Module: Equatable {
        let text: String
    }
    struct Identifier: Equatable {
        let text: String
    }

    struct Function: Equatable {
        let returnType: Type
        let argumentTuple: [Type]
    }

    var module: Module? {
        switch self {
        case .global(let global):
            return global.node.module
        case .function(let module, _, _, _):
            return module
        case .module(let module):
            return module
        case .identifier, .labelList, .type, .argumentTuple:
            return nil
        }
    }

    var swiftExpression: String {
        switch self {
        case .global(let global):
            return global.node.swiftExpression
        case .function(let module, let identifier, let labels, let sign):
            let label = zip(labels, sign.argumentTuple).map { "\($0.text): \($1.swiftExpression)" }
                .joined(separator: ", ")
            return "\(module.text).\(identifier.text)(\(label)) -> \(sign.returnType.swiftExpression)"
        case .module(let module):
            return module.text
        case .identifier(let id): return id.text
        default: fatalError()
        }
    }
}
