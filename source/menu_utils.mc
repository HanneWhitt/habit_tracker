using Toybox.WatchUi;
using Toybox.Application;


var editing_item;
var editing_idx;


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