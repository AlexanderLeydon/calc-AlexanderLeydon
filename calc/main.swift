//
//  main.swift
//  calc
//
//  Created by Jesse Clark on 12/3/18.
//  Copyright © 2018 UTS. All rights reserved.
//

import Foundation

var args = ProcessInfo.processInfo.arguments
// remove the name of the program
args.removeFirst()

var operators: String = "+-x%/"
var numbers: String = "0123456789"
var accpetableChars: String = operators + numbers

//Printing to standard error from: https://gist.github.com/algal/0a9aa5a4115d86d5cc1de7ea6d06bd91
var standardError = FileHandle.standardError

extension FileHandle : TextOutputStream {
    public func write(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        self.write(data)
    }
}

guard args.count > 0 else {
    print("Error: Line is empty",to:&standardError)
    exit(1)
}

//how to access characters at index from: https://www.quora.com/How-can-I-access-individual-characters-from-a-String-in-Swift
for i in 0..<args.count {
    for index in args[i].indices {
        guard accpetableChars.index(of: args[i][index]) != nil else {
            print("Error: Only enter numbers or arithmathic operators")
            exit(2)
        }
    }
}

func isOperator(oper: String) -> Bool{
    for index in oper.indices{
        if numbers.index(of: oper[index]) != nil {
            return false
        }
    }
    return true
}

func evaluate(firstNumber: Int, secondNumber: Int, oper: String) -> Int{
    switch oper {
        case "+":
            return (firstNumber + secondNumber)
        case "-":
            return (firstNumber - secondNumber)
        case "x":
            return (firstNumber * secondNumber)
        case "/":
            guard (secondNumber != 0) else {
                print("Error: cannot divide by zero",to:&standardError)
                exit(3)
            }
            return (firstNumber / secondNumber)
        case "%":
            return (firstNumber % secondNumber)
        default:
            return firstNumber
    }
}

func nextOperation(expression: [String])-> (oper: String,pos: Int){
    var nextOper = ""
    var nextOperPos = 0
    for i in 0..<expression.count{
        if isOperator(oper: expression[i]){
            switch expression[i]{
            case "x","/","%":
                if nextOper == "" || nextOper == "+" || nextOper == "-" || i < nextOperPos{
                    nextOper = expression[i]
                    nextOperPos = i
                }
            case "+","-":
                if nextOper == ""{
                    nextOper = expression[i]
                    nextOperPos = i
                }
            default: nextOper = ""
            }
        }
    }
    return (nextOper,nextOperPos)
}

func calculate(expression: [String]) -> String{
    var equation: [String]
    equation = expression
    while equation.count > 1 {
        let (oper, pos) = nextOperation(expression: equation)
        let result: Int = evaluate(firstNumber: Int(equation[pos-1])!, secondNumber: Int(equation[pos+1])!, oper: oper)
        for _ in 0..<3{
            equation.remove(at: pos-1)
        }
        equation.insert(String(result), at: pos-1)
    }
    return equation[0]
}

print(Int(calculate(expression: args))!)


