HTMLWidgets.widget({

  name: 'browseTracks',

  type: 'output',

  factory: function(el, width, height) {
    var IGV;
    
    return {
      renderValue: function(x) {
        var igvDiv = document.getElementById(el.id);
        var tracks = [];
        for(var key in x.tracks){
          tracks.push(x.tracks[key]);
        }
        console.log(tracks);
        var options = {
          genome: x.genome,
          locus: x.locus,
          tracks: tracks
        };
        
        IGV = igv.createBrowser(igvDiv, options);
      },

      resize: function(width, height) {
        
      },
      
      IGV: IGV
    };
  }
});
