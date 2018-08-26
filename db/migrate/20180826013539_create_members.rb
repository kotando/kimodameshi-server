class CreateMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :members do |t|
      t.string :member_uuid
      t.string :member_name
      t.references :lounge, index: true, foreign_key: true, null: false
      t.string :group
      t.blob :thumnail
      t.boolean :is_owner

      t.timestamps
    end
  end
end
