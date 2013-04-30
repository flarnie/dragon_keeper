require './dragon_data/d_k_classes'
require 'fileutils'
#create dragon-raising menu
dragon_menu = DKClasses::DK_Menu.new("Raising your Dragon", [], Proc.new { |player| dragon_menu.display(player)})
dragon_menu.add_option("Description of Dragon", (dragon_menu.length+1), Proc.new{ |player| 
        player.take_turn( lambda { |player| player.dragon.description })
        })
dragon_menu.add_option("Observe Dragon", (dragon_menu.length+1), Proc.new{ |player| 
        player.take_turn( lambda { |player| player.dragon.status })
        })
dragon_menu.add_option("Feed Dragon", (dragon_menu.length+1), Proc.new{ |player| 
        player.take_turn( lambda { |player| player.dragon.feed })
        })
dragon_menu.add_option("Scale Collection", (dragon_menu.length+1), Proc.new{ |player| 
        player.take_turn( lambda { |player| player.see_scales })
        })
dragon_menu.add_option("Quit", (dragon_menu.length+1), Proc.new{ |player| 
        player.save_game
        puts "Goodbye!"
        throw(:quit)})

#find all save files in the directory
players = Dir['dragon_data/*_save_file.yml']

#get the default (most recent? alphabetical?) player
if !(players.empty?)
  def get_player_name(filename)
    player = /dragon_data\/([a-zA-Z\s]*)_save_file.yml/.match(filename).captures[0]
  end
  default = get_player_name(players[0].to_s)
else
  default = nil
end

#if multiple files, make menu to choose
if players.length > 1
  player_menu = DKClasses::DK_Menu.new("Player Files", [], Proc.new { |a| player_menu.display(a)})
  players.each do |player_file|
        #load player data from yaml file
        yaml_string = File.read(player_file)
        data = YAML::load yaml_string
        p_name = data[0]["name"]
        puts "Loading file for #{p_name}..."
        p_element = data[0]["element"]
        p_scales = data[0]["scales"]
        p_dragon = data[0]["dragon"]
        this_player = DKClasses::Player.new(p_name, p_element, p_scales, p_dragon, false)
    player_menu.add_option("Play as #{p_name}", player_menu.length+1, Proc.new { |player| 
      dragon_menu.display(this_player)
      })
  end
end

#create main menu
main_menu = DKClasses::DK_Menu.new("Main Menu", [], Proc.new { |player| main_menu.display(player)})
if default != nil
  main_menu.add_option("Play as '#{default}'", 1, Proc.new{ |a| 
        puts "Loading file for #{default}..."
        #load player data from yaml file
        yaml_string = File.read(players[0])
        data = YAML::load yaml_string
        p_name = data[0]["name"]
        p_element = data[0]["element"]
        p_scales = data[0]["scales"]
        p_dragon = data[0]["dragon"]
        player = DKClasses::Player.new(p_name, p_element, p_scales, p_dragon, false)
        dragon_menu.display(player)
        })
end
main_menu.add_option("New Player", (main_menu.length+1), Proc.new { |a|
        newbie = DKClasses::Player.new()
        newbie.start_game #creates player data
        dragon_menu.display(newbie) #uses player data to start game
        })
if players.length > 1
  main_menu.add_option("Switch Player File", (main_menu.length+1), Proc.new { |a|
        player_menu.display("Lucky")})
end
main_menu.add_option("ASCII Art Credits", (main_menu.length+1), Proc.new { |a|
        puts '/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\
#\/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/
#
#     All ASCII Art was found on Chris.com
#     An amazing site that has been online
#     since 1994!
#     (You should check out his gallery
#     of ASCII artwork and donate to him!)
#     Credit for individual ASCII artworks:
#     >Pattern above and below this section
#     is from "Krogg"
#     >"Baby" dragon is from "orca"
#     >"Full Grown" dragon is from "dk (c) 1993"
#     >Dragon style menu border is from 
#     "Jeff Ferris" and is similar to patterns by 
#     "Brian Young" and "Alan Greep".
#     >Other art sources unknown.
#
#     Thanks to Chris of Chris.com for saving it all!
#
#     (press any key to continue)
#
#/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\
#\/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/'
any_key = gets.chomp

        })
main_menu.add_option("Quit", (main_menu.length+1), Proc.new{ |a| 
        puts "Goodbye!"
        throw(:quit)})


catch(:quit) do
main_menu.display("Lucky")
end