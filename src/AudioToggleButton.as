package {

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import com.greensock.TweenMax;


	public class AudioToggleButton extends MovieClip {

		private var mute: Boolean = false;
		public function AudioToggleButton() {
			setMute(true);
			var buttons = [background, soundButtonOn, soundButtonOff];
			for each(var button: MovieClip in buttons) {
				button.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				button.addEventListener(MouseEvent.MOUSE_OUT, onOverRoll);
				button.buttonMode = true;
			}
			TweenMax.allTo([soundButtonOn, soundButtonOff], 0.3, {
				tint: 0xFFFFFF,
				tintAmount: 1
			});
		}


		public function setMute(isMute: Boolean): void {
			soundButtonOn.visible = !isMute;
			soundButtonOff.visible = isMute;
			mute = isMute;
		}

		function onMouseOver(e: MouseEvent): void {
			TweenMax.allTo([soundButtonOn, soundButtonOff], 0.3, {
				tint: 0xFF0000,
				tintAmount: 1
			});

		}

		function onOverRoll(e: MouseEvent): void {
			TweenMax.allTo([soundButtonOn, soundButtonOff], 0.3, {
				tint: 0xFFFFFF,
				tintAmount: 1
			});
		}
	}

}