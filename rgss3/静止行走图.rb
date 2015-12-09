
#--------------------------------------------------------------------------
# ● require Taroxd基础设置
#    静止的人物行走图。
#    图片文件名以 # 开头时，该图片将被视为一个唯一朝向的人物。
#--------------------------------------------------------------------------

# 文件名满足的条件
Taroxd::StaticCharacter = -> name { name.start_with?('#') }

class Sprite_Character < Sprite_Base

  def static?
    Taroxd::StaticCharacter.call(@character_name)
  end

  def_chain :set_character_bitmap do |old|
    static? ? self.bitmap = Cache.character(@character_name) : old.call
  end

  def_unless :update_src_rect, :static?
end