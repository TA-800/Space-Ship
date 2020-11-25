Ship = Class{}

require 'Bullet'

function Ship:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dx = 0
    self.damaged = false
    self.bl = false
    self.br = false
end

function Ship:update(dt)
    -- going towards the left side
    if self.dx < 0 then
        self.x = math.max(0 + 2, self.x + (self.dx * dt))
    -- going towards the right side
    else
        self.x = math.min(self.x + (self.dx * dt), VIRTUAL_WIDTH - self.width - 2)
    end
end

function Ship:render()
    -- if ship is damaged then show this color else show normal color
    if self.damaged then
        -- Wings of ship
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle('fill', self.x - 2, self.y + (self.height / 2) - (self.height - 5) / 2, self.width + 4, self.height - 5)
        -- Body of ship
        love.graphics.setColor(0.5, 0.5, 0.5, 1)
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
        -- Gun of ship
        love.graphics.setColor(0.5, 0.5, 0.5, 1)
        love.graphics.rectangle('fill', self.x + (self.width / 2) - ((self.width / 3) / 2), self.y - 3, self.width / 3, self.height / 3)
    else
        -- Wings of ship
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle('fill', self.x - 2, self.y + (self.height / 2) - (self.height - 5) / 2, self.width + 4, self.height - 5)
        -- Body of ship
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
        -- Gun of ship
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle('fill', self.x + (self.width / 2) - ((self.width / 3) / 2), self.y - 3, self.width / 3, self.height / 3)
    end
    if self.bl then
        love.graphics.setColor(0.25, 0.25, 1, 0.75)
        love.graphics.polygon('fill', Player.x + Player.width,Player.y, Player.x + Player.width,Player.y + Player.height, Player.x + Player.width + Player.width/2, Player.y + Player.height/2)
        love.graphics.setColor(0.25, 0.25, 1, 0.5)
        love.graphics.polygon('fill', Player.x + Player.width + 3,Player.y, Player.x + Player.width + 3,Player.y + Player.height, Player.x + Player.width + Player.width/2 + 3, Player.y + Player.height/2)
    elseif self.br then
        love.graphics.setColor(0.25, 0.25, 1, 0.75)
        love.graphics.polygon('fill', Player.x,Player.y, Player.x,Player.y + Player.height, Player.x - Player.width/2,Player.y + Player.height/2)
        love.graphics.setColor(0.25, 0.25, 1, 0.5)
        love.graphics.polygon('fill', Player.x - 3,Player.y, Player.x - 3,Player.y + Player.height, Player.x - Player.width/2 - 3,Player.y + Player.height/2)
    end
end
