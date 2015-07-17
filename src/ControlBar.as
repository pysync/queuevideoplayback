package  {
	
	import flash.display.MovieClip;
	
	
	public class ControlBar extends MovieClip {
		
		
		public function ControlBar() {
		}
		
		public function setPaused(isPaused:Boolean):void {
			playPauseButton.playButton.visible = isPaused;
			playPauseButton.pauseButton.visible = !isPaused;
		}
		
		public function setMute(isMute:Boolean):void {
			audioToggleButton.soundButtonOn.visible = !isMute;
			audioToggleButton.soundButtonOff.visible = isMute;
		}
		
		public function setPlayProgress(time:Number):void {
			var minutes: String = toTwoDigits(int(time / 60));
			var seconds: String = toTwoDigits(int(time % 60));
			currentTimeText.text = minutes + ":" + seconds;
		}
			
		public function setTotalTime(duration:Number):void {
			var minutes: String = toTwoDigits(int(duration / 60));
			var seconds: String = toTwoDigits(int(duration % 60));
			totalTimeText.text = minutes + ":" + seconds;	
		}
		
		function toTwoDigits(value: Number): String {
			return (value < 10) ? "0" + String(value) : String(value);
		}
	}
	
}
