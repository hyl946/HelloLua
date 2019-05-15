-------------------------------------------------------------------------
--  Class include: LocationManager_Android, LocationManager_iOS, LocationManager
-------------------------------------------------------------------------

require "hecore.class"

--
-- LocationManager_Android ---------------------------------------------------------
--
-- initialize
local instanceAndroid = nil
LocationManager_Android = {
	native = nil,
	longitude = 0,
	latitude = 0,
	dataPath = HeResPathUtils:getUserDataPath() .. '/android_location_'..(UserManager:getInstance().uid or '0'),
}

function LocationManager_Android.getInstance()
	if not instanceAndroid then 
		instanceAndroid = LocationManager_Android
		instanceAndroid:readLocalData()
	end
	return instanceAndroid
end

function LocationManager_Android:readLocalData()
	local file = io.open(self.dataPath, "r")
    if file then
        local content = file:read("*a") 
        file:close()
        if content then
            local data = table.deserialize(content) or {}
            if data.longitude and data.latitude and data.updateTime then
            	local now = Localhost:timeInSec()
            	if compareDate(os.date('*t', now), os.date('*t', data.updateTime)) == 0 then
            		self.longitude = data.longitude
            		self.latitude = data.latitude
            		self.updateTime = updateTime
            	end
            end
        end
    end
end

function LocationManager_Android:writeLocalData()
	local file = io.open(self.dataPath,"w")
	local data = {
		longitude = self.longitude,
		latitude = self.latitude,
		updateTime = self.updateTime,
	}

    if file then
        file:write(table.serialize(data))
        file:close()
    end
end

function LocationManager_Android:initLocationManager()
	if not self.native then
		self.native = luajava.bindClass("com.happyelements.hellolua.baidu.location.BDLocationService"):getInstance()
	end
end

function LocationManager_Android:hasPermissions( ... )
	local k = true
	if self.native then
		pcall(function ( ... )
			k = self.native:checkPermission('android.permission.ACCESS_FINE_LOCATION') and self.native:checkPermission('android.permission.ACCESS_COARSE_LOCATION')
		end)
	end
	return k
end

function LocationManager_Android:gotoPermissionsSetting( ... )
	pcall(function ( ... )
		luajava.bindClass("com.happyelements.hellolua.baidu.location.PermissionPageUtils"):jump()
	end)
end

function LocationManager_Android:needUpdateLocation()
	local user = UserManager.getInstance().user
	if not user then return false end
	if user:getTopLevelId() < 15 then return false end
	
	local ret = math.abs(self.latitude) < 0.0000001 and math.abs(self.longitude) < 0.0000001
	if not ret then
		local now = Localhost:timeInSec()
        ret = compareDate(os.date('*t', now), os.date('*t', self.updateTime)) ~= 0
	end
	return ret
end

function LocationManager_Android:hasLocation()
	local now = Localhost:timeInSec()
	if self.updateTime and compareDate(os.date('*t', now), os.date('*t', self.updateTime)) == 0 then
		return true
	end
	return false
end

function LocationManager_Android:startUpdatingLocation(forceUpdate)
	if self:needUpdateLocation() or forceUpdate then
		local locationInterface = luajava.createProxy("com.happyelements.hellolua.baidu.location.BDLocationInterface", {
				onReceiveLocation = function(longitude,latitude)
					self.longitude = longitude
					self.latitude = latitude
					self.updateTime = Localhost:timeInSec()
					self:writeLocalData()
					if _G.isLocalDevelopMode then printx(0, string.format("self.longitude:%f",self.longitude)) end
					if _G.isLocalDevelopMode then printx(0, string.format("self.latitude:%f",self.latitude)) end
				end
			})

		self.native:requestLocation(locationInterface)
		-- self.native:requestOfflineLocation(locationInterface)
		self.running = true
	end
end

function LocationManager_Android:stopUpdatingLocation()
	if self.running then
		self.running = false
		self.native:stop_ui()
	end
end

function LocationManager_Android:getLongitude()
	return self.longitude
end

function LocationManager_Android:getLatitude()
	return self.latitude
end

