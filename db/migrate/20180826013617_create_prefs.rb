class CreatePrefs < ActiveRecord::Migration[5.1]
  def change
    create_table :prefs do |t|
      t.string :member_uuid
      t.string :pref_uuid
      t.integer :rank

      t.timestamps
    end
  end
end
