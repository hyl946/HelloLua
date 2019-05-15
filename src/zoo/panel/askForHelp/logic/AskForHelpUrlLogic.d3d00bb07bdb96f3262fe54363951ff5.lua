require "zoo.panel.MessageWithRewardsPanel"

local AskForHelpUrlLogic = class()

function AskForHelpUrlLogic:showPanel( txt_key, close_cb)
	AutoPopout:showNotifyPanel( txt_key, close_cb)
end

function AskForHelpUrlLogic:startWithConfig(config, close_cb)

	if tonumber(config.tlink or 0) == 3 then
		return
	end

	local function reject(reason)
		local levelId = tonumber(config.levelId or 1) or 1
    	local subsUid = config.uid or ''
		DcUtil:UserTrack({category = 'FriendLevel', sub_category = 'trigger_stage_panel', t1=levelId, t2=subsUid, t3=reason})
	end

	if WXJPPackageUtil.getInstance():isWXJPPackage() then
		self:showPanel("wxjp.friendlevel.help.tip", close_cb)
		return reject(6)
	end

	-- platform
	if not UserManager:getInstance():isSameInviteCodePlatform(config.invitecode) then
		self:showPanel("askforhelp.urllogic.platform.diff", close_cb)
		return reject(6)
	end

	-- version
	if not AskForHelpManager:getInstance():versionSupport() then
		self:showPanel("askforhelp.urllogic.version.low", close_cb)
		return reject(2)
	end

	-- url time
	if not config.ts then
		self:showPanel("askforhelp.urllogic.time.expired", close_cb)
		return
	else
		local cfg = AskForHelpManager.getInstance():getConfig()
		local VALID_DAYS = cfg.maxUrlValidDays
		local timeStamp = tonumber(config.ts)
		if not timeStamp then
			self:showPanel("askforhelp.urllogic.time.expired", close_cb)
			return
		end
		local mark = UserManager:getInstance().mark
		local now = Localhost:time()
		local dayTime = 86400000
		local begNow = math.floor((now - mark.createTime) / dayTime) * dayTime + mark.createTime
        local begStm = math.floor((timeStamp - mark.createTime) / dayTime) * dayTime + mark.createTime
		local endStm = begStm + dayTime*VALID_DAYS
		if now < timeStamp or begNow >= endStm then
			self:showPanel("askforhelp.urllogic.time.expired", close_cb)
			return
		end
	end

	-- self
	if not config.uid then
		self:showPanel("askforhelp.urllogic.uid.equal", close_cb)
		return
	else
		local user = UserManager:getInstance():getUserRef()
		if tonumber(config.uid) == tonumber(user.uid or '12345') then
			self:showPanel("askforhelp.urllogic.uid.equal", close_cb)
			return reject(7)
		end
	end

	-- topLevelId
	if not config.levelId then
		self:showPanel("askforhelp.urllogic.topLevelId.illegal", close_cb)
		return
	else
		local maxLevel = MetaManager:getInstance():getMaxNormalLevelByLevelArea()
		local user = UserManager:getInstance():getUserRef()

		local taLevel = tonumber(config.levelId) or 0
		local passed = UserManager:getInstance():hasPassedLevel(taLevel) -- 自己通过
		if user:getTopLevelId() < taLevel or (user:getTopLevelId() == taLevel and (not passed)) then
			self:showPanel("askforhelp.urllogic.topLevelId.illegal", close_cb)
			return reject(3)
		end

		if not passed then
			self:showPanel("askforhelp.urllogic.level.notpass", close_cb)
			return reject(8)
		end
	end

	local levelId = tonumber(config.levelId)
    local subsUid = config.uid or ''

	local function onCheckSuccess()
		local function onDisition(start)
			if not start then
				if close_cb then close_cb() end
				return
			end

			DcUtil:UserTrack({category = 'FriendLevel', sub_category = 'push_stage_button', t1=levelId, t2=subsUid})
			HomeScene:sharedInstance().worldScene:startLevel(levelId, StartLevelType.kAskForHelp)
    		AskForHelpManager:getInstance():enterMode(subsUid, tonumber(config.wx or 0)>0)
		end

		local AFHSchemaPanel = require 'zoo.panel.askForHelp.views.AFHSchemaPanel'
		AFHSchemaPanel:create(levelId, onDisition):popout()
		DcUtil:UserTrack({category = 'FriendLevel', sub_category = 'trigger_stage_panel', t1=levelId, t2=subsUid, t3=1})
	end

	local function onCheckFail(evt)
		local errcode = evt and evt.data or nil
		if errcode then
			local key = "askforhelp.error.tip." ..tostring(errcode)
			if key == Localization:getInstance():getText(key) then
				key = "error.tip."..tostring(errcode)
			end
			self:showPanel(key, close_cb)
			return reject(errcode)
		end
    end

	-- online check
	local http = AskForHelpCheckConditionHttp.new(true)
    http:ad(Events.kComplete, onCheckSuccess)
    http:ad(Events.kError, onCheckFail)
    http:ad(Events.kCancel, onCheckFail)
	http:syncLoad({levelId=levelId, subsUid=subsUid})
end

return AskForHelpUrlLogic