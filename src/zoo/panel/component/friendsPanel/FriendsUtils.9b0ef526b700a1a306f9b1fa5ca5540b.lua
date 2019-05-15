
local Util = {}

function Util:ACGINFO(profile, isShortStyle)

    local function isInfoVisible(profile)
        return profile.secret == true and tonumber(profile.uid) ~= tonumber(UserManager.getInstance().user.uid)
    end

	-- 男 90岁 摩羯座 山东省 德州市
	local ageText = ''
	local genderText = ''
	local constellationText = ''
	local ret = ""

	-- 如果隐私保密
	if isInfoVisible(profile) then
		ret = ""
		return ret
	end

	local age = profile.age
	age = age or 0
	if tonumber(age) == 100 then
		age = "99+"
	end
	ageText = age == 0 and "" or age.."岁".." "

	local genderTextGroup = {'', localize('my.card.edit.panel.content.male'), localize('my.card.edit.panel.content.female')}
	local gender = profile.gender or 0
	genderText = genderTextGroup[gender + 1]..''

	local constellation = profile.constellation or 0
	if constellation > 0 then
		constellationText = localize('my.card.edit.panel.content.constellation'..constellation)
	end

	-- location
	local location = ""
	local ver = string.split(profile.location or "", '#')
	if ver and table.size(ver) > 0 then
		if ver[1] then
			location = " " ..ver[1]
		end
		if not isShortStyle then
			if ver[2] then
				location = location .." " ..ver[2]
			end
			if ver[3] then
				location = location .." " ..ver[3]
			end
		end
	end

	ret = genderText
	if not string.isEmpty(ageText) then
		ret = ret .." "..ageText
	end
	if not string.isEmpty(constellationText) then
		ret = ret .." " ..constellationText
	end
	if not string.isEmpty(location) then
		ret = ret ..location
	end

	return ret
end

function Util:getData(dataProvider, idx)
	local ret = {user={}, profile={}}
	if not dataProvider.users[idx] then
		return ret
	end

	local user = dataProvider.users[idx]
	local profile = {}
	for k,v in pairs(dataProvider.profiles) do
		if v.uid == user.uid then
			profile = v
		end
	end
	return {user=user, profile=profile}
end

return Util