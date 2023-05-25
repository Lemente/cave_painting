-- put this into a mod that depends on "default" and "cave_painting"
-- included examples:
--   * default:coal_lump    -> basic (constant color, size = 1)
--   * default:coalblock    -> custom size (size = 3)
--   * default:apple        -> remover
--   * default:diamondblock -> dynamic color (rainbow-like)

local ggraffiti_range = minetest.registered_items["ggraffiti:spray_can_red"].range
local ggraffiti_on_use = minetest.registered_items["ggraffiti:spray_can_red"].on_use

--[[
 #dea31e
 #b3682f
 #a2402b
 #6c2d34
brun () #623e2d
marron (terre de sienne) #6a321a
noir (manganèse) #0d0300
blanc (kaolin) #fffaf1
]]
-- The color of the pixel at (8, 9) (probably 0-based indexing) in the dye texture.
local cave_dyes = {
    { name = "blanc_kaolin", desc = "blanc (kaolin)", color = "#edf6fd", tex = "moreores_mithril_lump" },
--    { name = "A_jaune_ocre", desc = "A_d09c53", color = "#d09c53" },
--   { name = "A_rouge_ocre", desc = "A_943b2d", color = "#943b2d" },
    { name = "brun_terre_dombre", desc = "brun (terre d'ombre)", color = "#9c7c49", tex = "default_gold_lump"  },
--    { name = "A_marron_terre_de_Sienne", desc = "A_2a1713", color = "#2a1713" },
    { name = "noir_manganese", desc = "noir (manganèse)", color = "#0e0c0d", tex = "default_coal_lump"  },

--    { name = "B_blanc (kaolin)", desc = "", color = "#" },
    { name = "ocre_jaune", desc = "ocre jaune", color = "#dea31e", tex = "default_lump_sulfur"  },
    { name = "ocre_rouge", desc = "ocre rouge", color = "#a2402b", tex = "moreores_mithril_lump"  },
    { name = "ocre_pourpre", desc = "ocre pourpre", color = "#6c2d34", tex = "moreores_mithril_lump"  },
    { name = "orange_terre_de_sienne", desc = "orange (terre de sienne)", color = "#b3682f", tex = "default_lump_bronze"  },
--    { name = "B_marron", desc = "B_marron", color = "#623e2d" },
    { name = "marron_terre_de_Sienne_brulee", desc = "marron (terre de Sienne brûlée)", color = "#541202", tex = "moreores_mithril_lump"  },
--    { name = "B_noir_manganese", desc = "0d0300", color = "#0d0300" },

}

minetest.override_item("default:coal_lump", {
    range = ggraffiti_range,
    on_use = function(item, player, pointed_thing)
        local meta = item:get_meta()
        meta:set_int("ggraffiti_size", 3)
        return ggraffiti_on_use(item, player, pointed_thing)
    end,
    _ggraffiti_spray_can = {
        color = "#111100",
    },
})


local function cave_painting_change_brush_size(itemstack, placer, pointed_thing)

    local meta = itemstack:get_meta()
    local current_size = tonumber(meta:get_int("ggraffiti_size"))
    minetest.chat_send_player(placer:get_player_name(), "taille actuelle = " .. current_size)
    if current_size == 0 or current_size == 1 then
        meta:set_int("ggraffiti_size", 2)
        itemstack:get_meta():set_string("count_meta", "taille 2")
        minetest.chat_send_player(placer:get_player_name(), itemstack:get_name() .."taille 2")
    elseif current_size == 2 then
        meta:set_int("ggraffiti_size", 3)
        itemstack:get_meta():set_string("count_meta", "taille 3")
        minetest.chat_send_player(placer:get_player_name(), itemstack:get_name() .."taille 3")
    elseif current_size == 3 then
        meta:set_int("ggraffiti_size", 1)
        itemstack:get_meta():set_string("count_meta", "taille 1")
        minetest.chat_send_player(placer:get_player_name(), itemstack:get_name() .."taille 1")
    end
    return itemstack
end

for _, color in ipairs(cave_dyes) do
    local item_name = "cave_painting:spray_can_" .. color.name

    minetest.register_craftitem(item_name, {
        description = (color.desc),
        inventory_image = color.tex .. ".png^[colorize:" .. color.color ..":255",

        range = ggraffiti_range,
        on_use = ggraffiti_on_use,

        on_place = cave_painting_change_brush_size,

        _ggraffiti_spray_can = {
            color = color.color,
        },
    })
end




-- https://stackoverflow.com/a/68323185
local function hslToRgb(h, s, l)
    h = h / 360
    s = s / 100
    l = l / 100

    local r, g, b

    if s == 0 then
        r, g, b = l, l, l -- achromatic
    else
        local function hue2rgb(p, q, t)
            if t < 0 then t = t + 1 end
            if t > 1 then t = t - 1 end
            if t < 1 / 6 then return p + (q - p) * 6 * t end
            if t < 1 / 2 then return q end
            if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
            return p
        end

        local q = l < 0.5 and l * (1 + s) or l + s - l * s
        local p = 2 * l - q
        r = hue2rgb(p, q, h + 1 / 3)
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - 1 / 3)
    end

    return r * 255, g * 255, b * 255
end

local function update_color(item)
    local t = math.floor(minetest.get_us_time() / 10000)
    local h, s, l = t % 360, t % 100, 50 + (t + 388) % 50
    local r, g, b = hslToRgb(h, s, l)
    local rgb = { r = r, g = g, b = b}

    local meta = item:get_meta()
    meta:set_string("ggraffiti_rgb_color", minetest.serialize(rgb))
end

-- dynamic color (rainbow-like)
minetest.override_item("default:diamondblock", {
    range = ggraffiti_range,
    on_use = function(item, player, pointed_thing)
        update_color(item)
        return ggraffiti_on_use(item, player, pointed_thing)
    end,
    _ggraffiti_spray_can = {
        rgb = true,
    },
})

minetest.register_globalstep(function()
    for _, player in ipairs(minetest.get_connected_players()) do
        local item = player:get_wielded_item()
        local control = player:get_player_control()
        if item:get_name() == "default:diamondblock" and control.dig then
            update_color(item)
            player:set_wielded_item(item)
        end
    end
end)