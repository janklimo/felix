class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.references :user, index: true, foreign_key: true
      t.references :feedback_request, index: true, foreign_key: true
      t.integer :value, default: 0, null: false
      t.text :text
      t.integer :tag, default: 0, null: false

      t.timestamps null: false
    end
  end
end
