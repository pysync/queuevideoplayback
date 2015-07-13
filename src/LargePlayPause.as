package  {
	
	import flash.display.MovieClip;
	
	
	public class LargePlayPause extends MovieClip {
		
		
		public function LargePlayPause() {
			setPlay(false);
		}
		
		public function setPlay(isPlay:Boolean):void {
			playButton.visible = isPlay;
			pauseButton.visible = !isPlay;
		}
		
	}
	
}
