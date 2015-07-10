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
	

	
	public class Main extends MovieClip {
		
		// data
		private var _videoData: Array = [
			{ url:"movie14.mp4", vars: {name:"V_0", width:480,height:320, scaleMode:"proportionalInside", centerRegistration:true, alpha:1 , autoPlay:false , estimatedBytes:"8887418" }},
			{ url:"movie21.mp4", vars: {name:"V_1", width:480,height:320, scaleMode:"proportionalInside", centerRegistration:true, alpha:1 , autoPlay:false,  estimatedBytes:"14602065"}},
			{ url:"movie30.mp4", vars: {name:"V_2", width:480,height:320, scaleMode:"proportionalInside", centerRegistration:true, alpha:1 , autoPlay:false,  estimatedBytes:"37803458"}},
			{ url:"movie32.mp4", vars: {name:"V_3", width:480,height:320, scaleMode:"proportionalInside", centerRegistration:true, alpha:1 , autoPlay:false,  estimatedBytes:"37803458"}},
			{ url:"movie34.mp4", vars: {name:"V_4", width:480,height:320, scaleMode:"proportionalInside", centerRegistration:true, alpha:1 , autoPlay:false,  estimatedBytes:"37803458"}},
			{ url:"movie35.mp4", vars: {name:"V_5", width:480,height:320, scaleMode:"proportionalInside", centerRegistration:true, alpha:1 , autoPlay:false,  estimatedBytes:"37803458"}}
		];
		
		private var _videoPrependURLs = "assets/";  
		
		private var _trackData: Array = [
			{ url: "music01.mp3", vars: {name:"T_0", autoPlay:false, repeat:-1} }
		];  
		
		private var _trackPrependURLs = "assets/";                               
		
		//an array containing the VideoLoaders in the order they should be played
		private var _videos: Array = [];

		//an array containing the Mp3Loaders in the order they should be played
		private var _tracks: Array = [];

		//keeps track of the VideoLoader that is currently playing
		private var _currentVideo: VideoLoader;

		// keeps track of the Mp3Loader that is currently playing
		private var _currentTrack: MP3Loader;

		// keeps track selected sound index
		private var _trackIndex: int;

		//if true, the mouse is over the video or UI controls
		private var _mouseIsOver: Boolean;

		//If true, the audio has been muted
		private var _silentMode: Boolean;

		//If true, the background music há been muted
		private var _silentModeBG: Boolean;

		//where is play started
		private var _isStarted: Boolean

		//tracks whether or not the video was paused when the user moused-down on the scrubber. We must pause for scrubbing, but this tells us whether or not to playVideo() when the user releases the mouse. 
		private var _preScrubPaused: Boolean;

		//DEBUG FLAG
		private var _isDebugEnable: Boolean;



		 
		 //when the image loads, fade it in from alpha:0 using TweenLite
		 function onImageLoad(event:LoaderEvent):void {
			 
		 }
	
		private var _thumbs:Array = [
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
		public function Main() {
			
			var p:MovieClip = availableMovieListPanel;
			p.removeChildren(0);
			
			var q:LoaderMax = new LoaderMax();
			
			for(var i = 0; i < 3; i++) {
				for (var j = 0; j < 3; j ++){
					
					var index = (i * 3) + j;
					var v:VideoItem = new VideoItem();
					v.x = 100 + j * 150;
					v.y = 50 + i * 100;
					p.addChild(v);
					v.titleText.text = "Video: [" + index + "]";
					
					 //create an ImageLoader:
					 var loader:ImageLoader = new ImageLoader(_thumbs[index], 
								{
									name:"thumb01", 
									container:v.thumbnail,
									x:0, y:0, 
									width:120, 
									height:68, 
									scaleMode:"proportionalInside",
									centerRegistration:true, 
									onComplete:onImageLoad
								});
				 
					q.append(loader);
								
				}
			}
			q.load();

			 
			
			
			return;
			_silentMode = true;
			_isStarted = false;
			_isDebugEnable = true;
			stage.scaleMode = "noScale";
			
			initUI();
			initMonitor();
			activateUI();
			
			startTrackLoaderMax();
			startVideoLoaderMax();
			
			preloader_mc.alpha = 1;
		}

/*		
		private function startLoaderMaxXML(): void {
			LoaderMax.activate([XMLLoader, VideoLoader, MP3Loader]);
			var xmlLoader: XMLLoader = new XMLLoader("xml/videoList.xml", {
				name: "videoList",
				onComplete: xmlHandler
			});
			xmlLoader.load();
		}
		
		private function startTrackLoaderMax(): void {
			var trackQueue:LoaderMax = new LoaderMax({
				name: "trackDataList",
				maxConnections:1,
				onProgress:trackLoaderProgressHandler,
				onComplete:trackLoaderCompleteHandler,
				onChildProgress:childTrackLoaderProgressHandler,
				onChildComplete:childTrackLoaderCompleteHandler
			});

			
			for(var i = 0; i < _trackData.length; i++) {
				trackQueue.append(new MP3Loader(_trackData[i].url, _trackData[i].vars))
			}
			
			trackQueue.prependURLs("assets/");
			trackQueue.load();
			_tracks = trackQueue.getChildren();
		}
		
		private function startVideoLoaderMax(): void {
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
		
		private function trackLoaderProgressHandler(event:LoaderEvent):void {
			preloader_mc.totalPercent_mc.text = "Total: " +  Math.round(event.target.progress * 100).toString() + " %";
						
		}
		
		private function trackLoaderCompleteHandler(event:LoaderEvent): void {
			preloader_mc.totalPercent_mc.text = "Total: DONE!";
			
			showVideo(_videos[0]);
		}
		
		private function childTrackLoaderProgressHandler(event:LoaderEvent): void {
			preloader_mc.childPercent_mc.text = "Child: " +  Math.round(event.target.progress * 100).toString() + " %";
		}
		
		private function childTrackLoaderCompleteHandler(event:LoaderEvent): void {
			preloader_mc.childPercent_mc.text = "Child: DONE!"
		}

		private function videoLoaderProgressHandler(event:LoaderEvent):void {
			preloader_mc.totalPercent_mc.text = "Total: " +  Math.round(event.target.progress * 100).toString() + " %";
						
		}
		
		private function videoLoaderCompleteHandler(event:LoaderEvent): void {
			preloader_mc.totalPercent_mc.text = "Total: DONE!";
		}
		
		private function childVideoLoaderProgressHandler(event:LoaderEvent): void {
			preloader_mc.childPercent_mc.text = "Child: " +  Math.round(event.target.progress * 100).toString() + " %";
		}
		
		private function childVideoLoaderCompleteHandler(event:LoaderEvent): void {
			preloader_mc.childPercent_mc.text = "Child: DONE!"
		}

		private function xmlHandler(event: LoaderEvent): void {

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

		private function getSelectedTrack(): MP3Loader {
			if (_trackIndex >= 0 && _trackIndex < _tracks.length)
				return _tracks[_trackIndex];
			return _tracks[0];
		}

		private function showVideo(video: VideoLoader): void {

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
				TweenMax.to(preloader_mc, 0.3, {
					autoAlpha: 0,
					onComplete: preloader_mc.stop
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

			//listen for PROGRESS events so that we can update the loadingBar_mc's scaleX accordingly
			_currentVideo.addEventListener(LoaderEvent.PROGRESS, updateDownloadProgress);

			//listen for a VIDEO_COMPLETE event so that we can automatically advance to the next video.
			_currentVideo.addEventListener(VideoLoader.VIDEO_COMPLETE, nextVideo);

			//listen for PLAY_PROGRESS events so that we can update the progressBar_mc's scaleX accordingly
			_currentVideo.addEventListener(VideoLoader.PLAY_PROGRESS, updatePlayProgress);

			//if the video hasn't fully loaded yet and is still buffering, show the preloader
			if (_currentVideo.progress < 1 && _currentVideo.bufferProgress < 1) {

				//when the buffer fills, we'll fade out the preloader
				_currentVideo.addEventListener(VideoLoader.VIDEO_BUFFER_FULL, bufferFullHandler);

				//prioritizing the video ensures that it moves to the top of the LoaderMax gueue and any other loaders that were loading are canceled to maximize bandwidth available for the new video.
				_currentVideo.prioritize(true);

				//play() the preloader and fade its alpha up.
				preloader_mc.play();
				TweenMax.to(preloader_mc, 0.3, {
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
			videoContainer_mc.addChild(_currentVideo.content);

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

			//update the progressBar_mc and loadingBar_mc
			updateDownloadProgress();
			updatePlayProgress();
            
            //update DEBUG
			updateMonitor();
		}

		private function initMonitor(): void {
			if (!_isDebugEnable)
				return;

			var videoIndex = _videos.indexOf(_currentVideo);
			var trackIndex = _tracks.indexOf(_currentTrack);

			monitor_mc.videoId_mc.text = "scene: --";
			monitor_mc.trackId_mc.text = "track: --";
		}

		private function updateMonitor(): void {
			if (!_isDebugEnable)
				return;

			var videoIndex = _videos.indexOf(_currentVideo);
			var trackIndex = _tracks.indexOf(_currentTrack);

			monitor_mc.videoId_mc.text = "scene: " + videoIndex;
			monitor_mc.trackId_mc.text = "track: " + trackIndex;
		}

		private function initUI(): void {

			//ignore mouse interaction with progressBar_mc so that clicks pass through to the loadingBar_mc whose listener handles skipping the video to that spot.
			controlUI_mc.progressBar_mc.mouseEnabled = false;

			//ignore mouse interaction with preloader_mc
			preloader_mc.mouseEnabled = false;

			//the "layer" blendMode makes the alpha fades cleaner (overlapping objects don't add alpha levels)
			controlUI_mc.blendMode = "layer";

			//set the progress and loading bars and the scrubber to the very beginning
			controlUI_mc.progressBar_mc.width = controlUI_mc.loadingBar_mc.width = 0;
			controlUI_mc.scrubber_mc.x = controlUI_mc.progressBar_mc.x;

			//initially hide the user interface - autoAlpha:0 sets alpha to 0 and visible to false.
			TweenMax.allTo([controlUI_mc, playPauseBigButton_mc, preloader_mc], 0, {
				autoAlpha: 0
			});
		}

		private function addListeners(objects: Array, type: String, func: Function): void {
			var i: int = objects.length;
			while (i--) {
				objects[i].addEventListener(type, func);
			}
		}

		private function updateDownloadProgress(event: LoaderEvent = null): void {
			controlUI_mc.loadingBar_mc.scaleX = _currentVideo.progress;
		}

		private function bufferFullHandler(event: LoaderEvent): void {
			TweenMax.to(preloader_mc, 0.3, {
				autoAlpha: 0,
				onComplete: preloader_mc.stop
			});
		}

		private function force2Digits(value: Number): String {
			return (value < 10) ? "0" + String(value) : String(value);
		}

		private function updatePlayProgress(event: LoaderEvent = null): void {
			var time: Number = _currentVideo.videoTime;
			var minutes: String = force2Digits(int(time / 60));
			var seconds: String = force2Digits(int(time % 60));
			controlUI_mc.currentTime_tf.text = minutes + ":" + seconds;
			controlUI_mc.progressBar_mc.scaleX = _currentVideo.playProgress;
			controlUI_mc.scrubber_mc.x = controlUI_mc.progressBar_mc.x + controlUI_mc.progressBar_mc.width;

		}

		private function refreshTotalTime(event: LoaderEvent = null): void {
			var minutes: String = force2Digits(int(_currentVideo.duration / 60));
			var seconds: String = force2Digits(int(_currentVideo.duration % 60));
			controlUI_mc.totalTime_tf.text = minutes + ":" + seconds;
		}

		private function activateUI(): void {

			addListeners([controlUI_mc, videoContainer_mc, playPauseBigButton_mc], MouseEvent.ROLL_OVER, toggleControlUI);
			addListeners([controlUI_mc, videoContainer_mc, playPauseBigButton_mc], MouseEvent.ROLL_OUT, toggleControlUI);
			addListeners([controlUI_mc.playPauseButton_mc, playPauseBigButton_mc, videoContainer_mc], MouseEvent.CLICK, togglePlayPause);
			controlUI_mc.scrubber_mc.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownScrubber);
			controlUI_mc.loadingBar_mc.addEventListener(MouseEvent.CLICK, scrubToMouse);
			controlUI_mc.audio_mc.addEventListener(MouseEvent.CLICK, toggleAudio);
			controlUI_mc.next_mc.addEventListener(MouseEvent.CLICK, nextVideo);
			controlUI_mc.back_mc.addEventListener(MouseEvent.CLICK, previousVideo);
			
			var controls:Array = [controlUI_mc.playPauseButton_mc, 
								  playPauseBigButton_mc, 
								  controlUI_mc.back_mc, 
								  controlUI_mc.next_mc, 
								  controlUI_mc.audio_mc, 
								  controlUI_mc.scrubber_mc];
			var i:int = controls.length;
			while (i--) {
			    //controls[i].buttonMode = true;
			    //controls[i].mouseChildren = false;
			}
			
			addListeners([controlUI_mc.back_mc, controlUI_mc.audio_mc, controlUI_mc.next_mc], MouseEvent.ROLL_OVER, blackRollOverHandler);
			addListeners([controlUI_mc.back_mc, controlUI_mc.audio_mc, controlUI_mc.next_mc], MouseEvent.ROLL_OUT, blackRollOutHandler);
			controlUI_mc.playPauseButton_mc.addEventListener(MouseEvent.ROLL_OVER, growPlayPause);
			controlUI_mc.playPauseButton_mc.addEventListener(MouseEvent.ROLL_OUT, shrinkPlayPause);
		}
		
		private function blackRollOverHandler(event:MouseEvent):void {
		    //TweenMax.to(event.target.label, 0.3, {tint:0xFFFFFF});
		}

		private function blackRollOutHandler(event:MouseEvent):void {
		    //TweenMax.to(event.target.label, 0.3, {tint:null});
		}
		
		private function growPlayPause(event:MouseEvent):void {
		    TweenMax.to(event.target, 0.2, {scaleX:1.3, scaleY:1.3});
		}

		private function shrinkPlayPause(event:MouseEvent):void {
		    TweenMax.to(event.target, 0.2, {scaleX:1, scaleY:1});
		}

		private function mouseDownScrubber(event: MouseEvent): void {
			_preScrubPaused = _currentVideo.videoPaused;
			_currentVideo.videoPaused = true;
			controlUI_mc.scrubber_mc.startDrag(false, new Rectangle(controlUI_mc.loadingBar_mc.x, controlUI_mc.loadingBar_mc.y, controlUI_mc.loadingBar_mc.width, 0));
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpScrubber);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, scrubToMouse);
		}

		private function scrubToMouse(event: MouseEvent): void {
			controlUI_mc.progressBar_mc.width = controlUI_mc.mouseX - controlUI_mc.progressBar_mc.x;
			_currentVideo.playProgress = controlUI_mc.progressBar_mc.scaleX;
		}

		private function mouseUpScrubber(event: MouseEvent): void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpScrubber);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, scrubToMouse);
			controlUI_mc.scrubber_mc.stopDrag();
			_currentVideo.videoPaused = _preScrubPaused;
		}

		private function toggleControlUI(event: MouseEvent): void {
			_mouseIsOver = !_mouseIsOver;
			if (_mouseIsOver) {
				TweenMax.to(controlUI_mc, 0.3, {
					autoAlpha: 1
				});
			} else {
				TweenMax.to(controlUI_mc, 0.3, {
					autoAlpha: 0
				});
			}
		}

		private function toggleAudio(event: MouseEvent): void {
			_silentMode = !_silentMode;
			if (_silentMode) {
				_currentVideo.volume = 0;
				//controlUI_mc.audio_mc.label.gotoAndStop("off");
			} else {
				_currentVideo.volume = 1;
				//controlUI_mc.audio_mc.label.gotoAndStop("on");
			}
		}

		private function toggleBGSoundTrack(event: MouseEvent): void {
			_silentModeBG = !_silentModeBG;
			if (_silentModeBG) {
				_currentTrack.volume = 0;
			} else {
				_currentTrack.volume = 1;
			}
		}

		private function togglePlayPause(event: MouseEvent = null): void {
			_currentVideo.videoPaused = !_currentVideo.videoPaused;
			if (_currentVideo.videoPaused) {
				TweenMax.to(playPauseBigButton_mc, 0.3, {
					autoAlpha: 1
				});
				//controlUI_mc.playPauseButton_mc.gotoAndStop("paused");
				TweenMax.to(videoContainer_mc, 0.3, {
					blurFilter: {
						blurX: 6,
						blurY: 6
					},
					colorMatrixFilter: {
						brightness: 0.5
					}
				});
			} else {
				TweenMax.to(playPauseBigButton_mc, 0.3, {
					autoAlpha: 0
				});
				//controlUI_mc.playPauseButton_mc.gotoAndStop("playing");
				TweenMax.to(videoContainer_mc, 0.3, {
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

		private function nextVideo(event: Event): void {
			var next: int = _videos.indexOf(_currentVideo) + 1;
			if (next >= _videos.length) {
				next = 0;
			}
			showVideo(_videos[next]);
		}

		private function previousVideo(event: Event): void {
			var prev: int = _videos.indexOf(_currentVideo) - 1;
			if (prev < 0) {
				prev = _videos.length - 1;
			}
			showVideo(_videos[prev]);
		}
		*/
	}
}