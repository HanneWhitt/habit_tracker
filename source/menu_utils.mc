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
        print("Canceled");
    }
}
