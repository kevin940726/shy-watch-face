using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.WatchUi;
using Toybox.ActivityMonitor;
using Toybox.Time.Gregorian as Date;

class ShyView extends WatchUi.WatchFace {
    private var olafImage;
    private var screenWidth;
    private var screenHeight;
    private var hoursFont;
    private var minutesFont;
    private var dateFont;
    private var heart;
    private var blinkingEyes;
    private var showSeconds = false;
    private var isLowPowerMode = false;
    private var isHidden = false;

    function initialize() {
        WatchFace.initialize();

        olafImage = Application.loadResource(Rez.Drawables.Olaf);
        hoursFont = Application.loadResource(Rez.Fonts.HoursFont);
        minutesFont = Application.loadResource(Rez.Fonts.MinutesFont);
        dateFont = Application.loadResource(Rez.Fonts.DateFont);
    }

    function onSettingsChanged() {
        showSeconds = Application.Properties.getValue("showSeconds");
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));

        screenWidth = dc.getWidth();
        screenHeight = dc.getHeight();

        var heartResource = WatchUi.loadResource(Rez.Drawables.Heart);
        heart = new WatchUi.AnimationLayer(heartResource, {
            :locX => screenWidth * 3 / 4,
            :locY => (screenHeight - heartResource.getHeight()) / 2 + 2, // Visual adjustment
        });
        addLayer(heart);

        blinkingEyes = new BlinkingEyes(dc);
    }

    function pumpHeart() {
        heart.play(null);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        isHidden = false;
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // Draw the UI
        drawOlaf(dc);
        drawHoursMinutes(dc);
        drawSecondsText(dc, false);
        drawDate(dc);
        drawHeartRateText(dc);
        drawBattery(dc);

        // Draw optional animations
        if (!isLowPowerMode && !isHidden) {
            pumpHeart();
            if (System.getClockTime().sec % 15 == 0) {
                blinkingEyes.blink();
            }
        }
    }

    function onPartialUpdate(dc) {
        drawSecondsText(dc, true);
    }

    private function drawOlaf(dc) {
        dc.drawBitmap(
            screenWidth / 2 - olafImage.getWidth() / 2,
            screenHeight - olafImage.getHeight(),
            olafImage
        );
    }

    private function drawHoursMinutes(dc) {
        var clockTime = System.getClockTime();
        var hours = clockTime.hour.format("%02d");
        var minutes = clockTime.min.format("%02d");

        var x = screenWidth / 2;
        var y = screenHeight - olafImage.getHeight() - 22;

        // Draw hours
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            x - 2,
            y,
            hoursFont,
            hours,
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Draw minutes
        dc.drawText(
            x + 2,
            y,
            minutesFont,
            minutes,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function drawSecondsText(dc, isPartialUpdate) {
        if (!showSeconds || isHidden) {
            return;
        }

        var clockTime = System.getClockTime();
        var minutes = clockTime.min.format("%02d");
        var seconds = clockTime.sec.format("%02d");

        var minutesWidth = 48; // dc.getTextWidthInPixels(minutes, minutesFont)
        var x = screenWidth / 2 + 2 + minutesWidth + 5; // Margin right 5px
        var y = screenHeight - olafImage.getHeight() - 22 - 2; // Visual adjustment 2px

        if (isPartialUpdate) {
            dc.setClip(
                x,
                y + 5, // Adjust for text justification 5px
                18, // dc.getTextWidthInPixels(seconds, dateFont)
                15 // Fixed height 15px
            );
            // Use the background color to force repaint the clip
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            dc.clear();
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        }

        dc.drawText(
            x,
            y,
            dateFont,
            seconds,
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }

    private function drawDate(dc) {
        var now = Time.now();
        var date = Date.info(now, Time.FORMAT_MEDIUM);
        var dateString = Lang.format("$1$, $2$ $3$", [date.day_of_week, date.month, date.day]);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            screenWidth / 2,
            35,
            dateFont,
            dateString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function drawHeartRateText(dc) {
        var heartRate = 0;
        
        if (ActivityMonitor has :INVALID_HR_SAMPLE) {
            var heartrateIterator = ActivityMonitor.getHeartRateHistory(null, false);
            var currentHeartrate = heartrateIterator.next().heartRate;

            if (currentHeartrate != ActivityMonitor.INVALID_HR_SAMPLE) {
                heartRate = currentHeartrate;
            }
        }

        var heartResource = heart.getResource();
        var x = screenWidth * 3 / 4 + heartResource.getWidth() + 4; // Margin right
        var y = screenHeight / 2;

        dc.setColor(
            heartRate > 120 ? Graphics.COLOR_DK_RED : Graphics.COLOR_WHITE,
            Graphics.COLOR_TRANSPARENT
        );
        dc.drawText(
            x,
            y,
            dateFont,
            heartRate == 0 ? "--" : heartRate.format("%d"),
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function drawBattery(dc) {
        var battery = System.getSystemStats().battery;

        var height = 12;
        var width = 18;
        var x = screenWidth / 4 - width;
        var y = screenHeight / 2 - height / 2 + 2;

        dc.setPenWidth(2);
        dc.setColor(
            battery <= 20 ? Graphics.COLOR_DK_RED : Graphics.COLOR_WHITE,
            Graphics.COLOR_TRANSPARENT
        );
        // Draw the outer rect
        dc.drawRoundedRectangle(
            x,
            y,
            width,
            height,
            2
        );
        // Draw the small + on the right
        dc.drawLine(
            x + width + 1,
            y + 3,
            x + width + 1,
            y + height - 3
        );
        // Fill the rect based on current battery
        dc.fillRectangle(
            x + 1,
            y,
            (width - 2) * battery / 100,
            height
        );

        // Draw the text
        dc.drawText(
            x - 6,
            screenHeight / 2,
            dateFont,
            battery.format("%d"),
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        isHidden = true;
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        isLowPowerMode = false;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        isLowPowerMode = true;
        blinkingEyes.stop();
        heart.stop();
    }

}
