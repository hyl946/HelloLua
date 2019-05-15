local Track = require 'zoo.panel.endGameProp.anim.Track'

local FuncTrack = class(Track)

function FuncTrack:ctor( ... )
	-- Track.ctor(self, ...)
	self.last_frame_index = nil
end


function FuncTrack:__update( p_frame_index )

	if self.last_frame_index == p_frame_index then
		return
	end

	for i = (self.last_frame_index or -1) + 1, p_frame_index, 1 do


		local frame_data = self:getFrameData(i)
		if frame_data then
			frame_data(self.target)
		end
	end

	self.last_frame_index = p_frame_index
	
end

function FuncTrack:copyFrom( other )
	Track.copyFrom(self, other)
	self.last_frame_index = other.last_frame_index
end


return FuncTrack