require ("lua.plancton-constants")
require ("lua.class")
require ("lua.game")
require ("lua.intro")
require ("lua.over")
require ("lua.region")
require ("lua.sprite")
require ("lua.cannon")
require ("lua.bullet")
require ("lua.shield")
require ("lua.block")
require ("lua.invader")
require ("lua.spaceship")
require ("lua.wave")
require ("lua.collisionmanager")


function love.load()

	game = GameBuilder:new()

	spriteBatch = game.spriteBatch
	gameState = game.state
	bg = game.bg
	font = game.font
	intro = IntroBuilder:new()
	over = OverBuilder:new()

	cannon = CannonBuilder:new()
	shields = game:placeShields()
	wave = WaveBuilder:new(
		{
			numLines = waveConstants.WAVE_LINES,
			numColumns = waveConstants.WAVE_COLUMNS,
		}
	)
	delayToNextWave = waveConstants.WAVE_DELAY_TO_NEXT_WAVE

	collisionManager = prepareCollisionTables()

end


function love.draw()

	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(bg)
	if game.state == gameConstants.GAME_OVER then
		over:showOptions()

	elseif game.state == gameConstants.GAME_INTRO then

		xTitle = (game.wCanvas - introConstants.INTRO_TITLE_COORD.w) / 2
		love.graphics.draw(game.images.title, xTitle, 32)

		xPlay = (game.wCanvas - introConstants.INTRO_PLAY_COORD.w) / 2
		love.graphics.draw(game.images.play, xTitle, game.hCanvas - 80)

		local stepIntro = 0.61
		local xUnits = xTitle + 100
		local xPts = xUnits + 40

		if (intro.timeCounter > (stepIntro)) then
			love.graphics.draw(game.images.unitC, xUnits,  180)
			if (intro.timeCounter > (stepIntro * 2)) then
				love.graphics.draw(game.images.unitCPts, xPts,  180 + 9)
				if (intro.timeCounter > (stepIntro * 3)) then
					love.graphics.draw(game.images.unitB, xUnits,  230)
					if (intro.timeCounter > (stepIntro * 4)) then
						love.graphics.draw(game.images.unitBPts, xPts,  230 + 9)
						if (intro.timeCounter > (stepIntro * 5)) then
							love.graphics.draw(game.images.unitA, xUnits,  280)
							if (intro.timeCounter > (stepIntro * 6)) then
								love.graphics.draw(game.images.unitAPts, xPts,  280 + 9)
								if (intro.timeCounter > (stepIntro * 7)) then
									love.graphics.draw(game.images.spaceship, xUnits,  330)
									if (intro.timeCounter > (stepIntro * 8)) then
										love.graphics.draw(game.images.spaceshipPts, xPts,  330 + 5)
									end
								end
							end
						end
					end
				end
			end
		end

	else


		for i=1, #drawableList do
			drawableList[i]:draw()
		end

		game:printScore()
		game:showLives()

	end

end

function love.update(dt)

	if game.state == gameConstants.GAME_INTRO then
		intro:update(dt)

	elseif  game.state == gameConstants.GAME_OVER then
		over:update()

	else
		for i=1, #updatableList do
			updatableList[i]:update(dt)
		end

		removeItems(updateListRemove, updatableList)
		removeItems(drawableListRemove, drawableList)
		removeItems(gameListRemove, gameList)
		removeItems(spaceshipListRemove, spaceshipList)
		removeItems(bulletListRemove, bulletList)
		removeItems(blockListRemove, blockList)
		removeItems(invaderListRemove, invaderList)
		removeItems(cannonListRemove, cannonList)

		if #invaderList == 0 then

			if delayToNextWave <= 0 then
				wave = WaveBuilder:new(
					{
						numLines = waveConstants.WAVE_LINES,
						numColumns = waveConstants.WAVE_COLUMNS,
					}
				)
				delayToNextWave = waveConstants.WAVE_DELAY_TO_NEXT_WAVE
			else
				delayToNextWave = delayToNextWave - dt

			end

		end
		if #cannonList == 0 then
			if game.lives > 1 then
				cannon = CannonBuilder:new()
				game.lives = game.lives - 1
			else
				for i,w in ipairs(waveList) do
					for i,v in ipairs(w.invaders) do
						v.active = false
					end
				end

				game.state = gameConstants.GAME_OVER
			end
		else
			local cannon = cannonList[1]
			local exploding = cannon.exploding
			if exploding == true then
				game.state = gameConstants.GAME_EXPLOSION_MODE
			else
				game.state = gameConstants.GAME_PLAY_KEYBOARD
			end

		end
	end

end

function love.keypressed(k)

	if game.state == gameConstants.GAME_PLAY_KEYBOARD then
		if k == " " then
			if #cannonList > 0 then
				cannon:shoot()
			end
		end
	end

	if k == "." then
		--collisionManager:updateWhenIAsk()
		--wave:findLateralLimits()
		dumpNumWaves()
		--wave:dumpFormationAndSpearHeads()
		print (#spaceshipList)
	end

	if k == "escape" then
		love.event.push("q")
	end

	if game.state == gameConstants.GAME_INTRO then
		if k == " " or k == "return" then
			game.state = gameConstants.GAME_PLAY_KEYBOARD
		else
			print (k)
		end
	end

end




function removeItems(itemsToRemove, source)
	for i=1, #itemsToRemove do
		--print ("antes # source = " .. #source)
		for j=1, #source do
			if source[j] == itemsToRemove[i] then
				table.remove(source, j)
				--print ("Remove " .. j)
				break
			end
		end
		--print ("depois # source = " .. #source)
		itemsToRemove[i] = nil
	end
end





function love.mousepressed(x, y, button)

	if game.state == gameConstants.GAME_PLAY_MOUSE then
		if button == "l" or button == "r" then cannon:shoot() end

	end



	--[[
	for _, s in ipairs(shields) do
		if x > s.pos.x and x < s.pos.x + s.width and
			y > s.pos.y and y < s.pos.y + s.height then

			s.dragging.active = true
			s.dragging.diffx = x - s.pos.x
			s.dragging.diffy = y - s.pos.y
			break

		end
	end

	]]





end



function drawIntro()

	love.graphics.draw(titleImage)
	love.graphics.draw(menuMouse)
	love.graphics.draw(menuKeyboard)



end




function prepareCollisionTables()

	local collisionManager = CollisionManagerBuilder:new()
	collisionManager:addCollisionTables(blockList, bulletList)
	collisionManager:addCollisionTables(cannonList, bulletList)
	collisionManager:addCollisionTables(invaderList, bulletList)
	collisionManager:addCollisionTables(invaderList, cannonList)
	collisionManager:addCollisionTables(spaceshipList, bulletList)

	return collisionManager


end




function dumpNumWaves()


print ("waves: " ..#waveList)
print ("invaders: " ..#invaderList)


end


