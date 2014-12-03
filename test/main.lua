local rich = require 'richtext'

message = [[
{Harro_71.png} Hello, {green}im {red}{fontBig}Harro.{fontMed}
{white}UTF8 german: {green}Ähnlichkeit mit Übungen ist Öffentlich.
{fontCyrillic}{white}UTF8 cyrillic: {red}а б в г д е ё ж з и й к л м н о
{fontSmall}{green}V{red}i{green}v{red}a{green}m{red}u{green}s {red}commodo ultricies scelerisque. In hac habitasse platea dictumst.
{fontMed}{blue}Fusce tempor euismod mollis. Ut lobortis commodo nulla, ac adipiscing urna auctor quis. Cras facilisis cursus metus, vel cursus leo posuere non. Aliquam sit amet vulputate orci. Vivamus ut ante ante, non hendrerit quam. Cras ligula libero, elementum id posuere sollicitudin, gravida ut nibh
Test1 {white}Test
Test2{white} Test
Test3 Test
{green}Test4 Test
{green}Test5 {white}Test
{green}Test6{white} Test
{green}{white}Test7 {green}{blue}Test
{green}{blue}Test8{green}{white} Test
{red}{green}Test9{green}{white} {blue}Test
{fontSmall}{red}Test10{green}{fontSmall} Test
{fontSmall}{red}Test11{fontCyrillic}{blue} TÄST
]]

local macros = {}
macros.white = {255, 255, 255}
macros.blue = {128, 128, 255}
macros.green = {0, 255, 0}
macros.red   = {255, 0, 0}
macros.fontBig = love.graphics.newFont('slkscr.ttf',60)
macros.fontCyrillic = love.graphics.newFont('font.ttf',14)
macros.fontMed = love.graphics.newFont(12)
macros.fontSmall = love.graphics.newImageFont('font1.png', "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 :-!.,'?>#")
macros['Harro_71.png'] = love.graphics.newImage('Harro_71.png')

local rt = nil

--if arg[#arg] == "-debug" then require("mobdebug").start() end

function love.load()
	rt = rich:new{ message, 500, macros }
end

function love.draw()
    rt:draw(10, 10)
end
