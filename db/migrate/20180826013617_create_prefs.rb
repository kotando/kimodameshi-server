class CreatePrefs < ActiveRecord::Migration[5.1]
  def change
    create_table :prefs do |t|
      t.string :member_id
      t.string :pref_id
      t.integer :rank

      t.timestamps
    end
  end
end
