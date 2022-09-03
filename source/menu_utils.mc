using Toybox.WatchUi;
using Toybox.Application;


var editing_item;
var editing_idx;

var available_colours;


class TypingDelegate extends WatchUi.TextPickerDelegate {

    protected var attribute;

    function initialize(attribute) {
        TextPickerDelegate.initialize();
        self.attribute = attribute;
    }

    function onTextEntered(text, changed) {
        if (changed) {

            // Update draft habit metadata
            shs_hab_meta[self.attribute] = text;

            // Update correct attribute in single habit settings view - Name is item idx 1
            editing_idx = single_habit_settings_view.findItemById(self.attribute);
            editing_item = single_habit_settings_view.getItem(editing_idx);
            editing_item.setSubLabel(text);
            single_habit_settings_view.updateItem(editing_item, editing_idx);

            if (self.attribute.equals("Name")) {
                // Also update title in single habit settings view
                single_habit_settings_view.setTitle(text);
            }
                
        } 
    }

    function onCancel() {
    }
}


class DeletionConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    
    protected var habit_id;

    function initialize(habit_id) {
        ConfirmationDelegate.initialize();
        self.habit_id = habit_id;
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_NO) {
            System.println("Cancel");
        } else {
            
            // Steps occuring regardless of whether habit is active
            habit_metadata.remove(self.habit_id);
            all_habits.remove(self.habit_id);

            // If habit was currently active
            if (contains(active_habits, self.habit_id)) {
                active_habits.remove(self.habit_id);
                current_data.remove(self.habit_id);
                n_habits = n_habits - 1;
                total_items = total_items - n_days;
            }

            // Delete habit data on disk
            Application.Storage.deleteValue(self.habit_id);
            var data_start_year = Application.Storage.getValue("__DATA_START_YEAR__");
            for (var y = data_start_year; y <= current_time["year"] + 1; y += 1) {
                var storage_key = getStorageKey(self.habit_id, y);
                Application.Storage.deleteValue(storage_key);
            }

            // Update habit list view
            editing_idx = habit_menu_view.findItemById(self.habit_id);
            habit_menu_view.deleteItem(editing_idx);

            WatchUi.popView(2);
        }
    }
}


class ColourMenu extends WatchUi.CustomMenu {

    public var current_colour;
    private var type;

    function initialize() {
        
        CustomMenu.initialize(
            60,
            Graphics.COLOR_WHITE,
            {}
        );

        current_colour = shs_hab_meta["Colours"];
        type = shs_hab_meta["Type"];
        available_colours = colour_scheme[type]["ordering"];
        
        for (var c = 0; c < available_colours.size(); c += 1) {

            var colour = available_colours[c];

            print(colour);

            self.addItem(
                new ColourMenuItem(
                    type,
                    colour
                )
            );

        }
	}

    function drawTitle(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.drawText(
            dc.getWidth()/2,
            dc.getHeight()/2,
            Graphics.FONT_XTINY,
            "Colours",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawFooter(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
    }

}


class ColourMenuItem extends WatchUi.CustomMenuItem {
    
    private var colour;
    private var type;
    private var item_scheme;


    function initialize(_type, _colour) {
        CustomMenuItem.initialize(_colour, {});
        colour = _colour;
        type = _type;
        item_scheme = colour_scheme[type]["colours"][colour];
    }

    function draw(dc) {

        if (type.equals("Binary")) {

            circle(dc, dc.getWidth()/2, dc.getHeight()/2, 40, item_scheme["unselected"]["Yes"]);

            dc.setColor(
                Graphics.COLOR_BLACK,
                Graphics.COLOR_WHITE
            );
            dc.setPenWidth(1);
            dc.drawLine(0, 0, dc.getWidth(), 0);
            dc.drawLine(0, dc.getHeight() - 1, dc.getWidth(), dc.getHeight() - 1);
        }
    }
}



class ColourMenuDelegate extends WatchUi.Menu2InputDelegate {
    
    private var selected_colour;

    function initialize() {
        Menu2InputDelegate.initialize();
        selected_colour = shs_hab_meta["Colours"];
    }

    function onSelect(item) {
        selected_colour = item.getId();
        self.onBack();
    }

    function onBack() {

        // Update habit metadata for habit who's setting are being edited now
        shs_hab_meta["Colours"] = selected_colour;

        // Update the SingleHabitSettings view 
        editing_idx = single_habit_settings_view.findItemById("Colours");
        editing_item = single_habit_settings_view.getItem(editing_idx);
        editing_item.setSubLabel(selected_colour);
        single_habit_settings_view.updateItem(editing_item, editing_idx);

        single_habit_settings_view.setFocus(editing_idx);

        WatchUi.popView(2);
    }
}
