//
//  ContentView.swift
//  firstios
//
//  Created by MAC on 2023/5/1.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State private var serverIPAddress = ""
    @State private var sshPort = ""
    @State private var username = ""
    @State private var password = ""
    @State private var operatingSystem = "centos"
    @State private var result = ""
    @State private var isConfiguring = false // 新增的状态属性
    
    let operatingSystems = ["centos", "ubuntu", "azure ubuntu"]
    
    var body: some View {
        ScrollView {
            VStack {
                LabeledTextField(label: "服务器IP地址", text: $serverIPAddress)
                LabeledTextField(label: "SSH端口", text: $sshPort)
                LabeledTextField(label: "用户名", text: $username)
                LabeledSecureField(label: "密码", text: $password)
                
                VStack(alignment: .leading) {
                    Text("操作系统")
                    Picker("操作系统", selection: $operatingSystem) {
                        ForEach(operatingSystems, id: \.self) {
                            Text($0)
                        }
                    }.pickerStyle(MenuPickerStyle())
                }.padding()
                
                Button(action: {
                    startConfiguration() // 调用新的函数来进行配置
                }) {
                    Text(isConfiguring ? "配置中" : "开始配置")
                }
                .padding()
                .disabled(isConfiguring) // 根据配置状态禁用按钮
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 2)
                )
                
                VStack(alignment: .leading) {
                    Text("结果")
                    TextEditor(text: $result)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                    
                    Button(action: {
                        UIPasteboard.general.string = self.result
                    }) {
                        Text("复制结果")
                    }
                    .padding()
                }.padding()
            }
        }
        
    }
    
    
    func startConfiguration() {
        isConfiguring = true
        
        DispatchQueue.global().async {
            // 进行配置任务...
            // 这里进行确认操作，如进行SSH连接并返回结果到result变量
            let taskParams: [String: Any] = ["serverIp": serverIPAddress, "serverPort": sshPort, "serverUserName": username, "serverPassWord": password, "os": operatingSystem]
            let v2rayAutoClient = V2RayManager(taskParams: taskParams)
            let newResult = v2rayAutoClient.run()
            
            DispatchQueue.main.async {
                // 配置完成后更新UI，设置isConfiguring为false
                isConfiguring = false
                self.result = newResult
            }
        }
    }
}

struct LabeledTextField: View {
    let label: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
            TextField("", text: $text)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
        }
        .padding()
    }
}

struct LabeledSecureField: View {
    let label: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
            SecureField("", text: $text)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
