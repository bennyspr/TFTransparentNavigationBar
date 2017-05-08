# TFTransparentNavigationBar

![preview](https://github.com/thefuntasty/TFTransparentNavigationBar/blob/master/Example/TFTransparentNavigationBar/preview.gif)

## Usage

In order to make transparent navigation bar you need set your navigation controller class to TFNavigationController. Then in your controllers implement TFTransparentNavigationBarProtocol which has only one method `navigationControllerBarPushStyle() -> TFNavigationBarStyle`. You have to return if your bar should be `.Solid` or `.Transparent`. The default style is .Solid therefore you can implement the protocol only for controllers you want to have a transparent bar. 

## Requirements

iOS 8 and later. <br />
No Apple-private API used. <br />
For Swift 2.3 use branch swift2.3

## Installation

TFTransparentNavigationBar is available through [CocoaPods](http://cocoapods.org). <br /> 
To install it, simply add the following line to your Podfile:

```ruby
pod 'TFTransparentNavigationBar', :git => "https://github.com/bennyspr/TFTransparentNavigationBar.git", :branch => 'swift2.3'
```

## License

TFTransparentNavigationBar is available under the MIT license. See the LICENSE file for more info.
