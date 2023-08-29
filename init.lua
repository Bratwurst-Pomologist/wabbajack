modname = minetest.get_current_modname()

local function transform_to_random_animal(entity)
    local animals = {
        {texture = "mobs_kitten_black.png", mesh = "mobs_kitten.b3d"},
        {texture = "mobs_kitten_ginger.png", mesh = "mobs_kitten.b3d"},
        {texture = "mobs_kitten_sandy.png", mesh = "mobs_kitten.b3d"},
        {texture = "mobs_kitten_splotchy.png", mesh = "mobs_kitten.b3d"},
        {texture = "mobs_kitten_striped.png", mesh = "mobs_kitten.b3d"},
        {texture = "mobs_cow.png", mesh = "mobs_cow.b3d"},
        {texture = "mobs_cow2.png", mesh = "mobs_cow.b3d"},
        {texture = "mobs_pumba.png", mesh = "mobs_pumba.b3d"},
        {texture = "mobs_bee.png", mesh = "mobs_bee.b3d"},
        {texture = "mobs_bunny_grey.png", mesh = "mobs_bunny.b3d"},
        {texture = "mobs_bunny_white.png", mesh = "mobs_bunny.b3d"},
        {texture = "mobs_bunny_evil.png", mesh = "mobs_bunny.b3d"},
        {texture = "mobs_bunny_brown.png", mesh = "mobs_bunny.b3d"},
        {texture = "mobs_chick.png", mesh = "mobs_chicken.b3d"},
        {texture = "mobs_chicken.png", mesh = "mobs_chicken.b3d"},
        {texture = "mobs_chicken_black.png", mesh = "mobs_chicken.b3d"},
        {texture = "mobs_chicken_brown.png", mesh = "mobs_chicken.b3d"},
        {texture = "mobs_chicken_white.png", mesh = "mobs_chicken.b3d"},
    }
    local random_animal = animals[math.random(#animals)]

    local sounds = dofile(minetest.get_modpath(modname).."/sounds_conf.lua")
    local randomSound = sounds[math.random(1, #sounds)]
    
    -- Store the original properties
    local original_properties = {
        textures = entity:get_properties().textures,
        mesh = entity:get_properties().mesh
    }
    
    -- Check if the entity is currently under enchantment
    local is_enchanted = entity:get_luaentity() and entity:get_luaentity().enchanted
    
    if not is_enchanted then
        minetest.sound_play(randomSound, {pos = pos, gain = 1.0, max_hear_distance = 32})
        entity:set_properties({
            textures = {random_animal.texture},
            mesh = random_animal.mesh
        })

        -- Mark the entity as enchanted
        entity:get_luaentity().enchanted = true
        
        minetest.after(10, function()
            local original_pos = entity:get_pos()  -- saves original position
            if entity:is_player() then
                entity:set_pos(original_pos)  -- Zurück zur ursprünglichen Position
            else
                -- Revert to the original properties
                entity:set_properties(original_properties)
                
                -- Reset the enchanted flag
                entity:get_luaentity().enchanted = false
                
                entity:set_pos(original_pos)  -- Porte das Mob zurück zum ursprünglichen Standort
            end
        end)
    end
end

local function apply_explosion_effect(pos)
    -- Erzeuge eine Explosion an der angegebenen Position
    minetest.add_particle({
        pos = pos,
        velocity = {x = 0, y = 0, z = 0},
        acceleration = {x = 0, y = 0, z = 0},
        expirationtime = 0.1,
        size = 10,
        collisiondetection = true,
        collision_removal = true,
        object_collision = true,
        vertical = false,
        texture = "fire_basic_flame.png",
    })
end

minetest.register_tool(modname..":wabbajack_wand", {
    description = "Wabbajack Wand",
    inventory_image = "wabbajack_wand.png",
    -- on_use start
    on_use = function(itemstack, user, pointed_thing)
      -- auswahl zufälliger Effekt 
      local random_effect = math.random(1,2)
      if random_effect == 1 then
        
        local player_name = user:get_player_name()
        
        local inv = minetest.get_inventory({type="player", name=player_name})
        
        if not inv:contains_item("main", "default:diamondblock") then
            minetest.chat_send_player(player_name, "Du benötigst einen Diamantblock, um den Zauber zu wirken.")
            return
        end

        if pointed_thing.type == "object" then
            local target = pointed_thing.ref
            local target_pos = target:get_pos()
            local distance = vector.distance(user:get_pos(), target_pos)

            if distance <= 10 and (target:is_player() or (target:is_player() == false and target:get_luaentity() --[[and target:get_luaentity().name:match("mobs_animal:")]])) then
                local is_enchanted = target:get_luaentity() and target:get_luaentity().enchanted
                
                if is_enchanted then
                    minetest.chat_send_player(player_name, "Das Ziel ist bereits verzaubert.")
                else
                    transform_to_random_animal(target)
                    inv:remove_item("main", "default:diamondblock")
                end
            else
                minetest.chat_send_player(player_name, "Das Ziel ist zu weit entfernt oder nicht gültig.")
            end
        else
            minetest.chat_send_player(player_name, "Du musst einen Spieler oder Mob auswählen.")
        end
        else
        -- 2. Effekt
        if pointed_thing.type == "node" then
        local target_pos = pointed_thing.under
        apply_explosion_effect(target_pos)
    elseif pointed_thing.type == "object" then
        local target_pos = pointed_thing.ref:get_pos()
        apply_explosion_effect(target_pos)
    end
        end
    end,
    -- on_use end
})

minetest.register_craft({
    output = modname..":wabbajack_wand",
    recipe = {
        {"", "default:diamond", ""},
        {"", "default:stick", ""},
        {"", "default:diamond", ""},
    },
})

print("[MOD] Zauberstab Mod geladen")


-------

--[[
-- Registrierung des Wabbajack-Items
minetest.register_craftitem("wabbajack:wabbajack", {
    description = "Wabbajack",
    inventory_image = "wabbajack.png",
    on_use = function(itemstack, user, pointed_thing)
        -- Zufälligen Effekt auswählen
        local random_effect = math.random(1, 3)  -- Zum Beispiel 3 mögliche Effekte
        if random_effect == 1 then
            -- Führe den Effekt 1 aus
        elseif random_effect == 2 then
            -- Führe den Effekt 2 aus
        else
            -- Führe den Effekt 3 aus
        end
        itemstack:take_item()  -- Verbrauche den Wabbajack nach Benutzung
        return itemstack
    end,
})

-- Registrierung der Rezept für den Wabbajack
minetest.register_craft({
    output = "wabbajack:wabbajack",
    recipe = {
        {"default:diamond", "default:gold_ingot", "default:diamond"},
        {"default:gold_ingot", "default:stick", "default:gold_ingot"},
        {"default:diamond", "default:gold_ingot", "default:diamond"},
    },
})
]]

--[[-- wabbajack.lua

-- ... (vorheriger Code)

-- Funktion für den Explosionseffekt
local function apply_explosion_effect(pos)
    -- Erzeuge eine Explosion an der angegebenen Position
    minetest.add_particle({
        pos = pos,
        velocity = {x = 0, y = 0, z = 0},
        acceleration = {x = 0, y = 0, z = 0},
        expirationtime = 0.1,
        size = 10,
        collisiondetection = true,
        collision_removal = true,
        object_collision = true,
        vertical = false,
        texture = "fire_basic_flame.png",
    })
end

-- Im on_use-Event den Explosionseffekt anwenden
on_use = function(itemstack, user, pointed_thing)
    if pointed_thing.type == "node" then
        local target_pos = pointed_thing.under
        apply_explosion_effect(target_pos)
    elseif pointed_thing.type == "object" then
        local target_pos = pointed_thing.ref:get_pos()
        apply_explosion_effect(target_pos)
    end
    itemstack:take_item()  -- Verbrauche den Wabbajack nach Benutzung
    return itemstack
end

-- ... (weiterer Code)
]]