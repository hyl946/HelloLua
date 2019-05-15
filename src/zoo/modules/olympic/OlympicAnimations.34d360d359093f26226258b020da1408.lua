---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-07-28 15:29:12
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2016-07-29 14:06:08
---------------------------------------------------------------------------------------
OlympicAnimations = class()

function OlympicAnimations:createLeftStepNode()
	return require("zoo.modules.olympic.OlympicLeftStepNode"):create()
end

function OlympicAnimations:createOlympicBlockerDecAnimation()
	
end