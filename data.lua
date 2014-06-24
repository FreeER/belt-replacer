data:extend(
{
  {
    type = "item",
    name = "replacer",
    place_result = "replacer",
    icon = "__base__/graphics/icons/creeper.png",
    flags = {"goes-to-quickbar"},
    subgroup = "belt",
    order = "a-a",
    stack_size = 10,
    enabled = true
  },
  {
    type = "recipe",
    name = "replacer",
    icon = "__base__/graphics/icons/creeper.png",
    energy_required = 1,
    ingredients = {{"iron-plate", 1}},
    enabled = "false",
    result = "replacer"
  },
  {
    type = "technology",
    name = "replacer",
    icon = "__belt-replacer__/graphics/technology/replacer-tech.png",
    prerequisites = {"logistics-2"},
    effects =
      {
        {
          type = "unlock-recipe",
          recipe = "replacer"
        }
      },
    unit =
      {
        count = 40,
        ingredients =
          {
            {"science-pack-1", 2},
            {"science-pack-2", 2}
          },
        time = 15
      }
  },
  {
    type = "unit",
    name = "replacer",
    icon = "__base__/graphics/icons/creeper.png",
    flags = {"placeable-player", "placeable-enemy", "placeable-off-grid", "breaths-air", "not-repairable"},
    minable = {mining_time = 1, result = "replacer"},
    max_health = 5,
    order="b-b-b",
    -- subgroup="enemies",
    resistances = 
    {
      {
        type = "physical",
        decrease = 4,
      },
      {
        type = "explosion",
        percent = 10
      }
    },
    healing_per_tick = 0.01,
    collision_box = {{-0.3, -0.3}, {0.3, 0.3}},
    selection_box = {{-0.7, -1.5}, {0.7, 0.3}},
    sticker_box = {{-0.3, -0.5}, {0.3, 0.1}},
    distraction_cooldown = 300,
    attack_parameters =
    {
      ammo_category = "melee",
      ammo_type = make_unit_melee_ammo_type(15),
      range = 1,
      cooldown = 35,
      sound =
      {
        {
          filename = "__base__/sound/creatures/biter-roar-medium-1.ogg",
          volume = 0.8
        },
        {
          filename = "__base__/sound/creatures/biter-roar-medium-2.ogg",
          volume = 0.8
        }
      },
      animation =
      {
        frame_width = 200,
        frame_height = 132,
        frame_count = 11,
        direction_count = 16,
        axially_symmetrical = false,
        shift = {1.25719, -0.464063},
        stripes =
        {
          {
            filename = "__base__/graphics/entity/medium-biter/medium-biter-attack-1.png",
            width_in_frames = 6,
            height_in_frames = 8
          },
          {
            filename = "__base__/graphics/entity/medium-biter/medium-biter-attack-2.png",
            width_in_frames = 5,
            height_in_frames = 8
          },
          {
            filename = "__base__/graphics/entity/medium-biter/medium-biter-attack-3.png",
            width_in_frames = 6,
            height_in_frames = 8
          },
          {
            filename = "__base__/graphics/entity/medium-biter/medium-biter-attack-4.png",
            width_in_frames = 5,
            height_in_frames = 8
          }
        }
      }
    },
    vision_distance = 30,
    movement_speed = 0.185,
    distance_per_frame = 0.15,
    -- in pu
    pollution_to_join_attack = 1000000,
    corpse = "medium-biter-corpse",
    dying_sound =
    {
      {
        filename = "__base__/sound/creatures/creeper-death-1.ogg",
        volume = 0.7
      },
      {
        filename = "__base__/sound/creatures/creeper-death-2.ogg",
        volume = 0.7
      },
      {
        filename = "__base__/sound/creatures/creeper-death-3.ogg",
        volume = 0.7
      },
      {
        filename = "__base__/sound/creatures/creeper-death-4.ogg",
        volume = 0.7
      }
    },
    run_animation =
    {
      filename = "__base__/graphics/entity/medium-biter/medium-biter-run.png",
      still_frame = 4,
      frame_width = 122,
      frame_height = 84,
      frame_count = 16,
      direction_count = 16,
      axially_symmetrical = false,
      shift = {0.514688, -0.219375},
    }
  }
})


-- create recipes with the belt speed in the name for accessing the data
-- in the control.lua (so it can be sorted and allow for replacing belt
-- corners with a faster belt)
recipes = {}
for _, belt in pairs(data.raw["transport-belt"]) do
  table.insert(recipes,
    {
      type = "recipe",
      -- * 1000000 to remove the decimal point which was causing a "Note with type recipe does not have name" error
      name = table.concat({"replacermod-[[", belt.speed*1000000, "]]", belt.name}),
      --name = "something",
      enabled = "false",
      ingredients = {},
      result = belt.name
    })
end
data:extend(recipes)
