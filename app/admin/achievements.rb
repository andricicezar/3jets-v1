ActiveAdmin.register Achievement do
  index do
    column :id
    column :name
    column :key_watched
    column :min_value
    default_actions
  end

  form do |f|
    f.inputs "Edit" do
      f.input :name
      f.input :icon
      f.input :key_watched, :as => :select, :collection => 
                    ["combo_wins", 
                     "combo_losses",
                     "alltime_wins",
                     "alltime_losses",
                     "combo_heads",
                     "combo_hits",
                     "combo_heads_hits",
                     "combo_miss",
                     "combo_heads_taken",
                     "alltime_miss",
                     "alltime_hits",
                     "alltime_heads_hits",
                     "alltime_heads"
                    ]
      f.input :min_value
      f.input :award_icon
    end
    f.actions
  end
end
