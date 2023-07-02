require_relative 'main'

class ClearDatabase
  results = Main.mysql_client.query "SELECT id FROM #{Config.db_table_name}"
  results.each do |row|
    Main.mysql_client.query "DELETE FROM #{Config.db_table_name} WHERE id = '#{row['id']}'"
  end
end
