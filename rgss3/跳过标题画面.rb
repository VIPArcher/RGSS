
#----------------------------------------------------------------------------
# ● 测试游戏时跳过标题画面
#----------------------------------------------------------------------------

module Taroxd
  SkipTitle = $TEST && !$BTEST
end

def SceneManager.first_scene_class
  DataManager.setup_new_game
  $game_map.autoplay
  Scene_Map
end if Taroxd::SkipTitle