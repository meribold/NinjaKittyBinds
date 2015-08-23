-- Can we make a macro that targets our last target and works when a Hunter uses Play Dead and stuff? Maybe
--   /targetlasttarget [noexists]
-- or
--   /stopmacro [exists]
--   /targetlasttarget
--   /startattack [combat,nostealth]

-- Can't target totems by name: Healing Stream Totem, Windwalk Totem, Earthbind Totem, Earthgrab Totem, Mana Tide Totem,
-- Healing Tide Totem, Capacitor Totem, Spirit Link Totem, ...

-- I think "/use [@party1]Rejuvenation" while having a party1 but being far away causes Rejuvenation to wait for us
-- clicking a target (SpellIsTargeting()).  "/use [@party1,exists]Rejuvenation" is the same.  "/use [@party1,help]
-- Rejuvenation" doesn't do it.  This seems like a better fix than "/use 1"  which has the effect of the protected
-- function SpellStopTargeting() (1 is INVSLOT_HEAD, see: http://wowpedia.org/InventorySlotId).  "/use 0" doesn't work
-- for this.

-- Form numbers as of Patch 6.0.2.  No Form (0), Bear Form (1), Cat Form (2), Travel Form (3).  Doesn't match with
-- GetBonusBarOffset() return values.  Those are (according to http://wowpedia.org/API_GetBonusBarOffset): No Form (0),
-- Cat Form (1), Tree of Life (2), Bear Form (3) and Moonkin (4).  These keybindings don't fully work until all
-- shapeshifts are learned.  GetBonusBarOffset() return values don't change when leveling, so this function is useful to
-- make keybinds that work correctly at low levels.  Cat Form is learned at level 6, Bear Form at level 8.  Shred and
-- Ferocious Bite and Prowl are learned before Bear Form.

-- As of patch 6.0.2, this pattern does not work anymore: "/castsequence 0,Cat Form".  Cat Form will never be used.

-- [@target] stops some abilities from auto-acquiring a target.  It does not stop them from dropping a friendly to
-- acquire a hostile one, though.  This makes [harm] preferable I guess.

-- From #moonglade on irc.quakenet.org:
--   <meribold> do you macro potions to anything or use them manually all the time?
--   <aggixx> manually all the time
--   <meribold> not really used to potions
--   <meribold> i guess i could keybind it to something like arena3 cyclone, that i'm not going to need outside of arena
--   <meribold> so i don't need a new keybind
--   <aggixx> yeah
--   <meribold> Bottomless Brawler's Draenic Agility Potion, Brawler's Draenic Agility Potion, Draenic Agility Potion:
--     are those the potions I should all put into one macro?
--   <bunnykillax> should just have bottomless
--   <bunnykillax> dont need both brawlers
--   <meribold> but i'll use it for different chars and some of them don't have access to it
--   <meribold> so it should just try to use bottomless first, than fall back to brawlers and finally fall back to
--     Draenic Agility Potion
--   <meribold> I guess
--   <aggixx> yeah that works I guess, never thought of doing that
--   <aggixx> I always just swapped the item on my actionbar

---- FIXME -------------------------------------------------------------------------------------------------------------
-- There is a bug where the "V" macro doesn't acquire a target sometimes.  This happens even though we don't have a
--   harmful target and there is an enemy player.  It seems to happen with, e.g. prowling Restoration Druids.
-- Some [@mouseover] macros are bound with modifiers.  That makes them almost unusable.

---- TODO --------------------------------------------------------------------------------------------------------------
-- Modifier-agnostic Skull Bash keybinding.
-- Both [@player] and [@pary1] binds should try [@mouseover,exists] first.
-- Do something clever about Glyph of the Stag.
-- Make vehicle binds work when Bartender isn't loaded.
-- Bind @arena[123] Rake?
-- Add /startattack to all binds that normally start auto-attack except when there's not enough energy.
-- Bind Rejuvenation and Healing Touch to SHIFT-[456] and Cenarion Ward to ALT-[456].  Healing Touch with modifier
--   because most finishers use it?
-- Self dispel is rarely used; it could be bound to something worse than Y.
-- Bind @target Entangling roots to stop pets from interrupting drinking etc?
-- Bind /tar arena[123] on mouse and switch those binds to other targeting functions (/targetenemyplayer?
--   /targetfriendplayer?) outside arena.
-- Kick on ASD?
-- Maybe the normal Rake bind shouldn't auto-target; accidently used it on a resto druid after his shadow priest guised.
-- Make the addon work for all classes, binding only the canonical stuff for classes other than Druid.
-- Should the main Wild Charge macro auto-target?
-- "C" is awful for kicking.  E.g., I can't rest my middle finger on "C" while pressing "F".
-- Shadowmeld into Prowl should be faster and easier.
-- Bind something to: SHIFT-3
-- Also bind /targetenemy in arena?

local addonName, addon = ...
addon._G = _G
_G[addonName] = addon
setfenv(1, addon)

print = function(...)
  _G.print("|cffff7d0a" .. addonName .. "|r:", ...)
end

_G["BINDING_HEADER_PRIMALBINDS"] = "PrimalBinds"
_G["BINDING_NAME_DONOTHING"]     = "Do Nothing"

local secureHeader = _G.CreateFrame("Frame", nil, _G.UIParent, "SecureHandlerBaseTemplate")

-- Returns false for 5v5 arena.
local function inArena()
  return (_G.select(2, _G.IsInInstance())) == "arena" and not _G.UnitExists("party3")
    and _G.GetNumArenaOpponentSpecs() <= 5
end

---- < MACROS > --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local macros = {
  { key = "`", text =
      "/cancelform [form:3,flying]\n" ..
      "/use Stampeding Roar"
  },
  { key = "SHIFT-`", command = "DONOTHING" },
  { key = "ALT-`", command = "DONOTHING" },
  { key = "CTRL-`", command = "DONOTHING" },
  { key = "1", text =
      "/cancelform [form:3,flying]\n" ..
      "/use Dash"
  },
  { key = "SHIFT-1", command = "DONOTHING" },
  { key = "ALT-1", command = "DONOTHING" },
  { key = "CTRL-1", command = "DONOTHING" },
  { key = "2", text =
      "/use Nature's Vigil",
  },
  { key = "SHIFT-2", text =
      "/use Renewal\n" ..
      "/use [notalent:2/2]Healthstone"
  },
  { key = "ALT-2", text =
      "/cancelaura Hand of Protection\n" ..
      "/cancelaura Prowl\n" ..
      "/use [nocombat]Conjured Mana Fritter\n" ..
      "/use [nocombat]Conjured Mana Buns\n" ..
      "/use [nocombat]Conjured Mana Pudding\n" ..
      "/use [nocombat]Gorgrond Mineral Water\n" ..
      "/use [nocombat]Cobo Cola\n" ..
      "/use [nocombat]Golden Carp Consomme",
  },
  { key = "3", specs = { [103] = true },
    init = function(self)
      self.button:SetAttribute("type", "macro")

      -- Used when Incarnation isn't active (Prowl's spell ID is 5215).
      self.button:SetAttribute("*macrotext1",
        -- Consider this: "/castsequence reset=180 Incarnation: King of the Jungle,Berserk".  This cast sequence will
        -- reset after using Berserk but won't reliably reset 180 seconds after using Incarnation.  The problem is that
        -- failed attempts to use Berserk will reset the timer.  E.g., when Berserk is on cooldown or while in caster
        -- form running the macro will reset the timer.  The latter may be fixed by using the [form:2] conditional (not
        -- really: the cast sequence won't be advanced).  Adding a second line that simply uses Incarnation will make
        -- sure Incarnation is always used (this also works while Berserk is on cooldown because it is off the GCD).
        -- However, it may still use Berserk when it should only use Incarnation.
        --[[
        "/castsequence reset=180 Incarnation: King of the Jungle,Berserk"
        --]]
        -- This version requires shifting out of form first when Incarnation should be used.
        --[[
        "/use [form:2]14\n" ..
        "/use [form:2]Berserk\n" ..
        "/use [form:2]Berserking\n" ..
        "/use Incarnation: King of the Jungle"
        --]]
        "/use Incarnation: King of the Jungle"
      )

      -- Used when Incarnation is active (Prowl's spell ID is 102547).
      self.button:SetAttribute("*macrotext2",
        "/use 14\n" ..
        "/use Berserk\n" ..
        "/use Berserking"
      )

      _G.SecureHandlerWrapScript(self.button, "OnClick", secureHeader, [[
        local spellId = select(2, GetActionInfo(owner:GetAttribute("prowlActionSlot")))
        if spellId == 5215 then
          return
        elseif spellId == 102547 then
          return "RightButton"
        else
          return false
        end
      ]])
      self.button:RegisterForClicks("AnyDown")
    end,
  },
  { key = "SHIFT-3", command = "DONOTHING" },
  { key = "ALT-3",
    init = function(self)
      -- Things I've tried that don't work. These two approaches don't work at all:
      --   self.button:SetAttribute("*spell1", "Summon Random Favorite Mount")
      --   self.button:SetAttribute("type", "summonmount")
      -- This one basically works, but it can't cancel shapeshift forms:
      --   self.button:SetAttribute("*macrotext1", "/run C_MountJournal.Summon(0)")
      if db.randomFavMountActionSlot then
        local randomFavMountButton = _G.CreateFrame("Button", "RandomFavoriteMountButton", _G.UIParent,
          "SecureActionButtonTemplate")
        randomFavMountButton:SetAttribute("type", "action")
        randomFavMountButton:SetAttribute("action", db.randomFavMountActionSlot)
        randomFavMountButton:RegisterForClicks("AnyDown")
        self.button:SetAttribute("type", "macro")
        self.button:SetAttribute("*macrotext1",
          "/cancelaura Goblin Glider\n" ..
          "/cancelaura Parachute\n" .. -- Parachute triggered after nitro boosts (55016) failed.
          "/castsequence [@player] Mark of the Wild,Foo\n" ..
          "/click RandomFavoriteMountButton\n" ..
          "/use 15\n" ..
          "/dismount"
        )
      else
        _G.error("\"Summon Random Favorite Mount\" not found on action bars.")
        --[[
        self.button:SetAttribute("type", "macro")
        if not _G.IsAddOnLoaded("Blizzard_PetJournal") then
          _G.LoadAddOn("Blizzard_PetJournal")
        end
        self.button:SetAttribute("*macrotext1",
            "/cancelaura Goblin Glider\n" ..
            "/castsequence [@player] Mark of the Wild,Foo\n" ..
            "/click MountJournalSummonRandomFavoriteButton\n" ..
            "/use 15\n" ..
            "/dismount"
        )
        ]]
        -- "/click MountJournalSummonRandomFavoriteButton" just calls "MountJournal_Summon(0)". See the definition of
        -- MountJournalSummonRandomFavoriteButton_OnClick() in "Blizzard_PetBattleUI.lua".
      end
      self.button:RegisterForClicks("AnyDown")
      --[[
      local favoriteMounts = {
        ["Black War Bear"] = true,
        ["Cenarion War Hippogryph"] = true,
        ["Flying Machine"] = true, -- How to check if we can't use this?
        ["Fossilized Raptor"] = true,
        ["Quel'Dorei Steed"] = true,
        ["Silver Covenant Hippogryph"] = true,
        ["Swift Moonsaber"] = true,
        ["Venomhide Ravasaur"] = true,
        ["Vicious Warsaber"] = true,
        ["Winterspring Frostsaber"] = true,
      }
      for index = 1, _G.GetNumCompanions("MOUNT") do
        local _, creatureName = _G.GetCompanionInfo("MOUNT", index)
        if favoriteMounts[creatureName] then
          _G.table.insert(favoriteMounts, index)
        end
      end
      for k, _ in _G.pairs(favoriteMounts) do
        if _G.type(k) == "string" then
          favoriteMounts[k] = nil
        end
      end
      _G.randomFavoriteMount = function()
        if _G.IsMounted() then return end
        -- IsFlyableArea() returns 1 for some areas in which flight is disabled, but returns nil if the player can't fly
        -- in the area even tho flight is generally allowed.
        local _, _, wintergraspActive = _G.GetWorldPVPAreaInfo(1)
        local canFly = _G.IsFlyableArea() and not (_G.GetZoneText() == "Wintergrasp" and wintergraspActive)
        for i = 1, 42 do -- This isn't very smart. TODO: do something smart here.
          local index = favoriteMounts[_G.math.random(#favoriteMounts)]
          local _, _, _, _, _, mountFlags = _G.GetCompanionInfo("MOUNT", index)
          if not canFly or _G.bit.band(mountFlags, 0x02) == 0x02 then
            _G.CallCompanion("MOUNT", index) -- This can't cancel shapeshift forms. TODO: maybe we should go for "/use"
                                             -- instead.
            break
          end
        end
      end
      --]]
      --[=[
      if _G.UnitName("player") == "Mornedhel" or _G.UnitName("player") == "Mornwen" then
        _G.SecureHandlerExecute(secureHeader, [[
          favoriteMounts = table.new(
            "Black War Bear",
            "Cenarion War Hippogryph",
            "Fossilized Raptor",
            "Quel'Dorei Steed",
            "Red Primal Raptor",
            "Silver Covenant Hippogryph",
            "Swift Moonsaber",
            "Vicious Warsaber",
            "Winterspring Frostsaber"
          )
          favoriteFlyingMounts = table.new(
            "Cenarion War Hippogryph",
            "Flying Machine",
            "Silver Covenant Hippogryph"
          )
        ]])
      elseif _G.UnitName("player") == "Mornurug" then
        _G.SecureHandlerExecute(secureHeader, [[
          favoriteMounts = table.new(
            "Armored Brown Bear",
            "Fossilized Raptor",
            "Red Primal Raptor",
            "Venomhide Ravasaur"
          )
          favoriteFlyingMounts = table.new(
            "Armored Blue Wind Rider",
            "Flying Machine",
            "Sunreaver Dragonhawk"
          )
        ]])
      end
      ]=]
      -- TODO: do something clever about error messages.
      -- http://us.battle.net/wow/en/forum/topic/4253966114
      -- http://eu.battle.net/wow/en/forum/topic/3313065586
      --[=[
      _G.SecureHandlerWrapScript(self.button, "OnClick", secureHeader, [[
        local mount
        if IsFlyableArea() then
          mount = favoriteFlyingMounts[math.random(#favoriteFlyingMounts)]
        else
          mount = favoriteMounts[math.random(#favoriteMounts)]
        end
        self:SetAttribute("*macrotext1",
          "/cancelaura Goblin Glider\n" ..
          "/castsequence [@player] Mark of the Wild,Foo\n" ..
          "/use [nomounted,swimming]Abyssal Seahorse\n" ..
          "/use [nomounted]" .. mount .. "\n" ..
          "/use 15\n" ..
          "/dismount"
        )
      ]]) -- "/castsequence [@player] Mark of the Wild,Foo" resets on death.
      ]=]
    end,
    --[[
    text =
      "/cancelaura Goblin Glider\n" ..
      "/castsequence [@player] Mark of the Wild,Foo\n" ..
      "/cancelform\n" ..
      "/run randomFavoriteMount()\n" ..
      --"/userandom [nomounted,flyable]Silver Covenant Hippogryph,Cenarion War Hippogryph\n" ..
      --"/userandom [nomounted,noflyable]Silver Covenant Hippogryph,Cenarion War Hippogryph,Swift Moonsaber," ..
        --"Fossilized Raptor,Winterspring Frostsaber\n" ..
      "/use 15\n" ..
      "/dismount",
    --]]
  },
  { key = "4", text =
      "/use [form:1]Frenzied Regeneration\n" ..
      "/use [@mouseover,help,dead]Revive;[@mouseover,help]Rejuvenation;[help,dead]Revive;[help][@player]Rejuvenation",
  },
  { -- TODO: Fix all the ress macros.  The [dead] macro conditional seems to correspond to UnitIsDeadOrGhost().
    key = "SHIFT-4", text =
      "/use [@mouseover,help,dead]Rebirth;[@mouseover,help]Healing Touch;[help,dead]Rebirth;[help]Healing Touch;" ..
        "[@player]Healing Touch",
  },
  --[=[
  { -- This would be nice, but we can't get the name of a targeted party or raid member from the restricted environment.
    key = "SHIFT-4",
    init = function(self)
      self.button:SetAttribute("type", "macro")
      _G.SecureHandlerWrapScript(self.button, "OnClick", secureHeader, [[
        if not self:GetAttribute("party1") or self:GetAttribute("party1") ~= owner:GetAttribute("party1") then
          local party1 = owner:GetAttribute("party1")
          self:SetAttribute("party1", party1)
          local text = "/use [@" .. party1 .. ",help,dead]Revive;[@" .. party1 .. ",help]Healing Touch"
          self:SetAttribute("*macrotext1", text)
        end
      ]])
      self.button:RegisterForClicks("AnyDown")
    end,
  },
  ]=]
  { key = "ALT-4", text =
      "/use Heart of the Wild\n" ..
      "/use Healthstone\n" ..
      "/use [@mouseover,help,nodead][help,nodead][@player]Cenarion Ward",
  },
  { key = "5",
    update = function(self)
      self.button:SetAttribute("*macrotext1",
        "/use [form:1]Frenzied Regeneration\n" ..
        "/use [@" .. db.party1 .. ",help,dead]Revive;[@" .. db.party1 .. ",help]Rejuvenation"
      )
    end,
  },
  { key = "SHIFT-5",
    update = function(self)
      self.button:SetAttribute("*macrotext1",
        "/use [@" .. db.party1 .. ",help,dead]Rebirth;[@" .. db.party1 .. ",help]Healing Touch"
      )
    end,
  },
  { key = "ALT-5",
    update = function(self)
      self.button:SetAttribute("*macrotext1",
        "/use [@" .. db.party1 .. ",help]Heart of the Wild\n" ..
        "/use [@" .. db.party1 .. ",help]Cenarion Ward"
      )
    end,
  },
  { key = "6",
    update = function(self)
      self.button:SetAttribute("*macrotext1",
        "/use [form:1]Frenzied Regeneration\n" ..
        --"/use [@" .. db.party2 .. ",help,dead]Revive;[@" .. db.party2 .. ",help]Rejuvenation"
        "/use [@mouseover,help]Mark of the Wild;[@" .. db.party2 .. ",help,dead]Revive;[@" .. db.party2 ..
          ",help]Rejuvenation"
      )
    end,
  },
  { key = "SHIFT-6",
    update = function(self)
      self.button:SetAttribute("*macrotext1",
        "/use [@" .. db.party2 .. ",help,dead]Rebirth;[@" .. db.party2 .. ",help]Healing Touch"
      )
    end,
  },
  { key = "ALT-6",
    update = function(self)
      self.button:SetAttribute("*macrotext1",
        "/use [@" .. db.party2 .. ",help]Heart of the Wild\n" ..
        "/use [@" .. db.party2 .. ",help]Cenarion Ward"
      )
    end,
  },
  { key = "TAB", text =
      "/use [form:2,nocombat,nostealth]Conjured Mana Fritter\n" ..
      "/use [form:2,nocombat,nostealth]Conjured Mana Buns\n" ..
      "/use [form:2,nocombat,nostealth]Conjured Mana Pudding\n" ..
      "/use [form:2,nocombat,nostealth]Gorgrond Mineral Water\n" ..
      "/use [form:2,nocombat,nostealth]Cobo Cola\n" ..
      "/use [form:2,nocombat,nostealth]Golden Carp Consomme\n" ..
      "/cancelform [form:3,flying]\n" ..
      "/use !Prowl",
  },
  { key = "SHIFT-TAB", command = "DONOTHING" },
  { key = "ALT-TAB", command = "DONOTHING" },
  { key = "CTRL-TAB", command = "DONOTHING" },
  { key = "Q", text = "/use 13" },
  { key = "SHIFT-Q",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena1]Soothe"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use Soothe"
        )
      end
    end,
  },
  { key = "ALT-Q", text =
      "/use [form:2]14\n" ..
      "/use [form:2]Berserk\n" ..
      "/use [form:2]Berserking",
  },
  { key = "CTRL-Q", command = "DONOTHING" },
  { key = "W", text =
      "/use Survival Instincts"
  },
  { key = "SHIFT-W",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena1]Faerie Fire\n" ..
          "/use [@arena1]Faerie Swarm"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use Faerie Fire\n" ..
          "/use Faerie Swarm"
        )
      end
    end,
  },
  { key = "ALT-W", text =
      "/use [help,nodead][@player]Antiseptic Bandage",
  },
  { key = "E",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/stopcasting [form:1/2]\n" ..
          "/cancelaura [form:1/2]Hand of Protection\n" ..
          "/use [noform:1/2]Cat Form;[@mouseover,harm][@arena1]Skull Bash"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/stopcasting [form:1/2]\n" ..
          "/cancelaura [form:1/2]Hand of Protection\n" ..
          "/use [noform:1/2]Cat Form;[@mouseover,harm][]Skull Bash"
        )
      end
    end,
  },
  { key = "SHIFT-E",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena1]Cyclone"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use Cyclone"
        )
      end
    end,
  },
  { key = "ALT-E",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/castsequence [@arena1,form:1/2]reset=1 Wild Charge,Skull Bash"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/castsequence [form:1/2]reset=1 Wild Charge,Skull Bash"
        )
      end
    end,
  },
  { key = "R", text =
      "/use [form:1]Frenzied Regeneration\n" ..
      "/use [noform:2]Cat Form;Maim" -- Maim doesn't seem to auto-acquire a target.
  },
  { key = "SHIFT-R", specs = { [103] = true }, text =
      "/use [form:1]Frenzied Regeneration\n" ..
      "/use [noform:2]Cat Form;Savage Roar\n" ..
      "/mountspecial",
  },
  { key = "ALT-R",
    init = function(self)
      self.button:SetAttribute("type", "macro")
      _G.SecureHandlerWrapScript(self.button, "OnClick", secureHeader, [[
        local spellId = select(2, GetActionInfo(owner:GetAttribute("prowlActionSlot")))
        if spellId == 5215 then
          return
        elseif spellId == 102547 then
          return "RightButton"
        else
          return false
        end
      ]])
      self.button:RegisterForClicks("AnyDown")
    end,
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1", -- Used when Incarnation isn't active.
          "/use [@arena1]Maim"
        )
        self.button:SetAttribute("*macrotext2", -- Used when Incarnation is active.
          "/use [@arena1]Rake"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use [harm]Maim"
        )
        self.button:SetAttribute("*macrotext2",
          "/use [harm]Rake"
        )
      end
    end,
  },
  { key = "T", text =
      "/stopcasting\n" ..
      "/use Typhoon\n" ..
      "/use Mass Entanglement",
  },
  { key = "SHIFT-T",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena1]Entangling Roots"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use Entangling Roots"
        )
      end
    end,
  },
  { key = "ALT-T",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena1]Mighty Bash"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use Mighty Bash"
        )
      end
    end,
  },
  { key = "Y", specs = { [102] = true, [103] = true, [104] = true }, text =
      "/use [form:1]Frenzied Regeneration\n" ..
      "/use [@mouseover,help,nodead][help,nodead][@player]Remove Corruption",
  },
  { key = "SHIFT-Y", text =
      "/use [@mouseover,help,nodead][@player]Mark of the Wild",
  },
  { key = "ALT-Y", text =
      "/use Hurricane",
  },
  { key = "ESCAPE",
    init = function(self)
      self.button:SetAttribute("type", "macro")
      self.button:SetAttribute("*macrotext1", -- Used when [nocanexitvehicle]
        "/use [form:1]Frenzied Regeneration\n" ..
        "/use [form:1]!Bear Form;[form:2]!Cat Form;[form:3][swimming]!Travel Form;!Cat Form"
      )
      self.button:SetAttribute("*macrotext2", -- Used when [canexitvehicle]
        "/leavevehicle"
      )
      _G.SecureHandlerWrapScript(self.button, "OnClick", secureHeader, [[
        return SecureCmdOptionParse("[canexitvehicle]RightButton;LeftButton")
      ]])
      self.button:RegisterForClicks("AnyDown")
    end
  },
  { key = "SHIFT-ESCAPE", command = "DONOTHING" },
  { key = "ALT-ESCAPE", command = "DONOTHING" },
  { key = "CTRL-ESCAPE", command = "DONOTHING" },
  { key = "A", text =
      "/use [form:1]Frenzied Regeneration\n" ..
      "/cancelform [form]\n" ..
      "/dismount [mounted]\n",
  },
  { key = "SHIFT-A",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena2]Soothe"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use [@focus,exists]Soothe"
        )
      end
    end,
  },
  { key = "ALT-A", command = "DONOTHING" },
  { key = "CTRL-A", command = "DONOTHING" },
  { key = "S", -- Canceling form and using Wild Charge with just one click isn't possible (I think).
    update = function(self)
      self.button:SetAttribute("*macrotext1",
        "/stopcasting\n" ..
        "/use [talent:1/2,form:1]Frenzied Regeneration\n" ..
        "/use Displacer Beast\n" ..
        "/use [@mouseover,harm,form:1/2][@mouseover,help,noform:1/2][harm,form:1/2][help,noform:1/2][@" .. db.party1 ..
          ",help,noform:1/2][@none,form:3]Wild Charge\n" ..
        "/use [form:3]1" -- Fixes the previous line using Wild Charge in Flight Form with no target.
      )
    end,
  },
  --[=[
  { key = "S",
    init = function(self)
      self.button:SetAttribute("type", "macro")
      _G.SecureHandlerWrapScript(self.button, "OnClick", secureHeader, [[
        if not UnitExists("target") or not PlayerCanAttack("target") then
          return "RightButton"
        end
      ]])
      self.button:RegisterForClicks("AnyDown")
    end,
    update = function(self)
      self.button:SetAttribute("*macrotext1",
        "/stopcasting\n" ..
        "/use [@" .. db.party2 .. ",help,noform]Wild Charge\n" ..
        "/use [@mouseover,harm,form:1/2][harm,form:1/2]Skull Bash"
      )
      self.button:SetAttribute("*macrotext2", -- Used when [noexists][noharm].
        "/stopcasting\n" ..
        "/use [@" .. db.party2 .. ",help,noform]Wild Charge\n" ..
        "/stopmacro [@" .. db.party2 .. ",help,noform]\n" ..
        "/use [@mouseover,harm,form:1/2]Skull Bash\n" ..
        "/stopmacro [@mouseover,harm,form:1/2]\n" ..
        "/targetenemyplayer [stealth]\n" ..
        "/stopmacro [noexists][noharm]\n" ..
        "/use [form:1/2]Skull Bash\n" ..
        "/cleartarget"
      )
    end,
  },
  --]=]
  { key = "SHIFT-S",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena2]Faerie Fire\n" ..
          "/use [@arena2]Faerie Swarm"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use [@focus,exists]Faerie Fire\n" ..
          "/use [@focus,exists]Faerie Swarm"
        )
      end
    end,
  },
  { key = "ALT-S",
    update = function(self)
      self.button:SetAttribute("*macrotext1",
        "/use [@" .. db.party1 .. ",help]Antiseptic Bandage"
      )
    end,
  },
  { key = "D",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/stopcasting [form:1/2]\n" ..
          "/cancelaura [form:1/2]Hand of Protection\n" ..
          "/use [form:3]Cat Form;[@" .. db.party2 .. ",help,noform]Wild Charge;[@mouseover,harm,form:1/2]" ..
            "[@arena2,form:1/2]Skull Bash"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/stopcasting [form:1/2]\n" ..
          "/cancelaura [form:1/2]Hand of Protection\n" ..
          "/use [form:3]Cat Form;[@" .. db.party2 .. ",help,noform]Wild Charge;[@mouseover,harm,form:1/2]" ..
            "[@focus,form:1/2]Skull Bash"
        )
      end
    end,
  },
  { key = "SHIFT-D",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena2]Cyclone"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use [@focus,exists]Cyclone"
        )
      end
    end,
  },
  { key = "ALT-D",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/castsequence [@arena2,form:1/2]reset=1 Wild Charge,Skull Bash"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/castsequence [@focus,exists,form:1/2]reset=1 Wild Charge,Skull Bash"
        )
      end
    end,
  },
  --{ key = "F", command = "INTERACTMOUSEOVER" },
  { key = "F", -- Shred auto-acquires a target when without a hostile target.
    init = function(self)
      self.button:SetAttribute("type", "macro")
      self.button:SetAttribute("*macrotext1", -- Used when [noform:1/2].
        "/use Cat Form"
      )
      self.button:SetAttribute("*macrotext2", -- Used when [form:2,nostealth][harm,form:2].
        "/stopattack [stealth]\n" ..
        "/use [@mouseover,harm][harm]Shred\n" ..
        "/stopattack [stealth]\n" ..
        "/startattack [harm,nostealth]"
      )
      self.button:SetAttribute("*macrotext3", -- Used when [noexists,form:2,stealth][noharm,form:2,stealth].
        "/use [@mouseover,harm]Shred\n" ..
        "/stopmacro [@mouseover,harm]\n" ..
        "/cleartarget\n" .. -- Buggy without this.
        "/targetenemyplayer\n" ..
        "/tar [noexists]player\n" ..
        "/stopmacro [noharm]\n" ..
        "/use Shred\n" ..
        "/tar player"
      )
      self.button:SetAttribute("*macrotext4", -- Used when [form:1].
        "/use [@mouseover,harm][harm]Mangle\n" ..
        "/tar [noexists]player"
      )
      -- Our snippets get these arguments: self, button, down. See wowprogramming.com/utils/xmlbrowser/test/FrameXML/
      -- SecureTemplates.lua and "Iriel's Field Guide to Secure Handlers".
      _G.SecureHandlerWrapScript(self.button, "OnClick", secureHeader, [[
        if GetBonusBarOffset() == 1 then
          if not IsStealthed() or UnitExists("target") and PlayerCanAttack("target") then
            return "RightButton"
          else
            return "MiddleButton"
          end
        elseif GetBonusBarOffset() == 3 then
          return "Button4"
        end
      ]])
      self.button:RegisterForClicks("AnyDown")
    end,
  },
  { key = "SHIFT-F",
    init = function(self)
      self.button:SetAttribute("type", "macro")
      self.button:SetAttribute("*macrotext1", -- Used when [noform:2].
        "/use [form:1]Growl;Cat Form"
      )
      self.button:SetAttribute("*macrotext2", -- Used when [form:2].
        "/use [harm]Ferocious Bite"
      )
      _G.SecureHandlerWrapScript(self.button, "OnClick", secureHeader, [[
        if GetBonusBarOffset() == 1 then
          return "RightButton"
        end
      ]])
      self.button:RegisterForClicks("AnyDown")
    end
  },
  { key = "ALT-F",
    init = function(self)
      self.button:SetAttribute("type", "macro")
      _G.SecureHandlerWrapScript(self.button, "OnClick", secureHeader, [[
        local spellId = select(2, GetActionInfo(owner:GetAttribute("prowlActionSlot")))
        if spellId == 5215 then
          return
        elseif spellId == 102547 then
          return "RightButton"
        else
          return false
        end
      ]])
      self.button:RegisterForClicks("AnyDown")
    end,
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena2]Maim"
        )
        self.button:SetAttribute("*macrotext2",
          "/use [@arena2]Rake"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use [@focus,exists]Maim"
        )
        self.button:SetAttribute("*macrotext2",
          "/use [@focus,exists]Rake"
        )
      end
    end,
  },
  { key = "G",
    init = function(self)
      self.button:SetAttribute("type", "macro")
      self.button:SetAttribute("*macrotext1", -- Used when [harm][nostealth].
        "/use Incapacitating Roar\n" ..
        "/use Ursol's Vortex\n" ..
        "/stopmacro [notalent:5/3]\n" ..
        "/tar [noexists]player\n" ..
        "/use [@mouseover,harm][harm]Mighty Bash"
      )
      self.button:SetAttribute("*macrotext2", -- Used when [noexists,stealth][noharm,stealth].
        "/use Incapacitating Roar\n" ..
        "/use Ursol's Vortex\n" ..
        "/stopmacro [notalent:5/3]\n" .. -- Continue if specced into Mighty Bash.
        "/use [@mouseover,harm]Mighty Bash\n" ..
        "/stopmacro [@mouseover,harm]\n" ..
        "/cleartarget\n" .. -- Buggy without this.
        "/targetenemyplayer\n" ..
        "/tar [noexists]player\n" ..
        "/stopmacro [noharm]\n" ..
        "/use Mighty Bash\n" ..
        "/tar player"
      )
      _G.SecureHandlerWrapScript(self.button, "OnClick", secureHeader, [[
        if IsStealthed() and (not UnitExists("target") or not PlayerCanAttack("target")) then
          return "RightButton"
        end
      ]])
      self.button:RegisterForClicks("AnyDown")
    end,
  },
  { key = "SHIFT-G",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena2]Entangling Roots"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use [@focus,exists]Entangling Roots"
        )
      end
    end,
  },
  { key = "ALT-G",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena2]Mighty Bash"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use [@focus,exists]Mighty Bash"
        )
      end
    end,
  },
  { key = "H", specs = { [102] = true, [103] = true, [104] = true },
    update = function(self)
      self.button:SetAttribute("*macrotext1",
        "/use [form:1]Frenzied Regeneration\n" ..
        "/use [@mouseover,help][@" .. db.party1 .. ",help]Remove Corruption"
      )
    end,
  },
  { key = "SHIFT-H", text =
      "/use Moonfire",
  },
  { key = "ALT-H", text =
      "/use [harm,form:1/2][@none,form:1/2]Thrash;[harm]Wrath",
  },
  { key = "Z",
    init = function(self)
      self.button:SetAttribute("type", "macro")
      _G.SecureHandlerWrapScript(self.button, "OnClick", secureHeader, [[
        if not down then
          return "RightButton"
        end
      ]])
      self.button:RegisterForClicks("AnyDown", "AnyUp")
    end,
    update = function(self)
      if (_G.select(2, _G.UnitRace("player"))) == "NightElf" then
        --[[
        self.button:SetAttribute("*macrotext1",
          "/cancelaura Prowl\n" .. -- Also Shadowmeld if "a more powerful spell is already active".
          "/use Shadowmeld"
        )
        --]]
        self.button:SetAttribute("*macrotext1",
          "/use Shadowmeld\n" ..
          "/cancelform [form:3,flying]\n" ..
          "/use [nostealth]!Prowl"
        )
        self.button:SetAttribute("*macrotext2",
          "/use !Prowl"
        )
      elseif (_G.select(2, _G.UnitRace("player"))) == "Worgen" then
        self.button:SetAttribute("*macrotext1",
          "/use Darkflight"
        )
        self.button:SetAttribute("*macrotext2")
      elseif (_G.select(2, _G.UnitRace("player"))) == "Tauren" then
        self.button:SetAttribute("*macrotext1",
          "/use War Stomp"
        )
        self.button:SetAttribute("*macrotext2")
      elseif (_G.select(2, _G.UnitRace("player"))) == "Troll" then
        self.button:SetAttribute("*macrotext1",
          "/use Berserking"
        )
        self.button:SetAttribute("*macrotext2")
      else
        _G.error()
      end
    end,
  },
  { key = "SHIFT-Z",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena3]Soothe"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use [@focus]Soothe"
        )
      end
    end,
  },
  { key = "ALT-Z", command = "DONOTHING" },
  { key = "CTRL-Z", command = "DONOTHING" },
  { key = "X", specs = { [103] = true },
    init = function(self)
      self.button:SetAttribute("type", "macro")
      self.button:SetAttribute("*macrotext1", -- Used when Incarnation isn't active (Prowl's spell ID is 5215).
        "/cancelform [form:3,flying]\n" ..
        "/use Tiger's Fury\n" .. -- Tiger's Fury activates Cat Form.
        "/use 14"
      )
      self.button:SetAttribute("*macrotext2", -- Used when Incarnation is active (Prowl's spell ID is 102547).
        "/cancelform [form:3,flying]\n" ..
        "/use 14\n" ..
        "/use Berserk\n" ..
        "/use Tiger's Fury\n" .. -- This always should be used after Berserk now. Tiger's Fury used to be unusable while
        "/use Berserking"        -- Berserk is active.
      )
      _G.SecureHandlerWrapScript(self.button, "OnClick", secureHeader, [[
        local spellId = select(2, GetActionInfo(owner:GetAttribute("prowlActionSlot")))
        if spellId == 5215 then
          return
        elseif spellId == 102547 then
          return "RightButton"
        else
          return false
        end
      ]])
      self.button:RegisterForClicks("AnyDown")
    end,
  },
  { key = "SHIFT-X",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena3]Faerie Fire\n" ..
          "/use [@arena3]Faerie Swarm"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use 6"
        )
      end
    end,
  },
  --[[
  { key = "SHIFT-X", specs = { [103] = true },
    update = function(self)
      local _, _, _, _, incarnationSelected = _G.GetTalentInfo(4, 2, _G.GetActiveSpecGroup())
      local _, _, _, _, treantsSelected = _G.GetTalentInfo(4, 3, _G.GetActiveSpecGroup())
      if incarnationSelected then -- We are specced into Incarnation.
        self.button:SetAttribute("*macrotext1",
          "/use Incarnation: King of the Jungle\n" ..
          "/use Nature's Vigil"
        )
      elseif treantsSelected then
        self.button:SetAttribute("*macrotext1",
          "/use [noform:2]Cat Form\n" ..
          "/use [form:2]14\n" ..
          "/use [form:2]Force of Nature"
        ) -- Treants aren't affected by: Savage Roar, Tiger's Fury, Nature's Vigil, Berserking (maybe haste in general?).
        -- They are affected by bonuses to agility.

      else -- We are specced into Soul of the Forest or haven't selected a level 60 talent.
        self.button:SetAttribute("*macrotext1",
          "/use Nature's Vigil\n" ..
          "/use 14\n" ..
          "/use Berserk\n" ..
          "/use Tiger's Fury\n" ..
          "/use Berserking"
        )
      end
    end,
  },
  ]]
  { key = "ALT-X",
    update = function(self)
      self.button:SetAttribute("*macrotext1",
        "/use [@" .. db.party2 .. ",help]Antiseptic Bandage"
      )
    end,
  },
  { key = "C",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/stopcasting [form:1/2]\n" ..
          "/cancelaura [form:1/2]Hand of Protection\n" ..
          "/use [noform:1/2]Cat Form;[@arena3]Skull Bash"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use Brawler's Bottomless Draenic Agility Potion\n" ..
          "/use Brawler's Draenic Agility Potion\n" ..
          "/use Draenic Agility Potion"
        )
      end
    end,
  },
  { key = "SHIFT-C",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena3]Cyclone"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use Survey"
        )
      end
    end,
  },
  { key = "ALT-C",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/castsequence [@arena3,form:1/2]reset=1 Wild Charge,Skull Bash"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use Fishing"
        )
      end
    end,
  },
  { key = "V",
    init = function(self)
      self.button:SetAttribute("type", "macro")
      self.button:SetAttribute("*macrotext1", -- Used when [form:2,harm][form:2,nostealth].
        "/stopattack [stealth]\n" ..
        --"/use [nocombat,nostealth]Prowl\n" .. Doesn't work but Prowl is used.
        "/use [@mouseover,harm][harm]Rake\n" ..
        "/stopattack [stealth]\n" ..    -- Rake (and Shred) will start auto-attack even when used in stealth :/
        "/startattack [harm,nostealth]" -- Also start auto-attack when there's not enough energy.
      )
      -- Used when [noexists,form:2,stealth][noharm,form:2,stealth] (should imply we aren't auto-attacking).  It seems
      -- /targetenemyplayer doesn't acquire a target sometimes or doesn't acquire the obvious target right in front of
      -- the character when using this macro without /cleartarget.
      self.button:SetAttribute("*macrotext2",
        "/use [@mouseover,harm]Rake\n" ..
        "/stopmacro [@mouseover,harm]\n" ..
        "/cleartarget\n" .. -- Buggy without this.
        "/targetenemyplayer\n" ..
        "/tar [noexists]player\n" ..
        "/stopmacro [noharm]\n" ..
        "/use Rake\n" ..
        "/stopattack\n" ..
        "/tar player"
      )
      self.button:SetAttribute("*macrotext3", -- Used when [noform:2].
        "/use [form:1]Frenzied Regeneration\n" ..
        "/use Cat Form"
      )
      _G.SecureHandlerWrapScript(self.button, "OnClick", secureHeader, [[
        if GetBonusBarOffset() ~= 1 then
          return "MiddleButton"
        elseif IsStealthed() and (not UnitExists("target") or not PlayerCanAttack("target")) then
          return "RightButton"
        end
      ]])
      self.button:RegisterForClicks("AnyDown")
    end,
  }, -- See http://www.arenajunkies.com/topic/290488-feral-rake-stun-opener
  { key = "SHIFT-V", text =
      "/use [form:1]Frenzied Regeneration\n" ..
      "/use [noform:2]Cat Form;[harm]Rip",
  },
  { key = "ALT-V",
    init = function(self)
      self.button:SetAttribute("type", "macro")
      self.button:SetAttribute("*macrotext1",
        "/use [@arena3]Maim"
      )
      self.button:SetAttribute("*macrotext2",
        "/use [@arena3]Rake"
      )
      _G.SecureHandlerWrapScript(self.button, "OnClick", secureHeader, [[
        local spellId = select(2, GetActionInfo(owner:GetAttribute("prowlActionSlot")))
        if spellId == 5215 then
          return
        elseif spellId == 102547 then
          return "RightButton"
        else
          return false
        end
      ]])
      self.button:RegisterForClicks("AnyDown")
    end,
  },
  { key = "B", text =
      "/use [form:1]Frenzied Regeneration\n" ..
      "/use [noform:1]Bear Form",
  },
  { key = "SHIFT-B",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena3]Entangling Roots"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use [@focus]Entangling Roots"
        )
      end
    end,
  },
  { key = "ALT-B",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena3]Mighty Bash"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use [@focus]Mighty Bash"
        )
      end
    end,
  },
  { key = "N", specs = { [102] = true, [103] = true, [104] = true },
    update = function(self)
      self.button:SetAttribute("*macrotext1",
        "/use [form:1]Frenzied Regeneration\n" ..
        "/use [@" .. db.party2 .. ",help]Remove Corruption"
      )
    end,
  },
  { key = "SHIFT-N", text =
      "/use [outdoors][swimming]!Travel Form;[noform:2]Cat Form",
  },
  { key = "ALT-N", text =
      "/use [form:1]Frenzied Regeneration\n" ..
      "/use [noform:2]Cat Form;[harm,form:2][@none,form:2]Swipe",
  },
  { key = "/", command = "OPENCHATSLASH" },
  { key = "SPACE", command = "MOVEFORWARD" },
  { key = "BUTTON1", command = "CAMERAORSELECTORMOVE" },
  { key = "BUTTON2", command = "INTERACTMOUSEOVER" },
  --[[
  { key = "MOUSEWHEELUP",
    update = function(self)
      --_G.print("GetInstanceInfo()", _G.GetInstanceInfo()) -- Works in PLAYER_ENTERING_WORLD.
      --_G.print("IsActiveBattlefieldArena()", _G.IsActiveBattlefieldArena()) -- Doesn't work in PLAYER_ENTERING_WORLD.
      --_G.print("GetNumArenaOpponents()", _G.GetNumArenaOpponents())
      -- I think GetNumGroupMembers() isn't for instance groups, so it doesn't return useful infomation when
      -- solo-queuing for Skirmishes.
      --local numGroupMembers = _G.GetNumGroupMembers()
      local numArenaOpponents = _G.GetNumArenaOpponentSpecs()
      if (_G.select(2, _G.IsInInstance())) == "arena" and not _G.UnitExists("party2") and numArenaOpponents < 3 then
        self.button:SetAttribute("*macrotext1",
          "/tar [@mouseover,exists,nomod]\n" ..
          "/targetenemy [mod:shift]\n" ..
          --"/startattack [exists,combat,nostealth,mod:shift]\n" ..
          "/tar [@arena1,nomod:shift]\n" ..
          "/focus [@arena2,nomod:shift]"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/tar [@mouseover,exists]\n" ..
          "/targetenemyplayer [@mouseover,noexists,nomod:shift]\n" ..
          "/targetenemy [@mouseover,noexists,mod:shift]\n"-- ..
          --"/focus [@focus,noexists] target\n" ..
          --"/startattack [exists,combat,nostealth]"
        )
      end
    end,
  },
  --]]
  --[[
  { key = "MOUSEWHEELUP",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/stopcasting [form:1/2]\n" ..
          "/cancelaura [form:1/2]Hand of Protection\n" ..
          "/use [@arena1]Skull Bash"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/stopcasting [form:1/2]\n" ..
          "/cancelaura [form:1/2]Hand of Protection\n" ..
          "/use Skull Bash"
        )
      end
    end,
  },
  --]]
  ----[[
  { key = "MOUSEWHEELUP",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/cancelform [@mouseover,help]\n" ..
          "/use [@mouseover,harm]Cyclone;[@mouseover,help]Wild Charge\n" ..
          --"/use [@mouseover,harm]Cyclone;[@mouseover,help]Rejuvenation\n" ..
          "/stopmacro [@mouseover,harm][@mouseover,help]\n" ..
          "/tar arena1\n" ..
          "/stopattack"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/cancelform [@mouseover,help]\n" ..
          "/use [@mouseover,harm]Cyclone;[@mouseover,help]Wild Charge\n" ..
          --"/use [@mouseover,harm]Cyclone;[@mouseover,help]Rejuvenation\n" ..
          "/targetenemyplayer [@mouseover,noharm,nohelp]"
        )
      end
    end,
  },
  --]]
  { key = "SHIFT-MOUSEWHEELUP" },
  { key = "ALT-MOUSEWHEELUP" },
  { key = "CTRL-MOUSEWHEELUP", command = "CAMERAZOOMIN" },
  --[[
  { key = "BUTTON3",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/stopcasting [form:1/2]\n" ..
          "/cancelaura [form:1/2]Hand of Protection\n" ..
          "/use [noform:1/2]Cat Form;[@mouseover,harm,form:1/2][@arena2,form:1/2]Skull Bash"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/stopcasting [form:1/2]\n" ..
          "/cancelaura [form:1/2]Hand of Protection\n" ..
          "/use [noform:1/2]Cat Form;[@mouseover,harm,form:1/2][@focus,form:1/2]Skull Bash"
        )
      end
    end,
  },
  --]]
  ----[[
  { key = "BUTTON3",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/tar arena2\n" ..
          "/stopattack"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/focus [@mouseover,exists]\n" ..
          "/targetfriendplayer [@mouseover,noexists]"
        )
      end
    end,
  },
  --]]
  { key = "SHIFT-BUTTON3" },
  { key = "ALT-BUTTON3" },
  { key = "CTRL-BUTTON3" },
  --[[
  { key = "MOUSEWHEELDOWN",
    update = function(self)
      --local numGroupMembers = _G.GetNumGroupMembers()
      local numArenaOpponents = _G.GetNumArenaOpponentSpecs()
      if (_G.select(2, _G.IsInInstance())) == "arena" and not _G.UnitExists("party2") and numArenaOpponents < 3 then
        self.button:SetAttribute("*macrotext1",
          "/focus [@mouseover,exists,nomod]\n" ..
          "/targetenemy [mod:shift] 1\n" ..
          --"/startattack [exists,combat,nostealth,mod:shift]\n" ..
          "/tar [@arena2,nomod:shift]\n" ..
          "/focus [@arena1,nomod:shift]"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/focus [@mouseover,exists]\n" ..
          "/targetenemyplayer [@mouseover,noexists,nomod:shift] 1\n" ..
          "/targetenemy [@mouseover,noexists,mod:shift] 1\n"-- ..
          --"/focus [@focus,noexists] target\n" ..
          --"/startattack [exists,combat,nostealth]"
        )
      end
    end,
  },
  --]]
  --[[
  { key = "MOUSEWHEELDOWN", text =
      "/stopcasting [form:1/2]\n" ..
      "/cancelaura [form:1/2]Hand of Protection\n" ..
      "/use [@arena3]Skull Bash",
  },
  --]]
  ----[[
  { key = "MOUSEWHEELDOWN",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/use [@mouseover,harm]Entangling Roots;[@mouseover,help]Healing Touch\n" ..
          "/stopmacro [@mouseover,harm][@mouseover,help]\n" ..
          "/tar arena3\n" ..
          "/stopattack"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use [@mouseover,harm]Entangling Roots;[@mouseover,help]Healing Touch\n" ..
          "/targetenemy [@mouseover,noharm,nohelp]"
        )
      end
    end,
  },
  { key = "SHIFT-MOUSEWHEELDOWN" },
  { key = "ALT-MOUSEWHEELDOWN" },
  { key = "CTRL-MOUSEWHEELDOWN", command = "CAMERAZOOMOUT" },
  { --[[
    The macro for swapping target and focus (given both exists) would normally be:
      /tar focus
      /targetlasttarget
      /focus
      /targetlasttarget

    After the first two lines the target is unchanged and the focus is also the last target. Now we can simply focus the
    target and target the last target (which is the previous focus).

    However, this macro won't result in the expected behaviour if target and focus refer to the same unit: "/tar focus"
    will have no effect (not even that of changing the last target) and "/targetlasttarget" will actually target the
    last target. Thus, next it will focus the last target and then restore the target.

    The longer version used below will first clear the last target. Targeting the focus still does nothing, targeting
    the last target will clear the target, "/focus [@target,exists]" will do nothing and the last "/targetlasttarget"
    will restore the target.
    ]]
    key = "BUTTON4",
    init = function(self)
      self.button:SetAttribute("type", "macro")
      self.button:RegisterForClicks("AnyDown")
    end,
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/use [noform:1/2]Cat Form;[]Skull Bash"
        )
        _G.SecureHandlerUnwrapScript(self.button, "OnClick")
      else
        self.button:SetAttribute("*macrotext1", -- Used when UnitExists("target") and UnitExists("focus").
          "/cleartarget\n" ..
          "/targetlasttarget\n" ..
          "/tar focus\n" ..
          "/targetlasttarget\n" ..
          "/focus [@target,exists]\n" ..
          "/targetlasttarget"
        )
        self.button:SetAttribute("*macrotext2", -- Used when UnitExists("target") and not UnitExists("focus").
          "/focus\n" ..
          "/cleartarget"
        )
        self.button:SetAttribute("*macrotext3", -- Used when not UnitExists("target") and UnitExists("focus").
          "/tar focus\n" ..
          "/clearfocus"
        )
        _G.SecureHandlerUnwrapScript(self.button, "OnClick")
        _G.SecureHandlerWrapScript(self.button, "OnClick", secureHeader, [[
          if UnitExists("target") then
            if UnitExists("focus") then
              -- ...
            else
              return "RightButton"
            end
          else
            if UnitExists("focus") then
              return "MiddleButton"
            else
              return false
            end
          end
        ]])
      end
    end,
  },
  { key = "SHIFT-BUTTON4", text = "/focus" },
  { key = "ALT-BUTTON4" },
  { key = "BUTTON5", command = "JUMP" },
  { key = "SHIFT-BUTTON5" },
  { key = "ALT-BUTTON5" },
  { key = "CTRL-BUTTON5" },
  --[[
  { key = "NUMPAD3",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/stopcasting [form:1/2]\n" ..
          "/cancelaura [form:1/2]Hand of Protection\n" ..
          "/use [noform:1/2]Cat Form;[@arena1]Skull Bash"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/stopcasting [form:1/2]\n" ..
          "/cancelaura [form:1/2]Hand of Protection\n" ..
          "/use [noform:1/2]Cat Form;Skull Bash"
        )
      end
    end,
  },
  { key = "NUMPAD2",
    update = function(self)
      if inArena() then
        self.button:SetAttribute("*macrotext1",
          "/stopcasting [form:1/2]\n" ..
          "/cancelaura [form:1/2]Hand of Protection\n" ..
          "/use [noform:1/2]Cat Form;[@mouseover,harm,form:1/2][@arena2,form:1/2]Skull Bash"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/stopcasting [form:1/2]\n" ..
          "/cancelaura [form:1/2]Hand of Protection\n" ..
          "/use [noform:1/2]Cat Form;[@mouseover,harm,form:1/2][@focus,form:1/2]Skull Bash"
        )
      end
    end,
  },
  { key = "NUMPAD1", text =
      "/stopcasting [form:1/2]\n" ..
      "/cancelaura [form:1/2]Hand of Protection\n" ..
      "/use [noform:1/2]Cat Form;[@arena3]Skull Bash",
  },
  { key = "NUMPAD6", text =
      "/tar arena1",
  },
  { key = "NUMPAD5", text =
      "/tar arena2",
  },
  { key = "NUMPAD4", text =
      "/tar arena3",
  },
  --]]
  { key = "-" },
  { key = "=" },
  { key = "U", command = "TOGGLEWORLDMAP" },
  { key = "I", command = "OPENALLBAGS" },
  { key = "O", command = "TOGGLESOCIAL" },
  { key = "J", command = "TOGGLEAUTORUN" },
  { key = "ENTER", command = "OPENCHAT" },
  { key = "F10", command = "TOGGLEGAMEMENU" },
  { key = "PRINTSCREEN", command = "SCREENSHOT" },
  { key = "UP", command = "MOVEFORWARD" },
  { key = "DOWN", command = "MOVEBACKWARD" },
  { key = "LEFT", command = "TURNLEFT" },
  { key = "RIGHT", command = "TURNRIGHT" },
}
-- < / MACROS > --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local handlerFrame = _G.CreateFrame("Frame")

