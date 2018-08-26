class CreateMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :members do |t|
      t.string :member_id ,primary_key :true
      t.string :member_name
      t.references :lounge, index: true, foreign_key: true, null: false
      t.string :group
      t.blob :thumnail

      t.timestamps
    end
  end
end
