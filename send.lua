local server_ip = "192.168.0.66"
local server_port = 8266


local function receive(conn, data)
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

end

local function send()
	local conn = net.createConnection(net.UDP)
	conn:on("receive", receive)
	conn:connect(server_port, server_ip)
-- 	local str = string.format("%d,%d,%d,%d", temp, hum, deep_sleep_time, max_connection_attempts)

-- 	conn:send(str)
-- 	str = nil
	conn:close()
end

send()

