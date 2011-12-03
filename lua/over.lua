
overList = {}
overListRemove = {}

Over = {}

OverBuilder = createClass(Over)


function Over:new()

	overList[#overList+1] = self

	self.overImages = self:loadImages()

	return self
end


function Over:destroy()
	self.active = false
	overListRemove[#overListRemove+1] = self
end


function Over:draw()

end

function Over:update(dt)
	if game.state == gameConstants.GAME_OVER then
		if love.mouse.isDown("l") then

			local overImages = self.overImages
			local x,y = love.mouse.getPosition()
			if x >= 160 and x <= 400
				and y >= 150 and y <= 300 then


				updatableList = {}
				drawableList = {}
				--collisionManager.collisionTables={}
				waveList={}
				invaderList = {}
				cannonList = {}
				shieldList = {}
				blockList = {}
				bulletList={}

				game.score = 0
				game.lives = 3
				game.state = 1

				cannon = CannonBuilder:new()
				shields = game:placeShields()
				wave = WaveBuilder:new(
					{
						numLines = waveConstants.WAVE_LINES,
						numColumns = waveConstants.WAVE_COLUMNS,
					}
				)

				collisionManager = prepareCollisionTables()

			elseif x >= 160 and x <= 400
				and y >= 320 and y <= 500 then

				love.event.push("q")
			end
		end

	end
end

function Over:loadImages()

	local overImages = {
		["title"] = {img={}, x=0, y=0,},
		["keyboard"] = {img={}, x=0, y=0,},
		["mouse"] = {img={}, x=0, y=0,},
		}

	local titleSprite = SpriteClass.new(overConstants.OVER_TITLE_SPRITE)
	local titleImgSource = love.image.newImageData(overConstants.OVER_TITLE_COORD.w, overConstants.OVER_TITLE_COORD.h)
	titleImgSource:paste(titleSprite.userData, 0, 0, 0, 0)
	overImages.title.img = love.graphics.newImage(titleImgSource)
	overImages.title.x = overConstants.OVER_TITLE_COORD.x
	overImages.title.y = overConstants.OVER_TITLE_COORD.y

	local keyboardSprite = SpriteClass.new(overConstants.OVER_KEYBOARD_SPRITE)
	local keyboardImgSource = love.image.newImageData(overConstants.OVER_KEYBOARD_COORD.w, overConstants.OVER_KEYBOARD_COORD.h)
	keyboardImgSource:paste(keyboardSprite.userData, 0, 0, 0, 0)
	overImages.keyboard.img = love.graphics.newImage(keyboardImgSource)
	overImages.keyboard.x = overConstants.OVER_KEYBOARD_COORD.x
	overImages.keyboard.y = overConstants.OVER_KEYBOARD_COORD.y

	local mouseSprite = SpriteClass.new(overConstants.OVER_MOUSE_SPRITE)
	local mouseImgSource = love.image.newImageData(overConstants.OVER_MOUSE_COORD.w, overConstants.OVER_MOUSE_COORD.h)
	mouseImgSource:paste(mouseSprite.userData, 0, 0, 0, 0)
	overImages.mouse.img = love.graphics.newImage(mouseImgSource)
	overImages.mouse.x = overConstants.OVER_MOUSE_COORD.x
	overImages.mouse.y = overConstants.OVER_MOUSE_COORD.y


	return overImages
end




function Over:showOptions()


	local font = love.graphics.newFont(gameConstants.GAME_FONT, 48)
	love.graphics.setFont(font)

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print("PLAY AGAIN",160, 200)

	love.graphics.print("TERMINAR",160, 320)

	love.graphics.setColor(255, 255, 255, 255)




end


