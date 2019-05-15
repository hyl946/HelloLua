local function switch( n )
	return function ( t )

		local function _do( action )
			if type(action) == 'function' then
				return action()
			else
				return action
			end
		end

		if t[n] ~= nil then
			return _do(t[n])
		end

		for k, f in pairs(t) do
			if type(k) == 'function' then
				if k(n) then
					return _do(f)
				end
			end
		end

		if t.default then
			return _do(t.default)
		end
	end
end

-- if __WIN32 then

-- 	local condition = 6  --print 321
-- 	local condition = 7  --print hello
-- 	local condition = 8  --print null
-- 	local condition = 9  --print world
	
-- 	local k = switch(condition){
-- 		[6] = function ( ... )
-- 			return 321
-- 		end ,
-- 		[7] = "hello",
-- 		[function (n) return n%2 == 1 end] = "world",
-- 		default = "null",
-- 	}

-- 	printx(61, k)

-- end

local maxId = -1

local function generateId( id )
	maxId = math.max(maxId + 1, id or 0)
	-- printx(61, 'maxId', maxId, debug.traceback())

	return maxId
end

local QuestFactory = class()

function QuestFactory:createQuestByRawData( rawData, groupId, moduleId)


	local classObj = switch(tonumber(rawData._type)){
		[1] = require 'zoo.quest.questImp.QILogin',
		[2] = require 'zoo.quest.questImp.QIPlayMainLevel',
		[3] = require 'zoo.quest.questImp.QIKillAnimal',
		[4] = require 'zoo.quest.questImp.QIPlayHiddenLevel',
		[5] = require 'zoo.quest.questImp.QIPassTopLevel',
		[6] = require 'zoo.quest.questImp.QIPassTopLevelContinuously',
		[7] = require 'zoo.quest.questImp.QIPassMainLevelWithNStar',
		[8] = require 'zoo.quest.questImp.QIPassHiddenLevel',
		[9] = require 'zoo.quest.questImp.QIGetNewStar',
		[10] = require 'zoo.quest.questImp.QIUsePreProp',
		[11] = require 'zoo.quest.questImp.QIPickFruit',
		[12] = require 'zoo.quest.questImp.QIKillLine',
		[13] = require 'zoo.quest.questImp.QIKillWrap',
		[14] = require 'zoo.quest.questImp.QIKillBird',

		[15] = require 'zoo.quest.questImp.QIBegEnergyFromFriends',
		[16] = require 'zoo.quest.questImp.QIKillAnimalInOneLevel',
		[17] = require 'zoo.quest.questImp.QIKillEffectInOneLevel',
		[18] = require 'zoo.quest.questImp.QIPlayUnfullLevel',
		[19] = require 'zoo.quest.questImp.QIPassExMainLevel',
		[20] = require 'zoo.quest.questImp.QIPlayUnpassedMainLevel',

		default = function ( ... )
			printx(61, 'no supported quest type')
		end,
	}

	if classObj then
		local quest = classObj.new()
		quest:setIdAndType(generateId(rawData.id), rawData._type)
		quest:setGroupId(groupId) 
		quest:setModuleId(moduleId or 0) -- QusetACT 的moduleId 是 0
		quest:setQuestData(rawData)
		return quest
	end
end

function QuestFactory:encodeQuest( quest )
	local rawData = quest:encode()
	rawData.id, rawData._type = quest:getIdAndType()
	return rawData
end

return QuestFactory