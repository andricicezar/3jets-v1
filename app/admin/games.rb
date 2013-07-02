ActiveAdmin.register Game do
  index do
    column :id
    column "First User" do |game|
      User.unscoped {
        if game.user1
          if !game.finished
            game.user1.name
          else
            if game.winner.id == game.fst_user
              div :class => "winner" do
                game.user1.name
              end
            else
              div :class => "looser" do
                game.user1.name
              end
            end
          end
        else
          "John Doe"
        end
      }
    end

    column "Second User" do |game|
      User.unscoped {
        if game.user2
          if !game.finished
            game.user2.name
          else
            if game.winner.id == game.scd_user
              div :class => "winner" do
                game.user2.name
              end
            else
              div :class => "looser" do
                game.user2.name
              end
            end
          end
        else
          "John Doe"
        end
      }
    end

    column "No Moves", :moves  do |game|
      game.moves.count
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
