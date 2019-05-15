
local UIHelper = require 'zoo.panel.UIHelper'
local Misc = require 'zoo.quarterlyRankRace.utils.Misc'
local SharePicture = require 'zoo.quarterlyRankRace.utils.SharePicture'

local rrMgr


local RankRaceHeadFrameGetPanel = class(BasePanel)

function RankRaceHeadFrameGetPanel:create()

	if not RankRaceMgr then
        require 'zoo.quarterlyRankRace.RankRaceMgr'
    end

    rrMgr = RankRaceMgr:getInstance()


    local panel = RankRaceHeadFrameGetPanel.new()
    panel:init()
    return panel
end

function RankRaceHeadFrameGetPanel:init()
    local ui = UIHelper:createUI("ui/RankRace/showoff.json", "rank.race.showoff/panel")
    UIUtils:adjustUI(ui, 222, nil, nil, 1724)

	BasePanel.init(self, ui)

	ui:getChildByPath('label2'):setVisible(false)

	local animalAnim = UIHelper:createArmature2('skeleton/RankRaceDan', 'rank.race.sk/animal')
	self.ui:addChild(animalAnim)
	animalAnim:setPosition(ccp(480, -1100))

	UIHelper:setAnimTitle( animalAnim, localize('rank.race.img.share.title.11') )

	local resName = 'rank.race.sk/pao1'

	local paoAnim = UIHelper:createArmature2('skeleton/RankRaceDan', resName)
	self.ui:addChild(paoAnim)
	paoAnim:setPosition(ccp(480, -540))

	self.refNodes = {}

	local scale = 1.08
    
    local Rewards = {}
    Rewards.itemId = 66012
    Rewards.num = 1

	local con = UIHelper:getCon(paoAnim, 'pao1')
	if con then
		if Rewards then
			local rewardItem = UIHelper:createUI('ui/RankRace/dan.json', 'rank.dan_/@RewardItem')
			rewardItem:setScale(scale)
			table.insert(self.refNodes, rewardItem)
			rewardItem:setPositionX((247 - 176 * scale)/2 + 21.85/2)
			rewardItem:setPositionY((243 + 178 * scale)/2 - 21.65/2)
			rewardItem:setRewardItem(Rewards)
			con:addChild(rewardItem.refCocosObj)

			rewardItem.userData = {
				itemId =  Rewards.itemId,
				num = Rewards.num,
			}
		end
	end

    animalAnim:playByIndex(0, 1)
	paoAnim:playByIndex(0, 1)

	local btn = GroupButtonBase:create(self.ui:getChildByPath('btn'))
	btn:setString('领取')
	btn:ad(DisplayEvents.kTouchTap, function ( ... )
		if self.isDisposed then return end
		self:onCloseBtnTapped(true)
	end)
end

function RankRaceHeadFrameGetPanel:fly( callback )
	if self.isDisposed then return end
	-- body

	if self.flying then
		return
	end

	self.flying = true

	local counter = #self.refNodes + 1

	local function onEnd( ... )
		counter = counter - 1
		if counter <= 0 then
			if callback then
				callback()
				callback = nil
			end
		end
	end

	for i = 1, 6 do

		if self.refNodes[i]  then
			if ItemType:isHeadFrame(self.refNodes[i].userData.itemId) then
				onEnd()
			else
				local bounds = self.refNodes[i]:getGroupBounds()
				local anim = FlyItemsAnimation:create(
					Misc:clampRewardsNum(
						{{itemId = self.refNodes[i].userData.itemId, num = self.refNodes[i].userData.num}}
					)
				)

				anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
				anim:setFinishCallback(onEnd)
				anim:play()
			end
		end
	end

	onEnd()

end

function RankRaceHeadFrameGetPanel:dispose( ... )
	-- body
	BasePanel.dispose(self, ...)

	for _, v in ipairs(self.refNodes or {}) do
		v:dispose()
	end
end

function RankRaceHeadFrameGetPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function RankRaceHeadFrameGetPanel:popout()
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
	self:popoutShowTransition()
end

function RankRaceHeadFrameGetPanel:onCloseBtnTapped( needShare )
	if self.isDisposed then return end

    local ItemID = 66012
    if ItemType:isHeadFrame(ItemID) then
        local now = Localhost:timeInSec()
        local nextWeekStartTS = rrMgr:getNextWeekStartTS()

		local delta = ( nextWeekStartTS - now ) * 1000 --毫秒
		HeadFrameType:setProfileContext(nil):addHeadFrame(ItemType:convertToHeadFrameId(ItemID), delta,true)
	end

    self:_close()

--	self:fly(function ( ... )
--    	if self.isDisposed then return end
--    	if Misc:isSupportShare() then
--    		if needShare then
--        		self:share()
--        	end
--        end
--        self:_close()
--    end)
end

function RankRaceHeadFrameGetPanel:popoutShowTransition( ... )
    if self.isDisposed then return end

    local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
    layoutUtils.setNodeRelativePos(self.ui:getChildByPath('closeBtn'), layoutUtils.MarginType.kTOP, 5)
end

return RankRaceHeadFrameGetPanel
