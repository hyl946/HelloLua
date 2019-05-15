ActivityPopoutAction = class(HomeScenePopoutAction)

function ActivityPopoutAction:ctor( ... )
	self.name = "ActivityPopoutAction"
	self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function ActivityPopoutAction:checkCanPop()
	local once = false
	local function needNoPop()
		if not once then
			self:onCheckPopResult(true)
		end
		once = true
		return false
	end

	local function onError()
		self:onCheckPopResult(false)
	end

	local function onGetList(list)
		if #list > 0 then
			for _,info in pairs(list) do
				local data = ActivityData.new(info)
				data:start(false,false,nil,onError,onError, needNoPop)
			end
		else
			self:onCheckPopResult(false)
		end
	end

	local actId = AutoPopout:getAction( OpenActivityPopoutAction.id ):getPopActId()
	self:checkActivity(onGetList, actId, true)
end

function ActivityPopoutAction:popout( next_action )
	local actId = AutoPopout:getAction( OpenActivityPopoutAction.id ):getPopActId()

	local index = 0
	local size = 0
	local runNext = true
	-- 
	local function onSuccess( ... )
		index = index + 1
		runNext = false
	end

	local function onError( ... )
		index = index + 1
		if index >= size and runNext then
			next_action()
		end
	end
	-- 
	local function onEnd( ... )

	end

	local function onGetList(list)
		if #list == 0 then
			next_action()
			return
		end

		size = #list

		for _,info in pairs(list) do
			local data = ActivityData.new(info)
			data:start(false,false,onSuccess,onError,onEnd)
		end
	end

	self:checkActivity(onGetList, actId)
end

function ActivityPopoutAction:checkActivity(cb, actId, notRecode)
	if self.debug then
		local list = {{actId = 4020, source = "QiXi201807/Config.lua", version = "1"}}
		if cb then cb(list) end
		return
	end

	local function onGetList(list)
		list = table.filter(list or {},function(v)
											if v.actId ~= nil and v.actId == 81 then return false end
                                            if v.actId ~= nil and v.actId == 3009 then return false end
                                            if v.actId ~= nil and v.actId == 10066 then return false end
											return v.actId ~= actId 
									   end)
		if cb then cb(list) end
	end
	PushActivity:sharedInstance():onComeToFront(onGetList, notRecode)
end