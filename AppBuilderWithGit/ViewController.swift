//
//  ViewController.swift
//  AppBuilderWithGit
//
//  Created by Hori,Masaki on 2017/08/11.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet var cloneButton: NSButton!
    @IBOutlet var urlField: NSTextField!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        NSApplication.appDelegate.registerTerminateCanceller { [weak self] in
            
            guard let `self` = self else { return true }
            
            if self.rawProgress {
                
                let alert = NSAlert()
                alert.messageText = "Stil building"
                alert.informativeText = "Wait for finish build."
                alert.runModal()
            }
            
            return self.rawProgress
        }
    }
    
    private dynamic var rawMessage: String = ""
    var message: String = "" {
        
        didSet {
            DispatchQueue.main.async {
                self.rawMessage = self.message
            }
        }
    }
    
    private dynamic var rawProgress: Bool = false
    var progress: Bool = false {
        
        didSet {
            DispatchQueue.main.async {
                self.rawProgress = self.progress
            }
        }
    }
    
    @IBAction func doIt(_ sender: Any?) {
        
        clone()
    }
    
}

extension ViewController {
    
    override func controlTextDidChange(_ obj: Notification) {
        
        guard let tx = obj.object as? NSTextField else { return }
        
        if let url = URL(string: tx.stringValue),
            let scheme = url.scheme,
            (scheme == "git") || (scheme == "http") || (scheme == "https"),
            let host = url.host, host != "",
            url.path != "/", url.path != "" {
            
            cloneButton.isEnabled = true
            
        } else {
            
            cloneButton.isEnabled = false
        }
    }
}

extension ViewController {
    
    fileprivate func clone() {
        
        guard let url = URL(string: urlField.stringValue)
            else { return }
        
        cloneButton.isEnabled = false
        
        DispatchQueue(label: "MMMMM", attributes: .concurrent).async {
            
            self.progress = true
            defer {
                self.progress = false
                DispatchQueue.main.async {
                    self.cloneButton.isEnabled = true
                }
            }
            
            let gitCloner = Git(url)
            
            self.message = "Cloning \"\(gitCloner.repositoryName)\" into \"\(gitCloner.repository.path)\""
            
            gitCloner.excute() {
                
                switch $0 {
                    
                case .none:
                    self.message = "Finish cloning"
                    
                    self.build(gitCloner.repository)
                    
                case let .gitError(stat, mess):
                    self.message = "Status -> \(stat)\n" + mess
                    
                case let .other(mess):
                    self.message = mess
                }
            }
            
        }
    }
    
    private func build(_ url: URL) {
        
        message = "Building Project."
        
        do {
            guard let builder = ProjectBuilder(url)
                else {
                    message = "Fail build because project file is not found."
                    return
            }
            
            try builder.build()
            
            message = "Build success!"
            
            NSWorkspace.shared().open(builder.productURL)
            
        } catch {
            
            message = "Fail to build."
        }
        
    }
    
}

