ActiveAdmin.register Game do
  index do
    column :id
    column "First User" do |game|
      User.unscoped {
        if User.where(:id => game.fst_user).count == 1
          fst_user = User.find(game.fst_user).email_splited

          if game.winner == 0
            fst_user
          else
            if game.winner == game.fst_user
              div :class => "winner" do
                fst_user
              end
            else
              div :class => "looser" do
                fst_user
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
        if User.where(:id => game.scd_user).count == 1
          scd_user = User.find(game.scd_user).email_splited

          if game.winner == 0
            scd_user
          else
            if game.winner == game.scd_user
              div :class => "winner" do
                scd_user
              end
            else
              div :class => "looser" do
                scd_user
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
      if User.where(:id => game.fst_user).count + User.where(:id => game.scd_user).count == 2
        render :partial => "show", :locals => {:game => game}
      else
        h2 "Unul din conturi a fost sters"
      end
    }
  end

end
