var express = require('express');
var app = express();

app.set('port', (process.env.PORT || 5000));
app.use(express.static(__dirname + '/bin/'));

app.get('/api/movies', function(res, res){
	var d = [
		{ 
			url: 'movie14.mp4', 
			title: '剣の世界', 
			thumb: 'http://vignette2.wikia.nocookie.net/swordartonline/images/e/ee/Yui.png/revision/latest/scale-to-width-down/275?cb=20140228061052'
		},
		
		{ 
			url: 'movie21.mp4', 
			title: 'ビーター', 
			thumb: 'http://vignette4.wikia.nocookie.net/swordartonline/images/a/a9/Sao-kirito-asuna-yui-family.png/revision/latest/scale-to-width-down/212?cb=20150705222747'
		},
		
		{ 
			url: 'movie30.mp4', 
			title: '赤鼻のトナカイ', 
			thumb: 'http://vignette2.wikia.nocookie.net/swordartonline/images/6/6b/LS_Concert_Event.png/revision/latest/scale-to-width-down/212?cb=20150611103807'
		},
		
		{ 
			url: 'movie32.mp4', 
			title: '黒の剣士', 
			thumb: 'http://vignette2.wikia.nocookie.net/swordartonline/images/7/7e/LS_Seven_and_Sinon_2.png/revision/latest/scale-to-width-down/212?cb=20150611103552'
		},
		
		{ 
			url: 'movie34.mp', 
			title: '圏内事件', 
			thumb: 'http://vignette4.wikia.nocookie.net/swordartonline/images/7/7a/LS_Asuna_event.png/revision/latest/scale-to-width-down/212?cb=20150610200221'
		},
		
		{ 
			url: 'movie35.mp4', 
			title: '幻の復讐者', 
			thumb: 'http://vignette2.wikia.nocookie.net/swordartonline/images/e/ef/Karatachi_Nijika.png/revision/latest/scale-to-width-down/212?cb=20150610194924'
		},
		
		{ 
			url: '', 
			title: '心の温度', 
			thumb: ''
		},
		
		{ 
			url: '', 
			title: '黒と白の剣舞', 
			thumb: ''
		},
		
		{ 
			url: '', 
			title: '青眼の悪魔', 
			thumb: ''
		},
		
		{ 
			url: '', 
			title: '紅の殺意', 
			thumb: ''
		},
		
		{ 
			url: '', 
			title: '朝露の少女', 
			thumb: ''
		},
		
		{ 
			url: '', 
			title: 'ユイの心', 
			thumb: ''
		},
		
		{ 
			url: '', 
			title: '奈落の淵', 
			thumb: ''
		},
		
		{ 
			url: '', 
			title: '世界の終焉', 
			thumb: ''
		}
	];
	
	res.json(d);
});

app.listen(app.get('port'), function() {
  console.log("Node app is running at localhost:" + app.get('port'))
});

