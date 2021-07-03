using Toybox.Application;


// STORAGE KEY format - gives day num of first day stored
var h1_key = "Mindfulness_361"; // day 361 = 1st jan 2021 - 6 days, day 371 = 5th jan 2021
var h1_val = [1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1];
var h2_key = "Piano_368";
var h2_val = [0, 1, 0, 1];

var h1_key2 = "Mindfulness_364"; // Only data for 29 dec 2020
var h1_val2 = [1];
var h2_key2 = "Piano_364"; // 29-31 dec 2020
var h2_val2 = [0, 1, 0];

var h1_key3 = "Mindfulness_359"; // some earlier Mindfulness data that we actually don't want to show up in development. 
var h1_val3 = [1, 0];

// We also need to store some metadata:
var h1_meta_key = "Mindfulness";
var h1_meta_val = {"short_name" => "M", "block_date_intervals" => [[359, 360], [361, 371]], "Type" => "Binary", "Colours" => "default_binary"};
var h2_meta_key = "Piano";
var h2_meta_val = {"short_name" => "P", "block_date_intervals" => [[364, 366], [368, 371]], "Type" => "Binary", "Colours" => "default_binary"};

// And some very general stuff
var all_habits_key = "__ALL_HABITS__";
var all_habits_val = ["Mindfulness", "Exercise", "Piano"];
var current_habits_key = "__ACTIVE_HABITS__";
var current_habits_val = ["Mindfulness", "Piano"];

// Writing all this to storage for development. All of this will be in storage already when app fully built. 
//Application.Storage.setValue(h1_key, h1_val);
//Application.Storage.setValue(h2_key, h2_val);
//Application.Storage.setValue(h2_key2, h2_val2);
//Application.Storage.setValue(h1_meta_key, h1_meta_val);
//Application.Storage.setValue(h2_meta_key, h2_meta_val);
//Application.Storage.setValue(all_habits_key, all_habits_val);
//Application.Storage.setValue(current_habits_key, current_habits_val);