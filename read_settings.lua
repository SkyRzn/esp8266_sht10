if file.open("settings", "r") == nil then return end
local str = file.read()
file.close()

local i = 1
local val
local vals = {}

for val in string.gmatch(str, "%d+") do
	vals[i] = tonumber(val)
	i = i + 1
end
if vals[1] ~= nil then deep_sleep_time = vals[1] end
if vals[2] ~= nil then max_connection_attempts = vals[2] end


