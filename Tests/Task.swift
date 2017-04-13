// https://github.com/Quick/Quick

import Quick
import Nimble

import AsyncTask

class TaskSpec: QuickSpec {
    override func spec() {
        
        it("can warp expensive synchronous API") {
            func encode(_ message: String) -> String {
                Thread.sleep(forTimeInterval: 0.1)
                return message
            }

            func encryptMessage(_ message: String) -> Task<String> {
                return Task {
                    encode(message)
                }
            }

            let message = "Hello"
            let encrypted = encryptMessage(message).await()
            expect(encrypted) == message
        }

        it("can wrap asynchronous APIs") {
            let session = URLSession(configuration: .ephemeral)

            let get = {(url: URL) in
                Task { session.dataTask(with: url, completionHandler: $0).resume() }
            }

            let url = URL(string: "https://httpbin.org/delay/1")!
            let (data, response, error) = get(url).await()
           
            expect(data).toNot(beNil())
            expect(response).toNot(beNil())

            expect(response!.url!.absoluteString) == "https://httpbin.org/delay/1"
            expect(error).to(beNil())
        }
    }
}
