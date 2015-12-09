
#--------------------------------------------------------------------------
# ● require Taroxd基础设置
#    简易调试控制台
#
#    require 快进游戏（fast_forward 功能）
#--------------------------------------------------------------------------

if $TEST

module Taroxd::Console

  KEY = :F5

  exit_help = 'exit 为真时，返回游戏。'

  HELP = <<-EOF.gsub(/^ {4}/, '')

    在控制台中可以执行任意脚本。下面是一些快捷方式。

    exit
      退出控制台并返回游戏。

    help
      显示这段帮助。

    recover(exit = true)
      完全恢复。#{exit_help}

    save(index = 0, exit = true)
      存档到指定位置。#{exit_help}

    load(index = 0, exit = true)
      从指定位置读档。#{exit_help}

    kill(hp = 0, exit = true)
      将敌方全体的 HP 设为 hp。仅战斗中可用。#{exit_help}

    suicide(hp = 0, exit = true)
      将己方全体的 HP 设为 hp。#{exit_help}

    fast_forward(*args)
      调用 Taroxd::FastForward。

    ff(*args)
      调用 Taroxd::FastForward 并返回游戏。

  EOF

  class << self

    EXIT_IDENTIFIER = Object.new   # 返回该值时，退出控制台并回到游戏

    # 获取窗口句柄
    console = Win32API.new('Kernel32', 'GetConsoleWindow', '', 'L').call
    game = Win32API.new('user32', 'GetActiveWindow', '', 'L').call
    hwnd = game
    set_window_pos = Win32API.new('user32', 'SetWindowPos', 'LLLLLLL', 'L')

    # 切换窗口
    define_method :switch_window do
      hwnd = hwnd == game ? console : game
      set_window_pos.call(hwnd, 0, 0, 0, 0, 0, 3)
    end

    # 如果按下按键，则进入控制台
    def update
      start if Input.trigger?(KEY)
    end

    alias_method :get_binding, :binding

    # 进入控制台
    def start
      switch_window
      binding = get_binding
      begin
        while (line = gets)
          next unless line[/\S/]
          _ = eval(line, binding)
          if _.equal?(EXIT_IDENTIFIER)
            switch_window
            Input.update    # 防止按下的 Enter 被游戏判定
            break
          end
          print '=> '
          p _
        end
      rescue => e
        p e
        retry
      end
    end

    def exit
      EXIT_IDENTIFIER
    end

    def help
      puts HELP
    end

    def recover(to_exit = true)
      $game_party.recover_all
      !to_exit || exit
    end

    def save(index = 0, to_exit = true)
      Sound.play_save
      DataManager.save_game_without_rescue(index)
      !to_exit || exit
    end

    def load(index = 0, to_exit = true)
      DataManager.load_game_without_rescue(index)
      Sound.play_load
      $game_system.on_after_load
      SceneManager.goto(Scene_Map)
      !to_exit || exit
    end

    def kill(hp = 0, to_exit = true)
      return to_exit && exit unless $game_party.in_battle
      $game_troop.each { |a| a.hp = hp }
      !to_exit || exit
    end

    def suicide(hp = 0, to_exit = true)
      $game_party.each { |a| a.hp = hp }
      !to_exit || exit
    end

    define_method :fast_forward, Taroxd::FastForward

    def ff(*args)
      fast_forward(*args)
      exit
    end
  end
end

Scene_Base.send :def_after, :update, Taroxd::Console.method(:update)

end # if $TEST