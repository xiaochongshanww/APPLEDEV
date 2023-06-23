//
//  sshconnect.swift
//  firstios
//
//  Created by MAC on 2023/6/20.
//

import Foundation
import NMSSH

class SSHManager {
    var host: String
    var username: String
    var password: String
    var session: NMSSHSession?

    init(host: String, username: String, password: String) {
        self.host = host
        self.username = username
        self.password = password
    }

    func connect() -> Bool {
        session = NMSSHSession.connect(toHost: host, withUsername: username)
        guard session?.isConnected == true else {
            print("Failed to connect")
            return false
        }

        session?.authenticate(byPassword: password)
        guard session?.isAuthorized == true else {
            print("Authentication failed")
            return false
        }
        return true
    }

    func disconnect() {
        session?.disconnect()
    }

    func execute(command: String) -> String? {
        guard let session = session, session.isConnected else {
            print("Not connected")
            return nil
        }

        var error: NSError?
        let response = session.channel.execute(command, error: &error, timeout: 10)

        if let error = error {
            print("Failed to execute command: \(error.localizedDescription)")
            return nil
        }

        return response
    }
}

func test_ssh() -> Void {
    let sshManager = SSHManager(host: "159.223.33.227", username: "root", password: "##19960310wcgWCG")
    let connected = sshManager.connect()
    if connected{
        let commandRs = sshManager.execute(command: "pwd")
        if let result = commandRs {
            print("命令行执行结果： \(result)")
        }
    }
    else{
        print("命令下发失败")
    }
    
    if connected{
        let commandRs = sshManager.execute(command: "pip install django")
        if let result = commandRs {
            print("命令行执行结果： \(result)")
        }
    }
    else{
        print("命令下发失败")
    }
}

test_ssh()

