local wificontroller = loadfile("service/wificontroller.lc")()
local doorcontroller = loadfile("service/doorcontroller.lc")()

-- Default conf for wifi
wifi.ap.dhcp.stop()
wifi.sleeptype(wifi.NONE_SLEEP)
wifi.setphymode(wifi.PHYMODE_N)

if file.open("config/wifi.conf", "r") then
 -- Wifi settings exist. Start system
 local cred = wificontroller.readcredentials()

 -- Set mode Station
 wifi.setmode(wifi.STATION)
 print("---------------------------------")
 print("WEAOS Garage Door Wifi Controller")
 print("  https://www.weareopensource.me ")
 print("---------------------------------")
 print("Connection to SSID: '" .. cred.ssid .. "'")
 success, res = pcall(wifi.sta.config, cred.ssid, cred.key)
 if success then
  wifi.sta.connect()
 else
  file.remove("config/wifi.conf")
  return
 end
 local attempts = 0
 tmr.alarm(1, 1000, 1, function()
  attempts = attempts + 1
  if wifi.sta.getip() == nil then
   print("IP unavailable, Waiting...")
  else
   tmr.stop(1)
   print("MAC address is: " .. wifi.ap.getmac())
   print("IP is " .. wifi.sta.getip())
   -- Init GPIOs
   doorcontroller.init()
   -- Register Multicast DNS
   mdns.register("weaos-garage-" .. node.chipid(), {description = "WEAOS garage door service", service = "http", port = 80, location = "Basement"})
   dofile("server.lc")
  end
  if attempts > 30 then
   file.remove("config/wifi.conf")
  end
 end)
else
 print("No wifi settings. Setup Mode")
 wificontroller.setupAP()
 dofile("server_setup.lc")
end
