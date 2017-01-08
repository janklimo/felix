class CreateFeedbackRequests < ActiveRecord::Migration
  def change
    create_table :feedback_requests do |t|
      t.references :company, index: true, foreign_key: true
      t.references :question, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
