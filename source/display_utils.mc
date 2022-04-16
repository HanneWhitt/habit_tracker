using Toybox.Graphics;
using Toybox.System;


var colour_scheme;


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
	    enddeg + 90
    );
}


function center_date(dc, day_of_week, day, font) {
	//var date_string = day_of_week + "\n" + day.toString();
	
	if (font == null) {
		font = Graphics.FONT_XTINY;
	}
	
	var date_string = abbreviate_weekday(day_of_week) + day.toString();
	
	dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
        dc.getWidth() / 2,
        dc.getHeight() / 2 - Graphics.getFontHeight(font)/2,
        Graphics.FONT_XTINY,
        date_string,
        Graphics.TEXT_JUSTIFY_CENTER
    );
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
function display_habit_data(dc, habit_data, item_idx, time, show_habit) {
	
	var coords = item_to_coords(item_idx);
	var selected_day_idx = coords[0];
	var selected_habit_idx = coords[1];
	
	var screen_radius = dc.getWidth()/2;
	//var days_in_month = time["days_in_month"];
	var day_degrees = (dispSett["max_display_degrees"] - dispSett["min_display_degrees"] - (n_days - 1)*dispSett["gap_degrees"])/n_days;
	var radius_increment = (screen_radius - dispSett["min_radius"])/n_habits;

	var habit_name;
	var datum;
	var selected;
	var colour;
	
	for (var habit_idx = 0; habit_idx < n_habits; habit_idx += 1) {
	
		habit_name = active_habits[habit_idx];

		for (var day_idx = 0; day_idx < n_days; day_idx += 1) {

			datum = habit_data[habit_name][day_idx];
			
			selected = (day_idx == selected_day_idx and habit_idx == selected_habit_idx);
			
			colour = get_colour(habit_name, datum, selected);
			
			var max_deg = dispSett["max_display_degrees"] - day_idx*(day_degrees + dispSett["gap_degrees"]);
			var min_deg = max_deg - day_degrees;
			var min_rad = dispSett["min_radius"] + habit_idx*radius_increment;
			var max_rad = dispSett["min_radius"] + (habit_idx + 1)*radius_increment - dispSett["gap_radius"];
			
			annulusSector(
				dc, 
				min_deg, 
				max_deg, 
				min_rad, 
				max_rad, 
				colour
			);
				
		}
	}
}

// Full display for use in selection mode; Show settings symbol if appropriate
// Add day numbers, Habit labels
function display_full(dc, habit_data, item_idx, time, show_habit) {

	if (time != null) {
		var day_of_week = time["day_of_week"];
		var day = time["day"];
		var month_name = time["month_name"];
		center_date(dc, day_of_week, day, Graphics.FONT_XTINY);
	}

	display_habit_data(dc, habit_data, item_idx, time, show_habit);
	
}