local deep_sleep_time = 5
local max_connection_attempts = 20
local run_cnt = 0
local temp = nil
local hum = nil
local SLEEP_TIMER = 1

function read_settings()
	if file.open("settings", "r") == nil then return end
	local str = file.read()
	file.close()

	local i = 1
	local vals = {}

	for val in string.gmatch(str, "%d+") do
		vals[i] = tonumber(val)
		i = i + 1
	end
	if vals[1] ~= nil then deep_sleep_time = vals[1] end
	if vals[2] ~= nil then max_connection_attempts = vals[2] end
end

function write_settings()
	local str = string.format("%d,%d", deep_sleep_time, max_connection_attempts)
	if file.open("settings", "w") == nil then return end
	file.write(str)
	file.close()
end

function receive(conn, data)
	tmr.stop(1)
	local i = 1
	local vals = {}

	for val in string.gmatch(data, "%d+") do
		vals[i] = tonumber(val)
		i = i + 1
	end

	if vals[1] == nil or vals[2] == nil then return end
	deep_sleep_time = (vals[1])
	max_connection_attempts = (vals[2])
	write_settings()

	wifi.sta.disconnect()
	sleep()
end

function sleep()
	node.dsleep(deep_sleep_time * 1000000)
end

function run()
	if run_cnt == 0 then
		read_settings()
		local sht = require("sht1x")
		sht.init(4, 3)
		temp = sht.get_raw_temperature()
		hum = sht.get_raw_humidity()
	end

	run_cnt = run_cnt + 1

	if wifi.sta.status() ~= 5 then -- not got IP
		if run_cnt > max_connection_attempts then sleep() end
		return
	end

	tmr.stop(0)

	conn = net.createConnection(net.UDP)
	conn:on("receive", receive)
	res = conn:connect(8266, "192.168.0.66")
	str = string.format("%d,%d,%d,%d", temp, hum, deep_sleep_time, max_connection_attempts)
	conn:send(str)
	print(node.heap())

	tmr.alarm(1, 500, 0, function() wifi.sta.disconnect() sleep() end)
end
