MaintenanceGroupTest = {}

--[[
 * MaintenanceGroupTest
 * @date    2018-11-22 15:25:05
 * @authors reast.li
 * @email 	reast.li@happyelements.com
--]]

MaintenanceGroupTest = class(UnittestTask)

function MaintenanceGroupTest:ctor()
	
end

--finished_cb(success, msg)
function MaintenanceGroupTest:run( finished_cb )
	self.finished_cb = finished_cb
	self:runTest()
end

function MaintenanceGroupTest:runTest()
	UpdateCheckUtils = {}
	require "hecore.utils"
	require "hecore.debug.printx"
	require "zoo.data.MaintenanceManager.lua"

	initPrintx( print , { 1  , 0 , -2 , -6 , -99 } , false )
	-- require "hecore.notify.Notify"
	-- require "zoo.scenes.component.HomeScene.popoutQueue.new.AutoPopout"

	_G.isLocalDevelopMode = true

	Localhost = {}

	UserManager = {}
	UserManager.getInstance = function () 
		local obj = {}
		obj.getTestInfo = function ()
			return nil
		end

		return obj
	end

	function MaintenanceManager:onlineLoad(onFinish)
		--do nothing
	end

	function Localhost:readFromStorage( fileName )
		if fileName then
			local filePath = HeResPathUtils:getAppAssetsPath() .. "/src/zoo/unittest/maintenanceGroupTest/" .. fileName
			local file = io.open(filePath, "rb")
			if file then
				local data = file:read("*a") 
				file:close()

				if data then
					local result = nil 
					local function decodeAmf3() result = amf3.decode(data) end
					--TODO: decypt data
					pcall(decodeAmf3)
					return result
					--return amf3.decode(data)
				end
			end
		end
		return nil
	end

	function Localhost:safeWriteStringToFile(data, filePath)
	    local tmpName = filePath .. "." .. os.time()
	    local file = io.open(tmpName, "wb")
	    assert(file, "persistent file failure " .. tmpName)
	    if not file then return end

	    local success = file:write(data)
	   
	    if success then
	        file:flush()
	        file:close()
	        os.remove(filePath)
	        os.rename(tmpName, filePath)
	    else
	        file:close()
	        os.remove(tmpName)
	        if _G.isLocalDevelopMode then printx(0, "write file failure " .. tmpName) end
	    end        
	end

	local ret = {}
	MaintenanceManager:getInstance():readFromStorage()	
	local maintenance = MaintenanceManager:getInstance()
	local resultData = {}
	local resultDataStr = "none"
	if maintenance.data and type(maintenance.data) == "table" then
		local _data = {}
		for k,v in pairs(maintenance.data) do
			table.insert( _data , v ) 
		end

		table.sort( _data , function ( a , b )
				if a.id < b.id then return true end
			end )

		local sortedTable = _data

		
		resultData[1] = {}
		resultData[2] = {}
		for k,v in ipairs( sortedTable ) do
			if v.modeValue == MaintenanceModeType.kGroup then
				local rangeMap = maintenance:getGroupChildRangeMap( v.name )
				local fixMap = {}
				for k1,v1 in pairs(rangeMap) do
					local fixV = {}
	        		table.insert( fixV , v1.str or 0 )
	        		local startId = v1.startId
	        		if not (v1.startId and v1.startId >= -1) then
	        			startId = -1
	        		end
	        		table.insert( fixV , startId )

	        		local endId = v1.endId
	        		if not (v1.endId and v1.endId >= -1) then
	        			endId = -1
	        		end
	        		table.insert( fixV , endId )

	        		table.insert( fixMap , fixV )
	        	end
				table.insert( resultData[1] , fixMap )
			elseif v.modeValue == MaintenanceModeType.kOrthogonalGroup then
				local uid = 57278129

				for i = 1 , 10000 do
					local _uid = tostring( math.floor(uid + i) )
					local currWeighValue , groupVersion = MaintenanceManager:getInstance():getUserWeighValue( v.name , _uid )

					local _group = 0

					for i = 1 , 3 do
						if MaintenanceManager:getInstance():isEnabledInGroup("TestSwitch2" , "G" .. tostring(i) , _uid ) then
							_group = i
							break
						end
					end

					table.insert( resultData[2] , { [1] = currWeighValue , [2] = groupVersion , [3] = _group } )
				end
			end
		end


		if false then
			local filePath = HeResPathUtils:getAppAssetsPath() .. "/src/zoo/unittest/maintenanceGroupTest/" .. "DefaultData"
	        resultDataStr = table.serialize( resultData )
	        Localhost:safeWriteStringToFile( resultDataStr , filePath )
		end

	end

	local defaultData = Localhost:readFromStorage("DefaultData")

	local function onError( e )
		print(e)
		print(debug.traceback())
	end
	local r = xpcall(self.validate, onError, self, resultData )
	print(r)
	self.finished_cb(r, "")	

	return ret
end

function MaintenanceGroupTest:validate( ret )
	local defaultDataStr = ""
	local defaultData = {}

	local filePath = HeResPathUtils:getAppAssetsPath() .. "/src/zoo/unittest/maintenanceGroupTest/" .. "DefaultData"
	local file = io.open(filePath, "rb")
	if file then
		defaultDataStr = file:read("*a") 
		if defaultDataStr then
			defaultData = table.deserialize( defaultDataStr )
		end
		file:close()
	end
	table.compare(ret, defaultData)
end
