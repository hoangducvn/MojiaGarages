local Translations = {
    error = {
        there_are_no_vehicles_in_the_garage = 'Không có xe nào trong nhà để xe?!',
        the_receiving_area_is_obstructed_by_something = 'Khu vực nhận xe bị cản trở bởi một thứ gì đó!?',
        nobody_owns_this_vehicle = 'Không có ai sở hữu chiếc xe này',
        you_need_to_return_the_car_you_received_before_so_you_can_get_a_new_one = 'Bạn cần trả lại chiếc xe bạn đã nhận trước đó để có thể nhận một chiếc xe mới',
        you_dont_have_enough_money = 'Bạn không có đủ tiền!',
    },
    success = {
        take_out_x_out_of_x_garage = 'Lấy xe %{vehicle} khỏi %{garage} thành công!',
        vehicle_parked_in_x = 'Đã gửi xe vào %{garage}',
        your_vehicle_has_been_marked = 'Phương tiện của bạn đã được đánh dấu',
    },
    info = {
        garage_menu_header = '🚘| %{header}',
        job_vehicle_menu_header = '🚘 | Danh sách xe dành cho %{grade}',
        close_menu = '❌| Đóng',
        vehicle_info = 'Biển số: %{plate}<br>Xăng: %{fuel}%<br>Máy: %{engine}%<br>Thân xe: %{body}%<br>Thùng Xăng: %{tank}%<br>Bụi Bẩn: %{dirt}%',
        vehicle_info_and_price = 'Tiền chuộc: ${price}<br>Biển số: %{plate}<br>Xăng: %{fuel}%<br>Máy: %{engine}%<br>Thân xe: %{body}%<br>Thùng Xăng: %{tank}%<br>Bụi Bẩn: %{dirt}%',
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})