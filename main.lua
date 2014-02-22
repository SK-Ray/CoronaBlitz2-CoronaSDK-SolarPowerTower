
-- Corona Blitz #2
-- Theme: Energy / Energize


--  Solar Power Tower
-- R.Delia  @stinkykitties



--[[

Times: 2-18-2014 9:30pm-10:00   basic tower and panels are in
        2-20-2014 5:00 - 6:30pm -- playing with snapshots, gave up and added touch events / transitions
        2-20-2014 10-11pm --addd music, changed some text around, got it to restart
        2-21-2014 5 -6pm
--]]

-- sounds from freesounds.org, and retain their filenames with file numbers... all are / should be cc0 anyways :)

--lets try to keep everything in one file as long as we can

display.setStatusBar( display.HiddenStatusBar )
display.setDefault( "background", 0, .2, .8 )   --blue background color

local sand = display.newRect(-100, display.actualContentHeight, display.actualContentWidth + 100, display.actualContentHeight /2.5 )
sand.anchorX = .5
sand.anchorY= 1
sand.x,sand.y = display.contentCenterX,display.actualContentHeight

sand:setFillColor(.8,.8,.2, 1)


local title = display.newText(   "Solar Power Tower", 0, 0, 0, 0, native.systemFontBold, 28)
title.anchorX = 0.5
title.anchorY = 0.5
title.x = display.contentCenterX
title.y = display.actualContentHeight  *.15
title:setFillColor(1,1,0,1)

local titleTransition = {}
titleTransition.step2 = function()
        title.transition = transition.to(title, {time = 1200, x = display.contentCenterX - 30, rotation = -13 ,onComplete = titleTransition.step1})
print("step2 title")
end
titleTransition.step1 = function()
    title.transition = transition.to(title, {time = 1200,  x = display.contentCenterX + 30, rotation = 13 , onComplete = titleTransition.step2})
end

titleTransition.step1()


local zapSound = audio.loadSound("assets/136542__joelaudio__electric-zap-001.wav")
local pewSound =audio.loadSound("assets/62363__fons__zap-2.wav")
local overSound = audio.loadSound("assets/138488__randomationpictures__powerdown.wav")
local backgroundTrack = audio.loadSound("assets/156681__snapper4298__stezzer-102-1-break.wav")

audio.play(backgroundTrack, {channel = 25, loops = -1})
local score = 0 

local timer = 30 * 1000
local speedFast = 2
local speedSlow= 50
local speedMultiplier = 100

local gameOn = false
local gameOver = false
local gameEnded = true

local lastTime  = 0
local deltaTime = 0
local totalTime = 0 

local timeBar
local bounceObject = {}
local bounceText1
local bounceText2

local myDisplayText = display.newText("Go!!!", display.contentCenterX, display.contentCenterY, 0, 0, native.systemFontBold, 64)
myDisplayText.anchorX = .5
myDisplayText.anchorY = .5
myDisplayText.alpha = 0

local function goText()
    title.alpha = 0
    myDisplayText:toFront()
    myDisplayText:setFillColor(1,1,0,1)
    myDisplayText.text = "Go!!!"
    myDisplayText.y = display.contentCenterY
    myDisplayText.alpha = 1
    transition.to(myDisplayText, {time = 1000, y = - 100, alpha = 0})
end



--goText()

local function setEndFlag()
    print("bounce2")
    gameEnded = true
    myDisplayText.text = "Play!"
    transition.to( myDisplayText, { alpha = 1, y=display.actualContentHeight - myDisplayText.height, time=10 } ) --, onComplete =  bounceObject.bounceText1 , alpha = 0
    
end

setEndFlag()

function bounceObject.bounceText2()
    transition.to( myDisplayText, { y=display.actualContentHeight - myDisplayText.height, time=3000, alpha = .5, onComplete = setEndFlag } ) --, onComplete =  bounceObject.bounceText1 , alpha = 0
     title.alpha =1
end

function bounceObject.bounceText1()
    myDisplayText.text = "Game Over"
    myDisplayText.alpha = 1
    --  myDisplayText.y = centerY
    transition.to( myDisplayText, {alpha = 1, y=display.contentCenterY, time=1000, onComplete =  bounceObject.bounceText2 } )
    print("bounce1")
end


