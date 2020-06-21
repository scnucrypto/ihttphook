# ihttphook
A plugin for iOS http/https network transfer using libcurl instead of CFNetwork. \
The main idea is to create subclasses of NSURLProtocol for custom http protocols and hook NSURLSessionConfiguration class for using the custom http protocol by default. \
Worked for NSURLConnection/NSURLSession/AFNetworing.

## Demo
* run http/https server listening on 80/443 port
```
# cd test-server
# node app.js
```
* select demo target and run iOS demo.app
## App hook
* select ihttphook target and build ihttphook.framework
* inject dynamic library into your app using insert_dylib tool
```
# PATH/TO/insert_dylib_tool  @rpath/ihttphook.framework/ihttphook xx.app/xx
```
* resign and repackage your app
## Lisense
The Apache License is used for this project. See LICENSE file.
## Credits & Thanks
Jason Cox, @jasonacox, https://github.com/jasonacox/Build-OpenSSL-cURL.git \
YANGQIAN, @yangqian111, https://github.com/yangqian111/PPSNetworkMonitor.git \
gengjf, @gengjf, https://github.com/gengjf/insert_dylib.git