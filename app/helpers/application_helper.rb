module ApplicationHelper

    def logo
	   return(image_tag("logo.png", :alt => "Sample App",  :class => "round"))
	end

	def title
			deftitle="Ruby on Rails Tutorial Sample App"
		if @title.nil?
			deftitle
		else
			deftitle + " | " + @title
		end
	end
end
