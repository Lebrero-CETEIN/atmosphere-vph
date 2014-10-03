# This migration comes from atmosphere (originally 20130826162855)
class CreateEndpoints < ActiveRecord::Migration
  def change
    create_table :endpoints do |t|
      t.string :name,                         null: false
      t.text :description
      # The below should force MySQL to use MEDIUMTEXT or LONGTEXT
      t.text :descriptor,                     limit: 16777215
      t.string :endpoint_type,                null: false, default: 'ws'
      t.string :invocation_path,              null: false

      t.references :port_mapping_template,    null: false

      t.timestamps
    end

    add_foreign_key :endpoints, :port_mapping_templates

  end
end
