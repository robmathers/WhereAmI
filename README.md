# WhereAmI
A quick command line tool to get your geographic coordinates using the OS X [CoreLocation][] framework, and optionally get human-readable geolocation data (address, etc.) via the [OpenCage API][opencage].

Download a zip with the latest version [here][download link].

## Usage
Open with Finder to execute, or in the terminal. If it can determine a location, it will output longitude, latitude, accuracy in meters and the time the location was found. WhereAmI tries to get a recent location, and will not display one if it is more than a minute old (to avoid inaccurate results from CoreLocation's cached data). If it cannot get location data, it will quit and print an error message.

Example:
```
whereami
```
Output:
```
Latitude: 45.424807, 
Longitude: -75.699234
Accuracy (m): 65.000000
Timestamp: 2019-09-28, 12:40:20 PM EDT
```

### Geolocation with OpenCage
(Available from version 1.1)
Use the `-k` flag, followed by your OpenCage API key (available [here](https://opencagedata.com/users/sign_up)), to get human readable location data.

Example:
```
whereami -k API_KEY_HERE
```
Output:
```
Latitude: 45.424807, 
Longitude: -75.699234
Accuracy (m): 65.000000
Timestamp: 2019-09-28, 12:40:20 PM EDT
111 Wellington St, Ottawa,ON K1A 0A6, Canada
```

## Notes
This is provided on an as-is basis. I make no guarantees or warranties as to its accuracy, stability or compatibility. It should be compatible with Mac OS 10.7 and above. Feel free to do with it as you wish.

## Changelog
### 1.02
 - Fixed missing `@autoreleasepool`. Shouldn't be any practical changes, but it's good form.

### 1.01
- WhereAmI will now check if Wi-Fi is not enabled and tell the user such if it can't get location data.

[corelocation]: http://en.wikipedia.org/wiki/CoreLocation
[opencage]: https://opencagedata.com/
[download link]: https://github.com/robmathers/WhereAmI/releases/download/v1.02/whereami-1.02.zip
