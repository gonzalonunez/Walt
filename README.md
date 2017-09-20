![Icon](/Walt%20Icon.png)
# Walt

[![CI Status](http://img.shields.io/travis/gonzalonunez/Walt.svg?style=flat)](https://travis-ci.org/gonzalonunez/Walt)
[![Version](https://img.shields.io/cocoapods/v/Walt.svg?style=flat)](http://cocoapods.org/pods/Walt)
[![License](https://img.shields.io/cocoapods/l/Walt.svg?style=flat)](http://cocoapods.org/pods/Walt)
[![Platform](https://img.shields.io/cocoapods/p/Walt.svg?style=flat)](http://cocoapods.org/pods/Walt)

Aptly named after one of the greatest animators of all time, Walt can turn a series of images into a gif or a video!

Walt is part of a larger effort to open source [Giffy](https://appsto.re/us/gSgd2.i).

## Installation

Walt is available through [CocoaPods](http://cocoapods.org). To use it, simply add `pod 'Walt'` to your Podfile. Make sure that `use_frameworks!` is also in your Podfile.

It should look something like this:

```ruby
use_frameworks!

target '<MY_TARGET_NAME>' do
  pod 'Walt'

  target '<MY_TEST_TARGET_NAME>' do
    inherit! :search_paths

  end
end
``````

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

Gonzalo Nuñez, hello@gonzalonunez.me

Twitter: [@gonzalo__nunez](https://twitter.com/gonzalo__nunez)

## License

Walt is available under the MIT license. See the LICENSE file for more info.

## Notes

As of right now, this is simply a direct Swift 3 port of existing code that I had – the original code is like 2+ years old. There will need to be a few more things before I can call this v1.0:

1. Unit Tests with extensive code coverage
2. Markup comments and documentation

Also, more than anything this library gives me the ability to isolate and modularize a lot of the functionality inside of some of my existing apps. With that being said, many of the features added to this will be influenced by goals I have with apps that use this. If for some reason this actually gets starred and used, other developers will be influencing that as well :)
