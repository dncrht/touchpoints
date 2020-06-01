class CreateTouchpoints < ActiveRecord::Migration[6.0]
  def change
    create_table :touchpoints do |t|
      t.integer :user_id
      t.json :utm_params
      t.string :referer
      t.timestamp :created_at
    end
  end
end
