# App Store Connect Kit

<!-- [![Test](https://github.com/Blackjacx/asckit/actions/workflows/test.yml/badge.svg)](https://github.com/Blackjacx/asckit/actions/workflows/test.yml) -->

[![X Follow](https://img.shields.io/badge/follow-%40blackjacx-1DA1F2?logo=twitter&style=for-the-badge)](https://x.com/intent/follow?original_referer=https%3A%2F%2Fgithub.com%2Fblackjacx&screen_name=Blackjacxxx)
[![Version](https://shields.io/github/v/release/blackjacx/ASCKit?display_name=tag&include_prereleases&sort=semver)](https://github.com/Blackjacx/ASCKit/releases)
[![Swift Package Manager Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FBlackjacx%2FASCKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/Blackjacx/ASCKit)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FBlackjacx%2FASCKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/Blackjacx/ASCKit)
[![Xcode 16+](https://img.shields.io/badge/Xcode-16%2B-blue.svg)](https://developer.apple.com/download/)
[![License](https://img.shields.io/github/license/blackjacx/asckit.svg)](https://github.com/Blackjacx/asckit/blob/develop/LICENSE)
[![Donate](https://img.shields.io/badge/Donate-PayPal-blue.svg?logo=paypal&style=for-the-badge)](https://www.paypal.me/STHEROLD)

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

- First, make sure all your feature branches/PRs are merged
- Checkout develop and pull:
  ```shell
  git checkout develop && git pull
  ```
- Update to the latest shared development files:
  ```shell
  bash <(curl -H -s https://raw.githubusercontent.com/Blackjacx/Scripts/main/frameworks/bootstrap.sh)
  ```
- Run `bundle update` to update all Ruby gems
- Run `swift package update` to update all SPM dependencies
- Commit all changes on `develop` using:
  ```
  git commit -am "Release version 'x.y.z'"
  ```
- Run `bundle exec fastlane release framework:"ASCKit" version:"x.y.z"` to release the new version
- Post the following on Twitter:
  ```
  ASCKit release x.y.z 🎉

  ▸ 🚀  Library package ASCKit successfully published
  ▸ 📅  August 24th
  ▸ 🌎  https://swiftpackageindex.com/Blackjacx/ASCKit
  ▸ 🌎  https://github.com/Blackjacx/ASCKit/releases/latest
  ▸ 👍  Tell your friends!

  #SPM #Apple #Development #AppStore #AppStoreConnect #API #Library #Package #Tools
  ```

## Contribution

- If you found a **bug**, please open an **issue**.
- If you have a **feature request**, please open an **issue**.
- If you want to **contribute**, please submit a **pull request**.

## Author

[Stefan Herold](mailto:stefan.herold@gmail.com) • 🐦 [@Blackjacxxx](https://twitter.com/Blackjacxxx)

## Contributors

Thanks to all of you who are part of this:

<a href="https://github.com/blackjacx/asckit/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=blackjacx/asckit" />
</a>

## License

ASCKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
