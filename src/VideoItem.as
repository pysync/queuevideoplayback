package {

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import com.greensock.loading.ImageLoader;
	import com.greensock.events.LoaderEvent;
	import com.greensock.TweenMax;

	public class VideoItem extends MovieClip {

		private var _context: Object = new Object();
		private var _indexInDataList: int = 0;

		public function VideoItem(c: Object, indexInDataList: int) {

			// set context refer to main app
			_context = c;

			// keep trace self index;
			_indexInDataList = indexInDataList;

			// setup content
			setup();

			// register event listener for each button
			addButton.addEventListener(MouseEvent.CLICK, onAddHandler);
		}

		private function setup(): void {
			var duration = _context.urlDataList[_indexInDataList].duration 
						 ? _context.urlDataList[_indexInDataList].duration 
						 : 10;
			var minutes: String = force2Digits(int(duration / 60));
			var seconds: String = force2Digits(int(duration % 60));

			
			durationText.text = minutes + ":" + seconds;
			titleText.text = _context.urlDataList[_indexInDataList].title;
		}

		public function createThumbImageLoader(): ImageLoader {

			// load thumbnail
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
			return loader;
		}

		// when the thumb image loaded
		private function onMovieThumbImageLoadedHandler(event: LoaderEvent): void {
			TweenMax.from(event.target.content, 1, {
				alpha: 0
			});
		}

		//when the movieitem addButton Clicked
		function onAddHandler(e: MouseEvent): void {
			
			var indexInQueue = _context.movieInQueue.length;
			var alignX = indexInQueue ? 1 : 0;
			var thumbW = 130;
			
			var video: VideoItemInQueue = new VideoItemInQueue(_context, 
															   _indexInDataList,
															   indexInQueue);
			_context.movieInQueue.push(video);
			video.x = indexInQueue * thumbW + alignX;
			video.y = 0;
			
			_context.queueMovieListPanel.addChild(video);
		}

		//Utils function
		private function force2Digits(value: Number): String {
			return (value < 10) ? "0" + String(value) : String(value);
		}
	}

}