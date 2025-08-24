local function DebugLog(msg)
	if not TIAN_WHEREISIT_GLOBAL_DATA.SETTINGS.DEBUG_MODE then
		return
	end
	print("[Where Is It] " .. tostring(msg))
end

return DebugLog
