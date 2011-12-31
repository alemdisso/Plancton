require ("lua.class")
require ("lua.drawable")
require ("lua.updatable")

waveList = {}
waveListRemove = {}

Wave = {}

WaveBuilder = createClass(Wave, Updatable)

function Wave:new()

	waveList[#waveList+1] = self

	self:initTimeline()
	self:loadImages()
	self:getReadyAndGo()

	return self
end

function Wave:initTimeline()

	self.timelineCounter = self:newAndRunningProgressiveCounter()
	self.currentTimelineStep = 0
	self.completeFormation = false

end

function Wave:loadImages()

	self:loadInvadersImages()
	self:loadSpaceshipImages()

end

function Wave:getReadyAndGo()

	self:prepareFormation()
	self:engage()

end

function Wave:newAndRunningProgressiveCounter()

	local myCounter = CounterBuilder:new()
	myCounter:time(0)
	myCounter:start()

	return myCounter

end

function Wave:loadInvadersImages()

	self.invaderImages = game.images.invaderUnits
	self:findWiderUnit()

end

function Wave:loadSpaceshipImages()

	self.spaceshipImage = game.images.spaceship

end

function Wave:prepareFormation()

	self:initFormation()
	self:setPosition()
	self:prepareToMove()
	self:enrollSpaceships()

end

function Wave:engage()

	self.invaders = {}
	for line = 1, self.numLines do
		for column = 1, self.numColumns do
			self.invaders = self:placeInvader(column, line)
		end
	end

	self.delayToNextSpaceship = math.random(waveConstants.WAVE_SPACESHIP_MIN_DELAY, waveConstants.WAVE_SPACESHIP_MAX_DELAY)

	return self

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

	self.invaders = {}
	self.formation = formation
	self.spearHeads = spearHeads

end

function Wave:setPosition()

	self.pos = {x = waveConstants.WAVE_INITIAL_X, y = waveConstants.WAVE_INITIAL_Y}

	self.maxX = self.width
	self.minX = 0
	self.maxY = self.height

end

function Wave:prepareToMove()

	self.direction = "right"
	self.speedX = self.speedX or waveConstants.WAVE_SPEED_X
	self.speedY = self.speedY or waveConstants.WAVE_SPEED_Y
	self.attackingShield = false

end

function Wave:enrollSpaceships()

	local maxArray = waveConstants.WAVE_MAX_SPACESHIPS_ARRAY
	local seedMax = math.random(#maxArray)
	self.availableSpaceships = maxArray[seedMax]

end

function Wave:destroy()
	self.active = false
	waveListRemove[#waveListRemove+1] = self
end

function Wave:draw()

end

function Wave:update(dt)

	if not self:isFormationAlreadyCompleted() then
		self:watchTimelineStep()
	elseif self:stillFighting() then
		self:manageLogistics(dt)
	else
		WaveBuilder:destroy(self)
	end

end

function Wave:isFormationAlreadyCompleted()

	if self:stillPlacingLines() then
		self.completeFormation = false
	else
		self.completeFormation = true
	end

	return self.completeFormation

end


function Wave:watchTimelineStep()
	local stepFormation = 0.17
	local timeCounter = self.timelineCounter
	local currentTime = timeCounter:time()
	local newTimelineStep = math.floor(currentTime /stepFormation)

	if newTimelineStep ~= currentTimelineStep then
		self.currentTimelineStep = newTimelineStep
	end

end

function Wave:stillFighting()

	local headCount = #self.invaders
	if headCount > 0 then
		return true
	else
		return false
	end

end

function Wave:manageLogistics(dt)

	local movementStep = self:calculateMovementStep(dt)

	self:checkIfShotOnTarget()

	self:findAndRemoveDeadUnits()
	self:findLateralLimits()
	self:findSpearHeads()
	local shiftMovement = self:planMove(movementStep)
	self:moveUnits(shiftMovement, movementStep)

	self:manageSpaceships(dt)

end


function Wave:stillPlacingLines()

	local waveLines = waveConstants.WAVE_LINES
	local currentTimelineStep = self.currentTimelineStep
	if currentTimelineStep < waveLines then
		return true
	else
		return false
	end

end

function Wave:calculateMovementStep(dt)

	local direction = self.direction
	local speedX = self.speedX
	local step = speedX * dt

	if direction == "left" then step = step * -1 end

	if self.attackingShield == true then
		step = step * 0.4
		end

	self.attackingShield = false

	return step

end

function Wave:checkIfShotOnTarget()

	local game = game
	local shotOnTarget = false

	if game.state == gameConstants.GAME_EXPLOSION_MODE then
		shotOnTarget = true
		self.haltCommand = true
	else
		self.haltCommand = false
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
			newDirection =	 "right"
		else
			newDirection = "left"
		end
		if newDirection ~= self.direction then
			self.direction = newDirection
		end
	end

	return shiftMovement

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

function Wave:manageSpaceships(dt)

	local delayToNextSpaceship = self.delayToNextSpaceship
	local availableSpaceships = self.availableSpaceships
	local spaceshipsEngaged = #spaceshipList

	if self.waitToPrepareNextSpaceship == true and spaceshipsEngaged == 0 then
		delayToNextSpaceship = math.random(waveConstants.WAVE_SPACESHIP_MIN_DELAY, waveConstants.WAVE_SPACESHIP_MAX_DELAY)
		self.waitToPrepareNextSpaceship = false
	end

	if spaceshipsEngaged == 0 and delayToNextSpaceship <= 0 and availableSpaceships > 0 then
		self.waitToPrepareNextSpaceship = true
		self:launchSpaceship()
		self.availableSpaceships = self.availableSpaceships - 1

	else
		delayToNextSpaceship = delayToNextSpaceship - dt
	end

	self.delayToNextSpaceship = delayToNextSpaceship

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

function Wave:placeInvader(column, line)

	local game = game or GameBuilder:new()
	local backEndBlock = math.ceil((self.numLines * 0.2))
	local middleBlock = math.ceil((self.numLines * 0.6))
	local unitImgArray = {}
	local unitType = nil
	local invaderImages = self.invaderImages

	local level = game:currentLevel()

	self:setSpeed(level)
	unitType = self:prepareUnitType(line, level)

	local newInvader = InvaderBuilder:new(
					{
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

function Wave:imagesFor(block)
	local unitImgArray = {}
	local invaderImages = self.invaderImages

	if block == 'back' then
		unitImgArray[1] = invaderImages[1]
		unitImgArray[2] = invaderImages[2]
	elseif block == 'middle' then
		unitImgArray[1] = invaderImages[3]
		unitImgArray[2] = invaderImages[4]
	else
		unitImgArray[1] = invaderImages[5]
		unitImgArray[2] = invaderImages[6]
	end

	return unitImgArray

end

function Wave:setSpeed(level)
	self.speedX = level.speedX
	self.speedY = level.speedY
end

function Wave:prepareUnitType(line, level)

	local backEndBlock = math.floor((self.numLines * waveConstants.WAVE_PERC_BACK_LINES))
	local nonFrontPercentual = 1 - waveConstants.WAVE_PERC_FRONT_LINES
	local middleBlock = math.floor((self.numLines * nonFrontPercentual))
	local unitType = nil

	if line <= backEndBlock then
		unitType = self:newBackEndUnitType(level)
	elseif line <= middleBlock then
		unitType = self:newMiddleUnitType(level)
	else
		unitType = self:newFrontEndUnitType(level)
	end

	return unitType




end

function Wave:newBackEndUnitType(level)
	local unitType = waveConstants.WAVE_INVADER_A
	unitType.minDelay = level.delays[1]
	unitType.maxDelay = level.delays[2]
	unitType.motionImagesArray = self:imagesFor('back')

	return unitType
end

function Wave:newMiddleUnitType(level)

	local unitType = waveConstants.WAVE_INVADER_B
	unitType.minDelay = level.delays[3]
	unitType.maxDelay = level.delays[4]
	unitType.motionImagesArray = self:imagesFor('middle')
	return unitType
end

function Wave:newFrontEndUnitType(level)

	local unitType = waveConstants.WAVE_INVADER_C
	unitType.minDelay = level.delays[5]
	unitType.maxDelay = level.delays[6]
	unitType.motionImagesArray = self:imagesFor('front')
	return unitType
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

function Wave:launchSpaceship()

	local newSpaceship = SpaceshipBuilder:new(
					{
					imgSourceArray = self.spaceshipImage,
					}
				)

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


function Wave:newStoppedRegressiveCounter()

	--print ("time " .. time)
	local myCounter = CounterBuilder:new({countMode="down"})
	myCounter:time(0)

	myCounter:start()

	return myCounter

end

