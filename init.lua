modname = minetest.get_current_modname()

local config = Settings(minetest.get_modpath(modname).."/wabbajack.conf")
local wj_radius = tonumber(config:get("wj_radius")) or 3

local function item_enchant(entity, user)
   local drop_items = math.random(10, 25)
   local pos_2 = entity:get_pos()
   --[[if entity:get_pos() ~= nil then
        local pos = entity:get_pos()
        else local pos = pos
        end]]
   if drop_items > 9 then
   minetest.chat_send_player(user:get_player_name(), "drop_items is set to "..drop_items)
   end
   local div_basis = drop_items
   local drop_items_2 = drop_items
    local item_names = {"default:diamond", "default:gold_ingot", "default:apple"}
    
    local function drop_item()
        local pos = entity:get_pos()
        local sounds = dofile(minetest.get_modpath(modname).."/drop_sound_conf.lua")
        local randomSound = sounds[math.random(1, #sounds)]
        local random_item = item_names[math.random(1, #item_names)]
        minetest.add_item(pos or pos_2, random_item)
        
        drop_items_2 = drop_items_2 - 1
        if drop_items_2 > 0 then
            local drop_interval = 10 / div_basis -- Abstand basierend auf erster Zahl von drop_items
            minetest.chat_send_player(user:get_player_name(), "drop_interval is set to "..drop_interval)
            minetest.sound_play(randomSound, {pos = pos, gain = 1.0, max_hear_distance = 32})
            minetest.after(drop_interval, drop_item)
        end
    end
    drop_item()
end



local function transform_to_random_animal(entity)
    local animals = {
        {texture = "mobs_kitten_black(1).png", mesh = "mobs_kitten.b3d"},
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
                 local lua_entity = entity:get_luaentity()
                  if lua_entity then
                    entity:get_luaentity().enchanted = false
                  end
                  
                entity:set_pos(original_pos)  -- Porte das Mob zurück zum ursprünglichen Standort
            end
        end)
    end
end

minetest.register_tool(modname..":wabbajack_wand", {
    description = "Wabbajack Wand",
    inventory_image = "wabbajack_wand.png",
    -- on_use start
    on_use = function(itemstack, user,  pointed_thing)
      -- auswahl zufälliger Effekt 
      local random_effect = math.random(1,3)
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
        -- 2. Effekt
        elseif random_effect == 2 then
        if pointed_thing.type == "node" then
        local target_pos = pointed_thing.under
        tnt.boom(target_pos, {radius = 3})
        elseif pointed_thing.type == "object" then
        local target_pos = pointed_thing.ref:get_pos()
        tnt.boom(target_pos, {radius = wj_radius})
        end
        -- 3. Effekt 
        else
        
        if pointed_thing.type == "object" then
        local target = pointed_thing.ref
        item_enchant(target, user)
    end
    return itemstack
    end
    -- Ende des random Effekts
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
