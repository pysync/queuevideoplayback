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
	import flash.events.VideoEvent;
	

	
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
		public var _isUIInitialized: Boolean;
		private var _silentMode: Boolean;
		private var _useTrack:Boolean;
		private var _isAutoPlay:Boolean;
		public var _isRelativePath:Boolean;
		public var _prependURL:String;
		public var _isDebugEnable: Boolean;
		private var _isTheEndReached: Boolean;

	
		public function Main() {
			
			loadParameters();
			_isUIInitialized = false;
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
			var debugEnable = params["__DEBUG__"] != undefined
			               ? params["__DEBUG__"] as String
			               : "true";
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


			//setDummyData();
		}
		
		function setDummyData():void {
			_isDebugEnable = true;
			_isAutoPlay = true;
			_silentMode = false;

			trace("setDummyData: " + _isDebugEnable);

			var soundUrl = "bgm01.mp3";
			//var movieUrls = ["dump1.mp4", "dump2.mp4", "dump3.mp4", "dump4.mp4","dump5.mp4", "dump6.mp4"];
			var movieUrls = [
			  "scene_0001.mp4",
			  "scene_0002.mp4",
			  "scene_0003.mp4",
			  "scene_0004.mp4"
			];

			_isRelativePath = true;
			_prependURL = "../assets/";

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
					x: -320, 
					y: -180,
					name:"movie_" + i, 
					container:videoContainer, 
					width:640, 
					height:360, 
					scaleMode:"None", 
					//centerRegistration: true,
					requireWithRoot:videoContainer, 
					bgColor:0x000000,
					alpha:0, 
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
			
			_isStarted = false;

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

			TweenMax.to(videoContainer, 0.0, {
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
				var trackUrl = _trackData.url
				if (_isRelativePath && _prependURL.length) {
					trackUrl = _prependURL + trackUrl;
				}
				_track = new MP3Loader(trackUrl, _trackData.vars);
				_useTrack = true;
				_track.prioritize(true);
				_track.load();
				_track.addEventListener(LoaderEvent.COMPLETE, onTrackLoadComplete);

				// _queue.append(_track);		
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
		
		function onTrackLoadComplete(event:LoaderEvent):void {
			if (_useTrack && event.target == _track) {
				if (!_isStarted) {
					stopLoading();
					showVideo(_videos[0]);
				}
			}
		}

		function loaderProgressHandler(event:LoaderEvent):void {
			debugger.setTotalProgress(event.target.progress);	
		}
		
		function loaderCompleteHandler(event:LoaderEvent): void {
			stopLoading();
		}
		
		function childLoaderProgressHandler(event:LoaderEvent): void {
			debugger.setChildProgress(event.target.progress);

			if (!_isStarted && event.target.progress >= 0.25){
				if (!_useTrack && event.target != _track) {
					stopLoading();
					showVideo(_videos[0]);
				}
			}
			
			if (_isStarted && event.target == _video){
			
				// handle when video loading..
				if (_video && _video.progress < 1) {
					if (_video.bufferProgress < _video.playProgress + 0.1){
						if (!_isLoading) startLoading();
					}else {
						if (_isLoading) stopLoading();
					}
				}	
			}
		}
		
		function childLoaderCompleteHandler(event:LoaderEvent): void {
			trace("child load onComplete");
		}

		function showVideo(video: VideoLoader, replay:Boolean = false): void {

			if (!replay && video == _video) {
				return;
			}			
			
			// The firstime
			if (_video == null && !_isUIInitialized) {
				activateUI(); 
			} 
			else {


				_video.removeEventListener(LoaderEvent.PROGRESS, updateDownloadProgress);
				_video.removeEventListener(VideoLoader.PLAY_PROGRESS, updatePlayProgress);
				_video.removeEventListener(VideoLoader.VIDEO_BUFFER_FULL, bufferFullHandler);
				_video.removeEventListener(VideoLoader.VIDEO_COMPLETE, nextVideo);
				_video.removeEventListener(LoaderEvent.INIT, refreshTotalTime);
				_video.removeEventListener(VideoLoader.VIDEO_PLAY, videoPlayHandler);
				_video.removeEventListener(VideoLoader.VIDEO_PAUSE, videoPauseHandler);

				stopLoading();

				TweenMax.to(_video.content, 0.0, {
					autoAlpha: 0
				});	
			}
			
			_video = video;
			_video.addEventListener(LoaderEvent.PROGRESS, updateDownloadProgress);
			_video.addEventListener(VideoLoader.VIDEO_COMPLETE, nextVideo);
			_video.addEventListener(VideoLoader.PLAY_PROGRESS, updatePlayProgress);	
			_video.addEventListener(VideoLoader.VIDEO_PLAY, videoPlayHandler);
			_video.addEventListener(VideoLoader.VIDEO_PAUSE, videoPauseHandler);
			
			
			if (_video.progress < 1 && _video.bufferProgress < 0.25) {

				_video.addEventListener(VideoLoader.VIDEO_BUFFER_FULL, bufferFullHandler);
				_video.prioritize(true);
				
				startLoading();
			}

			//always start with the volume at 0, and fade it up to 1 if necessary.
			_video.volume = 0;

			//start playing the video from its beginning
			_video.gotoVideoTime(0, true);
			largePlayPauseButton.setPaused(false);

			

            //only seek time to zero if first time play or video index = 0
			var _videoIndex = _videos.indexOf(_video);
			if (!_isStarted || _videoIndex == 0) {
				
				_isStarted = true;
				var trackAvailable = _track && _useTrack;
				audioToggleButton.setState(trackAvailable, _silentMode);
				
				if (trackAvailable) {
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

			//videoContainer.addChild(_video.content);
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
		
		function videoPlayHandler(event: LoaderEvent):void {
			if (!_video.videoPaused){
				if (_useTrack && _track){
					_track.soundPaused = false;
				}
			}
		}
		
		function videoPauseHandler(event: LoaderEvent):void {
			if (_video.videoPaused) {
				if (_useTrack && _track){
					_track.soundPaused = true;
				}
			}
		}
		

		function updatePlayProgress(event: LoaderEvent = null): void {
			debugger.setPlayProgress(_video.videoTime);

			if (_isStarted){
			
				// handle when video loading..
				if (_video && _video.progress < 1) {
					if (_video.bufferProgress < _video.playProgress + 0.1){
						if (!_isLoading) startLoading();
					}else {
						if (_isLoading) stopLoading();
					}
				}	
			}
		}

		function refreshTotalTime(event: LoaderEvent = null): void {
			debugger.setTotalTime(_video.duration);
		}

		function activateUI(): void {
			_isUIInitialized = true;
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
			showVideo(_videos[0], true);			
		}
		
		function goTheEnd(): void {
			_isTheEndReached = true;
			
			largePlayPauseButton.setPaused(true);

			if (_useTrack && _track){
				_track.playProgress = 0;
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
			
			for (var i:int = 0; i < _videos.length; i++) {
				var video:VideoLoader = _videos[i];
				if (video != _video) {
					TweenMax.to(video.content, 0.0, {
						autoAlpha: 0
					});	
				}
				_video.videoPaused = true;
				video.videoTime = 0;
				video.playProgress = 0;
			}
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