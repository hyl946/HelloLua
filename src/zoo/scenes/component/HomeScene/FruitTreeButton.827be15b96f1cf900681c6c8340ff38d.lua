require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"

FruitTreeButton = class(IconButtonBase)

function FruitTreeButton:create()
	local instance = FruitTreeButton.new()
	assert(instance)
	instance:initShowHideConfig(ManagedIconBtns.FRUIT)
	if instance then instance:init() end
	return instance
end

function FruitTreeButton:init()
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_fruit_tree')

	IconButtonBase.init(self, self.ui)

	self.numTip = self:addRedDotNum()
	self.upgradeTip =  self.ui:getChildByName("flag")

	local function onEnterHandler(evt)
		if evt == "enter" then self:refresh() end
	end
	self:registerScriptHandler(onEnterHandler)

	self:refresh()

	Notify:register("AchiUpgradeEvent", self.refresh, self)
end

function FruitTreeButton:refresh()
    self:stopHasNumberAni()

	local function getUid()
		local uid = '12345'
		if UserManager and UserManager:getInstance().user then
			uid = UserManager:getInstance().user.uid or '12345'
		end
		uid = tostring(uid)
		return uid
	end
	local uid = getUid()

	local hasThisKey = CCUserDefault:sharedUserDefault():getIntegerForKey("FruitTreeButton_IsOpened"..uid) or 0
	local level = FruitTreePanelModel:sharedInstance():getTreeLevel()
	if hasThisKey == 0  and level == 4 then
		self.numTip:setVisible(false)
		self.upgradeTip:setVisible(true)
	else
		local num = FruitTreeButtonModel:getCrowNumber()
		self.numTip:setNum(num)
		self.numTip:setVisible(true)
		if num > 0 then
            self:playHasNumberAni()
        end
		self.upgradeTip:setVisible(false)
	end
	
end

function FruitTreeButton:dispose()
	Notify:unregister("AchiUpgradeEvent", self)
	IconButtonBase.dispose(self)
end


FruitTreeButtonModel = class()
function FruitTreeButtonModel:getCrowNumber()
	if not kUserLogin then --离线默认不显示剩余采摘次数
		return 0
	end

	local meta = MetaManager:getInstance().fruits_upgrade
	if type(meta) ~= "table" then return 0 end
	local extend = UserManager:getInstance():getUserExtendRef()
	if type(extend) ~= "table" then return 0 end
	local fruitTreeLevel = extend:getFruitTreeLevel()
	if type(fruitTreeLevel) ~= "number" then return 0 end
	local upgrade = meta[fruitTreeLevel]
	if type(upgrade) ~= "table" or type(upgrade.pickCount) ~= "number" then return 0 end
	local dailyData = UserManager:getInstance():getDailyData()
	if type(dailyData) ~= "table" or type(dailyData.pickFruitCount) ~= "number" then return 0 end
	return upgrade.pickCount - dailyData.pickFruitCount + Achievement:getRightsExtra( "FruitGetCount" )
end

function FruitTreeButtonModel:isNeedShow()
	if self:getCrowNumber() >0 then
		return true
	end

	if InciteManager:isEntryEnable(EntranceType.kTree) and InciteManager:getReadySdk(nil, EntranceType.kTree) then
        local count = InciteManager:getCount(EntranceType.kTree)
		if count>0 then
			return true
		end
		
		local info = FruitTreeSceneLogic:sharedInstance():getInfo()
		return info and info[-1] ~= nil
	end

	return false
end