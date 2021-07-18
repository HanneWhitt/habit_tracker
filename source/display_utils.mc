using Toybox.Graphics;
using Toybox.System;


var colour_scheme;
var dispSett;


function annulusSector(dc, startdeg, enddeg, startrad, endrad, colour) {
	dc.setColor(colour, colour);
	var width = endrad - startrad;
    dc.setPenWidth(width);
    dc.drawArc(
    dc.getWidth() / 2,                     
    dc.getHeight() / 2,       
    startrad + width / 2,
    Graphics.ARC_COUNTER_CLOCKWISE,
    startdeg + 90,
    enddeg + 90);
}

function get_colour(habit_name, datum, selected) {
	
	var type = habit_metadata[habit_name]["Type"];
	var habit_colours = habit_metadata[habit_name]["Colours"];
		
	if (type.equals("Binary")) {
	
		if (datum == 1) {
			datum = "Yes";
		} else if (datum == 0) {
			datum = "No";
		} else if (datum == null) {
			datum = "No data";
		} else {
			throw new Lang.InvalidValueException("Invalid datum in storage!");
		}
		
		if (selected) {
			return colour_scheme[habit_colours]["selected"][datum];
		} else {
			return colour_scheme[habit_colours]["unselected"][datum];
		}
						
	} else {
		throw new Lang.InvalidValueException("Only Binary habits implemented at the moment.");
	}
	
}

// Display habit data only
function display_habit_data(dc, item_idx) {
	
	var coords = item_to_coords(item_idx);
	var selected_day_idx = coords[0];
	var selected_habit_idx = coords[1];
	
	System.println(selected_habit_idx);
	System.println(selected_day_idx);
	
	var screen_radius = dc.getWidth()/2;
	var days_in_month = time["days_in_month"];
	var degree_increment = (dispSett["max_display_degrees"] - dispSett["min_display_degrees"])/n_days;
	var radius_increment = (screen_radius - dispSett["min_radius"])/n_habits;

	var habit_name;
	var datum;
	var selected;
	var colour;
	
	for (var habit_idx = 0; habit_idx < n_habits; habit_idx += 1) {
	
		habit_name = active_habits[habit_idx];

		for (var day_idx = 0; day_idx < n_days; day_idx += 1) {

			datum = current_data[habit_name][day_idx];
			
			selected = (day_idx == selected_day_idx and habit_idx == selected_habit_idx);
			
			colour = get_colour(habit_name, datum, selected);
			
			annulusSector(
				dc, 
				dispSett["min_display_degrees"] + day_idx*degree_increment, 
				dispSett["min_display_degrees"] + (day_idx + 1)*degree_increment - dispSett["gap_degrees"], 
				dispSett["min_radius"] + habit_idx*radius_increment, 
				dispSett["min_radius"] + (habit_idx + 1)*radius_increment - dispSett["gap_radius"], 
				colour
			);
		}
	}
}

// Full display for use in selection mode; Show settings symbol if appropriate
// Add day numbers, Habit labels
function display_full(dc, item_idx) {

	display_habit_data(dc, item_idx);
	
}