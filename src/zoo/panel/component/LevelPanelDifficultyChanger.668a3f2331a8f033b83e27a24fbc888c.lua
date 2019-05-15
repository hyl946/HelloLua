require "hecore.utils"
assert(LevelDiffcultFlag)
assert(HomeScenePanelSkinType)
assert(LvlFlagColor)


-- 根据关卡难度调整关卡面板上的颜色和显示
------ 用法：
-- LevelPanelDifficultyChanger:changeBgByDifficulty( %1, %2, %3 )
-- %1 为 需要修改的继承自BasePanel的面板
-- %2 为 LevelDiffcultFlag中的常量，关卡难度是普通、困难还是超难
-- %3 为 HomeScenePanelSkinType中的常量，面板是进入关卡、关卡成功还是关卡失败
------


--元素的显示与否
local elementVisibilityConfigs = 
{
    -- 对需要调整可见的项进行设置；kNormal/kDifficult/kExceedinglyDifficult每项都可留空表示不调整
    -- 范例：
    -- {
    --     name = "showWhenNormal",
    --     [LevelDiffcultFlag.kNormal] = true,
    --     [LevelDiffcultFlag.kDiffcult] = false,
    --     [LevelDiffcultFlag.kExceedinglyDifficult] = false,
    -- },
    -- 需要批量时使用from和to（两端包含）
    -- 范例：
    -- {
    --     name = "bg/图层 ",
    --     from = 1,
    --     to = 10,
    --     [LevelDiffcultFlag.kNormal] = true,
    --     [LevelDiffcultFlag.kDiffcult] = false,
    --     [LevelDiffcultFlag.kExceedinglyDifficult] = false,
    -- },
    -- 需要根据面板类型的不同而采用不同显示时，让难度键对应的值为关于面板类型的表格
    -- 范例：
    -- {
    --     name = "showWhenDiffcultSuccess",
    --     [LevelDiffcultFlag.kNormal] = false,
    --     [LevelDiffcultFlag.kDiffcult] = {
    --         [HomeScenePanelSkinType.kLevelInfoPanel] = false,
    --         [HomeScenePanelSkinType.kLevelSucTopPanel] = true,
    --         [HomeScenePanelSkinType.kLevelFailTopPanel] = false,
    --     },
    --     [LevelDiffcultFlag.kExceedinglyDifficult] = false,
    -- },
    -- 需要根据面板的数据采用不同显示时，可以不使用true或者false，而是一个参数为面板的函数
    -- 范例：
    -- {
    --     name = "showWhenDiffcultFirstTime",
    --     [LevelDiffcultFlag.kNormal] = false,
    --     [LevelDiffcultFlag.kDiffcult] = {
    --         [HomeScenePanelSkinType.kLevelInfoPanel] = false,
    --         [HomeScenePanelSkinType.kLevelSucTopPanel] = function (panel) return panel.isFirst end,
    --         [HomeScenePanelSkinType.kLevelFailTopPanel] = false,
    --     },
    --     [LevelDiffcultFlag.kExceedinglyDifficult] = false,
    -- },
    {
        name = "bg/title_green_bg1", --面板顶部带刺藤蔓
        [LevelDiffcultFlag.kNormal] = false,
        [LevelDiffcultFlag.kDiffcult] = {
            [HomeScenePanelSkinType.kLevelInfoPanel] = true,
            [HomeScenePanelSkinType.kLevelSucTopPanel] = true,
            [HomeScenePanelSkinType.kLevelFailTopPanel] = false,
        },
        [LevelDiffcultFlag.kExceedinglyDifficult] = {
            [HomeScenePanelSkinType.kLevelInfoPanel] = true,
            [HomeScenePanelSkinType.kLevelSucTopPanel] = true,
            [HomeScenePanelSkinType.kLevelFailTopPanel] = false,
        },
    },
    {
        name = "bg/title_green_bg_2_", --面板顶部向上伸出的藤尖
        from = 1,
        to = 2,
        [LevelDiffcultFlag.kNormal] = false,
        [LevelDiffcultFlag.kDiffcult] = {
            [HomeScenePanelSkinType.kLevelInfoPanel] = true,
            [HomeScenePanelSkinType.kLevelSucTopPanel] = false,
            [HomeScenePanelSkinType.kLevelFailTopPanel] = false,
        },
        [LevelDiffcultFlag.kExceedinglyDifficult] = {
            [HomeScenePanelSkinType.kLevelInfoPanel] = true,
            [HomeScenePanelSkinType.kLevelSucTopPanel] = false,
            [HomeScenePanelSkinType.kLevelFailTopPanel] = false,
        },
    },
    {
        name = "bg/title_green_gift", --困难关礼物
        [LevelDiffcultFlag.kNormal] = false,
        [LevelDiffcultFlag.kDiffcult] = {
            [HomeScenePanelSkinType.kLevelInfoPanel] = function (panel) return panel.isFirst end,
            [HomeScenePanelSkinType.kLevelSucTopPanel] = function (panel) return panel.isFirst end,
            [HomeScenePanelSkinType.kLevelFailTopPanel] = false,
        },
        [LevelDiffcultFlag.kExceedinglyDifficult] = false,
    },
    {
        name = "bg/title_pur_gift", --超难关礼物
        [LevelDiffcultFlag.kNormal] = false,
        [LevelDiffcultFlag.kDiffcult] = false,
        [LevelDiffcultFlag.kExceedinglyDifficult] = {
            [HomeScenePanelSkinType.kLevelInfoPanel] = function (panel) return panel.isFirst end,
            [HomeScenePanelSkinType.kLevelSucTopPanel] = function (panel) return panel.isFirst end,
            [HomeScenePanelSkinType.kLevelFailTopPanel] = false,
        },
    },
    {
        name = "bg/diffcultadd", --右上关闭按钮下的单片叶子
        [LevelDiffcultFlag.kNormal] = false,
        [LevelDiffcultFlag.kDiffcult] = true,
        [LevelDiffcultFlag.kExceedinglyDifficult] = true,
    },
    {
        name = "bg/top_leaves_", --上边框的点缀叶子
        from = 1,
        to = 2,
        [LevelDiffcultFlag.kNormal] = true,
        [LevelDiffcultFlag.kDiffcult] = {
            [HomeScenePanelSkinType.kLevelInfoPanel] = false,
            [HomeScenePanelSkinType.kLevelSucTopPanel] = false,
            [HomeScenePanelSkinType.kLevelFailTopPanel] = true,
        },
        [LevelDiffcultFlag.kExceedinglyDifficult] = {
            [HomeScenePanelSkinType.kLevelInfoPanel] = false,
            [HomeScenePanelSkinType.kLevelSucTopPanel] = false,
            [HomeScenePanelSkinType.kLevelFailTopPanel] = true,
        },
    },
    {
        name = "title_pur_bg2",  --超难关紫花
        [LevelDiffcultFlag.kNormal] = false,
        [LevelDiffcultFlag.kDiffcult] = false,
        [LevelDiffcultFlag.kExceedinglyDifficult] = {
            [HomeScenePanelSkinType.kLevelInfoPanel] = true,
            [HomeScenePanelSkinType.kLevelSucTopPanel] = true,
            [HomeScenePanelSkinType.kLevelFailTopPanel] = false,
        },
    },
    {
        name = "title_green_flower",  --"困难"字样背后的花
        [LevelDiffcultFlag.kNormal] = false,
        [LevelDiffcultFlag.kDiffcult] = {
            [HomeScenePanelSkinType.kLevelInfoPanel] = true,
            [HomeScenePanelSkinType.kLevelSucTopPanel] = true,
            [HomeScenePanelSkinType.kLevelFailTopPanel] = false,
        },
        [LevelDiffcultFlag.kExceedinglyDifficult] = false,
    },
    {
        name = "title_pur_flower",  --"超难"字样背后的花
        [LevelDiffcultFlag.kNormal] = false,
        [LevelDiffcultFlag.kDiffcult] = false,
        [LevelDiffcultFlag.kExceedinglyDifficult] = {
            [HomeScenePanelSkinType.kLevelInfoPanel] = true,
            [HomeScenePanelSkinType.kLevelSucTopPanel] = true,
            [HomeScenePanelSkinType.kLevelFailTopPanel] = false,
        },
    },
    {
        name = "label_green2", --"困难"字样
        [LevelDiffcultFlag.kNormal] = false,
        [LevelDiffcultFlag.kDiffcult] = {
            [HomeScenePanelSkinType.kLevelInfoPanel] = true,
            [HomeScenePanelSkinType.kLevelSucTopPanel] = true,
            [HomeScenePanelSkinType.kLevelFailTopPanel] = false,
        },
        [LevelDiffcultFlag.kExceedinglyDifficult] = false,
    },
    {
        name = "label_pur2",  --"超难"字样
        [LevelDiffcultFlag.kNormal] = false,
        [LevelDiffcultFlag.kDiffcult] = false,
        [LevelDiffcultFlag.kExceedinglyDifficult] = {
            [HomeScenePanelSkinType.kLevelInfoPanel] = true,
            [HomeScenePanelSkinType.kLevelSucTopPanel] = true,
            [HomeScenePanelSkinType.kLevelFailTopPanel] = false,
        },
    },

    
}


