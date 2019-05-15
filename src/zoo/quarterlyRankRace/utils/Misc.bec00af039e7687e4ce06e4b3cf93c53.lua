local Misc = {}

function Misc:headIconLoader(headIcon, profile, callback)
	if not profile then
		profile = UserManager:getInstance().profile
	end

    local headHolder = headIcon:getChildByName('holder')
	local headHolderSize = headHolder:getContentSize()
	headHolder:setAnchorPointCenterWhileStayOrigianlPosition()

    local head = headHolder:getChildByName("head")
	if head then
		head:removeFromParentAndCleanup(true)
	end

    local function onLoaded( head )
        if headHolder.isDisposed then
            head:dispose()
            return
        end
        if head.isDisposed then
            return
        end
        head.name = "head"
        head:setPositionX(headHolder:getContentSize().height/2)
        head:setPositionY(headHolder:getContentSize().width/2)
        head:setScaleX(headHolder:getContentSize().width/100)
        head:setScaleY(headHolder:getContentSize().height/100)
        headHolder:addChild(head)
        if callback then
            callback()
        end
    end

	onLoaded(HeadImageLoader:createWithFrame(profile.uid, profile.headUrl))
end

function Misc:playNotifyAnim(icon)
	if (not icon) or icon.isDisposed then return end
	icon:stopAllActions()
	local secondPerFrame	= 1 / 60
	local function initActionFunc()
		icon:setScale(1)
	end
	local initAction = CCCallFunc:create(initActionFunc)
	local scale1	= CCScaleTo:create(secondPerFrame * (13 - 1), 1.076,	0.875)
	local scale2	= CCScaleTo:create(secondPerFrame * (25 - 13),  0.911, 1.12)
	local scale3	= CCScaleTo:create(secondPerFrame * (36 - 25),  0.981, 1.024)
	local scale4	= CCScaleTo:create(secondPerFrame * (50 - 36),  1, 1)
	local actionArray = CCArray:create()
	actionArray:addObject(scale1)
	actionArray:addObject(scale2)
	actionArray:addObject(scale3)
	actionArray:addObject(scale4)
	local seq 	= CCSequence:create(actionArray)
	icon:runAction(CCRepeatForever:create(seq))
end


function Misc:stopNotifyAnim(icon)
	if (not icon) or icon.isDisposed then return end
	icon:stopAllActions()
	icon:setScale(1)
end

function Misc:buildURL( host, path, params )
    local p = {}
    for key, value in pairs(params) do
        table.insert(p, string.format("%s=%s", key, value))
    end
    p = table.concat(p, '&')
    return host .. path .. '?' .. p
end

function Misc:isSupportShare( ... )

    if Misc:isLowDevice() then
        return false
    end
	local fuck_platforms = {
		-- PlatformNameEnum.kJJ,
        PlatformNameEnum.kMiTalk,
		-- PlatformNameEnum.kOppo,
	}

	for _, platform in ipairs(fuck_platforms) do
		if PlatformConfig:isPlatform(platform) then
			return false
		end
	end
	return true
end

function Misc:isLowDevice( ... )
	local function isIOSLowDevice()
        local result = false
        pcall(function ( ... )
            local frame = CCDirector:sharedDirector():getOpenGLView():getFrameSize()
            local deviceType = MetaInfo:getInstance():getMachineType() or ""
            local physicalMemory = NSProcessInfo:processInfo():physicalMemory() or 0
            local freeMemory = AppController:getFreeMemory()
            local totalMemory = AppController:getTotalMemory()
            physicalMemory = physicalMemory / (1024 * 1024)
            if physicalMemory < 600 or frame.width < 400 then result = true end
        end)
        return result
    end
    local function isAndroidLowDevice()
        local result = false
        pcall(function ( ... )
            local physicalMemory = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil"):getSysMemory()
            local frame = CCDirector:sharedDirector():getOpenGLView():getFrameSize()
            physicalMemory = physicalMemory / (1024 * 1024)
            if physicalMemory < 600 or frame.width < 400 then result = true end
            if physicalMemory < 0 then result = false end
        end)
        return result
    end
    local function isLowDevice()
        if __IOS then
            return isIOSLowDevice()
        elseif __ANDROID then
            return isAndroidLowDevice()
        end  
        return false
    end
    return isLowDevice()
end



