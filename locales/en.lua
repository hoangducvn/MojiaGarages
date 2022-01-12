local Translations = {
    error = {
        there_are_no_vehicles_in_the_garage = 'There are no vehicles in the garage?!',
        the_receiving_area_is_obstructed_by_something = 'The receiving area is obstructed by something!?',
        nobody_owns_this_vehicle = 'Nobody owns this vehicle',
        you_need_to_return_the_car_you_received_before_so_you_can_get_a_new_one = 'You need to return the car you received before so you can get a new one',
        you_dont_have_enough_money = 'You don\'t have enough money',
    },
    success = {
        take_out_x_out_of_x_garage = 'Successfully took %{vehicle} out of %{garage} garage!',
        vehicle_parked_in_x = 'Vehicle parked in %{garage}',
        your_vehicle_has_been_marked = 'Your vehicle has been marked',
    },
    info = {
        garage_menu_header = '🚘| %{header}',
        job_vehicle_menu_header = '🚘 | %{grade}\'s Vehicle List',
        close_menu = '❌| Close',
        vehicle_info = 'Plate: %{plate}<br>Fuel: %{fuel}%<br>Engine: %{engine}%<br>Body: %{body}%<br>Tank: %{tank}%<br>Dirt: %{dirt}%',
        vehicle_info_and_price = 'Price: $%{price}<br>Plate: %{plate}<br>Fuel: %{fuel}%<br>Engine: %{engine}%<br>Body: %{body}%<br>Tank: %{tank}%<br>Dirt: %{dirt}%',
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})