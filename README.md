**How to Build EyeTemp App**

1. Clone repo to you local directory
2. Install `CocoaPods` if you haven't installed it yet. Use [this tutorial](https://guides.cocoapods.org/using/getting-started.html) to install cocoa pods 
2. Open a terminal at your source root (Directory where the `Podfile` is located)
3. Run `pod install` at the command prompt
4. Once cocoapods installation is finished open the `.xcodeworspace`
5. This will open XCode and hit build. Your app should be build by now

**Things to lookout**

The app follows a functional programming paradigm. I have used `RxSwift` a popular `functional programming` framework. The source code follows a MVVM architecture. So if anyone who is trying to compile and follow the code should have a fair understanding of `RxSwift` and functional programming.

