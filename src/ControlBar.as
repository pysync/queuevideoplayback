package  {
	
	import flash.display.MovieClip;
	
	
	public class ControlBar extends MovieClip {
		
		
		public function ControlBar() {
			
			setPlay(false);
			setMute(true);
			
			setLoadingProgress(0);
			setPlayingProgress(0);
		}
		
		public function setLoadingProgress(percent:Number):void {
			
		}
		
		public function setPlayingProgress(percent:Number):void {
			
			setSeekTime(percent);
		}
		
		public function setSeekTime(percent:Number):void {
			
			
		}
		
		public function setPlay(isPlay:Boolean):void {
			playButton.visible = isPlay;
			pauseButton.visible = !isPlay;
		}
		
		public function setMute(isMute:Boolean):void {
			soundButtonOn.visible = !isMute;
			soundButtonOff.visible = isMute;
		}
	}
	
}
