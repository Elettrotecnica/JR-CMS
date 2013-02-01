<list name="images">
  <img src="@images:item@" width="450">
</list>
<script type="text/javascript">
  $(function() { 
      var content = $('#content');
      var images = content.find('img');
      
      images.hide();
      
      var stillDuration = 3000;
      var fadeDuration = 600;
      var totDuration = stillDuration + (fadeDuration * 2);
      
      function animateImages (index) {
	  var nextIndex = index + 1;
	  if (nextIndex >= images.length) {
	      nextIndex = 0;
	  }
	  content.find('> :eq(' + index + ')').fadeIn(fadeDuration).delay(stillDuration).fadeOut(fadeDuration, function () { animateImages(nextIndex) });
      }
      
      animateImages(0);
  });
</script>

