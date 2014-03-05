function love.load()
	love.physics.setMeter( 64 )
	world = love.physics.newWorld( 0, 9.81*64, true )
	world:setCallbacks( beginContact, endContact, preSolve, postSolve )
	
	objects = {}
	
	-- ... --
	
	objects.ground = {}
	objects.ground.body = love.physics.newBody(world, 650/2, 650-50/2)
	objects.ground.shape = love.physics.newRectangleShape( 650, 7 )
	objects.ground.fixture = love.physics.newFixture( objects.ground.body, objects.ground.shape )
	objects.ground.fixture:setUserData( "The Ground" )
	
	objects.leftWall = {}
	objects.leftWall.body = love.physics.newBody(world, 0, 0)
	objects.leftWall.shape = love.physics.newRectangleShape( 0.010*64, 18.75*64 )
	objects.leftWall.fixture = love.physics.newFixture( objects.leftWall.body, objects.leftWall.shape )
	objects.leftWall.fixture:setUserData( "Left Wall" )
	
	objects.rightWall = {}
	objects.rightWall.body = love.physics.newBody(world, 650, 0)
	objects.rightWall.shape = love.physics.newRectangleShape( 0.010*64, 18.75*64 )
	objects.rightWall.fixture = love.physics.newFixture( objects.rightWall.body, objects.rightWall.shape )
	objects.rightWall.fixture:setUserData( "Right Wall" )
	
	objects.ceiling = {}
	objects.ceiling.body = love.physics.newBody(world, 0, 0)
	objects.ceiling.shape = love.physics.newRectangleShape( 25*64, 0.010*64 )
	objects.ceiling.fixture = love.physics.newFixture( objects.ceiling.body, objects.ceiling.shape )
	
	-- ... --
	
	objects.plate = {}
	objects.plate.body = love.physics.newBody( world, 650/2, 650-80 )
	objects.plate.shape = love.physics.newRectangleShape( 60, 10 )
	objects.plate.fixture = love.physics.newFixture( objects.plate.body, objects.plate.shape )
	objects.plate.fixture:setUserData( "The Plate" )
	
	-- ... --
	
	objects.ball = {}
	objects.ball.body = love.physics.newBody(world, 650/2, 650/2, "dynamic")
	objects.ball.shape = love.physics.newCircleShape( 10 )
	objects.ball.fixture = love.physics.newFixture( objects.ball.body, objects.ball.shape, 1 )
	objects.ball.fixture:setRestitution( 0.9 )
	objects.ball.fixture:setUserData( "The Ball" )
	
	-- ... --
	
	love.graphics.setBackgroundColor( 104, 136, 248 ) --set the background color to a nice blue
	love.window.setMode( 650, 650 ) --set the window dimensions to 650 by 650
	
	-- ... --
	
	sunImage = love.graphics.newImage( "images/sun.png" )
	cloudImage = love.graphics.newImage( "images/cloud.png" )
	palmImage = love.graphics.newImage( "images/palm_tree.png" )
	grassImage = love.graphics.newImage( "images/grass.png" )
	cottageImage = love.graphics.newImage( "images/cottage.png" )
	
	-- ... --
	
	gameState = "working"
	gameOverAlpha = 255
	gameOverAlphaState = "down"
	grassState = "straight"
	score = 0
end


function love.update(dt)
	world:update(dt)
	
	if love.keyboard.isDown( "right" ) or love.keyboard.isDown( "left" ) then
		local newX = objects.plate.body:getX()
		
		if love.keyboard.isDown( "right" ) then
			newX = newX + 5
		else
			newX = newX - 5
		end
		
		objects.plate.body:setX( newX )
	end
end

function love.draw()
	if gameState == "Game Over"
	then
		love.graphics.setColor( 255, 255, 255, gameOverAlpha )
		love.graphics.setFont( love.graphics.newFont( 50 ) )
		love.graphics.print( "Game Over!", 650 / 4, 650 / 2 )
		
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.setFont( love.graphics.newFont( 20 ) )
		love.graphics.print( "Your Score: " .. score, 650 / 3.5, 650 - 250 )
		
		if gameOverAlpha == 255 then 
			gameOverAlphaState = "down" 
		elseif gameOverAlpha == 5 then
			gameOverAlphaState = "up" 
		end
		
		if gameOverAlphaState == "down" then
			gameOverAlpha = gameOverAlpha - 5
		else
			gameOverAlpha = gameOverAlpha + 5
		end
		
		return
	elseif gameState == "paused" then
		love.graphics.print( "Paused ...", 650 / 4, 650 / 2 )		
	end
	
	love.graphics.draw( sunImage, 40, 0 )
	love.graphics.draw( cloudImage, 0, 50 )
	love.graphics.draw( cloudImage, 135, 50 )
	love.graphics.draw( palmImage, 105, 340 )
	love.graphics.draw( cottageImage, 340, 390 )
	
	for k = -90, 630, 90 do
		love.graphics.draw( grassImage, k, 618 )
	end
	
	love.graphics.setColor( 140, 220, 410 )
	love.graphics.polygon( "fill", objects.plate.body:getWorldPoints( objects.plate.shape:getPoints() ) )
	
	love.graphics.setColor(193, 47, 14) --set the drawing color to red for the ball
	love.graphics.circle("fill", objects.ball.body:getX(), objects.ball.body:getY(), objects.ball.shape:getRadius())
	
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.print( "Score: " .. score, 650-80, 2 )
end

function beginContact(a, b, coll)
	if gameState == "Game Over" then return end
	
	if a:getUserData() == "The Plate" and b:getUserData() == "The Ball" then
		math.randomseed( os.time() )
		local angle = math.random( -90, 90 )
		local xVol = math.random( 0, 10 )
		local yVol = math.random( 600, 900 )
		
		b:getBody():setAngularVelocity( angle )
		b:getBody():setLinearVelocity( xVol, yVol )
		
		score = score + 10
	elseif a:getUserData() == "The Ground" and b:getUserData() == "The Ball" then
		gameState = "Game Over"
	end
end

function endContact( a, b, coll )
end

function preSolve( a, b, coll )
end

function postSolve( a, b, coll )
end

function love.keypressed( key, isRepeat )
	if key == " " then
		if gameState == "working" then
			gameState = "paused"
			objects.ball.body:setActive( false )
		elseif gameState == "paused" then
			gameState = "working"
			objects.ball.body:setActive( true )
		end	
	end
end
