SectionData = class()

function SectionData:ctor()
	self.pos1 = nil
	self.pos2 = nil
	self.sectionType = nil
	self.propId = nil
end

function SectionData:dispose()
	self.pos1 = nil
	self.pos2 = nil
	self.sectionType = nil
	self.propId = nil
end

function SectionData:init(sectionType , pos1 , pos2 , propId)
	self.sectionType = sectionType
	self.pos1 = pos1
	self.pos2 = pos2
	self.propId = propId
end

function SectionData:create(sectionType , pos1 , pos2 , propId)
	local data = SectionData.new()
	data:init(sectionType , pos1 , pos2 , propId)
	return data
end