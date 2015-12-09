
#--------------------------------------------------------------------------
# ● require Taroxd基础设置
#    增加打开网页的功能。
#--------------------------------------------------------------------------

module Taroxd::Web
  API = Win32API.new('shell32.dll', 'ShellExecuteA', 'pppppi', 'i')
  module_function

  # 打开网页
  def open(uri)
    API.call(0, 'open', uri, 0, 0, 1)
  end
end