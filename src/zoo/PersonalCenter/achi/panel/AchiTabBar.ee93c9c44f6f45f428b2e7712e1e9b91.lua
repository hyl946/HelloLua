local AchiTabBar = class()
function AchiTabBar:create(tabbar, tabTxts, colorConfig)
	local render = AchiTabBar.new()
    render:init(tabbar, tabTxts, colorConfig)
    return render
end

function AchiTabBar:init(tabbar, tabTxts, colorConfig)
    self.tabbar = tabbar
    self.animDuration = 0.12
    self.colorConfig = colorConfig

    self.arrow = self.tabbar:getChildByName('arrow')
    for i = 1, 3 do
        self['tab'..i] = self.tabbar:getChildByName('tab'..i)
        self['tab'..i].txt = self['tab'..i]:getChildByName('txt')
        self['tab'..i].dot = self['tab'..i]:getChildByName('dot')
        self['tab'..i].dot:setVisible(false)

        if #tabTxts >= i then
            local v = tabTxts[i]
            self['tab'..i].txt:changeFntFile('fnt/register2.fnt')
            self['tab'..i].txt:setColor(self.colorConfig.normal)
            self['tab'..i].txt:setScale(0.88)
            self['tab'..i].txt:setText(v)
            self['tab'..i].normalPos = ccp(self['tab'..i].txt:getPositionX(), self['tab'..i].txt:getPositionY())
            self['tab'..i].focusPos = ccp(self['tab'..i].txt:getPositionX() , self['tab'..i].txt:getPositionY() + 5)
            self['tab'..i]:setTouchEnabled(true, 0, true)
            self['tab'..i]:setButtonMode(true)
            self['tab'..i]:addEventListener(DisplayEvents.kTouchTap, function() 
                printx(5, 'click tab index = ', i) 
                self:onTabClicked(i)
            end)
        end
    end
end

function AchiTabBar:setView(view)
	self.view = view
end

function AchiTabBar:setNews(news)
    self.news = news
    for i = 1, #news do
        self['tab'..i].dot:setVisible(news[i])
    end
end

function AchiTabBar:goto(index)
    if not index or type(index) ~= 'number' or index > 3 or index < 1 then
        return 
    end

    if self.tabIndex then
    	local curTab = self['tab'..self.tabIndex]
    	if curTab then
	    	curTab.txt:stopAllActions()
	        curTab.txt:runAction(self:_getTabLooseFocusAnim(curTab))
            if self.news then curTab.dot:setVisible(self.news[self.tabIndex]) end
	    end
    end
    local nextTab = self['tab'..index]
    if nextTab then 
        -- local pos = nextTab:getParent():convertToWorldSpace(nextTab:getPosition())
        -- local wPos = self.layout:convertToNodeSpace(pos)
        -- self.scrollable:scrollOffsetToCenter(wPos.x)
        nextTab.txt:stopAllActions()
        nextTab.txt:runAction(self:_getTabOnFocusAnim(nextTab))
        nextTab.dot:setVisible(false)
        if self.news then 
            self.news[index] = false 
            local newAchis = AchiUIManager:getNewAchis()
            for i = #newAchis, 1, -1 do
                local achi = Achievement:getAchi(newAchis[i])
                if achi.category == index then
                    AchiUIManager:removeNewAchi(newAchis[i])
                end
            end
        end
    end
    if self.arrow then
        self.arrow:stopAllActions()
        self.arrow:runAction(self:_getArrowAnim(index))
    end

    self.tabIndex = index
end

function AchiTabBar:onTabClicked(index)
    self:goto(index)
    if self.view then self.view:gotoPage(index) end
end

function AchiTabBar:_getArrowAnim(index)
    local tab = self['tab'..index]
    if tab then 
        local pos = tab:getPosition()
        local worldPos = tab:getParent():convertToWorldSpace(ccp(pos.x + 56, pos.y - 35))
        local realPos = self.arrow:getParent():convertToNodeSpace(ccp(worldPos.x, worldPos.y))
        local move = CCMoveTo:create(self.animDuration, ccp(realPos.x, realPos.y))
        local ease = CCEaseSineOut:create(move)
        return ease
    end
    return nil
end

function AchiTabBar:_getTabOnFocusAnim(tab)
    if not tab then return nil end
    local tint = CCTintTo:create(self.animDuration, self.colorConfig.focus.r, self.colorConfig.focus.g, self.colorConfig.focus.b)
    local scale = CCScaleTo:create(self.animDuration, 34/28*0.88)
    local move = CCMoveTo:create(self.animDuration, tab.focusPos)
    local array = CCArray:create()
    array:addObject(tint)
    array:addObject(scale)
    array:addObject(move)
    local spawn = CCEaseSineOut:create(CCSpawn:create(array))
    return spawn
end

function AchiTabBar:_getTabLooseFocusAnim(tab)
    if not tab then return nil end
    local tint = CCTintTo:create(self.animDuration, self.colorConfig.normal.r, self.colorConfig.normal.g, self.colorConfig.normal.b)
    local scale = CCScaleTo:create(self.animDuration, 0.88)
    local move = CCMoveTo:create(self.animDuration, tab.normalPos)
    local array = CCArray:create()
    array:addObject(tint)
    array:addObject(scale)
    array:addObject(move)
    local spawn = CCEaseSineOut:create(CCSpawn:create(array))
    return spawn
end

return AchiTabBar