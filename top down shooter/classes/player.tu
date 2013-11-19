unit
class player
    import "tiles.tu", "bulletClass.tu"
    export initiate, Move, setUnwalkables, Angle, shoot, changeWeapon, currentHealth, currentX, currentY, changeHealth, Health

    var dir :
	record
	    up, down, left, right : boolean
	    cUp, cRight : int
	    now : int
	end record
    var health : int := 75
    var badTiles : flexible array 0 .. 0 of int
    var TimeDelay : int := Time.Elapsed
    type gun :
	record
	    timeToShoot : int
	    length : int
	    equip : boolean
	end record
    var shotgun, pistol, machineGun : gun
    pistol.equip := true
    pistol.timeToShoot := 500
    pistol.length := 5

    shotgun.equip := false
    shotgun.timeToShoot := 1000
    shotgun.length := 10

    machineGun.equip := false
    machineGun.timeToShoot := 5
    machineGun.length := 3
    var cx, cy, steps, currentAngle : real := 1
    var currentMap : ^tileSystem

    fcn currentX : real
	result cx
    end currentX
    fcn currentY : real
	result cy
    end currentY

    fcn collide (x, y : real, myMap : ^tileSystem) : boolean
	var tmp : boolean := false
	for b : 1 .. upper (badTiles)
	    if tileSystem (myMap).currentType (ceil (x), ceil (y)) = badTiles (b) then
		tmp := true
	    end if
	    if tileSystem (myMap).currentType (floor (x), ceil (y)) = badTiles (b) then
		tmp := true
	    end if
	    if tileSystem (myMap).currentType (ceil (x), floor (y)) = badTiles (b) then
		tmp := true
	    end if
	    if tileSystem (myMap).currentType (floor (x), floor (y)) = badTiles (b) then
		tmp := true
	    end if
	end for
	result tmp
    end collide
    proc Health (hlt : int)
	health := hlt
    end Health
    fcn angle (px, py, tx, ty : real) : real
	var adjecent : real := tx - px
	var opposite : real := ty - py
	if adjecent = 0 and ty > py then
	    result 90
	elsif adjecent = 0 and ty <= py then
	    result 270
	end if
	if opposite = 0 and tx > px then
	    result 0
	end if
	if opposite = 0 and tx < px then
	    result 180
	end if
	if ty < py then
	    if arctand (opposite / adjecent) > 0 then
		result 180 + arctand (opposite / adjecent)
	    else
		result 360 + arctand (opposite / adjecent)
	    end if
	    result 180 + arctand (opposite / adjecent)
	else
	    if arctand (opposite / adjecent) < 0 then
		result 180 + arctand (opposite / adjecent)
	    else
		result arctand (opposite / adjecent)
	    end if
	end if
    end angle

    fcn Angle : real
	result currentAngle
    end Angle

    proc setUnwalkables (i : int)
	new badTiles, upper (badTiles) + 1
	badTiles (upper (badTiles)) := i
    end setUnwalkables

    proc initiate (x, y, stps : real, map : ^tileSystem)
	cx := x
	cy := y
	steps := 1 / stps
	currentMap := map
	dir.up := collide (cx, cy + 1, currentMap)
	dir.down := collide (cx, cy - 1, currentMap)
	dir.left := collide (cx - 1, cy, currentMap)
	dir.right := collide (cx + 1, cy, currentMap)

	dir.cUp := 0
	dir.cRight := 0
    end initiate

    proc changeHealth (x : int)
	health += x
    end changeHealth
    fcn currentHealth : int
	result health
    end currentHealth
    fcn Move (direction, mx, my, shiftX, shiftY : int, run : boolean) : boolean
	var tmp : boolean := false

	if direction = 1 and (not dir.up or dir.cUp not= 0) then
	    cy += steps
	    dir.cUp += 1
	    tmp := true
	end if
	if direction = 2 and (not dir.down or dir.cUp not= 0) then
	    cy -= steps
	    dir.cUp -= 1
	    tmp := true
	end if

	if direction = 3 and (not dir.right or dir.cRight not= 0) then
	    cx += steps
	    dir.cRight += 1
	    tmp := true
	end if

	if direction = 4 and (not dir.left or dir.cRight not= 0) then
	    cx -= steps
	    dir.cRight -= 1
	    tmp := true
	end if

	if dir.cUp = 4 or dir.cUp = -4 or dir.cRight = 4 or dir.cRight = -4 then
	    dir.up := collide (cx, cy + 1, currentMap)
	    dir.down := collide (cx, cy - 1, currentMap)
	    dir.left := collide (cx - 1, cy, currentMap)
	    dir.right := collide (cx + 1, cy, currentMap)
	end if
	if dir.cUp = 0 then
	    dir.up := collide (cx, cy + 1, currentMap)
	    dir.down := collide (cx, cy - 1, currentMap)
	end if
	if dir.cRight = 0 then
	    dir.left := collide (cx - 1, cy, currentMap)
	    dir.right := collide (cx + 1, cy, currentMap)
	end if
	if dir.cUp = 4 or dir.cUp = -4 then
	    dir.cUp := 0
	end if
	if dir.cRight = 4 or dir.cRight = -4 then
	    dir.cRight := 0
	end if
	changeHealth (bulletClass.playerHit (cx * 16, cy * 16))
	if run then
	    bulletClass.run (shiftX, shiftY)
	end if
	currentAngle := angle (cx * 16, cy * 16, mx, my)
	result tmp
    end Move

    proc changeWeapon (x : int)
	if x = 1 then
	    shotgun.equip := true
	    pistol.equip := false
	    machineGun.equip := false
	elsif x = 2 then
	    shotgun.equip := false
	    pistol.equip := true
	    machineGun.equip := false
	elsif x = 3 then
	    shotgun.equip := false
	    pistol.equip := false
	    machineGun.equip := true
	end if
    end changeWeapon

    fcn shoot (angle : real) : boolean
	if shotgun.equip then
	    if TimeDelay + shotgun.timeToShoot < Time.Elapsed then
		bulletClass.shoot (angle, cx * 16 + 10 + 12 * cosd (angle), cy * 16 + 10 + 12 * sind (angle), shotgun.length, 15, currentMap, -100)
		bulletClass.shoot (angle + 5, cx * 16 + 10 + 12 * cosd (angle), cy * 16 + 10 + 12 * sind (angle), shotgun.length, 15, currentMap, -100)
		bulletClass.shoot (angle + 10, cx * 16 + 10 + 12 * cosd (angle), cy * 16 + 10 + 12 * sind (angle), shotgun.length, 15, currentMap, -100)
		bulletClass.shoot (angle - 5, cx * 16 + 10 + 12 * cosd (angle), cy * 16 + 10 + 12 * sind (angle), shotgun.length, 15, currentMap, -100)
		bulletClass.shoot (angle - 10, cx * 16 + 10 + 12 * cosd (angle), cy * 16 + 10 + 12 * sind (angle), shotgun.length, 15, currentMap, -100)
		TimeDelay := Time.Elapsed
		result true
	    end if
	elsif pistol.equip then
	    if TimeDelay + pistol.timeToShoot < Time.Elapsed then
		bulletClass.shoot (angle, cx * 16 + 10 + 12 * cosd (angle), cy * 16 + 10 + 12 * sind (angle), pistol.length, 15, currentMap, -33)
		TimeDelay := Time.Elapsed
		result true
	    end if
	elsif TimeDelay + machineGun.timeToShoot < Time.Elapsed then
	    bulletClass.shoot (angle, cx * 16 + 10 + 12 * cosd (angle), cy * 16 + 10 + 12 * sind (angle), machineGun.length, 15, currentMap, -20)
	    TimeDelay := Time.Elapsed
	    result true
	end if
	result false
    end shoot
end player