local totalHeight = display.actualContentHeight - (display.actualContentHeight - (display.contentCenterY * 2))
--print("totalHeight",totalHeight)
local totalWidth = display.actualContentWidth  - (display.actualContentWidth - (display.contentCenterX * 2))
--print("totalWidth",totalWidth)

local centerX = display.contentCenterX
local centerY = display.contentCenterY

--helper functions for positioning
local function getXByPercent(myPercent)
    
    local x =  totalWidth - (totalWidth - (totalWidth * myPercent / 100))
    -- print("x:",x)
    
    return x
end

local function getYByPercent(myPercent)
    
    local y =  totalHeight - (totalHeight - (totalHeight * myPercent / 100))
    print("Y:",y)
    return y
end

local mySnapshot = display.newSnapshot(totalWidth*2,totalHeight*2)  --why do i have to x2 this?
local mainGroup  = mySnapshot.group -- display.newGroup()



local scoreText = display.newText("Score: 0", (2 * (display.contentCenterX)- display.actualContentWidth) /2, getYByPercent(0), 0, 0, native.systemFont, 32)
scoreText.anchorX = 0
scoreText.anchorY = 0

local function updateScoreText()
    
    scoreText.text = "Score: " ..score
end

local collectionTower = display.newImage("assets/tower.png", system.ResourceDirectory, centerX, centerY)--display.newRect( centerX, centerY + 20, 60, 120)
collectionTower.yScale = .75
collectionTower.anchorX = .5
collectionTower.anchorY = .5
--lets make it partially see through for now...
collectionTower.alpha = .8
--make it look like it is narrower on top...
collectionTower.path.x1 = 20
collectionTower.path.y1 = 50
collectionTower.path.y4 =50


collectionTower.path.x4 = -20

local solarPanels = {}
local energies = {}

local physics = require("physics")
physics.start()
physics.setGravity(0, 9.8)

local function destroyRemainingEnergies()
    print("Kill the  rest:" .. #energies)
    for i , v in pairs(energies)  do
        local myEnergy =  v
        if myEnergy.transition then
            transition.cancel(myEnergy.transition)
            
            if myEnergy then
                physics.addBody(myEnergy,{ density=3.0, friction=0.5, bounce=0.3 })
                
            end
            
        end
        
        
    end
end

local function removeEnergies(myEnergy)
    print(#energies)
    for i,v in pairs(energies) do
        if v ==myEnergy then
            if myEnergy.transition then
                transition.cancel(myEnergy.transition)
            end
            print("remove:" .. i .. " - " ..  #energies .." left")
            v:removeSelf()
            v=nil
            table.remove(energies, i)
        end
    end
end

local function createEnergies()
    local energy = display.newRect(0, 0, 10, 10)
    energy:setFillColor(1, 1, 0, 1)
    table.insert(energies,energy)
    
    return energy
end

local function toTower2(myEnergy)
    
    local myPanel = myEnergy.panel
    if  gameOn ==false then
    else
        score = score + 100
        audio.play(zapSound, {channel = 30})
        scoreText.text = "Score: " ..score
    end
    
    --fade energy? collect it ?
    myPanel.switch =1
   myPanel:setFillColor(1,1,1,1)
    removeEnergies(myEnergy)
end

local function animateEnergy(myPanel)
    
    --we want to animate from the panel to the tower top, then to the tower base
    local newEnergy = createEnergies()
    newEnergy.x = myPanel.x
    newEnergy.y= myPanel.y 
    
    newEnergy.panel = myPanel
    newEnergy.transition =  transition.to(newEnergy, { time = math.random(speedFast,speedSlow) * speedMultiplier, x= collectionTower.x ,y=  collectionTower.y - 50, onComplete = toTower2}) --(myPanel,newEnergy)} )
    
end

local function makeSolarPanel(params)
    
    
    local solarPanel = display.newImage( "assets/panel.png" , getXByPercent(params.x), getYByPercent(params.y))--display.newRect( getXByPercent(params.x), getYByPercent(params.y), params.xSize,  params.ySize)

    solarPanel.anchorX = .5
    solarPanel.anchorY = .5
    
    function solarPanel:touch(event)
        if  gameOn == false then
            return
        end
        if event.phase == "ended" then
            
            if solarPanel.switch == 0 then
                --panel is off
                return
                
            end
            print("You touched panel:", solarPanel)
            audio.play(pewSound, {volume = .5})
            score = score + 10
            scoreText.text = "Score: " ..score
            solarPanel.switch = 0
            solarPanel:setFillColor(1,0,0, 1)
            
            animateEnergy(solarPanel)
        end
    end
    
    solarPanel:addEventListener("touch", solarPanel)
    
    table.insert(solarPanels,solarPanel)
    return solarPanel
end

local xSpacing = 20
local ySpacing = 20
local xSize = 20
local ySize = 29

--lets make 4 solar panels to start:
makeSolarPanel(  {x=50 + xSpacing,y= 50 - ySpacing,xSize=xSize,ySize=ySize })  --ne
makeSolarPanel(  {x=50-xSpacing,y=50 - ySpacing,xSize=xSize,ySize=ySize })  --nw
makeSolarPanel(  {x=50+xSpacing,y=50 + ySpacing,xSize=xSize,ySize=ySize  }) --se
makeSolarPanel(  {x=50 - xSpacing,y=50 + ySpacing,xSize=xSize,ySize=ySize  }) -- sw
makeSolarPanel(  {x=50-xSpacing * 1.25 ,y=50 ,xSize=xSize,ySize=ySize  })  --w
makeSolarPanel(  {x=50+xSpacing * 1.25 ,y=50 ,xSize=xSize,ySize=ySize  })  --e
makeSolarPanel(  {x=50 ,y=50 - ySpacing * 1.25 ,xSize=xSize,ySize=ySize  })  --n
makeSolarPanel(  {x=50 ,y=50 + ySpacing * 1.25 ,xSize=xSize,ySize=ySize  })  --s


--mainGroup.anchorChildren = true

--mainGroup.x,mainGroup.y = centerX,centerY

--mySnapshot.group.x = centerX
--mySnapshot.group.y = centerY
--mySnapshot.group:insert(mainGroup)
mySnapshot.anchorX = .75
mySnapshot.anchorY= .75
mySnapshot.x,mySnapshot.y = centerX,centerY


--rotation does not add to the game...
--transition.to(mySnapshot,{delay = 20, time = 16000, rotation = 360})-- rotation = -360})


