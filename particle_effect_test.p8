pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
function deep_copy(table)
    local t = {}
    for k,v in pairs(table) do
        t[k] = v
    end
    return t
end

function random(x,y)
    if(x < y) then
        return rnd(y-x) + x
    elseif(x > y) then
        return rnd(x-y) + y
    else
        return x
    end
end

function create_particle(e)
    local p = {
        dx = random(e.p.dx_min, e.p.dx_max),
        dy = random(e.p.dy_min, e.p.dy_max),
        col = e.p.col,
        r = random(e.p.r_min,e.p.r_max),
        life = random(e.p.life_min,e.p.life_max),
        gravity = e.p.gravity
    }

    p.x = e.x
    p.y = e.y

    --[[if(e.p.x_min ~= nil and e.p.x_max ~= nil) then
        p.x += random(e.p.x_min, e.p.x_max)
    end

    if(e.p.y_min ~= nil and e.p.y_max ~= nil) then
        p.y += random(e.p.y_min, e.p.y_max)
    end]]

    add(particles,p)
end

function update_particle(p)
    p.x = p.x + p.dx
    p.y = p.y + p.dy
    if(p.gravity) then p.dy = p.dy + gravity end
    p.life = p.life - 1
    if(p.life <= 0) then del(particles,p) end
end

function create_emitter(e)
    local emitter = {

        -- the emitter
        x = e.x or 0,
        y = e.y or 0,
        dx=random(e.e_dx_min,e.e_dx_max) or 0,
        dy=random(e.e_dy_min,e.e_dy_max) or 0,
        dy_max = e.e_dy_max or 2,
        spawn_time = e.spawn_time or 2,
        life = e.e_life or nil,
        gravity = e.e_gravity or false,
        timer = 0,

        -- the particle
        p={
            x_min = e.p_x_min or 0,
            x_max = e.p_x_max or 0,
            y_min = e.p_y_min or 0,
            y_max = e.p_y_max or 0,
            r_min = e.r_min or 1,
            r_max = e.r_max or 1,
            dx_min = e.p_dx_min or -2,
            dx_max = e.p_dx_max or 2,
            dy_min = e.p_dy_min or -2,
            dy_max = e.p_dy_max or 2,
            gravity=e.p_gravity,
            col = e.col or 5,
            life_min = e.p_life_min or 5,
            life_max = e.p_life_max or 45,
        }
    }

    add(emitters,emitter)
end

function update_emitter(e)
    e.timer += 1
    e.x += e.dx
    e.y += e.dy

    --gravity
    if(e.gravity == true) then e.dy += 0.05 end

    -- spawn a particle
    if(e.timer >= e.spawn_time) then
        if(e.spawn_time < 1) then
            for i=1,ceil(1/e.spawn_time) do create_particle(e) end
        else
            create_particle(e)
        end
        e.timer = 0
    end

    -- delete the emitter
    if(e.life ~= nil) then
        e.life = e.life - 1
        if(e.life <= 0) then del(emitters,e) end
    end
end

function create_smoke(emitter)
    create_emitter({x=emitter.x,y=emitter.y,dx_min=-0.2,dx_max=0.2,dy_min=-1,dy_max=-0.1})
end

function create_sparks()
end

function create_explosion(o)
    local spd = 2.5
    create_emitter({x=o.x+4,y=o.y+4,r_min=0.5,r_max=2,col=random(1,15),dx_min=-spd,dx_max=spd,
        dy_min=-spd,dy_max=spd,e_life=10,spawn_time=0.1,p_gravity=true})
end

function create_firework_explosion(o)
    local num_trails = random(10,20)
    for i=1,num_trails do
        create_trail(o)
    end
end

