func generateGlobalQuestion(level: Int) -> (question: String, answer: Double) {
    var num1: Int
    var num2: Int
    var operations: [String]
    var operation: String
    var question = ""
    var answer: Double = 0.0

    // Adjust difficulty based on grade level
    switch level {
    case 1...3: // Grades 1-3 (Basic math, addition and subtraction)
        num1 = Int.random(in: 1...9) // Single-digit numbers
        num2 = Int.random(in: 1...9) // Single-digit numbers
        operations = ["+", "-"] // Only addition and subtraction
    case 4...6: // Grades 4-6 (Introduce multiplication and division with single digits)
        num1 = Int.random(in: 1...9) // Single-digit numbers
        num2 = Int.random(in: 1...9) // Single-digit numbers
        operations = ["+", "-", "*", "/"] // Add multiplication and division
    case 7...8: // Grades 7-8 (Single-digit multiplication, double-digit division allowed)
        num1 = Int.random(in: 1...9) // Single-digit numbers for multiplication
        num2 = Int.random(in: 1...9) // Single-digit numbers for multiplication
        operations = ["+", "-", "*", "/"] // Add multiplication and division
    case 9...12: // Grades 9-12 (Double-digit numbers and mixed operations)
        num1 = Int.random(in: 10...99) // Double-digit numbers for multiplication
        num2 = Int.random(in: 10...99) // Double-digit numbers for multiplication
        operations = ["+", "-", "*", "/"] // All operations
    default:
        num1 = Int.random(in: 1...9)
        num2 = Int.random(in: 1...9)
        operations = ["+"]
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
        // For grades 1-8, use single-digit multiplication
        if level <= 8 {
            num1 = Int.random(in: 1...9) // Single-digit multiplication for lower grades
            num2 = Int.random(in: 1...9) // Single-digit multiplication
        }
        // For grades 9-12, allow two-digit multiplication
        if level >= 9 {
            num1 = Int.random(in: 10...99) // Two-digit multiplication for higher grades
            num2 = Int.random(in: 10...99) // Two-digit multiplication
        }
        question = "\(num1) * \(num2)"
        answer = Double(num1 * num2)
    case "/":
        // Ensure division only happens if the division result is a whole number (no remainder)
        // Re-generate num1 and num2 if division results in a non-whole number
        repeat {
            num1 = Int.random(in: 1...99) // Pick a number for num1
            num2 = Int.random(in: 1...99) // Pick a number for num2
        } while num1 % num2 != 0 // Repeat until num1 is perfectly divisible by num2

        question = "\(num1) / \(num2)"
        answer = Double(num1) / Double(num2)
    default:
        break
    }

    return (question, answer)
}
