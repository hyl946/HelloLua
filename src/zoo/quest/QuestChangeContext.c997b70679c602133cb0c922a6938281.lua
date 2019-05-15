local QuestChangeContext = class()

function QuestChangeContext:ctor( ... )
	self:reset()
	_G.questEvtDp:ad(QuestEventType.kQuestUpdate, self.onQuestUpdate, self)
end

function QuestChangeContext:onQuestUpdate( event )

	-- printx(61, 'QuestChangeContext:onQuestUpdate', event.data.quest.id, event.data.quest._type)

	local oldData = event.data.oldData
	local newData = event.data.newData
	local quest = event.data.quest

	local id, _ = quest:getIdAndType()

	if not self.dataChangeMap[id] then
		self.dataChangeMap[id] = {
			oldData = oldData,
			newData = newData,
			quest = quest,
		}
	else
		self.dataChangeMap[id].newData = newData
		self.dataChangeMap[id].quest = quest
	end


	-- local curScene = Director:sharedDirector():getRunningSceneLua()
	-- if curScene.name and curScene.name == 'GamePlaySceneUI' then
		-- self:popTip()
	-- end
end

----QuestACT 专属方法 -- 其他需求不应该用
function QuestChangeContext:popTip( done )
	-- body
	if (not AutoPopout:isInNextLevelMode()) and (require 'zoo.quest.QuestActLogic'):isActEnabled() then
		local changeDataList = self:getData(0)
		if #changeDataList > 0 then
			local QuestChangeAnimation = require 'zoo.quest.animation.QuestChangeAnimation'
			local anim = QuestChangeAnimation:create(changeDataList)
			if done then
				anim:ad(Events.kDispose, function ( ... )
					if done then done() end
				end)
			end
			anim:popout()
			return
		end
	end
	if done then done() end
end



function QuestChangeContext:reset( moduleId )
	if not self.dataChangeMap then
		self.dataChangeMap = {}
	end
	if not moduleId then
		self.dataChangeMap = {}
	else
		local tmp = table.filter(self.dataChangeMap, function ( v )
			return v.quest:getModuleId() ~= moduleId
		end) or {}

		self.dataChangeMap = {}

		for _, v in ipairs(tmp) do
			local id, _ = v.quest:getIdAndType()
			self.dataChangeMap[id] = v
		end

	end
end

function QuestChangeContext:getData(moduleId, getAll )
	local ret = {}
	for _, v in pairs(self.dataChangeMap) do
		if v.quest:getModuleId() == moduleId then
			if (v.newData.num > v.oldData.num) or (getAll and (v.newData.num ~= v.oldData.num)) then
				table.insert(ret, v)
			end
		end
	end
	return ret
end

local instance 
function QuestChangeContext:getInstance( ... )
	if not instance then
		instance = QuestChangeContext.new()
	end
	return instance
end

_G.QuestChangeContext = QuestChangeContext

return QuestChangeContext