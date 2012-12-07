# WhereAmI
A quick command line tool to get your geographic coordinates using the OS X [CoreLocation][]) framework.

Download a zip with the latest version [here][download link].

## Usage
Open with Finder to execute, or in the terminal. If it can determine a location, it will output longitude, latitude, accuracy in meters and the time the location was found. WhereAmI tries to get a recent location, and will not display one if it is more than a minute old (to avoid inaccurate results from CoreLocation's cached data). If it cannot get location data, it will quit and print an error message.

## Notes
This is a quick and dirty example. I make no guarantees or warranties as to its accuracy, stability or compatibility (it should work with 10.7 and 10.8, but I have only tested it on 10.7). Feel free to do with it as you wish.

## Changelog
### 1.02
 - Fixed missing `@autoreleasepool`. Shouldn't be any practical changes, but it's good form.

### 1.01
- WhereAmI will now check if Wi-Fi is not enabled and tell the user such if it can't get location data.

[corelocation]: http://en.wikipedia.org/wiki/CoreLocation
[download link]: https://github.com/downloads/robmathers/WhereAmI/whereami-1.02.zip