require ("lua.class")
require ("lua.drawable")
require ("lua.updatable")

shieldList = {}
shieldListRemove = {}

Shield = {}

ShieldBuilder = createClass(Shield, Updatable)


function Shield:new()

	shieldList[#shieldList+1] = self

	self:loadImage()
	self:loadSounds()
	self.region = region
	self.pos = {x=0, y=0, z=3}
	self.blocks = blocks or {}

	return self
end


function Shield:destroy()
	self.active = false
	shieldListRemove[#shieldListRemove+1] = self
end


function Shield:draw()

end

function Shield:update(dt)

end


function Shield:placeBlocks()

	for line = 1, 3 do
		for column = 1, 5 do
			if line ~= 3 or column ~= 3 then
				self:placeBlock(column, line)
			end
		end
	end
end


function Shield:placeBlock(column, line)

	local newBlock = BlockBuilder:new(
					{
						blockBatch = self.spriteBatch,
						shield = self,
						line = line,
						column = column
					}
				)
	table.insert(self.blocks, newBlock)

end


function Shield:loadImage()

	local w,h = shieldConstants.SHIELD_WIDTH, shieldConstants.SHIELD_HEIGHT
	local shieldRegion = RegionClass.new(0, 0, w, h)
	local shieldSpriteBatch = SpriteClass.new(shieldConstants.SHIELD_SPRITE)

	shieldImgSource = shieldSpriteBatch:cutRegionIntoImage(shieldRegion)

	local img
	img = love.graphics.newImage(shieldImgSource)

	self.imgSource = shieldImgSource
	self.spriteBatch = shieldSpriteBatch
	self.img = img
	self.width = self.img:getWidth()
	self.height = self.img:getHeight()

end


function Shield:loadSounds()


	self.hitSound = game:loadShieldHitSound()
	self.attackedSound = game:loadShieldAttackedSound()


end

