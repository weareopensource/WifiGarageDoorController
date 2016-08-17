#/bin/bash
baud=$2
if [ -z "$1" ]; then
 echo "This script requires an argument: USB device port"
 exit 1;
fi
if [ -z "$2" ]; then
 echo "Setting baudrate to default: 115200"
 baud=115200
 #Default nodemcu 1.5+ baudrate
fi

nodemcu-tool upload config/door.1.conf -k --port $1 --baud $baud
nodemcu-tool upload config/door.2.conf -k --port $1 --baud $baud
nodemcu-tool upload config/door.1.state -k --port $1 --baud $baud
nodemcu-tool upload config/door.2.state -k --port $1 --baud $baud
nodemcu-tool upload config/doors.conf -k --port $1 --baud $baud
nodemcu-tool upload routes/register.post.lua -k --compile --optimize --port $1 --baud $baud
nodemcu-tool upload routes/restart.post.lua -k --compile --optimize --port $1 --baud $baud
nodemcu-tool upload routes/ssids.get.lua -k --compile --optimize --port $1 --baud $baud
nodemcu-tool upload routes/state.get.lua -k --compile --optimize --port $1 --baud $baud
nodemcu-tool upload init.lua -k --port $1 --baud $baud
nodemcu-tool upload service/doorcontroller.lua -k --compile --optimize --port $1 --baud $baud
nodemcu-tool upload service/wificontroller.lua -k --compile --optimize --port $1 --baud $baud
nodemcu-tool upload static/favicon.ico -k --port $1 --baud $baud
nodemcu-tool upload static/favicon-96x96.png -k --port $1 --baud $baud
nodemcu-tool upload static/index.html -k --port $1 --baud $baud
nodemcu-tool upload static/script.js -k --port $1 --baud $baud
nodemcu-tool upload static/spinner.gif -k --port $1 --baud $baud
nodemcu-tool upload static/style.css -k --port $1 --baud $baud
nodemcu-tool upload server.lua -k --compile --optimize --port $1 --baud $baud
nodemcu-tool upload server_setup.lua -k --compile --optimize --port $1 --baud $baud
nodemcu-tool upload routes_custom.lua -k --compile --optimize --port $1 --baud $baud