function create_trail(o)
    if(o.typ == "firework") then
        local f = deep_copy(firework_trail)
        f.x = o.x+4
        f.y = o.y
        f.col=random(1,15)
        create_emitter(f)
    else
        local f = deep_copy(trail)
        f.x = o.x
        f.y = o.y+4
        f.e_dx_min = o.dx
        f.e_dx_max = o.dx
        f.col=random(1,15)
        create_emitter(f)
    end
end

function create_firework()
    local f = deep_copy(firework)
    f.x=random(16,128-16)
    f.y = 112
    f.dy=random(-5,-3)
    add(objects,f)
end

function create_rocket()
    local f = deep_copy(rocket)
    f.y = random(32,120)
    add(objects,f)
    create_trail(f)
end

function update_object(o)
    o.x = o.x + o.dx
    o.y = o.y + o.dy
    if(o.gravity) then
        o.dy = o.dy + gravity
    end

    --if(p.life <= 0) then
    if(o.typ == "firework") then
        if(o.dy >= 0) then
            create_firework_explosion(o)
            del(objects,o)
        end
    else
        if(o.x > 128) then del(objects,o) end
    end
end

function _init()

	emitters = {}
	particles = {}
    objects = {}
    timer = 0
    gravity = 0.2

    firework = {
        y=112,
        dx=0,
        gravity=true,
        img=4,
        typ="firework"
    }

    rocket = {
        x=0,
        y=64,
        dx=3,
        dy=0,
        gravity=false,
        img=2,
        typ="missile"
    }

    trail = {
        e_dx_min=0,
        e_dx_max=0,
        e_dy_min=0,
        e_dy_max=0,
        r_min=1,
        r_max=1,
        e_gravity=false,
        e_life = 100,
        spawn_time=3,
        p_gravity=false,
        p_x_min=-0,
        p_x_max=0,
        --p_y_min=o.y+4,
        --p_y_max=o.y+4,
        p_dx_min=0,
        p_dx_max=0,
        p_dy_min=0,
        p_dy_max=0,
        p_life_min = 5,
        p_life_max = 5,
    }

    firework_trail = {
        e_dx_min=-2,
        e_dx_max=2,
        e_dy_min=-2,
        e_dy_max=2,
        r_min=0.25,
        r_max=2,
        e_life=50,
        e_gravity=true,
        spawn_time=3,
        p_gravity=false,
        p_x_min=-4,
        p_x_max=4,
        --p_y_min=o.y+4,
        --p_y_max=o.y+4,
        p_dx_min=0,
        p_dx_max=0,
        p_dy_min=0,
        p_dy_max=0,
        p_life_min = 5,
        p_life_max = 30,
    }

    --create_smoke({x=64,y=100})
end

function _update()
    timer = (timer + 1) % 30

    -- update each emitter
    for e in all(emitters) do
        update_emitter(e)
    end

    -- update each particle
    for p in all(particles) do
        update_particle(p)
    end

    -- update each object
    for o in all(objects) do
        update_object(o)
    end

    if(btnp(4)) then
        create_firework()
        --create_rocket()
    end
end

function _draw()
	cls()

    for p in all(particles) do
        --circfill(p.x,p.y,p.r,p.col+timer%4)
        if(p.img ~= nil) then
            spr(p.img,p.x,p.y)
        else
            circ(p.x,p.y,p.r,p.col+timer%4)
        end
    end

    for o in all(objects) do
        spr(o.img+timer%2,o.x,o.y)
    end

    print("fps = " .. stat(7),0,16,7)
    print("cpu = " .. stat(1),0,24,7)
    print("count = " .. #particles,0,32,7)
    print("particle system test",24,0,7)
    print("fireworks",48,8,7)
end
__gfx__
0000000000008000099999000ccccc0000099000000cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000008880000090000000c00000098890000c11c0000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000088980000890090001c00c090088009c001100c00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000897980888888891111111c90088009c001100c00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000008997980888888891111111c99988999ccc11ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000897798000890090001c00c090888809c011110c00000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000089980000090000000c000090088009c001100c00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000088000099999000ccccc00000880000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000
