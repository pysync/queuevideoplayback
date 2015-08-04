package {

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import com.greensock.TweenMax;


	public class AudioToggleButton extends MovieClip {

		private var mute: Boolean = false;
		private var usable:Boolean = true;
		
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

		public function setState(isUsable: Boolean, isMute:Boolean): void {
			usable = isUsable;
			mute = isMute;
			var buttons = [background, soundButtonOn, soundButtonOff];
			for each(var button: MovieClip in buttons) {
				button.buttonMode = usable;
			}
			
			if (!usable) {
				TweenMax.to(background, 0, {autoAlpha: 0});
				TweenMax.allTo([soundButtonOn, soundButtonOff], 0, {
					autoAlpha: 0.2
				});
				setMute(true);
			} else {
				TweenMax.to(background, 0, {autoAlpha: 1});
				TweenMax.allTo([soundButtonOn, soundButtonOff], 0, {
					autoAlpha: 1
				});
				setMute(isMute);
			}
		}

		public function setMute(isMute: Boolean): void {
			mute = isMute;
			soundButtonOn.visible = !mute;
			soundButtonOff.visible = mute;
			
		}

		function onMouseOver(e: MouseEvent): void {
			if (!usable) return;
			
			TweenMax.allTo([soundButtonOn, soundButtonOff], 0.3, {
				tint: 0xFF0000,
				tintAmount: 1
			});

		}

		function onOverRoll(e: MouseEvent): void {
			if (!usable) return;
			
			TweenMax.allTo([soundButtonOn, soundButtonOff], 0.3, {
				tint: 0xFFFFFF,
				tintAmount: 1
			});
		}
	}

}