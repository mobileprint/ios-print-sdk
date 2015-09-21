def page_by_name page_name
	page_class_name = "#{page_name.gsub(' ', '')}Screen"
	page_constant = Object.const_get(page_class_name)

	page(page_constant)
end


def go_to page_class
    requested_page = page(page_class).navigate

	#wait_for_none_animating
    requested_page
end

