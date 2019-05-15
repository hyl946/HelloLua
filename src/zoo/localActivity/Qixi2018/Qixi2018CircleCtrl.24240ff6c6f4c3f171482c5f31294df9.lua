
local Qixi2018CircleCtrl = class()

--kTextAlignment = {kCCTextAlignmentLeft, kCCTextAlignmentCenter, kCCTextAlignmentRight}

function Qixi2018CircleCtrl:create( parent, pos, initShowNum, FntFile, Scale, TextAlignment, maxShowLength, fntWidth )
	local bar = Qixi2018CircleCtrl.new()
	bar:init( parent, pos, initShowNum, FntFile, Scale,TextAlignment, maxShowLength, fntWidth  )
	return bar
end

--maxShowLength 最大显示字的位数 3位最大只显示 999
function Qixi2018CircleCtrl:init( parent, pos, initShowNum, FntFile, Scale,TextAlignment, maxShowLength, fntWidth  )

    pos = pos or ccp(0,0)
    initShowNum = initShowNum or 0
    FntFile = FntFile or "fnt/tutorial_white.fnt"
    TextAlignment = TextAlignment or kCCTextAlignmentCenter

    if not parent then
        return
    end

    self.TextAlignment = TextAlignment --对齐方式
    self.parent = parent --父节点
    self.Scale = Scale --缩放
    self.maxShowLength = maxShowLength --最大显示位数
    self.FntFile = FntFile
    self.pos = pos
    self.fntWidth = fntWidth or 19 --1个字母宽度

    self.MaxShowNum = 0 --最大显示数

    --计算最大值
    self.MaxShowNum = self:getMaxShowNum( maxShowLength )

    if initShowNum >  self.MaxShowNum then
        initShowNum = self.MaxShowNum
    end

    self.CurShowNum = initShowNum
    self.OldNum = 0
    self.newShowNum = 0
    self.bNumberIsAnim = false --数字是否滚动中

    --
    local bgSprite = Sprite:createEmpty()
    bgSprite:setPosition( pos )
    parent:addChild( bgSprite )
    self.bgSprite = bgSprite

    local function update()
        self:UpdateNumber()
    end

    local array = CCArray:create()
    array:addObject( CCCallFunc:create( update ) )
    bgSprite:runAction( CCRepeatForever:create( CCSequence:create(array) ) )

    self.Label = {}
    for i=1, maxShowLength do
        local label = BitmapText:create( "" ,FntFile)
        label:setScale(Scale)
        label:setAnchorPoint(ccp(0.5, 0.5))
        bgSprite:addChildAt( label, 5 )
        self.Label[i] = label
    end

    self:UpdateMainFntPos()
end

function Qixi2018CircleCtrl:getNumList( num )
    --拆分数字
    local NumberList = {}

    local numstr = tostring(num)
	local numlen = string.len(numstr)
    for i = 1 , numlen do
		table.insert( NumberList , tonumber( string.sub(numstr, i, i) ) )
	end

    if #NumberList < self.maxShowLength then

        local length = self.maxShowLength - #NumberList

        for i=1, length do
            table.insert( NumberList , 1, 0 ) --根据最大位数 补齐000
        end
    end

    return NumberList
end

function Qixi2018CircleCtrl:getMaxShowNum( maxShowLength )
    --计算最大可显示数
    local maxnum = 1
    for i=1, maxShowLength do
        maxnum = maxnum * 10
    end
    maxnum = maxnum - 1

    return maxnum
end

function Qixi2018CircleCtrl:UpdateMainFntPos()

    self:UpdateFntPos( self.Label, self.CurShowNum )

    self.OldNum = self.CurShowNum
end

function Qixi2018CircleCtrl:setNumber( num, bAnim, bAniEndCallBack )

    local maxShuoNum = self:getMaxShowNum( self.maxShowLength  )
    if num > maxShuoNum then num = maxShuoNum end

    if bAnim then
        if self.CurShowNum == num then
             --直接更新数字
            self.CurShowNum = num - 10
            if self.CurShowNum <= 0 then
                self.CurShowNum = 1
            end
            self:UpdateFntPos( self.Label, self.CurShowNum )
        end

        self.newShowNum = num
        self.bAniEndCallBack = bAniEndCallBack
    else
        --直接更新数字
        self.CurShowNum = num
        self.newShowNum = num
        self:UpdateFntPos( self.Label, self.CurShowNum )
    end
end


