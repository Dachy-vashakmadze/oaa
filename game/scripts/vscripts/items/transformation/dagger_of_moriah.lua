---
--- Created by Zarnotox.
--- DateTime: 03-Dec-17 21:32
---

item_dagger_of_moriah = class(TransformationBaseClass)

LinkLuaModifier( "modifier_item_dagger_of_moriah_sangromancy", "items/transformation/dagger_of_moriah.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function item_dagger_of_moriah:GetIntrinsicModifierName()
  return "modifier_item_dagger_of_moriah"
end

function item_dagger_of_moriah:GetTransformationModifierName()
  return "modifier_item_dagger_of_moriah_sangromancy"
end

--------------------------------------------------------------------------------

modifier_item_dagger_of_moriah_sangromancy = class(ModifierBaseClass)
modifier_item_dagger_of_moriah = class(ModifierBaseClass)

--------------------------------------------------------------------------------

function modifier_item_dagger_of_moriah:IsHidden()
  return true
end

--------------------------------------------------------------------------------

function modifier_item_dagger_of_moriah_sangromancy:IsHidden()
  return false
end

function modifier_item_dagger_of_moriah_sangromancy:IsDebuff()
  return false
end

function modifier_item_dagger_of_moriah_sangromancy:IsPurgable()
  return false
end


--------------------------------------------------------------------------------

function modifier_item_dagger_of_moriah_sangromancy:OnCreated( event )
  local spell = self:GetAbility()

  spell.mod = self

  self.spellamp = spell:GetSpecialValueFor( "sangromancy_spell_amp" )
  self.selfDamage = spell:GetSpecialValueFor( "sangromancy_self_damage" )
end

--------------------------------------------------------------------------------

function modifier_item_dagger_of_moriah_sangromancy:OnRefresh( event )
  local spell = self:GetAbility()

  spell.mod = self

  self.spellamp = spell:GetSpecialValueFor( "sangromancy_spell_amp" )
  self.selfDamage = spell:GetSpecialValueFor( "sangromancy_self_damage" )
end

--------------------------------------------------------------------------------

function modifier_item_dagger_of_moriah_sangromancy:OnRemoved()
  local spell = self:GetAbility()

  if spell and not spell:IsNull() then
    spell.mod = nil
  end
end

--------------------------------------------------------------------------------

function modifier_item_dagger_of_moriah_sangromancy:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    MODIFIER_EVENT_ON_TAKEDAMAGE,
  }

  return funcs
end

--------------------------------------------------------------------------------

function modifier_item_dagger_of_moriah_sangromancy:GetModifierSpellAmplify_Percentage( event )
  local spell = self:GetAbility()

  return self.spellamp or spell:GetSpecialValueFor( "sangromancy_spell_amp" )
end

--------------------------------------------------------------------------------

function modifier_item_dagger_of_moriah_sangromancy:OnTakeDamage(event)
  if event.damage_category == 0 and event.attacker == self:GetParent() and not (event.unit == self:GetParent()) then

    local damage = {
      victim = event.attacker,
      attacker = event.attacker,
      damage = event.original_damage * (self.selfDamage / 100),
      damage_type = event.damage_type,
      ability = self:GetAbility(),
    }

    ApplyDamage( damage )
  end
end

--------------------------------------------------------------------------------

item_dagger_of_moriah_2 = item_dagger_of_moriah
