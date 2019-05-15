local actFileDir = "zoo/localActivity/UserCallBackTest"
local actFileDir_res = "ui/UserCallBackTest"
local function getActFileFullPath_src(file)
	assert(type(file) == "string")
	if string.starts(file, "/") then return actFileDir .. file
	else return actFileDir .. "/" .. file end
end

local function getActFileFullPath_res(file)
	assert(type(file) == "string")
	if string.starts(file, "/") then return actFileDir_res .. file
	else return actFileDir_res .. "/" .. file end
end
local config = {
	actId = 3009,
	topLevelId = 1,
	playIconAnim = true,
	src = {
		getActFileFullPath_src("src/Start.lua"),
		getActFileFullPath_src("src/model/ActModel.lua"),
		getActFileFullPath_src("src/model/ActRewardModel.lua"),
		getActFileFullPath_src("src/view/ActBasePanel.lua"),
		getActFileFullPath_src("src/model/Http.lua"),
		getActFileFullPath_src("src/model/Model.lua"),
		getActFileFullPath_src("src/view/MainPanel.lua"),
		getActFileFullPath_src("src/view/FirstDayPanel.lua"),
		getActFileFullPath_src("src/component/DayRender.lua"),
		getActFileFullPath_src("src/component/LastDayRender.lua"),
	},
	resource = {
		-- getActFileFullPath_res("localization/zh_CN/Text.strings"),
		getActFileFullPath_res("res/new_panel.json"),
	},
	startLua = getActFileFullPath_src("src/Start.lua"),
	iconManualAdjustX = 0,
	iconManualAdjustY = 0,
	notLoginPlayIconAnim = false,
	unsupportPrePackages = false,
	unsupportedPlatforms = {},
	leftRegionLayoutBar = false,

    iconIndexKey = 'user_callback_btn',
    iconShowPriority = 99, 
    iconHomeSceneRegion = 2,  
    iconShowHideOption = 2,

	icon = {
        startLua = getActFileFullPath_src("src/Icon.lua"),
        src = {
            getActFileFullPath_src("src/Icon.lua"),
        },
        resource = {
            SpriteUtil:getRealResourceName(getActFileFullPath_res("icon/icon.png")),
            SpriteUtil:getRealResourceName(getActFileFullPath_res("icon/iconText.png")),
        }
    },

    update_flag_value = 1,
}

local ver = tonumber(string.split(_G.bundleVersion, ".")[2])
if ver < 43 and not __WIN32 then
	if _G.__use_small_res then
		config.icon = getActFileFullPath_res("icon/oldVerIcon@2x.png")
	else
		config.icon = getActFileFullPath_res("icon/oldVerIcon.png")
	end
else
	config.icon = {
        startLua = getActFileFullPath_src("src/Icon.lua"),
        src = {
            getActFileFullPath_src("src/Icon.lua"),
        },
        resource = {
            SpriteUtil:getRealResourceName(getActFileFullPath_res("icon/icon.png")),
            SpriteUtil:getRealResourceName(getActFileFullPath_res("icon/iconText.png")),
        }
    }
end

local resourceList = nil
if _G.__use_small_res then
	resourceList = {
		"res/new_panel@2x.png",
    	"res/new_panel@2x.plist",
    	"skeleton/anim@2x/skeleton.xml",
    	"skeleton/anim@2x/texture.png",
		"skeleton/anim@2x/texture.xml",
    	-- 'res/frames/arrow@2x.png',
    	-- 'res/frames/arrow@2x.plist',
        'fnt/user_callback_numbers@2x.png',
        'fnt/user_callback_numbers@2x.fnt',
}
else
	resourceList = {
		"res/new_panel.png",
    	"res/new_panel.plist",
    	"skeleton/anim/skeleton.xml",
    	"skeleton/anim/texture.png",
		"skeleton/anim/texture.xml",
    	-- 'res/frames/arrow.png',
    	-- 'res/frames/arrow.plist',
        'fnt/user_callback_numbers.png',
        'fnt/user_callback_numbers.fnt',
	}
end

if resourceList then
	for _, v in pairs(resourceList) do
		table.insert(config.resource, getActFileFullPath_res(v))
	end
end

local beginTime = {year=2016, month=9, day=16, hour=10, min=0, sec=0}
local endTime =   {year=2030, month=9, day=16, hour=23, min=59, sec=59}
local realEndTime = table.clone(endTime)

