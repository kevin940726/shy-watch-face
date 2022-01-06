using Toybox.Timer;

class BlinkingEyes {
    private var dc;
    private var blinkCount = 0;
    private var blinkingTimer;

    function initialize(_dc) {
        dc = _dc;
        blinkCount = 0;
    }

    function blink() {
      try {
          dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);

          if (blinkCount % 2 == 0) {
              dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
          } else {
              dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
          }

          dc.fillRectangle(85, 178, 8, 6);
          dc.fillRectangle(125, 178, 8, 6);

          if (blinkCount >= 3) {
              stop();
              return;
          }

          blinkingTimer = new Timer.Timer();
          blinkingTimer.start(method(:blink), 200, false);

          blinkCount += 1;
      } catch (err) {
          // Ignore the error
      }
    }

    function stop() {
        blinkCount = 0;
        blinkingTimer.stop();
    }
}
