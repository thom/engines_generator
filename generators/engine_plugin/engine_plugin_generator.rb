require 'rails_generator'
require 'rails_generator/commands'

class EnginePluginGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      m.directory "vendor/plugins/#{file_name}"

      m.directory "vendor/plugins/#{file_name}/app"
      m.directory "vendor/plugins/#{file_name}/app/controllers"
      m.directory "vendor/plugins/#{file_name}/app/helpers"
      m.directory "vendor/plugins/#{file_name}/app/models"
      m.directory "vendor/plugins/#{file_name}/app/views"

      m.template "routes.rb", "vendor/plugins/#{file_name}/routes.rb"
      #m.map_route_from_plugin

      m.directory "vendor/plugins/#{file_name}/db"
      m.directory "vendor/plugins/#{file_name}/db/migrate"
      m.directory "vendor/plugins/#{file_name}/db/fixtures"

      m.directory "vendor/plugins/#{file_name}/lib"

      m.directory "vendor/plugins/#{file_name}/spec"
      m.directory "vendor/plugins/#{file_name}/spec/controllers"
      m.directory "vendor/plugins/#{file_name}/spec/fixtures"
      m.directory "vendor/plugins/#{file_name}/spec/models"
      m.directory "vendor/plugins/#{file_name}/spec/views"
      m.file "spec_helper.rb", "vendor/plugins/#{file_name}/spec/spec_helper.rb"

      m.directory "vendor/plugins/#{file_name}/tasks"

      m.file "empty_file", "vendor/plugins/#{file_name}/init.rb"
    end
  end
end
