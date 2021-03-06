
item_vampire = class(TransformationBaseClass)

LinkLuaModifier( "modifier_item_vampire", "items/transformation/vampire.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_vampire_active", "items/transformation/vampire.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function item_vampire:GetIntrinsicModifierName()
  return "modifier_item_vampire"
end

function item_vampire:GetTransformationModifierName()
  return "modifier_item_vampire_active"
end

item_vampire_2 = item_vampire
--------------------------------------------------------------------------------

modifier_item_vampire = class(ModifierBaseClass)
modifier_item_vampire_active = class(ModifierBaseClass)

--------------------------------------------------------------------------------

function modifier_item_vampire:IsHidden()
  return true
end

function modifier_item_vampire:DeclareFunctions()
  local funcs = {
    -- MODIFIER_EVENT_ON_HEALTH_GAINED,
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    MODIFIER_EVENT_ON_TAKEDAMAGE
  }
  return funcs
end

function modifier_item_vampire:GetModifierPreAttack_BonusDamage()
  return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_vampire:GetModifierBonusStats_Strength()
  return self:GetAbility():GetSpecialValueFor("bonus_strength")
end

function modifier_item_vampire:OnTakeDamage( event )
  if IsServer() then
    local parent = self:GetParent()
    local spell = self:GetAbility()

    if not self.mod then
      lifesteal(event, spell, parent, spell:GetSpecialValueFor('lifesteal_percent'))
    end
  end
end

--------------------------------------------------------------------------------

function modifier_item_vampire_active:IsPurgable()
  return false
end

function modifier_item_vampire_active:DeclareFunctions()
  local funcs = {
    -- MODIFIER_EVENT_ON_HEALTH_GAINED,
    MODIFIER_PROPERTY_DISABLE_HEALING,
    MODIFIER_EVENT_ON_TAKEDAMAGE
  }
  return funcs
end

function modifier_item_vampire_active:GetDisableHealing( kv )
  if IsServer() then
    -- Check that event is being called for the unit that self is attached to
    if not self.isVampHeal then
      return 1
    end
    return 0
  end
end

function modifier_item_vampire_active:OnTakeDamage( event )
  if IsServer() then
    local parent = self:GetParent()
    local spell = self:GetAbility()

    self.isVampHeal = true
    lifesteal(event, spell, parent, spell:GetSpecialValueFor('active_lifesteal_percent'))
    self.isVampHeal = false
  end
end

function lifesteal (event, spell, parent, amount)
  if IsServer() then
    -- if parent:PassivesDisabled() then
    --   return
    -- end

    if event.attacker ~= parent then
      return
    end

    local damage = event.damage

    if damage < 0 then
      return
    end

    if event.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then
      return
    end

    local parentTeam = parent:GetTeamNumber()
    local target = event.unit

    local ufResult = UnitFilter(
      target,
      DOTA_UNIT_TARGET_TEAM_ENEMY,
      DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
      DOTA_UNIT_TARGET_FLAG_NONE,
      parentTeam
    )

    if ufResult == UF_SUCCESS then
      parent:Heal( damage * ( amount * 0.01 ), parent )

      local part = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal_lanecreeps.vpcf", PATTACH_ABSORIGIN, parent )
      ParticleManager:ReleaseParticleIndex( part )
    else
      DebugPrint('Not lifestealing from ' .. tostring(target:GetName()))
    end
  end
end

Debug:EnableDebugging()
