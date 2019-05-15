require 'zoo.panel.basePanel.BasePanel'

---------------------------------------------------
---------------------------------------------------
---------------------------------------------------
---------------------------------------------------
-- ResourceManager:sharedInstance():addJsonFile("ui/star_achievement.json")

LadybugPromptPanel = class(BasePanel)

function LadybugPromptPanel:create(rewardElapse,rewardMeta)
	local panel = LadybugPromptPanel.new()
	panel:loadRequiredResource(PanelConfigFiles.star_achevement)
	panel.rewardElapse = rewardElapse
	panel.rewardMeta = rewardMeta
	panel:init()
	return panel
end

function LadybugPromptPanel:init()
	self:initData()

	self:initUI()
end

function LadybugPromptPanel:initData()

end

function LadybugPromptPanel:unloadRequiredResource()
end

function LadybugPromptPanel:initUI()
	-- local function onTouchEvent( evt )
	-- 	if evt.name == DisplayEvents.kTouchTap then
	-- 		self:onCloseBtnTapped()
	-- 	end
	-- end

	self.ui = self:buildInterfaceGroup("LadybugPromptPanel")

	BasePanel.init(self, self.ui)

	self.label1 = self.ui:getChildByName("label1")
	self.label2 = self.ui:getChildByName("label2")
	self.reward = self.ui:getChildByName("reward")
	self.lbg = self.ui:getChildByName("bg")

	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	local wSize = CCDirector:sharedDirector():getWinSize()
	local vOrigin = CCDirector:sharedDirector():getVisibleOrigin()

	local size = self:getGroupBounds().size
	self:setScale(visibleSize.height/wSize.height)

	-- self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()
	self:setPositionY(0)

	-- 调整元素Y位置
	local dx,dy = HomeScene:sharedInstance().starButton:getPositionX(),HomeScene:sharedInstance().starButton:getPositionY()
	-- if _G.isLocalDevelopMode then printx(0, "~~~~~~~~~~~~~~>>>>>>><<<<<<<<<",dy,self.label1:getPositionY()) end
	-- self.lbg:setPositionY(dy- visibleSize.height )
	-- self.label1:setPositionY(dy- visibleSize.height-33)
	-- self.label2:setPositionY(dy- visibleSize.height-66)
	-- self.reward:setPositionY(dy- visibleSize.height-42)
	
	-- touch close
	self.bg = LayerColor:create()
	self.bg:setColor(ccc3(0, 0, 255))
	self.bg:setAnchorPoint(ccp(0, 0))
	self.bg:setOpacity(1)
	self.bg:setContentSize(CCSizeMake(visibleSize.width,visibleSize.height))
	self.bg:setTouchEnabled(true, 0, false)
	self.bg:setPositionX(0)
	self.bg:setPositionY(-visibleSize.height)
	-- bg:ad(DisplayEvents.kTouchTap, onTouchEvent)
	self.ui:addChildAt(self.bg,0)

	local txt = Localization:getInstance():getText("mystar_hint1", {num=self.rewardElapse}) 
	local txt2 = Localization:getInstance():getText("mystar_hint2", {item="           "}) 

	self.label1:setString(txt)
	self.label2:setString(txt2)
	-- reward
	self.rewardItemId		= self.rewardMeta.reward[1].itemId
	self.rewardItemCount	= self.rewardMeta.reward[1].num
	local rewardItem = StarRewardItem2:create(self.reward, self.rewardItemId, self.rewardItemCount)

	local numberY = rewardItem.numberLabel:getPositionY()
	rewardItem.numberLabel:setPositionY(numberY + 35)

	self.reward:getChildByName("newBg"):setVisible(false)
	self.reward:getChildByName("itemNameLabel"):setVisible(false)

	-- 魔力鸟比较胖
	if (self.rewardItemId == 10052) then

	else
		self.reward:setPositionX(self.reward:getPositionX() - 4)
	end
end

function LadybugPromptPanel:popout()
	PopoutManager:sharedInstance():add(self, false, false)
end

function LadybugPromptPanel:onCloseBtnTapped( ... )
	PopoutManager:sharedInstance():remove(self, true)
end











