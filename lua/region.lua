RegionClass = {}

function RegionClass.new(x, y, w, h)
	local r= {}
	setmetatable(r, {__index = RegionClass})

	r.x = x or 0
	r.y = y or 0
	r.w = w or 0
	r.h = h or 0



	return r
end

