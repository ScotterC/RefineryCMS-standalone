class AddValueTypeToRefinerySettings < ActiveRecord::Migration
  def self.up
    add_column :refinery_settings, :form_value_type, :string

    RefinerySetting.reset_column_information
  end

  def self.down
    remove_column :refinery_settings, :form_value_type

    RefinerySetting.reset_column_information
  end
end
