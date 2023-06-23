//
//  v2rayAutoClient.swift
//  firstios
//
//  Created by MAC on 2023/6/19.
//

import Foundation

class V2RayManager {
    let taskParams: Dictionary<String, Any>
    let serverIP: String
    let sshPort: String
    let username: String
    let password: String
    let operatingSystem: String
    var sshManager: SSHManager?
    var env: Dictionary<String, Any>?

    init(taskParams: Dictionary<String, Any>) {
        self.taskParams = taskParams
        self.serverIP = taskParams["serverIp"] as! String
        self.sshPort = taskParams["serverPort"] as! String
        self.username = taskParams["serverUserName"] as! String
        self.password = taskParams["serverPassWord"] as! String
        self.operatingSystem = taskParams["os"] as! String
        self.env = [String: Any]()
        self.initEnvInfo()
    }

    func initEnvInfo(){
        // 初始化环境信息
        print("开始初始化环境信息")
        self.env?["server_ip"] = self.taskParams["serverIp"]
        self.env?["server_port"] = self.taskParams["serverPort"]
        self.env?["server_username"] = self.taskParams["serverUserName"]
        self.env?["server_password"] = self.taskParams["serverPassWord"]
        print("初始化环境信息完成")
    }
    
    func run() -> String{
        // 运行主函数
        
        // 登录远程服务器
        loginServer()
        
        // 更新服务器
        serverUpdate()
        
        // 自动安装python
        autoInstallPython()
        
        // 安装git
        installGit()
        
        // 克隆代码
        cloneV2rayAutoCode()
        
        // 安装python依赖
        installPythonRequirements()
        
        // 获取vmess url
        var vmess:String  = autoConfigV2rayService()
        
        // 返回vmess url
        return vmess
    }
    
    func executeCommand(cmd: String) -> String{
        // 远程执行命令行
        if let rs = self.sshManager?.execute(command: cmd){
            return rs
        }
        else{
            return ""
        }
    }
    
    func loginServer() -> Void{
        // 登录服务器
        self.sshManager = SSHManager(host: self.serverIP, username: self.username, password: self.password)
        if let isConnected = self.sshManager?.connect(), isConnected{
            print("登陆服务器成功")
        }
        else{
            print("登陆服务器失败")
        }
    }
    
    func serverUpdate() -> Void{
        // 更新服务器
        print("开始更新服务器")
        var command: String = ""
        _ = self.executeCommand(cmd: "pwd")
        let disVersion = self.getLinuxDistro()
        if !disVersion.isEmpty{
            if ["ubuntu", "debian"].contains(disVersion){
                command = "sudo apt-get update && sudo apt-get upgrade -y"
            }
            else if ["centos", "redhat", "fedora"].contains(disVersion){
                command = "sudo yum update -y"
            }
            else
            {
                print("不支持的操作系统版本")
                return
            }
        }
        else{
            print("无法获取系统版本信息")
            return
        }
        _ = self.executeCommand(cmd: command)
        print("更新服务器完成")
    }
    
