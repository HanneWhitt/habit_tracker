using Toybox.System;
using Toybox.Application;
using Toybox.Lang;
using Toybox.Attention;


var n_habits;
var n_days;
var total_items;
var item_idx;

var active_habits;
var current_data;
var habit_metadata;
var time;

// Key indexes 
var start_key = 4;
var back_key = 5;
var up_key = 13;
var down_key = 8;


function up() {
	item_idx = (item_idx + 1) % total_items;
}

function down() {
	item_idx = (item_idx - 1) % total_items;
	if (item_idx < 0) {
		item_idx += total_items;
	}
}


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


function getStorageKey(habit_name, year) {
	return ("__"+ habit_name + "_" + year.toString() + "__");
}


// A function to load from storage data for the last n_days_to_display and put it in an array
function loadHabitData(start_daynum, last_daynum, habits_to_load) {
	
	//var first_day_number = current_day_number - n_days_to_display + 1; // +1 for boundary problem
	System.println("loadCurrentData() loading data from day " + start_daynum.toString() + " to " + last_daynum.toString());
	
   	var n_days = last_daynum - start_daynum + 1;
		
	// Get the years of the first and last day
	var start_year = yearFromDaynum(start_daynum);
	var end_year = yearFromDaynum(last_daynum);
	
	// Initalise dict for data. Always contains a stamp of the daynum so that day associated with each datum is never muddled
	var loaded_data = {"__DAYNUM_INTERVAL__" => [start_daynum, last_daynum]};
	
	// Iterate through habits
	for (var h = 1; h <= habits_to_load.size; h += 1) {
	
		var habit_name = habits_to_load[h];
		var loaded_habit_data;
		loaded_habit_data = new [0];

		// Iterate through year blocks
		for (var y = start_year; y <= end_year; y += 1) {
			
			// Year length
			var year_length = daysInYear(y);
			
			// Load appropriate block for habit and year
			var storage_key = getStorageKey(habit_name, y);
			var block_data = Application.Storage.getValue(storage_key);
			
			// If block does not exist...
			if (block_data == null) {
				// ...create an array of null values of appropriate length
				block_data = new [year_length];
			} else {
				// ...otherwise, do a check that the loaded data has the right length
				if (year_length != block_data.size()) {
					var exception = new InvalidValueException("Loaded data block " + storage_key + "j has wrong length");
					throw exception;
				}				
			}
			
			// Get daynums of start and end of block
			var block_start = dayNumber(1, 1, y);
			var block_end = dayNumber(31, 12, y);
			
			// Get daynums to read from this block
			var read_start_daynum = max(start_daynum, block_start);
			var read_end_daynum = min(last_daynum, block_end);
			
			// Convert to daynum within year
			var read_start_index = DayInYear(read_start_daynum);
			var read_end_index = DayInYear(read_end_daynum);
			
			// Select data and add to array
			var read = block_data.slice(read_start_index, read_end_index);
			loaded_habit_data.addAll(read);
		
		}

		// Check that the combined loaded data for this habit has the expected length
		if (loaded_habit_data.size() != n_days) {
			var exception = new InvalidValueException("Combined loaded data has wrong length");
			throw exception;
		}
		
		// Add it to the master array
		loaded_data[h] = loaded_habit_data;

	}
	
	return loaded_data;
	
}


function change_datum(item_idx) {

	var coords = item_to_coords(item_idx);
	var selected_day_idx = coords[0];
	var selected_habit_idx = coords[1];
	
	System.println(selected_day_idx);
	System.println(selected_habit_idx);
	
	
	var selected_habit_name = active_habits[selected_habit_idx];
	var type = habit_metadata[selected_habit_name]["Type"];
	
	var datum = current_data[selected_habit_name][selected_day_idx];
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
	
	current_data[selected_habit_name][selected_day_idx] = datum;
	
	return response;

}


function saveCurrentData(current_data) {
	
	var current_data_first_day = current_data["__DAYNUM_INTERVAL__"][0];
	var current_data_last_day = current_data["__DAYNUM_INTERVAL__"][1];
	
	for (var h = 0; h < n_habits; h += 1) {
	
		var habit_name = active_habits[h];
		System.println("\nSaving " + habit_name + " data...");
		
		// ITERATE BACKWARDS DAY BY DAY KEEPING TRACK OF DAYNUM and SAVING TO APPROPRIATE BLOCK
		// UPDATE BLOCK DATES IF NEW DAY INFO
		// CREATE NEW BLOCK IF LENGTH GREATER THAN MAX
				// Get blocks from habit metadata    		
		var blocks = habit_metadata[habit_name]["block_date_intervals"];
		
		var current_write_day = current_data_last_day;
		
		// Iterate through data blocks, with most recent first
		for (var block_idx = blocks.size() - 1; block_idx >= 0; block_idx -= 1) {
			
			var block_start = blocks[block_idx][0];
			var block_end = blocks[block_idx][1];
			
			if (block_end > current_data_last_day) { 
				// should never happen - means the metadata says that it contains data stored on days which haven't happened yet
				throw new Lang.InvalidValueException("Loaded block end date seems to be after last data in current data which should be impossible");
			
			} else if (block_end < current_data_first_day) { 
				// When we reach the point that all the remaining blocks finish before the first block in current_data, so do not need to be updated
				System.println("No more blocks to update for " + habit_name);
				break;
				
			} else { 
				// Blocks which need to be updated
				
				// Construct storage key and load block:		
				var storage_key = habit_name + '_' + block_start.toString();
				var old_block = Application.Storage.getValue(storage_key);
				System.println("Loaded old block " + storage_key + " length " + old_block.size().toString());
				
				// Figure out what data to transfer to what positions in the loaded block
				var new_block_length = current_write_day - block_start + 1;
				var new_block = new [new_block_length];
				
				for (var write_idx = new_block_length - 1; write_idx >= 0; write_idx -= 1) {
					
					if (current_write_day >= current_data_first_day) {
						new_block[write_idx] = current_data[habit_name][current_write_day - current_data_first_day];
				
					} else { 
						new_block[write_idx] = old_block[write_idx];
						
					}
					
					current_write_day -= 1;
				
				}
				
				System.println(old_block);
				System.println(new_block);
				
				
				//Overwrite
				Application.Storage.setValue(storage_key, new_block);
				
			}
			
		}
		
	}
	
}