-- 调色索引
local colorAdjustConfigs =
{
    -- 对需要调整色彩的项进行设置；kNormal/kDifficult/kExceedinglyDifficult每项都可留空表示不调整
    -- 数值是_G.LvlFlagColor中的键值
    -- 范例：
    -- {
    --     name = "bg/bg",
    --     [LevelDiffcultFlag.kNormal] = 1,
    --     [LevelDiffcultFlag.kDiffcult] = 2,
    --     [LevelDiffcultFlag.kExceedinglyDifficult] = 3,
    -- },
    -- 需要批量时使用from和to（两端包含）
    -- 范例：
    -- {
    --     name = "图层 ",
    --     from = 1,
    --     to = 10,
    --     [LevelDiffcultFlag.kNormal] = 1,
    --     [LevelDiffcultFlag.kDiffcult] = 2,
    --     [LevelDiffcultFlag.kExceedinglyDifficult] = 3,
    -- },



    {
        name = "string_",  --1元打折界面的条
        from = 1,
        to = 2,
        [LevelDiffcultFlag.kDiffcult] = 52,
        [LevelDiffcultFlag.kExceedinglyDifficult] = 2,
    },
    {
        name = "bg/jsmaline_",  --1元打折界面的条
        from = 1,
        to = 10,
        [LevelDiffcultFlag.kDiffcult] = 52,
        [LevelDiffcultFlag.kExceedinglyDifficult] = 2,
    },
    {
        name = "hang_",  --面板上方吊线细藤蔓
        from = 1,
        to = 6,
        [LevelDiffcultFlag.kDiffcult] = 52,
        [LevelDiffcultFlag.kExceedinglyDifficult] = 2,
    },
    {
        name = "bg/bg",  --面板背景
        [LevelDiffcultFlag.kExceedinglyDifficult] = 1,
    },
    {
        name = "bg/diffcultadd",  --右上关闭按钮下的单片叶子
        [LevelDiffcultFlag.kDiffcult] = 54,
        [LevelDiffcultFlag.kExceedinglyDifficult] = 4,
    },
    {
        name = "bg/border_",  --边框
        from = 1,
        to = 4,
        [LevelDiffcultFlag.kDiffcult] = 52,
        [LevelDiffcultFlag.kExceedinglyDifficult] = 2,
    },
    {
        name = "bg/title_green_bg1",  --面板顶部带刺藤蔓
        [LevelDiffcultFlag.kDiffcult] = 52,
        [LevelDiffcultFlag.kExceedinglyDifficult] = 2,
    },
    {
        name = "bg/title_green_bg_2_",  --面板顶部向上伸出的藤尖
        from = 1,
        to = 2,
        [LevelDiffcultFlag.kDiffcult] = 52,
        [LevelDiffcultFlag.kExceedinglyDifficult] = 2,
    },
    {
        name = "bg/top_leaves_",  --上边框的点缀叶子
        from = 1,
        to = 2,
        [LevelDiffcultFlag.kDiffcult] = 52,
        [LevelDiffcultFlag.kExceedinglyDifficult] = 2,
    },
    {
        name = "bg/bottom_leaves_",  --下边框的点缀叶子
        from = 1,
        to = 2,
        [LevelDiffcultFlag.kDiffcult] = 53,
        [LevelDiffcultFlag.kExceedinglyDifficult] = 3,
    },
    {
        name = "clippingAreaAbove/_itemScale9Bg",
        [LevelDiffcultFlag.kExceedinglyDifficult] = 5,
    },
    {
        name = "clippingAreaAbove_new/_itemScale9Bg",
        [LevelDiffcultFlag.kExceedinglyDifficult] = 5,
    },
    {
        name = "_itemBg",
        [LevelDiffcultFlag.kExceedinglyDifficult] = 5,
    },
    {
        name = "fadeArea/messageBox",
        [LevelDiffcultFlag.kExceedinglyDifficult] = 5,
    },
    {
        name = "jump_level_area/jump_level_bg",
        [LevelDiffcultFlag.kDiffcult] = 56,
        [LevelDiffcultFlag.kExceedinglyDifficult] = 6,
    },
    {
        name = "jump_level_area/jump_level_icon/bubble",
        [LevelDiffcultFlag.kExceedinglyDifficult] = 7,
    },
    {
        name = "jumptwobtn",  --跳过按钮的颜色值
        [LevelDiffcultFlag.kDiffcult] = 57,
        [LevelDiffcultFlag.kExceedinglyDifficult] = 7,
    },

}


