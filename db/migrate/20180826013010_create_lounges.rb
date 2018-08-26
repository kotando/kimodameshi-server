class CreateLounges < ActiveRecord::Migration[5.1]
  def change
    create_table :lounges do |t|
      t.string :lounge_uuid
      t.string :lounge_name
      t.string :first_group
      t.string :second_group
      t.string :owner_id
      t.boolean :allow_alone
      t.string :status

      t.timestamps
    end
  end
end
