package {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;

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
		public var _queue:LoaderMax;
		public var _track: MP3Loader;
		public var _video: VideoLoader;
		public var _mouseIsOver: Boolean;
		public var _isLoading:Boolean;
		public var _isStarted: Boolean;
		private var _silentMode: Boolean;
		private var _useTrack:Boolean;
		private var _isAutoPlay:Boolean;
		public var _isRelativePath:Boolean;
		public var _prependURL:String;
		public var _isDebugEnable: Boolean;
		private var _isTheEndReached: Boolean;

	
		public function Main() {
			
			loadParameters();
			_silentMode = false;
			_useTrack = false;
			_isStarted = false;
			_mouseIsOver = false;
			_isLoading = false;
			_isTheEndReached = false;
			stage.scaleMode = "noScale";
			
			initUI();
			initMonitor();
			registerInterface();
			
			if (_isAutoPlay) {
				stopAll();	
				startLoaderMax();
			}
		}
		
		function registerInterface():void {
			ExternalInterface.addCallback("playMovie", playSingleMovie);
			ExternalInterface.addCallback("playMultiMovies", playMultiMovies);
			ExternalInterface.addCallback("setBGM", setBGM);
		}
		
		function playSingleMovie(movieUrl:String, soundUrl:String=null):void {
			setVideoData([movieUrl]);
			setTrackData(soundUrl);
			stopAll();
			startLoaderMax();
		}

		function playMultiMovies(movieUrls:Array, soundUrl:String=null):void {
			setVideoData(movieUrls);
			setTrackData(soundUrl);
			stopAll();	
			startLoaderMax();
		}
		
		function setBGM(soundUrl:String):void {
			if (!_video || !_videos || !_videos.length){
				return;
			}
			setTrackData(soundUrl);
			stopAll();
			startLoaderMax();
		}
				
		function loadParameters():void {
			var params:Object = stage.loaderInfo.parameters;
			var debugEnable = params["debugEnable"] != undefined
			               ? params["debugEnable"] as String
			               : "false";
			_isDebugEnable = debugEnable == "true";
			
			var autoPlay = params["autoPlay"] != undefined
			             ? params["autoPlay"] as String
			             : "false";
			_isAutoPlay = autoPlay == "true";
			
			var relativePath = params["relativePath"] !=undefined
						     ? params["relativePath"] as String
			                 : "true"
			_isRelativePath = relativePath == "true";
			
			_prependURL = params["prependURL"] != undefined 
						? params["prependURL"] as String
						: "";
			
			var soundUrl = params["soundUrl"] != undefined 
						 ? params["soundUrl"] as String
			             : "";
			
			var movieUrls:Array = params["movieUrls"] != undefined
						   ? JSON.parse(params["movieUrls"]) as Array
						   : [];
			
			setTrackData(soundUrl);
			setVideoData(movieUrls);
		}
		
		function setTrackData(soundUrl:String):void {
			_trackData = soundUrl.length ? {
				url: soundUrl,
				vars: {
					name: "track",
					autoPlay:false,
					repeat: 1,
					estimateBytes: 9500
				}
			}: null;
		}
		
		function setVideoData(movieUrls:Array):void {

			_videoData = [];
			
			for(var i:int = 0; i < movieUrls.length; i++) {
				var vars:Object = {
					name:"movie_" + i, 
					width:640,
					height:360, 
					scaleMode:"proportionalInside", 
					centerRegistration:true, 
					alpha:1, 
					volume:0,
					autoPlay:false, 
					estimatedBytes:"654000"
				};
				
				_videoData.push({
					url: movieUrls[i],
					vars: vars
				});
			}			
		}

		function debug(msg:String):void {
			debugger.msgText.text = msg;
		}
	
		function stopAll():void {
			if (_track && !_track.paused){
				_track.paused = true;
				_track.unload();
			}
			
			if (_video && !_video.paused){
				_video.paused = true;
				_video.unload();
			}
				
			_silentMode = false;
			TweenMax.allTo([audioToggleButton, largePlayPauseButton, loadingAnim], 0, {
				autoAlpha: 0
			});
			
			audioToggleButton.setMute(_silentMode);
			largePlayPauseButton.setPaused(true);
			initMonitor();
		}
		
		function startLoaderMax(): void {
			if (_queue) {}
			
			_queue = new LoaderMax({
				name: "DataList",
				maxConnections:1,
				autoLoad: false,
				onProgress:loaderProgressHandler,
				onComplete:loaderCompleteHandler,
				onChildProgress:childLoaderProgressHandler,
				onChildComplete:childLoaderCompleteHandler
			});
						
			if (_trackData && _trackData.url.length) {
				_track = new MP3Loader(_trackData.url, _trackData.vars);
				_useTrack = true;
				_queue.append(_track);		
			} else {
				_useTrack = false;
				_track = null;
			}

			
			
			_videos.length = 0;
			var vl:VideoLoader = null;
			for each (var v in _videoData) {
				vl = new VideoLoader(v.url, v.vars); 
				_videos.push(vl);
				_queue.append(vl);
			}
			var msg:String = "input scenes " + _videos.length;
				msg += " / use sound " + (_useTrack ? "yes" : "no");
			    msg += " / path relative " + (_isRelativePath ? "yes": "no");
			debug(msg);
			
			if (_isRelativePath && _prependURL.length) {
				_queue.prependURLs(_prependURL);
			}
			
			_queue.load();
			startLoading();

		}	
		
		function startLoading():void {
			_isLoading = true;
			TweenMax.to([audioToggleButton, largePlayPauseButton], 0.3, {
				autoAlpha: 0
			});	
			
			TweenMax.to(loadingAnim, 0.3, {
				autoAlpha: 1,
				onComplete: loadingAnim.start
			});
			
		}
		
		function stopLoading():void {
			_isLoading = false;
			TweenMax.to(loadingAnim, 0.3, {
				autoAlpha: 0,
				onComplete: loadingAnim.stop
			});
		}
	
		function loaderProgressHandler(event:LoaderEvent):void {
			debugger.setTotalProgress(event.target.progress);
						
		}
		
		function loaderCompleteHandler(event:LoaderEvent): void {
			showVideo(_videos[0]);
			stopLoading();
		}
		
		function childLoaderProgressHandler(event:LoaderEvent): void {
			debugger.setChildProgress(event.target.progress);
		}
		
		function childLoaderCompleteHandler(event:LoaderEvent): void {
		}

		function showVideo(video: VideoLoader): void {

			if (video == _video && _video.playProgress == 0) {
				return;
			}
			
			// The firstime
			if (_video == null && !_isStarted) {
				
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

				stopLoading();

				TweenMax.to(_video.content, 0.0, {
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
				
				startLoading();
			}

			//start playing the video from its beginning
			_video.gotoVideoTime(0, true);
			largePlayPauseButton.setPaused(false);

			//always start with the volume at 0, and fade it up to 1 if necessary.
			_video.volume = 0;

            //only seek time to zero if first time play or video index = 0
			var _videoIndex = _videos.indexOf(_video);
			if (!_isStarted || _videoIndex == 0) {
				_isStarted = true;
				
				if (_track && _useTrack) {
					_track.gotoSoundTime(0, true);
					_track.volume = 0;
					audioToggleButton.setMute(_silentMode);
					if (!_silentMode) {
						TweenMax.to(_track, 0.8, {
							volume: 1
						});
					}
				}
			}

			videoContainer.addChild(_video.content);

			TweenMax.to(_video.content, 0.0, {
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

		function initMonitor(): void {
			trace("isDebug: " + _isDebugEnable);
			if (!_isDebugEnable) {
				debugger.visible = false;
				return;
			}
			debugger.visible = true;
			debugger.videoIdText.text = "--";
		}

		function updateMonitor(): void {
			if (!_isDebugEnable)
				return;

			var videoIndex = _videos.indexOf(_video) + 1;
			var inforText = videoIndex + " / " + _videos.length;
			debugger.videoIdText.text = inforText;
		}

		function initUI(): void {
			loadingAnim.mouseEnabled = false;
			audioToggleButton.blendMode = "layer";
			largePlayPauseButton.blendMode = "layer";

			TweenMax.allTo([audioToggleButton, largePlayPauseButton, loadingAnim], 0, {
				autoAlpha: 0
			});
			audioToggleButton.setMute(_silentMode);
			largePlayPauseButton.setPaused(true);
		}


		function updateDownloadProgress(event: LoaderEvent = null): void {
			
		}

		function bufferFullHandler(event: LoaderEvent): void {
			stopLoading();
		}

		function updatePlayProgress(event: LoaderEvent = null): void {
			debugger.setPlayProgress(_video.videoTime);
		}

		function refreshTotalTime(event: LoaderEvent = null): void {
			debugger.setTotalTime(_video.duration);
		}

		function activateUI(): void {

			addListeners([audioToggleButton, videoContainer, largePlayPauseButton], MouseEvent.ROLL_OVER, showControlUI);
			addListeners([audioToggleButton, videoContainer, largePlayPauseButton], MouseEvent.ROLL_OUT, hideControlUI);
			
			var butons = [largePlayPauseButton];
			addListeners(butons, MouseEvent.CLICK, togglePlayPause);
			audioToggleButton.addEventListener(MouseEvent.CLICK, toggleAudio);
			
		}
		
		function showControlUI(event: MouseEvent): void {
			if (_isLoading) return;
			TweenMax.allTo([audioToggleButton, largePlayPauseButton], 0.3, {
					autoAlpha: 1
			});
		}
		
		function hideControlUI(event: MouseEvent):void {
			if (_isLoading || (_video && _video.videoPaused)) return;
			TweenMax.to([audioToggleButton, largePlayPauseButton], 0.3, {
				autoAlpha: 0
			});	
		}

		function toggleAudio(event: MouseEvent): void {
			if (!_useTrack || !_track){
				return;
			}
			_silentMode = !_silentMode;
			audioToggleButton.setMute(_silentMode);
			if (_silentMode) {
				_track.volume = 0;
			} else {
				_track.volume = 1;
			}
		}
		
		function togglePlayPause(event: MouseEvent = null): void {
			if (_isTheEndReached) {
				rePlay();
				return
			}
			
			_video.videoPaused = !_video.videoPaused;
			largePlayPauseButton.setPaused(_video.videoPaused);
			
			if (_video.videoPaused) {
				if (_useTrack && _track){
					_track.soundPaused = true;
				}

				
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
				if (_useTrack && _track){
					_track.soundPaused = false;

				}
			
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
		
		function rePlay(): void {
			_isTheEndReached = false;
			largePlayPauseButton.setPaused(false);
		
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
			
			showVideo(_videos[0]);			
		}
		
		function goTheEnd(): void {
			_isTheEndReached = true;
			_video.videoPaused = true;
			largePlayPauseButton.setPaused(true);

			if (_useTrack && _track){
				_track.soundPaused = true;
			}

			TweenMax.allTo([audioToggleButton, largePlayPauseButton], 0.3, {
				autoAlpha: 1
			});
			
			TweenMax.to(videoContainer, 0.3, {
				blurFilter: {
					blurX: 6,
					blurY: 6
				},
				colorMatrixFilter: {
					brightness: 0.5
				}
			});

		}

		function nextVideo(event: Event): void {
			var next: int = _videos.indexOf(_video) + 1;
			if (next >= _videos.length) {
				goTheEnd();
				return;
			}
			showVideo(_videos[next]);
		}

		function previousVideo(event: Event): void {
			var prev: int = _videos.indexOf(_video) - 1;
			if (prev < 0) {
				prev = _videos.length - 1;
			}
			showVideo(_videos[prev]);
		}
	
		function addListeners(objects: Array, type: String, func: Function): void {
			var i: int = objects.length;
			while (i--) {
				objects[i].addEventListener(type, func);
			}
		}
	}
}