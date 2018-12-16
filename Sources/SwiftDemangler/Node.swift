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

    struct Global: Equatable {
        let node: Node

        var module: Module? {
            return node.module
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
        let argumentTuple: Type
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
}
