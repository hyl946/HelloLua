local SaveDataServer = {}

local saveDataKey = {
	kEnergyActQuest = 'energy_act_quest',
}

SaveDataServer.DataKey = saveDataKey

local function get_save_file_name( key )
	local uid = UserManager:getInstance().uid or '12345'


	
	return key .. '_shadow_' .. uid .. '_happy_new_year_'
end

function SaveDataServer:write( key, data )
	Localhost.getInstance():writeToStorage(data, get_save_file_name(key))
	-- printx(61, 'SaveDataServer:write', key)
end

function SaveDataServer:read( key)
	-- printx(61, 'SaveDataServer:read', key)
	return Localhost.getInstance():readFromStorage(get_save_file_name(key))
end

return SaveDataServer