import Quick
import Nimble
import AsyncTask

class DispatchQueueSpec: QuickSpec {
    override func spec() {
        // Thanks to https://github.com/duemunk/Async
        it("works with async") {
            // waiting on the current thread creates dead lock
            Task() {
                #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(tvOS)) // Simulator
                    expect(Thread.isMainThread()) == true
                #else
                    expect(qos_class_self()) == qos_class_main()
                #endif
                }.async(.main)

            Task() {
                expect(qos_class_self()) == QOS_CLASS_USER_INTERACTIVE
                }.async(.userInteractive)

            Task() {
                expect(qos_class_self()) == QOS_CLASS_USER_INITIATED
                }.async(.userInitiated)

            Task() {
                expect(qos_class_self()) == QOS_CLASS_UTILITY
                }.async(.utility)

            Task() {
                expect(qos_class_self()) == QOS_CLASS_BACKGROUND
                }.async(.background)

            let customQueue = DispatchQueue(label: "CustomQueueLabel")
            Task() {
                let currentClass = qos_class_self()
                let isValidClass = currentClass == qos_class_main() || currentClass == QOS_CLASS_USER_INITIATED
                expect(isValidClass) == true
                // TODO: Test for current queue label. dispatch_get_current_queue is unavailable in Swift, so we cant' use the return value from and pass it to dispatch_queue_get_label.
                }.await(.custom(customQueue))

            waitUntil { done in
                Thread.sleep(forTimeInterval: 0.05)
                done()
            }
        }
    }
}
