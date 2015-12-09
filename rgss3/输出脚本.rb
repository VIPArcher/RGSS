
#--------------------------------------------------------------------------
# ● 输出脚本
#--------------------------------------------------------------------------

path = 'rgss3'
ext  = '.rb'

output = lambda do

  if File.directory?(path)
    Dir.glob("#{path}/*#{ext}", &File.method(:delete))
  else
    Dir.mkdir(path)
  end

  $RGSS_SCRIPTS.each_with_index do |(_, tag, _, contents), i|
    next unless tag.start_with?('★')..tag.start_with?('☆')
    next unless contents.force_encoding('utf-8')[/\S/]
    filename = tag.delete('- /:*?"<>|\\')
    if filename.empty?
      msgbox "Warning: script #{i} with an invalid tag"
    else
      File.open("#{path}/#{filename}#{ext}", 'wb') do |f|
        f.write contents.delete("\r")
      end
    end
  end
  msgbox 'Scripts output successfully.'
  exit
end

output.call if $TEST && !$BTEST