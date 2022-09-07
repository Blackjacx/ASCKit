# App Store Connect Kit


<!-- [![Test](https://github.com/Blackjacx/asckit/actions/workflows/test.yml/badge.svg)](https://github.com/Blackjacx/asckit/actions/workflows/test.yml) -->
[![Twitter](https://img.shields.io/twitter/follow/blackjacxxx?label=%40Blackjacxxx)](https://twitter.com/blackjacxxx)
[![Version](https://shields.io/github/v/release/blackjacx/ASCKit?display_name=tag&include_prereleases&sort=semver)](https://github.com/Blackjacx/ASCKit/releases)
[![Swift Package Manager Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FBlackjacx%2FASCKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/Blackjacx/ASCKit)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FBlackjacx%2FASCKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/Blackjacx/ASCKit)
[![iOS 15+](https://img.shields.io/badge/iOS-15.0%2B-blue.svg)](https://developer.apple.com/download/)
[![Xcode 13+](https://img.shields.io/badge/Xcode-13%2B-blue.svg)](https://developer.apple.com/download/)
[![Codebeat](https://codebeat.co/badges/09488e6e-331e-4d7a-9238-3b2224cc8f04)](https://codebeat.co/projects/github-com-blackjacx-asckit-develop)
[![License](https://img.shields.io/github/license/blackjacx/asckit.svg)](https://github.com/Blackjacx/asckit/blob/develop/LICENSE)
[![Donate](https://img.shields.io/badge/Donate-PayPal-blue.svg)](https://www.paypal.me/STHEROLD)

App Store Connect API access using your teams API key.

<!-- <p align="center">
<img src="./icon.png" alt="SHSearchBar" height="128" width="128">
</p> -->

This is a package providing access to Apple's App Store Connect API. The idea was born since I have to manage 30+ apps in our account in my day-to-day job. I needed a tool where I can make batch adjustments to all apps at once. This package provides the backbone of two of my apps that do that job:
- an iOS app (not public yet) and
- my command line tool `asc` which is part of my [Assist package](https://github.com/Blackjacx/Assist)

I continuously evolve ASCKit as I require new functionality here. Please feel free to provide feedback or add new functionality by opening a PR.

## Code Documentation

The [code documentation](https://swiftpackageindex.com/Blackjacx/ASCKit/develop/documentation/asckit) is generated and hosted by [Swift Package Index](https://swiftpackageindex.com/) (powered by [DocC](https://developer.apple.com/documentation/docc))

## Release

To release this Swift package the following steps have to be taken:
- Create a new branch `release-x.y.z`
- Increment the version in https://github.com/Blackjacx/ASCKit/blob/develop/.spi.yml
- Run `bash <(curl -H -s https://raw.githubusercontent.com/Blackjacx/Scripts/master/frameworks/bootstrap.sh)` to update to the latest shared development files
- Run `bundle update` to update all Ruby gems
- Commit all changes, make a PR and merge it to develop
- Run `bundle exec fastlane release framework:"ASCKit" version:"x.y.z"` to release the new version
- Post the following on Twitter
```
ASCKit release x.y.z 🎉

▸ 🚀  Library package ASCKit (x.y.z) successfully published
▸ 📅  September 2nd
▸ 🌎  https://swiftpackageindex.com/Blackjacx/ASCKit
▸ 🌎  https://github.com/Blackjacx/ASCKit/releases/latest
▸ 👍  Tell your friends!

#SPM #Apple #Development #AppStore #AppStoreConnect #AppStoreConnectAPI #Kit #Library #Package #Framework #Tools #Boilerplate #Code
```

## Contribution

- If you found a **bug**, please open an **issue**.
- If you have a **feature request**, please open an **issue**.
- If you want to **contribute**, please submit a **pull request**.

## Author

[Stefan Herold](mailto:stefan.herold@gmail.com) • 🐦 [@Blackjacxxx](https://twitter.com/Blackjacxxx)

## License

ASCKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
