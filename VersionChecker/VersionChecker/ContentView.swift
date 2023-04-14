//
//  ContentView.swift
//  VersionChecker
//
//  Created by Jarren Campos on 4/13/23.
//

import SwiftUI

@main
struct VersionChecker: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct Result: Codable {
    let resultCount: Int
    let results: [AppVersion]
    
    enum CodingKeys: String, CodingKey {
        case resultCount = "resultCount"
        case results = "results"
    }
}

struct AppVersion: Codable {
    let version: String?
    
    enum CodingKeys: String, CodingKey {
        case version = "version"
    }
}

struct ContentView: View {
    @State var version: String?
    @State var updateNeeded: Bool = false
    
    var body: some View {
        VStack {
            if let version = version {
                Text("App Store Version: \(version)")
                Text("Your current version: \(Bundle.main.releaseVersionNumber ?? "error")")
                Button {
                    versionChecker()
                } label: {
                    Text("Try Again")
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
                
                Button {
                    openTwitter()
                } label: {
                    Text("Follow me @jarrencampos")
                }
                .buttonStyle(.bordered)
                
            } else {
                Text("Loading...")
            }
        }
        .alert(isPresented: $updateNeeded) {
            Alert(
                title: Text("Update Available"),
                message: Text("A new version is available. Please update to version \(version ?? "") now."),
                primaryButton: .default(Text("Update")) {
                    openAppStore()
                },
                secondaryButton: .cancel(Text("Next Time")) {
                    print("dismissed")
                }
            )
        }
        .onAppear {
            versionChecker()
        }
    }
    // YOU CAN OBVIOUSLY DELETE THIS!
    func openTwitter() {
        if let url = URL(string: "https://twitter.com/jarrencampos") {
            UIApplication.shared.open(url)
        }
    }
    func openAppStore() {
#warning("ATTENTION! Add your app id right after the 'id' for this to work properly.")
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1637019953") {
            UIApplication.shared.open(url)
        }
    }
    func compareVersions(_ version1: String, _ version2: String) {
        if version1 == "" || version2 == ""{
            return
        }
        
        let v1 = version1.components(separatedBy: ".")
        let v2 = version2.components(separatedBy: ".")
        
        let count = max(v1.count, v2.count)
        for i in 0..<count {
            let num1 = i < v1.count ? Int(v1[i]) ?? 0 : 0
            let num2 = i < v2.count ? Int(v2[i]) ?? 0 : 0
            if num1 < num2 {
                updateNeeded = false
                return
            } else if num1 > num2 {
                updateNeeded = true
                return
            }
        }
        updateNeeded = true
    }
    
    func versionChecker() {
#warning("ATTENTION! Add your app id right after the 'id=' for this to work properly.")
        guard let url = URL(string: "https://itunes.apple.com/lookup/?id=1637019953") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(Result.self, from: data)
                if let version = result.results.first?.version {
                    DispatchQueue.main.async {
                        self.version = version
                        compareVersions(version, Bundle.main.releaseVersionNumber ?? "")
                    }
                }
            } catch let error {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }
        .resume()
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
