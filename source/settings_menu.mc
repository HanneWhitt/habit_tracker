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
        print(item.getId());
        if (item.getId().equals("Habits")) {
            WatchUi.pushView(new HabitMenu(), new HabitMenuDelegate(), 1);
        }
    }

    function onBack() {
        WatchUi.popView(2);
    }
}



class HabitMenu extends WatchUi.Menu2 {

    protected var hab_name;
    protected var hab_is_active;

    function initialize() {
		Menu2.initialize({:title=>"Habits"});

        for (var h = 0; h < all_habits.size(); h += 1) {

            hab_name = all_habits[h];
            if (contains(active_habits, hab_name)) {
                hab_is_active = "Active";
            } else {
                hab_is_active = "Inactive";
            }

            self.addItem(
                new MenuItem(
                    hab_name,
                    hab_is_active,
                    hab_name,
                    {}
                )
            );

        }

        self.addItem(
            new MenuItem(
                "Add new",
                null,
                "Add new",
                {}
            )
        );

	}
}


class HabitMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        if (item.getId().equals("Add new")) {
            print("ADD NEW PRESSED");
        } else {
            WatchUi.pushView(new HabitSettings(item.getId()), new HabitSettingsDelegate(), 1);
        }
    }

    function onBack() {
        WatchUi.popView(2);
    }
}


class HabitSettings extends WatchUi.Menu2 {

    protected var hab_name;
    protected var hab_is_active_bool;
    protected var hab_meta;

    function initialize(habit_name) {
		Menu2.initialize({:title=>habit_name});

        self.hab_name = habit_name;
        hab_is_active_bool = contains(active_habits, self.hab_name);
        hab_meta = habit_metadata[hab_name];

        self.addItem(
            new ToggleMenuItem(
                "Status",
                {:enabled => "Active", :disabled => "Inactive"},
                "Status",
                hab_is_active_bool,
                {}
            )
        );

        self.addItem(
            new MenuItem(
                "Name",
                habit_name,
                "Name",
                {}
            )
        );

        self.addItem(
            new MenuItem(
                "Abbreviation",
                hab_meta["Abbreviation"],
                "Abbreviation",
                {}
            )
        );

        self.addItem(
            new MenuItem(
                "Habit type",
                hab_meta["Type"],
                "Habit type",
                {}
            )
        );

        self.addItem(
            new MenuItem(
                "Colours",
                hab_meta["Colours"],
                "Colours",
                {}
            )
        );

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


class HabitSettingsDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        System.println(item.getId());
    }

    function onBack() {
        WatchUi.popView(2);
    }
}