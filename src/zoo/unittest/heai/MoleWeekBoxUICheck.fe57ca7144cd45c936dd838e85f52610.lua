-- 检测周赛boxui 旧素材是否存在
-- 
--add bt zhigang.niu
MoleWeekBoxUICheck = class(UnittestTask)

local function initPos(x,y) 
    local pos = {}
    pos.x=  x
    pos.y = y
    return pos
end

function MoleWeekBoxUICheck:ctor( ... )
	-- body
	UnittestTask.ctor(self, ...)

end

function MoleWeekBoxUICheck:run( callback )

    local basePath = "moleweek_race_end_game/box"
    local checkSaiJiList = {3,4}

	--测试用例
	local dataSets = {}
    for i=1, 10 do
        for j,k in ipairs(checkSaiJiList) do
            table.insert(dataSets,basePath..i.."_"..k)
        end
    end

	for _, v in ipairs(dataSets) do
		if not self:checkMoleWeekFla(v) then
			callback(false, 'failed on MoleWeekBoxUICheck ' .. v.. " missed" )
			return
		end
	end

	callback(true, 'test MoleWeekBoxUICheck.lua successd!')
end


-- ============================== 后边是实现可以不看
-- ============================== 后边是实现可以不看
-- ============================== 后边是实现可以不看

function MoleWeekBoxUICheck:checkMoleWeekFla( key )
    local FilePath = "flash/MoleWeekly/MoleWeekly.json"
    FilePath = CCFileUtils:sharedFileUtils():fullPathForFilename(FilePath)

    local file, err = io.open(FilePath, "rb")

    if file and not err then
        local content = file:read("*a")
		io.close(file)

        local fileJson = table.deserialize( content or {} )

        if fileJson.groups then
            if fileJson.groups[key] then return true end
        end
    end

    return false
end

