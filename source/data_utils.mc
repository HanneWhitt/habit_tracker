using Toybox.System;
using Toybox.Application;
using Toybox.Lang;
using Toybox.Attention;


var n_habits;
var n_days;
var total_items;

var active_habits;
var habit_metadata;

// Key indexes 
var start_key = 4;
var back_key = 5;
var up_key = 13;
var down_key = 8;


// Convert item_idx (index over all selectables) to day_idx, habit_idx pair
function item_to_coords(item_idx) {
	if (item_idx == total_items - 1 or item_idx == null) {
		return [null, null];
	} else if (item_idx < total_items - 1 and item_idx >= 0) {
		System.println([total_items, item_idx, n_days - item_idx/n_habits - 1, item_idx % n_habits]);
		return [n_days - item_idx/n_habits - 1, item_idx % n_habits]; 
	} else {
		var exception_string = "Invalid item_idx: " + item_idx.toString() + ". Must be in range 0 - " + (total_items - 1).toString();
		throw new Lang.InvalidValueException(exception_string);
	}
}


function getStorageKey(habit_id, year) {
	return ("__"+ habit_id + "_" + year.toString() + "__");
}


// A function to load from storage data for the last n_days_to_display and put it in an array
function SaveLoadHabitData(start_daynum, last_daynum, habit_ids, save_data) {
	
	var n = last_daynum - start_daynum + 1;
	
	// Get the years of the first and last day
	var start_year = yearFromDaynum(start_daynum);
	var end_year = yearFromDaynum(last_daynum);
	
	// Initalise dict for loaded data. 
	// Always contains a stamp of the daynum so that day associated with each datum is never muddled
	var loaded_data = {"__DAYNUM_INTERVAL__" => [start_daynum, last_daynum]};
	
	if (save_data == null) {
		System.println("SaveLoadHabitData() LOADING data from day " + start_daynum.toString() + " to " + last_daynum.toString());
	} else {
		System.println("SaveLoadHabitData() SAVING data from day " + start_daynum.toString() + " to " + last_daynum.toString());
	} 
	
	// Iterate through habits
	for (var h = 0; h < habit_ids.size(); h += 1) {		
		
		var habit_id = habit_ids[h];
		var habit_data;
		
		print('\n' + habit_id);
		
		
		if (save_data == null) {
			habit_data = new [0];
		} else {
			habit_data = save_data[habit_id];
		}

		// Iterate through year blocks
		for (var y = start_year; y <= end_year; y += 1) {
			
			print(y);
			
			
			// Year length
			var year_length = daysInYear(y);
			
			// Load current saved version of appropriate block for habit and year
			var storage_key = getStorageKey(habit_id, y);
			var block_data = Application.Storage.getValue(storage_key);
			
			// If block does not exist...
			if (block_data == null) {
				// ...create an array of null values of appropriate length
				block_data = new [year_length];
			} else {
				// ...otherwise, do a check that the loaded data has the right length
				if (year_length != block_data.size()) {
					throw new Lang.InvalidValueException("Loaded data block " + storage_key + " has wrong length (" + block_data.size().toString() + ")");
				}				
			}
			
			// Get daynums of start and end of year block
			var block_start = dayNumber(1, 1, y);
			var block_end = dayNumber(31, 12, y);
			
			// Get daynums to read from this block
			var overlap_start_daynum = max(start_daynum, block_start);
			var overlap_end_daynum = min(last_daynum, block_end);
			var overlap_length = overlap_end_daynum - overlap_start_daynum + 1;
			
			// Convert to daynum within year to get indices within saved year blocks
			var save_data_start_index = DayInYear(overlap_start_daynum) - 1;
			
			if (save_data == null) {
				// Select data and add to array
				var read = block_data.slice(save_data_start_index, save_data_start_index + overlap_length);
				habit_data.addAll(read);
				
			} else {
				// Get indexes to take from habit data 
				var write_start_index = overlap_start_daynum - start_daynum;
				
				// Integrate into block				
				for (var w = 0; w < overlap_length; w += 1) {
					block_data[w + save_data_start_index] = habit_data[w + write_start_index];
				}
				
				// Save or overwrite block with new data
				Application.Storage.setValue(storage_key, block_data);
			}
		
		}

		if (save_data == null) { 
			// Check that the combined loaded data for this habit has the expected length
			if (habit_data.size() != n) {
				throw new Lang.InvalidValueException("Combined loaded data has length " + habit_data.size().toString() + ", expected length " + n.toString());
			}
			
			// Add it to the master array
			loaded_data[habit_id] = habit_data;
		}
	}
	
	return loaded_data;
	
}


// Given a daynum, load n_days of data leading up to and including that day
function loadDaynumHabitData(habits_to_load, last_daynum) {
	var start_daynum = last_daynum - n_days + 1;
	return SaveLoadHabitData(start_daynum, last_daynum, active_habits, null);
}

function addBlankHabitData(habit_data, new_habit_id) {
	var start_daynum = habit_data["__DAYNUM_INTERVAL__"][0];
	var last_daynum = habit_data["__DAYNUM_INTERVAL__"][1];
	var n = last_daynum - start_daynum + 1;

	return habit_data;
}


function SaveHabitData(save_data) {
	var start_daynum = save_data["__DAYNUM_INTERVAL__"][0];
	var last_daynum = save_data["__DAYNUM_INTERVAL__"][1];
	print(save_data);
	print((save_data == null));
	SaveLoadHabitData(start_daynum, last_daynum, active_habits, save_data);
}



function change_datum(item_idx) {

	var coords = item_to_coords(item_idx);
	var selected_day_idx = coords[0];
	var selected_habit_idx = coords[1];
	
	System.println(selected_day_idx);
	System.println(selected_habit_idx);
	
	var selected_habit_id = active_habits[selected_habit_idx];
	var type = habit_metadata[selected_habit_id]["Type"];
	
	var datum = current_data[selected_habit_id][selected_day_idx];
	var response = "None";
	
	if (type.equals("Binary")) {
	
		if (datum == 0 or datum == null) {
			datum = 1;
			response = "vibrate";
		} else if (datum == 1) {
			datum = 0;
		} else {
			throw new Lang.InvalidValueException("Invalid datum in current_data!");
		}
						
	} else {
		throw new Lang.InvalidValueException("Only Binary habits implemented at the moment.");
	}
	
	current_data[selected_habit_id][selected_day_idx] = datum;
	
	return response;

}

