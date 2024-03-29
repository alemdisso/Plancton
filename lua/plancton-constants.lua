function protect_table (tbl)
  return setmetatable ({},
    {
    __index = tbl,  -- read access gets original table item
    __newindex = function (t, n, v)
       error ("attempting to change constant " ..
             tostring (n) .. " to " .. tostring (v), 2)
      end -- __newindex
    })

end -- function protect_table


gameConstants =
  {
  GAME_INTRO = 0,
  GAME_PLAY_KEYBOARD = 1,
  GAME_PLAY_MOUSE = 2,
  GAME_OVER = 3,
  GAME_EXPLOSION_MODE = 4,
  GAME_SPRITE = "resources/images/plancton_sprite.png",
  GAME_BG = "resources/images/sea-bg.png",
  --GAME_BG = "resources/images/bg.png",
  GAME_FONT = "resources/fonts/04B_03B_.TTF",
  GAME_FONTSIZE = 18,
  GAME_LIVES = 3,
  GAME_MINICANNON_COORD = {spriteX=220, spriteY=27, w=25, h=23},
  GAME_WCANVAS = 640,
  GAME_HCANVAS = 480,
  GAME_WINDOW_CAPTION = "Planctons Atacam!",
  GAME_LEFT_MARGIN = 12,
  GAME_RIGHT_MARGIN = 12,
  GAME_DELAY_TO_NEXT_CANNON = 2,
  }

gameConstants = protect_table (gameConstants)


introConstants =
  {
  --INTRO_TITLE_SPRITE = "resources/images/title.png",
  --INTRO_MOUSE_SPRITE = "resources/images/mouse.png",
  --INTRO_KEYBOARD_SPRITE = "resources/images/keyboard.png",
  INTRO_TITLE_COORD = {spriteX=0, spriteY=142, w=344, h=87},
  INTRO_UNIT_C_PTS_COORD = {spriteX=0, spriteY=107, w=100, h=15},
  INTRO_UNIT_B_PTS_COORD = {spriteX=104, spriteY=108, w=108, h=15},
  INTRO_UNIT_A_PTS_COORD = {spriteX=0, spriteY=124, w=108, h=15},
  INTRO_SPACESHIP_PTS_COORD = {spriteX=108, spriteY=125, w=122, h=15},
  INTRO_PLAY_COORD = {spriteX=0, spriteY=86, w=340, h=18},
  INTRO_PLAY_BUTTON_COORD = {x=150, y=400, w=340, h=18},
  INTRO_DELAY_TO_SHOW_1ST_UNIT = -2,
  INTRO_MOUSE_COORD = {x=143, y=300, w=474, h=35},
  INTRO_KEYBOARD_COORD = {x=0, y=86, w=216, h=12},

  }

introConstants = protect_table (introConstants)


waveConstants =
  {
  WAVE_INITIAL_X = 32,
  WAVE_INITIAL_Y = 60,
  WAVE_LINES = 5,
  WAVE_COLUMNS = 11,
  WAVE_UNIT_MOTION_STEPS=2,
  WAVE_MIN_DELAY = 5,
  WAVE_MAX_DELAY = 23,
  WAVE_UNIT_A_COORD = {spriteX=65, spriteY=50, w=25, h=32},
  WAVE_UNIT_B_COORD = {spriteX=115, spriteY=50, w=27, h=32},
  WAVE_UNIT_C_COORD = {spriteX=0, spriteY=50, w=32, h=32},
  WAVE_SPACESHIP_COORD = {spriteX=168, spriteY=54, w=30, h=20},
  WAVE_SPACESHIP = {x=168, y=71, w=20, h=13},
  WAVE_INVADER_A = {pts=40, minDelay=2, maxDelay=7, motionImagesArray={},},
  WAVE_INVADER_B = {pts=20, minDelay=3, maxDelay=8, motionImagesArray={},},
  WAVE_INVADER_C = {pts=10, minDelay=2, maxDelay=10, motionImagesArray={},},
  WAVE_PERC_BACK_LINES = 0.2,
  WAVE_PERC_FRONT_LINES = 0.4,
  WAVE_SPACESHIP_MIN_DELAY = 10,--20,
  WAVE_SPACESHIP_MAX_DELAY = 17,--40,
  WAVE_SPACESHIP = {x=168, y=71, w=20, h=13},
  WAVE_SPACESHIP_MOTION_STEPS=1,
  WAVE_MAX_SPACESHIPS_ARRAY = {3, 4, 4, 4, 5, 5, 5, 5, 6},
  WAVE_SPACE_BETWEEN_COLUMNS = 4,
  WAVE_SPACE_BETWEEN_LINES = 1,
  WAVE_DELAY_TO_NEXT_WAVE = 1,
  WAVE_INVADER_EXPLOSION = {spriteX=200, spriteY=52, w=30, h=32},
  }

waveConstants = protect_table (waveConstants)


