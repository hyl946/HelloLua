local A, B, C, D = 1,2,3,4
local _config = {
    max = 35,
    buffs = 
    {
        {buff = {A}, count = 1},
        {buff = {A,B}, count = 6},
        {buff = {A,B,C}, count = 11},
        {buff = {A,B,C,D}, count = 21},
        {buff = {A,A,B,C,D}, count = 32},
    },
}


local UserCallbackBuffLogic = {}

function UserCallbackBuffLogic:getBuffGradeAndConfigByClassGrade(buffGrade)
    local destConfig = {}
    local maxGrade = buffGrade
    local config = _config
    if config.buffs[maxGrade] then
        for k, v in ipairs(config.buffs[maxGrade].buff) do
            table.insert(destConfig, {buffType = v})
        end
    end
    return maxGrade, destConfig
end



return UserCallbackBuffLogic