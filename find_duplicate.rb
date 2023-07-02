require_relative 'main'
require_relative 'config'

class FindDuplicate
  @path_equal_files = []
  @name_equal_files = []
  @name_hash_equal_file = []

  @source_dir_name_length = Config.source_directory.size

  def self.find_files(file_path)
    pp file_path
    if File.file? file_path
      file_hash = Main.file_hash file_path
      results = Main.mysql_client.query "SELECT path FROM #{Config.db_table_name} WHERE hash = '#{file_hash}'"
      file_exist = false
      results.each do |row|
        file_exist = true if row['path'] == file_path.slice(@source_dir_name_length..-1)
      end

      if file_exist
        @path_equal_files << file_path.slice(@source_dir_name_length..-1)
      else
        results = Main.mysql_client.query "SELECT hash, filename FROM #{Config.db_table_name} WHERE filename = '#{File.basename(file_path)}'"
        file_hash_filename_exist = false
        results.each do |row|
          file_hash_filename_exist = true if row['hash'] == file_hash
        end

        if file_hash_filename_exist
          @name_hash_equal_file << File.basename(file_path)
        else
          result_row_count = 0
          results.each do |_|
            result_row_count += 1
          end

          @name_equal_files << File.basename(file_path) if result_row_count >= 1
        end

        Main.mysql_client.query "INSERT INTO #{Config.db_table_name} (hash, path, filename) VALUES ('#{file_hash}', '#{file_path.slice(@source_dir_name_length..-1)}', '#{File.basename(file_path)}')"
      end
    end
  end

  def self.sub_directory(dir)
    directory = Dir["#{dir}*/"]

    directory.each do |sub_dir|
      pp sub_dir
      self.sub_directory sub_dir
    end

    files = Dir["#{dir}*"]
    files.each do |file_path|
      self.find_files file_path
    end
  end

  directory = Dir["#{Config.source_directory}*/"]
  directory.each do |dir|
    sub_directory dir
  end

  files = Dir["#{Config.source_directory}*"]
  files.each do |file_path|
    self.find_files file_path
  end

  puts "path equal files"
  @path_equal_files.each do |file_path|
    puts file_path
  end

  puts ""
  puts "name equal files"
  @name_equal_files.each do |filename|
    puts filename
  end

  puts ""
  puts "name and hash equal files"
  @name_hash_equal_file.each do |filename|
    puts filename
  end
end
