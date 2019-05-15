require "zoo.scenes.component.HomeScene.flyToAnimation.FlySpecialItemAnimation"

local AnimationPlayer = require 'zoo.panel.endGameProp.anim.AnimationPlayer'
local PropertyTrack = require 'zoo.panel.endGameProp.anim.PropertyTrack'
local UIHelper = require 'zoo.panel.UIHelper'
local Misc = require 'zoo.quarterlyRankRace.utils.Misc'

local function OpacitySetter( context, Opacity )
	if (not context) or context.isDisposed then return end
	context:setOpacity(Opacity)
end

local BoxCtrl = class()

function BoxCtrl:ctor( boxRes, boxIndex, ShowIndex )
	self.ui = boxRes
	self.boxIndex = boxIndex
    self.ShowIndex = ShowIndex or boxIndex

	self.target = self.ui:getChildByPath('target')
	self.label = self.ui:getChildByPath('target/label')
	self.label:setVerticalAlignment(kCCVerticalTextAlignmentCenter)


	self.icon = self.ui:getChildByPath('icon')
	self.sp1 = self.ui:getChildByPath('1')
	self.sp2 = self.ui:getChildByPath('2')
	self.sp3 = self.ui:getChildByPath('3')

	self:refresh()
	RankRaceMgr:getInstance():addObserver(self)
end


function BoxCtrl:setGoldBoxUI( goldBoxUI )
	-- body
	self.goldBoxUI = goldBoxUI
end

function BoxCtrl:createAnim( ... )
	if self.isDisposed then return end
	
	local lightOpacityTrank = PropertyTrack.new()
	lightOpacityTrank:setName('lightOpacityTrank')
	lightOpacityTrank:setPropertyAccessor(nil, OpacitySetter)
	lightOpacityTrank:setTargetPath('./2')
	lightOpacityTrank:setFrameDataConfig({
		{index = 0, data = 255},
		{index = 10, data = math.floor(0.34*255)},
		{index = 20, data = 255},
	})
	self.animPlayer:addTrack(lightOpacityTrank)
end

function BoxCtrl:dispose( ... )
	RankRaceMgr:getInstance():removeObserver(self)
end

function BoxCtrl:onNotify( obKey, ...)
	if self.ui.isDisposed then return end
	if self['_handle_' .. obKey] then
		self['_handle_' .. obKey](self, ...)
		return
	end
end

function BoxCtrl:_handle_kTargetCountChange0( ... )
	if self.ui.isDisposed then return end
	self:refresh()
end

function BoxCtrl:_handle_kRewardInfoChange( ... )
	if self.ui.isDisposed then return end
	self:refresh()
end

local BoxAniPosConfig = {
	[3] = {
		{x = -105, y = 105, scale = 0.9},	
		{x = -110, y = 105, scale = 0.9},	
		{x = -110, y = 105, scale = 0.9},	
		{x = -110, y = 105, scale = 0.9},	
		{x = -110, y = 105, scale = 0.9},	
	    {x = -110, y = 105, scale = 0.9},
		{x = -110, y = 105, scale = 0.9},	
	},
	[4] = {
		{x = -105, y = 105, scale = 0.9},	
		{x = -110, y = 105, scale = 0.9},	
		{x = -110, y = 105, scale = 0.9},	
		{x = -110, y = 105, scale = 0.9},	
		{x = -110, y = 105, scale = 0.9},	
	    {x = -110, y = 105, scale = 0.9},
		{x = -110, y = 105, scale = 0.9},
	},
}

function BoxCtrl:refresh( ... )
	if self.ui.isDisposed then return end
		
	self.icon:setVisible(false)
	self.sp1:setVisible(false)
	self.sp2:setVisible(false)
	self.sp2:stopAllActions()
	self.sp3:setVisible(false)
	self.target:setVisible(false)

	local notFounded = true
	local state = RankRaceMgr:getInstance():getBoxRewardState(self.boxIndex)
	if state == RankRaceMgr.BoxState.kUnavaliable then
		self.icon:setVisible(true)
		self.sp1:setVisible(true)
	elseif state == RankRaceMgr.BoxState.kAvaliable then
		if not self.boxAni then
            local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()
            self.boxAni = ArmatureNode:create('rank_race_reward_box_ani'..SaijiIndex..'/boxAni'..self.ShowIndex)
            local AniConfig = BoxAniPosConfig[SaijiIndex]

			self.boxAni:update(0.001)
			self.ui:addChild(self.boxAni)
			self.boxAni:setPosition(ccp(AniConfig[self.boxIndex].x, AniConfig[self.boxIndex].y)) 
			self.boxAni:setScale(AniConfig[self.boxIndex].scale)
			self.boxAni:play("p", 0)
		end
	elseif state == RankRaceMgr.BoxState.kRewarded then
		if self.boxAni then
			self.boxAni:removeFromParentAndCleanup(true)
			self.boxAni = nil 
		end
		self.sp3:setVisible(true)
		self.icon:setVisible(true)
	end

	if self.boxIndex == RankRaceMgr:getInstance():getFirstUnavaliableBoxIndex() then
		self.target:setVisible(true)
		local info = RankRaceMgr:getInstance():getBoxesRespectiveInfos()[self.boxIndex]

		local text = string.format('%d/%d', info[1], info[2])

		if self.targetLabel then self.targetLabel:removeFromParentAndCleanup(true) end

		self.targetLabel = BitmapText:create(text, 'fnt/newzhousai_rubynum.fnt')
		self.targetLabel:setAnchorPoint(ccp(0.5, 0.5))

		local pos = self.label:getPosition()
		local dime = self.label:getDimensions()

		self.targetLabel:setPositionX(pos.x + dime.width/2)
		self.targetLabel:setPositionY(pos.y - dime.height/2-1)
		self.target:addChild(self.targetLabel)
		self.targetLabel:setScale(math.min(0.6, 110/self.targetLabel:getContentSize().width))
	end
