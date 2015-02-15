deep_sleep_time = 600
max_connection_attempts = 20
temp = ""
hum = ""
btemp = ""
run_cnt = 0

local function sleep()
	print("sleep")
	node.dsleep(deep_sleep_time * 1000000)
end

function run()
	print("run")
	if run_cnt == 0 then
		local data = dofile("sht1x_v2.lua")
		temp = (data[1])
		hum = (data[2])
		data = nil
		collectgarbage()
		
		btemp = dofile("ds18b20.lua")
		collectgarbage()
		print(temp, hum, btemp)
	end
	
	run_cnt = run_cnt + 1
	
	if wifi.sta.status() ~= 5 then -- not got IP
		if run_cnt > max_connection_attempts then sleep() end
		return
	end

	tmr.stop(0)
	collectgarbage()
	print("send")
	dofile("send.lua")
	tmr.alarm(0, 100, 0, sleep)
end

tmr.alarm(0, 1000, 1, run)
