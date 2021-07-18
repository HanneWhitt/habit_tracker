using Toybox.WatchUi;
using Toybox.Application;


// A function to load settings which are qualities of the device. We only support fr645m for the moment. 
function deviceSettings() {
	self.dispSett = WatchUi.loadResource(Rez.JsonData.displaySettings);
}


// A function to load general, permanent settings which depend on user preference - not the day or time. Some hard coded for dev but more could be made available to user later.
function userSettings() {
    
	// Days to display. If made available as a setting probably cap out at 28 to avoid having to do more than two different months on same screen
    n_days = 10;
    
    // Habits to display
  	self.active_habits = Application.Storage.getValue("__ACTIVE_HABITS__");
  	n_habits = self.active_habits.size();
  	
  	// Total items
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

