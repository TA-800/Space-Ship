Background = Class{}


function Background:init()
    self.LINES = {}
end

function Background:spawn(x, dy, length)
    -- insert background lines into table
    table.insert(self.LINES, {x = x, y = -length, dy = dy, length = length})
end

function Background:update(dt)
    -- update every line in background
    for i, v in ipairs(self.LINES) do
        v.y = v.y + (v.dy * dt)

        -- if line goes outside screen
        if v.y >= VIRTUAL_HEIGHT then
            table.remove(self.LINES, i)
        end
    end
end

function Background:render()
    for i, v in ipairs(self.LINES) do
        love.graphics.setColor(1, 1, 1, 0.75)
        love.graphics.line(v.x,v.y, v.x,v.y+v.length)
    end
end