    func getLinuxDistro() -> String{
        // 获取Linux操作系统类型
        print("获取Linux操作系统类型")
        let cmd = "cat /etc/os-release | grep -E '^ID='"
        let outPut = self.executeCommand(cmd: cmd)
        if !outPut.isEmpty{
            let components = outPut.components(separatedBy: "=")
            if components.count > 1{
                var linuxDistribute = components[1].lowercased()
                linuxDistribute = linuxDistribute.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\" "))
                self.env?["linux_distribute"] = linuxDistribute
                return linuxDistribute
            }
            else{
                print("获取Linux操作系统类型失败")
                return ""
            }
        }
        else{
            print("获取Linux操作系统类型失败")
            return ""
        }
    }
    
    func autoInstallPython() -> Void{
        // 自动安装Python
        print("开始自动安装Python")
        let pythonInstallCommand = self.getPythonInstallComand()
        _ = self.executeCommand(cmd: pythonInstallCommand)
        print("自动安装Python完成")
        print("开始自动安装pip")
        let pipInstallCommand = self.getPipInstallCommand()
        _ = self.executeCommand(cmd: pipInstallCommand)
        print("自动安装pip完成")
    }
    
    func getPythonInstallComand() -> String{
        // 根据操作系统获取Python安装命令
        let linuxDistribute: String  = self.env?["linux_distribute"] as! String
        if ["ubuntu", "debian"].contains(linuxDistribute){
            return "sudo apt-get install python3 -y"
        }
        else if ["centos", "redhet", "fedora"].contains(linuxDistribute)
        {
            return "sudo yum install python3 -y"
        }
        else{
            print("不支持的操作系统类型")
            return ""
        }
    }
    
    func getPipInstallCommand() -> String{
        // 根据操作系统获取pip安装命令
        let linuxDistribute: String  = self.env?["linux_distribute"] as! String
        if ["ubuntu", "debian"].contains(linuxDistribute){
            return "sudo apt-get install python3-pip -y"
        }
        else if ["centos", "redhet", "fedora"].contains(linuxDistribute)
        {
            return "sudo yum install python3-pip -y"
        }
        else{
            print("不支持的操作系统类型")
            return ""
        }
    }
    
    func installGit(){
        // 安装git
        print("开始安装git")
        let gitInstallCommand = self.getGitInstallCommand()
        _ = self.executeCommand(cmd: gitInstallCommand)
        print("安装git完成")
    }
    
    func getGitInstallCommand() -> String{
        // 获取git安装命令
        let linuxDistribute: String  = self.env?["linux_distribute"] as! String
        if ["ubuntu", "debian"].contains(linuxDistribute){
            return "sudo apt-get install git -y"
        }
        else if ["centos", "redhet", "fedora"].contains(linuxDistribute)
        {
            return "sudo yum install git -y"
        }
        else{
            print("不支持的操作系统类型")
            return ""
        }
    }
    
    func cloneV2rayAutoCode(){
        // 克隆v2ray-auto代码
        print("开始克隆v2ray-auto代码")
        _ = self.executeCommand(cmd: "sudo rm -rf /home/git_dir/")
        _ = self.executeCommand(cmd: "sudo mkdir -p /home/git_dir")
        let cloneCommand = self.getCloneV2rayCodeCommand()
        _ = self.executeCommand(cmd: cloneCommand)
        print("克隆v2ray-auto代码完成")
    }
    
    func getCloneV2rayCodeCommand() -> String{
        // 获取克隆v2ray代码的命令
        let cloneCommand = "git clone https://github.com/wcg14231022/v2ray_auto.git /home/git_dir/v2ray_auto"
        if let operatingSystem = self.taskParams["os"] as? String, operatingSystem.range(of: "azure ubuntu", options: .caseInsensitive) != nil{
            let serverUserName = self.env?["server_username"] as? String ?? ""
            let cloneCommand = "git clone https://github.com/wcg14231022/v2ray_auto.git /home/\(serverUserName)/git_dir/v2ray_auto"
            return cloneCommand
        }
        return cloneCommand
    }
    
    func installPythonRequirements(){
        // 安装Python依赖
        print("开始安装Python依赖")
        let installCommand = self.getInstallPythonRequirementsCommand()
        _ = self.executeCommand(cmd: installCommand)
        print("安装Python依赖完成")
    }
    
    func getInstallPythonRequirementsCommand() -> String{
        // 获取安装Python依赖的命令
        let installCommand = "sudo pip install -r /home/git_dir/v2ray_auto/requirements.txt"
        if let operatingSystem = self.taskParams["os"] as? String, operatingSystem.range(of: "azure ubuntu", options: .caseInsensitive) != nil{
            let serverUserName = self.env?["server_username"] as? String ?? ""
            let installCommand = "sudo pip3 install -r /home/\(serverUserName)/git_dir/v2ray_auto/requirements.txt"
            return installCommand
        }
        return installCommand
    }
    
    func autoConfigV2rayService() -> String{
        // 自动配置v2ray服务
        print("开始自动配置v2ray服务")
        let configCommand = self.getAutoConfigV2rayServiceCommand()
        print("配置命令: \(configCommand)")
        let rs = self.executeCommand(cmd: configCommand)
        print("配置结果: \(rs)")
        self.openFireWallForV2ray(rs: rs)
        var vmess:String = self.getVmess(rs: rs)
        print("自动配置v2ray服务完成")
        print("获取到的vmess: \(vmess)")
        return vmess
    }
    
    func getVmess(rs: String) -> String {
        let regexPattern = "vmess_url:\\s*(\\S+)\\n"
        do {
            let regex = try NSRegularExpression(pattern: regexPattern)
            if let match = regex.firstMatch(in: rs, options: [], range: NSRange(location: 0, length: rs.utf16.count)) {
                if let range = Range(match.range(at: 1), in: rs) {
                    let vmess = String(rs[range])
                    print("获取到的vmess: \(vmess)")
                    return vmess
                }
            }
        } catch {
            print("Regex not valid")
        }
        return ""
    }

    
    func openFireWallForV2ray(rs: String) -> Void{
        // 打开防火墙
        let port = self.getV2rayPort(rs: rs)
        _ = self.executeCommand(cmd: "sudo iptables -A INPUT -p tcp --dport \(port) -j ACCEPT")
        _ = self.executeCommand(cmd: "sudo iptables -A INPUT -p udp --dport \(port) -j ACCEPT")
        _ = self.executeCommand(cmd: "sudo firewall-cmd --permanent --zone=public --add-port=\(port)/tcp")
        _ = self.executeCommand(cmd: "sudo firewall-cmd --permanent --zone=public --add-port=\(port)/udp")
        _ = self.executeCommand(cmd: "sudo firewall-cmd --reload")
    }
    
    func getV2rayPort(rs: String) -> String{
        // 获取v2ray端口
        let regexPattern = "随机端口为:\\s*(\\d+)\\n"
        do {
            let regex = try NSRegularExpression(pattern: regexPattern)
            if let match = regex.firstMatch(in: rs, options: [], range: NSRange(location: 0, length: rs.utf16.count)) {
                if let range = Range(match.range(at: 1), in: rs) {
                    let port = String(rs[range])
                    print("获取到的v2ray端口: \(port)")
                    return port
                }
            }
        } catch {
            print("Regex not valid")
        }
        return ""
    }
    
    func getAutoConfigV2rayServiceCommand() -> String{
        // 获取自动配置v2ray服务的命令
        let configCommand = "cd /home/git_dir/v2ray_auto && sudo python3 /home/git_dir/v2ray_auto/auto_install_v2ray.py"
        if let operatingSystem = self.taskParams["os"] as? String, operatingSystem.range(of: "azure ubuntu", options: .caseInsensitive) != nil{
            let serverUserName = self.env?["server_username"] as? String ?? ""
            let configCommand = "cd /home/\(serverUserName)/git_dir/v2ray_auto && sudo python3 /home/\(serverUserName)/git_dir/v2ray_auto/auto_install_v2ray.py"
            return configCommand
        }
        return configCommand
    }
    
}

