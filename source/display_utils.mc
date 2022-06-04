using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Math;

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


function indicator(dc, x, y, r, colour) {
	dc.setColor(colour, colour);
	dc.setPenWidth(r);
    dc.drawCircle(x, y, 0);
}


var theta;
function settings_symbol(dc, x, y, r, colour) {
	
	dc.setColor(colour, colour);
	dc.setPenWidth(r);
    dc.drawCircle(x, y, r);

	for (var a = 0; a < 360; a += 45) {
		theta = Math.toRadians(a);
		dc.drawCircle(
			x + 3*r*Math.sin(theta)/2,
			y + 3*r*Math.cos(theta)/2, 
			0
		);
	}
}



class sectorDisplayer {

	public var screen_radius;
	public var min_radius;
	public var half_radius;
	public var day_degrees;
	public var radius_increment;
	public var shape;

	public var item_idx;
	public var previous_item_idx;
	public var habit_idx;
	public var previous_habit_idx;
	public var day_idx;
	public var previous_day_idx;

	protected var time_info;
	protected var previous_time_info;

	public var animation_item_idx;

	
	function initialize(shape) {
		self.shape = shape;
		self.screen_radius = fixedDisplaySettings["screen_radius"];
		self.min_radius = fixedDisplaySettings["min_radius"];
		self.half_radius = (self.screen_radius + self.min_radius)/2;
		self.day_degrees = (fixedDisplaySettings["max_display_degrees"] - fixedDisplaySettings["min_display_degrees"] - (n_days - 1)*fixedDisplaySettings["gap_degrees"])/n_days;
		self.radius_increment = (screen_radius - self.min_radius)/n_habits;
		self.indices_to_start();
	}

	function indices_to_start() {
		self.item_idx = 0;
		self.previous_item_idx = null;
		self.day_idx = n_days - 1;
		self.previous_day_idx = null;
		self.habit_idx = 0;
		self.previous_day_idx = null;
		self.time_info = getTime(null);
		self.previous_time_info = null;
		self.animation_item_idx = 0;
	}

	protected var coords;
	protected var min_deg;
	protected var max_deg;
	protected var min_rad;
	protected var max_rad;


