


local iconBtns = {}
local anchors = {}
local alwaysHideBtns = {}
local iconBtnState = {}
local finishedBtns = {}
IconButtonPool = class({})

IconButtonPool.sortFunc = function (v1, v2)
    return v1.showPriority > v2.showPriority
end

function IconButtonPool:dump()
    printx(3, '----------------IconButtonPool:dump------------')
    for k, v in pairs(iconBtns) do
        printx(3, v.indexKey, v.homeSceneRegion, v.showPriority)
    end
end

function IconButtonPool:add(iconInstance)
    for k, v in pairs(iconBtns) do
        if v.indexKey == iconInstance.indexKey then
            printx(3, '重复添加按钮', iconInstance.indexKey)
            printx(3, debug.traceback())
            --debug.debug()
            return
        end
    end
    iconBtns[iconInstance] = iconInstance
    anchors[iconInstance] = true 
    if not iconBtnState[iconInstance] then -- 没有设置state才给值
        if iconInstance.homeSceneRegion == IconBtnShowState.ALWAYS_HIDE then
            iconBtnState[iconInstance] = IconBtnShowState.HIDE_N_FOLD
        else
            iconBtnState[iconInstance] = IconBtnShowState.ON_HOMESCENE -- 先给默认值
        end
    end
end

function IconButtonPool:remove(iconInstance)
    if iconBtns[iconInstance] == nil then
        printx(3, 'remove 有bug', iconInstance.indexKey)
        printx(3, debug.traceback())
        -- debug.debug()
    end

    if iconBtns[iconInstance] then
        iconBtns[iconInstance] = nil
    end

    if anchors[iconInstance] then
        anchors[iconInstance] = nil
    end

    if alwaysHideBtns[iconInstance] then
        alwaysHideBtns[iconInstance] = nil
    end

    if iconBtnState[iconInstance] then
        iconBtnState[iconInstance] = nil
    end
end

function IconButtonPool:getBtnByKey(key)
    for k, v in pairs(iconBtns) do
        if v.indexKey == key then
            return v
        end
    end
    return nil
end

function IconButtonPool:setBtnState(iconInstance, state)
    iconBtnState[iconInstance] = state
end

function IconButtonPool:getBtnState(iconInstance)
    if iconInstance and iconBtnState[iconInstance] then
        return iconBtnState[iconInstance]
    else
        printx(3, 'getBtnState 有问题', iconInstance.indexKey)
        printx(3, debug.traceback())
        -- debug.debug()
        return IconBtnShowState.NOT_EXIST
    end
end

function IconButtonPool:onBtnFinishJob(btn)
    finishedBtns[btn] = true
end

function IconButtonPool:isBtnFinishedJob(btn)
    return finishedBtns[btn] == true
end

-- 这里的alwaysHide表示的是按钮结束了功能  
-- 再也不出来了
function IconButtonPool:addAlwaysHideBtn(iconInstance)
    alwaysHideBtns[iconInstance] = iconInstance
end

function IconButtonPool:removeAlwaysHideBtn(iconInstance)
    alwaysHideBtns[iconInstance] = nil
end

function IconButtonPool:isAlwaysHideBtn(iconInstance)
    return alwaysHideBtns[iconInstance] ~= nil
end

function IconButtonPool:getBtnAnchor(iconInstance)
    return anchors[iconInstance]
end

local function sort(btns)
    table.sort(btns, IconButtonPool.sortFunc)
end

function IconButtonPool:getHomeSceneBtnsBySide(side)
    local ret = {}
    for k, v in pairs(iconBtns) do
        if v.homeSceneRegion == side and iconBtnState[v] == IconBtnShowState.ON_HOMESCENE then
            table.insert(ret, v)
        end
    end
    return ret
end

function IconButtonPool:getBtns(side)
    local homeSceneBtn = {}
    local hideBtns = {}
    for k, v in pairs(iconBtns) do
        if v.homeSceneRegion == side then
            if not v.showPriority then
                printx(3, 'btn没有showPriority', v.indexKey)
                printx(3, debug.traceback())
                debug.debug()
                v.showPriority = 0 -- 还是给个默认值吧
            end
            if IconButtonPool:isAlwaysHideBtn(v) then
                table.insert(hideBtns, v)
            else
                table.insert(homeSceneBtn, v)
            end
        end
    end

    -- 在大藤蔓上的排在前面啊
    sort(homeSceneBtn)
    sort(hideBtns)
    local ret = {}
    for k, v in pairs(homeSceneBtn) do
        table.insert(ret, v)
    end
    for k, v in pairs(hideBtns) do
        table.insert(ret, v)
    end
    return ret
end

function IconButtonPool:getInsertionIndex(priority, side)
    local btns = self:getBtns(side)
    for i, v in ipairs(btns) do
        if priority>v.showPriority then
            return i
        end
    end
    return #btns + 1
end
