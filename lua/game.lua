require ("lua.class")
require ("lua.drawable")
require ("lua.updatable")


gameList = {}
gameListRemove = {}

Game = {}

GameBuilder = createClass(Game, Updatable, Drawable)

function Game:new()
	gameList[#gameList+1] = self

	math.randomseed(os.time())

	self:defineWindowConfiguration()
	self:createLevels()
	self.spriteBatch = SpriteClass.new(gameConstants.GAME_SPRITE)
	self:loadImages()
	self:loadSounds()

	--self.state = gameConstants.GAME_PLAY_KEYBOARD
	self.state = gameConstants.GAME_INTRO

	self.bg = love.graphics.newImage(gameConstants.GAME_BG)
	self.font = love.graphics.newFont(gameConstants.GAME_FONT, gameConstants.GAME_FONTSIZE)

	self.lives = gameConstants.GAME_LIVES
	self.lastExtraLife = 0
	self.score = 0

	return self
end

function Game:destroy()
	self.active = false
	gameListRemove[#gameListRemove+1] = self
end

function Game:draw(dt)

end

function Game:update(dt)

end

function Game:defineWindowConfiguration()

	love.graphics.setMode(gameConstants.GAME_WCANVAS, gameConstants.GAME_HCANVAS, false, true, 0)
	love.graphics.setCaption(gameConstants.GAME_WINDOW_CAPTION)

	local wCanvas = love.graphics.getWidth()
	local hCanvas = love.graphics.getHeight()

	self.wCanvas = wCanvas
	self.hCanvas = hCanvas

end

function Game:createLevels()

	local gameLevels =	{
			{
				speedX = 40,
				speedY = 20,
				delays = {5,15,7,30,17,40},
		},
			{
				speedX = 42,
				speedY = 21,
				delays = {5,14,6,28,13,35},
		},
			{
				speedX = 44,
				speedY = 22,
				delays = {4,13,6,26,11,32},
		},
			{
				speedX = 47,
				speedY = 25,
				delays = {4,12,5,23,9,28},
		},
			{
				speedX = 50,
				speedY = 27,
				delays = {3,11,5,20,7,25},
		},
			{
				speedX = 55,
				speedY = 30,
				delays = {3,10,4,17,5,20},
		},
			{
				speedX = 62,
				speedY = 35,
				delays = {2,9,4,15,4,18},
		},
			{
				speedX = 70,
				speedY = 40,
				delays = {2,8,3,12,3,15},
		},
			{
				speedX = 80,
				speedY = 47,
				delays = {1,7,2,10,2,12},
		},
			{
				speedX = 90,
				speedY = 52,
				delays = {1,6,1,8,2,10},
		},
	}

	self.gameLevels = gameLevels

end



function Game:loadImages()

	local images = {}

	images["miniCannon"] = self:loadMiniCannonImage()
	images["title"] = self:loadTitleImage()
	images["play"] = self:loadPlayImage()
	images["unitA"] = self:loadUnitAImage()
	images["unitB"] = self:loadUnitBImage()
	images["unitC"] = self:loadUnitCImage()
	images["spaceship"] = self:loadSpaceshipImage()
	images["unitAPts"] = self:loadUnitAPtsImage()
	images["unitBPts"] = self:loadUnitBPtsImage()
	images["unitCPts"] = self:loadUnitCPtsImage()
	images["spaceshipPts"] = self:loadSpaceshipPtsImage()
	images["cannon"] = self:loadCannonImages()
	images["invaderUnits"] = self:loadInvaderUnitImages()

	self.images = images


end

function Game:loadImage(coordinates)
	local imgSource = love.image.newImageData(coordinates.w, coordinates.h)
	imgSource:paste(self.spriteBatch.userData, 0, 0, coordinates.spriteX, coordinates.spriteY)
	return love.graphics.newImage(imgSource)
end

function Game:loadMiniCannonImage()
	return self:loadImage(gameConstants.GAME_MINICANNON_COORD)
end

function Game:loadTitleImage()
	return self:loadImage(introConstants.INTRO_TITLE_COORD)
end

function Game:loadPlayImage()
	return self:loadImage(introConstants.INTRO_PLAY_COORD)
end

function Game:loadUnitAImage()
	return self:loadImage(waveConstants.WAVE_UNIT_A_COORD)
end

function Game:loadUnitBImage()
	return self:loadImage(waveConstants.WAVE_UNIT_B_COORD)
end

function Game:loadUnitCImage()
	return self:loadImage(waveConstants.WAVE_UNIT_C_COORD)
end

function Game:loadSpaceshipImage()
	return self:loadImage(waveConstants.WAVE_SPACESHIP_COORD)
end

function Game:loadUnitAPtsImage()
	return self:loadImage(introConstants.INTRO_UNIT_A_PTS_COORD)
end

function Game:loadUnitBPtsImage()
	return self:loadImage(introConstants.INTRO_UNIT_B_PTS_COORD)
end

function Game:loadUnitCPtsImage()
	return self:loadImage(introConstants.INTRO_UNIT_C_PTS_COORD)
end

function Game:loadSpaceshipPtsImage()
	return self:loadImage(introConstants.INTRO_SPACESHIP_PTS_COORD)
end


function Game:loadSounds()

	local sounds = {}
	sounds["cannonDeath"] = self:loadCannonDeathSound()
	sounds["cannonShot"] = self:loadCannonShotSound()

	sounds["invaderDeath"] = self:loadInvaderDeathSound()
	sounds["invaderShot"] = self:loadInvaderShotSound()

	sounds["spaceshipDeath"] = self:loadSpaceshipDeathSound()
	sounds["spaceshipTravel"] = self:loadSpaceshipTravelSound()

	self.sounds = sounds

end

function Game:loadSound(file, volume, pitch)

	local volume = volume or 1
	local pitch = pitch or 1
	local sound = love.audio.newSource(file, static)
	sound:setVolume(volume)
	sound:setPitch(pitch)
	return sound

end


function Game:loadCannonShotSound()
	local filePath = cannonConstants.CANNON_SHOT_SOUND
	local volume = cannonConstants.CANNON_SHOT_SOUND_VOLUME
	local pitch = cannonConstants.CANNON_SHOT_SOUND_PITCH
	return self:loadSound(filePath, volume, pitch)
end

function Game:loadCannonDeathSound()
	local filePath = cannonConstants.CANNON_DEATH_SOUND
	local volume = cannonConstants.CANNON_DEATH_SOUND_VOLUME
	local pitch = cannonConstants.CANNON_DEATH_SOUND_PITCH
	return self:loadSound(filePath, volume, pitch)
end

function Game:loadInvaderShotSound()
	local filePath = invaderConstants.INVADER_SHOT_SOUND
	local volume = invaderConstants.INVADER_SHOT_SOUND_VOLUME
	local pitch = invaderConstants.INVADER_SHOT_SOUND_PITCH
	return self:loadSound(filePath, volume, pitch)
end

function Game:loadInvaderDeathSound()
	local filePath = invaderConstants.INVADER_DEATH_SOUND
	local volume = invaderConstants.INVADER_DEATH_SOUND_VOLUME
	local pitch = invaderConstants.INVADER_DEATH_SOUND_PITCH
	return self:loadSound(filePath, volume, pitch)
end

function Game:loadSpaceshipTravelSound()
	local filePath = spaceshipConstants.SPACESHIP_TRAVEL_SOUND
	local volume = spaceshipConstants.SPACESHIP_TRAVEL_SOUND_VOLUME
	local pitch = spaceshipConstants.SPACESHIP_TRAVEL_SOUND_PITCH
	return self:loadSound(filePath, volume, pitch)
end

function Game:loadSpaceshipDeathSound()
	local filePath = spaceshipConstants.SPACESHIP_DEATH_SOUND
	local volume = spaceshipConstants.SPACESHIP_DEATH_SOUND_VOLUME
	local pitch = spaceshipConstants.SPACESHIP_DEATH_SOUND_PITCH
	return self:loadSound(filePath, volume, pitch)
end

function Game:placeShields()

	local leftMargin, rightMargin = shieldConstants.SHIELD_LATERAL_MARGINS, shieldConstants.SHIELD_LATERAL_MARGINS
	local numShields = shieldConstants.SHIELD_NUM_SHIELDS

	local wCanvas = love.graphics.getWidth() - leftMargin - rightMargin
	local hCanvas = love.graphics.getHeight()

	local shieldSector = wCanvas / numShields

	-- posiciona os escudos
	shields = {}
	for i = 1, numShields do
		thisShield = ShieldBuilder:new()
		local halfGap = (shieldSector - thisShield.width) / 2
		local sectorCorner = (i-1) * shieldSector
		local shieldHeight = thisShield.height
		local cannonHeight = cannonConstants.CANNON_HEIGHT
		local spaceBetweenShieldAndCannon = shieldConstants.SHIELD_BOTTOM_MARGIN

		local newX = math.floor(leftMargin + sectorCorner + halfGap)
		local newY = math.floor(hCanvas - spaceBetweenShieldAndCannon - cannonHeight - thisShield.height)

		thisShield.pos.x = newX
		thisShield.pos.y = newY

		thisShield:placeBlocks()

		shields[i] = thisShield
	end

	return shields

end

function Game:addPointsToScore(points)

	self.score = self.score + points

	local pointsSinceLastLife = self.score - self.lastExtraLife

	if pointsSinceLastLife > 1000 then
		self.lives = self.lives + 1
		self.lastExtraLife = math.floor(self.score - (self.score%1000))
	end

end

function Game:printScore()

	love.graphics.setFont(self.font)

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print("SCORE",32,16)

	love.graphics.setColor(0, 255, 0, 255)
	love.graphics.print(self.score,100,16)

	love.graphics.setColor(255, 255, 255, 255)

end

function Game:showLives()

	local lives = self.lives - 1
	local x = 400

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print("LIVES",320,16)

	love.graphics.setColor(255, 255, 255, 255)
	if lives <  6 then
		for i=1, lives do
			love.graphics.draw(self.images.miniCannon, x + (32 * i), 16, 0, 1, 1, 0, 0)
		end
	else
		love.graphics.draw(self.images.miniCannon, x, 16, 0, 1, 1, 0, 0)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.print("X " .. lives,x + 40 ,16)
	end
end

function Game:loadCannonImages()

	local baseCoordinates = cannonConstants.CANNON_IMAGE_COORD
	local spriteX = baseCoordinates.spriteX
	local spriteY = baseCoordinates.spriteY
	local regionWidth = baseCoordinates.w
	local regionHeight = baseCoordinates.h

	local imgSource = {}
	local imgArray = {}


	for i = 1, cannonConstants.CANNON_MOTION_STEPS do
		local coordinates = {spriteX=0, spriteY=0, w=0, h=0}
		coordinates.spriteX = ((i-1) * baseCoordinates.w) + baseCoordinates.spriteX
		coordinates.spriteY = baseCoordinates.spriteY
		coordinates.w = baseCoordinates.w
		coordinates.h = baseCoordinates.h
		imgArray[i] = self:loadImage(coordinates)
	end

	return imgArray
end

function Game:loadInvaderUnitImages()

	local units = {waveConstants.WAVE_UNIT_A_COORD, waveConstants.WAVE_UNIT_B_COORD, waveConstants.WAVE_UNIT_C_COORD}
	local imgArray = {}
	local index = 0


	for i,v in ipairs(units) do

		local unitCoordinates = v
		local spriteX = unitCoordinates.spriteX
		local spriteY = unitCoordinates.spriteY
		local regionWidth = unitCoordinates.w
		local regionHeight = unitCoordinates.h
		local imgSource = {}

		for j = 1, waveConstants.WAVE_UNIT_MOTION_STEPS do
			index = index + 1
			local coordinates = {spriteX=0, spriteY=0, w=0, h=0}
			coordinates.spriteX = ((j-1) * unitCoordinates.w) + unitCoordinates.spriteX
			coordinates.spriteY = unitCoordinates.spriteY
			coordinates.w = unitCoordinates.w
			coordinates.h = unitCoordinates.h
			imgArray[index] = self:loadImage(coordinates)
		end

	end

	return imgArray

end
