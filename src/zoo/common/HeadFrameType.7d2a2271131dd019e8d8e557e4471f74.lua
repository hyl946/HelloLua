HeadFrameType = {
	kNormal = 6001,
	kASF = 14,

	kRankRace_3 = 6002,
	kRankRace_2 = 6003,
	kRankRace_1 = 6004,

	kXFRank_1 = 6005,
	kXFRank_2 = 6006,
	kXFRank_3 = 6007,

	kACT_QIXI_2018 = 6008,

    kRankRace_4 = 6009,
	kRankRace_5 = 6010,
	kRankRace_6 = 6011,
    kRankRace_7 = 6012,

    kThankGiving = 6013,
    kFindingTheWay = 6014,

    kRankRace_3_1 = 6015,
    kRankRace_3_2 = 6016,
    kRankRace_3_3 = 6017,
    kChristmasHeadFrame = 6018,
    kChristmasHeadFrame_ANI = 6019,

    -- 2019 春节活动 占位 
    kSP2019_1 = 6020,  --福袋头像框
    kSP2019_2 = 6021,  --通关头像框

    kRankRace_4_1 = 6022,
    kRankRace_4_2 = 6023,
    kRankRace_4_3 = 6024,
  	
  	kDailyTasks = 6025, --每日任务头像框

  	kFifthAnniversaryStep = 6026,
  	kFifthAnniversaryAllPass = 6027,
  	
    -- kTestAnimHeadFrame = 6099,
}

local anim_res_config = {
	[HeadFrameType.kChristmasHeadFrame_ANI] = {
		plist = "flash/head_frames.plist",
		anim = {
			[2] = {'jHeadFrames/6019_2_yuanjian%d0000', 1, 2 , 1/2},
		}
	}
}

local loaded_cache = {}
--设定 头像框的动画素材只加载不释放 因为如果真的存在一个好友或者自己当前戴着动画头像框 那么我认为这个素材就应该常驻


-- 6001：基础头像框
-- 6002-6004：周赛头像框
-- 6005-6007：满星头像框
-- 6008：七夕头像框
-- 6009-6012：周赛新赛季头像框

--肯定是限时的头像框 如果有这个配置 那么未获得时 会显示“限时”两字
HeadFrameTimeLimit= {
	kASF = 14,
	kXFRank_1 = 6005,
	kXFRank_2 = 6006,
	kXFRank_3 = 6007,
	kACT_QIXI_2018 = 6008,
	kRankRace_7 = 6012,
}


local MaxFrameType = 0
for k, v in pairs(HeadFrameType) do
	MaxFrameType = math.max(MaxFrameType, v)
end


if _G.isLocalDevelopMode then
	-- for i = 1, 16 do
	-- 	HeadFrameType['kTest' .. i] = MaxFrameType + i
	-- end
end

HeadFrameStyle = {
	k1 = 1,
	k2 = 2,
	k3 = 3,
}

function HeadFrameType:isValid( item )
	-- body
	if item and tonumber(item.id) then

		if not table.exist(HeadFrameType, item.id or 0) then
			return false
		end

		if not item.timestamp then
			return true
		end

		local timestamp = tonumber(item.timestamp)

		if timestamp then
			if timestamp <= 0 then
				return true
			end

			if timestamp >= Localhost:time() then
				return true
			end
		end
	end
	return false
end

--数据结构

-- {
-- 	{id = 6001, timestamp = -1, },
-- 	{id = 6003, timestamp = os.time(), },
-- 	{id = 6003, timestamp = -1, },
-- 	{id = 6004, timestamp = -1, },
-- 	{id = 6005, timestamp = -1, },
-- }

local fake_data = {
	{id = 6001, timestamp = -1},
	{id = 6002, timestamp = (Localhost:time() + 30000)},
	{id = 6003, timestamp = (Localhost:time() + 30000)},
	{id = 6004, timestamp = (Localhost:time() + 30000)},
	{id = 14, timestamp = (Localhost:time() + 12000)},
}

local debugFlag = false

local profile_context

--todo 从user里读写数据
local function raw_get_bag( ... )


	local profile = profile_context or (UserManager.getInstance().profile or {})
	local headFrames = profile.headFrames or {}

	local data = {}

	local found_normal = false
	for _, v in ipairs(headFrames) do
		table.insert(data, {id = tonumber(v.id), timestamp = tonumber(v.expireTime), obtainTime = tonumber(v.obtainTime)})
		if (tonumber(v.id) or 0) == HeadFrameType.kNormal then
			found_normal = true
		end
	end
	if not found_normal then
		table.insert(data, {id=HeadFrameType.kNormal})
	end
	-- body

	if debugFlag then
		return fake_data
	end

	return data
