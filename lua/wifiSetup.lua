local wifiSetup = {}

function wifiSetup.enter_setup(mainFunc)
   print("Entering WiFi setup mode...")
   enduser_setup.start(
      function()
         print("Connected to wifi as:" .. wifi.sta.getip())
         mainFunc()
      end,
      function(err, str)
         print("enduser_setup: Err #" .. err .. ": " .. str)
      end,
      print -- Lua print function can serve as the debug callback
   )
end

return wifiSetup
