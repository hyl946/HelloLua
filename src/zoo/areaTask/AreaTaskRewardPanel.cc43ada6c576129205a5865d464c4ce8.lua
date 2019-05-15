
local UIHelper = require 'zoo.panel.UIHelper'
local Misc = require 'zoo.quarterlyRankRace.utils.Misc'
local SharePicture = require 'zoo.quarterlyRankRace.utils.SharePicture'

local rrMgr


local AreaTaskRewardPanel = class(BasePanel)

function AreaTaskRewardPanel:create(rewards)

    local panel = AreaTaskRewardPanel.new()
    panel:init(rewards)
    return panel
end

function AreaTaskRewardPanel:init(rewards)
    local ui = UIHelper:createUI("ui/RankRace/showoff.json", "rank.race.showoff/panel")
    UIUtils:adjustUI(ui, 222, nil, nil, 1724)

	BasePanel.init(self, ui)

	ui:getChildByPath('label2'):setVisible(false)

	local animalAnim = UIHelper:createArmature2('skeleton/area_task_reward', 'areaTask/anim')
	animalAnim:setAnimationScale(1.4)
	self.ui:addChild(animalAnim)
	animalAnim:setPosition(ccp(160, -300))


	self.refNodes = {}

	local scale = 1.08

	local rewardNum = #rewards
	local res_prefix = 'p'
	if rewardNum == 2 then
		res_prefix = 'p1'
		scale = 1.28
	end


	local res_name = nil

	if rewardNum == 1 then
		res_name = 'p2'
	end

	for i = 1, 3 do
		local con = UIHelper:getCon(animalAnim, res_name or (res_prefix .. i))
		if con then
			if rewards[i] then
				local rewardItem

				if ItemType:isTimeProp(rewards[i].itemId) then
					rewardItem = UIHelper:createUI('ui/area_task.json', 'area_task.panel/@RewardItem')
				else
					rewardItem = UIHelper:createUI('ui/area_task.json', 'area_task.panel/1@RewardItem')
				end

				rewardItem:setScale(scale)
				table.insert(self.refNodes, rewardItem)
				rewardItem:setPositionX((191.95 - 176 * scale)/2 - 0/2)
				rewardItem:setPositionY((191.95 + 178 * scale)/2 + 3.6/2)
				rewardItem:setRewardItem(rewards[i])
				con:addChild(rewardItem.refCocosObj)


				local nNumForDisplay = rewards[i].num
				if ItemType:isMergableItem(rewards[i].itemId) then
					nNumForDisplay = 1
				end

				rewardItem.userData = {
					itemId = rewards[i].itemId,
					num = nNumForDisplay,
				}

				

			end
		end
	end

	animalAnim:playByIndex(0, 1)

	local btn = GroupButtonBase:create(self.ui:getChildByPath('btn'))

	btn:setString('领取')

	btn:ad(DisplayEvents.kTouchTap, function ( ... )
		if self.isDisposed then return end

		self:onCloseBtnTapped()
	end)

	btn:setVisible(false)

	self.ui:getChildByPath('closeBtn'):setVisible(false)

	setTimeOut(function ( ... )
		if self.isDisposed then return end
		self:onCloseBtnTapped()
	end, 5)

end


local function clampRewardsNum( rewards )
    return table.map(function ( v )
        -- return {itemId = v.itemId, num = math.min(5, v.num)}

        if v.itemId == 2 or v.itemId == 14 then
        	return v
        end
        return {itemId = v.itemId, num = math.min(v.num, 16)}
    end, rewards)
end


function AreaTaskRewardPanel:fly( callback )
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

			elseif ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE == self.refNodes[i].userData.itemId then
				local bounds = self.refNodes[i]:getGroupBounds()
				local ngEnergyAnim = FlyTopEnergyBottleAni:create(ItemType.INFINITE_ENERGY_BOTTLE)
				ngEnergyAnim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
				ngEnergyAnim:setFinishCallback(onEnd)
				ngEnergyAnim:play()
			else
				local bounds = self.refNodes[i]:getGroupBounds()
				local anim = FlyItemsAnimation:create(
					clampRewardsNum(
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

function AreaTaskRewardPanel:dispose()
	BasePanel.dispose(self)

	for _, v in ipairs(self.refNodes or {}) do
		v:dispose()
	end
end

function AreaTaskRewardPanel:_close()
    if self.isDisposed then return end
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self)
end

function AreaTaskRewardPanel:popout()
	PopoutManager.sharedInstance():add(self,true,false)
	self:popoutShowTransition()
end

function AreaTaskRewardPanel:popoutPush()
	PopoutQueue.sharedInstance():push(self,true,false)
end




function AreaTaskRewardPanel:onCloseBtnTapped(  )
	if self.isDisposed then return end

	self:fly(function ( ... )
    	if self.isDisposed then return end
        self:_close()
    end)
end

function AreaTaskRewardPanel:popoutShowTransition( ... )
    if self.isDisposed then return end

	local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
    local vSize = Director:sharedDirector():getVisibleSize()
    local wSize = Director:sharedDirector():getWinSize()
    local vOrigin = Director:sharedDirector():getVisibleOrigin()
    local mask = LayerColor:create()
    mask:changeWidthAndHeight(wSize.width/self.ui:getScaleX(), wSize.height/self.ui:getScaleY())
    mask:setColor(ccc3(0, 0, 0))
    mask:setOpacity(200)
    self.ui:addChildAt(mask, 0)
    local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
    layoutUtils.setNodeRelativePos(mask, layoutUtils.MarginType.kLEFT, 0)
    layoutUtils.setNodeRelativePos(mask, layoutUtils.MarginType.kBOTTOM,  -vOrigin.y)
    self.maskLayer = mask

    setTimeOut(function ( ... )
    	if self.isDisposed then return end
		self.allowBackKeyTap = true
    	UIUtils:setTouchHandler(self.maskLayer, function ( ... )
	    	if self.isDisposed then return end
	    	self:onCloseBtnTapped()
    	end, function ( ... )
    		return true
    	end)
    end, 1)

end



return AreaTaskRewardPanel
