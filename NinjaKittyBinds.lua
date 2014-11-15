NinjaKittyBinds = { _G = _G }
setfenv(1, NinjaKittyBinds)

-- Can we make a macro that targets our last target and works when a Hunter uses Play Dead and stuff? Maybe
--   /targetlasttarget [noexists]
-- or
--   /stopmacro [exists]
--   /targetlasttarget
--   /startattack [combat,nostealth]

-- Can't target totems: Healing Stream Totem, Windwalk Totem, Earthbind Totem, Earthgrab Totem, Mana Tide Totem,
-- Healing Tide Totem, Capacitor Totem, Spirit Link Totem, ...

-- I think "/use [@party1]Rejuvenation" while having a party1 but being far away causes Rejuvenation to wait for us
-- clicking a target (SpellIsTargeting()). "/use [@party1,exists]Rejuvenation" is the same. "/use [@party1,help]
-- Rejuvenation" doesn't do it.
-- This seems like a better fix than "/use 1"  which has the effect of the protected function SpellStopTargeting()
-- (1 is INVSLOT_HEAD, see: http://wowpedia.org/InventorySlotId). "/use 0" doesn't work for this.

-- Add /mountspeical to Savage Roar macros? This animation is now played by default when using Savage Roar.

-- Form numbers as of Patch 6.0.2.
-- 0: No Form
-- 1: Bear Form
-- 2: Cat Form
-- 3: Travel Form

-- As of patch 6.0.2, this pattern does not work anymore: "/castsequence 0,Cat Form". Cat Form will never be used.

-- [@target] stops some abilities from auto-acquiring a target. It does not stop them from dropping a friendly to
-- acquire a hostile one.

-- TODO: Bind Moonfire. Do something clever about Glyph of the Stag.

local secureHeader = _G.CreateFrame("Frame", nil, _G.UIParent, "SecureHandlerBaseTemplate")

---- < MACROS > --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- Used to have "/cancelaura [form:2]Incarnation: King of the Jungle".

local macros = {
  { key = "`", text =
      "/cancelform [form:3,flying]\n" ..
      "/use Stampeding Roar"
  },
  { key = "SHIFT-`" },
  { key = "ALT-`" },
  { key = "1", text =
      "/cancelform [form:3,flying]\n" ..
      "/use Dash"
  },
  { key = "SHIFT-1" },
  { key = "ALT-1" },
  { key = "2", text =
      "/use Healthstone"
  },
  { key = "SHIFT-2", text =
      "/use Nature's Vigil",
  },
  { key = "ALT-2", text =
      "/cancelaura Hand of Protection\n" ..
      "/cancelaura Prowl\n" ..
      "/use [nocombat]Conjured Mana Buns\n" ..
      "/use [nocombat]Conjured Mana Pudding\n" ..
      "/use [nocombat]Cobo Cola\n" ..
      "/use [nocombat]Golden Carp Consomme",
  },
  { key = "3", specs = { [103] = true },
    init = function(self)
      self.button:SetAttribute("type", "macro")
      self.button:SetAttribute("*macrotext1", -- Used when Incarnation isn't active (Prowl's spell ID is 5215).
        "/use Incarnation: King of the Jungle"
      )
      self.button:SetAttribute("*macrotext2", -- Used when Incarnation is active (Prowl's spell ID is 102547).
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
  { key = "SHIFT-3", text =
      "/use Incarnation: King of the Jungle\n" ..
      "/use 14\n" ..
      "/use Berserk\n" ..
      "/use Berserking",
  },
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
  { -- TODO: Fix all the ress macros. [dead] seems to correspond to UnitIsDeadOrGhost().
    key = "4", text =
      "/use [@mouseover,help,dead]Rebirth;[@mouseover,help]Healing Touch;[help,dead]Rebirth;[help]Healing Touch;" ..
        "[@player]Healing Touch",
  },
  { key = "SHIFT-4",
    update = function(self)
      self.button:SetAttribute("*macrotext1",
        "/use [@" .. db.party1 .. ",help,dead]Rebirth;[@" .. db.party1 .. ",help]Healing Touch"
      )
    end,
  },
  --[=[
  { -- This would be nice, but we can't get the name of a targeted party or raid member from a restricted environment.
    key = "SHIFT-4",
    init = function(self)
      self.button:SetAttribute("type", "macro")
      _G.SecureHandlerWrapScript(self.button, "OnClick", secureHeader, [[
        if not self:GetAttribute("party1") or self:GetAttribute("party1") ~= owner:GetAttribute("party1") then
          local party1 = owner:GetAttribute("party1")
          self:SetAttribute("party1", party1)
          local text = "/use [@" .. party1 .. ",help,dead]Rebirth;[@" .. party1 .. ",help]Healing Touch"
          self:SetAttribute("*macrotext1", text)
        end
      ]])
      self.button:RegisterForClicks("AnyDown")
    end,
  },
  ]=]
  { key = "ALT-4",
    update = function(self)
      self.button:SetAttribute("*macrotext1",
        "/use [@" .. db.party2 .. ",help,dead]Rebirth;[@" .. db.party2 .. ",help]Healing Touch"
      )
    end,
  },
  { key = "5", text =
      "/use [form:1]Frenzied Regeneration\n" ..
      "/use [@mouseover,help,dead]Revive;[@mouseover,help]Rejuvenation;[help,dead]Revive;[help]Rejuvenation;" ..
        "[@player]Rejuvenation",
  },
  { key = "SHIFT-5",
    update = function(self)
      self.button:SetAttribute("*macrotext1",
        "/use [form:1]Frenzied Regeneration\n" ..
        "/use [@" .. db.party1 .. ",help,dead]Revive;[@" .. db.party1 .. ",help]Rejuvenation"
      )
    end,
  },
  { key = "ALT-5",
    update = function(self)
      self.button:SetAttribute("*macrotext1",
        "/use [form:1]Frenzied Regeneration\n" ..
        "/use [@" .. db.party2 .. ",help,dead]Revive;[@" .. db.party2 .. ",help]Rejuvenation"
      )
    end,
  },
  { key = "6", text =
      "/use Heart of the Wild\n" ..
      "/use Renewal\n" ..
      "/use [@mouseover,help,nodead][help,nodead][@player]Cenarion Ward",
  },
  { key = "SHIFT-6",
    update = function(self)
      self.button:SetAttribute("*macrotext1",
        "/use [@" .. db.party1 .. ",help]Heart of the Wild\n" ..
        "/use [@" .. db.party1 .. ",help]Cenarion Ward"
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
      "/cancelaura Prowl\n" .. -- When we want to Shadowmeld, we want to Shadowmeld! We don't want to be told that
      "/use Shadowmeld",       -- "a more powerful spell is already active".
  },
  { key = "SHIFT-TAB" },
  { key = "ALT-TAB" },
  { key = "Q", text = "/use 13" },
  { key = "SHIFT-Q", text =
      "",
  },
  { key = "ALT-Q" },
  { key = "W", text = "/use Survival Instincts" },
  { key = "SHIFT-W",text =
      "/tar arena1",
  },
  { key = "ALT-W",
    update = function(self)
      if (_G.select(2, _G.IsInInstance())) == "arena" then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena1,form:1/2]Wild Charge"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use [@focus,form:1/2]Wild Charge"
        )
      end
    end,
  },
  { key = "E", text =
      "/stopcasting\n" ..
      "/use [noform:1/2]Cat Form;[@arena1]Skull Bash",
  },
  { key = "SHIFT-E",
    update = function(self)
      if (_G.select(2, _G.IsInInstance())) == "arena" then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena1]Cyclone"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use [@focus]Cyclone"
        )
      end
    end,
  },
  { key = "ALT-E",
    update = function(self)
      if (_G.select(2, _G.IsInInstance())) == "arena" then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena1]Faerie Fire"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use [@focus]Faerie Fire"
        )
      end
    end,
  },
  { key = "R", text =
      "/use [noform:2]Cat Form;Maim" -- Maim doesn't seem to auto-acquire a target.
  },
  { key = "SHIFT-R", specs = { [103] = true }, text =
      "/use [form:1]Frenzied Regeneration\n" ..
      "/use [noform:2]Cat Form;Savage Roar",
  },
  { key = "ALT-R",
    update = function(self)
      if (_G.select(2, _G.IsInInstance())) == "arena" then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena1]Maim"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use [@focus]Maim"
        )
      end
    end,
  },
  { key = "T", text =
      "/stopcasting\n" ..
      "/use Typhoon",
  },
  { key = "SHIFT-T",
    update = function(self)
      if (_G.select(2, _G.IsInInstance())) == "arena" then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena1]Entangling Roots"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use [@focus]Entangling Roots"
        )
      end
    end,
  },
  { key = "ALT-T",
    update = function(self)
      if (_G.select(2, _G.IsInInstance())) == "arena" then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena1]Mighty Bash"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use [@focus]Mighty Bash"
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
  { key = "ESCAPE", text =
      "/use [form:1]Frenzied Regeneration\n" ..
      "/cancelform [form]\n" ..
      "/dismount [mounted]\n" ..
      "/stopcasting",
  },
  { key = "SHIFT-ESCAPE" },
  { key = "ALT-ESCAPE" },
  { key = "A", text =
      "/use [form:1]Frenzied Regeneration\n" ..
      "/use [form:1]!Bear Form;[form:2]!Cat Form;[form:3][swimming]!Travel Form;!Cat Form",
  },
  { key = "SHIFT-A", text =
      "",
  },
  { key = "ALT-A" },
  { key = "S", -- Canceling form and using Wild Charge with just one click isn't possible (I think).
    update = function(self)
      self.button:SetAttribute("*macrotext1",
        "/stopcasting\n" ..
        "/use Displacer Beast\n" ..
        "/use [form:3][@mouseover,help,noform][@mouseover,harm,form:1/2][help,noform][harm,form:1/2][@" .. db.party1
          .. ",help,noform]Wild Charge\n" ..
        "/use [form:3]1"
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
  { key = "SHIFT-S",text =
      "/tar arena2",
  },
  { key = "ALT-S",
    update = function(self)
      if (_G.select(2, _G.IsInInstance())) == "arena" then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena2,form:1/2]Wild Charge"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use [form:1/2]Wild Charge"
        )
      end
    end,
  },
  { key = "D",
    update = function(self)
      if (_G.select(2, _G.IsInInstance())) == "arena" then
        self.button:SetAttribute("*macrotext1",
          "/stopcasting\n" ..
          "/use [noform:1/2]Cat Form;[@mouseover,harm][@arena2]Skull Bash"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/stopcasting\n" ..
          "/use [noform:1/2]Cat Form;[@mouseover,harm][]Skull Bash"
        )
      end
    end,
  },
  { key = "SHIFT-D",
    update = function(self)
      if (_G.select(2, _G.IsInInstance())) == "arena" then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena2]Cyclone"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use Cyclone"
        )
      end
    end,
  },
  { key = "ALT-D",
    update = function(self)
      if (_G.select(2, _G.IsInInstance())) == "arena" then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena2]Faerie Fire"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use Faerie Fire"
        )
      end
    end,
  },
  { key = "F",
    init = function(self)
      self.button:SetAttribute("type", "macro")
      self.button:SetAttribute("*macrotext1", -- Used when [noform:2].
        "/use Cat Form"
      )
      self.button:SetAttribute("*macrotext2", -- Used when [harm].
        "/use [form:1]Frenzied Regeneration\n" ..
        "/use [noform:2]Cat Form;[@mouseover,harm][]Shred\n" ..
        "/stopattack [stealth]"
      )
      self.button:SetAttribute("*macrotext3", -- Used when [noexists][noharm].
        "/use [form:1]Frenzied Regeneration\n" ..
        "/use [noform:2]Cat Form;[@mouseover,harm]Shred\n" ..
        "/stopmacro [noform:2][@mouseover,harm]\n" ..
        "/targetenemyplayer [stealth]\n" ..
        "/stopmacro [noexists][noharm]\n" ..
        "/use [harm]Shred\n" ..
        "/cleartarget"
      )
      self.button:SetAttribute("*macrotext4", -- Used when we have Incarnation.
        "/use [harm]Shred" -- Shred auto-acquires a target when without a hostile target.
      )
      -- Our snippets get these arguments: self, button, down.  See
      -- "http://wowprogramming.com/utils/xmlbrowser/live/FrameXML/SecureTemplates.lua" and "Iriel’s Field Guide to
      -- Secure Handlers".
      _G.SecureHandlerWrapScript(self.button, "OnClick", secureHeader, [[
        local spellId = select(2, GetActionInfo(owner:GetAttribute("prowlActionSlot")))
        if spellId == 5215 then
          if GetBonusBarOffset() == 1 then
            if UnitExists("target") and PlayerCanAttack("target") then
              return "RightButton"
            else
              return "MiddleButton"
            end
          end
        elseif spellId == 102547 then
          return "Button4"
        else
          return false
        end
      ]])
      self.button:RegisterForClicks("AnyDown")
    end,
  },
  { key = "SHIFT-F", text =
      "/use [noform:2]Cat Form;[harm]Ferocious Bite",
  },
  { key = "ALT-F",
    update = function(self)
      if (_G.select(2, _G.IsInInstance())) == "arena" then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena2]Maim"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use [@target]Maim"
        )
      end
    end,
  },
  { key = "G",
    init = function(self)
      self.button:SetAttribute("type", "macro")
      self.button:SetAttribute("*macrotext1", -- Used when [harm].
        "/use Incapacitating Roar\n" ..
        "/use Ursol's Vortex\n" ..
        "/use [@mouseover,harm][]Mighty Bash"
      )
      self.button:SetAttribute("*macrotext2", -- Used when [noexists][noharm].
        "/use Incapacitating Roar\n" ..
        "/use Ursol's Vortex\n" ..
        "/use [@mouseover,harm]Mighty Bash\n" ..
        "/stopmacro [@mouseover,harm]\n" ..
        "/targetenemyplayer [stealth]\n" ..
        "/stopmacro [noexists][noharm]\n" ..
        "/use Mighty Bash\n" ..
        "/cleartarget"
      )
      _G.SecureHandlerWrapScript(self.button, "OnClick", secureHeader, [[
        if not UnitExists("target") or not PlayerCanAttack("target") then
          return "RightButton"
        end
      ]])
      self.button:RegisterForClicks("AnyDown")
    end,
  },
  { key = "SHIFT-G",
    update = function(self)
      if (_G.select(2, _G.IsInInstance())) == "arena" then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena2]Entangling Roots"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use Entangling Roots"
        )
      end
    end,
  },
  { key = "ALT-G",
    update = function(self)
      if (_G.select(2, _G.IsInInstance())) == "arena" then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena2]Mighty Bash"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use Mighty Bash"
        )
      end
    end,
  },
  { key = "H", specs = { [102] = true, [103] = true, [104] = true },
    update = function(self)
      self.button:SetAttribute("*macrotext1",
        "/use [form:1]Frenzied Regeneration\n" ..
        "/use [@" .. db.party1 .. ",help]Remove Corruption"
      )
    end,
  },
  { key = "SHIFT-H", text =
      "/use Soothe",
  },
  { key = "ALT-H", text =
      "/use [noform:2]Cat Form;[harm][@none]Thrash",
  },
  --[=[
  { key = "Z", specs = { [103] = true },
    init = function(self)
      self.button:SetAttribute("type", "macro")
      self.button:SetAttribute("*macrotext1", -- Used when [harm].
        "/cancelform [form:3,flying]\n" ..
        "/use !Prowl\n" ..
        "/use [nostealth]Shadowmeld"
      )
      self.button:SetAttribute("*macrotext2", -- Used when [noexists][noharm].
        "/cancelform [form:3,flying]\n" ..
        "/use !Prowl\n" ..
        "/use [nostealth]Shadowmeld"
      )
      self.button:SetAttribute("*macrotext3", -- Used when we have Incarnation.
        "/cancelform [form:3,flying]\n" ..
        "/use !Prowl"
      )
      _G.SecureHandlerWrapScript(self.button, "OnClick", secureHeader, [[
        local spellId = select(2, GetActionInfo(owner:GetAttribute("prowlActionSlot")))
        if spellId == 5215 then
          if not UnitExists("target") or not PlayerCanAttack("target") then
            return "RightButton"
          end
        elseif spellId == 102547 then
          return "MiddleButton"
        else
          return false
        end
      ]])
      self.button:RegisterForClicks("AnyDown")
    end
  },
  ]=]
  { key = "Z", text =
      "/use [form:2,nocombat,nostealth]Conjured Mana Buns\n" ..
      "/use [form:2,nocombat,nostealth]Conjured Mana Pudding\n" ..
      "/use [form:2,nocombat,nostealth]Cobo Cola\n" ..
      "/use [form:2,nocombat,nostealth]Golden Carp Consomme\n" ..
      "/cancelform [form:3,flying]\n" ..
      "/use !Prowl",
  },
  { key = "SHIFT-Z", text =
      ""
  },
  { key = "ALT-Z" },
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
        "/use Tiger's Fury\n" ..
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
  { key = "SHIFT-X",text =
      "/tar arena3",
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
          "/use Tiger's Fury\n" ..
          "/use 14\n" ..
          "/use Berserk\n" ..
          "/use Berserking"
        )
      end
    end,
  },
  ]]
  { key = "ALT-X",
    update = function(self)
      if (_G.select(2, _G.IsInInstance())) == "arena" then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena3,form:1/2]Wild Charge"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use [@focus,form:1/2]Wild Charge"
        )
      end
    end,
  },
  { key = "C", text =
      "/stopcasting\n" ..
      "/use [noform:1/2]Cat Form;[@arena3]Skull Bash",
  },
  { key = "SHIFT-C",
    update = function(self)
      if (_G.select(2, _G.IsInInstance())) == "arena" then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena3]Cyclone"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use [@focus]Cyclone"
        )
      end
    end,
  },
  { key = "ALT-C",
    update = function(self)
      if (_G.select(2, _G.IsInInstance())) == "arena" then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena3]Faerie Fire"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use [@focus]Faerie Fire"
        )
      end
    end,
  },
  { key = "V",
    init = function(self)
      self.button:SetAttribute("type", "macro")
      self.button:SetAttribute("*macrotext1", -- Used when [harm].
        "/use [@mouseover,harm][]Rake\n" ..
        "/stopattack [stealth]" -- Unlike Pounce, Rake and Shred will start auto-attack even when used in stealth, which
      )                         -- is retarded.
      self.button:SetAttribute("*macrotext2", -- Used when [noexists][noharm].
        "/use [@mouseover,harm]Rake\n" ..
        "/stopmacro [@mouseover,harm]\n" ..
        "/targetenemyplayer [stealth]\n" ..
        "/stopmacro [noexists][noharm]\n" ..
        "/use Rake\n" ..
        "/cleartarget"
      )
      _G.SecureHandlerWrapScript(self.button, "OnClick", secureHeader, [[
        if not UnitExists("target") or not PlayerCanAttack("target") then
          return "RightButton"
        end
      ]])
      self.button:RegisterForClicks("AnyDown")
    end,
  },
  { key = "SHIFT-V", text =
      "/use [noform:2]Cat Form;[harm]Rip",
  },
  { key = "ALT-V",
    update = function(self)
      if (_G.select(2, _G.IsInInstance())) == "arena" then
        self.button:SetAttribute("*macrotext1",
          "/use [@arena3]Maim"
        )
      else
        self.button:SetAttribute("*macrotext1",
          "/use [@focus]Maim"
        )
      end
    end,
  },
  { key = "B", text =
      "/use [form:1]Frenzied Regeneration\n" ..
      "/use [noform:1]Bear Form",
  },
  { key = "SHIFT-B",
    update = function(self)
      if (_G.select(2, _G.IsInInstance())) == "arena" then
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
      if (_G.select(2, _G.IsInInstance())) == "arena" then
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
      "/use !Travel Form",
  },
  { key = "ALT-N", text =
      "/use [noform:2]Cat Form;[harm,form:2][@none,form:2]Swipe",
  },
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
  { key = "ALT-MOUSEWHEELUP",
    update = function(self)
      self.button:SetAttribute("*macrotext1",
        "/stopcasting\n" ..
        "/cancelform\n" ..
        "/use [@" .. db.party1 .. ",help]Wild Charge"
      )
    end,
  },
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
  { key = "ALT-MOUSEWHEELDOWN",
    update = function(self)
      self.button:SetAttribute("*macrotext1",
        "/stopcasting\n" ..
        "/cancelform\n" ..
        "/use [@" .. db.party2 .. ",help]Wild Charge"
      )
    end,
  },
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
    key = "BUTTON4", init = function(self)
      self.button:SetAttribute("type", "macro")
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
      _G.SecureHandlerWrapScript(self.button, "OnClick", secureHeader, [[
        local macroText = ""
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
      self.button:RegisterForClicks("AnyDown")
    end,
  },
  { key = "SHIFT-BUTTON4", text = "/focus" },
  { key = "ALT-BUTTON4", text = "/focus party1" },
  { key = "BUTTON5", text = "/targetfriendplayer" },
  { key = "SHIFT-BUTTON5", text = "/targetfriend" },
  { key = "ALT-BUTTON5", text = "/focus party2" },
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
    if _G.type(macro.bind) == "function" then
      macro:bind()
    elseif macro.button then
      _G.SetBindingClick(macro.key, macro.button:GetName(), "LeftButton")
    else--[[if not macro.button then]]
      _G.SetBinding(macro.key, "CLICK NinjaKittyBindsDummyButton")
    end
  end

  -- See http://wowprogramming.com/docs/api_types#binding for the first parameter, http://wowpedia.org/BindingID for the
  -- second.
  _G.SetBinding("PRINTSCREEN", "SCREENSHOT")
  _G.SetBinding("F10", "TOGGLEGAMEMENU")
  _G.SetBinding("U", "TOGGLEWORLDMAP")
  _G.SetBinding("I", "OPENALLBAGS")
  _G.SetBinding("O", "TOGGLESOCIAL")
  _G.SetBinding("-", "MASTERVOLUMEDOWN")
  _G.SetBinding("=", "MASTERVOLUMEUP")
  --_G.SetBinding("F", "INTERACTMOUSEOVER")
  _G.SetBinding("J", "TOGGLEAUTORUN")
  _G.SetBinding("ENTER", "OPENCHAT")
  _G.SetBinding("/", "OPENCHATSLASH")
  _G.SetBinding("SPACE", "MOVEFORWARD")
  _G.SetBinding("BUTTON1", "CAMERAORSELECTORMOVE")
  _G.SetBinding("BUTTON2", "INTERACTMOUSEOVER")
  _G.SetBinding("BUTTON3", "JUMP")
  _G.SetBinding("CTRL-MOUSEWHEELUP", "CAMERAZOOMIN")
  _G.SetBinding("CTRL-MOUSEWHEELDOWN", "CAMERAZOOMOUT")

  _G.SaveBindings(_G.GetCurrentBindingSet())

  _G.print("Commands bound and saved as " .. (_G.GetCurrentBindingSet() == 1 and "account" or "character specific") ..
    " binding set.")
end

-- http://wowpedia.org/AddOn_loading_process#Order_of_events_fired_during_loading
function handlerFrame:ADDON_LOADED()
  self:UnregisterEvent("ADDON_LOADED")

  _G.assert(not _G.InCombatLockdown())

  if not _G.NinjaKittyBindsDB then
    _G.NinjaKittyBindsDB = {}
  end

  db = _G.NinjaKittyBindsDB

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

    overrideBarStateHandler:SetAttribute("_onstate-canexitvehicle", [[
      if newstate == "canexitvehicle" then
        self:SetBindingClick(false, "ESCAPE", "BT4Button85")
      elseif newstate == "nocanexitvehicle" then
        self:ClearBinding("ESCAPE")
      end
    ]])

    _G.RegisterStateDriver(overrideBarStateHandler, "canexitvehicle",
      "[canexitvehicle]canexitvehicle;nocanexitvehicle")

    overrideBarStateHandler:SetAttribute("_onstate-petbattle", [[
      if newstate == "petbattle" then
        for i, key in ipairs(table.new("A", "S", "D", "F", "G", "H")) do
          self:SetBindingClick(false, key, "NinjaKittyBindsPetBattle" .. key .. "Button")
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
      local proxyButton = _G.CreateFrame("Button", "NinjaKittyBindsPetBattle" .. key .. "Button", _G.UIParent,
        "SecureActionButtonTemplate")
      proxyButton:SetAttribute("type", "click")
      proxyButton:SetAttribute("clickbutton", self)
      proxyButton:RegisterForClicks("AnyDown")
    end)

    for _, button in _G.ipairs(buttons) do
      local key = keys[button:GetID()]
      local proxyButton = _G.CreateFrame("Button", "NinjaKittyBindsPetBattle" .. key .. "Button", _G.UIParent,
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

  -- http://wowpedia.org/Creating_a_slash_command
  _G.SLASH_NINJAKITTYKEYBINDS1, SLASH_NINJAKITTYKEYBINDS2 = "/nkb"
  _G.SlashCmdList.NINJAKITTYKEYBINDS = function(message, editBox)
    if not _G.InCombatLockdown() and message == "bind" then
      bind()
    end
  end

  self.ADDON_LOADED = nil
end

function _G.NinjaKittyBinds:update()
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

  local specID, specName = _G.GetSpecializationInfo(_G.GetSpecialization() or 2)

  for _, macro in _G.ipairs(macros) do
    _G.assert(macro.key)
    if not macro.specs or macro.specs[specID] then
      if macro.text or macro.init or macro.update then
        macro.button = _G.CreateFrame("Button", "NinjaKittyBinds" .. macro.key .. "Button", _G.UIParent,
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

-- vim: tw=120 sw=2 et
