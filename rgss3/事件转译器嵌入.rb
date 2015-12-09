
#----------------------------------------------------------------------------
# ● require 事件转译器
#----------------------------------------------------------------------------

class Taroxd::Translator

  # 是否需要与旧存档兼容。不是新工程的话填 true。
  SAVEDATA_COMPATIBLE = false

  # 读档时是否重新执行事件。（暂不支持从中断处开始。因此建议不要在事件执行时存档）
  # true 表示读档时从头开始执行事件，false 表示读档时丢弃执行中的事件。
  # 该选项仅当 SAVEDATA_COMPATIBLE 为 false 时有效。
  RUN_ON_LOAD = false

  # 调试模式，开启时会将转译的脚本输出到控制台
  DEBUG = false

  @cache = {}

  class << self
    attr_reader :cache
  end
end

class Game_Interpreter

  Translator = Taroxd::Translator

  def run
    wait_for_message
    instance_eval(&compile_code)
    Fiber.yield
    @fiber = nil
  end

  unless Translator::SAVEDATA_COMPATIBLE

    def marshal_dump
      [@map_id, @event_id, @list]
    end

    def marshal_load(obj)
      @map_id, @event_id, @list = obj
      create_fiber if Translator::RUN_ON_LOAD
    end
  end # unless Translator::SAVEDATA_COMPATIBLE

  private

  def rb_code
    Translator.translate(@list, @map_id, @event_id)
  end

  def translator_binding
    binding
  end

  if $TEST && Translator::DEBUG

    def compile_code
      proc = Translator.cache[[@list, @map_id, @event_id]]
      return proc if proc
      code = rb_code
      puts code
      Translator.cache[[@list, @map_id, @event_id]] =
        eval(code, translator_binding)
    rescue StandardError, SyntaxError => e
      p e
      puts e.backtrace
      rgss_stop
    end

  else

    def compile_code
      Translator.cache[[@list, @map_id, @event_id]] ||=
        eval(rb_code, translator_binding)
    end

  end # if $TEST && Translator::DEBUG
end

# 切换地图时，清除事件页转译代码的缓存

class Game_Map

  alias_method :setup_without_translator, :setup

  def setup(map_id)
    setup_without_translator(map_id)
    Taroxd::Translator.cache.clear
  end
end