function Misc:getItemSprite(itemId)
    local ret = nil
    pcall(function ( ... )
        if ItemType:isTimeProp(itemId) then
            itemId = ItemType:getRealIdByTimePropId(itemId)
        end
        ret = ResourceManager:sharedInstance():buildItemSprite(itemId)
    end)

    if not ret then
        ret = Sprite:createEmpty()
        local layer = LayerColor:createWithColor(ccc3(255, 0, 0), 50, 50)
        ret:addChild(layer)
        ret:addChild(TextField:create('没有素材shit', nil, 48))
    end
    return ret
end

-- itemId:num:p


function Misc:__parse(str, delimts)
    local delimt = string.sub(delimts, 1, 1)
    local ret = {}
    if table.exist({'+', '*', '%', '.'}, delimt) then
        delimt = '%' .. delimt
    end
    for v in string.gmatch(str, string.format('([^%s]+)', delimt)) do

        if #delimts > 1 then
            v = self:parse(v, string.sub(delimts, 2))
        end

        table.insert(ret, v)
    end
    return ret
end

function Misc:parse(str, delimts)

    local ret = self:__parse(str, string.sub(delimts, 1))
    return ret
end



local AsyncFuncRunner = class()

function AsyncFuncRunner:create( ... )
    return AsyncFuncRunner.new()
end

function AsyncFuncRunner:ctor( ... )
    self.func_list = {}
    self.next_func_index = 1
end

function AsyncFuncRunner:add( func )
    table.insert(self.func_list, func)
    return self
end

function AsyncFuncRunner:run()
    if self.func_list[self.next_func_index] then
        self.func_list[self.next_func_index](function ( ... )
            self.next_func_index = self.next_func_index + 1
            return self:run()
        end)
    end
    return
end


Misc.AsyncFuncRunner = AsyncFuncRunner

function Misc:table_walk( tbl, func)
    for k, v in ipairs(tbl) do
        if func(v, k) then
            return
        end
    end
end

local function reverse_ipair( tbl )
    local i = #tbl + 1
    return function ( ... )
        i = i - 1
        if i <= 0 then
            return nil, nil
        end
        return i, tbl[i]
    end
end

function Misc:table_reverse_walk( tbl, func)
    for k, v in reverse_ipair(tbl) do
        if func(v, k) then
            return
        end
    end
end

function Misc:showTip( key )
    if localize(key .. '.p') ~= key .. '.p' then
        CommonTip:showTip(localize(key .. '.p'), 'positive')
    elseif localize(key .. '.n') ~= key .. '.n' then
        CommonTip:showTip(localize(key .. '.n'), 'negative')
    else
        CommonTip:showTip(localize(key))
    end
end

function Misc:day2Date( dayIndex )
    local ts = dayIndex * 3600 * 24 - 8 * 3600
    local date = os.date('*t', ts)
    return date
end

local function splitNum( num )
    -- body
    local digits = {}

    local bFlag = true

    while num > 0 or bFlag do
        table.insert(digits, 1, num % 10)
        num = math.floor(num / 10)
        bFlag = false
    end

    return digits

end