end

local function raw_set_bag( data )
	
	local raw_data = {}

	for _, v in ipairs(data) do
		table.insert(raw_data, {id = v.id, expireTime = v.timestamp or 0, obtainTime = v.obtainTime or 0})
	end

	if not profile_context then
		UserManager:getInstance().profile.headFrames = raw_data
		UserService:getInstance().profile.headFrames = table.clone(raw_data, true)
	end

end

local function raw_get_cur( ... )
	local profile = profile_context or (UserManager.getInstance().profile or {})
	return profile.headFrame
end

local function raw_set_cur( id )
	if not profile_context then
		UserManager:getInstance().profile.headFrame = id
		UserService:getInstance().profile.headFrame = id
	end
end

function HeadFrameType:requestSave( )
	-- print("HeadFrameType:requestSave()",UserManager:getInstance().profile.headFrame)
	ChooseHeadFrameHttp.new(false):load(UserManager:getInstance().profile.headFrame)
end

function HeadFrameType:getAvaiHeadFrame( ... )

	local ret = table.filter(raw_get_bag(), function ( item )
		return self:isValid(item)
	end)

	table.sort(ret, function ( a, b )

		if a.id == HeadFrameType.kNormal then
			return false
		end

		if b.id == HeadFrameType.kNormal then
			return true
		end

		local ta = tonumber(a.obtainTime) or 0
		local tb = tonumber(b.obtainTime) or 0

		return ta > tb
	end)

	return ret
end

function HeadFrameType:getCurHeadFrame( ... )


	local cur_ = raw_get_cur() or HeadFrameType.kNormal

	if self:has(cur_) then
		return cur_
	end

	return HeadFrameType.kNormal
end

function HeadFrameType:has( target )
	return self:find(target) ~= nil
end

function HeadFrameType:find( target )

	local cur_bag = self:getAvaiHeadFrame()

	local item = table.find(cur_bag, function ( item )
		return item.id == target
	end)


	return item

end

function HeadFrameType:setCurHeadFrame( target )
	--print("HeadFrameType:setCurHeadFrame(  )",target,self:has(target),self:getCurHeadFrame(),target ~= self:getCurHeadFrame())
	if self:has(target) then

		local needUpdate = false

		if target ~= self:getCurHeadFrame() then
			needUpdate = true
		end

		if needUpdate then
			raw_set_cur(target)
			self:updateAll()
		end

		return true
	end
	return false
end

function HeadFrameType:checkShowHeadFrameGotPanel( closeCallback )
	print("-HeadFrameType:checkShowHeadFrameGotPanel()",self,self.justGotNewHeadFrame)
	if not self.justGotNewHeadFrame then return end
	HeadFrameGotPanel:create( closeCallback )
	self.justGotNewHeadFrame = false
end

function HeadFrameType:addHeadFrame( target, duration,alertPanel)
	print("HeadFrameType:addHeadFrame",target,duration,alertPanel,debug.traceback())
	local curFrameId = self:getCurHeadFrame()

	local cur_bag = raw_get_bag()

	local found = false

	for _, v in ipairs(cur_bag) do
		if v.id == target then
			if v.timestamp then
				if (tonumber(v.timestamp) or 0) > 0 then

					if (tonumber(v.timestamp) or 0) <  Localhost:time() then
						v.obtainTime = Localhost:time()
					end

					if duration then
						v.timestamp = math.max((tonumber(v.timestamp) or 0), Localhost:time()) + duration
					else
						v.timestamp = 0
					end
				end
			end

			found = true
			break
		end
	end
	if not found then
		if duration then
			table.insert(cur_bag, {id = target, timestamp = Localhost:time() + duration, obtainTime = Localhost:time()})
		else
			table.insert(cur_bag, {id = target, timestamp = 0, obtainTime = Localhost:time()})
		end

		raw_set_bag(cur_bag)
		self:setCurHeadFrame(target)
		self:updateAll()
		HeadFrameType:setProfileContext():updateShowTime()

		self:requestSave()
	else
		raw_set_bag(cur_bag)
	end

	self:getEventMgr():dispatchEvent(Event.new(HeadFrameType.Events.kUpdateShowTime))

	DcUtil:UserTrack({category='UI', sub_category='get_head_frame', t1=target}, false)

	-- Notify:dispatch("AutoPopoutEventAwakenAction", NewHeadFrameUnlockPopoutAction,target)

	self.justGotNewHeadFrame = true
	if alertPanel then
	    self:checkShowHeadFrameGotPanel()
	end
end

function HeadFrameType:setProfileContext( profile )
	profile_context = profile
	return self
end

local loaders = {}

