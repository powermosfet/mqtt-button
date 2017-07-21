local wifiSetup = require("wifiSetup")
local config    = require("config")
local button    = require("button")
local led       = require("led")

local pubTimer = tmr.create()
local mqttCli  = mqtt.Client(config.mqttClientName, config.mqttClientTimeout)
local btn1     = button.create(config.board.pinButton1, mqttCli, config.mqttTopicButton1)
local btn2     = button.create(config.board.pinButton2, mqttCli, config.mqttTopicButton2)
local led1     = led.create(config.board.pinLed1)
local led2     = led.create(config.board.pinLed2)

am2320.init(config.board.pinAm2320Sda, config.board.pinAm2320Scl)

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
   mqttCli:connect(config.mqttServerHost, config.mqttServerPort, 0, function(client)
      print("MQTT connected")

      client:subscribe(config.mqttTopicBase .. config.mqttTopicLed1, 0, function(conn)
         print("subscribe to LED1 success")

         client:subscribe(config.mqttTopicBase .. config.mqttTopicLed2, 0, function(conn)
            print("subscribe to LED2 success")
         end)
      end)

      client:on("message", function(client, topic, message)
         if topic == config.mqttTopicBase .. config.mqttTopicLed1 then
            if message == "1" then
               led1.on()
            else
               led1.off()
            end
         end

         if topic == config.mqttTopicBase .. config.mqttTopicLed2 then
            if message == "1" then
               led2.on()
            else
               led2.off()
            end
         end
      end)

      -- temp/humidity timer
      pubTimer:alarm(msecs(config.am2320Interval), tmr.ALARM_AUTO, function()
         local rh = 0
         local t = 0
         rh, t = am2320.read()
         client:publish(config.mqttTopicBase .. "temperature", t / 10, 0, 0)
         print("Publishing temp: " .. t / 10)
         client:publish(config.mqttTopicBase .. "humidity", rh / 10, 0, 0)
         print("Publishing humidity: " .. rh / 10)
      end)
   end)
end

-- Setup
wifi.setmode(wifi.STATION)
wifi.sta.autoconnect(1)

-- Check for "setup" button
button1Value = gpio.read(config.board.pinButton1)
button2Value = gpio.read(config.board.pinButton2)
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
