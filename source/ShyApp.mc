import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class ShyApp extends Application.AppBase {
    private var view;

    function initialize() {
        AppBase.initialize();
    }

    function onSettingsChanged() {
        view.onSettingsChanged();
        WatchUi.requestUpdate();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        view = new ShyView();
        onSettingsChanged();
        return [ view ] as Array<Views or InputDelegates>;
    }

}

function getApp() as ShyApp {
    return Application.getApp() as ShyApp;
}
