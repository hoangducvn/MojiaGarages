MainLanguage = 'en'
CustomFont = nil --[nil]: use system default font - or ['name of your custom font']: You need your_custum_font.gfx EX: CustomFont = 'Oswald'

function GetText(str)
    if not Language then
		return 'Language error' 
	end
    if not Language[MainLanguage] then
		return 'Invalid locale' 
	end
    if not Language[MainLanguage][str] then
		return 'Invalid string' 
	end
    return Language[MainLanguage][str]
end

Language = {
    ['vi'] = {
        ['vehicle_info'] = 'Biển số: %s<br>Xăng: %s<br>Máy: %s<br>Thân xe: %s',
        ['vehicle_info_and_price'] = 'Tiền chuộc: $%s<br>Biển số: %s<br>Xăng: %s<br>Máy: %s<br>Thân xe: %s',
        ['garage_menu_header'] = '🚘| %s',
        ['close_menu'] = '❌| Đóng',
        ['there_are_no_vehicles_in_the_garage'] = 'Không có xe nào trong nhà để xe?!',
        ['the_receiving_area_is_obstructed_by_something'] = 'Khu vực nhận xe bị cản trở bởi một thứ gì đó!?',
        ['take_out_x_out_of_x_garage'] = 'Lấy xe %s khỏi %s thành công!',
        ['vehicle_parked_in_x'] = 'Đã gửi xe vào %s',
        ['nobody_owns_this_vehicle'] = 'Không có ai sở hữu chiếc xe này',
        ['you_need_to_return_the_car_you_received_before_so_you_can_get_a_new_one'] = 'Bạn cần trả lại chiếc xe bạn đã nhận trước đó để có thể nhận một chiếc xe mới',
        ['job_vehicle_menu_header'] = '🚘 | Danh sách xe dành cho %s',
        ['you_dont_have_enough_money'] = 'Bạn không có đủ tiền!',
    },
    ['en'] = {
        ['vehicle_info'] = 'Plate: %s<br>Fuel: %s<br>Engine: %s<br>Body: %s',
        ['vehicle_info_and_price'] = 'Price: $%s<br>Plate: %s<br>Fuel: %s<br>Engine: %s<br>Body: %s',
        ['garage_menu_header'] = '🚘| %s',
        ['close_menu'] = '❌| Close',
        ['there_are_no_vehicles_in_the_garage'] = 'There are no vehicles in the garage?!',
        ['the_receiving_area_is_obstructed_by_something'] = 'The receiving area is obstructed by something!?',
        ['take_out_x_out_of_x_garage'] = 'Successfully took %s out of %s garage!',
        ['vehicle_parked_in_x'] = 'Vehicle parked in %s',
        ['nobody_owns_this_vehicle'] = 'Nobody owns this vehicle',
        ['you_need_to_return_the_car_you_received_before_so_you_can_get_a_new_one'] = 'You need to return the car you received before so you can get a new one',
        ['job_vehicle_menu_header'] = '🚘 | %s\'s Vehicle List',
        ['you_dont_have_enough_money'] = 'You don\'t have enough money',
    }
}