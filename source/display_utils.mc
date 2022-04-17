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


class sectorDisplayer {

	public var screen_radius;
	public var day_degrees;
	public var radius_increment;
	public var shape;
	
	function initialize(shape) {
		self.shape = shape;
		self.screen_radius = fixedDisplaySettings["screen_radius"];
		self.day_degrees = (fixedDisplaySettings["max_display_degrees"] - fixedDisplaySettings["min_display_degrees"] - (n_days - 1)*fixedDisplaySettings["gap_degrees"])/n_days;
		self.radius_increment = (screen_radius - fixedDisplaySettings["min_radius"])/n_habits;
	}
	
	protected var day_idx;
	protected var habit_idx;
	protected var coords;
	protected var min_deg;
	protected var max_deg;
	protected var min_rad;
	protected var max_rad;

	function plot_sector(dc, day_idx, habit_idx, colour) {
		
		max_deg = fixedDisplaySettings["max_display_degrees"] - day_idx*(self.day_degrees + fixedDisplaySettings["gap_degrees"]);
		min_deg = max_deg - self.day_degrees;
		min_rad = fixedDisplaySettings["min_radius"] + habit_idx*self.radius_increment;
		max_rad = fixedDisplaySettings["min_radius"] + (habit_idx + 1)*self.radius_increment - fixedDisplaySettings["gap_radius"];
		
		if (self.shape.equals("Annulus Sector")) {
			annulusSector(
				dc, 
				min_deg, 
				max_deg, 
				min_rad, 
				max_rad, 
				colour
			);
//		} else if (self.shape.equals("Circle")) {
//			throw new Lang.InvalidValueException("Only Annulus Sector implemented at present");
		} else {
			throw new Lang.InvalidValueException("Received shape arg '" + self.shape + "', only 'Annulus Sector' implemented at present");
		}		
	}

	protected var habit_name;
	protected var datum;
	protected var colour;
	
	function get_data_plot_sector(dc, habit_data, day_or_item_idx, habit_idx_or_none, selected) {
		
		if (habit_idx_or_none == null) {
			coords = item_to_coords(day_or_item_idx);
			day_idx = coords[0];
			habit_idx = coords[1];
		} else {
			day_idx = day_or_item_idx;
			habit_idx = habit_idx_or_none;
		}
		
		habit_name = active_habits[habit_idx];
		datum = habit_data[habit_name][day_idx];
		colour = get_colour(habit_name, datum, selected);
				
		self.plot_sector(dc, day_idx, habit_idx, colour);
			
	}
	
	// Display habit data only - initial view screen.
	function display_habit_data(dc, habit_data) {
		
		for (var habit_idx = 0; habit_idx < n_habits; habit_idx += 1) {
		
			for (var day_idx = 0; day_idx < n_days; day_idx += 1) {
				
				self.get_data_plot_sector(dc, habit_data, day_idx, habit_idx, false);
					
			}
		}
	}
	
	protected var selected_day_idx;
	protected var selected_habit_idx;
	protected var selected_habit_name;
	
	// Add current selection, settings symbol and labelling - selection view screen
	function display_selection_and_labelling(dc, habit_data, time) {
	
		print("ITEM IDX - " + item_idx.toString());
		print(previous_item_idx);
	
		self.get_data_plot_sector(dc, habit_data, item_idx, null, true);
		if (previous_item_idx != null) {
			self.get_data_plot_sector(dc, habit_data, previous_item_idx, null, false);
		}
		
		if (time != null) {
			var day_of_week = time["day_of_week"];
			var day = time["day"];
			var month_name = time["month_name"];
			center_date(dc, day_of_week, day, Graphics.FONT_XTINY);
		}
					
	}

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