-- http://www.wowinterface.com/forums/showthread.php?p=267998
handlerFrame:SetScript("OnEvent", function(self, event, ...)
  return self[event] and self[event](self, ...)
end)

local function bind()
  -- TODO: start by unbinding a lot of things? GetBinding(index) only returns command names and keys bound to binding
  -- ID's (http://wowpedia.org/BindingID).

  for _, macro in _G.ipairs(macros) do
    _G.assert(macro.key)
    if macro.button then
      _G.SetBindingClick(macro.key, macro.button:GetName(), "LeftButton")
    elseif macro.command then
      _G.SetBinding(macro.key, macro.command)
    else
      --_G.SetBinding(macro.key, "CLICK " .. addonName .. "DummyButton")
      --_G.SetBinding(macro.key, "DONOTHING")
      _G.SetBinding(macro.key)
    end
  end

  _G.SetModifiedClick("AUTOLOOTTOGGLE", "CTRL")
  _G.SetModifiedClick("CHATLINK", "SHIFT")
  _G.SetModifiedClick("COMPAREITEMS", "SHIFT")
  _G.SetModifiedClick("DRESSUP", "CTRL")
  _G.SetModifiedClick("FOCUSCAST", "NONE")
  _G.SetModifiedClick("OPENALLBAGS", "SHIFT")
  _G.SetModifiedClick("PICKUPACTION", "CTRL")
  _G.SetModifiedClick("QUESTWATCHTOGGLE", "SHIFT")
  _G.SetModifiedClick("SELFCAST", "NONE")
  _G.SetModifiedClick("SHOWITEMFLYOUT", "SHIFT")
  _G.SetModifiedClick("SOCKETITEM", "CTRL")
  _G.SetModifiedClick("SPLITSTACK", "SHIFT")
  _G.SetModifiedClick("STICKYCAMERA", "SHIFT")
  _G.SetModifiedClick("TOKENWATCHTOGGLE", "SHIFT")

  -- Can't use _G.CHARACTER_BINDINGS as it's defined as part of the load-on-demand Blizzard_BindingUI.
  _G.SaveBindings(2)

  _G.assert(_G.GetCurrentBindingSet() == 2)

  print("Commands bound and saved as " .. (_G.GetCurrentBindingSet() == 1 and "account" or "character specific") ..
    " binding set.")
