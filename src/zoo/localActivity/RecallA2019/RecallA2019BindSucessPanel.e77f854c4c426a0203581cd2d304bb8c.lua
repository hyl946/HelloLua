local UIHelper = require 'zoo.panel.UIHelper'

local RecallA2019BindSucessPanel= class(BasePanel)

function RecallA2019BindSucessPanel:create(profile, closecb)
    local panel = RecallA2019BindSucessPanel.new()
    panel:init(profile, closecb)
    return panel
end

function RecallA2019BindSucessPanel:dispose( ... )
    BasePanel.dispose(self)
end

function RecallA2019BindSucessPanel:init(profile, closecb)
    self.ui = UIHelper:createUI('ui/RecallA2019/bindSucess.json', 'RecallA2019_bindSucess/panel')
    BasePanel.init(self, self.ui)
    self.closecb = closecb
    --裁剪
    local bg = self.ui:getChildByName("bg")
    local mask = bg:getChildByName("mask")
    local offseth = 2

    local maskSize = mask:getContentSize()
    local rect = {size = {width = maskSize.width, height = maskSize.height - offseth}}
    local clipping = ClippingNode:create(rect)
    mask:removeFromParentAndCleanup(false)
    clipping:setStencil(mask.refCocosObj)
    mask:dispose()

    local grain = bg:getChildByName("grain")
    grain:removeFromParentAndCleanup(false)
    clipping:addChild(grain)
    clipping:setAlphaThreshold(0.5)
    
    bg:addChildAt(clipping, 1)
    --

    local headBg = self.ui:getChildByName("head")
    local name = self.ui:getChildByName("name")
    local tip2 = self.ui:getChildByName("tip2")
    tip2:setVisible(false)
    local tip3 = self.ui:getChildByName("tip3")
    tip3:setVisible(false)

    --头像框
    profile = profile or UserManager.getInstance().profile
	if profile and profile.headUrl then
		local function onImageLoadFinishCallback(clipping)
			if self.isDisposed then return end
		end
		local head = HeadImageLoader:createWithFrame(profile.uid, profile.headUrl)
        head:setPosition(ccp(102/2,105/2))
        headBg:addChild(head)
		onImageLoadFinishCallback(head)
	end

    --name
    local UserName = profile.name or "消消乐玩家"
    name:setString(nameDecode(UserName))

    --btn
    local btn = GroupButtonBase:create(self.ui:getChildByPath('btn'))
    btn:ad(DisplayEvents.kTouchTap, function ( ... )
        -- body
        self:onCloseBtnTapped()
    end)
    btn:setString('确定')

--    self.closeBtn = self.ui:getChildByName('close')
--    self.closeBtn:setTouchEnabled(true, 0, true)
--    self.closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)

    local topLevel = UserManager.getInstance().user:getTopLevelId()
    local ver = tonumber(string.split(_G.bundleVersion, ".")[2])
    if ver <= 64 then
        tip2:setVisible(true)
    elseif topLevel < 30  then
        tip3:setVisible(true)
    else
        btn:setPositionY(btn:getPositionY()-20)
    end


    --刷新icon
    self:clearActInfo()
    HomeScene:sharedInstance():buildActivityButton()
end

function RecallA2019BindSucessPanel.clearActInfo( ... )
    local actInfos = UserManager:getInstance().actInfos or {}
    for k, v in pairs(actInfos) do
        if v.actId == 1034 then
            table.remove(actInfos,k)
            break
        end
    end
    return true   
end

function RecallA2019BindSucessPanel:_close()
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self)
    if self.closecb then
        self.closecb()
    end
end

function RecallA2019BindSucessPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    PopoutManager:sharedInstance():add(self, true)
    self.allowBackKeyTap = true
end

function RecallA2019BindSucessPanel:onCloseBtnTapped( ... )
    self:_close()
end

return RecallA2019BindSucessPanel