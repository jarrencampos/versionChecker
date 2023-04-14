# Version Checker

Notify your users to update the app with a simple alert! Implementing is easy, below is how it works. Feel free to clone the project to test this yourself!

# JSON Object
Below is the JSON object segmented out to show only the version from the GET request. You can view all the data that the api return by going here and entering your app id number after the "id=" itunes.apple.com/lookup/?id=1637019953

```swift
// Written by Jarren Campos on 4/13/23

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
```
# Functions
## Compare Versions
This is where we compare the two versions from the local version and the app store version.
```swift
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
```
## Network Call
Here we call the itunes api to GET the data we need to compare it to.
```swift
    func versionChecker() {
    #warning("ATTENTION! Add your app id right after the 'id=' for this to work properly.")
        guard let url = URL(string: "https://itunes.apple.com/lookup/?id=") else {
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
```
## Open App Store
This is the function we call from the button to open the appstore for an update.
```swift
    func openAppStore() {
#warning("ATTENTION! Add your app id right after the 'id' for this to work properly.")
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id") {
            UIApplication.shared.open(url)
        }
    }
```
# Download the project and it out yourself!

![Demo CountPages alpha](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExM2I1NjAwYTBmZWU2ZDBmNzExOWU4OWRiMWZmZDhmOTU2M2YxNzQ3ZSZjdD1n/Es92Dr9Yi27sw9koSe/giphy.gif)

[![Twitter URL](https://img.shields.io/twitter/follow/jarrencampos?style=social)](https://twitter.com/jarrencampos)
