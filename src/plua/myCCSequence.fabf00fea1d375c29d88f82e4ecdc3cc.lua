
CCArray = class()
function CCArray:ctor()
	self.arrayTab = {}
end

function CCArray:create()
	return CCArray.new()
end

function CCArray:count()
	return #self.arrayTab
end

function CCArray:addObject(obj)
	local len = #self.arrayTab
	self.arrayTab[len + 1] = obj
end

function CCArray:copy()
	local other = CCArray:create()
	for k, v in ipairs(self.arrayTab) do
		local obj = v:copy()
		other:addObject(obj)
	end
	return other
end


myCCSequence = class(myCCAction)

function myCCSequence:ctor()
	self.actionQuere = {}
end


function myCCSequence:createWithTwoActions(act1, act2)
	local seq = myCCSequence.new()
	seq.actionQuere[1] = nil
	seq:addAction(act1)
	seq:addAction(act2)
	return seq
end


function myCCSequence:create(arr)
	local seq = myCCSequence.new()
	seq.actionQuere[1] = nil
	local len = #arr.arrayTab
	for i=1, len do
		local act1 = arr.arrayTab[i]
		seq:addAction(act1)
	end
	return seq
end

CCSpawn = class(myCCSequence)

function CCSpawn:create(arr)
	local act = myCCSequence.new()
	act.actionQuere[1] = nil
	local len = #arr.arrayTab
	for i=1, len do
		local act1 = arr.arrayTab[i]
		act:addAction(act1)
	end
	return act
end

function CCSpawn:createWithTwoActions(act1, act2)
	local act = CCSpawn.new()
	act.actionQuere[1] = nil
	act:addAction(act1)
	act:addAction(act2)
	return act
end

ccBezierConfig = class()
function ccBezierConfig:new_local()
	return ccBezierConfig:new()
end

function ccBezierConfig:call()
end

function ccBezierConfig:endPosition()
	return {}
end

function ccBezierConfig:controlPoint_1()
	return {}
end

function ccBezierConfig:controlPoint_2()
	return {}
end




CCSequence = myCCSequence