cannonConstants =
  {
	CANNON_WIDTH = 55,
	CANNON_HEIGHT = 50,
	CANNON_SPRITE_X = 0,
	CANNON_SPRITE_Y = 0,
	CANNON_BULLET_HIT_IMPACT = 1,
	CANNON_BULLET_COORD = {spriteX=220, spriteY=0, w=3, h=10},
	CANNON_BULLET_MOTION_STEPS=1,
	--CANNON_INTERVAL_FIRE=0.2,
	CANNON_INTERVAL_FIRE=0.5,
	CANNON_IMAGE_COORD = {spriteX=0, spriteY=0, w=55, h=50},
	CANNON_MOTION_STEPS=4,
	CANNON_SHOT_SOUND = "resources/audio/cannonshot.wav",
	CANNON_SHOT_SOUND_VOLUME = 0.25,
	CANNON_SHOT_SOUND_PITCH = 1,
	CANNON_DEATH_SOUND = "resources/audio/cannondeath.wav",
	CANNON_DEATH_SOUND_VOLUME = 1,
	CANNON_DEATH_SOUND_PITCH = 1,

  }

cannonConstants = protect_table (cannonConstants)


shieldConstants =
  {
	SHIELD_NUM_SHIELDS = 4,
	SHIELD_NUM_LINES = 3,
	SHIELD_NUM_COLUMNS = 5,
	SHIELD_VOID_BLOCK = {line=3, column=3},
	SHIELD_HITS_BLOCK = 3,
	SHIELD_SPRITE = "resources/images/shield-redux.png",
	SHIELD_WIDTH = 60,
	SHIELD_HEIGHT = 54,

	SHIELD_HIT_SOUND = "resources/audio/shieldhit.wav",
	SHIELD_HIT_SOUND_VOLUME = 0.8,
	SHIELD_HIT_SOUND_PITCH = 1,

	SHIELD_ATTACKED_SOUND = "resources/audio/36846__ecodtr__laserrocket.wav",
	SHIELD_ATTACKED_SOUND_VOLUME = 0.5,
	SHIELD_ATTACKED_SOUND_PITCH = 0.75,


	SHIELD_LATERAL_MARGINS = 30,
	SHIELD_BOTTOM_MARGIN = 20,
  }

shieldConstants = protect_table (shieldConstants)


invaderConstants =
  {
	INVADER_WIDTH = 55,
	INVADER_HEIGHT = 50,
	INVADER_SPRITE_X = 0,
	INVADER_SPRITE_Y = 0,
	INVADER_BULLET_HIT_IMPACT = 1,
	INVADER_SHOT_SOUND = "resources/audio/invadershot.wav",
	INVADER_SHOT_SOUND_VOLUME = 0.4,
	INVADER_SHOT_SOUND_PITCH = 1,
	INVADER_DEATH_SOUND = "resources/audio/13797__sweetneo85__wilhelm.wav",
	--INVADER_DEATH_SOUND = "resources/audio/aliendeath.wav",
	INVADER_DEATH_SOUND_VOLUME = 0.5,
	INVADER_DEATH_SOUND_PITCH = 0.75,
	INVADER_BULLET_A_COORD = {spriteX=234, spriteY=0, w=5, h=13},
	INVADER_BULLET_B_COORD = {spriteX=246, spriteY=0, w=5, h=13},
	INVADER_BULLET_C_COORD = {spriteX=257, spriteY=0, w=5, h=13},
	INVADER_BULLET_MOTION_STEPS=2,
	INVADER_BULLETS_ARRAY = {1, 1, 2, 2, 2, 2, 3, 3, 3},
	INVADER_BULLETS_SPEED_ARRAY = {143, 143, 150, 150, 150, 153, 157},
  }

invaderConstants = protect_table (invaderConstants)


spaceshipConstants =
  {
	SPACESHIP_TRAVEL_SOUND = "resources/audio/spaceshiptravel.wav",
	SPACESHIP_TRAVEL_SOUND_VOLUME = 1,
	SPACESHIP_TRAVEL_SOUND_PITCH = 1,
	SPACESHIP_DEATH_SOUND = "resources/audio/spaceshipdeath.wav",
	SPACESHIP_DEATH_SOUND_VOLUME = 0.75,
	SPACESHIP_DEATH_SOUND_PITCH = 0.75,
	SPACESHIP_DELAY_TO_PLAY_SOUND = 0.5,
	SPACESHIP_POINTS_ARRAY = {50, 100, 100, 150, 150, 200, 200, 300},
	SPACESHIP_TIME_SHOWING_POINTS = 2,
	SPACESHIP_TRAVEL_SPEED = 70,
	SPACESHIP_Y_ORBIT = 45,
	SPACESHIP_TRAVEL_SPEED_ARRAY = {58, 63, 63, 70, 70, 70, 70, 70, 70, 77, 77, 82},
  }

spaceshipConstants = protect_table (spaceshipConstants)


overConstants =
  {
  OVER_PLAY_AGAIN_COORD = {spriteX=0, spriteY=230, w=170, h=15},
  OVER_PLAY_BUTTON_COORD = {x=150, y=400, w=170, h=16},
  OVER_GAME_OVER_COORD = {spriteX=0, spriteY=245, w=294, h=30},
  OVER_GAME_OVER_Y_LETTERS ={0, 27, 51, 85, 133, 162, 208, 238, 267}

  }

overConstants = protect_table (overConstants)

