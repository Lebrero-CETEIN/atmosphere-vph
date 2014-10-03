# This migration comes from atmosphere (originally 20130820144329)
class CreateApplianceTypes < ActiveRecord::Migration
  def change
    create_table :appliance_types do |t|

      t.string :name,                   null: false
      t.text :description
      t.boolean :shared,                null: false, default: false
      t.boolean :scalable,              null: false, default: false
      t.string :visible_to,             null: false, default: 'owner'

      # Incorporated from the old AppliancePreferences model
      t.float :preference_cpu
      t.integer :preference_memory
      t.integer :preference_disk

      t.references :security_proxy,     null: true
      t.references :user,               null: true

      t.timestamps
    end

    add_index :appliance_types, :name, unique: true
    add_foreign_key :appliance_types, :users
    add_foreign_key :appliance_types, :security_proxies
  end
end
