local button = {}

local config = require("config")

local ledPin
local value
local timer = tmr.create()

function button.create(pin, mqttClient, topic)
   btn = {}

   btn.value = gpio.LOW
   btn.locked = false
   btn.timer = tmr.create()
   btn.timer:register(500, tmr.ALARM_SINGLE, function (t)
      btn.locked = false
   end)

   btn.handleEdge = function(level, time)
      if not locked then
         btn.value = level
         btn.locked = true
         btn.timer:start()
         if btn.value == gpio.LOW then
            mqttClient:publish(config.mqttTopicBase .. topic, 1, 0, 0)
         else
            mqttClient:publish(config.mqttTopicBase .. topic, 0, 0, 0)
         end
      end
   end

   gpio.mode(pin, gpio.INPUT)
   gpio.trig(pin, "both", btn.handleEdge)

   return btn
end

return button
