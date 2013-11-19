unit
module bulletClass
    import "tiles.tu", "particleClass.tu"
    export shoot, run, setCollideables, playerHit, MaxDis
    type vector :
	record
	    vY, vX : real
	    x, y : real
	    ex, ey : real
	    angle : real
	    bType : int
	    len, speed : real
	    maxDis, currentDis : real
	    startS, startY : real
	    currentMap : ^tileSystem
	    playerHit : boolean
	    doubleCheck : boolean
	end record
    var myMap : ^tileSystem
    var bullet : flexible array 0 .. 0 of vector
    var collideables : flexible array 0 .. 0 of int
    var explosion, blood : ^particleSystem
    new particleSystem, explosion
    new particleSystem, blood
    particleSystem (explosion).atributes (0, 0, yellow, 10, 10, 300)
    particleSystem (blood).atributes (0, -.5, red, 13, 60, 350) %112
    fcn tangent (theta : real) : real
	result sind (theta) / cosd (theta)
    end tangent

    proc setCollideables (i : int)
	new collideables, upper (collideables) + 1
	collideables (upper (collideables)) := i
    end setCollideables

    fcn collide (x, y : real, myMap : ^tileSystem) : boolean
	var tmp : boolean := false
	for b : 1 .. upper (collideables)
	    if x >= 2000 or y >= 2000 then
		result true
	    end if
	    if tileSystem (myMap).currentType (floor (x), floor (y)) = collideables (b) then
		tmp := true
	    end if
	end for
	result tmp
    end collide

    fcn MaxDis (ang, x, y : real, map : ^tileSystem) : real
	var Ay, Ax, angle, tmp1, tmp2, Ya, Xa, shiftX, shiftY : real
	if collide (x / 16, y / 16, map) then
	    result 0
	end if
	angle := 180 - ang
	if angle >= 0 and angle <= 180 then
	    Ay := floor (y / 16) * (16) + 16
	    Ya := 16
	else
	    Ay := floor (y / 16) * (16) - 1
	    Ya := -16
	end if
	Xa := 16 / (tangent (angle) + .0000000001)
	Ax := x + ((y - Ay) / (tangent (angle) + .0000001))
	if Ax < 0.00000005 then
	    Ax := 0
	end if
	if tangent (angle) = 0 then
	    tmp1 := 999999999
	end if
	shiftX := Ax
	shiftY := Ay
	if not tangent (angle) = 0 then
	    loop
		exit when collide (abs (shiftX / 16), abs (shiftY / 16), map) or sqrt (abs ((x - shiftX) ** 2 + (y - shiftY) ** 2)) > 350
		if angle >= 0 and angle <= 180 then
		    shiftX -= Xa
		else
		    shiftX += Xa + .1
		end if
		shiftY += Ya
		exit when collide (abs (shiftX / 16), abs (shiftY / 16), map) or sqrt (abs ((x - shiftX) ** 2 + (y - shiftY) ** 2)) > 350
	    end loop
	end if
	tmp1 := sqrt (abs ((x - shiftX) ** 2 + (y - shiftY) ** 2))
	var Bx, By : real
	if angle >= 90 and angle <= 270 then
	    Bx := floor (x / 16) * (16) + 16
	    Xa := 16
	else
	    Bx := floor (x / 16) * (16) - 1
	    Xa := -16
	end if
	By := y + (x - Ax) * tangent (angle)
	Ya := tangent (angle) * 16
	shiftX := Bx
	shiftY := By
	if ang not= 90 and ang not= 270 then
	    loop
		exit when collide (abs (shiftX / 16), abs (shiftY / 16), map) or sqrt (abs ((x - shiftX) ** 2 + (y - shiftY) ** 2)) > 350
		if angle >= 90 and angle <= 270 then
		    shiftX += Xa
		    shiftY -= Ya
		elsif angle >= -180 and angle <= -90 then
		    shiftX -= Xa
		    shiftY -= Ya
		else
		    shiftX += Xa
		    shiftY += Ya
		end if
		exit when collide (abs (shiftX / 16 + .3), abs (shiftY / 16 + .3), map) or sqrt (abs ((x - shiftX) ** 2 + (y - shiftY) ** 2)) > 350
	    end loop
	end if

	tmp2 := sqrt (abs ((x - shiftX) ** 2 + (y - shiftY) ** 2))
	if ang >= 90 and ang <= 110 then
	    tmp2 := tmp1 + 5
	elsif ang >= 250 and ang <= 299 then
	    tmp2 := tmp1 + 5
	end if

	if tmp1 <= tmp2 then
	    result tmp1
	elsif tmp1 > tmp2 then
	    result tmp2
	end if
    end MaxDis

    fcn distance (x1, x2, y1, y2 : real) : real
	result sqrt ((x1 - x2) ** 2 + (y1 - y2) ** 2)
    end distance

    fcn playerHit (px, py : real) : int
	for x : 1 .. upper (bullet)
	    if round (distance (px + 10, bullet (x).x, py + 10, bullet (x).y)) <= 12 then
		bullet (x).playerHit := true
		result bullet (x).bType
	    end if
	end for
	result 0
    end playerHit
    proc shoot (angle, x, y, len, speed : real, currentMap : ^tileSystem, btype : int)
	new bullet, upper (bullet) + 1
	myMap := currentMap
	bullet (upper (bullet)).ex := x
	bullet (upper (bullet)).ey := y
	bullet (upper (bullet)).vX := cosd (angle) * speed
	bullet (upper (bullet)).vY := sind (angle) * speed
	bullet (upper (bullet)).len := len
	bullet (upper (bullet)).angle := angle
	bullet (upper (bullet)).x := cosd (angle) * len + x
	bullet (upper (bullet)).y := sind (angle) * len + y
	bullet (upper (bullet)).currentMap := currentMap
	bullet (upper (bullet)).doubleCheck := false
	bullet (upper (bullet)).maxDis := MaxDis (angle, x, y, currentMap)
	if MaxDis (angle, bullet (upper (bullet)).x, bullet (upper (bullet)).y, currentMap) > bullet (upper (bullet)).maxDis then
	    bullet (upper (bullet)).maxDis := MaxDis (angle, bullet (upper (bullet)).x, bullet (upper (bullet)).y, currentMap)
	end if
	bullet (upper (bullet)).currentDis := 0
	bullet (upper (bullet)).speed := speed
	bullet (upper (bullet)).playerHit := false
	bullet (upper (bullet)).bType := btype
    end shoot

    proc run (shiftX, shiftY : real)
	for x : 1 .. upper (bullet)
	    if collide (bullet (x).ex / 16, bullet (x).ey / 16, myMap) or collide (bullet (x).x / 16, bullet (x).y / 16, myMap) then
		bullet (x).doubleCheck := true
	    end if

	    if not bullet (x).currentDis + bullet (x).speed >= bullet (x).maxDis or bullet (x).playerHit and not bullet (x).doubleCheck then
		bullet (x).ex += bullet (x).vX
		bullet (x).ey += bullet (x).vY
		bullet (x).x += bullet (x).vX
		bullet (x).y += bullet (x).vY
		bullet (x).currentDis += bullet (x).speed
		Draw.ThickLine (round (bullet (x).ex) - round (shiftX), round (bullet (x).ey) - round (shiftY), round (bullet (x).x) - round (shiftX), round (bullet (x).y) - round (shiftY),
		    3, grey)
	    end if
	end for

	var num : int := 0
	var remove : flexible array 0 .. -1 of int

	for i : 1 .. upper (bullet)
	    if bullet (i).currentDis + bullet (i).speed >= bullet (i).maxDis or bullet (i).playerHit or bullet (i).doubleCheck then
		if bullet (i).playerHit then
		    particleSystem (blood).execute (1, round (bullet (i).x - shiftX), round (bullet (i).y - shiftY))
		else
		    particleSystem (explosion).execute (5, round (bullet (i).x - shiftX), round (bullet (i).y - shiftY))
		end if
		new remove, upper (remove) + 1
		remove (upper (remove)) := i - upper (remove)
	    end if
	end for
	for i : 0 .. upper (remove)
	    for j : remove (i) .. upper (bullet) - 1
		bullet (j) := bullet (j + 1)
	    end for
	    new bullet, upper (bullet) - 1
	end for

	particleSystem (explosion).RunParticle
	particleSystem (blood).RunParticle
    end run
end bulletClass

