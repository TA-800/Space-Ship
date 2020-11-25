-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
-- https://github.com/Ulydev/push
push = require 'push'
-- the "Class" library we're using will allow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables and
-- methods
Class = require 'class'
require 'Ship'
require 'Bullet'
require 'Enemy'
require 'Background'
require 'Power'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

--432, 243
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

Player = Ship(VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT - 30, 30, 15)

-- seed RNG
math.randomseed(os.time())


gameState = 'start'

music = love.audio.newSource("sounds/music.mp3", "stream")
music:setLooping(true)
music:play() 

--[[
    Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
    -- makes upscaling look pixel-y instead of blurry
    love.graphics.setDefaultFilter('nearest', 'nearest')

    sounds = {
        ['hit'] = love.audio.newSource("sounds/hit.wav", 'static'),
        ['earthhit'] = love.audio.newSource("sounds/hurt1.wav", "static"),
        ['playerhit'] = love.audio.newSource("sounds/hurt2.wav", "static"),
        ['lb'] = love.audio.newSource("sounds/leftboost.wav", "static"),
        ['rb'] = love.audio.newSource("sounds/rightboost.wav", "static"),
        ['shoot'] = love.audio.newSource("sounds/shoot.wav", "static"),
        ['power'] = love.audio.newSource("sounds/power.wav", "static"),
        ['select'] = love.audio.newSource("sounds/select.wav", 'static')
    }

    

    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)

    love.graphics.setFont(smallFont)

    LIVES = 3
    collide = false
    earthCollide = false
    EARTHLIVES = 3

    power = Power(3, 250)

    SHIP_SPEED = 350
    bullet = Bullet()
    FIRED = false
    BULLET_SPEED = 775

    enemy = Enemy()
    ENEMY_SPEED = 50
    SPAWN = false
    SPAWN_TIME = 1

    background = Background()

    bgtimer = 0
    timer = 0
    shotTimer = 1
    RENDERFLASH = false
    collideTimer = 0
    hitTimer = 0
    hitTimer2 = 0

    power_timer = 0
    power_fired = false

    score = 0
    -- set the title of our application window
    love.window.setTitle('SPACESHIP 50!')

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

end

--[[
    Called by LÖVE whenever we resize the screen; here, we just want to pass in the
    width and height to push so our virtual resolution can be resized as needed.
]]
function love.resize(w, h)
    push:resize(w, h)
end

--[[
    Runs every frame, with "dt" passed in, our delta in seconds 
    since the last frame, which LÖVE2D supplies us.
]]
function love.update(dt)
    -- if playing (not paused), then update
    if gameState == 'play' then
        -- update every frame
        Player:update(dt)
        enemy:update(dt)
        bullet:update(dt)
        background:update(dt)
        power:update(dt)

        -- timer for different things
        -- enemy spawn timer
        timer = timer + dt
        -- slightly reduce spawn time as well
        if SPAWN_TIME > 0.3 then
            SPAWN_TIME = SPAWN_TIME - dt/1000
        end
        -- background spawn timer
        bgtimer = bgtimer + dt
        -- muzzle flash timer
        shotTimer = shotTimer + dt
        -- power timer
        if power.power_charges > 0 then    
            if power_timer < 2 then
                power_timer = power_timer + dt
            else
                power_timer = 2
            end
        end
        -- earth hit timer (for fx)
        if hitTimer2 >= 0 then
            hitTimer2 = hitTimer2 - dt
        else
            hitTimer2 = 0
        end
        -- player hit timer (for fx)
        if hitTimer >= 0 then
            hitTimer = hitTimer - dt
        else
            hitTimer = 0
        end
        --increase enemy speed little by little to make game harder
        ENEMY_SPEED = ENEMY_SPEED + dt

        -- BULLET COLLISION
        if #(bullet.BULLETS) >= 1 then
            -- loop through enemies
            for i, v in ipairs(enemy.ENEMIES) do
                -- loop through bullets
                for j, w in ipairs(bullet.BULLETS) do 
                    -- POINT-BASED collision for SQUARE enemies
                    -- checking for x condition
                    -- if square
                    if v.r1 == 1 then
                        -- if unrotated square
                        if v.r3 == 2 then
                            if w.x + 1 >= v.x - 2 and w.x + 1 <= v.x + v.length + 2 then
                                -- checking for y condition
                                if w.y <= v.y + v.length then
                                    score = score + 1
                                    table.remove(bullet.BULLETS, j)
                                    table.remove(enemy.ENEMIES, i)
                                    sounds['hit']:stop()
                                    sounds['hit']:play()
                                end
                            end
                        else
                            -- if rotated square
                            if w.x + 1 >= v.x - v.length - 2 and w.x + 1 <= v.x + v.length + 2 then
                                if w.y <= v.y then
                                    score = score + 1
                                    table.remove(bullet.BULLETS, j)
                                    table.remove(enemy.ENEMIES, i)
                                    sounds['hit']:stop()
                                    sounds['hit']:play()
                                end
                            end
                        end
                    else
                        -- if circle
                        if w.x + 1 >= v.x - (v.length + 2) and w.x + 1 <= v.x + v.length + 2 then
                            -- checking for y condition
                            if w.y <= v.y + v.length then
                                score = score + 1
                                table.remove(bullet.BULLETS, j)
                                table.remove(enemy.ENEMIES, i)
                                sounds['hit']:stop()
                                sounds['hit']:play()
                            end
                        end
                    end
                end
            end
        end

        -- PLAYER LIVES: if enemy hits player
        if #(enemy.ENEMIES) >= 1 then
            for i, v in ipairs(enemy.ENEMIES) do
                -- if square
                if v.r1 == 1 then
                    -- if unrotated square
                    if v.r3 == 2 then
                        -- left point of enemy greater than left point of player    OR      right point of enemy less than right point of player
                        if (v.x >= Player.x and v.x <= Player.x + Player.width) or (v.x + v.length <= Player.x + Player.width and v.x + v.length >= Player.x) then
                            if v.y > Player.y then
                                table.remove(enemy.ENEMIES, i)
                                collide = true
                            end
                        end
                    elseif v.r3 == 1 then
                        -- if rotated square
                        if (v.x - v.length - 2 >= Player.x and v.x - v.length - 2 <= Player.x + Player.width) or (v.x + v.length + 2 >= Player.x and v.x + v.length + 2 <= Player.x + Player.width) then
                            if v.y > Player.y then
                                table.remove(enemy.ENEMIES, i)
                                collide = true
                            end
                        end
                    end
                else
                    -- if circle
                    if (v.x - v.length >= Player.x and v.x - v.length <= Player.x + Player.width) or (v.x + v.length <= Player.x + Player.width and v.x + v.length >= Player.x) then
                        if v.y + v.length - 1 > Player.y then
                            table.remove(enemy.ENEMIES, i)
                            collide = true
                        end
                    end
                end
            end
        end

        -- EARTH LIVES: if enemy hits earth
        if #(enemy.ENEMIES) >= 1 then
            for i, v in ipairs(enemy.ENEMIES) do 
                if v.y + v.length / 2 >= VIRTUAL_HEIGHT then
                    earthCollide = true
                    table.remove(enemy.ENEMIES, i)
                    sounds['earthhit']:stop()
                    sounds['earthhit']:play()
                end
            end
        end

        -- POWER COLLISION: if wave hits enemies
        if #(power.POWERS) >= 1 then
            for i, v in ipairs(enemy.ENEMIES) do
                for j, w in ipairs(power.POWERS) do
                    -- if circle
                    if v.r1 == 2 then
                        if math.sqrt(((Player.x + Player.width / 2) - (v.x))^2 + ((v.y) - (Player.y + Player.height / 2))^2) <= w.r then
                            table.remove(enemy.ENEMIES, i)
                            score = score + 1
                            sounds['hit']:play()
                        end
                    -- if square
                    elseif v.r1 == 1 then
                        if math.sqrt(((player_tempx + Player.width / 2) - (v.x + v.length / 2))^2 + ((v.y + v.length / 2) - (player_tempy + Player.height / 2))^2) <= w.r then
                            table.remove(enemy.ENEMIES, i)
                            score = score + 1
                            sounds['hit']:play()
                        end
                    end
                end
            end
        end

        -- slow down speed of ship
        if love.keyboard.isDown('lctrl') then
            SHIP_SPEED = 350 / 2
        -- adding boost to ship
        elseif love.keyboard.isDown('lshift') then
            SHIP_SPEED = 350 * 2
            if love.keyboard.isDown('a') or love.keyboard.isDown('left') then
                Player.bl = true
                Player.br = false
                sounds['lb']:play()
            elseif love.keyboard.isDown('d') or love.keyboard.isDown('right') then
                Player.br = true
                Player.bl = false
                sounds['rb']:play()
            else
                Player.br = false
                Player.bl = false
            end
        else 
            SHIP_SPEED = 350
            Player.br = false
            Player.bl = false
        end

        -- player left / right controls
        if love.keyboard.isDown('a') or love.keyboard.isDown('left') then
            Player.dx = -SHIP_SPEED
        elseif love.keyboard.isDown('d') or love.keyboard.isDown('right') then
            Player.dx = SHIP_SPEED
        else
            Player.dx = 0
        end

        -- spawn enemy after some time
        if timer >= SPAWN_TIME then
            SPAWN = true
            timer = 0
        end

        -- spawn bg lines after some time
        if bgtimer >= 0.25 then
            background:spawn(math.random(1, VIRTUAL_WIDTH - 1), math.random(45, 60), math.random(4, 6))
            bgtimer = 0
        end

        if shotTimer <= 0.2 then
            RENDERFLASH = true
        else
            RENDERFLASH = false
        end

        -- if enemy hits player then make some animation
        if Player.damaged then
            collideTimer = collideTimer + dt
            if collideTimer >= 0.35 then
                Player.damaged = false
                collideTimer = 0
            end
        end

        -- when run out of lives
        if LIVES < 0 then
            gameState = 'dead'
        end
        if EARTHLIVES < 0 then
            gameState = 'earthDead'
        end

    end
end

--[[
    Called after update by LÖVE2D, used to draw anything to the screen, 
    updated or otherwise.
]]
function love.draw()
    push:apply('start')

    if gameState == 'start' then
        -- BLACK BACKGROUND
        love.graphics.clear(0, 0, 0, 1)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(largeFont)
        love.graphics.printf("PLAY", 0, 30, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("OBJECTIVE", 0, 90, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("INFORMATION", 0, 150, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press P to play", 0, 55, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press O for more game knowledge", 0, 115, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press I for information", 0, 175, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'objective' then
        love.graphics.clear(0, 0, 0, 1)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(largeFont)
        love.graphics.printf("You must do your best to protect Earth from incoming objects and meteorites for as long as you can!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press A or the left arrow key // R or the right arrow key to control the ship", 0, 80, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Left Shift or Left Control to speed up or slow down the ship", 0, 100, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Space bar to shoot", 0, 120, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Q to use POWER WAVE which you can use three times only", 0, 140, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press ESC to go back to menu page", 0, VIRTUAL_HEIGHT - 30, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'information' then
        love.graphics.clear(0, 0, 0, 1)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(largeFont)
        love.graphics.printf("Game developed by Taher Ali\n Hope you enjoy!", 0, 30, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Used LOVE2D (Lua) for creating this game", 0, 80, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Used BFXR for sound effects", 0, 120, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Music: A Journey Awaits! by Pierre Bondoerffer", 0, 160, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press ESC to go back to menu page", 0, VIRTUAL_HEIGHT - 30, VIRTUAL_WIDTH, 'center')

    -- draw only when playing to save memory
    elseif gameState == 'play' then
        love.graphics.clear(0, 0, 0.1, 1)

        -- RENDER OBJECTS
        background:render()
        enemy:render()
        bullet:render()
        power:render()
        power:HUDrender()
        Player:render()
        

        -- if collision
        if collide then
            Player.damaged = true
            collideTimer = 0
            hitTimer = 0.35
            LIVES = LIVES - 1
            collide = false
            sounds['playerhit']:play()
        end

        -- if enemy collision with earth
        if earthCollide then
            EARTHLIVES = EARTHLIVES - 1
            hitTimer2 = 0.35
            earthCollide = false 
        end
        if hitTimer2 > 0 then
            love.graphics.setColor(0.1, 0.1, 0.75, hitTimer2/0.35)
            love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
        end
        if hitTimer > 0 then
            love.graphics.setColor(1, 1, 1, hitTimer/0.35)
            love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
        end
        
        -- firing bullets
        if FIRED then
            bullet:fire(Player.x + Player.width / 2, Player.y)
            shotTimer = 0
            -- set FIRED back to false to avoid spamming of object creation
            FIRED = false
            -- stopping then playing again to overlap sound effects, i.e its not forced to play the sound completely then only able to play again from start
            sounds['shoot']:stop()
            sounds['shoot']:play()
        end

        -- muzzle flash
        if RENDERFLASH then
            bullet:muzzleFlashRender()
        end

        -- firing power
        if power_fired then
            player_tempx = Player.x
            player_tempy = Player.y
            power:spawn(player_tempx + Player.width / 2, player_tempy + Player.height / 2)
            power_fired = false
            sounds['power']:play()
        end

        -- enemy spawn time
        if SPAWN then
            -- spawn enemy
            -- random 1 for location, 2 for size, 3 for square or circle, 4 for square rotation
            enemy:spawn(math.random(15, VIRTUAL_WIDTH - 15), math.random(9, 13), math.random(2), math.random(2))
            -- set SPAWN back to false to avoid spamming of object creation
            SPAWN = false
        end

        love.graphics.setFont(smallFont)
        love.graphics.printf("LIVES: " .. tostring(LIVES) ..  " EARTH LIVES: " .. tostring(EARTHLIVES), 0, 0, VIRTUAL_WIDTH, 'center')

        displayScore(score)
        displayFPS()

   -- pause game state
    elseif gameState == 'pause' then
        love.graphics.clear(0, 1, 0, 1)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.setFont(largeFont)
        love.graphics.printf("PAUSED!", 10, VIRTUAL_HEIGHT / 2 - 10, VIRTUAL_WIDTH, 'center')
    
    -- dead game state
    elseif gameState == 'dead' then
        love.graphics.clear(0, 0, 0, 1)
        love.graphics.setFont(largeFont)
        love.graphics.printf("YOU DIED!\n SCORE: " .. tostring(score), 10, VIRTUAL_HEIGHT / 2 - 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press R to restart!", 10, VIRTUAL_HEIGHT / 2 + 30, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'earthDead' then
        love.graphics.clear(0, 0, 0, 1)
        love.graphics.setFont(largeFont)
        love.graphics.printf("EARTH IS LOST!\n SCORE: " .. tostring(score), 10, VIRTUAL_HEIGHT / 2 - 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press R to restart!", 10, VIRTUAL_HEIGHT / 2 + 30, VIRTUAL_WIDTH, 'center')
    end

    push:apply('end')
end

function love.keypressed(key)
    -- to quit game
    if key == 'escape' and gameState == 'play' then
        gameState = 'exit'
        love.event.quit()
    end

    -- pause if playing or resume if paused
    if key == 'p' then
        sounds['select']:play()
        if gameState == 'play' then
            gameState = 'pause'
        elseif gameState == 'pause' then
            gameState = 'play'
        end
    end

    -- restart if dead
    if key == 'r' and (gameState == 'dead' or gameState == 'earthDead') then
        gameState = 'play'
        love.load()
    end

    -- for bullets fired
    if key == 'space' then
        FIRED = true
    end

    -- for power used
    if key == 'q' and power_timer >= 2 then
        power_fired = true
        power_timer = 0
    end

    -- menu page
    if gameState == 'start' then
        if key == 'p' then
            gameState = 'play'
            sounds['select']:play()
        elseif key == 'o' then
            gameState = 'objective'
            sounds['select']:play()
        elseif key == 'i' then
            gameState = 'information'
            sounds['select']:play()
        end
    end
    if gameState == 'objective' then
        if key == 'escape' then
            gameState = 'start'
            sounds['select']:play()
        end
    end
    if gameState == 'information' then
        if key == 'escape' then
            gameState = 'start'
            sounds['select']:play()
        end
    end
end

--[[
    Renders the current FPS.
]]
function displayFPS()
    -- simple FPS display across all states
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function displayScore(score)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('SCORE: ' .. tostring(score), VIRTUAL_WIDTH - 70, 10)
end