function Misc:createNumAnim(fnt, startNum, endNum)
    local layer = Layer:create()

    layer.digitNodes = {}

    local digits = {}

    local num = math.max(startNum, endNum)

    digits = splitNum(num)

    local bmp = BitmapText:create(tostring(7), fnt)
    local size = bmp:getContentSize()
    local width = size.width
    local height = size.height
    bmp:dispose()

    local clipSize = CCSizeMake(width * #digits, height)
    local clippingNode = SimpleClippingNode:create()
    clippingNode:setContentSize(CCSizeMake(clipSize.width + 16, clipSize.height))



    local nb10 = #digits

    for i = 1, nb10 do
        local subLayer = Layer:create()

        local kkk = 0

        local bmp = BitmapText:create('', fnt)
        subLayer:addChild(bmp)
        bmp:setPositionY(kkk * height + 1)
        kkk = kkk + 1

        for j = 0, 9 do
            local bmp = BitmapText:create(tostring(j), fnt)
            bmp:setAnchorPoint(ccp(0, 0))
            subLayer:addChild(bmp)
            bmp:setPositionY(kkk * height + 1)
            kkk = kkk + 1
            bmp:setPositionX( (width - bmp:getContentSize().width)/2 )
        end

        for j = 0, 9 do
            local bmp = BitmapText:create(tostring(j), fnt)
            bmp:setAnchorPoint(ccp(0, 0))
            subLayer:addChild(bmp)
            bmp:setPositionY(kkk * height + 1)
            kkk = kkk + 1
            bmp:setPositionX( (width - bmp:getContentSize().width)/2 )
        end

        function subLayer:setValue(value, curV, delay)
            if self.isDisposed then return end

            local v = 0

            if value ~= '' then
                v = value + 1
                if curV then
                    if v < curV then
                        v = v + 10
                    end
                end
            end

            if curV then
                self:runAction(CCSequence:createWithTwoActions(
                    CCDelayTime:create(delay or 0),
                    CCMoveTo:create(0.4, ccp(self:getPositionX(), v * ( -height)))
                ))
            else
                self:setPositionY(v * ( -height))
            end

            self.curV = v

        end

        function subLayer:scrollToValue(value, delay)
            if self.isDisposed then return end
            self:setValue(value, self.curV, delay)
        end

        subLayer:setPositionX((i - 1) * width)
        layer:addChild(subLayer)

        layer.digitNodes[i] = subLayer
    end

    function layer:setNum( value )
        if self.isDisposed then return end

        local index = #splitNum(value)
        local num = value
        local bFlag = true
        while num > 0 or bFlag do
            self.digitNodes[index]:setValue(num % 10)
            num = math.floor(num / 10)
            index = index - 1            
            bFlag = false
        end

        local index = #digits
        while index > #digits - #splitNum(value) do
            self.digitNodes[index]:setValue('')
            index = index - 1            
        end

    end

    function layer:scrollToValue( value )
        if self.isDisposed then return end
        local index = #digits
        local num = value
        local bFlag = true

        local delay = (#splitNum(value)) * 0.3
        while num > 0 or bFlag do
            self.digitNodes[index]:scrollToValue(num % 10, delay)
            delay = delay - 0.3
            num = math.floor(num / 10)
            index = index - 1            
            bFlag = false
        end
        while index > 1 do
            self.digitNodes[index]:setValue('')
            index = index - 1            
        end
    end

    layer:setNum(startNum)

    -- return layer
    clippingNode:addChild(layer)
    clippingNode.animNode = layer

    function clippingNode:play( ... )
        if self.isDisposed then return end
        self.animNode:scrollToValue(endNum)
    end

    return clippingNode
end


function Misc:createNum(fnt, num)

    local layer = Layer:create()

    layer.digitNodes = {}

    local digits = {}

    digits = splitNum(num)

    local bmp = BitmapText:create(tostring(7), fnt)
    local size = bmp:getContentSize()
    local width = size.width
    local height = size.height
    bmp:dispose()

    local nb10 = #digits

    for i = 1, nb10 do
        local subLayer = Layer:create()
        local bmp = BitmapText:create(tostring(digits[i]), fnt)
        bmp:setAnchorPoint(ccp(0, 0))
        subLayer:addChild(bmp)
        bmp:setPositionY(1)
        bmp:setPositionX((width - bmp:getContentSize().width)/2 )
        bmp:setPositionX((i - 1) * width)
        layer:addChild(subLayer)
    end

    return layer
end

function Misc:clampRewardsNum( rewards )
    return table.map(function ( v )
        -- return {itemId = v.itemId, num = math.min(5, v.num)}
        return {itemId = v.itemId, num = v.num}
    end, rewards)
end


local function splitChars( text,maxCount,filterFunc )
    local charTab = {}
    local count = 0
    for uchar in string.gfind(text, "[%z\1-\127\194-\244][\128-\191]*") do
        if count >= maxCount then
            return charTab,count,true
        end
        if uchar ~= '\n' and uchar ~= '\r' then
            if not filterFunc or filterFunc(uchar) then 
                table.insert(charTab, uchar)
                count = count + 1
            end
        else
            table.insert(charTab, uchar)
        end
    end
    return charTab,count,false
end

local function truncat( str, max )
    local str = '' .. str .. ''
    if #str < 2 then
        str = ' ' .. str .. ' '
        max = max + 1
    end

    local str_table, _, truncated = splitChars(str, max)
    local ret = table.concat(str_table, '')
    if truncated then
        ret = ret .. '...'
    end
    return ret
end

function Misc:truncat( str, max )
    return truncat(str, max)
end

return Misc