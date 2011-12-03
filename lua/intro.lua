
introList = {}
introListRemove = {}

Intro = {}

IntroBuilder = createClass(Intro, Updatable, Drawable)


function Intro:new()

	introList[#introList+1] = self

	self.introImages = self:loadImages()
	self.timeCounter = -2

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

		print ("intro")
			local introImages = self.introImages
			local x,y = love.mouse.getPosition()
			if x >= introImages.play.x and x <= introImages.play.x + introImages.play.img:getWidth()
				and y >= introImages.play.y and y <= introImages.play.y + introImages.play.img:getHeight() then

				game.state = gameConstants.GAME_PLAY_KEYBOARD

			end
		end

	end
end

function Intro:loadImages()

	local introImages = {
		["title"] = {img={}, x=0, y=0,},
		["play"] = {img={}, x=0, y=0,},
		["mouse"] = {img={}, x=0, y=0,},
		}

	introImages.play.img = game.images.play
	introImages.play.x = introConstants.INTRO_PLAY_BUTTON_COORD.x
	introImages.play.y = introConstants.INTRO_PLAY_BUTTON_COORD.y


	--local titleSprite = SpriteClass.new(introConstants.INTRO_TITLE_SPRITE)
	--[[local titleSprite = game.spriteBatch
	local titleImgSource = love.image.newImageData(introConstants.INTRO_TITLE_COORD.w, introConstants.INTRO_TITLE_COORD.h)
	titleImgSource:paste(titleSprite.userData, 0, 0, 0, 0)
	introImages.title.img = love.graphics.newImage(titleImgSource)
	introImages.title.x = introConstants.INTRO_TITLE_COORD.x
	introImages.title.y = introConstants.INTRO_TITLE_COORD.y

	--local keyboardSprite = SpriteClass.new(introConstants.INTRO_KEYBOARD_SPRITE)
	local keyboardSprite = game.spriteBatch
	local keyboardImgSource = love.image.newImageData(introConstants.INTRO_KEYBOARD_COORD.w, introConstants.INTRO_KEYBOARD_COORD.h)
	keyboardImgSource:paste(keyboardSprite.userData, 0, 0, 0, 0)
	introImages.keyboard.img = love.graphics.newImage(keyboardImgSource)
	introImages.keyboard.x = introConstants.INTRO_KEYBOARD_COORD.x
	introImages.keyboard.y = introConstants.INTRO_KEYBOARD_COORD.y

	--local mouseSprite = SpriteClass.new(introConstants.INTRO_MOUSE_SPRITE)
	local mouseSprite = game.spriteBatch
	local mouseImgSource	 = love.image.newImageData(introConstants.INTRO_MOUSE_COORD.w, introConstants.INTRO_MOUSE_COORD.h)
	mouseImgSource:paste(mouseSprite.userData, 0, 0, 0, 0)
	introImages.mouse.img = love.graphics.newImage(mouseImgSource)
	introImages.mouse.x = introConstants.INTRO_MOUSE_COORD.x
	introImages.mouse.y = introConstants.INTRO_MOUSE_COORD.y
]]



	return introImages
end

