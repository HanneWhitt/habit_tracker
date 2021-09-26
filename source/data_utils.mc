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


// A function to load from storage data for the last n_days_to_display and put it in an array
function loadCurrentData(current_day_number, n_days_to_display) {
	
	var first_day_number = current_day_number - n_days_to_display + 1; // +1 for boundary problem
	System.println("loadCurrentData() loading data from day " + first_day_number.toString() + " to " + current_day_number.toString());
	
	// Dict to store data. Always contains a stamp of the daynum interval so that day associated with each datum is never muddled
   	var daynum_interval = [first_day_number, current_day_number];
   	var current_data = {"__DAYNUM_INTERVAL__" => daynum_interval};
	
	for (var h = 0; h < n_habits; h += 1) {
	
		var habit_name = active_habits[h];
		System.println("\nLoading " + habit_name + " data...");    		
		    		
		var display_data = new [n_days_to_display];
		
		// Get blocks from habit metadata    		
		var blocks = habit_metadata[habit_name]["block_date_intervals"];
		
		System.println("Available data blocks: " + blocks.toString());
		
		// Iterate through data blocks, with most recent first
		for (var block_idx = blocks.size() - 1; block_idx >= 0; block_idx -= 1) {

   			var block_start = blocks[block_idx][0];   			
			var block_end = blocks[block_idx][1];    			
			
			if (block_end > current_day_number) { 
				// should never happen - data was recorded on future days!?
				throw new Lang.InvalidValueException("block end date seems to be after current date which should be impossible");
			
			} else if (block_end < first_day_number) { 
				// When we reach the point that all the rest of the data is before the first day to be shown on screen - so does not need to be loaded
				System.println("No more relevant " + habit_name + " data");
				break;
				
			} else { 
				// Relevant data!
				
				// Construct storage key and load block:		
				var storage_key = habit_name + '_' + block_start.toString();
				var block_data = Application.Storage.getValue(storage_key);
				System.println("Loaded block " + storage_key + " length " + block_data.size().toString());
				
				// Figure out which data from the block to copy onto which part of the display array
				var first_start = max(first_day_number, block_start);
				var splice_start = first_start - block_start;
				var copy_length = block_data.size() - splice_start;										
				var write_start = first_start - first_day_number;
				
				// Copy it 
				for (var i = 0; i < copy_length; i += 1) {
					display_data[i + write_start] = block_data[i + splice_start];
				
				}
				
				System.println(display_data);
			}
		}
		
		// Add fully constructed display data into all-habit array_dict
		current_data[habit_name] = display_data;
	}
	
	System.println(current_data);
	
	return current_data;	
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


