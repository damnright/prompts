import Foundation

struct Word: Sendable {
    let id: Int
    let term: String
}

enum LoadState {
    case idle
    case loading
    case loaded([Word])
    case cancelled
    case failed(String)
}

@MainActor
final class WordLoader {
    private(set) var state: LoadState = .idle

    func load() async {
        state = .loading
        do {
            // 模拟可取消的异步等待；没有网络或数据库副作用。
            try await Task.sleep(for: .milliseconds(20))
            try Task.checkCancellation()
            state = .loaded([Word(id: 1, term: "speak"), Word(id: 2, term: "review")])
        } catch is CancellationError {
            state = .cancelled
        } catch {
            state = .failed(String(describing: error))
        }
    }
}

@main
struct Demo {
    @MainActor
    static func main() async {
        let normal = WordLoader()
        await normal.load()
        if case .loaded(let words) = normal.state {
            print("loaded: \(words.count)")
        } else {
            fatalError("正常路径应加载成功")
        }

        let cancelled = WordLoader()
        let task = Task { await cancelled.load() }
        task.cancel()
        await task.value
        if case .cancelled = cancelled.state {
            print("cancelled")
        } else {
            fatalError("取消路径不应发布成功结果")
        }
    }
}
