require "zoo.panel.basePanel.BasePanel"
require "zoo.net.OnlineGetterHttp"
require "zoo.baseUI.ButtonWithShadow"

SVIPGetRewardPanel = class(BasePanel)

function SVIPGetRewardPanel:create()
	local panel = SVIPGetRewardPanel.new()
	panel:loadRequiredResource(PanelConfigFiles.BeginnerPanel)
	if panel:init() then
		return panel
	else
		panel = nil
		return nil
	end
end

function SVIPGetRewardPanel:init()

--    printx(0,"------------------")

	self.ui = self:buildInterfaceGroup('SvipGetReward/SvipGetRewardPanel')

	BasePanel.init(self, self.ui)

	self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)

	self.btnGet = self.ui:getChildByName("btn")
	self.btnGet = GroupButtonBase:create(self.btnGet)
    self.btnGet:setString(Localization:getInstance():getText("beginner.panel.btn.get.text"))
	local function onGetTouched()
		self:getReward()
	end
	self.btnGet:ad(DisplayEvents.kTouchTap, onGetTouched)

	return true
end

function SVIPGetRewardPanel:getReward()
    --获取奖励
    local function GetRewardAnim( position )
        local scene = Director:sharedDirector():getRunningScene()

        local vs = Director:sharedDirector():getVisibleSize()
        local vo = Director:sharedDirector():getVisibleOrigin()

        local CenterPos = ccp(vo.x+vs.width/2, vo.y+vs.height/2) 

        local function FlyGold()
            local anim = FlyItemsAnimation:create({{itemId = ItemType.GOLD, num = 200}})
            anim:setWorldPosition(ccp(CenterPos.x, CenterPos.y))
            anim:setFinishCallback( 
                function() 
                end )
            anim:play()
        end
        FlyGold()
    end

    local rewardId = 19
    local function onSuccess(evt)
         if type(evt.data) ~= "table" or type(evt.data.rewardItems) ~= "table" then 
            return 
        end
        local reward = {itemId = ItemType.GOLD, num = 200}
        UserManager:getInstance():addReward(reward)
        GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kAccountLogin, reward.itemId, reward.num, DcSourceType.kSvipBindPhone, nil, 10066)
       
        CommonTip:showTip(localize("test for dan.luo"), "negative", nil, 5)

        UserManager:getInstance():setUserRewardBit(rewardId, true)

        GetRewardAnim()

        --打点
        local params = {
		    game_type = "stage",
		    game_name = "svip",
		    category = 'SVIP',
		    sub_category = "UI_svipphonenumber_complete",
            t1 = 1,
	    }

	    DcUtil:dcForUserTrack(params)
    end

    local function onError(evt)
        CommonTip:showTip("网络连接失败，请连接网络后重启游戏")

         --打点
        local params = {
		    game_type = "stage",
		    game_name = "svip",
		    category = 'SVIP',
		    sub_category = "UI_svipphonenumber_complete",
            t1 = 2,
	    }

	    DcUtil:dcForUserTrack(params)
    end

    local http = GetRewardsHttp.new(true)
    http:addEventListener(Events.kComplete, onSuccess)
    http:addEventListener(Events.kError, onError)

    http:load(rewardId)

    PopoutManager:sharedInstance():remove(self, true)
    if self.close_cb then self.close_cb() end
end

function SVIPGetRewardPanel:popout(close_cb)
    self.close_cb = close_cb
	PopoutQueue:sharedInstance():push(self)
end