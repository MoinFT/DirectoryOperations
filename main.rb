require 'mysql2'
require 'digest'
require 'fileutils'

require_relative 'credentials'

class Main
  def self.mysql_client
    Mysql2::Client.new(host: Credentials.db_host, username: Credentials.db_username, password: Credentials.db_password, database: Credentials.database)
  end

  def self.file_hash(file_path)
    digest = Digest::SHA256.new
    file_stat = File.stat file_path
    digest.update file_stat.dev.to_s
    digest.update file_stat.ino.to_s
    digest.update file_stat.mode.to_s
    digest.update file_stat.uid.to_s
    digest.update file_stat.gid.to_s
    digest.update file_stat.size.to_s

    File.open file_path, 'rb' do |file|
      while (chunk = file.read(1024))
        digest.update(chunk)
      end
    end

    digest.hexdigest
  end
end
