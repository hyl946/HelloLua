
local UIHelper = require 'zoo.panel.UIHelper'

local rewardPanel = class(BasePanel)
function rewardPanel:create( callback )
    local panel = rewardPanel.new()
    panel:init(callback)
    return panel
end

function rewardPanel:init(callback)
    self.callback = callback

    local ui = UIHelper:createUI("ui/MiniProgramPromote/MiniProgramPromote_reward.json", "MiniProgramPromote_reward/panel")
    BasePanel.init(self, ui)
    

    self.canClick = true
    local btn = GroupButtonBase:create(self.ui:getChildByPath('btn'))
    btn:ad(DisplayEvents.kTouchTap, function ( ... )
        if not self.canClick then return end

        self.canClick = false 

        -- body
        PaymentNetworkCheck.getInstance():check(function ()
            --do
            self:getReward()
        end, function ()
            CommonTip:showTip("该功能需要联网,请检查网络状态")
        end)
       
    end)
    btn:setString('领取')

    self.rewards = { {itemId = ItemType.TIMELIMIT_PRE_RANDOM_BIRD, num = 1}, {itemId = ItemType.GOLD, num = 1}, {itemId = ItemType.COIN, num = 8888} }
    self.pos = {}
    for i=1, 3 do
        local str = "bubble"..i

        local bubble = self.ui:getChildByPath(str)

        local item = self:getItemSprite( self.rewards[i].itemId, self.rewards[i].num, true)
        bubble:addChild(item)
        self.pos[i] = item
    end
end

function rewardPanel:getReward( bErrorClose )

    if bErrorClose == nil then bErrorClose = false end

    local function FlyEnd()
        self.canClick = true
        self:_close()
    end

    -- 请求活动数据
	local function onSuccess(evt)
		local data = evt.data
        local rewardItems = data.rewardItems

        if rewardItems then
            for i,reward in ipairs(rewardItems) do
                if UserManager.addRewardsWithDc and type(UserManager.addRewardsWithDc) == "function" then
			        UserManager:getInstance():addRewardsWithDc({reward}, { source = "activity", activityId = MiniProgramPromoteManager.ACT_ID })
			        hasItemRewards = true
		        else
			        GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kActivity, reward.itemId, reward.num, DcSourceType.kActPre..MiniProgramPromoteManager.ACT_ID, nil, MiniProgramPromoteManager.ACT_ID)
			        UserManager:getInstance():addReward(reward, true)
			        Localhost:getInstance():flushCurrentUserData()
		        end
		        UserService:getInstance():addRewards({reward})
            end
        end

        self:fly( FlyEnd )
	end

	local function onFail(evt)
		local errcode = evt and evt.data or nil
	    if errcode then
		    CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(errcode)), "negative")
	    end

        self.canClick = true
        if bErrorClose then FlyEnd() end
	end

	local function onCancel( ... )
		-- body
        self.canClick = true
        if bErrorClose then FlyEnd() end
	end

    local params = {
		actId = MiniProgramPromoteManager.ACT_ID,
		rewardId = 1,
	}

	HttpBase:syncPost("activityReward",params,
		onSuccess, onFail, onCancel)


    MiniProgramPromoteManager.getInstance():dc( 'reward', 'reward_get' )
end

function rewardPanel:fly( callback )

    local counter = #self.rewards

    local function onEnd( ... )
        counter = counter - 1

        if counter <= 0 then
            if callback then
                callback()
                callback = nil
            end
        end
    end

    for i=1, 3 do
        if self.rewards[i] and self.pos[i] then
            local bounds = self.pos[i]:getGroupBounds()
            local num = self.rewards[i].num
            if self.rewards[i].itemId == 66018 then
                num = 1
            end

            local anim = FlyItemsAnimation:create({{itemId = self.rewards[i].itemId, num = num}})
            anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
            anim:setFinishCallback(onEnd)
            anim:play()
        end
    end
end

function rewardPanel:_close()
    if self.callback then self.callback() end
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self)
end

function rewardPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    -- PopoutManager:sharedInstance():add(self, true)
    PopoutManager:sharedInstance():add(self, true, nil, nil, nil, 220)
    self.allowBackKeyTap = true
end

function rewardPanel:setPositionForPopoutManager()
    local vSize = CCDirector:sharedDirector():getVisibleSize()
    local posAdd =  CCDirector:sharedDirector():getVisibleOrigin().y
    self:setPosition(ccp(self:getHCenterInScreenX(), -(vSize.height - self:getVCenterInScreenY() + posAdd)))
end

function rewardPanel:onCloseBtnTapped( ... )
    self:getReward( true )
end

function rewardPanel:getItemSprite( itemId, itemNum, autoAddTimeLimitIcon  )

    local paoBG = Sprite:createEmpty()

    if itemId == 50016 then
        itemId = 10066
    end

    local posX = 57/0.7 
    local posY = 60/0.7

    local ret = ResourceManager:sharedInstance():buildItemSprite(itemId)
    if autoAddTimeLimitIcon and ItemType:isTimeProp(itemId) then
        local time_prop_flag = ResourceManager:sharedInstance():createTimeLimitFlag(itemId)
        ret:addChild(time_prop_flag)
        local size = ret:getContentSize()
        time_prop_flag:setPosition(ccp(size.width/2, size.height/5))
        time_prop_flag:setScale(1 / math.max(ret:getScaleY(), ret:getScaleX()))
    end
    paoBG:addChild(ret)
    ret:setAnchorPoint(ccp(0.5, 0.5))
    ret:setPosition(ccp(paoBG:getContentSize().width/2 + posX ,paoBG:getContentSize().height/2 + posY ))
    paoBG.ret = ret

    local num = BitmapText:create('x' .. tostring( itemNum ), 'fnt/event_default_digits.fnt')
    num:setAnchorPoint(ccp(0.5, 0.5))
    num:setPosition(ccp(paoBG:getContentSize().width/2 + posX ,paoBG:getContentSize().height/2 - 90 + posY ))
    paoBG:addChild( num )
    num:setScale(1.2)
    paoBG.num = num

    return paoBG
end

return rewardPanel