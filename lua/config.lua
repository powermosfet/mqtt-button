local config = {}

config.board                = require("board_v_1_0")
config.mqttClientName       = "MQTTButton1"
config.mqttClientTimeout    = 120
config.mqttServerHost       = "192.168.10.118"
config.mqttServerPort       = 1883
config.am2320Interval       = {
   hours   = 0,
   minutes = 5,
   seconds = 0
}
config.mqttTopicBase        = "home/shed/"
config.mqttTopicTemperature = "temperature"
config.mqttHumidity         = "humidity"
config.mqttTopicButton1     = "button1"
config.mqttTopicButton2     = "button2"
config.mqttTopicLed1        = "led1"
config.mqttTopicLed2        = "led2"

return config
