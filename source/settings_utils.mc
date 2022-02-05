using Toybox.WatchUi;
using Toybox.Application;
using Toybox.System;

// First use information
var first_use_bool; 
var first_use_time_info;
var n_uses;
var dispSett;
var data_start_daynum;


function is_first_use() {
	System.println(Application.Storage.getValue("__FIRST_USE_DAYNUM__"));
	first_use_bool = (Application.Storage.getValue("__FIRST_USE_DAYNUM__") == null);
	if (first_use_bool) {
			System.println("THIS IS FIRST USE OF APPLICATION");
	}
	return first_use_bool;
}


// Should only ever be run once. Initialises all settings and data at default/example values. 
function first_time_setup() {

	System.println("FIRST TIME SET UP");
	
	// Remove anything hanging around
	Application.Storage.clearValues();

	// First time date info
	first_use_time_info = getTime();
	
	System.println("FIRST TIME INFO...");
	System.println(first_use_time_info);
	
	// Set first use date
	Application.Storage.setValue("__FIRST_USE_DAYNUM__", first_use_time_info["day_num"]);
	
	// First possible date to record data is 1st Jan, at least one year before first use date
	data_start_daynum = dayNumber(1, 1, first_use_time_info["year"] - 1);	
	Application.Storage.setValue("__DATA_START_DAYNUM__", data_start_daynum);
	Application.Storage.setValue("__DATA_START_YEAR__", first_use_time_info["year"] - 1);	

	// Set up default settings values from json file
	var setupValues = WatchUi.loadResource(Rez.JsonData.setupValues);
	for (var entry_idx = 0; entry_idx < setupValues.size(); entry_idx += 1) {
		System.println(setupValues.keys()[entry_idx]);
		Application.Storage.setValue(setupValues.keys()[entry_idx], setupValues.values()[entry_idx]);
	}

}


var new_habit_dict;

function set_up_new_habit(name, abbreviation, type, colours) {
	
	System.println("SETTING UP HABIT:");
	System.println(name);

	var new_habit_dict = {"Abbreviation" => abbreviation, "Type" => type, "Colours" => colours};

	Application.Storage.setValue(name, new_habit_dict);
	
}

// A function to load settings which are qualities of the device. We only support fr645m for the moment. 
function fixedSettings() {

	var first_use_date = Application.Storage.getValue("__FIRST_USE_DAYNUM__");
	n_uses = Application.Storage.getValue("__N_USES__");
	
	dispSett = WatchUi.loadResource(Rez.JsonData.displaySettings);
	
}


// A function to load general, permanent settings which depend on user preference - not the day or time. Some hard coded for dev but more could be made available to user later.
function userSettings() {
    
	// Days to display. If made available as a setting probably cap out at 28 to avoid having to do more than two different months on same screen
    n_days = 10;
    
    // Habits to display
  	self.active_habits = Application.Storage.getValue("__ACTIVE_HABITS__");
  	n_habits = self.active_habits.size();
  	
  	// Total items on data display screen, +1 for settings symbol
  	total_items = n_days*n_habits + 1;
  	
  	// Habit metadata
  	self.habit_metadata = {};
  	self.colour_scheme = {};
  	var habit_name;
  	var habit_meta;
  	var habit_colours;
  	
  	for (var h = 0; h < n_habits; h += 1) {
  	
  		habit_name = self.active_habits[h];
  		
  		habit_meta = Application.Storage.getValue(habit_name);
		self.habit_metadata[habit_name] = habit_meta;
		
		habit_colours = habit_meta["Colours"];
		self.colour_scheme[habit_colours] = WatchUi.loadResource(Rez.JsonData.colourSchemes)[habit_colours];
	}
}

