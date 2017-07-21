local led = {}

local config = require("config")

led.create = function(pin)
   local aLed = {}

   gpio.mode(pin, gpio.OUTPUT)

   aLed.on = function()
      gpio.write(pin, gpio.HIGH)
   end

   aLed.off = function()
      gpio.write(pin, gpio.LOW)
   end

   return aLed
end

return led
