# 1MillionBot client SDK for iOS

## Installation
### Swift Package Manager

+ File > Swift Packages > Add Package Dependency
+ Add https://github.com/1millionbot/ios-sdk
+ Select "Up to Next Major" with "1.0.0"

## How to use it
First of all you must add to your __NSMicrophoneUsageDescription__ and  __NSSpeechRecognitionUsageDescription__ to your _Info.plist_, as this library makes use of both permissions for the user to be able to dictate messages to our bot.

Initialize the SDK at start-up time on your `AppDelegate` by calling `OneMillionBot.initialize` and supplying your designated api key:

```swift
OneMillionBot.initialize(
    apiKey: <myApiKey>
)
```

By default, all the non fatal errors will be logged to the stdout using `Swift.print` if the build type is `Debug`, you can change this behaviour by supplying your own implementation, as such:

```swift
OneMillionBot.initialize(
    apiKey: <myApiKey>, 
    logger: { string in
        // my custom loggin behaviour
    }
)
```

`OneMillionBot.initialize` also accepts an `APIEnv`, if none is supplied `APIEnv.production` is used, which points to 1MillionBot production servers. If you need to use the staging server, you can supply `APIEnv.staging` when calling `OneMillionBot.initialize`:

```swift
OneMillionBot.initialize(
    apiKey: <myApiKey>,
    apiEnv: .staging
)
```

Then you can just add `OneMillionBotView` to your ViewController using Interface Builder or just programatically like so:

```swift
let bot = OneMillionBotView(.bottomRight)
view.addSubview(bot)

NSLayoutConstraint.activate([
    bot.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
    bot.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
    bot.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
])
```
