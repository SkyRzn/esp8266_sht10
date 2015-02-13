local server_ip = "192.168.0.66"
local server_port = 8266
local deep_sleep_time = 2
local max_connection_attempts = 20
local run_cnt = 0
local temp = nil
local hum = nil


local function receive(conn, data)
	tmr.stop(0)
	local i = 1
	local val
	local vals = {}

	for val in string.gmatch(data, "%d+") do
		vals[i] = tonumber(val)
		i = i + 1
	end

	if vals[1] == nil or vals[2] == nil then return end
	deep_sleep_time = (vals[1])
	max_connection_attempts = (vals[2])

	dofile("write_settings.lua")
	sleep()
end

local function sleep()
	node.dsleep(deep_sleep_time * 1000000)
end

function run()
	print (node.heap())
	if run_cnt == 0 then
		dofile("read_settings.lua")

		collectgarbage()

		local sht = dofile("sht1x_v2.lua")

		temp = (sht[1])
		hum = (sht[2])

		print (temp, hum)

		sht = nil
		collectgarbage()
	end

	run_cnt = run_cnt + 1

	print (wifi.sta.status())
	if wifi.sta.status() == 1 then -- not got IP
		if run_cnt > max_connection_attempts then sleep() end
		return
	end

	tmr.stop(0)

	local conn = net.createConnection(net.UDP)
	conn:on("receive", receive)
	conn:connect(server_port, server_ip)
	local str = string.format("%s,%s,%d,%d", temp, hum, deep_sleep_time, max_connection_attempts)
	conn:send(str)
	conn:close()

	tmr.alarm(0, 500, 0, function() sleep() end)
end
