local dimmer = {}

local ledPin
local value
local timer = tmr.create()

function dimmer.init(pin)
   ledPin = pin
   value = 0
   pwm.setup(ledPin, 500, 0)
   pwm.start(ledPin)
end

function dimmer.changeDutyCycle(duty)
   pwm.setduty(ledPin, math.floor((1 - (duty / 100)) * 1023))
end

return dimmer
