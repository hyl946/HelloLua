
HomeScenePopoutAction = class()

function HomeScenePopoutAction:ctor()
	self.source = 0
	self.checkRuntime = false
	self.name = "HomeScenePopoutAction"
	self.isWait = false
	self.isPopScene = false --弹出的面板是否有独立的scene
	self.recallUserNotPop = false
end

function HomeScenePopoutAction:init( atype, id, pre )
	self.atype = atype
	self.id = id
	self.priority = id
	if pre then
		pre.nextAction = self
	end
end

function HomeScenePopoutAction:clear()
	-- body
end

function HomeScenePopoutAction:setSource( ... )
	local p = {...}
	local ret = 0
	for i,v in ipairs(p) do
		local tmp = bit.lshift(1, v - 1)
		ret = bit.bor(ret, tmp)
	end

	self.source = ret
end

function HomeScenePopoutAction:wait(params)
	self.isWait = true
	self.waitParams = params
end

function HomeScenePopoutAction:awaken()
	self.isWait = false
end

function HomeScenePopoutAction:onCheckCacheResult(cacheCanPop, needClearCache)
	if needClearCache == nil then
		needClearCache = true
	end
	AutoPopout:checkCacheResult( self, cacheCanPop, needClearCache)
end

function HomeScenePopoutAction:onCheckPopResult(canPop)
	AutoPopout:checkPopResult( self, canPop )
end

local function match( ori, source )
	if ori == 0 then return true end
	if source == nil then return false end
	local c = bit.lshift(1, source - 1)
	local ret = bit.band(ori, c)
	return ret ~= 0
end

function HomeScenePopoutAction:matchSource(source)
	if match(self.source, AutoPopoutSource.kTriggerPop) then
		--触发式需要在所有场景下弹出
		return true
	end
	return match(self.source, source)
end

function HomeScenePopoutAction:popout(next_action)
	next_action()
end

function HomeScenePopoutAction:checkCanPop()
	self:onCheckPopResult(false)
end

function HomeScenePopoutAction:checkCache(cache)
	self:onCheckCacheResult(cache.para and cache.para.canPop)
end

function HomeScenePopoutAction:next()
	if not AutoPopout.isCheckOne then
		AutoPopout:check( self.nextAction )
	end

	self.isWait = false

	AutoPopout.isCheckOne = false
end

--only open url
function HomeScenePopoutAction:checkOpenUrlMethod(cache)
	local res = cache.para
	return res.method == self.openUrlMethod
end