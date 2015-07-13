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
			currentLoadingBar.scaleX = percent;
		}
		
		public function setPlayingProgress(percent:Number):void {
			currentProgressBar.scaleX = percent;
			setSeekTime(percent);
		}
		
		public function setSeekTime(percent:Number):void {
			var _x = percent * totalProgressBar.width;
			seekTimeAnchor.x = _x;
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
