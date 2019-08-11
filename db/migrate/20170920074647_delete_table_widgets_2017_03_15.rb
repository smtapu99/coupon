class DeleteTableWidgets20170315 < ActiveRecord::Migration[5.0]
  def up
    execute("DROP TABLE IF EXISTS widgets_2017_03_15")
  end

  def down
    # no rollback migration intended
  end
end
