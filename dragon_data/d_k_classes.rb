#Classes related to the Dragon Keeper Game
module DKClasses
require './dragon_data/TextOnlyUX'
require 'yaml'
  #The player methods and data.
  class Player
    attr_reader :name, :element, :scales, :dragon
    #The Player object stores player's name, their chosen 'element', 'scale' inventory, the active dragon object, and config. option.
    def initialize(name = '', element = '', scales = [], dragon = nil, non_load=true)
      @name = name.length> 0 ? name : get_name()
      @element = element.length> 0 ? element : get_element()
      @scales = scales
      @dragon = dragon != nil ? Dragon.new(dragon.name, dragon.element, dragon.asleep, dragon.stuff_in_belly, dragon.level, dragon.points, non_load) : ''
      save_game if non_load
    end
    #Augments dragon stats in a standard way and calls a method chosen from the 'dragon menu', adding a 'scale' to inventory if one is returned.
    def take_turn(lambda)
      @dragon.hunger_up
      lambda.call(self)
      scale = @dragon.point_up
      if scale == "scale"
        @scales << {"element"=>@dragon.element, "name"=>@dragon.name}
        puts "You have collected a scale!"
        #have new baby dragon
        restart_dragon
      end
      save_game
    end
    #Saves the new player data, overwriting old save file.  Uses YAML.
    def save_game()
      object = [{"name"=>@name, "element"=>@element, "scales"=>@scales, "dragon"=>@dragon}]
      main_directory = Dir.getwd
      Dir.chdir("dragon_data")
      File.open(@name+'_save_file.yml', 'w') do |f|
        YAML::dump(object, f)
      end
      Dir.chdir(main_directory)
      puts "(Your game has been saved.)"
    end
    #A little validator for alphabetical char.s and spaces.
    def alpha_check(string)
      /[^a-zA-Z\s]/.match(string)
    end
    #Asks for a player's name.
    def get_name
      puts "What be ye name?"
      name = gets.chomp
      if alpha_check(name)
        puts "We only use the alphabet in this magical land."
        name = get_name
        #recursion yee ha
      end
      #add a check for uniqueness
      name
    end
    #Asks for the player's 'element'.
    def get_element
      puts "What's your favorite element?"
      elem = gets.chomp.downcase
      if alpha_check(elem)
        puts "We only use the alphabet in this magical land."
        elem = get_element
      end
      elem
    end
    #Prints a list of 'scale' inventory.
    def see_scales
      if @scales.length > 0
        puts "You examine your scale collection:"
        @scales.each do |scale|
          puts "A #{scale['element']} tinted scale left by #{scale['name']}"
        end
        puts "(press any key to continue)"
        any_key = gets.chomp
      else
        puts "You have not collected any scales yet."
        puts "(press any key to continue)"
        any_key = gets.chomp
      end
    end
    #Prints a character description.
    def to_s
      "You are #{@name} who favors #{@element}."
    end
    #Runs through the text and options of a new game, and creates active Dragon object.
    def start_game
      5.times { puts "." }
      puts "You have traveled far and wide, searching for #{@element} and wonder."
      puts "Taking shelter in a small cave, you have found a large smooth stone."
      puts "Strange... as you examine it you seem to feel movement from within..."
      puts "(Press any key to continue...)"
      any_key = gets.chomp
      if any_key
        puts "You fall asleep, using the strange stone as a pillow."
        5.times do 
          puts "."
          sleep(1.0)
        end
        puts "The stone burst in a cloud of #{@element}-tinted smoke!"
        puts "A baby dragon has hatched."
        puts '                _/(               <~\  /~>               )\_
              .~   ~-.            /^-~~-^\            .-~   ~.
           .-~        ~-._       : /~\/~\ :       _.-~        ~-.
        .-~               ~~--.__: \0/\0/ ;__,--~~               ~-.
       /                        ./\. ^^ ./\.                        \
      .                         |  ( )( )  |                         .
      -~~--.        _.---._    /~   U`\'U   ~\    _.---._        .--~~-
            ~-. .--~       ~~-|              |-~~       ~--. .-~
               ~              |  :        :  |_             ~
                              `\,\'  :  :  `./\' ~~--._
                             .(<___.\'  `,___>),--.___~~-.
                             ~ (((( ~--~ ))))      _.~  _)
                                ~~~      ~~~/.--~ _.--~'
        puts "(Press any key to continue...)"
        again_key = gets.chomp
        if again_key
          puts "Congratulations!  What will you name the dragon?"
          dragon_name = gets.chomp
          dragee = Dragon.new(dragon_name, @element)
          @dragon = dragee
          save_game
        end
      end
    end
    #Runs through 'end game' text, generates new active Dragon object.
    def restart_dragon
      5.times { puts "."}
      puts "#{@dragon.name} has left you a dragon egg.  It is hatching!"
      puts "(press any key to continue)"
      any_key = gets.chomp
      rand_element = @dragon.rand_element
      puts "The stone burst in a cloud of #{rand_element}-tinted smoke!"
        puts "A baby dragon has hatched."
        puts '                _/(               <~\  /~>               )\_
              .~   ~-.            /^-~~-^\            .-~   ~.
           .-~        ~-._       : /~\/~\ :       _.-~        ~-.
        .-~               ~~--.__: \0/\0/ ;__,--~~               ~-.
       /                        ./\. ^^ ./\.                        \
      .                         |  ( )( )  |                         .
      -~~--.        _.---._    /~   U`\'U   ~\    _.---._        .--~~-
            ~-. .--~       ~~-|              |-~~       ~--. .-~
               ~              |  :        :  |_             ~
                              `\,\'  :  :  `./\' ~~--._
                             .(<___.\'  `,___>),--.___~~-.
                             ~ (((( ~--~ ))))      _.~  _)
                                ~~~      ~~~/.--~ _.--~'
        puts "(Press any key to continue...)"
        again_key = gets.chomp
        puts "Congratulations!  What will you name the dragon?"
        renew_name = gets.chomp
        renew_dragon = Dragon.new(renew_name, rand_element)
        @dragon = renew_dragon
        save_game
      end

  end
  #Stores data and methods for interacting with the Dragon.
  class Dragon
    attr_reader :name, :element, :asleep, :stuff_in_belly, :level, :points
    #The Dragon class stores all data about the player's Dragon and about their game state, as well as ASCII art and text options for game.
    def initialize(name, element, asleep = false, stuff_in_belly = 8, level = 0, points = 0, non_load = true)
      @name = name.capitalize
      @element = element
      @asleep = asleep
      @stuff_in_belly = stuff_in_belly
      @level = level
      @points = 0
      @dragon_ascii = ['                _/(               <~\  /~>               )\_
              .~   ~-.            /^-~~-^\            .-~   ~.
           .-~        ~-._       : /~\/~\ :       _.-~        ~-.
        .-~               ~~--.__: \0/\0/ ;__,--~~               ~-.
       /                        ./\. ^^ ./\.                        \
      .                         |  ( )( )  |                         .
      -~~--.        _.---._    /~   U`\'U   ~\    _.---._        .--~~-
            ~-. .--~       ~~-|              |-~~       ~--. .-~
               ~              |  :        :  |_             ~
                              `\,\'  :  :  `./\' ~~--._
                             .(<___.\'  `,___>),--.___~~-.
                             ~ (((( ~--~ ))))      _.~  _)
                                ~~~      ~~~/.--~ _.--~',
                                '                         ^\    ^                  
                        / \\  / \                 
                       /.  \\/   \      |\___/|   
    *----*           / / |  \\    \  __/  O  O\   
    |   /          /  /  |   \\    \_\/  \     \     
   / /\/         /   /   |    \\   _\/    \'@___@      
  /  /         /    /    |     \\ _\/       |U
  |  |       /     /     |      \\\/        |
  \  |     /_     /      |       \\  )   \ _|_
  \   \       ~-./_ _    |    .- ; (  \_ _ _,\\\'
  ~    ~.           .-~-.|.-*      _        {-,
   \      ~-. _ .-~                 \      /\'
    \                   }            {   .*
     ~.                 \'-/        /.-~----.
       ~- _             /        >..----.\\\\\
           ~ - - - - ^}_ _ _ _ _ _ _.-\\\\\\',
                                '         ^                       ^
         |\   \        /        /|
        /  \  |\__  __/|       /  \
       / /\ \ \ _ \/ _ /      /    \
      / / /\ \ {*}\/{*}      /  / \ \
      | | | \ \( (00) )     /  // |\ \
      | | | |\ \(V""V)\    /  / | || \| 
      | | | | \ |^--^| \  /  / || || || 
     / / /  | |( WWWW__ \/  /| || || ||
    | | | | | |  \______\  / / || || || 
    | | | / | | )|______\ ) | / | || ||
    / / /  / /  /______/   /| \ \ || ||
   / / /  / /  /\_____/  |/ /__\ \ \ \ \
   | | | / /  /\______/    \   \__| \ \ \
   | | | | | |\______ __    \_    \__|_| \
   | | ,___ /\______ _  _     \_       \  |
   | |/    /\_____  /    \      \__     \ |    /\
   |/ |   |\______ |      |        \___  \ |__/  \
   v  |   |\______ |      |            \___/     |
      |   |\______ |      |                    __/
       \   \________\_    _\               ____/
     __/   /\_____ __/   /   )\_,      _____/
    /  ___/  \uuuu/  ___/___)    \______/
    VVV  V        VVV  V ',
    '

                                                    .%,
                                                   X:-x\\\',
                                                  X:/%;::\:X
                                                 X:l%  ; :\'\:X
                                                X:l%   :  : \'\:X
                                                X:l%   :   :  \'\:X
                             b,      b,        X:/l%   :    :   \:X
                            JPQ,    JPQ,       X:l%    :     :   \'\:X
                          .dP\'d|._,=dPQq\     X:l%\'    :      :    \'\:X
                         xdP  #P"\'_    _,:   .X:l%     :       :    \'\:X
                      .d/"p   \'  \'O \  \'O:;  X:l%\'     :       :      \:X
                    ,pP\' q.          \:  `#  X:ld       :       :      \':X
                  ,d"   ,pq  .,-qx_,  "\  `Q:  l%       :       :       k:X
                ./\'     Jp       .      `  ` 3  %       :        ;      k:X
               dP       p            p    `  `q         :        :      k:X
              d/       ; J,/";xpx"\: \'*q    ` `\,       :         :     l:X.
             dP      ;\'    dP      "\:_,`.q. /d b\      :         :      k:X
           .d\'      ;    dP            .\_j \'- u-\'      :         :      k:X
