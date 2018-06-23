package {

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import com.greensock.TweenMax;


	public class LargePlayPause extends MovieClip {

		private var paused: Boolean = false;
		public function LargePlayPause() {
			setPaused(false);

			var buttons = [background, playButton, pauseButton];
			for each(var button: MovieClip in buttons) {
				button.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				button.addEventListener(MouseEvent.MOUSE_OUT, onOverRoll);
				button.buttonMode = true;
			}

			TweenMax.allTo([playButton, pauseButton], 0.3, {
				tint: 0xFFFFFF,
				tintAmount: 1
			});
		}

		public function setPaused(isPaussed: Boolean): void {
			playButton.visible = isPaussed;
			pauseButton.visible = !isPaussed;
			paused = isPaussed;
		}


		function onMouseOver(e: MouseEvent): void {

			TweenMax.allTo([playButton, pauseButton], 0.3, {
				tint: 0xFF0000,
				tintAmount: 1
			});
		}

		function onOverRoll(e: MouseEvent): void {
			TweenMax.allTo([playButton, pauseButton], 0.3, {
				tint: 0xFFFFFF,
				tintAmount: 1
			});
		}

	}

}