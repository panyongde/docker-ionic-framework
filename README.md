# 运行
```
alias ion="docker run -ti --rm --net host --privileged -v /dev/bus/usb:/dev/bus/usb -v ~/.gradle:/root/.gradle -v \$PWD:/myApp:rw panyongde/cordova-ionic ionic"
```

