require 'zoo.dc.animal_lua'


function getInsideVersion()
  local insideVersion = ""
  if __ANDROID then
    local function getInsideVersion_()
      local disp = luajava.bindClass("com.happyelements.hellolua.StartupConfig")
      insideVersion = disp:getInsideVersion()
      if insideVersion == nil then
        insideVersion = ""
      end
    end
    pcall(getInsideVersion_)
  end
  -- he_log_error("insideVersion = " .. tostring(insideVersion))
  return insideVersion
end



local errors = {}

_G._VALIDATE_DC_DATA = 1
_G._VALIDATE_DC_PLATFORM = {
	_=0,
	apple=1000,
	baiduapp=0,
	he=10000,
	vivo=10000,
	yingyongbao=10000,
}
_G._VALIDATE_DC_JAVA_INSIDE = {}


local function log(s)
	printx(-98, s)
end

local function push_error(s)
	local KEY = 'VALIDATE_DC_'
	he_log_error(KEY .. s)
end

local function rename_field(data)
	log('rename_field')
	local newData = {}
	for k, v in pairs(data) do
		local _k = LuaDpSDK:getNewAttr(k)
		newData[_k] = data[k]
		if _k ~= k then
			log('\t[field] ' .. k .. ' to ' .. _k)
		end
	end
	return newData
end

local function rename_acType_simple(data)
	log('rename_acType_simple')
	local acType = data._ac_type
	local newAcType = LuaDpSDK:getNewAcType(acType)
	if newAcType ~= acType then
		data._ac_type = newAcType
		log('\t[acType] ' .. acType .. ' to ' .. tostring(newAcType))
	end
	return data
end

local function rename_acType_category(data)
	log('rename_acType_category')
	local acType = data._ac_type
	local acCategory = data.category
	local newAcType = LuaDpSDK:getNewAcTypeSplit(acType, acCategory)
	if newAcType ~= acType then
		data._ac_type = newAcType
		log('\t[acType] ' .. acType .. ' to ' .. tostring(newActype))
	end
	return data
end

local function rename_acType(data)
	log('rename_acType')
	if data._ac_type == tostring(101) then
		local newData = rename_acType_category(data)
		return newData
	else
		local newData = rename_acType_simple(data)
		return newData
	end
end

local function checkCharacter(s)
	if string.find(s, ',') then return true end
	if string.find(s, '|') then return true end
	if string.find(s, ':') then return true end
	if string.find(s, "'") then return true end
	if string.find(s, '[') then return true end
	if string.find(s, ']') then return true end
	if string.find(s, '{') then return true end
	if string.find(s, '}') then return true end
	if string.find(s, '&') then return true end
	if string.find(s, '?') then return true end
	if string.find(s, '%') then return true end
	if string.find(s, '\\') then return true end
	if string.find(s, '#') then return true end
	if string.find(s, '"') then return true end
	if string.find(s, '\n') then return true end
	if string.find(s, '\r') then return true end
	if string.find(s, '\f') then return true end
	return false
end

local function addError(s)
	errors[#errors + 1] = s
end

local function clearError()
	errors = {}
end

local function refactor(data)
	log('refactor_structure')
	data = rename_acType(data)
	data = rename_field(data)

	local newData = {}
	local extractmap = {}

	local acType = data._ac_type
	for k, v in pairs(data) do
		--[[
		if checkCharacter(k) then
			addError('illegal key: ' .. tostring(k))
		end
		if checkCharacter(v) then
			addError('illegal value: ' .. tostring(v))
		end
		]]

		if LuaDpSDK:isExistInSchema(acType, k) then
			if newData[k] ~= nil then
				addError('duplicate field: ' .. tostring(k))
			end
			newData[k] = v
			log('\t[to schema] ' .. k)
		else
			if extractmap[k] ~= nil then
				addError('duplicate field extra: ' .. tostring(k))
			end
			extractmap[k] = v
			log('\t[to extra] ' .. k)
		end
	end

--[[
	local payloads = data['payloads']
	if payloads ~= nil then
		for k, v in pairs(payloads) do
			if isExistInSchema(acType, k) then
				if newData[k] ~= nil then
					errors[#errors] = 'duplicate field: ' .. tostring(k)
				end
				newData[k] = v
			else
				if newData['extractmap'] == nil then
					newData['extractmap'] = {}
				end
				local node = newData['extractmap']
				if node[k] ~= nil then
					errors[#errors] = 'duplicate field extra: ' .. tostring(k)
				end
				node[k] = v
			end
		end
	end
	]]

	local json = table.serialize(extractmap)
	newData['extractmap'] = json

	return newData, extractmap
end

local function validate(data)
	clearError()

	local newData, extractmap = refactor(data)
	return newData, extractmap
end

local function isAllowRefactor()
	if not _VALIDATE_DC_DATA then
		return false
	end

    local platformName = StartupConfig:getInstance():getPlatformName()

    local uid = 12345
    if UserManager and UserManager:hadInited() then
		uid = tonumber(UserManager:getInstance().uid) or 0
    end

	local dimi = _VALIDATE_DC_PLATFORM['_']
	if _VALIDATE_DC_PLATFORM[platformName] then
		dimi = _VALIDATE_DC_PLATFORM[platformName]
	end

	local uid10000 = uid % 10000
	if uid10000 >= dimi then
		return false
	end

	return true
end

function refactor_dc_body(data, saveInLuaTable)
	if not isAllowRefactor() then
		log('skip validate')
		if saveInLuaTable then
			_G[saveInLuaTable] = data
		end
		return data
	end

	log('\n\n========\tbegin refactor dc body\t========')
	log('old dc json')
	log(table.serialize(data))
	print('')
	log('old dc body')
	log(table.tostringByKeyOrder(data))

	log('refactor dc body')
	local newData, _extractmap = validate(data)
	log('new dc body')
	log(table.tostringByKeyOrder(newData))

	local pr = LuaDpSDK:checkRequest(newData, _extractmap)
	if(pr:GetSuccess())then
		log("sdk return success")
	else
		local reason = pr:GetErrorReason()
		addError(tostring(reason))
	end

	if #errors > 0 then
		log('errors:')
		local errorMsg = table.tostring(errors)
		log(errorMsg)
		push_error(errorMsg .. '\n<<data>>\n' .. table.serialize(data))
	end

	if saveInLuaTable then
		_G[saveInLuaTable] = newData
	end
	return newData
end


pcall(function()
	if _G._VALIDATE_DC_DATA then
		if __ANDROID then
			HeDCLog:setEnableDcValidation(true)
		elseif __IOS then
			HeDCLog:setEnableDcValidation(true)
			HeDCLog:setEnableDcValidationIos(true)
		else
			HeDCLog:setEnableDcValidation(true)
		end

		if __ANDROID then
		    -- local platformName = StartupConfig:getInstance():getPlatformName()
			local insideVersion = getInsideVersion() or ""
		    print('insideVersion = ' .. insideVersion)
			local java = table.findStr(_G._VALIDATE_DC_JAVA_INSIDE, insideVersion) ~= nil
			local disp = luajava.bindClass("com.happyelements.android.DcSender")
		    disp:setUseSchema(java)
		end
	else
		if __ANDROID then
			HeDCLog:setEnableDcValidation(false)
		elseif __IOS then
			HeDCLog:setEnableDcValidation(false)
			HeDCLog:setEnableDcValidationIos(false)
		else
			HeDCLog:setEnableDcValidation(false)
		end

		if __ANDROID then
			local disp = luajava.bindClass("com.happyelements.android.DcSender")
		    disp:setUseSchema(false)
		end
	end

end)

