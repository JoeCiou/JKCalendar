<p align="center"><img src="https://cdn.rawgit.com/JoeCiou/JKCalendar/513e2d53/Resources/banner.png" width="">

# JKCalendar
![](https://travis-ci.org/JoeCiou/JKCalendar.svg?branch=master)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/JKCalendar.svg)](http://cocoadocs.org/docsets/JKCalendar)
[![Platform](https://img.shields.io/cocoapods/p/JKCalendar.svg)](http://cocoadocs.org/docsets/JKCalendar)
[![Swift 3.x](https://img.shields.io/badge/Swift-3.x-orange.svg?style=flat)](https://swift.org/)
[![Swift 4.0](https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat)](https://swift.org/)
## Screenshot
<img src="https://cdn.rawgit.com/JoeCiou/JKCalendar/513e2d53/Resources/scroll_video.gif" width="300">   <img src="https://cdn.rawgit.com/JoeCiou/JKCalendar/513e2d53/Resources/page_video.gif" width="300">

## Requirements
- iOS 9.0+
- Xcode 8+

## Installation
#### CocoaPods
To install add the following line to your `Podfile`:
```ruby
pod 'JKCalendar'
```

#### Carthage
To install add the following line to your `Cartfile`:
```ruby
github "JoeCiou/JKCalendar"
```

## Usage

Firstley, import `JKCalendar`
```swift
import JKCalendar
```

### Initialization
Then, there are to two ways you can create JKCalendar:
- By storyboard, change class of any `UIView` to JKCalendar

_**Note:** Set Module to `JKCalendar`._

- By code, using initializer.
```swift
let calendar = JKCalendar(frame: frame)
```

### Mark
```swift
public enum JKCalendarMarkType{
    case circle
    case hollowCircle
    case underline
    case dot
}
```
For single mark:
<img src="https://cdn.rawgit.com/Joe22499/JKCalendar/3de876ad/Resources/mark_type_single.png">
For continuous mark:
<img src="https://cdn.rawgit.com/Joe22499/JKCalendar/3de876ad/Resources/mark_type_continuous.png">

#### Examples
Firstley, Setup data source:
```swift
calendar.dataSource = self
```
For single mark:
```swift
func calendar(_ calendar: JKCalendar, marksWith month: JKMonth) -> [JKCalendarMark]? {
    let today = JKDay(date: Date())
    if today == month{
        return [JKCalendarMark(type: .underline, day: today, color: UIColor.red)]
    }else{
        return nil
    }
}
```
For continuous mark:
```swift
func calendar(_ calendar: JKCalendar, continuousMarksWith month: JKMonth) -> [JKCalendarContinuousMark]?{
    let markStartDay = JKDay(year: 2017, month: 9, day: 3)!
    let markEndDay = JKDay(year: 2017, month: 9, day: 12)!
    if markStartDay == month || markEndDay == month{
        return [JKCalendarContinuousMark(type: .circle, start: markStartDay, end: markEndDay, color: UIColor.red)]
    }else{
        return nil
    }
}
```

## License
The MIT License (MIT)

copyright (c) 2017 Joe Ciou


