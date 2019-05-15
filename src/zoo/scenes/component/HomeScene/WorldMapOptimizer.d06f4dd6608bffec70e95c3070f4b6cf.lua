
WorldMapOptimizer = class()

local instance = nil
local screenHeight = 1280

function WorldMapOptimizer:getInstance()
	if not instance then 
		instance = WorldMapOptimizer.new()
		instance.viewMap = {}	-- ScreenID to it's views
		instance.viewPositionMap = {}	-- ScreenID to it's views
		instance.operMap = {}
		instance.itemsMap = {}  -- 当前可视区内的NodeViews
		instance.worldScene = nil

		instance.objectPool = {}
		instance.objectShowMap = {}
	end
	return instance
end

function WorldMapOptimizer:init(worldScene, ...)
	instance.worldScene = worldScene

	local visibleSize = CCDirector:sharedDirector():getVisibleSize()

	screenHeight = visibleSize.height
end

-- 根据view的Y值，计算出view所在的屏幕ID，然后加入到指定的屏幕中
function WorldMapOptimizer:buildCache(view , type , ...)
	local viewY = view:getPositionY() - 360
	local screenID = math.ceil(viewY / screenHeight) 
	if screenID == 0 then
		screenID = 1
	end

	if not instance.viewMap[screenID] then
		instance.viewMap[screenID] = {}
	end

	table.insert( instance.viewMap[screenID] , view )

	if type == 2 and view.parent then
		view:setVisible(false)
	end
end


function WorldMapOptimizer:buildCacheByPosition(pos , datas )
	local viewY = pos.y - 360
	local screenID = math.ceil(viewY / screenHeight) 
	if screenID == 0 then
		screenID = 1
	end

	if not instance.viewPositionMap[screenID] then
		instance.viewPositionMap[screenID] = {}
	end

	table.insert( instance.viewPositionMap[screenID] , datas )
end

function WorldMapOptimizer:clearCacheAll()
	instance.viewPositionMap = {}
end

-- 更新当前屏幕内的所有view
local function updateViews(currScreenID , isShow , forceUpdate)
	--printx( 1 , "   WorldMapOptimizer  updateViews  ===================================  " , currScreenID)
	if instance.viewMap and instance.viewMap[currScreenID] then
		local currViews = instance.viewMap[currScreenID]

		-- 更新当前屏幕内view的可见性
		for k,v in pairs(currViews) do
			table.insert(instance.itemsMap, v)
			--printx( 1 , "   WorldMapOptimizer  updateViews  v.levelId = " , v.levelId , isShow)
			if v.parent and not v:isVisible() == isShow then
				v:setVisible(isShow)
			end
		end
	end

	if instance.operMap[currScreenID] then
		instance.operMap[currScreenID] = nil
	end



	if instance.viewPositionMap and instance.viewPositionMap[currScreenID] then

		local currCacheDatas = instance.viewPositionMap[currScreenID]

		if currCacheDatas then

			local usrCurTopLevel = UserManager.getInstance().user:getTopLevelId()

			for k,cacheData in pairs(currCacheDatas) do
				if not instance.objectPool[cacheData.id] then instance.objectPool[cacheData.id] = {} end
				if not instance.objectShowMap[cacheData.id] then instance.objectShowMap[cacheData.id] = {} end
				if not instance.objectShowMap[cacheData.id][currScreenID] then instance.objectShowMap[cacheData.id][currScreenID] = {} end
				if isShow then
					if cacheData.minLevel <= usrCurTopLevel then
						return
					end
					if #instance.objectShowMap[cacheData.id][currScreenID] == 0 then
						if #instance.objectPool[cacheData.id] == 0 then

							local objview = cacheData.createInstanceCallback(cacheData)
							--printx(1,"create  ----- > " , objview.id , tostring(objview))
							table.insert( instance.objectShowMap[cacheData.id][currScreenID] , objview )
						else
							local objview = table.remove( instance.objectPool[cacheData.id] ) 
							objview.isCachedInPool = false
							objview:setVisible(true)
							--printx(1,"pick out by pool  ----- > " , objview.id , tostring(objview))
							cacheData.updateInstanceCallback( objview ,  cacheData )
							table.insert( instance.objectShowMap[cacheData.id][currScreenID] , objview )
						end
					else
						if forceUpdate then
							-- RemoteDebug:log("wmo updateViews----------------------------------------0" .. "  id:" .. cacheData.id .. "  screenID:" .. currScreenID)
							-- RemoteDebug:log("wmo updateViews----------------------------" .. table.tostring(instance.objectShowMap))
							local objview = instance.objectShowMap[cacheData.id][currScreenID][1]
							if objview.isDisposed then
								require "hecore.debug.remote"
								RemoteDebug:log("wmo updateViews----------------------------------------2")
								RemoteDebug:uploadLog()
							else
								cacheData.updateInstanceCallback( objview ,  cacheData )
							end
							-- RemoteDebug:uploadLog()
						end
					end
				else
					local instanceArr = instance.objectShowMap[cacheData.id][currScreenID]
					for k1,v1 in pairs(instanceArr) do
						if v1:getParent() and not v1.isDisposed then

							if #instance.objectPool[cacheData.id] < cacheData.maxInstance then
								v1:setVisible(false)
								cacheData.cacheInstanceCallback( v1 )
								if cacheData.deleteMode == "remove" then
									v1:getParent():removeChild( v1 , false)
								elseif cacheData.deleteMode == "reposition" then
									--v1:setPositionY( v1:getPositionY() - 999999 )
								else
									v1:getParent():removeChild( v1 , false)
								end
								table.insert( instance.objectPool[cacheData.id] , v1 )
								v1.isCachedInPool = true
								--printx(1,"put in pool  ----- > " , v1.id , tostring(v1))
							else
								--printx(1,"delete  ----- > " , v1.id , tostring(v1))
								v1:getParent():removeChild( v1 , true) --对象池已满，强制删除
								cacheData.deleteInstanceCallback( v1 )
							end

						end
					end

					instance.objectShowMap[cacheData.id][currScreenID] = {}
				end
			end
		end
	end

	--printx( 1 , "   WorldMapOptimizer  updateViews  =============================================  ")
	
