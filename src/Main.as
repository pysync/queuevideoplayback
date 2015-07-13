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
		
		// data
		public var _videoData: Array = [
			{ url:"movie14.mp4", vars: {name:"V_0", width:320,height:240, scaleMode:"proportionalInside", centerRegistration:true, alpha:1 , autoPlay:false , estimatedBytes:"8887418" }},
			{ url:"movie21.mp4", vars: {name:"V_1", width:320,height:240, scaleMode:"proportionalInside", centerRegistration:true, alpha:1 , autoPlay:false,  estimatedBytes:"14602065"}},
			{ url:"movie30.mp4", vars: {name:"V_2", width:320,height:240, scaleMode:"proportionalInside", centerRegistration:true, alpha:1 , autoPlay:false,  estimatedBytes:"37803458"}},
			{ url:"movie32.mp4", vars: {name:"V_3", width:320,height:240, scaleMode:"proportionalInside", centerRegistration:true, alpha:1 , autoPlay:false,  estimatedBytes:"37803458"}},
			{ url:"movie34.mp4", vars: {name:"V_4", width:320,height:240, scaleMode:"proportionalInside", centerRegistration:true, alpha:1 , autoPlay:false,  estimatedBytes:"37803458"}},
			{ url:"movie35.mp4", vars: {name:"V_5", width:320,height:240, scaleMode:"proportionalInside", centerRegistration:true, alpha:1 , autoPlay:false,  estimatedBytes:"37803458"}}
		];
				
		public var _thumbs:Array = [
			"http://vignette2.wikia.nocookie.net/swordartonline/images/e/ee/Yui.png/revision/latest/scale-to-width-down/275?cb=20140228061052",
			"http://vignette4.wikia.nocookie.net/swordartonline/images/a/a9/Sao-kirito-asuna-yui-family.png/revision/latest/scale-to-width-down/212?cb=20150705222747",
			"http://vignette2.wikia.nocookie.net/swordartonline/images/6/6b/LS_Concert_Event.png/revision/latest/scale-to-width-down/212?cb=20150611103807",
			"http://vignette2.wikia.nocookie.net/swordartonline/images/7/7e/LS_Seven_and_Sinon_2.png/revision/latest/scale-to-width-down/212?cb=20150611103552",
			"http://vignette4.wikia.nocookie.net/swordartonline/images/7/7a/LS_Asuna_event.png/revision/latest/scale-to-width-down/212?cb=20150610200221",
			"http://vignette2.wikia.nocookie.net/swordartonline/images/e/ef/Karatachi_Nijika.png/revision/latest/scale-to-width-down/212?cb=20150610194924",
			"http://vignette1.wikia.nocookie.net/swordartonline/images/a/a9/LS_Characters.png/revision/latest/scale-to-width-down/212?cb=20150610193407",
			"http://vignette4.wikia.nocookie.net/swordartonline/images/4/4c/LS_Sumeragi_vs_Kirito.png/revision/latest/scale-to-width-down/212?cb=20150610190729",
			"http://vignette2.wikia.nocookie.net/swordartonline/images/c/ca/LS_Aftermath.png/revision/latest/scale-to-width-down/212?cb=20150610193123"
		];
		
		public var _hostName = "http://localhost:5000";
		public var _todayMovieAPi = "http://localhost:5000/api/movies";
		public var defaultThumb = "http://localhost:5000/assets/default_thumb.png";
				
		// keep track last loaded url list data
		public var urlDataList:Object = [];

		// keep track current video in queue
		public var movieInQueue:Array = new Array();
		
		public var _videoPrependURLs = "assets/";  
		
		public var trackData: Array = [
			{ url: "music01.mp3", title: "Hello world", vars: {name:"T_0", autoPlay:false, repeat:-1} },
			{ url: "music01.mp3", title: "What You Are", vars: {name:"T_1", autoPlay:false, repeat:-1} },
			{ url: "music01.mp3", title: "By your coll", vars: {name:"T_1", autoPlay:false, repeat:-1} }
		];  
			
		public var _trackPrependURLs = "assets/";                               
		
		//an array containing the VideoLoaders in the order they should be played
		public var _videos: Array = [];

		//an array containing the Mp3Loaders in the order they should be played
		public var _tracks: Array = [];

		//keeps track of the VideoLoader that is currently playing
		public var _currentVideo: VideoLoader;

		// keeps track of the Mp3Loader that is currently playing
		public var _currentTrack: MP3Loader;

		// keeps track selected sound index
		public var _trackIndex: int;

		//if true, the mouse is over the video or UI controls
		public var _mouseIsOver: Boolean;

		//If true, the audio has been muted
		public var _silentMode: Boolean;

		//If true, the background music há been muted
		public var _silentModeBG: Boolean;

		//where is play started
		public var _isStarted: Boolean

		//tracks whether or not the video was paused when the user moused-down on the scrubber. We must pause for scrubbing, but this tells us whether or not to playVideo() when the user releases the mouse. 
		public var _preScrubPaused: Boolean;

		//DEBUG FLAG
		public var _isDebugEnable: Boolean;

	
		public function Main() {

			
			loadTodayMovieUrlList();
			
			
			// clear UI - !importance!
			queueMovieListPanel.removeChildren(0);
			queueMusicListPanel.setup(this);
			
			_silentMode = true;
			_isStarted = false;
			_isDebugEnable = true;
			stage.scaleMode = "noScale";
			
			initUI();
			initMonitor();
			activateUI();
			
			startTrackLoaderMax();
			startVideoLoaderMax();
			
			loadingAnim.alpha = 1;
		}

		// ============================================ I: Loading Data List Use for build Available Movie List =================================
		
		// - entry point will fire event process
		public function loadTodayMovieUrlList(): void {
			var _jsonLoader:URLLoader = new URLLoader();
			_jsonLoader.load(new URLRequest(_todayMovieAPi));
			_jsonLoader.addEventListener(Event.COMPLETE, onTodayMovieUrlLoaded);
			_jsonLoader.addEventListener(IOErrorEvent.IO_ERROR, onTodayMovieUrlLoadError);
		} 
		
		// TODO: notify to user to retry load
		public function onTodayMovieUrlLoadError(e:IOErrorEvent):void {
			
			trace("processTodayMovieLoadError: " + e);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, onTodayMovieUrlLoadError);
		}
		
		// - process loaded url data and setup available movie list
		// - store loaded url data movie list
		
		// TODO: fix for match data type in response of api 
		public function onTodayMovieUrlLoaded(e:Event):void {
			
			var rawJson:String = e.target.data;
			//trace(rawJson);
			
			urlDataList = JSON.parse(rawJson);
			//trace(urlList);
			
			// in this example, response is array!
			if (urlDataList && urlDataList.length > 0 ){
				//trace("response data list have length: " + urlList.length);
				setupListMoviePanel();
			}
			else {
				// TODO: handler when cannot parse data
			}
		}
		
		// setup list of available movies & set hanler action:
		// 1: play preview movie
		// 2: add movie to queue
		// 3: scroll to load more movie
		
		public function setupListMoviePanel():void {
		
			var columns:int = 3;
			var rows:int = int(urlDataList.length / columns);
			var alignX = 100;
			var alignY = 50;
			var thumbW = 140;
			var thumbH = 100;

			var contentHeight = rows * (thumbH + alignY);
			var contentWidth = columns * thumbW;
			
			var listContent:MovieClip = new MovieClip();
			listContent.graphics.beginFill(0xFFFFFF, 1);
			listContent.graphics.drawRect(0, 0, contentWidth, contentHeight); 
            listContent.graphics.endFill();  
			listContent.x = listContent.y = 0;
			
			listMoviePanel.listPanel.source = listContent;
			var queue:LoaderMax = new LoaderMax();
			
			for(var i:int = 0; i < urlDataList.length; i++) {
				
				var video:VideoItem = new VideoItem(this, i);
				video.x = alignX + (i % columns) * thumbW;
				video.y = alignY + int(i / columns) * thumbH;
				listContent.addChild(video);
				queue.append(video.createThumbImageLoader());
			}
			queue.load();
		}
		
		//Utils function
		public function force2Digits(value: Number): String {
			return (value < 10) ? "0" + String(value) : String(value);
		}
		
		//Utils function
		public function dragEffect():void {
			var newColor:ColorTransform = new ColorTransform();
			newColor.color = 0xFF0000;
			dragFrameSlot.border.transform.colorTransform = newColor;
		}


		
		public function startLoaderMaxXML(): void {
			LoaderMax.activate([XMLLoader, VideoLoader, MP3Loader]);
			var xmlLoader: XMLLoader = new XMLLoader("xml/videoList.xml", {
				name: "videoList",
				onComplete: xmlHandler
			});
			xmlLoader.load();
		}
		
		public function startTrackLoaderMax(): void {
			var trackQueue:LoaderMax = new LoaderMax({
				name: "trackDataList",
				maxConnections:1,
				onProgress:trackLoaderProgressHandler,
				onComplete:trackLoaderCompleteHandler,
				onChildProgress:childTrackLoaderProgressHandler,
				onChildComplete:childTrackLoaderCompleteHandler
			});

			
			for(var i = 0; i < trackData.length; i++) {
				trackQueue.append(new MP3Loader(trackData[i].url, trackData[i].vars))
			}
			
			trackQueue.prependURLs("assets/");
			trackQueue.load();
			_tracks = trackQueue.getChildren();
		}
		
		public function startVideoLoaderMax(): void {
			var videoQueue:LoaderMax = new LoaderMax({
				name: "videoDataList",
				maxConnections:1,
				onProgress:videoLoaderProgressHandler,
				onComplete:videoLoaderCompleteHandler,
				onChildProgress:childVideoLoaderProgressHandler,
				onChildComplete:childVideoLoaderCompleteHandler
			});
			
			for(var j = 0; j < _videoData.length; j++) {
				videoQueue.append(new VideoLoader(_videoData[j].url, _videoData[j].vars));
			}
			videoQueue.prependURLs("assets/");
			videoQueue.load();
			_videos = videoQueue.getChildren();
		}	
		
		public function trackLoaderProgressHandler(event:LoaderEvent):void {
			loadingAnim.totalPercentText.text = "Total: " +  Math.round(event.target.progress * 100).toString() + " %";
						
		}
		
		public function trackLoaderCompleteHandler(event:LoaderEvent): void {
			loadingAnim.totalPercentText.text = "Total: DONE!";
			
			showVideo(_videos[0]);
		}
		
		public function childTrackLoaderProgressHandler(event:LoaderEvent): void {
			loadingAnim.childPercentText.text = "Child: " +  Math.round(event.target.progress * 100).toString() + " %";
		}
		
		public function childTrackLoaderCompleteHandler(event:LoaderEvent): void {
			loadingAnim.childPercentText.text = "Child: DONE!"
		}

		public function videoLoaderProgressHandler(event:LoaderEvent):void {
			loadingAnim.totalPercentText.text = "Total: " +  Math.round(event.target.progress * 100).toString() + " %";
						
		}
		
		public function videoLoaderCompleteHandler(event:LoaderEvent): void {
			loadingAnim.totalPercentText.text = "Total: DONE!";
		}
		
		public function childVideoLoaderProgressHandler(event:LoaderEvent): void {
			loadingAnim.childPercentText.text = "Child: " +  Math.round(event.target.progress * 100).toString() + " %";
		}
		
		public function childVideoLoaderCompleteHandler(event:LoaderEvent): void {
			loadingAnim.childPercentText.text = "Child: DONE!"
		}

		public function xmlHandler(event: LoaderEvent): void {

			var trackQueue: LoaderMax = LoaderMax.getLoader("trackListLoader");
			_tracks = trackQueue.getChildren();
			trackQueue.load();

			//get the LoaderMax named "videoListLoader" which was inside our XML
			var videoQueue: LoaderMax = LoaderMax.getLoader("videoListLoader");

			//store the nested VideoLoaders in an array
			_videos = videoQueue.getChildren();

			//start loading the queue of VideoLoaders (they will load in sequence)
			videoQueue.load();

			//show the first video
			showVideo(_videos[0]);
		}

		public function getSelectedTrack(): MP3Loader {
			if (_trackIndex >= 0 && _trackIndex < _tracks.length)
				return _tracks[_trackIndex];
			return _tracks[0];
		}

		public function showVideo(video: VideoLoader): void {

			//if the new video is the one that's currently showing, do nothing.
			if (video == _currentVideo) {
				return;
			}

			//The first time through, the _currentVideo will be null. That's when we need to activate the user interface
			if (_currentVideo == null) {
				activateUI(); //don't activate the UI until the first video is ready. This avoids errors when _currentVideo is null.
			} else {

				//remove the event listeners from the _currentVideo (which is now the old one that will be replaced)
				_currentVideo.removeEventListener(LoaderEvent.PROGRESS, updateDownloadProgress);
				_currentVideo.removeEventListener(VideoLoader.VIDEO_COMPLETE, nextVideo);
				_currentVideo.removeEventListener(VideoLoader.PLAY_PROGRESS, updatePlayProgress);
				_currentVideo.removeEventListener(VideoLoader.VIDEO_BUFFER_FULL, bufferFullHandler);
				_currentVideo.removeEventListener(LoaderEvent.INIT, refreshTotalTime);

				//If the video is paused, we should togglePlayPause() so that the new video plays and the interface matches.
				if (_currentVideo.videoPaused) {
					togglePlayPause();
				}

				//fade out the preloader and then stop() it. If the new video needs to display the preloader, that's okay because the fade-in tween we create later will overwrite this one.
				TweenMax.to(loadingAnim, 0.3, {
					autoAlpha: 0,
					onComplete: loadingAnim.stop
				});

				//fade the current (old) video's alpha out. Remember the VideoLoader's "content" refers to the ContentDisplay Sprite we see on the screen.
				TweenMax.to(_currentVideo.content, 0.8, {
					autoAlpha: 0
				});

				//fade the current (old) video's volume down to zero and then pause the video (it will be invisible by that time).
				TweenMax.to(_currentVideo, 0.8, {
					volume: 0,
					onComplete: _currentVideo.pauseVideo
				});
			}

			//now swap the _currentLoader variable so it refers to the new video.
			_currentVideo = video;

			//listen for PROGRESS events so that we can update the currentLoadingBar's scaleX accordingly
			_currentVideo.addEventListener(LoaderEvent.PROGRESS, updateDownloadProgress);

			//listen for a VIDEO_COMPLETE event so that we can automatically advance to the next video.
			_currentVideo.addEventListener(VideoLoader.VIDEO_COMPLETE, nextVideo);

			//listen for PLAY_PROGRESS events so that we can update the currentProgressBar's scaleX accordingly
			_currentVideo.addEventListener(VideoLoader.PLAY_PROGRESS, updatePlayProgress);

			//if the video hasn't fully loaded yet and is still buffering, show the preloader
			if (_currentVideo.progress < 1 && _currentVideo.bufferProgress < 1) {

				//when the buffer fills, we'll fade out the preloader
				_currentVideo.addEventListener(VideoLoader.VIDEO_BUFFER_FULL, bufferFullHandler);

				//prioritizing the video ensures that it moves to the top of the LoaderMax gueue and any other loaders that were loading are canceled to maximize bandwidth available for the new video.
				_currentVideo.prioritize(true);

				//play() the preloader and fade its alpha up.
				loadingAnim.play();
				TweenMax.to(loadingAnim, 0.3, {
					autoAlpha: 1
				});
			}

			//start playing the video from its beginning
			_currentVideo.gotoVideoTime(0, true);

			//always start with the volume at 0, and fade it up to 1 if necessary.
			_currentVideo.volume = 0;
			if (!_silentMode) {
				TweenMax.to(_currentVideo, 0.8, {
					volume: 1
				});
			}
            
            //only seek time to zero if first time play or video index = 0
			var _videoIndex = _videos.indexOf(_currentVideo);
			if (!_isStarted || _videoIndex == 0) {
				_isStarted = true;
			
				_currentTrack = getSelectedTrack();
				_currentTrack.gotoSoundTime(0, true);
				
				_currentTrack.volume = 0;
				if (!_silentModeBG){
					TweenMax.to(_currentTrack, 0.8, {
						volume: 1
					});
				}
			}

			//when we addChild() the VideoLoader's content, it makes it rise to the top of the stacking order
			videoContainer.addChild(_currentVideo.content);

			//fade the VideoLoader's content alpha in. Remember, the "content" refers to the ContentDisplay Sprite that we see on the stage.
			TweenMax.to(_currentVideo.content, 0.8, {
				autoAlpha: 1
			});

			//update the total time display
			refreshTotalTime();

			//if the VideoLoader hasn't received its metaData yet (which contains duration information), we should set up a listener so that the total time gets updated when the metaData is received.
			if (_currentVideo.metaData == null) {
				_currentVideo.addEventListener(LoaderEvent.INIT, refreshTotalTime);
			}

			//update the currentProgressBar and currentLoadingBar
			updateDownloadProgress();
			updatePlayProgress();
            
            //update DEBUG
			updateMonitor();
		}

		public function initMonitor(): void {
			if (!_isDebugEnable)
				return;

			var videoIndex = _videos.indexOf(_currentVideo);
			var trackIndex = _tracks.indexOf(_currentTrack);

			debugger.videoIdText.text = "scene: --";
			debugger.trackIdText.text = "track: --";
		}

		public function updateMonitor(): void {
			if (!_isDebugEnable)
				return;

			var videoIndex = _videos.indexOf(_currentVideo);
			var trackIndex = _tracks.indexOf(_currentTrack);

			debugger.videoIdText.text = "scene: " + videoIndex;
			debugger.trackIdText.text = "track: " + trackIndex;
		}

		public function initUI(): void {

			//ignore mouse interaction with currentProgressBar so that clicks pass through to the currentLoadingBar whose listener handles skipping the video to that spot.
			controlBar.currentProgressBar.mouseEnabled = false;

			//ignore mouse interaction with loadingAnim
			loadingAnim.mouseEnabled = false;

			//the "layer" blendMode makes the alpha fades cleaner (overlapping objects don't add alpha levels)
			controlBar.blendMode = "layer";

			//set the progress and loading bars and the scrubber to the very beginning
			controlBar.currentProgressBar.width = controlBar.currentLoadingBar.width = 0;
			controlBar.seekTimeAnchor.x = controlBar.currentProgressBar.x;

			//initially hide the user interface - autoAlpha:0 sets alpha to 0 and visible to false.
			TweenMax.allTo([controlBar, playLargeButton, loadingAnim], 0, {
				autoAlpha: 0
			});
		}

		public function addListeners(objects: Array, type: String, func: Function): void {
			var i: int = objects.length;
			while (i--) {
				objects[i].addEventListener(type, func);
			}
		}

		public function updateDownloadProgress(event: LoaderEvent = null): void {
			controlBar.currentLoadingBar.scaleX = _currentVideo.progress;
		}

		public function bufferFullHandler(event: LoaderEvent): void {
			TweenMax.to(loadingAnim, 0.3, {
				autoAlpha: 0,
				onComplete: loadingAnim.stop
			});
		}



		public function updatePlayProgress(event: LoaderEvent = null): void {
			var time: Number = _currentVideo.videoTime;
			var minutes: String = force2Digits(int(time / 60));
			var seconds: String = force2Digits(int(time % 60));
			controlBar.currentTimeText.text = minutes + ":" + seconds;
			controlBar.currentProgressBar.scaleX = _currentVideo.playProgress;
			controlBar.seekTimeAnchor.x = controlBar.currentProgressBar.x + controlBar.currentProgressBar.width;

		}

		public function refreshTotalTime(event: LoaderEvent = null): void {
			var minutes: String = force2Digits(int(_currentVideo.duration / 60));
			var seconds: String = force2Digits(int(_currentVideo.duration % 60));
			controlBar.totalTimeText.text = minutes + ":" + seconds;
		}

		public function activateUI(): void {

			addListeners([controlBar, videoContainer, playLargeButton], MouseEvent.ROLL_OVER, toggleControlUI);
			addListeners([controlBar, videoContainer, playLargeButton], MouseEvent.ROLL_OUT, toggleControlUI);
			addListeners([controlBar.playButton, playLargeButton, videoContainer], MouseEvent.CLICK, togglePlayPause);
			controlBar.seekTimeAnchor.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownScrubber);
			controlBar.currentLoadingBar.addEventListener(MouseEvent.CLICK, scrubToMouse);
			controlBar.soundButtonOn.addEventListener(MouseEvent.CLICK, toggleAudio);
			controlBar.nextButton.addEventListener(MouseEvent.CLICK, nextVideo);
			controlBar.previousButton.addEventListener(MouseEvent.CLICK, previousVideo);
			
			var controls:Array = [controlBar.playButton, 
								  playLargeButton, 
								  controlBar.previousButton, 
								  controlBar.nextButton, 
								  controlBar.soundButtonOn, 
								  controlBar.seekTimeAnchor];
			var i:int = controls.length;
			while (i--) {
			    //controls[i].buttonMode = true;
			    //controls[i].mouseChildren = false;
			}
			
			addListeners([controlBar.previousButton, controlBar.soundButtonOn, controlBar.nextButton], MouseEvent.ROLL_OVER, blackRollOverHandler);
			addListeners([controlBar.previousButton, controlBar.soundButtonOn, controlBar.nextButton], MouseEvent.ROLL_OUT, blackRollOutHandler);
			controlBar.playButton.addEventListener(MouseEvent.ROLL_OVER, growPlayPause);
			controlBar.playButton.addEventListener(MouseEvent.ROLL_OUT, shrinkPlayPause);
		}
		
		public function blackRollOverHandler(event:MouseEvent):void {
		    //TweenMax.to(event.target.label, 0.3, {tint:0xFFFFFF});
		}

		public function blackRollOutHandler(event:MouseEvent):void {
		    //TweenMax.to(event.target.label, 0.3, {tint:null});
		}
		
		public function growPlayPause(event:MouseEvent):void {
		    TweenMax.to(event.target, 0.2, {scaleX:1.3, scaleY:1.3});
		}

		public function shrinkPlayPause(event:MouseEvent):void {
		    TweenMax.to(event.target, 0.2, {scaleX:1, scaleY:1});
		}

		public function mouseDownScrubber(event: MouseEvent): void {
			_preScrubPaused = _currentVideo.videoPaused;
			_currentVideo.videoPaused = true;
			controlBar.seekTimeAnchor.startDrag(false, new Rectangle(controlBar.currentLoadingBar.x, controlBar.currentLoadingBar.y, controlBar.currentLoadingBar.width, 0));
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpScrubber);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, scrubToMouse);
		}

		public function scrubToMouse(event: MouseEvent): void {
			controlBar.currentProgressBar.width = controlBar.mouseX - controlBar.currentProgressBar.x;
			_currentVideo.playProgress = controlBar.currentProgressBar.scaleX;
		}

		public function mouseUpScrubber(event: MouseEvent): void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpScrubber);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, scrubToMouse);
			controlBar.seekTimeAnchor.stopDrag();
			_currentVideo.videoPaused = _preScrubPaused;
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
				_currentVideo.volume = 0;
				//controlBar.audio_mc.label.gotoAndStop("off");
			} else {
				_currentVideo.volume = 1;
				//controlBar.audio_mc.label.gotoAndStop("on");
			}
		}

		public function toggleBGSoundTrack(event: MouseEvent): void {
			_silentModeBG = !_silentModeBG;
			if (_silentModeBG) {
				_currentTrack.volume = 0;
			} else {
				_currentTrack.volume = 1;
			}
		}

		public function togglePlayPause(event: MouseEvent = null): void {
			_currentVideo.videoPaused = !_currentVideo.videoPaused;
			if (_currentVideo.videoPaused) {
				TweenMax.to(playLargeButton, 0.3, {
					autoAlpha: 1
				});
				//controlBar.playPauseButton_mc.gotoAndStop("paused");
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
				TweenMax.to(playLargeButton, 0.3, {
					autoAlpha: 0
				});
				//controlBar.playPauseButton_mc.gotoAndStop("playing");
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
			var next: int = _videos.indexOf(_currentVideo) + 1;
			if (next >= _videos.length) {
				next = 0;
			}
			showVideo(_videos[next]);
		}

		public function previousVideo(event: Event): void {
			var prev: int = _videos.indexOf(_currentVideo) - 1;
			if (prev < 0) {
				prev = _videos.length - 1;
			}
			showVideo(_videos[prev]);
		}
		
	}
}