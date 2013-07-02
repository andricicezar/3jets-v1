ActiveAdmin.register Achievement do
  index do
    column :id
    column :name
    column :key_watched
    column :min_value
    default_actions
  end
end
