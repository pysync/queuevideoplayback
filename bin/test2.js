$( document ).ready(function() {
	// ====================== Create Data Test ==================

	// Test data with absolute path
	soundUrls = [
		"http://localhost:5000/assets/bgm01.mp3", 
		"http://localhost:5000/assets/bgm02.mp3",
		"http://localhost:5000/assets/bgm03.mp3", 
		"http://localhost:5000/assets/bgm04.mp3",
		"http://localhost:5000/assets/bgm05.mp3"
	];
	movieUrls = [
		  "http://localhost:5000/assets/scene_0001.mp4",
		  "http://localhost:5000/assets/scene_0002.mp4",
		  "http://localhost:5000/assets/scene_0003.mp4",
		  "http://localhost:5000/assets/scene_0004.mp4"
	];

	// ====================== Embed SWF To HTML =================
	
	var flashvars = {
		debugEnable: true,
		relativePath: false,
		prependURL: "assets/",
		autoPlay: true,
		soundUrl: soundUrls[0],
		movieUrls:  JSON.stringify(movieUrls)
	};
	
	
	var params = {};
	var attributes = {};

	swfobject.embedSWF("Main.swf", "preview", 
					   "100%", "100%", 
	                   "9.0.0", "expressInstall.swf", 
	                   flashvars, params, attributes);
								

	// ==================== TEST BUTTONS ======================
	
				 
	$("#play-one-movie-btn-1").click(function(){ 
		var player = document.getElementById("preview");
		player.playMovie(movieUrls[0], "");	
	});
	
	$("#play-one-movie-btn-2").click(function(){ 
		var player = document.getElementById("preview");
		player.playMovie(movieUrls[1], "");	
	});
	
	$("#play-multi-movie-btn").click(function(){
		var player = document.getElementById("preview");
		player.playMultiMovies(movieUrls, soundUrls[0]);	
	});
	
	$("#change-bgm-btn-1").click(function(){ 
		var player = document.getElementById("preview");
		player.setBGM(soundUrls[0]);	
	});
	
	$("#change-bgm-btn-2").click(function(){ 
		var player = document.getElementById("preview");
		player.setBGM(soundUrls[1]);	
	});
	$("#change-bgm-btn-3").click(function(){ 
		var player = document.getElementById("preview");
		player.setBGM(soundUrls[2]);	
	});
	$("#change-bgm-btn-4").click(function(){ 
		var player = document.getElementById("preview");
		player.setBGM(soundUrls[3]);	
	});
	$("#change-bgm-btn-5").click(function(){ 
		var player = document.getElementById("preview");
		player.setBGM(soundUrls[4]);	
	});

});