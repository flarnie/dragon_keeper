
module TextOnlyUX
class Menu
	attr_reader :menu_name

	def initialize(menu_name, options, do_after)
		@menu_name = menu_name
		@options = options
		@do_after = do_after #what to do after option executed?

	end

	def length()
		@options.length
	end

	def add_option(title, number, action)
	    @options << { title:title, number:number, action:action }
	end

	def display(student)
		quit = false
		#find longest option string
		longest_option = @options[0][:title].dup #default to first value
		for option in @options
			if option[:title].length > longest_option.length
				longest_option = option[:title].dup
			end
		end
		inner_width = longest_option.length
		#create horizontal borders
		def add_dashes(string,length)
			length.times{
				string += '-'
			}
			string
		end
		horiz_border = add_dashes("---------", inner_width)
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
        puts "|     #{pad_titles(@menu_name, inner_width)}  |"
        puts "|     #{pad_titles(" ", inner_width)}  |"
        for option in @options
        	puts "| #{option[:number]}>> #{pad_titles(option[:title], inner_width)}  |"
        end
        puts "|     #{pad_titles(" ", inner_width)}  |"
        puts horiz_border
        puts '*Please type the number of your choice:'
        choice = gets.chomp
        puts "You chose #{choice}"
       option_chosen = false
       for option in @options
       	  if choice == option[:number].to_s
       	  	option[:action].call(student)
       	  	option_chosen= true
       	  end
       	end
       	if !option_chosen
       		puts "That was not an option!"
       	end
       	#last, do the do_after
       	@do_after.call(student)
    end
end
end #end module TextOnlyUX

#Menu should print like this:
#-------------------
#| 1>> Chocolate   |
#| 2>> Strawberry  |
#| 3>> Caramel     |
#| 4>> Pecan-Pie   |
#-------------------