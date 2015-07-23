$( document ).ready(function() {
	// ====================== Create Data Test ==================
	var soundUrls = [
		"music01.mp3", 
		"music02.mp3"
	];
	var movieUrls = [
		  "scene_0001.mp4",
		  "scene_0002.mp4",
		  "scene_0003.mp4",
		  "scene_0004.mp4"
	];

	// ====================== Embed SWF To HTML =================
	
	var flashvars = {};
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

});