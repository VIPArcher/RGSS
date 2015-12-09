
#--------------------------------------------------------------------------
# ● require Taroxd基础设置
#    更改角色/敌人普通攻击/防御的技能ID
#
#    使用方法：
#      在装备/技能/角色/职业/敌人上备注 <attackskill x> / <guardskill x>
#      建议与“战斗指令优化”配合使用。
#--------------------------------------------------------------------------

Taroxd::AttackSkill = true

class RPG::BaseItem
  note_i :attack_skill, false
  note_i :guard_skill,  false
end

class Game_BattlerBase

  def_chain :attack_skill_id do |old|
    note_objects { |item| return item.attack_skill if item.attack_skill }
    old.call
  end

  def_chain :guard_skill_id do |old|
    note_objects { |item| return item.guard_skill if item.guard_skill }
    old.call
  end
end
