using Toybox.WatchUi;


class SettingsMain extends WatchUi.Menu2 {

    function initialize() {
		Menu2.initialize({:title=>"Settings"});

        self.addItem(
            new MenuItem(
                "Habits",
                null,
                "Habits",
                {}
            )
        );

        self.addItem(
            new MenuItem(
                "General",
                null,
                "General",
                {}
            )
        );

	}
}


class SettingsMainDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        habit_menu_view = new HabitMenu();
        habit_menu_delegate = new HabitMenuDelegate();
        if (item.getId().equals("Habits")) {
            WatchUi.pushView(habit_menu_view, habit_menu_delegate, 1);
        }
    }

    function onBack() {
        sectorDisplay = new sectorDisplayer(userDisplaySettings["shape"]);
        WatchUi.popView(2);
    }
}


class HabitMenu extends WatchUi.Menu2 {

    public var hab_id;
    public var hab_name;
    public var hab_is_active;
    public var menu_length;

    function initialize() {
		Menu2.initialize({:title=>"Habits"});

        self.menu_length = 0;

        for (var h = 0; h < all_habits.size(); h += 1) {

            hab_id = all_habits[h];

            hab_name = habit_metadata[hab_id]["Name"];

            if (contains(active_habits, hab_id)) {
                hab_is_active = "Active";
            } else {
                hab_is_active = "Inactive";
            }

            self.addHabit(hab_name, hab_is_active, hab_id); 

        }

        self.addAddNew();

	}

    function addHabit(h_name, h_is_active, h_id) {
        self.addItem(
            new MenuItem(
                h_name,
                h_is_active,
                h_id,
                {}
            )
        );
        self.menu_length += 1;
    }

    function addAddNew() {
        self.addItem(
            new MenuItem(
                "Add new",
                null,
                "Add new",
                {}
            )
        );
        self.menu_length += 1;
    }

    function extend(h_name, h_is_active, h_id) {
        self.deleteItem(self.menu_length - 1);
        self.menu_length -= 1;
        self.addHabit(h_name, h_is_active, h_id);
        self.addAddNew();
    }

}


class HabitMenuDelegate extends WatchUi.Menu2InputDelegate {
    
    protected var selected_habit_id;
  
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        selected_habit_id = item.getId();
        single_habit_settings_view = new SingleHabitSettings(selected_habit_id);
        single_habit_settings_delegate = new SingleHabitSettingsDelegate();
        WatchUi.pushView(single_habit_settings_view, single_habit_settings_delegate, 1);
    }

    function onBack() {
        // Update disk versions of all_habits, active habits
        Application.Storage.setValue("__ALL_HABITS__", all_habits);
        Application.Storage.setValue("__ACTIVE_HABITS__", active_habits);
        WatchUi.popView(2);
    }
}


var shs_hab_id;
var shs_hab_meta;
var shs_hab_is_active_bool;


class SingleHabitSettings extends WatchUi.Menu2 {

    function initialize(hab_id) {

        if (hab_id.equals("Add new")) {
            shs_hab_id = habit_ID_from_idx(next_new_hab_idx);
            shs_hab_meta = default_new_habit(next_new_hab_idx);
            Menu2.initialize({:title=>"New Habit"});
            shs_hab_is_active_bool = true;
        } else {
            shs_hab_id = hab_id;
            shs_hab_meta = habit_metadata[hab_id];
            Menu2.initialize({:title=>shs_hab_meta["Name"]});
            shs_hab_is_active_bool = contains(active_habits, shs_hab_id);
            self.addItem(
                new ToggleMenuItem(
                    "Status",
                    {:enabled => "Active", :disabled => "Inactive"},
                    "Status",
                    shs_hab_is_active_bool,
                    {}
                )
            );
        }

        self.addItem(
            new MenuItem(
                "Name",
                shs_hab_meta["Name"],
                "Name",
                {}
            )
        );

        self.addItem(
            new MenuItem(
                "Abbreviation",
                shs_hab_meta["Abbreviation"],
                "Abbreviation",
                {}
            )
        );

        self.addItem(
            new MenuItem(
                "Habit type",
                shs_hab_meta["Type"],
                "Habit type",
                {}
            )
        );

        self.addItem(
            new MenuItem(
                "Colours",
                shs_hab_meta["Colours"],
                "Colours",
                {}
            )
        );

        if (hab_id.equals("Add new")) {
            self.addItem(
                new MenuItem(
                    "Cancel",
                    null,
                    "Cancel",
                    {}
                )
            );
        } else {
            self.addItem(
                new MenuItem(
                    "Delete",
                    null,
                    "Delete",
                    {}
                )
            );
        }

	}
}



