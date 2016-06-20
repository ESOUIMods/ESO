local addon = {
	name = "SetManager",
	playerDefaults =
	{
		sets = { }
	},
	accountDefaults =
	{
		sets = { }
	},
}

local am = GetAnimationManager()
local wm = GetWindowManager()
local em = GetEventManager()

local function InitializeSlots(parent)
	local slots =
	{
		[EQUIP_SLOT_HEAD] = parent:GetNamedChild("EquipmentSlotsHead"),
		[EQUIP_SLOT_NECK] = parent:GetNamedChild("EquipmentSlotsNeck"),
		[EQUIP_SLOT_CHEST] = parent:GetNamedChild("EquipmentSlotsChest"),
		[EQUIP_SLOT_SHOULDERS] = parent:GetNamedChild("EquipmentSlotsShoulder"),
		[EQUIP_SLOT_MAIN_HAND] = parent:GetNamedChild("EquipmentSlotsMainHand"),
		[EQUIP_SLOT_OFF_HAND] = parent:GetNamedChild("EquipmentSlotsOffHand"),
		[EQUIP_SLOT_POISON] = parent:GetNamedChild("EquipmentSlotsPoison"),
		[EQUIP_SLOT_WAIST] = parent:GetNamedChild("EquipmentSlotsBelt"),
		[EQUIP_SLOT_LEGS] = parent:GetNamedChild("EquipmentSlotsLeg"),
		[EQUIP_SLOT_FEET] = parent:GetNamedChild("EquipmentSlotsFoot"),
		[EQUIP_SLOT_COSTUME] = parent:GetNamedChild("EquipmentSlotsCostume"),
		[EQUIP_SLOT_RING1] = parent:GetNamedChild("EquipmentSlotsRing1"),
		[EQUIP_SLOT_RING2] = parent:GetNamedChild("EquipmentSlotsRing2"),
		[EQUIP_SLOT_HAND] = parent:GetNamedChild("EquipmentSlotsGlove"),
		[EQUIP_SLOT_BACKUP_MAIN] = parent:GetNamedChild("EquipmentSlotsBackupMain"),
		[EQUIP_SLOT_BACKUP_OFF] = parent:GetNamedChild("EquipmentSlotsBackupOff"),
		[EQUIP_SLOT_BACKUP_POISON] = parent:GetNamedChild("EquipmentSlotsBackupPoison"),
	}

	parent.slots = slots

	parent:GetNamedChild("PaperDoll"):SetTexture(GetUnitSilhouetteTexture("player"))

	local ZO_Character_GetEmptyEquipSlotTexture = ZO_Character_GetEmptyEquipSlotTexture
	for slotId, slotControl in pairs(slots) do
		local iconControl = slotControl:GetNamedChild("Icon")
		iconControl:SetTexture(ZO_Character_GetEmptyEquipSlotTexture(slotId))
	end
end

local function PlayerActivated()
	em:UnregisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED)
	-- RefreshWornInventory()
	-- RefreshBackUpWeaponSlotStates()
end

local function PlayerDeactivated()
	local function ScanInventory(bagId, list)
		list = list or { }

		local slotIndex = ZO_GetNextBagSlotIndex(bagId, nil)
		local IsEquipable, GetItemLink, GetItemLinkSetInfo = IsEquipable, GetItemLink, GetItemLinkSetInfo
		while slotIndex do
			if IsEquipable(bagId, slotIndex) then
				local itemLink = GetItemLink(bagId, slotIndex)
				local hasSet = GetItemLinkSetInfo(itemLink, false)
				if hasSet then
					list[#list + 1] = itemLink
				end
			end
			slotIndex = ZO_GetNextBagSlotIndex(bagId, slotIndex)
		end

		return list
	end
	addon.account.sets = ScanInventory(BAG_BANK)
	addon.player.sets = ScanInventory(BAG_WORN, ScanInventory(BAG_BAGBACK))
end

function addon:InitWindow()
	local control

	control = CreateControlFromVirtual("SetManager_Character", nil, "SetManager_Character_Template")
	control:SetAnchor(TOPLEFT, ZO_SharedWideLeftPanelBackground, TOPLEFT, 0, -40)
	control:SetAnchor(BOTTOMLEFT, ZO_SharedWideLeftPanelBackground, BOTTOMLEFT, 0, -30)

	addon.windowSet = control
	InitializeSlots(control)
	SETMANAGER_CHARACTER_FRAGMENT = ZO_FadeSceneFragment:New(addon.windowSet, false, 0)
	STATS_SCENE:AddFragment(THIN_LEFT_PANEL_BG_FRAGMENT)
	STATS_SCENE:AddFragment(SETMANAGER_CHARACTER_FRAGMENT)

	em:RegisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED, PlayerActivated)
	em:RegisterForEvent(addon.name, EVENT_PLAYER_DEACTIVATED, PlayerDeactivated)
end

local function OnAddonLoaded(event, name)
	if name ~= addon.name then return end
	em:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

	addon.player = ZO_SavedVars:New("SetManager_Data", 1, nil, addon.playerDefaults, nil)
	addon.account = ZO_SavedVars:NewAccountWide("SetManager_Data", 1, nil, addon.accountDefaults, nil)

	addon:InitWindow()
end

em:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

SET_MANAGER = addon