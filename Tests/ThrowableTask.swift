import Quick
import Nimble
import AsyncTask

class ThrowableTaskSpec: QuickSpec {
    override func spec() {
        it("should throw") {
            enum TestError: Error {
                case notFound
            }

            let load = {(path: String) -> ThrowableTask<NSData> in
                ThrowableTask {
                    Thread.sleep(forTimeInterval: 0.05)
                    switch path {
                    case "profile.png":
                        return NSData()
                    case "index.html":
                        return NSData()
                    default:
                        throw TestError.notFound
                    }
                }
            }

            expect{try load("profile.png").await()}.notTo(throwError())
            expect{try load("index.html").await()}.notTo(throwError())
            expect{try load("random.txt").await()}.to(throwError())
            expect{try [load("profile.png"), load("index.html")].awaitAll()}.notTo(throwError())
            expect{try [load("profile.png"), load("index.html"), load("random.txt")].awaitAll()}.to(throwError())
        }
    }
}