--现在只支持123456这么走
function Qixi2018CircleCtrl:UpdateNumber()

    if self.CurShowNum == self.newShowNum then
        return
    end

    if self.bNumberIsAnim then
        return
    end

    self.bNumberIsAnim = true

    local DifferentNum = self.newShowNum - self.CurShowNum
    local Speed = math.floor( DifferentNum/10 )
    if Speed == 0 then
        Speed = 1
    end

    local nextNum = self.CurShowNum + Speed
    if nextNum > self.newShowNum then
        nextNum = self.newShowNum
    end

    local curShowList = self:getNumList( self.CurShowNum )
    local nextShowList = self:getNumList( nextNum )
    
    --新老对比 哪个不同需要滚动
    local noSameLength = 0

    --比较不同的位置
    local noSameList = {}

    for i,v in pairs(curShowList) do
        if v ~= nextShowList[i] then
            table.insert( noSameList, i )
        end
    end

    --创建滚动的数字
    local tempLabelList = {}
    for i=1, self.maxShowLength do
        local label = BitmapText:create( "" ,self.FntFile)
        label:setScale(self.Scale)
        label:setAnchorPoint(ccp(0.5, 0.5))
        self.bgSprite:addChildAt( label, 5 )
        tempLabelList[i] = label
    end

    --
    self:UpdateFntPos( tempLabelList, nextNum )

    --只显示不同的部分 并且位置下移
    for i,v in pairs(tempLabelList) do
        v:setVisible(false)
    end

    local ActionNum = 0
    local CompleteNum = 0
    local function testMoveEnd()
        CompleteNum = CompleteNum + 1

        if CompleteNum == ActionNum then

            for i,v in pairs(tempLabelList) do
                v:removeFromParentAndCleanup( true )
            end
            
            self.CurShowNum = nextNum
            self:UpdateMainFntPos()

            if self.bNumberIsAnim then
                self.bNumberIsAnim = false
            end

            if self.CurShowNum == self.newShowNum then --每次走1个数 都走完了调用回调
                if self.bAniEndCallBack then self.bAniEndCallBack() end
            end
        end
    end

    local function CheckIsInNoSameList( index )
        
        for i,v in pairs(noSameList) do
            if v == index then
                return true
            end
        end

        return false
    end

    local moveLength = 30
    for i,v in pairs(nextShowList) do
        local binNoSameList = CheckIsInNoSameList( i )
        if binNoSameList then
            tempLabelList[i]:setVisible(true)
            tempLabelList[i]:setPositionY( tempLabelList[i]:getPositionY()-moveLength )
--            tempLabelList[i]:setColor( ccc3(255,0,0) )

            --
            tempLabelList[i]:setOpacity( 0 )

            local array = CCArray:create()
            local array3 = CCArray:create()
            array3:addObject( CCMoveBy:create(0.1, ccp(0,moveLength))  )
            array3:addObject( CCFadeIn:create(0.1) )

            array:addObject( CCSpawn:create(array3))
            array:addObject( CCCallFunc:create( testMoveEnd ) )
            tempLabelList[i]:runAction( CCSequence:create(array) )
            ActionNum = ActionNum + 1

            --
            self.Label[i]:setOpacity( 255 )
            local array2 = CCArray:create()
            local array4 = CCArray:create()
            array4:addObject( CCMoveBy:create(0.1, ccp(0,moveLength))  )
            array4:addObject( CCFadeOut:create(0.1) )

	        array2:addObject( CCSpawn:create(array4) )
            array2:addObject( CCCallFunc:create( testMoveEnd ) )
            self.Label[i]:runAction( CCSequence:create(array2) )
            ActionNum = ActionNum + 1
        end
    end
end

function Qixi2018CircleCtrl:UpdateFntPos( LabelList, ShowNum )

    for i,v in pairs(LabelList) do
        v:setVisible(false)
    end

    --拆分数字
    local NumberList = self:getNumList( ShowNum )

    local AllLength = 0
    local FirseZeroLength = 0
    local bCurIsNotZero = false
    if #NumberList > 0 then
        for i,v in pairs(NumberList) do
            if not LabelList[i] then break end
            LabelList[i]:setText( ""..v )
            LabelList[i]:setOpacity( 255 )

            if v ~= 0 then
                bCurIsNotZero = true
            end

            if bCurIsNotZero then
                LabelList[i]:setVisible(true)
            else
                FirseZeroLength = FirseZeroLength + self.fntWidth
            end

            AllLength = AllLength + self.fntWidth
        end
        
        local frontPos = 0
        if self.TextAlignment == kCCTextAlignmentLeft then
            frontPos = 0 - FirseZeroLength
        elseif self.TextAlignment == kCCTextAlignmentCenter then
            frontPos = AllLength/2 *(-1) - FirseZeroLength/2
        elseif self.TextAlignment == kCCTextAlignmentRight then
            frontPos = AllLength *(-1)
        end

        for i,v in pairs(NumberList) do
            LabelList[i]:setPositionX( frontPos + self.fntWidth/2 )
            LabelList[i]:setPositionY( 0 )

            frontPos = LabelList[i]:getPositionX() + self.fntWidth/2
        end
    end
end

return Qixi2018CircleCtrl
