-- Zauberstab Mod für Minetest

modname = minetest.get_current_modname()
local function transform_to_random_animal(entity)
    local animals = {
        {texture = "mobs_kitten_black.png", mesh = "mobs_kitten.b3d"},
        {texture = "mobs_cow.png", mesh = "mobs_cow.b3d"},
        {texture = "mobs_pumba.png", mesh = "mobs_pumba.b3d"}
    } -- Namen der Tiere aus der "mobs_animal" Mod
    local random_animal = animals[math.random(#animals)]
    
    entity:set_properties({
        textures = {random_animal.texture},
        mesh = random_animal.mesh
    })
   
    local original_pos = entity:get_pos()
    
    minetest.after(10, function()
        if entity:is_player() then
            entity:set_pos(original_pos)  -- Zurück zur ursprünglichen Position
        end
    end)
end

-- Registriere den Zauberstab
minetest.register_tool(modname..":wabbajack_wand", {
    description = "Wabbajack Wand",
    inventory_image = "wabbajack_wand.png", -- Füge das Bild deines Zauberstabs hinzu
    on_use = function(itemstack, user, pointed_thing)
        local player_name = user:get_player_name()
        
        -- Überprüfe ob der Spieler einen Diamantblock hat
        if not minetest.get_inventory({type="player", name=player_name}):contains_item("main", "default:diamondblock") then
            minetest.chat_send_player(player_name, "Du benötigst einen Diamantblock, um den Zauber zu wirken.")
            return
        end

        -- Überprüfe ob der Spieler einen gültigen Zielblock ausgewählt hat
        if pointed_thing.type == "object" then
            local target = pointed_thing.ref
            local target_pos = target:get_pos()
            local distance = vector.distance(user:get_pos(), target_pos)

            -- Überprüfe ob das Ziel ein Spieler oder Mob ist und im Bereich von 10 Blöcken ist
            if distance <= 10 and (target:is_player() or (target:is_player() == false and target:get_luaentity() and target:get_luaentity().name:match("mobs_animal:"))) then
                -- Verzaubere den Spieler oder Mob für 1 Minute
                transform_to_random_animal(target)

                -- Entferne einen Diamantblock aus dem Inventar des Spielers
                minetest.get_inventory({type="player", name=player_name}):remove_item("main", "default:diamondblock")
            else
                minetest.chat_send_player(player_name, "Das Ziel ist zu weit entfernt oder nicht gültig.")
            end
        else
            minetest.chat_send_player(player_name, "Du musst einen Spieler oder Mob auswählen.")
        end
    end,
})

-- Füge Crafting-Rezept für den Zauberstab hinzu
minetest.register_craft({
    output = modname..":wabbajack_wand",
    recipe = {
        {"", "default:diamond", ""},
        {"", "default:stick", ""},
        {"", "default:diamond", ""},
    },
})

print("[MOD] Zauberstab Mod geladen")
