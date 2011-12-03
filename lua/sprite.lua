SpriteClass = {}

function SpriteClass.new(filename)
	local s= {}
	setmetatable(s, {__index = SpriteClass})


	local userData = love.image.newImageData(filename)

	s.filename = filename or "images\resources\sprite_batch.png"
	s.userData = userData

	return s
end


function SpriteClass:cutRegionIntoImage(region)
	local s = self


	local imgSource = love.image.newImageData(region.w, region.h)
	imgSource:paste(s.userData, 0, 0, region.x, region.y)
	img = love.graphics.newImage(imgSource)

	return imgSource

end