function LocationManager_Android:getLocationData()
	local mapData = self.native:getLocationData()
	if mapData then
		return luaJavaConvert.map2Table(mapData)
	end
	return nil
end

--
-- LocationManager_iOS ---------------------------------------------------------
--
-- initialize
local instanceiOS = nil
LocationManager_iOS = {}

function LocationManager_iOS.getInstance()
	if not instanceiOS then instanceiOS = LocationManager_iOS end
	return instanceiOS
end

function LocationManager_iOS:initLocationManager()
	LocationManager:getInstance():initLocationManager()
end

function LocationManager_iOS:startUpdatingLocation()
	LocationManager:getInstance():startUpdatingLocation()
end

function LocationManager_iOS:gotoPermissionsSetting( ... )
	UIApplication:sharedApplication():openSettingUrl(NSURL:URLWithString('prefs:root=LOCATION_SERVICES'))
	--CommonTip:showTip('prefs:root=LOCATION_SERVICES')
end

function LocationManager_iOS:hasPermissions( ... )
	return LocationManager:getInstance():hasPermissions()
end


function LocationManager_iOS:stopUpdatingLocation()
	LocationManager:getInstance():stopUpdatingLocation()
end

function LocationManager_iOS:getLongitude()
	return LocationManager:getInstance():getLongitude()
end

function LocationManager_iOS:getLatitude()
	return LocationManager:getInstance():getLatitude()
end

function LocationManager_iOS:getLocationData()
	return LocationManager:getInstance():getLocationData()
end

--
-- LocationManager_WP8 ---------------------------------------------------------
--
-- initialize
local instanceWp8 = nil
LocationManager_WP8 = {}

function LocationManager_WP8.getInstance()
	if not instanceWp8 then 
    instanceWp8 = LocationManager_WP8 
  end
	return instanceWp8
end

function LocationManager_WP8:initLocationManager()
  -- do nothing
end

function LocationManager_WP8:startUpdatingLocation()
	LocationManager:GetInstance():StartUpdatingLocation(false)
end

function LocationManager_WP8:stopUpdatingLocation()
	-- do nothing
end

function LocationManager_WP8:getLongitude()
	return LocationManager:GetInstance():GetLongitude()
end

function LocationManager_WP8:getLatitude()
	return LocationManager:GetInstance():GetLatitude()
end

function LocationManager_WP8:getLocationData()
	return nil
end

--
-- LocationManager ---------------------------------------------------------
--
local instance = nil
LocationManager_All = {location = nil}

function LocationManager_All.getInstance()
	if not instance then 
		instance = LocationManager_All 
		if __IOS then
			instance.location = LocationManager_iOS.getInstance()
		end

		if __ANDROID then
			instance.location = LocationManager_Android.getInstance()
		end
    
		if __WP8 then
			instance.location = LocationManager_WP8.getInstance()
		end
		-- 游戏切到后台时需要停止定位服务
		local function onEnterForeground()
			if instance.isLocationUpdating then
				if instance.location then
					instance.location:startUpdatingLocation()
				end
			end
		end
		GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kEnterForeground, onEnterForeground)
		local function onEnterBackground()
			if instance.isLocationUpdating then
				if instance.location then
					instance.location:stopUpdatingLocation()
				end
			end
		end
		GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kEnterBackground, onEnterBackground)
	end
	return instance
end

function LocationManager_All:initLocationManager()
	if self.location then
		self.location:initLocationManager()
	end
	self.isLocationUpdating = false
end

function LocationManager_All:startUpdatingLocation(forceUpdate)
	if self.location then
		self.location:startUpdatingLocation(forceUpdate)
		self.isLocationUpdating = true
	end
end

function LocationManager_All:hasLocation()
	if __ANDROID then
		return self.location:hasLocation()
	else
		return true
	end
end

function LocationManager_All:stopUpdatingLocation()
	if self.location then
		self.location:stopUpdatingLocation()
		self.isLocationUpdating = false
	end
end

function LocationManager_All:getLongitude()
	if self.location then
		return self.location:getLongitude()
	end
end

