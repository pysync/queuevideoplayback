package {

	import flash.display.MovieClip;


	public class AudioToggleButton extends MovieClip {


		public function AudioToggleButton() {
			// constructor code
		}


		public function setMute(isMute: Boolean): void {
			soundButtonOn.visible = !isMute;
			soundButtonOff.visible = isMute;
		}
	}

}