# repack_ios plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-repack_ios)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-repack_ios`, add it to your project by running:

```bash
fastlane add_plugin repack_ios
```

## About repack_ios

This plugin allows you to repack your existing .ipa packages with new assets or non-executable resources without rebuilding the native code. It supports fastlane's *sigh* and *match* actions to automatically detect provisioning profiles and certificates for resigning the modified ipa package. Also internally uses Gym configuration arguments to detect build related parameters like output directory etc.

You can use this plugin to modify your react-native js bundle without re-compiling the entire XCode project from the beginning. It significantly reduces the compilation time, especially useful for CI/CD based processes and also for your test automation.

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