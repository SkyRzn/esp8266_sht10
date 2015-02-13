if deep_sleep_time ~= nil and max_connection_attempts ~= nil then
	if file.open("settings", "w") == nil then return end
	file.write(deep_sleep_time..","..max_connection_attempts)
	file.close()
end
