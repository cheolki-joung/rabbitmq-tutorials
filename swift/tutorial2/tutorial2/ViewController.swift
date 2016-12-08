//  Converted with Swiftify v1.0.6185 - https://objectivec2swift.com/
import UIKit
import RMQClient

class ViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.workerNamed("Jack")
        self.workerNamed("Jill")
        sleep(1)
        self.newTask("Hello World...")
        self.newTask("Just one this time.")
        self.newTask("Five.....")
        self.newTask("None")
        self.newTask("Two..dots")
    }
    
    func newTask(_ msg: String) {
        let conn = RMQConnection(delegate: RMQConnectionDelegateLogger())
        conn.start()
        let ch = conn.createChannel()
        let q = ch.queue("task_queue", options: .durable)
        let msgData = msg.data(using: .utf8)
        ch.defaultExchange().publish(msgData, routingKey: q.name, persistent: true)
        print("Sent \(msg)")
        conn.close()
    }
    
    func workerNamed(_ name: String) {
        let conn = RMQConnection(delegate: RMQConnectionDelegateLogger())
        conn.start()
        let ch = conn.createChannel()
        let q = ch.queue("task_queue", options: .durable)
        ch.basicQos(1, global: false)
        print("\(name): Waiting for messages")
        let manualAck = RMQBasicConsumeOptions()
        q.subscribe(manualAck, handler: {(_ message: RMQMessage) -> Void in
            let messageText = String(data: message.body, encoding: .utf8)
            print("\(name): Received \(messageText)")
            // imitate some work
            let sleepTime = UInt32(messageText!.components(separatedBy: ".").count) - 1
            print("\(name): Sleeping for \(sleepTime) seconds")
            sleep(sleepTime)
            ch.ack(message.deliveryTag)
        })
    }
}