function HeadFrameType:buildUI( frameId, style, uid)
	
	frameId = frameId or HeadFrameType.kNormal
	style = style or 1

	-- printx(101 , "\n\n HeadFrameType:buildU traceback = " , debug.traceback() )



	for _, v in ipairs(loaders) do
		local ui = v(frameId, style, uid)
		if ui then
			return ui
		end
	end
	if frameId > MaxFrameType then
		frameId = MaxFrameType
	end
	local res = 'jHeadFrames/' .. frameId .. '_' .. style
	if frameId == HeadFrameType.kNormal and style == 2 then
		if tostring(uid) ~= tostring(UserManager:getInstance().user.uid or 0) then
			res = res .. '_1'	
		end
	end

	local ret = ResourceManager:sharedInstance():buildGroup(res)
	if anim_res_config[frameId] then
		local anim_cfg = anim_res_config[frameId]
		if anim_cfg then
			if anim_cfg.anim[style] then
				if not loaded_cache[anim_cfg.plist] then
					FrameLoader:loadImageWithPlist(anim_cfg.plist)
					loaded_cache[anim_cfg.plist] = true
				end
				local time =  anim_cfg.anim[style][4]
				if not time then
					time = 1/24
				end
				local animHeadFrame, action = SpriteUtil:buildAnimatedSprite( time , anim_cfg.anim[style][1], anim_cfg.anim[style][2], anim_cfg.anim[style][3])
				animHeadFrame:runAction(CCRepeatForever:create(action))
				animHeadFrame.name = 'headFrame'
				local spHeadFrame = ret:getChildByPath('headFrame')
				local spHeadFrame2 = ret:getChildByPath('headFrame2')
				if spHeadFrame2 then
					spHeadFrame2:setVisible(false)
				end
				local posX = spHeadFrame:getPositionX()
				local posY = spHeadFrame:getPositionY()

				animHeadFrame:setPositionX(posX)
				animHeadFrame:setPositionY(posY)
				animHeadFrame:setAnchorPoint(ccp(0, 1))
				spHeadFrame:removeFromParentAndCleanup(true)
				ret:addChild(animHeadFrame)
			end

		end
	end
	return ret

end


function HeadFrameType:isTimeLimitForShow( frameId )
	-- body
	local hasIt = table.find(HeadFrameTimeLimit , function ( node )
		return node == frameId
	end)
	if hasIt then
		return true
	else
		return false
	end

end


function HeadFrameType:isTimeLimit( frameId )
	-- body
	 local frame = self:find(frameId)
	 return frame and frame.timestamp and frame.timestamp > 0
end

function HeadFrameType:buildDescUI(frameId , hasLockIcon)

	frameId = frameId or HeadFrameType.kNormal
	local res = 'jHeadUI/desc'
	local ui = ResourceManager:sharedInstance():buildGroup(res)

	ui:getChildByPath('title'):setString(localize('headframe.title.' .. frameId))
	local desc = localize('headframe.desc.' .. frameId)
	ui:getChildByPath('desc'):setString(desc)


	local function setRichText(textLabel, str)
		textLabel:setVisible(false)
		local width = textLabel:getDimensions().width
		local pos = textLabel:getPosition()
		local richText = TextUtil:buildRichText(str, width, textLabel:getFontName(), textLabel:getFontSize(), textLabel:getColor())
		richText:setPosition(ccp(pos.x, pos.y))
		ui:addChildAt(richText, textLabel:getZOrder())
	end
	local message = localize('headframe.desc.' .. frameId)

	setRichText( ui:getChildByPath('desc') , message)

	if utfstrlen(desc)>18 then
		local bg = ui:getChildByPath('tab')
		bg:setScaleY(bg:getScaleY()+0.1)
		ui:getChildByPath('time'):setPositionY(-180)
	end

	if self:isTimeLimit(frameId) or (not self:setProfileContext():find(frameId)) then
		local refresh = function ( ... )
			if ui.isDisposed then return end

			local frame = self:setProfileContext():find(frameId)

			if frame then

				local delta = frame.timestamp - Localhost:time()
				local deltaInSec = delta / 1000

				local d = math.floor(deltaInSec / (3600 * 24))
				local h = math.floor(deltaInSec % (3600 * 24) / 3600)
				local m = math.floor(deltaInSec % (3600 * 24) % 3600 / 60)
				local s = math.floor(deltaInSec % (3600 * 24) % 3600 % 60)

				local time = ''


				if s > 0 then time = '' .. s .. '秒' end
				if m > 0 then time = '' .. m .. '分钟' end
				if h > 0 then time = '' .. h .. '小时' end
				if d > 0 then time = '' .. d .. '天' end

				if time ~= '' then
					ui:getChildByPath('time'):setString(string.format('(%s后过期)', time))
				else
					ui:getChildByPath('time'):setString(string.format('(已过期)', time))
				end
			else
				if not hasLockIcon then
					--打开的时候过期了 显示已过期
					ui:getChildByPath('time'):setString(string.format('(已过期)'))
				else
					local stringKey =  'headframe.timelimit.' .. frameId
					if localize( stringKey ) ~= stringKey then
						ui:getChildByPath('time'):setString( localize( stringKey ) )
					end
				end
			end
		end

		ui.oneSecondTimer	= OneSecondTimer:create()
		ui.oneSecondTimer:setOneSecondCallback(refresh)
		ui.oneSecondTimer:start()

		refresh()
		function ui:dispose( ... )
			self.oneSecondTimer:stop()
			Layer.dispose(self, ...)
		end
	end


	

	return ui

