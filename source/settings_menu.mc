using Toybox.WatchUi;

class SettingsMainMenu extends WatchUi.Menu2 {

    function initialize() {
		Menu2.initialize({:title=>"Settings"});

        self.addItem(
            new MenuItem(
                "Item 1 Label",
                "Item 1 subLabel",
                "itemOneId",
                {}
            )
        );
        self.addItem(
            new MenuItem(
                "Item 2 Label",
                "Item 2 subLabel",
                "itemTwoId",
                {}
            )
        );
	}
}

class MyMenu2InputDelegate extends WatchUi.Menu2InputDelegate {
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