LevelPanelDifficultyChanger = {}

-- 物件缓存
local _elementsBuffer = { }
-- 物件缓存归属于哪个面板
local _elementsBufferBelongsTo = false

function LevelPanelDifficultyChanger:clearElementsBuffer()
    _elementsBuffer = { }
    _elementsBufferBelongsTo = false
end

local function _findUiByPath(path, fromParent)
    assert(type(path)=="string")
    assert(fromParent)
    
    -- 缓存的父级变更时，清空缓存
    if fromParent ~= _elementsBufferBelongsTo then 
        LevelPanelDifficultyChanger:clearElementsBuffer()
    end
    _elementsBufferBelongsTo = fromParent

    local inBuffer = _elementsBuffer[path]
    if inBuffer then return inBuffer end

    local selection = nil
    if not selection then
        selection = fromParent.ui:getChildByPath(path) 
    end
    if not selection and fromParent.ui and fromParent.ui.realUI  then
        selection = fromParent.ui.realUI:getChildByPath(path)
    end
    if selection then _elementsBuffer[path] = selection end
    --if not selection then print("LevelPanelDifficultyChanger: Didn't find ui children: "..path) end --debug
    return selection
end

function LevelPanelDifficultyChanger:changeNodeByDifficulty(nodeToChange, levelDiffcultFlag)
    local function _applyColorAdjustToNode( nodeName, config )
        if not nodeToChange then return end
        if nodeName ~= nil and nodeToChange.name ~= nodeName then
            return
        end
        assert(config)
        local configOnDiff = config[levelDiffcultFlag]
        if configOnDiff then 
            nodeToChange:adjustColor(_G.LvlFlagColor[configOnDiff][1],
                _G.LvlFlagColor[configOnDiff][2],
                _G.LvlFlagColor[configOnDiff][3],
                _G.LvlFlagColor[configOnDiff][4])
            nodeToChange:applyAdjustColorShader()
        end
    end
        -- 调色
    for _,v in ipairs(colorAdjustConfigs) do
        _applyColorAdjustToNode(v.name,v)
    end

