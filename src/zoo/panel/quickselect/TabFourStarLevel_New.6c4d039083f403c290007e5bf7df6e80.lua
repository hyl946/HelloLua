require "zoo.animation.FlowerNode"
require 'zoo.panel.quickselect.TabFourStarComplete_New'
-- require 'zoo.panel.quickselect.TabFourStarNone'


-- require("zoo/panel/quickselect/TabFourStarNone_New.lua")
require("zoo/panel/quickselect/TabFourStarSome_New.lua")

----------------------------------------------------
----------------- TabFourStarLevel_New -----------------
----------------------------------------------------

assert(BaseUI)
TabFourStarLevel_New = class(BaseUI)

function TabFourStarLevel_New:create(ui,hostPanel , heightNode )
	local panel = TabFourStarLevel_New.new()
	panel:init(ui,hostPanel , heightNode )
	return panel
end

function TabFourStarLevel_New:init( ui , hostPanel , heightNode )

	self.hostPanel = hostPanel
	-- self.start3Layer = start3Layer
	-- self.start4Layer = start4Layer
	self.heightNode = heightNode
	BaseUI.init(self, ui)
	self.ui:getChildByName("content"):setAlpha( 0 )

end

function TabFourStarLevel_New:setVisible(value)
	BaseUI.setVisible(self,value)

	if (value == true) then 
		self:initContent()
	else
		self:removeContent()
	end
end

function TabFourStarLevel_New:initContent()
	self.ui:removeChildren()
	-- self.hostPanel.title_full_four_star:setVisible(false)
	-- self.hostPanel.title_full_hidden:setVisible(false)

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

			local part1Pro = #dataList_3 / (#dataList_3 + #dataList_4)

			if _G.isLocalDevelopMode then printx(100, " part1Pro = " , part1Pro) end

			local minPro = 300 / self.heightNode

			part1Pro = math.max( minPro , part1Pro )
			part1Pro = math.min( 1-minPro , part1Pro )
			if _G.isLocalDevelopMode then printx(100, " part1Pro = " , part1Pro) end
			if _G.isLocalDevelopMode then printx(100, "  #dataList_3 = " ,  #dataList_3) end
			if _G.isLocalDevelopMode then printx(100, "  #dataList_4 = " ,  #dataList_4) end

			if _G.isLocalDevelopMode then printx(100, "  isFindAll = " ,  isFindAll) end

			local part2Pro = 1 - part1Pro

			if #dataList_3 >0 then
				isStar3 = true
				local someState = TabFourStarSome_New:create(self.hostPanel , dataList_3 ,isStar3 ,isStar3Full , self.heightNode ,part1Pro )
				self.ui:addChild(someState)
				someState:setPositionX(someState:getPositionX() + 0 )
				someState:setPositionY(someState:getPositionY()   )
				posY = self.heightNode * part1Pro + 10
			end

			if #dataList_4 >0 then
				isStar3 = false
				local someState = TabFourStarSome_New:create(self.hostPanel , dataList_4 ,isStar3 , isStar4Full , self.heightNode , part2Pro ,isFindAll)
				self.ui:addChild(someState)
				someState:setPositionX(someState:getPositionX() +0 )
				someState:setPositionY(someState:getPositionY()  - posY )
			end
			
			if isFindAll then
				self.hostPanel.txtDesc4:setString(" ")
			else
				self.hostPanel.txtDesc4:setString("更多4星关卡等你发现哦~")
			end
		else
			--没有四星关通关		
			local noneState = TabFourStarNone_New:create( 1 )
			self.ui:addChild(noneState)
			self.hostPanel.txtDesc4:setString(Localization:getInstance():getText(" "))
		end
	else
		self.hostPanel.txtDesc4:setString(" ")
		--全部四星关通关
		local noneState = TabFourStarComplete_New:create(self.hostPanel , self.heightNode )
		self.ui:addChild(noneState)

		
		-- local posY = 700/2 -self.heightNode /2
		-- noneState:setPositionY( posY )
	end

	DcUtil:UserTrack({
		category = "ui",
		sub_category = "click_fourstar_chooselevel",
	},true)

end

function TabFourStarLevel_New:removeContent()
 	self.ui:removeChildren()
end

