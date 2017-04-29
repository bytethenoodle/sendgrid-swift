import PackageDescription

let package = Package(
  name: "SendGrid",
  dependencies: [
    .Package(url: "https://github.com/bytethenoodle/RequestSession", "0.0.5")
    
  ]
)
