package {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import com.greensock.TweenMax;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.XMLLoader;
	import com.greensock.loading.VideoLoader;
	import com.greensock.loading.MP3Loader;
	import flash.geom.Rectangle;
	import flash.display.Sprite;
	import com.greensock.loading.ImageLoader;
	import flash.net.URLLoader;
	import flash.errors.IOError;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import fl.containers.ScrollPane;
	import flash.geom.ColorTransform;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import com.greensock.loading.display.ContentDisplay;
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	

	
	public class Main extends MovieClip {
		private var _trackData:Object = new Object();
		public var _videoData: Array = [];
		public var _videos: Array = [];
		public var _track: MP3Loader;
		public var _video: VideoLoader;
		public var _mouseIsOver: Boolean;
		public var _isStarted: Boolean;
		private var _silentMode: Boolean;
		public var _isDebugEnable: Boolean;

	
		public function Main() {
			
			loadParameters();
			_silentMode = false;
			_isStarted = false;
			_isDebugEnable = true;
			stage.scaleMode = "noScale";
			
			initUI();
			initMonitor();
			activateUI();
			startLoaderMax();
		}
		
				
		private function loadParameters():void {
			var flashvars:Object = stage.loaderInfo.parameters;

			var parseSuccess:Boolean = false;
			
			try {
				var soundUrl = flashvars["soundUrl"] as String;
				var movieUrls = flashvars["movieUrls"] as String;
				
				if (soundUrl.length > 0 && movieUrls.length > 0){
					
					_trackData = {
						url: soundUrl,
						vars: {
							name: "track",
							autoPlay:false,
							repeat: 1,
							estimateBytes: 9500
						}
					};
					
					_videoData = [];
					var urls:Array = JSON.parse(movieUrls) as Array;
					for(var i:int = 0; i < urls.length; i++) {
						var vars:Object = {
							name:"movie_" + i, 
							width:320,
							height:240, 
							scaleMode:"proportionalInside", 
							centerRegistration:true, 
							alpha:1, 
							volume:0,
							autoPlay:false, 
							estimatedBytes:"8887418" 
						};
						
						_videoData.push({
							url: urls[i],
							vars: vars
						});
					}
					
					parseSuccess = true;
				}
			} 
			catch(error:Error) {
				trace("fail for parse params.");
			}
			
			debugger.msgText.text = "load data: " + parseSuccess + " l: " + _videoData.length;
		}

		
		function debug(msg:String):void {
			debugger.msgText.text = msg;
		}
	
		public function startLoaderMax(): void {
			var queue:LoaderMax = new LoaderMax({
				name: "DataList",
				maxConnections:1,
				autoLoad: false,
				onProgress:loaderProgressHandler,
				onComplete:loaderCompleteHandler,
				onChildProgress:childLoaderProgressHandler,
				onChildComplete:childLoaderCompleteHandler
			});
			
			
			_track = new MP3Loader(_trackData.url, _trackData.vars);
			queue.append(_track);
			
			var t:String = "";
			_videos.length = 0;
			var vl:VideoLoader = null;
			for each (var v in _videoData) {
				vl = new VideoLoader(v.url, v.vars); 
				_videos.push(vl);
				queue.append(vl);
				t += v.url + " = ";
			}
			debug(t);
			queue.prependURLs("assets/");
			queue.load();
		}	

	
		function loaderProgressHandler(event:LoaderEvent):void {
			var percent:int = Math.round(event.target.progress * 100);
			loadingAnim.totalPercentText.text = "Total: " +  percent + " %";
						
		}
		
		function loaderCompleteHandler(event:LoaderEvent): void {
			loadingAnim.totalPercentText.text = "Total: DONE!";
			showVideo(_videos[0]);
		}
		
		function childLoaderProgressHandler(event:LoaderEvent): void {
			var percent:int = Math.round(event.target.progress * 100);
			loadingAnim.childPercentText.text = "Child: " +  percent + " %";
		}
		
		function childLoaderCompleteHandler(event:LoaderEvent): void {
			loadingAnim.childPercentText.text = "Child: DONE!"
		}

		public function showVideo(video: VideoLoader): void {

			if (video == _video) {
				return;
			}

			if (_video == null) {
				activateUI(); 
			} else {

				_video.removeEventListener(LoaderEvent.PROGRESS, updateDownloadProgress);
				_video.removeEventListener(VideoLoader.PLAY_PROGRESS, updatePlayProgress);
				_video.removeEventListener(VideoLoader.VIDEO_BUFFER_FULL, bufferFullHandler);
				_video.removeEventListener(VideoLoader.VIDEO_COMPLETE, nextVideo);
				_video.removeEventListener(LoaderEvent.INIT, refreshTotalTime);

				if (_video.videoPaused) {
					togglePlayPause();
				}

				TweenMax.to(loadingAnim, 0.3, {
					autoAlpha: 0,
					onComplete: loadingAnim.stop
				});

				TweenMax.to(_video.content, 0.8, {
					autoAlpha: 0
				});

				_video.volume = 0;
				
			}

			_video = video;

			_video.addEventListener(LoaderEvent.PROGRESS, updateDownloadProgress);
			_video.addEventListener(VideoLoader.VIDEO_COMPLETE, nextVideo);
			_video.addEventListener(VideoLoader.PLAY_PROGRESS, updatePlayProgress);

			if (_video.progress < 1 && _video.bufferProgress < 1) {

				_video.addEventListener(VideoLoader.VIDEO_BUFFER_FULL, bufferFullHandler);
				_video.prioritize(true);
				
				loadingAnim.play();
				TweenMax.to(loadingAnim, 0.3, {
					autoAlpha: 1
				});
			}

			//start playing the video from its beginning
			_video.gotoVideoTime(0, true);

			//always start with the volume at 0, and fade it up to 1 if necessary.
			_video.volume = 0;

            //only seek time to zero if first time play or video index = 0
			var _videoIndex = _videos.indexOf(_video);
			if (!_isStarted || _videoIndex == 0) {
				_isStarted = true;
				_track.gotoSoundTime(0, true);
				
				_track.volume = 0;
				if (!_silentMode) {
					TweenMax.to(_track, 0.8, {
						volume: 1
					});
				}

			}

			videoContainer.addChild(_video.content);

			TweenMax.to(_video.content, 0.8, {
				autoAlpha: 1
			});

			refreshTotalTime();

			if (_video.metaData == null) {
				_video.addEventListener(LoaderEvent.INIT, refreshTotalTime);
			}

			updateDownloadProgress();
			updatePlayProgress();
            updateMonitor();
		}

		public function initMonitor(): void {
			if (!_isDebugEnable)
				return;

			var videoIndex = _videos.indexOf(_video);
			debugger.videoIdText.text = "scene: --";
		}

		public function updateMonitor(): void {
			if (!_isDebugEnable)
				return;

			var videoIndex = _videos.indexOf(_video);
			debugger.videoIdText.text = "scene: " + videoIndex;
		}

		public function initUI(): void {
			loadingAnim.mouseEnabled = false;
			controlBar.blendMode = "layer";

			TweenMax.allTo([controlBar, loadingAnim], 0, {
				autoAlpha: 0
			});
		}



		public function updateDownloadProgress(event: LoaderEvent = null): void {
			
		}

		public function bufferFullHandler(event: LoaderEvent): void {
			TweenMax.to(loadingAnim, 0.3, {
				autoAlpha: 0,
				onComplete: loadingAnim.stop
			});
		}

		public function updatePlayProgress(event: LoaderEvent = null): void {
			var time: Number = _video.videoTime;
			var minutes: String = toTwoDigits(int(time / 60));
			var seconds: String = toTwoDigits(int(time % 60));
			controlBar.currentTimeText.text = minutes + ":" + seconds;
		}

		public function refreshTotalTime(event: LoaderEvent = null): void {
			var minutes: String = toTwoDigits(int(_video.duration / 60));
			var seconds: String = toTwoDigits(int(_video.duration % 60));
			controlBar.totalTimeText.text = minutes + ":" + seconds;
		}

		public function activateUI(): void {

			addListeners([controlBar, videoContainer], MouseEvent.ROLL_OVER, toggleControlUI);
			addListeners([controlBar, videoContainer], MouseEvent.ROLL_OUT, toggleControlUI);
			addListeners([controlBar.playButton, videoContainer], MouseEvent.CLICK, togglePlayPause);
			controlBar.soundButtonOn.addEventListener(MouseEvent.CLICK, toggleAudio);
			
		}
		
		public function toggleControlUI(event: MouseEvent): void {
			_mouseIsOver = !_mouseIsOver;
			if (_mouseIsOver) {
				TweenMax.to(controlBar, 0.3, {
					autoAlpha: 1
				});
			} else {
				TweenMax.to(controlBar, 0.3, {
					autoAlpha: 0
				});
			}
		}

		public function toggleAudio(event: MouseEvent): void {
			_silentMode = !_silentMode;
			if (_silentMode) {
				_track.volume = 0;
			} else {
				_track.volume = 1;
			}
		}

		public function togglePlayPause(event: MouseEvent = null): void {
			_video.videoPaused = !_video.videoPaused;
			if (_video.videoPaused) {

				TweenMax.to(videoContainer, 0.3, {
					blurFilter: {
						blurX: 6,
						blurY: 6
					},
					colorMatrixFilter: {
						brightness: 0.5
					}
				});
			} else {

				TweenMax.to(videoContainer, 0.3, {
					blurFilter: {
						blurX: 0,
						blurY: 0,
						remove: true
					},
					colorMatrixFilter: {
						brightness: 1,
						remove: true
					}
				});
			}
		}

		public function nextVideo(event: Event): void {
			var next: int = _videos.indexOf(_video) + 1;
			if (next >= _videos.length) {
				next = 0;
			}
			showVideo(_videos[next]);
		}

		public function previousVideo(event: Event): void {
			var prev: int = _videos.indexOf(_video) - 1;
			if (prev < 0) {
				prev = _videos.length - 1;
			}
			showVideo(_videos[prev]);
		}
		
		public function toTwoDigits(value: Number): String {
			return (value < 10) ? "0" + String(value) : String(value);
		}
	
		public function addListeners(objects: Array, type: String, func: Function): void {
			var i: int = objects.length;
			while (i--) {
				objects[i].addEventListener(type, func);
			}
		}
	}
}