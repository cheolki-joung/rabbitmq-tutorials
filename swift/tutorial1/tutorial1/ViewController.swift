//  Converted with Swiftify v1.0.6185 - https://objectivec2swift.com/
import UIKit
import RMQClient

class ViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.send()
        self.receive()
    }
    
    func send() {
        print("Attempting to connect to local RabbitMQ broker")
        let conn = RMQConnection(delegate: RMQConnectionDelegateLogger())
        conn.start()
        let ch = conn.createChannel()
        let q = ch.queue("hello")
        ch.defaultExchange().publish("Hello World!".data(using: .utf8), routingKey: q.name)
        print("Sent 'Hello World!'")
        conn.close()
    }
    
    func receive() {
        print("Attempting to connect to local RabbitMQ broker")
        let conn = RMQConnection(delegate: RMQConnectionDelegateLogger())
        conn.start()
        let ch = conn.createChannel()
        let q = ch.queue("hello")
        print("Waiting for messages.")
        q.subscribe({(_ message: RMQMessage) -> Void in
            print("Received \(String(data: message.body, encoding: String.Encoding.utf8))")
        })
    }
}
