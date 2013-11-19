import "classes/player.tu", "classes/tiles.tu", "classes/particleClass.tu", "classes/bulletClass", "classes/AI.tu"
var myMap : ^tileSystem
new tileSystem, myMap

%%%%%%what the bullets can collide into
bulletClass.setCollideables (-1)
for x : 1 .. 16
    bulletClass.setCollideables (x)
end for
%%%%%%%
%%%%%%the tiles
for x : 0 .. 17
    tileSystem (myMap).InitiateTile ("tiles/" + intstr (x) + ".bmp")
end for
tileSystem (myMap).InitiateTile ("tiles/rKey.bmp")
tileSystem (myMap).InitiateTile ("tiles/bKey.bmp")
tileSystem (myMap).InitiateTile ("tiles/gKey.bmp")
for x : 1 .. 3
    tileSystem (myMap).InitiateTile ("tiles/w" + intstr (x) + ".bmp")
end for
tileSystem (myMap).InitiateTile ("tiles/w2.bmp")
for x : 18 .. 22
    tileSystem (myMap).InitiateTile ("tiles/" + intstr (x) + ".bmp")
end for
%28
for x : 21 .. 23
    tileSystem (myMap).SetAnimate (x, x + 1, 450)
end for
tileSystem (myMap).SetAnimate (24, 21, 500)

tileSystem (myMap).SetAnimate (25, 26, 750)
tileSystem (myMap).SetAnimate (26, 25, 2050)
%%%%stuff
var enemy : flexible array 0 .. 0 of ^player
var enemyAI : flexible array 0 .. 0 of ^AI
var human : ^player
new player, human
for x : 1 .. 16
    player (human).setUnwalkables (x)
end for
for x : 21 .. 24
    player (human).setUnwalkables (x)
end for
%%%%%%%%%%%%player and enemy pics
var enemyPic : array 0 .. 36 of int
enemyPic (0) := Pic.FileNew ("enemy.bmp")
for k : 1 .. 36
    enemyPic (k) := Pic.Rotate (enemyPic (0), k * 10, Pic.Width (enemyPic (0)) div 2, Pic.Height (enemyPic (0)) div 2)
end for
var playerPic : array 0 .. 36 of int
playerPic (0) := Pic.FileNew ("shotgun.bmp")
for k : 1 .. 36
    playerPic (k) := Pic.Rotate (playerPic (0), k * 10, Pic.Width (playerPic (0)) div 2, Pic.Height (playerPic (0)) div 2)
end for
%%%%%%%%%%%%%%

proc enemies (map : string)
    var enemyNum : int
    var ex, ey, eex, eey : real
    var fileName : string := map
    var fileNo : int
    new enemy, 0
    if File.Exists (map) then
	open : fileNo, fileName, get
	get : fileNo, enemyNum
	new enemy, enemyNum
	new enemyAI, enemyNum
	for x : 1 .. enemyNum
	    new player, enemy (x)
	    new AI, enemyAI (x)
	    get : fileNo, ex
	    get : fileNo, ey
	    player (enemy (x)).initiate (ex, ey, 4, myMap)
	    get : fileNo, eex
	    get : fileNo, eey
	    AI (enemyAI (x)).setPatrol (ex, ey, eex, eey)
	    if player (enemy (x)).Move (0, 1, 1, 0, 0, false) then
	    end if
	    for y : 1 .. 10
		player (enemy (x)).setUnwalkables (y)
	    end for
	    for y : 21 .. 24
		player (enemy (x)).setUnwalkables (y)
	    end for
	    player (enemy (x)).setUnwalkables (25)
	    player (enemy (x)).setUnwalkables (26)
	end for
	close (fileNo)
    end if
end enemies

var px, py : int := 1 * 16 - 3
py := 1 * 16 - 3
var shiftX, shiftY : int := 0
proc fade
    for x : 15 .. 31
	colourback (x)
	cls
	delay (25)
	View.Update
    end for
    delay (50)
    for decreasing x : 31 .. 16
	colourback (x)
	cls
	delay (25)
	View.Update
    end for
end fade
var warp : flexible array 0 .. 0 of
    record
	atX, atY, destinationX, destinationY : int
	map : string
    end record

proc setWarpPoints (map : string)
    colour (yellow)
    var atX, atY, destinationX, destinationY, Wpoints : int
    var warpMap : string
    var fileName : string := map
    var fileNo : int
    new warp, 0

    if File.Exists (map) then
	open : fileNo, fileName, get
	get : fileNo, Wpoints
	new warp, Wpoints
	for x : 1 .. Wpoints
	    get : fileNo, warp (x).atX
	    get : fileNo, warp (x).atY
	    get : fileNo, warp (x).destinationX
	    get : fileNo, warp (x).destinationY
	    get : fileNo, warp (x).map
	end for
    end if
    put upper (warp)
end setWarpPoints
var rKey, bKey, gKey : boolean := false
var equip : int := 2
var weapon : array 1 .. 3 of int
for x : 1 .. 3
    weapon (x) := 0