end

function LevelPanelDifficultyChanger:changeBgByDifficulty(levelPanelToChange, levelDiffcultFlag, panelTypeFlag)
    
    local function _applyVisibleToNode(nodeName, config)
        local node = _findUiByPath(nodeName,levelPanelToChange)
        if not node then return end
        assert(config)
        local configOnDiff = config[levelDiffcultFlag]
        if configOnDiff~=nil then
            local typeOfConfigOnDiff = type(configOnDiff)
            if typeOfConfigOnDiff == "boolean" then
                node:setVisible(configOnDiff)
            elseif typeOfConfigOnDiff == "function" then
                node:setVisible(configOnDiff(levelPanelToChange))
            elseif typeOfConfigOnDiff == "table" then
                local configOnPanelType = configOnDiff[panelTypeFlag]
                if configOnPanelType~=nil then
                    local typeOfConfigOnPanelType = type(configOnPanelType)
                    if typeOfConfigOnPanelType == "boolean" then
                        node:setVisible(configOnPanelType)
                    elseif typeOfConfigOnPanelType == "function" then
                        node:setVisible(configOnPanelType(levelPanelToChange))
                    else
                        print("LevelPanelDifficultyChanger: invalid elementVisibleConfig of: ".. nodeName)
                    end
                end
            else
                print("LevelPanelDifficultyChanger: invalid elementVisibleConfig of: " .. nodeName)
            end
        end
    end

    local function _applyColorAdjustToNode(nodeName, config)
        local node = _findUiByPath(nodeName,levelPanelToChange)
        if not node then return end
        assert(config)

        local configOnDiff = config[levelDiffcultFlag]
        if configOnDiff then 
            node:adjustColor(_G.LvlFlagColor[configOnDiff][1],
                _G.LvlFlagColor[configOnDiff][2],
                _G.LvlFlagColor[configOnDiff][3],
                _G.LvlFlagColor[configOnDiff][4])
            node:applyAdjustColorShader()
        end
    end

    -- 可见性
    for _,v in ipairs(elementVisibilityConfigs) do
        if v.from then
            for i=v.from,v.to do
                _applyVisibleToNode(v.name .. tostring(i), v)
            end
        else
            _applyVisibleToNode(v.name, v)
        end
    end

    -- 调色
    for _,v in ipairs(colorAdjustConfigs) do
        if v.from then
            for i=v.from,v.to do
                _applyColorAdjustToNode(v.name .. tostring(i), v)
            end
        else
            _applyColorAdjustToNode(v.name, v)
        end
    end

end
