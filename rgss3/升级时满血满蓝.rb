
#--------------------------------------------------------------------------
# ● require Taroxd基础设置
#    升级时满血满蓝
#--------------------------------------------------------------------------

Taroxd::RecoverOnLvUP = true

Game_Actor.send :def_after, :level_up, :recover_all