end for
proc triggers
    if tileSystem (myMap).currentType (round (player (human).currentX), round (player (human).currentY)) = 25 then
	player (human).changeHealth (-5)
    end if
    if tileSystem (myMap).currentType (round (player (human).currentX), round (player (human).currentY)) = 18 then
	rKey := true
	if tileSystem (myMap).changeTile (18, 0) then
	end if
	if tileSystem (myMap).changeTile (13, 0) then
	end if
	if tileSystem (myMap).changeTile (14, 0) then
	end if
    end if
    if tileSystem (myMap).currentType (round (player (human).currentX), round (player (human).currentY)) = 19 then
	bKey := true
	if tileSystem (myMap).changeTile (19, 0) then
	end if
	if tileSystem (myMap).changeTile (11, 0) then
	end if
	if tileSystem (myMap).changeTile (12, 0) then
	end if
    end if
    if tileSystem (myMap).currentType (round (player (human).currentX), round (player (human).currentY)) = 20 then
	gKey := true
	if tileSystem (myMap).changeTile (20, 0) then
	end if
	if tileSystem (myMap).changeTile (16, 0) then
	end if
	if tileSystem (myMap).changeTile (15, 0) then
	end if
    end if
    if tileSystem (myMap).currentType (round (player (human).currentX), round (player (human).currentY)) = 29 then
	tileSystem (myMap).changeCurrentTile (round (player (human).currentX), round (player (human).currentY), 0)
	weapon (1) += 1
	weapon (2) += 5
	weapon (3) += 10
    end if
    if tileSystem (myMap).currentType (round (player (human).currentX), round (player (human).currentY)) = 28 then
	tileSystem (myMap).changeCurrentTile (round (player (human).currentX), round (player (human).currentY), 0)
	if player (human).currentHealth + 600 * .3 > 600 then
	    player (human).Health (600)
	else
	    player (human).changeHealth (round (600 * .3))
	end if
    end if
end triggers

proc load (map : string, x, y : int)
    fade
    tileSystem (myMap).clearTiles
    tileSystem (myMap).InitiateMap (map + ".txt")
    enemies (map + "enemy.txt")
    player (human).initiate (x, y, 4, myMap)
    setWarpPoints (map + "warps.txt")
    shiftX := 0
    shiftY := 0
    px := 0
    py := 0
    if x * 16 > maxx div 2 then
	shiftX := (maxx div 2 - x * 16) * -1
	if not tileSystem (myMap).MoveMap (-shiftX, 0) then
	    shiftX := tileSystem (myMap).Cx * -1
	end if
    end if
    if rKey = true then
	if tileSystem (myMap).changeTile (18, 0) then
	end if
	if tileSystem (myMap).changeTile (13, 0) then
	end if
	if tileSystem (myMap).changeTile (14, 0) then
	end if
    end if
    if bKey = true then

	if tileSystem (myMap).changeTile (19, 0) then
	end if
	if tileSystem (myMap).changeTile (11, 0) then
	end if
	if tileSystem (myMap).changeTile (12, 0) then
	end if
    end if
    if gKey = true then
	if tileSystem (myMap).changeTile (20, 0) then
	end if
	if tileSystem (myMap).changeTile (16, 0) then
	end if
	if tileSystem (myMap).changeTile (15, 0) then
	end if
    end if
    px := x * 16 - shiftX - 5

    if y * 16 > maxy div 2 then
	shiftY := (maxy div 2 - y * 16) * -1
	if not tileSystem (myMap).MoveMap (0, -shiftY) then
	    shiftY := tileSystem (myMap).Cy * -1
	end if
    end if
    py := y * 16 - shiftY - 5
end load

%%%%%%%%%%%%%%%%%
fcn onScreen (x, y : real) : boolean
    result (x * 16 - shiftX >= 0 and x * 16 - shiftX <= maxx and y * 16 - shiftY > 0 and y - shiftY * 16 < maxy) and (x * 16 - shiftX + 10 >= 0 and x * 16 - shiftX + 10 <= maxx and y * 16 -
	shiftY +
	10 > 0 and y * 16 - shiftY + 10 < maxy)
end onScreen
proc enemyReact
    var dir : int
    var dis, angX, angY : real
    var useless : flexible array 0 .. 0 of int
    for x : 1 .. upper (enemy)
	if not AI (enemyAI (x)).patrolling then
	    dis := bulletClass.MaxDis (player (enemy (x)).Angle, player (human).currentX * 16, player (human).currentY * 16, myMap)
	else
	    dis := 0
	end if
	dir := AI (enemyAI (x)).move (player (human).currentX, player (human).currentY, player (enemy (x)).currentX, player (enemy (x)).currentY, dis, shiftX, shiftY)
	angX := AI (enemyAI (x)).angX
	angY := AI (enemyAI (x)).angY
	if player (enemy (x)).Move (dir, round (angX), round (angY), shiftX, shiftY, false) then
	end if
	if AI (enemyAI (x)).shoot (dir) then
	    if player (enemy (x)).shoot (player (enemy (x)).Angle) then
	    end if
	end if
	if onScreen (player (enemy (x)).currentX, player (enemy (x)).currentY) then
	    Pic.Draw (enemyPic (round (player (enemy (x)).Angle / 10)), round (player (enemy (x)).currentX * 16 - 3 - shiftX), round (player (enemy (x)).currentY * 16 - 3 - shiftY), picMerge)
	end if

	if player (enemy (x)).currentHealth <= 0 then
	    new useless, upper (useless) + 1
	    useless (upper (useless)) := x
	    tileSystem (myMap).changeCurrentTile (round (player (enemy (x)).currentX), round (player (enemy (x)).currentY), Rand.Int (28, 29))
	end if
    end for
    for x : 1 .. upper (useless)
	for j : useless (x) .. upper (enemy) - 1
	    enemy (j) := enemy (j + 1)
	    enemyAI (j) := enemyAI (j + 1)
	end for
	new enemy, upper (enemy) - 1
	new enemyAI, upper (enemyAI) - 1
    end for
end enemyReact

proc playerWarp (x, y : real)
    for num : 1 .. upper (warp)
	if x = warp (num).atX and y = warp (num).atY then
	    load (warp (num).map, warp (num).destinationX, warp (num).destinationY)
	    exit
	end if
    end for
end playerWarp
%%%%%%%%%%%%%%%%%%
var key : array char of boolean
var mx, my, mb : int
%%%%%%%%%%%%%%%%%%%%