function config.setAttributes( attrs )  --用 activity_config_ios_audit.xml 里配置的数据覆盖当前数据
	local function parseTime( str,default )
		local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
		local year, month, day, hour, min, sec = string.match(str,pattern)
		if year and month and day and hour and min and sec then
			return {
				year=tonumber(year), 
				month=tonumber(month), 
				day=tonumber(day), 
				hour=tonumber(hour), 
				min=tonumber(min), 
				sec=tonumber(sec),
			}
		else
			return default
		end
	end

	local function parseInt( str,default )
		return tonumber(str) or default
	end

	if attrs.beginTime then --活动开始时间
		beginTime = parseTime(attrs.beginTime,beginTime)
	end

	if attrs.endTime then --活动结束时间
		endTime = parseTime(attrs.endTime, endTime)
	end

	if attrs.topLevelId then --解锁活动的玩家topLevelId
		config.topLevelId = parseInt(attrs.topLevelId, config.topLevelId) 
	end
end

function config.getDayStartTimeByTS(ts)
	if ts ~= nil then
		local utc8TimeOffset = 57600
		local dayInSec = 86400
		return ts - ((ts - utc8TimeOffset) % dayInSec)
	end
	
	return 0
end

function config.isActBegin( ... )
	return Localhost:timeInSec() > os.time(beginTime)
end

function config.setEndTime(time)
	endTime = time
end

function config.isActEnd( ... )
	if type(endTime) == "number" then
		return Localhost:timeInSec() >= endTime
	end
	
	return Localhost:timeInSec() >= os.time(endTime)
end

function config.getLevelStartDayByTS( ... )
	return config.getDayStartTimeByTS(os.time(levelActivityStartTime))
end

function config.getLevelStartByTS( ... )
	return os.time(levelActivityStartTime)
end

function config.isShowMsgNum( ... )
	return true
end

function config.isUnSupportPkg( ... )
	if _G.isPrePackage or __WP8 then
		return true
	end

	return false
end

function config.isVersionSupport( ... )
	local ver = tonumber(string.split(_G.bundleVersion, ".")[2])
	return ver > 57
end

function config.isCompatibleVersion(versionCode)
	local ver = tonumber(string.split(_G.bundleVersion, ".")[2]) or 0
	return ver >= versionCode
end

function config.hasUpdateFlag()
    local update_flag = (_G.__UserCallback and _G.__UserCallback >= config.update_flag_value)
    return update_flag
end

-- 动更标志
local update_flag = (_G.__USERCALLBACK2_UPDATE_FLAG and _G.__USERCALLBACK2_UPDATE_FLAG >= config.update_flag_value)
function config.hasUpdateFlag()
    local update_flag = (_G.__USERCALLBACK2_UPDATE_FLAG and _G.__USERCALLBACK2_UPDATE_FLAG >= config.update_flag_value)
    return update_flag or __WIN32
end

function config.isSupport( ... )

	-- if __WIN32 then return true end

	if not config.isVersionSupport() or config.isUnSupportPkg() then 
		return false 
	end
	
	if not config.hasUpdateFlag() then
        return false
    end

	local actInfo
	for k, v in pairs(UserManager:getInstance().actInfos or {}) do
	    if v.actId == config.actId then
	        actInfo = v
	        break
	    end
	end

	if actInfo == nil or actInfo.see == false then
		return false
	end

	if not config.hasUpdateFlag() then 
		return false
	end

	-- local buffEndTime = tonumber(actInfo.extra) or 0 
	-- if buffEndTime > Localhost:time() then 
	-- 	UserCallbackManager.getInstance():setBuffEndTime(buffEndTime)
	-- end

	-- 标签由后端判断
	-- if UserTagManager:getUserTagBySeries(UserTagNameKeyFullMap.kActivation) ~= UserTagValueMap[UserTagNameKeyFullMap.kActivation].kReturnBack then 
	-- 	return false 
	-- end

	local inTime = config.isActBegin() and not config.isActEnd()

	if inTime then

		local activityData = LocalBox:getData( LocalBoxKeys.Activity_UserCallBackTest )

		if not activityData then activityData = {} end
		
		activityData.flag = true
		-- activityData.endTime = endTime
		activityData.realEndTime = realEndTime
		LocalBox:setData( LocalBoxKeys.Activity_UserCallBackTest , activityData )

		-- RemoteDebug:uploadLogWithTag( "UserCallBackTest" , "config.isSupport  TRUE  activityData.endTime"  .. tostring(activityData.endTime))

		return inTime
	else
		return false
	end
	
end

function config.getStartTime( ... )
	return os.time(beginTime)
end

function config.getEndTime( ... )
	return os.time(endTime)
end

return config