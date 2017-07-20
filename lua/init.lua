-- Config
local pinButton1 = 5
local pinButton2 = 1
local pinLed1    = 6
local pinLed2    = 2
local pubTimer   = tmr.create()
local mqttCli    = mqtt.Client("mqttButton", 120) 

local wifiSetup = require("wifiSetup")

function invert(old)
   if old == gpio.LOW then
      return gpio.HIGH
   else
      return gpio.LOW
   end
end

function msecs(time)
   return ((time.hours * 60 + time.minutes) * 60 + time.seconds) * 1000
end

function main()
   mqttCli:on("connect", function(client) print ("connected") end)
   mqttCli:on("offline", function(client) print ("offline") end)

   print("MQTT connecting")
   mqttCli:connect("192.168.10.118", 1883, 0, function(client)
      print("MQTT connected")

      -- temp/humidity timer
      pubTimer:alarm(msecs({
         hours   = 0,
         minutes = 5,
         seconds = 0
      }), tmr.ALARM_AUTO, function()
         local value = tmr.now()
         client:publish("home/test/graph", value, 0, 0)
      end)

      gpio.trig(pinButton1, "both", 
         function(level, time)
            gpio.write(pinLed1, invert(level))
            print("Button 1 pressed")
         end
         )
      gpio.trig(pinButton2, "both", 
         function(level, time)
            gpio.write(pinLed2, invert(level))
            print("Button 2 pressed")
         end
         )
   end)
end

-- Setup
gpio.mode(pinButton1, gpio.INPUT)
gpio.mode(pinButton2, gpio.INPUT)
gpio.mode(pinLed1, gpio.OUTPUT)
gpio.mode(pinLed2, gpio.OUTPUT)
wifi.setmode(wifi.STATION)
wifi.sta.autoconnect(1)

-- Check for "setup" button
button1Value = gpio.read(pinButton1)
button2Value = gpio.read(pinButton2)
if button1Value == gpio.LOW and button2Value == gpio.LOW then
   wifiSetup.enter_setup(main)

else
   print("Performing normal startup...")
   print("Current WiFi status: " .. wifi.sta.status())
   if wifi.sta.status() == wifi.STA_GOTIP then
         print("Got IP. starting main...")
      main()

   else
      print("No ip. waiting...")
      wifi.sta.eventMonReg(wifi.STA_GOTIP, function()
         print("Got IP. starting main...")
         main()
      end)
   end
end

wifi.sta.eventMonStart()
