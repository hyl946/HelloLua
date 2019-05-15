
local UIHelper = require 'zoo.panel.UIHelper'

local TestPhotoPanel = class(BasePanel)

function TestPhotoPanel:create()
    local panel = TestPhotoPanel.new()
    panel:init()
    return panel
end

local function buildBtn( callback, w, h, text )
	local btn = LayerColor:createWithColor(ccc3(255,0,0), w, h)
    btn:setTouchEnabled(true)
    btn:ad(DisplayEvents.kTouchTap, function ( ... )
    	if callback then callback() end
    end)
    btn:ignoreAnchorPointForPosition(false)
    btn:setAnchorPoint(ccp(0, 1))

    local text = TextField:create(text or "", nil, 24)
    text:setAnchorPoint(ccp(0.5, 0.5))
    btn:addChild(text)
    text:setPosition(ccp(w/2, h/2))
    local size = text:getContentSize()
    local scale = math.min(h/size.height, w/size.width)
    text:setScale(scale)
    return btn
end

function TestPhotoPanel:init()
    local ui = LayerColor:createWithColor(ccc3(128,128,128), 600, 800)
    ui:ignoreAnchorPointForPosition(false)
    ui:setAnchorPoint(ccp(0, 1))
	BasePanel.init(self, ui)

    local closeBtn = buildBtn(function ( ... )
    	self:onCloseBtnTapped()
    end, 64, 64, 'close')
    ui:addChild(closeBtn)
    closeBtn:setPosition(ccp(600 - 64, 800))


    local function apply( pathname )
    	if self.isDisposed then return end

    	-- CommonTip:showTip('pathname' .. pathname)
    	if ui.sp then
			ui.sp:removeFromParentAndCleanup(true)
		end

		local sp = Sprite:create(pathname)
		sp:setAnchorPoint(ccp(0.5, 0.5))

		local size = sp:getContentSize()
		local scale = math.min(800/size.height, 600/size.width)
		sp:setScale(scale)

		ui:addChild(sp)
		sp:setPosition(ccp(300, 400))

		ui.sp = sp

    end

    local takeBtn = buildBtn(function ( ... )
    	

		local PhotoPicker = require 'zoo.photoPicker.PhotoPicker'
		PhotoPicker:create():takePhoto(200, 100, function ( pathname )
			if self.isDisposed then return end
			apply(pathname)
		end)


    end, 128, 64, "take")

    ui:addChild(takeBtn)
    takeBtn:setPosition(ccp(0, 64))

    local selectBtn = buildBtn(function ( ... )
    	-- body

    	local PhotoPicker = require 'zoo.photoPicker.PhotoPicker'
		PhotoPicker:create():selectPhoto(200, 100, function ( pathname )
			if self.isDisposed then return end
			apply(pathname)
		end)

    end, 128, 64, "select")

    ui:addChild(selectBtn)
    selectBtn:setPosition(ccp(600 - 128, 64))

    



end

function TestPhotoPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function TestPhotoPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function TestPhotoPanel:onCloseBtnTapped( ... )
    self:_close()
end

return TestPhotoPanel