class SingleHabitSettingsDelegate extends WatchUi.Menu2InputDelegate {
    
    protected var original_hab_is_active_bool;

    function initialize() {
        Menu2InputDelegate.initialize();
        original_hab_is_active_bool = shs_hab_is_active_bool;
    }

    function onSelect(item) {
        if (item.getId().equals("Status")) {
            shs_hab_is_active_bool = item.isEnabled();
        } else if (item.getId().equals("Name")) {
            WatchUi.pushView(
                new WatchUi.TextPicker(shs_hab_meta["Name"]),
                new TypingDelegate("Name"),
                2
            );
        } else if (item.getId().equals("Abbreviation")) {
            WatchUi.pushView(
                new WatchUi.TextPicker(shs_hab_meta["Abbreviation"]),
                new TypingDelegate("Abbreviation"),
                2
            );
        } else if (item.getId().equals("Cancel")) {
            // Don't change anything; just pop back to the previous view
            WatchUi.popView(2);
        } else if (item.getId().equals("Delete")) {
            // Push deletion confirmation view
            var message = "Delete " + shs_hab_meta["Name"] + "?";
            WatchUi.pushView(
                new WatchUi.Confirmation(message),
                new DeletionConfirmationDelegate(shs_hab_id),
                2
            );
        }
    }

    function onBack() {

        // Update/Create entry in habit_metadata for this item
        habit_metadata[shs_hab_id] = shs_hab_meta;

        // Update/Create the settings on disk for this habit
        Application.Storage.setValue(shs_hab_id, shs_hab_meta);

        // Add to or update Habit Menu view
        editing_idx = habit_menu_view.findItemById(shs_hab_id);
        if (editing_idx == -1) {
            // New habit being created
            habit_menu_view.extend(
                shs_hab_meta["Name"],
                "Active",
                shs_hab_id
            );
            active_habits.add(shs_hab_id);
            all_habits.add(shs_hab_id);
            next_new_hab_idx += 1;
            Application.Storage.setValue("__NEXT_NEW_HABIT_INDEX__", next_new_hab_idx);
            n_habits = active_habits.size();
            total_items = n_days*n_habits + 1;
            current_data = addBlankHabitData(current_data, shs_hab_id);
            editing_idx = habit_menu_view.menu_length - 2;
        } else {
            // Updating old one
            editing_item = habit_menu_view.getItem(editing_idx);
            editing_item.setLabel(shs_hab_meta["Name"]);

            // Change status 
            if (original_hab_is_active_bool != shs_hab_is_active_bool) {
                if (shs_hab_is_active_bool) {
                    editing_item.setSubLabel("Active");
                    active_habits.add(shs_hab_id);
                    n_habits = n_habits + 1;
                    total_items = total_items + n_days;
                    current_data = addHabitData(current_data, [shs_hab_id]);
                } else {
                    editing_item.setSubLabel("Inactive");
                    active_habits.remove(shs_hab_id);
                    n_habits = n_habits - 1;
                    total_items = total_items - n_days;
                    SaveHabitData(current_data, [shs_hab_id]);
                    current_data.remove(shs_hab_id);
                }
            }

            habit_menu_view.updateItem(editing_item, editing_idx);

        }

        habit_menu_view.setFocus(editing_idx);

        WatchUi.popView(2);
    }
}
