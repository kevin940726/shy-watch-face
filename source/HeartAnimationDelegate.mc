import Toybox.WatchUi;

class HeartAnimationDelegate extends WatchUi.AnimationDelegate {
    private var animation;

    function initialize(animationLayer) {
        AnimationDelegate.initialize();
        animation = animationLayer;
    }

    function onAnimationEvent(event, options) {
        switch(event) {
            case WatchUi.ANIMATION_EVENT_COMPLETE:
                animation.play({
                  :delegate => self
                });
                break;
        }
    }
}
