
introList = {}
introListRemove = {}

Intro = {}

IntroBuilder = createClass(Intro, Updatable, Drawable)


function Intro:new()
	introList[#introList+1] = self

	self.timeCounter = introConstants.INTRO_DELAY_TO_SHOW_1ST_UNIT

	return self
end


function Intro:destroy()
	self.active = false
	introListRemove[#introListRemove+1] = self
end


function Intro:draw()

end

function Intro:update(dt)
	self.timeCounter = self.timeCounter + dt
	if game.state == gameConstants.GAME_INTRO then
		if love.mouse.isDown("l") then
			self:checkForClickOnPlayButton()
		end
	end
end

function Intro:checkForClickOnPlayButton()

			local playImage = game.images.play
			local xPlay = introConstants.INTRO_PLAY_BUTTON_COORD.x
			local yPlay = introConstants.INTRO_PLAY_BUTTON_COORD.y
			local x,y = love.mouse.getPosition()
			local w = playImage:getWidth()
			local h = playImage:getHeight()

			if x >= xPlay and x <= xPlay + w
				and y >= yPlay and y <= yPlay + h then
				game.state = gameConstants.GAME_PLAY_KEYBOARD
			end

end

function Intro:showTitle()
	local xTitle = (game.wCanvas - introConstants.INTRO_TITLE_COORD.w) / 2
	love.graphics.draw(game.images.title, xTitle, 32)

end

function Intro:showPlayButton()
	local xTitle = (game.wCanvas - introConstants.INTRO_TITLE_COORD.w) / 2
	local xPlay = (game.wCanvas - introConstants.INTRO_PLAY_COORD.w) / 2
	love.graphics.draw(game.images.play, xTitle, game.hCanvas - 80)
end

function Intro:showUnitsAndPoints()

	local xTitle = (game.wCanvas - introConstants.INTRO_TITLE_COORD.w) / 2
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
end




--[[



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




]]