end

-- http://wowpedia.org/AddOn_loading_process#Order_of_events_fired_during_loading
function handlerFrame:ADDON_LOADED()
  self:UnregisterEvent("ADDON_LOADED")

  _G.assert(not _G.InCombatLockdown())

  if not _G.PrimalBindsDB then
    _G.PrimalBindsDB = {}
  end

  db = _G.PrimalBindsDB

  local databaseDefaults = {
    party1 = "party1",
    party2 = "party2",
  }

  for k, v in _G.pairs(databaseDefaults) do
    if not db[k] then db[k] = v end
  end

  --secureHeader:SetAttribute("party1", db.party1)
  --secureHeader:SetAttribute("party2", db.party2)

  do
    local overrideBarStateHandler = _G.CreateFrame("Frame", nil, nil, "SecureHandlerStateTemplate")

    -- We don't use the first action bar as the possess bar because skills are put on it automatically while leveling.
    -- TODO: display binding labels.
    overrideBarStateHandler:SetAttribute("_onstate-overridebar", [[
      if newstate == "overridebar" then
        for i, key in ipairs(table.new("A", "S", "D", "F", "G", "H")) do
          self:SetBindingClick(false, key, "BT4Button" .. (12 + i))
          --self:SetBindingClick(false, key, "OverrideActionBarButton" .. (12 + i))
        end
      elseif newstate == "nooverridebar" then
        for _, key in ipairs(table.new("A", "S", "D", "F", "G", "H")) do
          self:ClearBinding(key)
        end
      end
    ]])

    _G.RegisterStateDriver(overrideBarStateHandler, "overridebar",
      "[overridebar][vehicleui][possessbar][bonusbar:5]overridebar;nooverridebar")

    --[=[
    overrideBarStateHandler:SetAttribute("_onstate-canexitvehicle", [[
      if newstate == "canexitvehicle" then
        self:SetBindingClick(false, "ESCAPE", "BT4Button85")
      elseif newstate == "nocanexitvehicle" then
        self:ClearBinding("ESCAPE")
      end
    ]])

    _G.RegisterStateDriver(overrideBarStateHandler, "canexitvehicle",
      "[canexitvehicle]canexitvehicle;nocanexitvehicle")
    ]=]

    overrideBarStateHandler:SetAttribute("_onstate-petbattle", [[
      if newstate == "petbattle" then
        for i, key in ipairs(table.new("A", "S", "D", "F", "G", "H")) do
          self:SetBindingClick(false, key, "PrimalBindsPetBattle" .. key .. "Button")
        end
      elseif newstate == "nopetbattle" then
        self:ClearBindings()
      end
    ]])

    _G.RegisterStateDriver(overrideBarStateHandler, "petbattle",
      "[petbattle]petbattle;nopetbattle")
  end

  do
    local keys = { "A", "S", "D", "F", "G" }
    _G.assert(#keys == _G.NUM_BATTLE_PET_HOTKEYS)

    local buttons = {
      _G.PetBattleFrame.BottomFrame.SwitchPetButton,
      _G.PetBattleFrame.BottomFrame.CatchButton,
    }

    -- Only for abilities, not other action buttons.
    _G.hooksecurefunc("PetBattleAbilityButton_OnLoad", function(self)
      local key = keys[self:GetID()]
      local proxyButton = _G.CreateFrame("Button", "PrimalBindsPetBattle" .. key .. "Button", _G.UIParent,
        "SecureActionButtonTemplate")
      proxyButton:SetAttribute("type", "click")
      proxyButton:SetAttribute("clickbutton", self)
      proxyButton:RegisterForClicks("AnyDown")
    end)

    for _, button in _G.ipairs(buttons) do
      local key = keys[button:GetID()]
      local proxyButton = _G.CreateFrame("Button", "PrimalBindsPetBattle" .. key .. "Button", _G.UIParent,
        "SecureActionButtonTemplate")
      proxyButton:SetAttribute("type", "click")
      proxyButton:SetAttribute("clickbutton", button)
      proxyButton:RegisterForClicks("AnyDown")
    end

    _G.hooksecurefunc("PetBattleAbilityButton_UpdateHotKey", function(self)
      self.HotKey:SetText(keys[self:GetID()])
      self.HotKey:Show()
    end)
  end -- http://wowprogramming.com/utils/xmlbrowser/live/AddOns/Blizzard_PetBattleUI/Blizzard_PetBattleUI.lua

  -- wow.gamepedia.com/Creating_a_slash_command
  _G.SLASH_PRIMALBINDS1, SLASH_PRIMALBINDS2 = "/primalbinds"
  _G.SlashCmdList.PRIMALBINDS = function(message, editBox)
    if not _G.InCombatLockdown() and message == "bind" then
      bind()
    end
  end

  self.ADDON_LOADED = nil
end

function update()
  _G.assert(not _G.InCombatLockdown())
  for _, macro in _G.ipairs(macros) do
    if macro.update and macro.button then
      macro:update()
    end
  end
end

-- http://wowpedia.org/AddOn_loading_process#Order_of_events_fired_during_loading
function handlerFrame:PLAYER_LOGIN()
  _G.assert(not _G.InCombatLockdown())

  do
    -- Find the first action slot that Prowl (could be 5215 or 102547) is placed in. We can use it to find if
    -- Incarnation is active or not. If we move Prowl we have to /reload; TODO: can we find the new action slot directly
    -- even if in combat?
    -- http://wowpedia.org/API_GetActionInfo
    -- http://wowprogramming.com/docs/api/GetActionInfo
    local actionType, id, subType
    if db.prowlActionSlot then
      actionType, id, subType = _G.GetActionInfo(db.prowlActionSlot)
    end
    if not actionType or actionType ~= "spell" or not id or (id ~= 5215 and id ~= 102547) then
      db.prowlActionSlot = nil
      for i = 1, 120 do
        local actionType, id, subType = _G.GetActionInfo(i)
        if actionType and actionType == "spell" and (id == 5215 or id == 102547) then
          db.prowlActionSlot = i
          break
        end
      end
    end
    secureHeader:SetAttribute("prowlActionSlot", db.prowlActionSlot)
  end

  do
    local actionType, id
    if db.randomFavMountActionSlot then
      actionType, id = _G.GetActionInfo(db.randomFavMountActionSlot)
    end
    if not actionType or actionType ~= "summonmount" or not id or id ~= 268435455 then
      db.randomFavMountActionSlot = nil
      for i = 1, 120 do
        local actionType, id = _G.GetActionInfo(i)
        if actionType and actionType == "summonmount" and id == 268435455 then
          db.randomFavMountActionSlot = i
          break
        end
      end
    end
  end

  local specID, _ = _G.GetSpecializationInfo(_G.GetSpecialization() or 2)
  _G.assert(specID)

  for _, macro in _G.ipairs(macros) do
    _G.assert(macro.key)
    if not macro.specs or macro.specs[specID] then
      if macro.text or macro.init or macro.update then
        macro.button = _G.CreateFrame("Button", addonName .. macro.key .. "Button", _G.UIParent,
          "SecureActionButtonTemplate")
      end
      if macro.init --[[and _G.type(macro.init) == "function"]] then
        macro:init()
      elseif macro.button then
        macro.button:SetAttribute("type", "macro")
        -- By default, a button only receives the left mouse button's "up" action.
        macro.button:RegisterForClicks("AnyDown")
      end
      if macro.text then
        macro.button:SetAttribute("*macrotext1", macro.text)
      end
    end
  end

  update()
end

function handlerFrame:PLAYER_ENTERING_WORLD()
  _G.assert(not _G.InCombatLockdown())
  update()
end

function handlerFrame:SPELLS_CHANGED(...)
  _G.print("SPELLS_CHANGED", ...)
end

-- This event seems to be posted when gaining a level, in which case we may be in combat.
-- http://wowprogramming.com/docs/events/PLAYER_SPECIALIZATION_CHANGED
function handlerFrame:PLAYER_SPECIALIZATION_CHANGED(unit)
  _G.assert(unit == "player")
  if not _G.InCombatLockdown() then
    update()
  else
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
  end
end

function handlerFrame:PLAYER_REGEN_DISABLED()
  _G.assert(not _G.InCombatLockdown())
  update()
end

function handlerFrame:ARENA_PREP_OPPONENT_SPECIALIZATIONS()
  _G.assert(not _G.InCombatLockdown())
  update()
end

function handlerFrame:PLAYER_REGEN_ENABLED()
  _G.assert(not _G.InCombatLockdown())
  update()
  self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

handlerFrame:RegisterEvent("ADDON_LOADED")
handlerFrame:RegisterEvent("PLAYER_LOGIN")
handlerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
--handlerFrame:RegisterEvent("SPELLS_CHANGED")
handlerFrame:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
--handlerFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
handlerFrame:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")

-- vim: tw=120 sts=2 sw=2 et
