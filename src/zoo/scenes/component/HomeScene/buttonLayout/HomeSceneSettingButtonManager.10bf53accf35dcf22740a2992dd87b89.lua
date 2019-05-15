
local LeftPositionConfig = {
    [1] = {
        [1] = {c = 1, r = 2},
    },
    [2] = {
        [2] = {c = 1, r = 3},
        [1] = {c = 1, r = 2}, 
    },
    [3] = {
        [3] = {c = 1, r = 4},
        [2] = {c = 1, r = 3},
        [1] = {c = 1, r = 2},  
    },
    [4] = {
        [2] = {c = 1, r = 3}, [4] = {c = 2, r = 3}, 
        [1] = {c = 1, r = 2}, [3] = {c = 2, r = 2},
    },
    [5] = {
        [5] = {c = 1, r = 4},
        [2] = {c = 1, r = 3}, [4] = {c = 2, r = 3}, 
        [1] = {c = 1, r = 2}, [3] = {c = 2, r = 2},
                              
    },
    [6] = {
        [5] = {c = 1, r = 4}, [6] = {c = 2, r = 4},
        [2] = {c = 1, r = 3}, [4] = {c = 2, r = 3}, 
        [1] = {c = 1, r = 2}, [3] = {c = 2, r = 2},
    },
    [7] = {
        [7] = {c = 1, r = 5},
        [5] = {c = 1, r = 4}, [6] = {c = 2, r = 4},
        [2] = {c = 1, r = 3}, [4] = {c = 2, r = 3}, 
        [1] = {c = 1, r = 2}, [3] = {c = 2, r = 2},                     
    },
    [8] = {
        [7] = {c = 1, r = 5}, [8] = {c = 2, r = 5},
        [5] = {c = 1, r = 4}, [6] = {c = 2, r = 4},
        [2] = {c = 1, r = 3}, [4] = {c = 2, r = 3}, 
        [1] = {c = 1, r = 2}, [3] = {c = 2, r = 2},   
    },
}

local function getPositionByRowColumnIndex(r, c)
    local rowMargin = 5
    local rowHeight = 110
    local colMargin = 7
    local colWidth = 110
    local ox = 26
    local oy = -120
    return ccp((colMargin * (c - 1) + (c - 1) * colWidth), (rowMargin * r + (r - 1) * rowHeight))
end

HomeSceneSettingButtonManager = class()
HomeSceneSettingButtonType = table.const{
    kNull = 0,
    kSettingBtn = 1,
    kFcBtn = 3,
    kForumBtn = 4,
    kNewFaqBtn = 5,
    kBagBtn = 7,
    kAccountBtn = 8,
}

local instance = nil
function HomeSceneSettingButtonManager.getInstance()
    if not instance then
        instance = HomeSceneSettingButtonManager.new()
        instance:init()
    end
    return instance
end

function HomeSceneSettingButtonManager:init()
    self.btnGroupBar = nil
    self.allBtnTypeTable = {}
    self.finalBtnTypeTable = {}
    self.widthDelta = 118
    self.heightDelta = 134
    self.xOriPos = -75
    self.yOriPos = 70
    self.bgSizeWidth = 180
    self.bgSizeHeight = 134

    -------------------test----------------------
    -- self:setButtonShowPosState(HomeSceneSettingButtonType.kFcBtn, true)
    -- self:setButtonShowPosState(HomeSceneSettingButtonType.kAccountBtn, true)
    -- self:setButtonShowPosState(HomeSceneSettingButtonType.kSettingBtn, true)
    -- self:setButtonShowPosState(HomeSceneSettingButtonType.kForumBtn, true)
    -- self:setButtonShowPosState(HomeSceneSettingButtonType.kStarReward, true)
    -- self:setButtonShowPosState(HomeSceneSettingButtonType.kMark, true)
    -- UserManager:getInstance().requestNum = 10
    ---------------------------------------------
    
end

function HomeSceneSettingButtonManager:getButtonCount()
    return #self.allBtnTypeTable
end

function HomeSceneSettingButtonManager:getBtnTypeInfoTable()
    return self.finalBtnTypeTable
end

function HomeSceneSettingButtonManager:getBarBgSize()
    return self.bgSizeWidth, self.bgSizeHeight  
end

local function sortFunc(a, b)
    return a < b
end

function HomeSceneSettingButtonManager:serializeBtnTypeTable()
    table.sort(self.allBtnTypeTable, sortFunc)
    self.finalBtnTypeTable = {}
    local count = #self.allBtnTypeTable 
    local config = LeftPositionConfig[count]
    for k, v in pairs(config) do
        if self.finalBtnTypeTable[v.r] == nil then
            self.finalBtnTypeTable[v.r] = {}
        end
    end

    for i, v in ipairs(self.allBtnTypeTable) do
        local btnConfig = {}
        btnConfig.btnType = v
        local posConfig = getPositionByRowColumnIndex(config[i].r, config[i].c)
        btnConfig.posX, btnConfig.posY = posConfig.x, posConfig.y
        table.insert(self.finalBtnTypeTable[config[i].r], btnConfig)
    end
end

function HomeSceneSettingButtonManager:setButtonShowPosState(buttonType, showInBar)
    if not buttonType then return end

    local shouldUpdateLayout = false
    if showInBar then 
        if not table.includes(self.allBtnTypeTable, buttonType) then 
            table.insert(self.allBtnTypeTable, buttonType)
            shouldUpdateLayout = true
        end
    else
        local tempTable = {}
        for i,v in ipairs(self.allBtnTypeTable) do
            if v == buttonType then 
                shouldUpdateLayout = true
            else
                table.insert(tempTable, v)
            end
        end
        self.allBtnTypeTable = tempTable
    end
    if shouldUpdateLayout then 
        self:serializeBtnTypeTable()
    end
end

function HomeSceneSettingButtonManager:addLayerColorWrapper(ui,anchorPoint)
    local size = ui:getGroupBounds().size
    local pos = ui:getPosition()
    local layer = LayerColor:create()
    layer:setColor(ccc3(255,0,0))
    layer:setOpacity(200)
    layer:setContentSize(CCSizeMake(size.width, size.height))
    layer:ignoreAnchorPointForPosition(false)
    layer:setAnchorPoint(anchorPoint)
    layer:setPosition(ccp(pos.x, pos.y-size.height))
    
    local uiParent = ui:getParent()
    local index = uiParent:getChildIndex(ui)
    ui:removeFromParentAndCleanup(false)
    ui:setPosition(ccp(0,size.height))
    layer:addChild(ui)
    uiParent:addChildAt(layer, index)

    return layer
end

function HomeSceneSettingButtonManager:setBtnGroupBar(btnGroupBar)
    self.btnGroupBar = btnGroupBar
end

function HomeSceneSettingButtonManager:getBtnGroupBar()
    return self.btnGroupBar
end

