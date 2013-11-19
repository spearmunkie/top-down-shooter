%saurabh
unit
class particleSystem
    export execute, RunParticle, atributes
    type vector :
	record
	    x : real
	    y : real
	    vY : real
	    vX : real
	    duration : int
	    clr : int
	end record
    var resistence : real := 1.05
    var maxDuration : int := 2500
    var pullY : real := -.98
    var pullX : real := 0
    var pClr : int := white
    var spitOut : int := 10
    var maxParticle : int := 2000

    var CurrentParticle : int := 0
    var particles : flexible array 0 .. 0 of vector

    proc DrawParticle (current : int)
	%drawdot (round (particles (current).x), round (particles (current).y), particles (current).clr)
	var dir_x, dir_y, dist : real := 0
	dist := sqrt (particles (current).vX ** 2 + particles (current).vY ** 2)
	if dist not= 0 then
	    dir_x := ((particles (current).vX / dist * 10) + particles (current).vX)
	    dir_y := ((particles (current).vY / dist * 10) + particles (current).vY)
	end if
	drawline (round (particles (current).x), round (particles (current).y), round (particles (current).x - dir_x), round (particles (current).y - dir_y), particles (current).clr)
    end DrawParticle

    fcn onScreen (x, y : real) : boolean
	result x >= 0 and x <= maxx and y >= 0 and y <= maxy
    end onScreen

    procedure RunParticle
	for x : 1 .. upper (particles)
	    if particles (x).duration < maxDuration then
		particles (x).duration += 1
		particles (x).vY := (particles (x).vY + pullY) / resistence
		particles (x).vX := (particles (x).vX + pullX) / resistence
		particles (x).y := (particles (x).y + particles (x).vY)
		particles (x).x := (particles (x).x + particles (x).vX)
		if not onScreen (particles (x).x, particles (x).y) then
		    particles (x).duration := maxDuration
		end if
		if particles (x).duration < maxDuration then
		    DrawParticle (x)
		end if
	    end if
	end for
    end RunParticle

    procedure CreateParticle (x, y : real)
	var angle : real
	var radii : real
	if CurrentParticle > maxParticle then
	    CurrentParticle := 1
	end if
	if CurrentParticle + 1 > upper (particles) then
	    new particles, upper (particles) + 1
	end if
	CurrentParticle += 1
	particles (CurrentParticle).duration := 1
	particles (CurrentParticle).clr := pClr
	particles (CurrentParticle).duration := 1
	particles (CurrentParticle).x := x
	particles (CurrentParticle).y := y
	angle := Rand.Int (1, 360)
	radii := Rand.Int (1, 12)
	particles (CurrentParticle).vX := radii * cosd (angle)
	particles (CurrentParticle).vY := radii * sind (angle)
	DrawParticle (CurrentParticle)
    end CreateParticle

    proc execute (times, x, y : int)
	for b : 1 .. times
	    for k : 1 .. spitOut
		CreateParticle (x, y)
	    end for
	end for
    end execute

    proc atributes (pX, pY : real, colour, duration, out, maxP : int)
	pullX := pX
	pullY := pY
	pClr := colour
	maxDuration := duration
	spitOut := out
	maxParticle := maxP
    end atributes

end particleSystem
