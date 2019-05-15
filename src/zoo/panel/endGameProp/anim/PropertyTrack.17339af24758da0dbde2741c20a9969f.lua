local Track = require 'zoo.panel.endGameProp.anim.Track'

local PropertyTrack = class(Track)

function PropertyTrack:ctor( ... )
	-- Track.ctor(self, ...)
	self.getter = nil
	self.setter = nil
	self.proterty_interpolater = function ( a, b, t)
		return (1-t) * a + t * b;
	end
	self.clock_interpolater = nil
end

function PropertyTrack:setPropertyAccessor(p_getter, p_setter)
	self.getter = p_getter
	self.setter = p_setter
end

function PropertyTrack:setPropertyInterpolater( p_interpolater )
	-- body
end

function PropertyTrack:setClockInterpolater( p_clock_interpolater )
	-- body
end

function PropertyTrack:__update( p_frame_index )

	--todo 实现时间曲线变化
	-- if self.clock_interpolater then

	-- end

	local frame_data = self:getFrameData(p_frame_index)
	if not frame_data then
		local before_frame_data, before_frame_index = self:getFrameDataBefore(p_frame_index)
		local after_frame_data, after_frame_index = self:getFrameDataAfter(p_frame_index)
		local t = (p_frame_index - before_frame_index) / (after_frame_index - before_frame_index)
		frame_data = self.proterty_interpolater(before_frame_data, after_frame_data, t)
	end
	self.setter(self.target, frame_data)
end


function PropertyTrack:copyFrom( other )
	Track.copyFrom(self, other)

	self.getter = other.getter
	self.setter = other.setter
	self.proterty_interpolater = other.proterty_interpolater
	self.clock_interpolater = other.clock_interpolater


end

return PropertyTrack