end

function BoxCtrl:onTap( ... )
	if self.ui.isDisposed then return end
	if not self.canvas then return end
	if self.canvas.isDisposed then return end

	local state = RankRaceMgr:getInstance():getBoxRewardState(self.boxIndex)
	if state == RankRaceMgr.BoxState.kUnavaliable then
		local rewards = RankRaceMgr:getInstance():getMeta():getBoxRewardConfig()[self.boxIndex].rewards
		local tipPanel = BoxRewardTipPanel:create({ rewards=table.clone(rewards, true)})

		local info = RankRaceMgr:getInstance():getBoxesRespectiveInfos()[self.boxIndex]
		tipPanel:setTipString(string.format('再得%d宝石可领', info[2] - info[1]))
		self.canvas:addChild(tipPanel)
		local bounds = self.ui:getGroupBounds()
		tipPanel:setArrowPointPositionInWorldSpace(0,bounds:getMidX(),bounds:getMidY())
	elseif state == RankRaceMgr.BoxState.kAvaliable then
		RankRaceMgr:getInstance():receiveBoxRewards(self.boxIndex, function ( rewards )
			if self.ui.isDisposed then return end
			local goldBoxBounds = self.goldBoxUI:getGroupBounds()
            local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()

            local index = self.boxIndex
            if self.boxIndex == 7 then
            	local bigDan = RankRaceMgr.getInstance():getCurBigDan()
                if bigDan == 1 then
                    index = 8
                elseif bigDan == 2 then
                    index = 9
                elseif bigDan == 3 then
                    index = 10
                end
            end
            local itemRes = 'n.race.rank/s'..SaijiIndex .. '/box'..index

            local boxUI = UIHelper:getBuilder('ui/RankRace/reward.json'):buildGroup(itemRes)

            local _icon = boxUI:getChildByPath('icon')
            local _sp1 = boxUI:getChildByPath('1')
            _icon:removeFromParentAndCleanup(false)
            _sp1:removeFromParentAndCleanup(false)
            boxUI:removeFromParentAndCleanup(true)
            _icon:addChild(_sp1)

            _sp1:setCascadeOpacityEnabled(true)
            _sp1:setOpacityModifyRGB(true)

            _icon:setCascadeOpacityEnabled(true)
            _icon:setOpacityModifyRGB(true)

            local scale = 1.0 / _icon:getScaleX()

            _sp1:setPositionX((- _icon:getPositionX() + _sp1:getPositionX()) * scale)
            _sp1:setPositionY((- _icon:getPositionY() + _sp1:getPositionY()) * scale + _icon:getContentSize().height)

            _sp1:setScale(scale)

			local boxRes = CCSprite:createWithSpriteFrameName('n.race.rank/as/s10000')
	    	boxRes:retain()

            local ItemInfo = {
			    [ItemType.RACE_TARGET_1] = {
				    targetPos = ccp(goldBoxBounds:getMidX(), goldBoxBounds:getMidY()),
                    frameName = "Prop_50104_inner0000"
			    }
		    }

			local animation = OpenBoxAnimation:create(Misc:clampRewardsNum(rewards), _icon.refCocosObj, ItemInfo )
			animation:setFinishCallback(function ()
				RankRaceMgr.getInstance():notify(RankRaceOBKey.kRefreshCanLotteryShow)
			end)
			animation:play()


			DcUtil:UserTrack({
		        category='weeklyrace2018', 
		        sub_category='weeklyrace2018_get_reward',
		        t1 = self.boxIndex,
		    })

		end, function ( evt )

			local errCode = evt.data
			if errCode then
				CommonTip:showTip(localize('error.tip.' .. errCode))
			else
				CommonTip:showTip(localize('rank.race.box.fail'))
			end

		end, function ( ... )

			CommonTip:showTip(localize('rank.race.box.cancel'))

		end)
	elseif state == RankRaceMgr.BoxState.kRewarded then
		CommonTip:showTip(localize('rank.race.box.empty'))
	end
end

function BoxCtrl:setCanvas( canvas )
	self.canvas = canvas
end

return BoxCtrl