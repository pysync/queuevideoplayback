package {

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import com.greensock.loading.ImageLoader;
	import com.greensock.events.LoaderEvent;
	import com.greensock.TweenMax;
	import flash.display.DisplayObject;

	public class VideoItemInQueue extends MovieClip {

		private var _context: Object = new Object();
		private var _indexInDataList: int = 0;
		private var _indexInQueue: int = 0;
		
		public function VideoItemInQueue(c: Object, indexInDataList:int, indexInQueue:int) {

			// set context refer to main app
			_context = c;

			// keep trace self index;
			_indexInDataList = indexInDataList;
			
			// keep track index inQueue;
			_indexInQueue = indexInQueue;

			trace("setup queueIndex: " + _indexInQueue);
			trace("setup dataIndex: " + _indexInDataList);
			// setup content
			setup();
			
			// register event listener for each button
			removeButton.addEventListener(MouseEvent.CLICK, onRemoveHandler);
		}
		
		private function setup():void {
			durationText.text = _context.urlDataList[_indexInDataList].title;
			
			// loade thumbnail
			var thumbUrl = _context.urlDataList[_indexInDataList].thumb 
						 ? _context.urlDataList[_indexInDataList].thumb 
						 : _context.defaultThumb;
			
			var loader: ImageLoader = new ImageLoader(thumbUrl, {
				name: "videoItemInQueue-thumbnail",
				container: thumbnail,
				x: 0,
				y: 0,
				width: 120,
				height: 68,
				scaleMode: "proportionalInside",
				centerRegistration: true,
				onComplete: onMovieThumbImageLoadedHandler
			});
			loader.load();
		}
	
		public function setIndexInQueue(index:int):void {
			_indexInQueue = index;
		}
		
		// handler remove from queue event
		private function onRemoveHandler(e: MouseEvent): void {

			removeButton.removeEventListener(MouseEvent.CLICK, onRemoveHandler);
			
			var queueLength = _context.movieInQueue.length;
			var movieClip:DisplayObject = _context.queueMovieListPanel.getChildAt(_indexInQueue);
			
			if (_indexInQueue < queueLength - 1) {
				var ix = movieClip.x;
				var iy = movieClip.y;
				
				for (var i = _indexInQueue + 1; i < queueLength; i++) {
					
					var displayObject:DisplayObject =  _context.queueMovieListPanel.getChildAt(i);
					var tx = displayObject.x; 
					var ty = displayObject.y;
					displayObject.x = ix; 
					displayObject.y = iy;
					ix = tx; iy = ty;
					
					var video:VideoItemInQueue = _context.movieInQueue[i];
					video.setIndexInQueue(i - 1);
				}
			}
			_context.movieInQueue.splice(_indexInQueue, 1);
			_context.queueMovieListPanel.removeChildAt(_indexInQueue);

		}

		// when the thumb image loaded
		private function onMovieThumbImageLoadedHandler(event: LoaderEvent): void {
			TweenMax.from(event.target.content, 1, { alpha: 0});
		}
		
		//Utils function
		private function force2Digits(value: Number): String {
			return (value < 10) ? "0" + String(value) : String(value);
		}
	}

}