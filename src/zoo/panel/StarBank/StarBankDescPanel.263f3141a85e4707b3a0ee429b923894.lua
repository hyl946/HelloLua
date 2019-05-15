--[[
 * StarBankDescPanel
 * @date    2017-12-14 15:32:36
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

StarBankDescPanel = class(BasePanel)

function StarBankDescPanel:ctor( ... )
	-- body
end

function StarBankDescPanel:create( ... )
	local panel = StarBankDescPanel.new()
	panel:loadRequiredResource("ui/star_bank_new.json")
	panel:init()
	return panel
end

function StarBankDescPanel:init( ... )
	self.ui = self:buildInterfaceGroup("StarBank/descPanel")
	BasePanel.init(self, self.ui)

	self.closeBtn = self.ui:getChildByName("close")
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function ()
		self:onCloseBtnTapped()
	end)
	self.closeBtn:setTouchEnabled(true)

    self.btn = GroupButtonBase:create(self.ui:getChildByName('btn'))
	self.btn:ad(DisplayEvents.kTouchTap, function ( ... )
		self:onCloseBtnTapped()
	end)
	self.btn:setString("知道了")

	local config = StarBank:getConfig()
	local wm = config.wm
	for index,number in ipairs(wm) do
		local coinnum = self.ui:getChildByName("star"..index)
		local num = TextField:createWithUIAdjustment(coinnum:getChildByName('ph'), coinnum:getChildByName('number'))
		num:setString(number)
    	coinnum:addChild(num)
    	coinnum:setAnchorPointWhileStayOriginalPosition(ccp(0, 0.5))

		local ph = self.ui:getChildByName("starph"..index)
		ph:setVisible(false)
		local size = ph:getGroupBounds().size
		local pos = ph:getPosition()
		local csize = num:getContentSize()
		coinnum:setPositionX(pos.x + size.width/2 - (csize.width+48) / 2)
	end

	local function SetString(descIndex, key, p, y)
		local desc = self.ui:getChildByName("desc"..descIndex)
		local v = 0
		for i=1,2 do
			local k = key.."_"..i
			local txt = localize(k, p)
			local t = desc:getChildByName("txt"..i)
			local ph = desc:getChildByName("ph"..i)
			ph:setVisible(false)
			-- local txtp = TextField:createWithUIAdjustment(ph, t)
			-- desc:addChild(txtp)

			if txt ~= k then
				t:setString(txt)
				t:setVisible(true)
				v = v + 1
			else
				t:setVisible(false)
			end
		end
		desc:setPositionY(y)
		if v == 0 then
			desc:setVisible(false)
		end
		return v
	end

	local desc1 = self.ui:getChildByName("desc1")
	local yoffset = desc1:getPositionY()
	local para = {
		[3] = {num1 = config.min, num2 = config.max},
		[4] = {num = math.ceil(config.buyTimeOut/3600/24)},
	}
	for index=1,5 do
		local v = SetString(index,"star.bank.detail"..index, para[index], yoffset)
		yoffset = yoffset - v * 43 - 10
	end

	local bgsize = self.ui:getGroupBounds().size
	local btnsize = self.btn:getGroupBounds().size
	self.btn:setPositionY(yoffset - (yoffset + bgsize.height)/2 + btnsize.height / 2 )
end

function StarBankDescPanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self, true)
end

function StarBankDescPanel:popout()
	self.allowBackKeyTap = true
    PopoutManager:sharedInstance():add(self, true, false)

    local winSize = CCDirector:sharedDirector():getVisibleSize()

	local w = 720
	local h = 1280

	local r = winSize.height / h
	if r < 1.0 then
		self:setScale(r)
	end

	local x = self:getHCenterInParentX()
	local y = self:getVCenterInParentY()
	self:setPosition(ccp(x, y))

	local container = self:getParent()
	if container then
		container = container:getParent()
	end
	if container and container.darkLayer then
		container.darkLayer:setOpacity(200)
	end
end