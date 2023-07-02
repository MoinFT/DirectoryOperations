require_relative 'main'
require_relative 'config'

class IndexTargetDir
  @source_dir_name_length = Config.source_directory.size

  def self.index_files(file_path)
    pp file_path
    if File.file? file_path
      file_hash = Main.file_hash file_path
      Main.mysql_client.query "INSERT INTO #{Config.db_table_name} (hash, path) VALUES ('#{file_hash}', '#{file_path.slice(@source_dir_name_length..-1)}')"
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
      self.index_files file_path
    end
  end

  directory = Dir["#{Config.source_directory}*/"]
  directory.each do |dir|
    sub_directory dir
  end

  files = Dir["#{Config.source_directory}*"]
  files.each do |file_path|
    self.index_files file_path
  end
end