end

function WorldMapOptimizer:firstUpdate(...)
	
	local k,v
	local k2,v2

	for k,v in pairs(instance.viewMap) do
		if v and type(v) == "table" then
			for k2,v2 in pairs(v) do
				if v2 and v2.parent and v2:isVisible() then
					v2:setVisible(false)
				end
			end
		end
	end
	instance.operMap = {}
	instance:update()
end

function WorldMapOptimizer:removeAllClouds()
	-- RemoteDebug:log("removeAllClouds----------------------------------------0")
	for k,v in pairs(instance.objectShowMap) do
	-- RemoteDebug:log("removeAllClouds----------------------------------------0.5" .. " id:" .. tostring(v.id) .. "  dataV:" .. table.tostring(v))
	-- RemoteDebug:log("removeAllClouds----------------------------------------0.6" .. "  k:" .. k)
		if k == "NewLockedCloud" then
	-- RemoteDebug:log("removeAllClouds----------------------------------------1")
			instance.objectShowMap[k] = nil
		end
	end

	-- RemoteDebug:log("removeAllClouds----------------------------------------2")
	for k, v in pairs(instance.objectPool) do
	-- RemoteDebug:log("removeAllClouds----------------------------------------3  id:" .. tostring(v.id) .. "  davaV:" .. table.tostring(v))
	-- RemoteDebug:log("removeAllClouds----------------------------------------3.6" .. "  k:" .. k)
		if k == "NewLockedCloud" then
	-- RemoteDebug:log("removeAllClouds----------------------------------------4")
			instance.objectPool[k] = nil
		end
	end
	-- RemoteDebug:uploadLog()
end

function WorldMapOptimizer:update( forceUpdate , ...)

	-- 根据MaskedLayer的当前Y坐标来确定屏幕ID
	local offsetY = instance.worldScene.maskedLayer:getPositionY()
	offsetY = math.abs(offsetY) - 50 + (screenHeight / 2)
	local currScreenID = math.ceil( offsetY / screenHeight )
	if currScreenID == 0 then 
		currScreenID = 1
	end

	-- 查看当前屏幕是否已经被处理了
	if not forceUpdate and
		instance.operMap[currScreenID] 
		and instance.operMap[currScreenID - 1] 
		and instance.operMap[currScreenID + 1] 
		then
		return
	end

	--printx( 1 , "WorldMapOptimizer:update  ========================================")

	-- 清空緩存表
	instance.itemsMap = {}

	-- 更新当前屏幕的同时也更新临近的两个屏幕（注意顺序很重要）
	updateViews(currScreenID , true , forceUpdate)
	updateViews(currScreenID - 1 , true , forceUpdate)
	updateViews(currScreenID + 1 , true , forceUpdate)
	--printx( 1 , "WorldMapOptimizer:update  -------------------------")
	for k,v in pairs(instance.operMap) do
		if v then
			updateViews(k , false , forceUpdate)
		end
	end
	--printx( 1 , "WorldMapOptimizer:update  FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF")

	-- 记录刚刚更新过的三个屏幕
	instance.operMap = {}
	instance.operMap[currScreenID] = true
	instance.operMap[currScreenID - 1] = true
	instance.operMap[currScreenID + 1] = true

end