end

function HeadFrameType:addLoader( func )
	table.insert(loaders, func)
end

local headImageGrp = {}

local timerInited = false
local myLastFrameId = nil

function HeadFrameType:register( v )
	table.insert(headImageGrp, v)

	if not timerInited then
		timerInited = true
		myLastFrameId = self:setProfileContext():getCurHeadFrame()
		self.oneSecondTimer	= OneSecondTimer:create()
		local function oneSecondCallback()
			self:oneSecondCallback()
		end
		self.oneSecondTimer:setOneSecondCallback(oneSecondCallback)
		self.oneSecondTimer:start()
	end
end

function HeadFrameType:unregister( ... )
	table.removeValue(headImageGrp, v)
end

function HeadFrameType:updateAll( ... )
	for _, v in ipairs(headImageGrp) do
		v:refreshHeadFrame()
	end
end

function HeadFrameType:oneSecondCallback( ... )
	local nowFrameId = self:setProfileContext():getCurHeadFrame()
	if nowFrameId ~= myLastFrameId then
		myLastFrameId = nowFrameId
		self:updateAll()
		self:getEventMgr():dispatchEvent(Event.new(HeadFrameType.Events.kHeadFrameAutoChange))
	end
end

function HeadFrameType:hasNewHeadFrame( ... )
	do return false end
	-- body
	local profile = profile_context or (UserManager.getInstance().profile or {})
	if profile then
		local headFrameShowTime = tonumber(profile.headFrameShowTime or 0) or 0
		local maxObtainTime = 0

		table.walk(self:getAvaiHeadFrame(), function ( v )
			if v.id ~= HeadFrameType.kNormal then
				maxObtainTime = math.max(maxObtainTime, v.obtainTime or 0)
			end
		end)
		if _G.isLocalDevelopMode then printx(100, " hasNewHeadFrame " , maxObtainTime , headFrameShowTime ,maxObtainTime > headFrameShowTime) end
		return maxObtainTime > headFrameShowTime
	end

	return false
end

function HeadFrameType:buildNewFlag( ... )
	-- body
	return ResourceManager:sharedInstance():buildGroup('jHeadUI/new')
end


HeadFrameType.Events = {
	kUpdateShowTime = 'HeadFrameType.Events.kUpdateShowTime',
	kHeadFrameAutoChange = 'HeadFrameType.Events.kHeadFrameAutoChange',
}

function HeadFrameType:updateShowTime( ... )
	if not profile_context then
		local now = Localhost:time()
		UserManager.getInstance().profile.headFrameShowTime = tostring(now)
		UserService.getInstance().profile.headFrameShowTime = tostring(now)
		OpNotifyOffline.new(false):load(OpNotifyOfflineType.kHeadFrameUpdateShowTime, tostring(now))

		self:getEventMgr():dispatchEvent(Event.new(HeadFrameType.Events.kUpdateShowTime))
	end
end

function HeadFrameType:isNew( frameId )
	if not profile_context then
		local frame = self:find(frameId)
		if frame then
			if frameId == HeadFrameType.kNormal then
				return false
			end
			return (tonumber(frame.obtainTime) or 0) >= (tonumber(UserManager.getInstance().profile.headFrameShowTime) or 0)
		end
	end
end

function HeadFrameType:getEventMgr( ... )
	if not self.eventMgrInited then
		self.eventMgrInited = true
		self.eventMgr = EventDispatcher.new()
	end
	return self.eventMgr
end

-- ____DDDD = function ( ... )
-- 	setTimeOut(function ( ... )
-- 		-- body
-- 		local f = HeadFrameType:setProfileContext():getAvaiHeadFrame()
-- 		printx(61, table.tostring(f) .. tostring(HeadFrameType:setProfileContext():hasNewHeadFrame()))

-- 	end, 1)
-- end