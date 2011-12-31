require ("lua.class")
require ("lua.drawable")
require ("lua.updatable")

blockList = {}
blockListRemove = {}

Block = {}

BlockBuilder = createClass(Block, Updatable, Drawable)


function Block:new()

	blockList[#blockList+1] = self
	self.signature="block"

	self:calculatePosition()

	self.timesHitted = 0

	self.pixels = self:initPixels()

	self.active = true

	return self
end


function Block:destroy()
	self.active = false
	blockListRemove[#blockListRemove+1] = self
end


function Block:draw()

	local shield = self.shield

	love.graphics.draw(self.img, self.pos.x, self.pos.y)

end


function Block:update(dt)

end


function Block:calculatePosition()

	local shield = self.shield
	local line = self.line
	local column = self.column
	local blockBatch = self.blockBatch
	local blockW = shield.width / shieldConstants.SHIELD_NUM_COLUMNS
	local blockH = shield.height / shieldConstants.SHIELD_NUM_LINES
	local blockX = ((column - 1) * blockW)
	local blockY = ((line - 1) * blockH)

	self:initImage(blockX, blockY, blockW, blockH)
	self.pos = {x=blockX, y=blockY, z=3}


	self.pos.x = self.pos.x + shield.pos.x
	self.pos.y = self.pos.y + shield.pos.y



end


function Block:initImage(x, y, w, h)

	local blockBatch = self.blockBatch
	local blockSource = love.image.newImageData(w, h)
	blockSource:paste(blockBatch.userData, 0, 0, x, y)
	local img = love.graphics.newImage(blockSource)

	self.imgSource = blockSource
	self.img = img

	self.width = img:getWidth()
	self.height = img:getHeight()

end


function Block:initPixels()

	local pixels = {}
	local widthBlock = self.width
	local heightBlock = self.height

	for l = 1, heightBlock do
		for c = 1, widthBlock do
			local pixel= {l=l-1, c=c-1}
			table.insert(pixels, pixel)
		end
	end

	return pixels

end


function Block:collide(obstacle)



	local maxHits = shieldConstants.SHIELD_HITS_BLOCK
	local timesHitted
	local hitImpact

	if obstacle.signature == "bullet" then
		self.shield.hitSound:stop()
		self.shield.hitSound:play()
		local bullet = obstacle
		hitImpact = self:hitImpact(bullet)
		timesHitted = self.timesHitted + hitImpact

	elseif obstacle.signature == "invader" then

		self.shield.attackedSound:stop()
		self.shield.attackedSound:play()
		hitImpact = 0.1
		timesHitted = self.timesHitted + hitImpact

	end

	if (timesHitted >= maxHits) then
		BlockBuilder:destroy(self)
	else
		self:damage(hitImpact)
	end
	self.timesHitted = timesHitted

end


function Block:hitImpact(bullet)

	local grazedBullet = false
	local aimGap = 0
	local hitImpact = 0

	if self.pos.x >= bullet.pos.x then
		aimGap = self.pos.x - bullet.pos.x
	else
		aimGap = (self.pos.x + self.width) - bullet.pos.x
	end

	if aimGap < bullet.width then
		grazedBullet = true
	end
	local hitImpact = 1
	if grazedBullet then
		hitImpact = 0.5
	end

	return hitImpact

end

function Block:damage(hitImpact)

	local maxHits = shieldConstants.SHIELD_HITS_BLOCK
	local totalPixels = self.width * self.height
	local pixelsToRemove = hitImpact * ((totalPixels / maxHits))

	for i = 1, pixelsToRemove do
		local indexPixel = math.random(1, #self.pixels - 1)
		local pixel = self.pixels[indexPixel]
		table.remove(self.pixels, indexPixel)
		self.imgSource:setPixel(pixel.c, pixel.l,0,0,0,0)
	end

	local img = love.graphics.newImage(self.imgSource)
	self.img = img


end
