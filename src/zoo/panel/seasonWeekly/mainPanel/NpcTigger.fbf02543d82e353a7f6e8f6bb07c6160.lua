local BaseNpcAnimNode = require 'zoo.panel.seasonWeekly.mainPanel.BaseNpcAnimNode'

local NpcTigger = class(BaseNpcAnimNode)

local SkinType = {
	kHat = 1,
	kScarf = 2,
	kHand = 3,
	kDecorate = 4,
}

local SkinMeta = {
	[SkinType.kHat] = {
		[1] = 4,
		[2] = 9,
	},
	[SkinType.kDecorate] = {
		[1] = 16,
		[2] = 16,
	},
	[SkinType.kHand] = {
		[1] = 9,
		[2] = 16,
	},
	[SkinType.kScarf] = {
		[1] = 4,
		[2] = 9,
	},
}

NpcTigger.SkinType = SkinType
NpcTigger.SkinMeta = SkinMeta

function NpcTigger:create( ... )
	local npc = NpcTigger.new()
	npc:initAnimNode(
		'skeleton/tigger',
		'tigger',
		'sw.s4.npc.anim/tigger',
		'ui/npc_skin.json'
	)
	return npc
end

function NpcTigger:getSkinsNum( ... )
	local counter = 0
	for _, v in pairs(SkinMeta) do
		counter = counter + table.size(v)
	end
	return counter
end

function NpcTigger:getPicecsNumNeedToCompleteAll( ... )
	local counter = 0
	for _, v in pairs(SkinMeta) do
		for _, n in pairs(v) do
			counter = counter + n
		end
	end
	return counter
end


function NpcTigger:playIdle( ... )
	self.animNode:playByIndex(0, 0)
end

function NpcTigger:initSkinConfig( ... )
	self.skinConfig = {
		skinTypeMapSlots = {
			[SkinType.kHat] = {'hat'},
			[SkinType.kDecorate] = {'decorate'},
			[SkinType.kHand] = {'hand1', 'hand2'},
			[SkinType.kScarf] = {'scarf'},
		},
		slotMapSpriteFrameNamePrefix = {
			['hat'] = 'sw.s4.npc.tigger/hat',
			['decorate'] = 'sw.s4.npc.tigger/decorate',
			['hand1'] = 'sw.s4.npc.tigger/hand1',
			['hand2'] = 'sw.s4.npc.tigger/hand2',
			['scarf'] = 'sw.s4.npc.tigger/scarf',
		}
	}
end

function NpcTigger:isComplete( skinType, group )
	local needNum = (SkinMeta[skinType] or {})[group] or 0
	return SeasonWeeklyRaceManager:getInstance():getSkinGroupPositionNum(skinType, group) >= needNum
end

function NpcTigger:isCompleteAll( ... )
	for _, skinType in pairs(SkinType) do
		for i = 1, 2 do
			if not self:isComplete(skinType, i) then
				return false
			end
		end
	end
	return true
end

function NpcTigger:isPiecesEnoughToCompleteAll( ... )
	return  SeasonWeeklyRaceManager:getInstance():getTotalPieceNum() >= NpcTigger:getPicecsNumNeedToCompleteAll()
end

function NpcTigger:refreshSkin( ... )
	local curSkin = SeasonWeeklyRaceManager:getInstance():getCurSkin() or {}
	for skinType, group in pairs(curSkin) do

		self:setSkin2(tonumber(skinType) or 1, tonumber(group) or 1)
	end
end

function NpcTigger:isCompleteAnyone( ... )
	for _, skinType in pairs(SkinType) do
		for i = 1, 2 do
			if self:isComplete(skinType, i) then
				return true
			end
		end
	end
	return false
end


function NpcTigger:getSkinCompletedNum( ... )
	local counter = 0
	for _, skinType in pairs(SkinType) do
		for i = 1, 2 do
			if self:isComplete(skinType, i) then
				counter = counter + 1
			end
		end
	end
	return counter
end

return NpcTigger