mySnapshot:invalidate()

timeBar  = display.newRect( ( 2 * (display.contentCenterX)- display.actualContentWidth) /2  , getYByPercent(100), display.actualContentWidth, 30)
timeBar:setFillColor(0,1,0, 1)
timeBar.anchorX = 0
timeBar.anchorY = 1



local function enterFrameListener(event)
    
    if gameOn == false then
        return
    end
    
    deltaTime = event.time - lastTime
    if deltaTime > 50 then 
        deltaTime = 50
        print("Delta problem: "..deltaTime)
    end
    
    lastTime = event.time
    
    totalTime = totalTime + deltaTime
    
    
    --  print("time: "..totalTime .. " time left: " .. timer - totalTime)
    local percentLeft = ( (timer - totalTime) / timer) * 100
    -- print(percentLeft)
    if totalTime  > timer then
        gameOn = false
        
        if gameOver == false then
            gameOver  = true
            bounceObject.bounceText1("Game Over!")
            destroyRemainingEnergies()
            audio.play(overSound)
        end
    else
        timeBar.xScale = percentLeft / 100
        
        if percentLeft < 75 then
            
            
            timeBar:setFillColor(1,1,0,1)
        end
        if percentLeft < 25 then
            timeBar:setFillColor(1,0,0,1)
        end
    end
    
    
end
Runtime:addEventListener("enterFrame", enterFrameListener)

local overlay = display.newRect( ( 2 * (display.contentCenterX)- display.actualContentWidth) /2  ,0, display.actualContentWidth, display.actualContentHeight)
overlay.anchorX = .5
overlay.anchorY = .5
overlay.x = centerX
overlay.y = centerY

overlay.isHitTestable = true
overlay.alpha = 0

function overlay:touch(event)
    
    if gameEnded == true then
        
    else
        return
    end
    if event.phase == "ended" then
        print("Restarting")
        
        gameEnded = false
        gameOn = true
        gameOver = false
        score = 0
        updateScoreText()
        totalTime = 0
        deltaTime = 0
        timeBar:setFillColor(0,1,0,1)
        for i ,v in pairs(solarPanels) do
            local myPanel = v
            v.switch = 1
            v:setFillColor(1,1,1,1)
        end
        goText()
    end
end
overlay:addEventListener("touch",overlay)
