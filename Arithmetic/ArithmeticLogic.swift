import Foundation

func generateGlobalQuestion(level: Int) -> (question: String, answer: Double) {
    var num1: Int
    var num2: Int
    var operations: [String]
    var operation: String
    var question = ""
    var answer: Double = 0.0

    // Adjust difficulty based on grade level
    switch level {
    case 1...3: // Grades 1-3 (Basic math, addition, subtraction, simple multiplication)
        num1 = Int.random(in: 1...9) // Single-digit numbers
        num2 = Int.random(in: 1...9) // Single-digit numbers
        operations = ["+", "-", "*"] // Basic operations
    case 4...6: // Grades 4-6 (Addition, subtraction, multiplication, division)
        num1 = Int.random(in: 1...20) // Up to 20 for addition and subtraction
        num2 = Int.random(in: 1...20) // Up to 20 for division and multiplication
        operations = ["+", "-", "*", "/"] // Add division
    case 7...8: // Grades 7-8 (Squares, two-digit multiplication, simple division)
        num1 = Int.random(in: 1...20) // Numbers 1-20 for squaring
        num2 = Int.random(in: 1...11) // One number up to 11 for multiplication
        operations = ["+", "-", "*", "/", "^2"] // Squares included
    case 9...12: // Grades 9-12 (Squares, cubes, and powers of 2, larger numbers)
        num1 = Int.random(in: 1...20) // Numbers 1-20 for squaring or cubing
        num2 = Int.random(in: 1...11) // One number no higher than 11 for multiplication
        operations = ["+", "-", "*", "/", "^2", "^3", "2^x"] // Add cube and powers of 2
    default:
        num1 = Int.random(in: 1...20) // Numbers 1-20 for squaring or cubing
        num2 = Int.random(in: 1...11) // One number no higher than 11 for multiplication
        operations = ["+", "-", "*", "/", "^2", "^3", "2^x"] // Add cube and powers of 2
    }

    // Randomly pick an operation
    operation = operations.randomElement() ?? "+"

    // Generate the question based on the operation
    switch operation {
    case "+":
        question = "\(num1) + \(num2)"
        answer = Double(num1 + num2)
    case "-":
        question = "\(num1) - \(num2)"
        answer = Double(num1 - num2)
    case "*":
        question = "\(num1) * \(num2)"
        answer = Double(num1 * num2)
    case "/":
        // Ensure division only happens if the division result is a whole number (no remainder)
        repeat {
            num1 = Int.random(in: 1...99) // Pick a number for num1
            num2 = Int.random(in: 1...99) // Pick a number for num2
        } while num1 % num2 != 0 // Repeat until num1 is perfectly divisible by num2
        question = "\(num1) / \(num2)"
        answer = Double(num1) / Double(num2)
    case "^2":
        // Square the number for grades 7-8
        question = "\(num1) ^ 2"
        answer = Double(num1 * num1) // Square the number
    case "^3":
        // Cube the number for grades 9-12
        question = "\(num1) ^ 3"
        answer = Double(num1 * num1 * num1) // Cube the number
    case "2^x":
        // Power of 2 for grades 9-12
        let exponent = Int.random(in: 1...8) // Exponent range 1-8
        question = "2 ^ \(exponent)"
        answer = pow(2.0, Double(exponent)) // Calculate 2 raised to the power of exponent
    default:
        break
    }

    return (question, answer)
}
