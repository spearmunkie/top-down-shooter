unit
class AI
    export setPatrol, move, angX, angY, shoot, patrolling
    var patrol : boolean := true
    var startX, startY, endX, endY : real
    var stop : int := Time.Elapsed
    var angleX, angleY : real := 0
    var away : boolean := false
    fcn Distance (x1, y1, x2, y2 : real) : real
	result sqrt ((x1 - x2) ** 2 + (y1 - y2) ** 2)
    end Distance

    fcn onScreen (x, y, shiftX, shiftY : real) : boolean
	result (x * 16 - shiftX >= 0 and x * 16 - shiftX <= maxx and y * 16 - shiftY > 0 and y - shiftY * 16 < maxy) and (x * 16 - shiftX + 16 >= 0 and x * 16 - shiftX + 16 <= maxx and y * 16 -
	    shiftY + 16 > 0 and y * 16 - shiftY + 16 < maxy)
    end onScreen
    fcn patrolling : boolean
	result patrol
    end patrolling
    proc setPatrol (x, y, x2, y2 : real)
	startX := x
	startY := y
	endX := x2
	endY := y2
    end setPatrol
    fcn angX : real
	result angleX
    end angX

    fcn angY : real
	result angleY
    end angY
    fcn move (px, py, ex, ey, MaxDis, shiftX, shiftY : real) : int
	if (ceil (px) = ceil (ex) or ceil (py) = ceil (ey)) and onScreen (ex, ey, shiftX, shiftY) then
	    patrol := false
	end if
	if not onScreen (ex, ey, shiftX, shiftY) then
	    patrol := true
	end if
	if not patrol then
	    angleX := px * 16
	    angleY := py * 16
	    if MaxDis <= Distance (px * 16, py * 16, ex * 16, ey * 16) and not patrol then
		if px > ex then
		    result 3
		elsif px < ex then
		    result 4
		end if
		if py > ey then
		    result 1
		elsif py < ey then
		    result 2
		end if
		result 0
	    end if
	end if

	if ex = endX and ey = endY then
	    away := false
	    stop := Time.Elapsed
	end if

	if ex = startX and ey = startY then
	    away := true
	    stop := Time.Elapsed
	end if

	if patrol and away /*and Time.Elapsed >= stop + 1000*/ then
	    angleX := endX * 16
	    angleY := endY * 16
	    if endX > ex then
		result 3
	    elsif endX < ex then
		result 4
	    end if
	    if endY > ey then
		result 1
	    elsif endY < ey then
		result 2
	    end if
	end if

	if patrol and not away /*and Time.Elapsed >= stop + 1000*/ then
	    angleX := startX * 16
	    angleY := startY * 16
	    if startX > ex then
		result 3
	    elsif startX < ex then
		result 4
	    end if
	    if startY > ey then
		result 1
	    elsif startY < ey then
		result 2
	    end if
	end if
	result 0
    end move

    fcn shoot (dir : int) : boolean
	result (not patrol) and (dir = 0)
    end shoot
end AI
