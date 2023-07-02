require 'mysql2'
require 'digest'
require 'fileutils'

require_relative 'main'
require_relative 'config'

class CopyDir
  @not_copied_files = []

  @source_dir_name_length = Config.source_directory.size

  def self.copy_file(file_path)
    pp file_path
    if File.file? file_path
      file_hash = Main.file_hash file_path
      results = Main.mysql_client.query "SELECT path FROM #{Config.db_table_name} WHERE hash = '#{file_hash}'"
      file_exist = false
      results.each do |row|
        file_exist = true if row['path'] == file_path.slice(@source_dir_name_length..-1)
      end

      unless file_exist
        file_dirname = File.dirname(file_path.slice((@source_dir_name_length + 1)..-1))
        if File.exist? "#{Config.target_directory}/#{file_dirname}/#{File.basename(file_path)}"
          @not_copied_files << file_path.slice(@source_dir_name_length..-1)
        else
          Main.mysql_client.query "INSERT INTO #{Config.db_table_name} (hash, path) VALUES ('#{file_hash}', '#{file_path.slice(@source_dir_name_length..-1)}')"
          FileUtils.mkdir_p "#{Config.target_directory}/#{file_dirname}" unless Dir.exist? "#{Config.target_directory}/#{file_dirname}"
          FileUtils.cp file_path, "#{Config.target_directory}/#{file_dirname}/#{File.basename(file_path)}"
        end
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
      self.copy_file file_path
    end
  end

  directory = Dir["#{Config.source_directory}*/"]
  directory.each do |dir|
    sub_directory dir
  end

  files = Dir["#{Config.source_directory}*"]
  files.each do |file_path|
    self.copy_file file_path
  end

  puts "not copied files"
  @not_copied_files.each do |filename|
    puts filename
  end
end