X         ./\'     ;\'    /"            .\'                :         ;      k:X
\X       .d\'     ;    ,"             :      X:l%        :        :       k:X
:\X      d\'     ;   ./\'             :       X:/%        :        ;       k:X
::lX    JP     ;    J              :      .X:/ %        :       :        k;X
k:lX    #\'    :    j\'             :    .X:/ %           :       :       d:lX
k:lX   |P    ;     |             :  .X:/ %              :       ;       k;lX
k:lX   ||    ;    |\'            : X:/ %                 ;       :      d:;X\'
k:lX   d|   ;     :l           :X:/ %\'                 :        :      k:lX
k:iX   #|   ;     ||          X:/ %                    ;        ;      k:lX
 k:\X  ||  ;       ||       X:/ %                     :        :       k:lX
  k:\pQJb  ;        \N.PQ XX/ %                      ;         ;       k:lX
   kJP.Ql\;          XQ. J Q J                      :         ;        k:lX
   6Q : Q%           \Q  Q   J              ;\'\'\'\'\':.:;\'\'::.  :         k:lX
  6QQ  : Ql           lQ\'   J              ;        ;     \': :;\'\'\':.   k::X.
 6QQQ )  Ql           i6    Q             ;                 .;     \':.  k:\X
  6QQ   J l           \  6  Q            ;                            \':.k:X
 9QQ   J  i            l 6   6          ;                                 k;',
