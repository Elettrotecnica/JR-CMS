<center>
  <table border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="100%">
	<if @file_type@ eq "image">
	  <img id="image" src='@object.file_url@'>
	  <script type="text/javascript">
	    $(function() {
	      var image = $('#image');
   	      image.load(function () {
		var height = image.height();
		var width = image.width();
		if (height > width) {
		    image.attr('height', 450);
		} else {
		    image.attr('width', 450);
		}
   	      });
	    });
	  </script>
	</if>
	<else>
	  <script type='text/javascript' src="/resources/jwplayer/jwplayer.js"></script>
	  <video id='jwplayer@object_id@'></video>
	  <script type='text/javascript'>
	    jwplayer('jwplayer@object_id@').setup({
		flashplayer: '/resources/jwplayer/player.swf',
		file: '@object.file_url@',
		width: 450,
	    <if @file_type@ eq "audio">
		height: 60
	    </if>
	    });
	  </script>
	</else>
      </td>
    </tr>
    <tr>
      <td width="100%" style="text-align:left;">
	<br />
	@object.title;noquote@<br />
	@object.description;noquote@<br />
      </td>
    </tr>
  </table>
</center>