	function plot_sector(dc, d, h, colour) {
		
		max_deg = fixedDisplaySettings["max_display_degrees"] - d*(self.day_degrees + fixedDisplaySettings["gap_degrees"]);
		min_deg = max_deg - self.day_degrees;
		min_rad = self.min_radius + h*self.radius_increment;
		max_rad = self.min_radius + (h + 1)*self.radius_increment - fixedDisplaySettings["gap_radius"];
		
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
			var error_message;
			error_message = "Received shape arg '" + self.shape + "', only 'Annulus Sector' implemented at present";
			throw new Lang.InvalidValueException(error_message);
		}		
	}

	protected var habit_id;
	protected var datum;
	protected var colour;
	
	function get_data_plot_sector(dc, habit_data, d, h, selected) {
		
		if (h == null) {
			coords = item_to_coords(d);
			d = coords[0];
			h = coords[1];
		}
		
		habit_id = active_habits[h];
		datum = habit_data[habit_id][d];
		colour = get_colour(habit_id, datum, selected);

		self.plot_sector(dc, d, h, colour);
	}
	


	// Display habit data only - initial view screen.
	function display_habit_data(dc, habit_data) {
		
		for (var h = 0; h < n_habits; h += 1) {
		
			for (var d = 0; d < n_days; d += 1) {
				
				self.get_data_plot_sector(dc, habit_data, d, h, false);
					
			}
		}

	}

	function display_habit_data_animated(dc, habit_data) {

		if (self.animation_item_idx == 0) {
			dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_WHITE);
			dc.clear();
		}

		if (self.animation_item_idx < total_items - 1) {

			for (var i = 0; i < n_habits; i += 1) {
				coords = item_to_coords(self.animation_item_idx);
				self.get_data_plot_sector(dc, habit_data, coords[0], coords[1], false);
				self.animation_item_idx += 1;
			}

			WatchUi.requestUpdate();
			return false;

		} else {
			return true;
		}

	}

	function update_idx_and_time() {
		self.previous_day_idx = self.day_idx;
		self.previous_habit_idx = self.habit_idx;

		coords = item_to_coords(self.item_idx);
		self.day_idx = coords[0];
		self.habit_idx = coords[1];
		
		// Update selected date info if day has changed
		if (self.day_idx != self.previous_day_idx) {
			self.previous_time_info = self.time_info;
			if (self.day_idx != null) {
				self.time_info = getTime(1 + self.day_idx - n_days);
			}
		}
	}

	function up() {
		self.previous_item_idx = self.item_idx;
		self.item_idx = (self.item_idx + 1) % total_items;
		self.update_idx_and_time();
	}

	function down() {
		self.previous_item_idx = self.item_idx;
		self.item_idx = (self.item_idx - 1) % total_items;
		if (self.item_idx < 0) {
			self.item_idx += total_items;
		}
		self.update_idx_and_time();
	}

	protected var col;

	// Used to display OR REMOVE a selected sector, date label, time label, indicators
	function display_selection_and_labelling(
			dc,
			habit_data, 
			t_info,
			d,
			h,
			update_day_lab,
			update_habit_lab,
			on_or_off
		) {

		if (on_or_off) {
			col = Graphics.COLOR_BLACK;
		} else {
			col = Graphics.COLOR_WHITE;
		}

		if (d == null and h == null) {
			self.display_settings_option(dc, Graphics.FONT_XTINY, col);
		} else {

			self.get_data_plot_sector(dc, habit_data, d, h, on_or_off);
			
			if (t_info != null and update_day_lab) {
				display_date(
					dc,
					t_info["day_of_week"],
					t_info["day"],
					Graphics.FONT_XTINY,
					col
				);
				display_day_indicator(dc, d, col);
			}

			if (update_habit_lab) {
				display_habit_label(dc, h, Graphics.FONT_XTINY, col);
				display_habit_indicator(dc, h, col);
			}
		}

	}

	protected var prev_habit_idx;
	protected var prev_day_idx;
	protected var update_day_label;
	protected var update_habit_label;


	// Remove the old selection elements, then add the new ones
	function update_selection_and_labelling(dc, habit_data, time_info) {

		update_day_label = true;
		update_habit_label = true;

		if (self.previous_item_idx != null) {

			// If the day has not changed, don't update date label etc
			if (self.day_idx == self.previous_day_idx) {
				update_day_label = false;
			}

			// If the habit has not changed, don't update habit label etc
			if (self.habit_idx == self.previous_habit_idx) {
				update_habit_label = false;
			}

			self.display_selection_and_labelling(
				dc, 
				habit_data, 
				self.previous_time_info, 
				self.previous_day_idx, 
				self.previous_habit_idx,
				update_day_label,
				update_habit_label,
				false
			);
		}

		self.display_selection_and_labelling(
			dc, 
			habit_data, 
			self.time_info, 
			self.day_idx, 
			self.habit_idx, 
			update_day_label,
			update_habit_label,
			true
		);

	}


	function clear_selection_and_labelling(dc, habit_data) {

		self.display_selection_and_labelling(
			dc, 
			habit_data, 
			self.time_info, 
			self.day_idx, 
			self.habit_idx,
			true,
			true,
			false
		);

	}


	function display_date(dc, day_of_week, day, font, colour) {

		var date_string = abbreviate_weekday(day_of_week) + day.toString();
		
		dc.setColor(colour, Graphics.COLOR_WHITE);
		dc.drawText(
			self.screen_radius,
			self.screen_radius - Graphics.getFontHeight(font)/2,
			font,
			date_string,
			Graphics.TEXT_JUSTIFY_CENTER
		);
	}


	function display_habit_label(dc, h, font, colour) {

		var h_id = active_habits[h];
		var h_abbrev = habit_metadata[h_id]["Abbreviation"];
		
		dc.setColor(colour, Graphics.COLOR_WHITE);
		dc.drawText(
			self.screen_radius + 20,
			self.screen_radius - self.half_radius - Graphics.getFontHeight(font)/2,
			font,
			h_abbrev,
			Graphics.TEXT_JUSTIFY_LEFT
		);

	}


	protected var ang;	
	protected var hyp;
	protected var x_pos;
	protected var y_pos;

	function display_day_indicator(dc, d, colour) {

		ang = Math.toRadians(fixedDisplaySettings["max_display_degrees"] - d*(self.day_degrees + fixedDisplaySettings["gap_degrees"]) - self.day_degrees/2);
		hyp = self.min_radius - 6;
		x_pos = self.screen_radius - hyp*Math.sin(ang);
		y_pos = self.screen_radius - hyp*Math.cos(ang);
		
		indicator(dc, x_pos, y_pos, 5, colour);

	}


	function display_habit_indicator(dc, h, colour) {

		x_pos = self.screen_radius + 6;
		min_rad = self.min_radius + h*self.radius_increment;
		max_rad = self.min_radius + (h + 1)*self.radius_increment - fixedDisplaySettings["gap_radius"];
		y_pos = self.screen_radius - (max_rad + min_rad)/2;
		
		indicator(dc, x_pos, y_pos, 5, colour);

	}

	function display_settings_option(dc, font, colour) {
		settings_symbol(
			dc, 
			self.screen_radius,
			self.screen_radius,
			self.screen_radius/12,
			colour
		);
		dc.setColor(colour, Graphics.COLOR_WHITE);
		dc.drawText(
			self.screen_radius + 10,
			self.screen_radius - self.half_radius,
			font,
			"Settings",
			Graphics.TEXT_JUSTIFY_LEFT
		);
	}

	function is_showing_settings() {
		return (self.item_idx == total_items - 1);
	}

}



function get_colour(habit_id, datum, selected) {
	
	var type = habit_metadata[habit_id]["Type"];
	var habit_colours = habit_metadata[habit_id]["Colours"];
		
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