'@@@@@@@@@@@@@@@@@@@@@**^^""~~~"^@@^*@*@@**@@@@@@@@@
@@@@@@@@@@@@@*^^\'"~   , - ' '; ,@@b. \'  -e@@@@@@@@@
@@@@@@@@*^"~      . \'     . \' ,@@@@(  e@*@@@@@@@@@@
@@@@@^~         .       .   \' @@@@@@, ~^@@@@@@@@@@@
@@@~ ,e**@@*e,  ,e**e, .    \' \'@@@@@@e,  "*@@@@@\'^@
@\',e@@@@@@@@@@ e@@@@@@       \' \'*@@@@@@    @@@\'   0
@@@@@@@@@@@@@@@@@@@@@\',e,     ;  ~^*^\'    ;^~   \' 0
@@@@@@@@@@@@@@@^""^@@e@@@   .\'           ,\'   .\'  @
@@@@@@@@@@@@@@\'    \'@@@@@ \'         ,  ,e\'  .    ;@
@@@@@@@@@@@@@\' ,&&,  ^@*\'     ,  .  i^"@e, ,e@e  @@
@@@@@@@@@@@@\' ,@@@@,          ;  ,& !,,@@@e@@@@ e@@
@@@@@,~*@@*\' ,@@@@@@e,   \',   e^~^@,   ~\'@@@@@@,@@@
@@@@@@, ~" ,e@@@@@@@@@*e*@*  ,@e  @@""@e,,@@@@@@@@@
@@@@@@@@ee@@@@@@@@@@@@@@@" ,e@\' ,e@\' e@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@" ,@" ,e@@e,,@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@~ ,@@@,,0@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@,,@@@@@@@@@@@@@@@@@@@@@@@@@
"""""""""""""""""""""""""""""""""""""""""""""""""""']
    @encounters = ["A tricksy invisible hobbit is trying to steal your gems!", 
      "A knight is here, claiming #{@name} has eaten the princess.", 
      "#{@name} has become sad, because a small child stopped believing in them.", 
      "A hoard of goblins are trying to imprison #{@name}!",
    "A rival dragon has appeared and wants to claim the cave.",
    "Bright light blinds you- it is a phoenix!", "A terrifying elephant encroaches!", 
    "It's a Rodent Of Unusual Size!", "A fairy has appeared, offering to grant one wish."]
    @levels = [{"level"=>"baby", "desc"=>"A winged, scaly reptile the size of a cat."},
      {"level"=>"young", "desc"=>"A cow-sized lizard with bat-like wings and sharp teeth."},
      {"level"=>"large", "desc"=>"A sprawling mess of scales, claws, and teeth with wings."},
      {"level"=>"full-grown", "desc"=>"A majestic, sophisticated monster with intelligent eyes, 
dagger-like claws, shining scales, and wings that can blot out the sun."}]
    @alt_elements = ["water", "fire", "wind", "amethyst", "iron", "gold", "emerald", 
      "ruby", "grilled-cheese", "meatloaf", "silver", "cake", "rubix-cube", "glitter", 
      "crystal", "smoke", "data"]
    @happy_greetings = ["pounces on you and licks your face.", "blinks at you in a thoughtful way.",
        "is happily crushing boulders in the back of the cave.", "nibbles playfully on your elbow.", 
        "is putting the moves on a wandering iguana.", "tries to talk to you- it's breath smells like rotten eggs!", 
        "is practicing flying.", "nuzzles you as you observe it.", "has brought you a dead mouse."]
    @yuck_greetings = ["hacks up some brimstone.", "is panting unhappily.", "growls at you.", 
          "smells worse than usual today!", "hisses at you.", "begins circling you like a shark.", 
          "curls into a little ball of dragon and sighs.", "makes fun of your haircut."]
      #show user their new dragon!
      description if non_load
    end
    #Prints customized description of the Dragon.
    def description
      puts @dragon_ascii[@level]
      puts "#{@name} is a #{@levels[@level]['level']} dragon: #{@levels[@level]['desc']} 
It has #{@element}-tinted scales and smells of sulfur."
      puts "(press any key to continue)"
      any_key = gets.chomp
    end
    #Prints status update based on hunger and sleep status.
    def status
      puts @asleep ? "As #{@name} snores, smoke rises from his nostrils." : "#{@name} prowls the cave, full of energy!"
      if !(@asleep)
        case @stuff_in_belly
        when 1,2,3,4
          puts "#{@name} #{@yuck_greetings[rand((@yuck_greetings.length-1))]}"
          puts "#{@name}'s stomach is growling, and it looks at you in a strange way."
        when 5,6,7,8
          puts "#{@name} #{@happy_greetings[rand((@happy_greetings.length-1))]}"
          puts "#{@name} seems content."
        when 9,10
          puts "#{@name} #{@happy_greetings[rand((@happy_greetings.length-1))]}"
          puts "#{@name} whimpers- it has a tummy ache!"
        when 0
          puts "#{@name} #{@yuck_greetings[rand((@yuck_greetings.length-1))]}"
          puts "#{@name} is wasting away!"
        end
      end
      puts "(press any key to continue)"
      any_key = gets.chomp
    end
    #Decreases 'stuff_in_belly' and prints update.  50% chance of waking dragon.
    def hunger_up
      @stuff_in_belly -= rand(1..2) if @stuff_in_belly > 0
      if @asleep 
        if rand(1..2) == 2
          @asleep = false
          puts "#{@name} has woken up, and is hungry!"
          @stuff_in_belly -= 5
        else
          puts "#{@name} is still asleep- 'ZZzzzzzzz'"
        end
      end
      @stuff_in_belly = 0 if @stuff_in_belly < 0
      puts "Hunger Hint: its fullness = #{@stuff_in_belly}"
    end
    #Increases 'stuff_in_belly' and prints update.  Also wakes dragon if asleep.
    def feed
      if @asleep
        puts "You have awakened a dragon.  What a brave soul!"
        @asleep = false
      end
      puts "Feed your dragon a large or small gem?"
      puts "(enter 1 for small or 2 for large)"
      size = gets.chomp
      if @stuff_in_belly < 10
        case size
        when '1'
          @stuff_in_belly += 1
          puts "Your dragon munches the gem."
        when '2'
          @stuff_in_belly += 5
          puts "Your dragon munches the gem."
          if @stuff_in_belly > 10
            @stuff_in_belly = 10
          end
        else
          puts "Please enter 1 for a small gem and 2 for a large gem."
          feed
        end
      end
    end
    #Increases 'points', determining encounter frequency, and randomly puts Dragon to sleep.
    def point_up
      @points += 1 if (5..9).include?(@stuff_in_belly) && !(@asleep)
      if (1..2).include?(@points) && rand(1..2) == 2
        @asleep = true
        puts "#{@name} has fallen asleep - 'ZZzzzzzzz'"
      end
      if @points >= 3
        @points = 0
        encounter
      end
    end
    #Prints text of an 'encounter', waking up dragon if asleep and leveling up the Dragon.
    def encounter
      puts "* - * - * - * - * - * - * - * - * - * - * - * - * - * - * - *"
      puts "         ENCOUNTER!~"
      puts @encounters[(rand(@encounters.length-1))]
      if @asleep
        puts "Your dragon has woken up!" 
        @stuff_in_belly -= 5
      end
      puts "#{@name} fights them off and becomes stronger!"
      puts "(press any key to continue)"
      any_key = gets.chomp
      level_up
    end
    #Increases Dragon level, prints message, and prints end-game text if level reaches 4.  Returns scale when game ends.
    def level_up
      if @level < 3
        @level += 1
        description
      else
        puts "Your dragon roars with a burst of flame!"
        puts "THE TIME HAS COME.  #{@name} dragon must leave the nest."
        puts "Any parting words for your scaly companion?"
        words = gets.chomp
        puts "\"'#{words}'; I will always remember that!\"
        growls your dragon, as it takes to the skies."
        puts "(press any key to continue)"
        any_key = gets.chomp
        puts @dragon_ascii[4]
        puts "As #{@name} flies away, it leaves two things:"
        puts "A scale that gleams like #{@element} in the sun,"
        puts "and a large, smooth stone...."
        scale = "scale"
      end
    end
    #Returns a random element from init data.
    def rand_element
      @alt_elements[(rand(@alt_elements.length - 1))]
    end

  end
  #Child class of Menu from TextOnlyUX; it has a dragon aesthetic.
  class DK_Menu < TextOnlyUX::Menu
    #Displays menu with a dragon peeking over the top, fixed width.
    def display(player)
     quit = false
     #for this style inner menu width is fixed at 57
     inner_width = 53
    horiz_border = '                                  /   \       
 _                        )      ((   ))     (
(@)                      /|\      ))_((     /|\
|-|                     / | \    (/\|/\)   / | \                      (@)
| | -------------------/--|-voV---\`|\'/--Vov-|--\---------------------|-|
|-|                         \'^`   (o o)  \'^`                          | |
| |                               `\Y/\'                               |-|
|-|                                                                   | |'
    #create option padding
    def pad_titles(title, length)
      if title.length < length
        (length-title.length).times{
          title += ' '
        }
      end
      title
    end
        #display the menu
        puts horiz_border
        puts "|-|         #{pad_titles(@menu_name, inner_width)}     | |"
        puts "| |         #{pad_titles(" ", inner_width)}     |-|"
        toggle = false
        for option in @options
          left = toggle ? "-" : ' '
          right = toggle ? ' ' : "-"
          puts "|#{left}|     #{option[:number]} > #{pad_titles(option[:title], inner_width)}     |#{right}|"
          toggle = !toggle
        end
        puts "|#{right}|         #{pad_titles(" ", inner_width)}     |#{left}|"
        bottom_border = '|_|___________________________________________________________________| |
(@)              l   /\ /         ( (       \ /\   l                `\|-|
                 l /   V           \ \       V   \ l                  (@)
                 l/                _) )_          \I
                                   `\ /\'
'
        puts bottom_border
        puts '*Please type the number of your choice:'
        choice = gets.chomp
        puts "You chose #{choice}"
       option_chosen = false
       for option in @options
          if choice == option[:number].to_s
            option[:action].call(player)
            option_chosen= true
          end
        end
        if !option_chosen
          puts "That was not an option!"
        end
        #last, do the do_after
        @do_after.call(player)
    end
  end
end


#Menu should look like this:
#                                  /   \       
# _                        )      ((   ))     (
#(@)                      /|\      ))_((     /|\
#|-|                     / | \    (/\|/\)   / | \                      (@)
#| | -------------------/--|-voV---\`|'/--Vov-|--\---------------------|-|
#|-|                         '^`   (o o)  '^`                          | |
#| |                               `\Y/'                               |-|
#|-|                                                                   | |
#| |     1 > Play as 'Lucky'                                           |-|
#|-|     2 > Switch Player File                                        | |
#| |     3 > Quit                                                      |-|
#|-|                                                                   | |
#|_|___________________________________________________________________| |
#(@)              l   /\ /         ( (       \ /\   l                `\|-|
#                 l /   V           \ \       V   \ l                  (@)
#                 l/                _) )_          \I
#                                   `\ /'
#             `  Jeff Ferris
#    

#/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\
#\/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/
#
#     All ASCII Art was found on Chris.com
#     An amazing site that has been online
#     since 1994!
#     (You should check out his gallery
#     of ASCII artwork and donate to him!)
#     Credit for individual ASCII artworks:
#     >Pattern above and below this section
#     is from 'Krogg'
#     >'Baby' dragon is from 'orca'
#     >'Full Grown' dragon is from 'dk (c) 1993'
#     >Dragon style menu border is from 
#     'Jeff Ferris' and is similar to patterns by 
#     'Brian Young' and 'Alan Greep'.
#     >Other art sources unknown.
#
#     Thanks to Chris of Chris.com for saving it all!
#
#     (press any key to continue)
#
#/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\
#\/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/