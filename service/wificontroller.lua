local ssidprefix = "weaos-"

local readcredentials = function()
 local ssid, key, password
 if file.open("config/wifi.conf", "r") then
  ssid = string.gsub(file.readline(), "\n", "");
  key = string.gsub(file.readline(), "\n", "");
  password = string.gsub(file.readline(), "\n", "");
  return { ssid = ssid, key = key, password = password }
 end
 return nil
end

local setupAP = function()
 print("Setting up Access Point")
 wifi.setmode(wifi.STATIONAP)
 local cfg = {}
 cfg.ssid = ssidprefix .. node.chipid()
 cfg.password = "bullshit"
 cfg.auth = wifi.AUTH_OPEN
 cfg.channel = 10
 -- Init config
 wifi.ap.config(cfg)
 -- Init AP IP
 cfg = {
  ip = "10.0.0.1",
  netmask = "255.255.255.0",
  gateway = "10.0.0.1"
 }
 wifi.ap.setip(cfg)
 -- Init AP DHCP config
 cfg = {}
 cfg.start = "10.0.0.2"
 wifi.ap.dhcp.config(cfg)
 wifi.ap.dhcp.start()
end

local savesettings = function(conf)
 -- Save changes to file
 file.open("config/wifi.conf", "w+")
 file.writeline(conf.ssid)
 file.writeline(conf.key)
 file.writeline(conf.password)
 file.flush()
 file.close()
end

return { setupAP = setupAP, readcredentials = readcredentials, savesettings = savesettings }
