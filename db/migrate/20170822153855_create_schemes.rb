class CreateSchemes < ActiveRecord::Migration
  def change
    create_table :schemes do |t|
      t.datetime :starting_at
      t.datetime :ending_at
      t.string :state, default: "inactive"

      t.timestamps null: false
    end
    add_index :schemes, :state
  end
end
