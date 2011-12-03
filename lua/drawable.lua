drawableList = {}
drawableListRemove = {}

Drawable =
{
	pos =
	{
		x = 0,
		y = 0,
		z = 0,
	},
	img = nil
}

DrawableBuilder = createClass(Drawable)

function Drawable:new()
	drawableList[#drawableList+1] = self
	table.sort(drawableList, function(a, b)
		return a.pos.z < b.pos.z
	end)
end

function Drawable:destroy()
	drawableListRemove[#drawableListRemove+1] = self
end

function Drawable:draw()
	love.graphics.draw(self.img, self.pos.x, self.pos.y, 0, 1, 1, 0, 0)
end

function Drawable:isOnScreen()
return not (self.pos.x > love.graphics.getWidth() or
self.pos.x < -self.img:getWidth() or
self.pos.y > love.graphics.getHeight() or
self.pos.y < -self.img:getHeight())
end
