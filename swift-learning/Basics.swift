struct Word {
    let id: Int
    var term: String
    let level: String
    var example: String?
}

func exampleText(for word: Word) -> String {
    word.example ?? "暂无例句"
}

enum ReviewError: Error {
    case invalidScore
}

func validateScore(_ score: Int) throws -> Int {
    guard (0...100).contains(score) else {
        throw ReviewError.invalidScore
    }
    return score
}

final class Counter {
    var value = 0
}

let original = Word(id: 1, term: "speak", level: "A2", example: nil)
var copy = original
copy.term = "review"
print("example: \(exampleText(for: original))")
print("value copy: \(original.term) / \(copy.term)")

let first = Counter()
let second = first
second.value += 1
print("shared reference: \(first.value) / \(second.value)")

let words = [original, Word(id: 2, term: "review", level: "A2", example: nil)]
let terms = words.filter { $0.level == "A2" }.map { $0.term }
print("A2 terms: \(terms.joined(separator: ", "))")

do {
    _ = try validateScore(101)
} catch {
    print("error: \(error)")
}
