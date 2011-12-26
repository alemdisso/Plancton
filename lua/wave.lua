require ("lua.class")
require ("lua.drawable")
require ("lua.updatable")


waveList = {}
waveListRemove = {}

Wave = {}

WaveBuilder = createClass(Wave, Updatable)


function Wave:new()

	waveList[#waveList+1] = self

	self:loadInvadersImages()
	self:loadSpaceshipImages()
	self:initFormation()
	print (self.availableSpaceships)
	self:engage()

	return self
end


function Wave:destroy()
	self.active = false
	waveListRemove[#waveListRemove+1] = self
end


function Wave:draw()

end

function Wave:update(dt)


	if self:stillFighting() then

		local direction = self.direction
		local speedX = self.speedX
		local step = speedX * dt


		if direction == "left" then step = step * -1 end

		if self:shotOnTarget() then
			self.haltCommand = true
		else
			self.haltCommand = false
		end

		self:findAndRemoveDeadUnits()
		self:findLateralLimits()
		self:findSpearHeads()
		shiftMovement = self:planMove(step)
		self:moveUnits(shiftMovement, step)

		local delayToNextSpaceship = self.delayToNextSpaceship
		local availableSpaceships = self.availableSpaceships

		if self.delayToNextSpaceship <= 0  and availableSpaceships > 0 then
			self:launchSpaceship()
			print (availableSpaceships)
			self.delayToNextSpaceship = math.random(waveConstants.WAVE_SPACESHIP_MIN_DELAY, waveConstants.WAVE_SPACESHIP_MAX_DELAY)
			self.availableSpaceships = self.availableSpaceships - 1
		else
			self.delayToNextSpaceship = self.delayToNextSpaceship - dt
		end
	else
		WaveBuilder:destroy(self)
	end



end



function Wave:loadInvadersImages()

	self.invaderImages = game.images.invaderUnits
	self:findWiderUnit()

end

function Wave:createUnitMotionStepsRegions(x, y, w, h)
	for i = 1, waveConstants.WAVE_UNIT_MOTION_STEPS do
		local newRegion = RegionClass.new(((i-1) * w) + x, y, w, h)
		table.insert(self.invaderRegions, newRegion)
	end
end

function Wave:loadUnitsImagesFromSprite()

	local invaderRegions = self.invaderRegions
	local invaderImgSource = {}
	local invaderImgArray = {}
	for i = 1, #invaderRegions do
		local region = invaderRegions[i]
		invaderImgSource[i] = spriteBatch:cutRegionIntoImage(region)
	end

	return invaderImgSource

end

function Wave:initFormation()

	local numLines = self.numLines or 1
	local numColumns = self.numColumns or 1

	local formation = {}
	local spearHeads= {}

	for i=1,self.numLines do
		spearHeads[i] = 0
		formation[i] = {}
		for j=1, self.numColumns do
			formation[i][j] = false
		end
	end

	self.invaders = invaders or {}
	self.formation = formation

	self.spearHeads = spearHeads
	self.numLines = numLines
	self.numColumns = numColumns

	self.pos = {x=0, y=0, z=3}

	self.maxX = self.width
	self.minX = 0
	self.maxY = self.height
	self.direction = "right"
	self.speedX = self.speedX or waveConstants.WAVE_SPEED_X
	self.speedY = self.speedY or waveConstants.WAVE_SPEED_Y

	self.availableSpaceships = waveConstants.WAVE_MAX_SPACESHIPS

end


function Wave:engage()

	self.pos.x = waveConstants.WAVE_INITIAL_X
	self.pos.y = waveConstants.WAVE_INITIAL_Y
	self.invaders = {}
	for line = 1, self.numLines do
		for column = 1, self.numColumns do
			self.invaders = self:placeInvader(column, line)
		end
	end

	self.delayToNextSpaceship = math.random(waveConstants.WAVE_SPACESHIP_MIN_DELAY, waveConstants.WAVE_SPACESHIP_MAX_DELAY)


	return self

end


function Wave:shotOnTarget()

	local game = game
	local shotOnTarget = false

	if game.state == gameConstants.GAME_EXPLOSION_MODE then
		shotOnTarget = true
	end

	return shotOnTarget
end


function Wave:findAndRemoveDeadUnits()

	local toRemove = self:findUnitsToRemove()

	self:removeDeadUnits(toRemove)

	for i=1, #toRemove do
		for j=1, #self.invaders do
			if self.invaders[j] == toRemove[i] then
				self.formation[self.invaders[j].line][self.invaders[j].column] = false
				table.remove(self.invaders, j)
				break
			end
		end
		toRemove[i] = nil
	end
end

function Wave:findUnitsToRemove()

	local toRemove = {}

	for k,v in ipairs(self.invaders) do
		local thisInvader = v
		if not thisInvader.active then
			table.insert(toRemove, thisInvader)
		end
	end

	return toRemove
end


function Wave:removeDeadUnits(toRemove)

	for i=1, #toRemove do
		for j=1, #self.invaders do
			if self.invaders[j] == toRemove[i] then
				self.formation[self.invaders[j].line][self.invaders[j].column] = false
				table.remove(self.invaders, j)
				break
			end
		end
		toRemove[i] = nil
	end

end


function Wave:findLateralLimits()

	local minFound = game.hCanvas
	local maxFound = 0

	for k,v in ipairs(self.invaders) do
		local thisInvader = v
		if thisInvader.active then
			if thisInvader.pos.x < minFound then minFound = thisInvader.pos.x end
			if thisInvader.pos.x > maxFound then maxFound = thisInvader.pos.x end
		end
	end

	if minFound ~= self.minX then self.minX = minFound end
	if maxFound ~= self.maxX then self.maxX = maxFound end

end

function Wave:findSpearHeads()

	local spearHeads = {}

	for i = 1, self.numColumns do
		spearHeads[i] = 0
	end

	for k,v in ipairs(self.invaders) do
		local thisInvader = v
		if thisInvader.active then
			if thisInvader.line > spearHeads[thisInvader.column] then
				spearHeads[thisInvader.column] = thisInvader.line
			end
		end
	end

	self.spearHeads = spearHeads

end


function Wave:planMove(step)

	local direction = self.direction
	local newDirection = direction
	local shiftMovement = true

	if self:spaceToShift(step) then
		-- move wave
		shiftMovement = true
	else
		-- if reached limit, line down and change direction
		shiftMovement = false
		if direction == "left" then
			newDirection = "right"
		else
			newDirection = "left"
		end
		if newDirection ~= self.direction then
			self.direction = newDirection
		end
	end

	return shiftMovement

end


function Wave:spaceToShift(pace)

	local canvasMargin = 5
	local leftProtection = 0
	local rightProtection = self.width + canvasMargin


	local direction = self.direction
	local newMaxX = self.maxX + pace + rightProtection
	local newMinX = self.minX + pace - leftProtection
	local wCanvas = game.wCanvas - canvasMargin
	local spaceToShift = false


	if direction == "right" then
		if newMaxX <= wCanvas then spaceToShift = true end
	else
		if newMinX >= 0 then spaceToShift = true end
	end

	return spaceToShift

end


function Wave:moveUnits(shiftMovement, step)

	for i, v in ipairs(self.invaders) do
		local thisInvader = v

		if thisInvader.active  then

			local posX = thisInvader.pos.x
			local posY = thisInvader.pos.y

			if shiftMovement then
				local newX = posX + step
				thisInvader:move(newX, posY)
			else
				local newY = posY + self.speedY
				thisInvader:move(posX, newY)
				local yReached = newY + thisInvader.height
				if yReached > self.maxY then
					self.maxY = yReached
				end
			end
		end
	end
end

function Wave:placeInvader(column, line)

	local firstBlock = math.ceil((self.numLines * 0.2))
	local secondBlock = math.ceil((self.numLines * 0.6))
	local unitImgArray = {}
	local unitType = nil
	local invaderImages = self.invaderImages

	local faster = nil
	local level = nil
	local waveCount = #waveList
	if waveCount > 10 then
		faster = true
		level = game.gameLevels[10]
		self.speedX = level.speedX
		self.speedY = level.speedY
	else
		faster = false
		level = game.gameLevels[waveCount]
		self.speedX = level.speedX
		self.speedY = level.speedY
	end

	if line <= firstBlock then
		unitType = waveConstants.WAVE_INVADER_A
		unitType.minDelay = level.delays[1]
		unitType.maxDelay = level.delays[2]
		unitImgArray[1] = invaderImages[1]
		unitImgArray[2] = invaderImages[2]
	elseif line <= secondBlock then
		unitType = waveConstants.WAVE_INVADER_B
		unitType.minDelay = level.delays[3]
		unitType.maxDelay = level.delays[4]
		unitImgArray[1] = invaderImages[3]
		unitImgArray[2] = invaderImages[4]
	else
		unitType = waveConstants.WAVE_INVADER_C
		unitType.minDelay = level.delays[5]
		unitType.maxDelay = level.delays[6]
		unitImgArray[1] = invaderImages[5]
		unitImgArray[2] = invaderImages[6]
	end

	local newInvader = InvaderBuilder:new(
					{
						imgArray = unitImgArray,
						invaderBatch = game.spriteBatch,
						wave = self,
						line = line,
						column = column,
						unitType = unitType
					}
				)

	table.insert(self.invaders, newInvader)
	if newInvader.pos.x > self.maxX then self.maxX = newInvader.pos.x end
	if newInvader.pos.x < self.minX then self.minX = newInvader.pos.x end

	if newInvader.pos.y > self.maxY then self.maxY = newInvader.pos.y end

	return self.invaders

end


function Wave:findWiderUnit()


	local invaderImages = self.invaderImages

	local widerUnitWidth = 0

	for i,v in ipairs(invaderImages) do
		local imgInvader = v
		local thisWidth = 	imgInvader:getWidth()
		if thisWidth > widerUnitWidth then
			widerUnitWidth = thisWidth
			widerUnitHeight = imgInvader:getHeight()
			self.img = imgInvader
		end
	end

	self.width = widerUnitWidth
	self.height = widerUnitHeight

end


function Wave:loadSpaceshipImages()

	local spriteBatch = game.spriteBatch

	self.spaceshipRegions = {}

	local spaceships = {waveConstants.WAVE_SPACESHIP}

	for i,v in ipairs(spaceships) do
		local spaceshipCoordinates = v
		self:createSpaceshipMotionStepsRegions(spaceshipCoordinates.x,
									spaceshipCoordinates.y,
									spaceshipCoordinates.w,
									spaceshipCoordinates.h
									)
	end

	spaceshipImgSource = self:loadSpaceshipsImagesFromSprite()
	self.spaceshipImgSource = spaceshipImgSource

	return spaceshipImgSource

end


function Wave:createSpaceshipMotionStepsRegions(x, y, w, h)
	for i = 1, waveConstants.WAVE_SPACESHIP_MOTION_STEPS do
		local newRegion = RegionClass.new(((i-1) * w) + x, y, w, h)
		table.insert(self.spaceshipRegions, newRegion)
	end
end

function Wave:loadSpaceshipsImagesFromSprite()

	local spaceshipRegions = self.spaceshipRegions
	local spaceshipImgSource = {}
	local spaceshipImgArray = {}
	local spriteBatch = game.spriteBatch
	for i = 1, #spaceshipRegions do
		local region = spaceshipRegions[i]
		spaceshipImgSource[i] = spriteBatch:cutRegionIntoImage(region)
	end

	return spaceshipImgSource

end

function Wave:launchSpaceship()

	local newSpaceship = SpaceshipBuilder:new(
					{
						imgSourceArray = self.spaceshipImgSource,
					}
				)

end

function Wave:stillFighting()

	local headCount = #self.invaders
	if headCount > 0 then
		return true
	else
		return false
	end

end

function Wave:stopFire(command)

	if command == nil then
		return self.stopFire
	else
		self.stopFire = command
		return self.stopFire

	end
end

function Wave:dumpFormationAndSpearHeads()

	for i,v in ipairs(self.formation) do
		local stringLine = ""
		local lineFormation = v
		for j,u in ipairs(lineFormation) do
			local position = u
			local charPosition = ""
			if position == true then
				charPosition = "X"
			elseif position == false then
				charPosition = "0"
			else
				charPosition = "?"
			end

			if self.spearHeads[j] == i then
				charPosition = "V"
			end
			stringLine = stringLine .. charPosition .." "
			print ("spearHead coluna " .. j .. " = " .. self.spearHeads[j] .. "minha linha eh " .. i)
		end
			print (stringLine)
	end
end
