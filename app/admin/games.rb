ActiveAdmin.register Game do
  index do
    column :id
    column "Winner" do |game|
      User.unscoped {
        game.winnerName if game.fst_user > 0
      }
    end

    column "Loser" do |game|
      User.unscoped {
        game.loserName if game.scd_user > 0
    }
    end

    column "No Moves", :moves  do |game|
      game.moves.count
    end
    
    column do |game|
      if game.finished
        span :class => "label label-success" do
          "Finished"
        end
      end
      if game.countable
        span :class => "label label-info" do
          "Countable"
        end
      end
    end
    default_actions
  end


  show do |game|
    User.unscoped {
      if game.num_players == 2
        render :partial => "show", :locals => {:game => game}
      else
        h2 "Jocul inca nu a inceput"
      end
    }
  end

end
