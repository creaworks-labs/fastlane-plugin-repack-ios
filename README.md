# repack-ios plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-repack_ios)
[![Gem Version](https://badge.fury.io/rb/fastlane-plugin-repack_ios.svg)](https://badge.fury.io/rb/fastlane-plugin-repack_ios)
[![Downloads](https://img.shields.io/gem/dt/fastlane-plugin-repack_ios.svg?style=flat)](https://rubygems.org/gems/fastlane-plugin-repack_ios)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/creaworks-labs/fastlane-plugin-repack-ios/blob/master/LICENSE)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-repack_ios`, add it to your project by running:

```bash
fastlane add_plugin repack_ios
```

## About repack-ios

This plugin allows you to re-pack your existing .ipa packages with new assets or non-executable resources without rebuilding the native code. It supports fastlane's *sigh* and *match* actions to automatically detect provisioning profiles and certificates for resigning the modified ipa package. Also internally uses Gym configuration arguments to detect build related parameters like output directory etc.

You can use this plugin to modify your react-native js bundle without re-compiling the entire XCode project from the beginning. It significantly reduces the compilation time, especially useful for CI/CD based processes and also for your test automation.

## Examples

The only requires arguments are *ipa* path for the pre-built package and *contents* path for the resources that would like to replace. Basic usage as follows:

```ruby
  repack_ios({ ipa: "./build/ios/TestApp.ipa", output_name: "TestApp", contents: "./build/react-native/" })
```

You can also specify additional parameters to `repack_ios` action. Eg.

```ruby
  repack_ios({
    ipa: "./build/ios/TestApp.ipa",
    contents: "./build/react-native/",
    match_type: "adhoc",  # Optional if you use _sigh_ or _match_
    bundle_id: "com.creaworks.fastlane-app.repacked",
    bundle_version: ENV["CI_BUILD_NUMBER"]
  })
```

## Parameters

| Key           | Description           | Default  |
| ------------- |-----------------------| --------|
| ipa | Path to your original ipa file to modify | *Required* |
| output_name | The product name of the Xcode target | *Required* |
| contents | Path for the new contents | *Required* |
| app_identifier | The bundle identifier of your app | Default value read from Appfile's app_identifier key |
| entitlements | Path to the entitlement file to use, e.g. `myApp/MyApp.entitlements`| Default value can be resolved from *sigh* |
| display_name | Display name to force resigned ipa to use | _Inherited_ |
| version | Version number to force resigned ipa to use. Updates both `CFBundleShortVersionString` and `CFBundleVersion` values in `Info.plist`. Applies for main app and all nested apps or extensions | _Inherited_ |
| short_version | Short version string to force resigned ipa to use (`CFBundleShortVersionString`) | _Inherited_ |
| bundle_version | Bundle version to force resigned ipa to use (`CFBundleVersion`) | _Inherited_ |
| bundle_id | Set new bundle ID during resign (`CFBundleIdentifier`) | _Optional_ |
| match_type | Define the profile type | Optional if you use _sigh_ or _match_ |
| provisioning_profile | Path to your provisioning_profile. | Optional if you use _sigh_ or _match_ |

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).

## License

MIT © [omerduzyol](https://github.com/omerduzyol)
