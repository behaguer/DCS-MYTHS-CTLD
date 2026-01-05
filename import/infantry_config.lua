-----------------[[ infantry_config.lua ]]-----------------

-- ************** WEIGHT CALCULATIONS FOR INFANTRY GROUPS ******************

-- Infantry groups weight is calculated based on the soldiers' roles, and the weight of their kit
-- Every soldier weights between 90% and 120% of ctld.SOLDIER_WEIGHT, and they all carry a backpack and their helmet (ctld.KIT_WEIGHT)
-- Standard grunts have a rifle and ammo (ctld.RIFLE_WEIGHT)
-- AA soldiers have a MANPAD tube (ctld.MANPAD_WEIGHT)
-- Anti-tank soldiers have a RPG and a rocket (ctld.RPG_WEIGHT)
-- Machine gunners have the squad MG and 200 bullets (ctld.MG_WEIGHT)
-- JTAC have the laser sight, radio and binoculars (ctld.JTAC_WEIGHT)
-- Mortar servants carry their tube and a few rounds (ctld.MORTAR_WEIGHT)

ctld.SOLDIER_WEIGHT = 80 -- kg, will be randomized between 90% and 120%
ctld.KIT_WEIGHT = 20     -- kg
ctld.RIFLE_WEIGHT = 5    -- kg
ctld.MANPAD_WEIGHT = 18  -- kg
ctld.RPG_WEIGHT = 7.6    -- kg
ctld.MG_WEIGHT = 10      -- kg
ctld.MORTAR_WEIGHT = 26  -- kg
ctld.JTAC_WEIGHT = 15    -- kg

-- ************** INFANTRY GROUPS FOR PICKUP ******************
-- Unit Types
-- inf is normal infantry
-- mg is M249
-- at is RPG-16
-- aa is Stinger or Igla
-- mortar is a 2B11 mortar unit
-- jtac is a JTAC soldier, which will use JTACAutoLase
-- You must add a name to the group for it to work
-- You can also add an optional coalition side to limit the group to one side
-- for the side - 2 is BLUE and 1 is RED
ctld.loadableGroups = {
    { name = ctld.i18n_translate("Standard Group"),                   inf = 6,    mg = 2,  at = 2 }, -- will make a loadable group with 6 infantry, 2 MGs and 2 anti-tank for both coalitions
    { name = ctld.i18n_translate("Anti Air"),                         inf = 2,    aa = 3 },
    { name = ctld.i18n_translate("Anti Tank"),                        inf = 2,    at = 6 },
    { name = ctld.i18n_translate("Mortar Squad"),                     mortar = 6 },
    { name = ctld.i18n_translate("JTAC Group"),                       inf = 4,    jtac = 1 }, -- will make a loadable group with 4 infantry and a JTAC soldier for both coalitions
    { name = ctld.i18n_translate("Single JTAC"),                      jtac = 1 }, -- will make a loadable group witha single JTAC soldier for both coalitions
    { name = ctld.i18n_translate("2x - Standard Groups"),             inf = 12,   mg = 4,  at = 4 },
    { name = ctld.i18n_translate("2x - Anti Air"),                    inf = 4,    aa = 6 },
    { name = ctld.i18n_translate("2x - Anti Tank"),                   inf = 4,    at = 12 },
    { name = ctld.i18n_translate("2x - Standard Groups + 2x Mortar"), inf = 12,   mg = 4,  at = 4, mortar = 12 },
    { name = ctld.i18n_translate("3x - Standard Groups"),             inf = 18,   mg = 6,  at = 6 },
    { name = ctld.i18n_translate("3x - Anti Air"),                    inf = 6,    aa = 9 },
    { name = ctld.i18n_translate("3x - Anti Tank"),                   inf = 6,    at = 18 },
    { name = ctld.i18n_translate("3x - Mortar Squad"),                mortar = 18 },
    { name = ctld.i18n_translate("5x - Mortar Squad"),                mortar = 30 },
    -- {name = ctld.i18n_translate("Mortar Squad Red"), inf = 2, mortar = 5, side =1 }, --would make a group loadable by RED only
}
-----------------[[ END OF infantry_config.lua ]]-----------------
