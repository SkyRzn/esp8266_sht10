server_ip = "192.168.0.66"
server_port = 8266
deep_sleep_time = 600
max_connection_attempts = 20
run_cnt = 0
new_settings = nil

battery = dofile("battery.lua")
collectgarbage()

data = dofile("sht1x_v3.lua")
temp = (data[1])
hum = (data[2])
data = nil
collectgarbage()
print(temp, hum)

btemp = dofile("ds18b20_v3.lua")
collectgarbage()
print("btemp", btemp)

dofile("read_settings.lua")
collectgarbage()

local function sleep()
	print("sleep")
	node.dsleep(deep_sleep_time * 1000000)
end

function receive(conn, data)
	tmr.stop(0)
	new_settings = data
	dofile("write_settings.lua")
	sleep()
end

function run()
	run_cnt = run_cnt + 1
	print("run", run_cnt)
	
	if wifi.sta.status() ~= 5 then -- not got IP
		if run_cnt > max_connection_attempts then sleep() end
		return
	end

	tmr.stop(0)
	collectgarbage()

	print("send", temp, hum, btemp)

	local conn = net.createConnection(net.UDP)
	conn:on("receive", receive)
	conn:connect(server_port, server_ip)
	conn:send(temp..","..hum..","..btemp..","..battery..","..deep_sleep_time..","..max_connection_attempts..","..run_cnt)
	tmr.wdclr()
	temp = nil
	hum = nil
	btemp = nil
	collectgarbage()
	tmr.alarm(0, 200, 0, function() conn:close() sleep() end)
end

tmr.alarm(0, 1000, 1, run)
