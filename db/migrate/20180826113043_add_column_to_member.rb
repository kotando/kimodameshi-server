class AddColumnToMember < ActiveRecord::Migration[5.1]
  def change
    add_column :members, :status, :string
  end
end
