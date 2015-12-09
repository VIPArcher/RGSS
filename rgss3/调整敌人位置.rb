
#--------------------------------------------------------------------------
# ● require Taroxd基础设置
#    在「敌人」中备注 <offset x a> <offset y b>，其中 a, b 为偏移量。
#--------------------------------------------------------------------------

class RPG::Enemy < RPG::BaseItem
  note_i :offset_x
  note_i :offset_y
end

class Game_Troop
  def_after :setup do |_|
    @enemies.each do |enemy|
      enemy.screen_x += enemy.enemy.offset_x
      enemy.screen_y += enemy.enemy.offset_y
    end
  end
end