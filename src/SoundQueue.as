package  {
	
	import flash.display.MovieClip;
	import fl.controls.RadioButtonGroup;
	
	
	public class SoundQueue extends MovieClip {
		
		private var _group:RadioButtonGroup = new RadioButtonGroup("sound group");
		private var _context:Object = new Object();
		
		public function SoundQueue() {
			// constructor code
		}
		
		public function setup(context:Object){
			_context = context;
			var radioButtons = [soundA, soundB, soundC];
			for (var i:int = 0; i < radioButtons.length; i++){
				radioButtons[i].group = _group;
			}
			
			if (_context.trackData.length >= 3){
				for (i = 0; i < radioButtons.length; i++){
					radioButtons[i].label = _context.trackData[i].title;
				}
			}

		}
	}
	
}
