
function love.load()
    card = {
        x = 100,
        y = 100,
        face = love.graphics.newImage("cardfaces/G-BT01-088EN PR.jpg"),
        dragging = { active = false, dx = 0, dy = 0, x0, y0}
    }
    zone = {
        x = 300,
        y = 100,
        width = 200,
        height = 400
    }
end

function love.update(dt)
    if card.dragging.active then
        card.x = love.mouse.getX() - card.dragging.dx
        card.y = love.mouse.getY() - card.dragging.dy
    end
end

function love.draw()
    love.graphics.draw(card.face, card.x, card.y, 0, 1, 1, card.face:getWidth()/2, card.face:getHeight()/2)
    love.graphics.rectangle("line", zone.x, zone.y, zone.width, zone.height)
end

function love.mousepressed(x, y, button)
    if button == "l"
    and x > card.x - card.face:getWidth()/2 and x < card.x + card.face:getWidth()/2
    and y > card.y - card.face:getHeight()/2 and y < card.y + card.face:getHeight()/2
    then
        card.dragging.active = true
        card.dragging.dx = x - card.x
        card.dragging.dy = y - card.y
        card.dragging.x0 = card.x
        card.dragging.y0 = card.y
    end
end

function love.mousereleased(x, y, button)
    if button == "l" then
        if card.x > zone.x and card.x < zone.x + zone.width
        and card.y > zone.y and card.y < zone.y + zone.height
        then
            card.x = zone.x + zone.width/2
            card.y = zone.y + zone.height/2
        else
            card.x = card.dragging.x0
            card.y = card.dragging.y0
        end
        card.dragging.active = false
    end
end
