package {

	import flash.display.MovieClip;


	public class Debugger extends MovieClip {


		public function Debugger() {
			// constructor code
		}

		public function setPlayProgress(time: Number): void {
			var minutes: String = toTwoDigits(int(time / 60));
			var seconds: String = toTwoDigits(int(time % 60));
			currentTimeText.text = minutes + ":" + seconds;
		}

		public function setTotalTime(duration: Number): void {
			var minutes: String = toTwoDigits(int(duration / 60));
			var seconds: String = toTwoDigits(int(duration % 60));
			totalTimeText.text = minutes + ":" + seconds;
		}

		public function setChildProgress(progress:Number):void {
			var percent:int = Math.round(progress * 100);
			childPercentText.text = percent.toString() + " %";	
		}
		
		public function setTotalProgress(progress:Number):void {
			var percent:int = Math.round(progress * 100);
			totalPercentText.text = percent.toString() + " %";	
		}
		
		function toTwoDigits(value: Number): String {
			return (value < 10) ? "0" + String(value) : String(value);
		}
		

	}

}