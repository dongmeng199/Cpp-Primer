# @Yue Wang  Aug 2015
#
# Remove lines that cantain some word from all files with in the given directory recursively.
# To use:
#   $ ruby remover.rb dirname file_extension key_word
# insensitive casing by default.
#

class Remover
  attr_reader :matched, :unmatched
  
  def initialize
    @matched = {}
    @unmatched = {}
  end

  def perform_on filename
    @filename = filename
    
    File.readlines(@filename).each_with_index do |line, i| 
      if yield line, i
        @matched[ i + 1 ] = line
      else
        @unmatched[ i + 1 ] = line
      end
    end 
    
    File.open(@filename, 'w+'){ |file| file.puts @unmatched.values }
  end

end

if ARGV.size != 3
  puts "wrong agruments"
  exit
end

dir = ARGV[0]
extension = ARGV[1]
expr = ARGV[2]
 
allFilePaths = Dir.glob "#{ dir }/**/*.#{ extension }"

allFilePaths.each do |path|
 
  pattern = Regexp.new(Regexp.escape(expr), Regexp::IGNORECASE)
  rm = Remover.new
  rm.perform_on( path ) do |line, i| 
    begin
      line.match(pattern)
    rescue
      puts "\n---------------exception happens when reading the line:"
      puts line
      puts "file: [#{ path }] line:[#{ i }]"
      puts "---------------just igonored\n" 
      result = false
    end
  end
  
  if !rm.matched.empty? 
    puts "lines deleted in file [#{ path }] :" 
  else
    puts "no matched found in file [#{ path }]."  
  end
  
  rm.matched.each do |idx, line|
    puts "[#{ idx  }] #{ line }"
  end

end
