class RemoveSessionsSlidersAndSlides < ActiveRecord::Migration[5.2]
  def change
    drop_table :sessions
    drop_table :sliders
    drop_table :slides
  end
end