function LocationManager_All:getLatitude()
	if self.location then
		return self.location:getLatitude()
	end
end

function LocationManager_All:getLocationData()
	if self.location then
		return self.location:getLocationData()
	end
	return nil
end

function LocationManager_All:hasPermissions( ... )
	if self.location and self.location.hasPermissions then
		return self.location:hasPermissions()
	end
	return true
end

function LocationManager_All:gotoPermissionsSetting( ... )
	-- body
	if self.location and self.location.gotoPermissionsSetting then
		return self.location:gotoPermissionsSetting()
	end

end

--[[
{
  "code": 0,
  "data": {
    "ip": "61.49.51.157",
    "country": "中国",
    "area": "",
    "region": "北京",
    "city": "北京",
    "county": "XX",
    "isp": "联通",
    "country_id": "CN",
    "area_id": "",
    "region_id": "110000",
    "city_id": "110100",
    "county_id": "xx",
    "isp_id": "100026"
  }
}
]]
local kLocationStorageFile = "iplookup_cache.ds"
function LocationManager_All:getIPLocation(callback, refresh)
	if PrepackageUtil:isPreNoNetWork() then
    	if type(callback) == "function" then callback(nil) end
		return
	end
	if refresh ~= true then
		if not self.ip_location then
			self.ip_location = Localhost:readFromStorage( kLocationStorageFile )
		end
		if self.ip_location and self.ip_location.updateTime and 
				compareDate(os.date("*t",Localhost.timeInSec()), os.date("*t",self.ip_location.updateTime)) == 0 then -- once a day
        	
        	if _G.isLocalDevelopMode then printx(0, ">>> cached location:", table.tostring(self.ip_location)) end
        	if type(callback) == "function" then callback(self.ip_location) end
			return
		end
	end

	local function getValue(data, key)
		local ret = data[key]
		if ret and string.lower(ret) ~= "xx" then
			return ret
		end
		return ""
	end
	local callbackHanler = function(response)
        if response.httpCode == 200 then
            if type(response) == "table" and type(response.body) == "string" then
                local tab = table.deserialize(response.body)
                if type(tab) == "table" and type(tab.data) == "table" then
                	local data = tab.data
            		local location = {}
            		location.country = getValue(data, "country")
            		location.province = getValue(data, "region")
            		location.city = getValue(data, "city")
            		location.area = getValue(data, "area")
            		location.isp = getValue(data, "isp")

            		location.countryId = getValue(data, "country_id")
            		location.provinceId = getValue(data, "region_id")
            		location.cityId = getValue(data, "city_id")
            		location.areaId = getValue(data, "area_id")
            		location.ispId = getValue(data, "isp_id")

            		location.ip = data.ip
            		location.district = ""
            		location.updateTime = Localhost.timeInSec()
                	if _G.isLocalDevelopMode then printx(0, ">>> location:", table.tostring(location)) end

            		self.ip_location = location
            		Localhost:writeToStorage(location, kLocationStorageFile)
                end
            end
        end
        if type(callback) == "function" then callback(self.ip_location) end
    end

    local requestUrl = "http://ip.taobao.com/service/getIpInfo.php?ip=myip"
  --   local requestUrl = "https://api.map.baidu.com/location/ip?ak=hgQqUBbug3NVNcVuQt34zdFWRFX0GLHz"
 	-- if _G.isLocalDevelopMode or MaintenanceManager:getInstance():isEnabled("IPLocationUseHttp", false) then
 	-- 	requestUrl = "http://api.map.baidu.com/location/ip?ak=hgQqUBbug3NVNcVuQt34zdFWRFX0GLHz"
 	-- end
    local request = HttpRequest:createPost(requestUrl)
    local timeout = 2
    local connection_timeout = 1

    request:setConnectionTimeoutMs(connection_timeout * 1000)
    request:setTimeoutMs(timeout * 1000)
    HttpClient:getInstance():sendRequest(callbackHanler, request)
end

function LocationManager_All:getIPLocationCached()
	if not self.ip_location then
		self.ip_location = Localhost:readFromStorage( kLocationStorageFile )
	end
	return self.ip_location
end