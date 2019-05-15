require "zoo.animation.FlowerNode"
require 'zoo.panel.quickselect.TabFourStarComplete'
require 'zoo.panel.quickselect.TabFourStarNone'

----------------------------------------------------
----------------- TabFourStarLevel -----------------
----------------------------------------------------

assert(not TabFourStarLevel)
assert(BaseUI)
TabFourStarLevel = class(BaseUI)

function TabFourStarLevel:create(ui,hostPanel)
	local panel = TabFourStarLevel.new()
	panel:init(ui,hostPanel)
	return panel
end

function TabFourStarLevel:init(ui,hostPanel)
	self.hostPanel = hostPanel
	-- self.start3Layer = start3Layer
	-- self.start4Layer = start4Layer
	BaseUI.init(self, ui)

	self.ui:getChildByName("content"):setAlpha(0)
end

function TabFourStarLevel:setVisible(value)
	BaseUI.setVisible(self,value)

	if (value == true) then 
		self:initContent()
	else
		self:removeContent()
	end
end

function TabFourStarLevel:initContent()
	self.ui:removeChildren()
	self.hostPanel.title_full_four_star:setVisible(false)
	self.hostPanel.title_full_hidden:setVisible(false)

	self.fourStarDataList = FourStarManager:getInstance():getFourStarLevels()

	-- self.start3Layer = self.hostPanel:getChildByName("start3Layer")
	-- self.start4Layer = self.hostPanel:getChildByName("start4Layer")

	if #FourStarManager:getInstance():getAllNotToFourStarLevels() > 0 then
		local dataList_3 ,dataList_4 = FourStarManager:getInstance():getAllUnlockStar4Levels()
		local isFindAll = FourStarManager:getInstance():isFindAllStar4Levels()
		

			
		if  #dataList_3 + #dataList_4 > 0 then 
			-- 部分四星关通关
			local posY = 0
			local isStar3 = false

			local isStar3Full = false
			local isStar4Full = false
			if #dataList_3 >0 and  #dataList_4 == 0 then
				isStar3Full = true
			elseif #dataList_3 ==0 and  #dataList_4 > 0 then
				isStar4Full = true
			end

			if #dataList_3 >0 then
				isStar3 = true
				local someState = TabFourStarSome:create(self.hostPanel , dataList_3 ,isStar3 ,isStar3Full )
				self.ui:addChild(someState)
				someState:setPositionX(someState:getPositionX() + 10 )
				someState:setPositionY(someState:getPositionY()  - 10 )
				posY = 340 
			end

			if #dataList_4 >0 then
				isStar3 = false
				local someState = TabFourStarSome:create(self.hostPanel , dataList_4 ,isStar3 , isStar4Full )
				self.ui:addChild(someState)
				someState:setPositionX(someState:getPositionX() +10 )
				someState:setPositionY(someState:getPositionY() - 10 - posY )
			end
			
			self.hostPanel.txtDesc:setString(" ")
			if isFindAll then
				self.hostPanel.txtDesc4:setString(" ")
			else
				self.hostPanel.txtDesc4:setString("更多4星关卡等你发现哦~")
			end
			
		else
			--没有四星关通关		
			local noneState = TabFourStarNone:create(self.hostPanel)
			self.ui:addChild(noneState)
			self.hostPanel.txtDesc:setString( "听说有些关卡可以获得四星哦~" )
			self.hostPanel.txtDesc4:setString(Localization:getInstance():getText(" "))

		end
	else
		--全部四星关通关
		local completeState = TabFourStarComplete:create(self.hostPanel)
		self.ui:addChild(completeState)
		self.hostPanel.txtDesc:setString("")
		self.hostPanel.title_full_four_star:setVisible(true)
	end

	DcUtil:UserTrack({
		category = "ui",
		sub_category = "click_fourstar_chooselevel",
	},true)

end

function TabFourStarLevel:removeContent()
 	self.ui:removeChildren()
end

