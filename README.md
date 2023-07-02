# Directory operations

## Doing before start

If you don't have yet a MySQL database running do this before. Because you need this DB for every script.

### Requirements

- Ruby Version: 3.1.2
- Gems:
  - mysql2
- MySQL Server

### Needed files

1. You need to create a `config.rb` and enter the source and target directory as well as the name of the database table

    Note: The `source_directoy` and `target_directory` must not have `/` at the end.

    ```ruby
    class Config
      def self.source_directory
        "/mnt/c"
      end
    
      def self.target_directory
        "/mnt/d"
      end
    
      def self.db_table_name
        "database_table_name"
      end
    end
    ```

2. You need to create a `credentials.rb` and enter the credentials for your database

    ```ruby
    class Credentials
      def self.db_host
        "your_database_host_ip_address"
      end
    
      def self.db_username
        "username"
      end
    
      def self.db_password
        "password"
      end
    
      def self.database
        "database_name"
      end
    end
    ```

## Now you can start

### What can you with the scripts

Directory operations has two possible use cases.

#### Find duplicate files

With the script `find_duplicate.rb` you can find duplicate files in a specific directory.

1. To configure the directory you have to go in the `config.rb` file and set the `source_directory`.
2. Execute the script with `ruby find_duplicate.rb`
3. When the script is finished you have three different outputs:
   - The first is `path equal files`: This contains all files that have the same path and hash.
   - The second is `name equal files`: This contains all files that have the same name.
   - the third is `name and hash equal files`: This contains all files that have the same name and hash. (This are exactly same files)
4. To prepare the database for the next run execute the script `ruby clear_database.rb`. (If you want to find duplicated files between two directories you have to skip these step)

#### Copy directory

With the script `copy_dir.rb` you can copy on directory to another without overwrite duplicate files.

1. To configure the directory you have to go in the `config.rb` file and set the `source_directory` and `target_directory`.
2. If your target directory is not empty you have to index it. (If you copy a second directory to the same target and didn't have cleared the database you don't need this script)
   - Execute the script `ruby index_target_dir.rb`
3. Execute the script `ruby copy_dir.rb`
4. When the script is finished you have one output:
   - The output is `not copied files`: This contains all files that couldn't be copied because the file name exists already under this path.
5. To prepare the database for the next run execute the script `ruby clear_database.rb`. (If you want to copy a second directory to the same target you have to skip these step)
