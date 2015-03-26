local i = 1
local val
local vals = {}

for val in string.gmatch(new_settings, "%d+") do
	vals[i] = tonumber(val)
	i = i + 1
end

if vals[1] ~= nil then deep_sleep_time = vals[1] end
if vals[2] ~= nil then max_connection_attempts = vals[2] end

if deep_sleep_time ~= nil and max_connection_attempts ~= nil then
	if file.open("settings", "w") == nil then return end
	print("write settings:", deep_sleep_time, max_connection_attempts)
	file.write(deep_sleep_time..","..max_connection_attempts)
	file.close()
end
