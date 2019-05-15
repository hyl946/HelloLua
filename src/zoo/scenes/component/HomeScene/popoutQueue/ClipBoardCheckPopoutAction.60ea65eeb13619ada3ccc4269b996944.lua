
ClipBoardCheckPopoutAction = class(HomeScenePopoutAction)

local ClipBoardUtilType = {
    kFriend = 1,
    OpenWeekMainPanel = 2,
}

local Prioritys = {
    ClipBoardUtilType.kFriend,
    ClipBoardUtilType.OpenWeekMainPanel,
}

local package = "zoo.scenes.component.HomeScene.popoutQueue.clipBoardUtilType."

local ClipBoardUtilCls = {
    [ClipBoardUtilType.kFriend] = require(package .. "AddFriend"),
    [ClipBoardUtilType.OpenWeekMainPanel] = require(package .. "OpenWeekMainPanel"),
}

function ClipBoardCheckPopoutAction:ctor()
    self.ignorePopCount = true
    self.name = "ClipBoardCheckPopoutAction"
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function ClipBoardCheckPopoutAction:checkCanPop()
    local canPop = false

    local types = table.values(ClipBoardUtilType)
    table.sort(types, function ( a, b )
        local pa = table.indexOf(Prioritys, a) or 0x7FFFFFFF
        local pb = table.indexOf(Prioritys, b) or 0x7FFFFFFF
        return pa < pb
    end)


    self.pasteStr = ClipBoardUtil.getRawText() or ''

    local checkType
    checkType =  function( _index )
        local _type = types[_index]

        if _type then
            local cls = ClipBoardUtilCls[_type]
            cls.canPop(self.pasteStr, function ( canPopNode )
                if canPopNode then
                    self.checkType = _type
                    self:onCheckPopResult(true)
                    ClipBoardUtil.copyText('')
                else
                    checkType(_index + 1)
                end
            end)
        else
            self:onCheckPopResult(false)
        end
    end


    checkType(1)


    
    

    if _G.isLocalDevelopMode then printx(100, " ClipBoardCheckPopoutAction:checkCanPop() canPop = " , canPop  ) end
    -- self:onCheckPopResult( canPop )
end

function ClipBoardCheckPopoutAction:popout( next_Action )

    local function closeCallBack( ... )
        if next_Action then
            next_Action()
        end
    end 

    if ClipBoardUtilCls[self.checkType or -1] then
        ClipBoardUtilCls[self.checkType or -1].popout(self.pasteStr, closeCallBack)
    else
        closeCallBack()
    end
end