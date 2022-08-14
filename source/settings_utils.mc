using Toybox.WatchUi;
using Toybox.Application;
using Toybox.System;

// First use information
var first_use_date;
var first_use_bool; 
var first_use_time_info;
var n_uses;
var next_new_hab_idx;
var colour_scheme;


// General
var fixedDisplaySettings;
var userDisplaySettings;
var data_start_daynum;
var sectorDisplay; 

var all_habits;

var wipe_data_str = "__FIRST_USE_V6_DAYNUM__";

function is_first_use() {
	first_use_bool = (Application.Storage.getValue(wipe_data_str) == null);
	if (first_use_bool) {
			System.println("THIS IS FIRST USE OF APPLICATION");
	}

	return first_use_bool;
}


// Should only ever be run once. Initialises all settings and data at default/example values. 
function first_time_setup() {

	System.println("FIRST TIME SET UP");
	
	// Remove anything hanging around from e.g an old install or previous version
	Application.Storage.clearValues();

	// First time date info
	first_use_time_info = getTime(null);
	
	System.println("FIRST TIME INFO...");
	System.println(first_use_time_info);
	
	// Set first use date
	Application.Storage.setValue(wipe_data_str, first_use_time_info["day_num"]);
	
	// First possible date to record data is 1st Jan, at least one year before first use date
	data_start_daynum = dayNumber(1, 1, first_use_time_info["year"] - 1);	
	Application.Storage.setValue("__DATA_START_DAYNUM__", data_start_daynum);
	Application.Storage.setValue("__DATA_START_YEAR__", first_use_time_info["year"] - 1);	

	// Set up default user settings values from json file
	var userDefaults = WatchUi.loadResource(Rez.JsonData.userDefaults);
	for (var entry_idx = 0; entry_idx < userDefaults.size(); entry_idx += 1) {
		Application.Storage.setValue(userDefaults.keys()[entry_idx], userDefaults.values()[entry_idx]);
	}

}


// A function to load settings which are qualities of the device. We only support fr645m for the moment. 
function refreshFixedSettings() {

	first_use_date = Application.Storage.getValue("__FIRST_USE_DAYNUM__");
	n_uses = Application.Storage.getValue("__N_USES__");
	next_new_hab_idx = Application.Storage.getValue("__NEXT_NEW_HABIT_INDEX__");
	
	fixedDisplaySettings = WatchUi.loadResource(Rez.JsonData.fixedDisplaySettings);
	
}


function habit_ID_from_idx(idx) {
	var s = "habit_" + idx.toString();
	return s;
}

function default_new_habit(idx) {
    return {
        "Name" => "Habit" + (idx + 1).toString(),
        "Abbreviation" => "H" + (idx + 1).toString(),
        "Type" => "Binary",
        "Colours" => "Blue"
    };
}

// A function to load general, permanent settings which depend on user preference - not the day or time. Some hard coded for dev but more could be made available to user later.
function refreshUserSettings() {
    
	// Days to display. If made available as a setting probably cap out at 28 to avoid having to do more than two different months on same screen
    n_days = Application.Storage.getValue("__N_DAYS__");
    
    // Habits to display
  	active_habits = Application.Storage.getValue("__ACTIVE_HABITS__");
	n_habits = active_habits.size();
	all_habits = Application.Storage.getValue("__ALL_HABITS__");

	// Next new habit index
	next_new_hab_idx = Application.Storage.getValue("__NEXT_NEW_HABIT_INDEX__");
  	
  	// Total items on data display screen, +1 for settings symbol
  	total_items = n_days*n_habits + 1;
  	
  	// Habits to display
  	userDisplaySettings = Application.Storage.getValue("__USER_DISPLAY_SETTINGS__");
  	
  	// Habit metadata
  	habit_metadata = {};
  	var habit_id;
  	var habit_meta;
  	
  	colour_scheme = WatchUi.loadResource(Rez.JsonData.fixedSettings)["Colour Schemes"];
  	
  	for (var h = 0; h < all_habits.size(); h += 1) {
  	
  		habit_id = self.all_habits[h];
  		
  		habit_meta = Application.Storage.getValue(habit_id);
		self.habit_metadata[habit_id] = habit_meta;		
	}
	
	sectorDisplay = new sectorDisplayer(userDisplaySettings["shape"]);
	
}

