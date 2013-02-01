<html>
  <head>
    <title>@page_title@</title>
    <link rel="stylesheet" href="/@package_key@/css/style.css" type="text/css" media="all">
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <script src="/resources/jquery/jquery.js"></script>
    <meta property="og:title" content="@page_title@" />
    <meta property="og:description" content="Director, designer, multimedia artist" />
    <meta property='og:image' content='http://213.251.147.24@object_thumbnail@' />
  </head>
  <body>
  <div id="fb-root"></div>
    <script>(function(d, s, id) {
      var js, fjs = d.getElementsByTagName(s)[0];
      if (d.getElementById(id)) return;
      js = d.createElement(s); js.id = id;
      js.src = "//connect.facebook.net/it_IT/all.js#xfbml=1";
      fjs.parentNode.insertBefore(js, fjs);
    }(document, 'script', 'facebook-jssdk'));</script>
    <!--     Contenitore dell'intera pagina -->
    <div id="page">
      <if @menu1:rowcount@ defined>
	<div id="topMenus">
	<!--       Menu 1 -->
	<div id="menu1">
	  <multiple name="menu1">
	    <a href='@menu1.category_url@'>@menu1.category_name@</a>
	  </multiple>
	</div>
	<div id="titleRuler"></div>
	<div id="share_buttons">
	  <table cellpadding="0" cellspacing="0">
	    <tr>
	      <td>
		<a href="http://www.youtube.com/user/jacoporondinelli" target="_blank" title="Jacopo Rondinelli Youtube Channel"><img src="/@package_key@/images/youtube.jpeg" height="29"/></a>&nbsp;&nbsp;
	      </td>
	      <td>
		<a href="http://www.facebook.com/jacoporondinellipage" target="_blank" title="Jacopo Rondinelli Facebook Page"><img src="/@package_key@/images/facebook.jpeg" height="26"/></a>&nbsp;&nbsp;
	      </td>
	      <td>
		<div id="fb-like" class="fb-like" data-send="false" data-layout="button_count" data-show-faces="true"></div>
	      </td>
	    </tr>
	  </table>
	</div>
	  <if @menu2:rowcount@ defined>
	  <!--       Menu 2 -->
	  <div id="menu2">
	    <multiple name="menu2">
	      <span class="menu2Element">
		<if @menu2.is_selected_p@ ><a href='@menu2.category_url@' id="menu2ElementSelected">@menu2.category_name@</a></if>
		<else><a href='@menu2.category_url@'>@menu2.category_name@</a></else>
	      </span>
	    </multiple>
	  </div>
	  </if>
	</div>
      <div id="sideMenus" class="menus">
	  <if @menu3:rowcount@ defined>
	  <!--       Menu 3 -->
	  <div id="menu3">
	    <multiple name="menu3">
	      <div class="menuNElement">
		<if @menu3.is_child_p@ true>
		  <a href='@menu3.category_url@'>@menu3.category_name@</a>
		</if>
		<elseif @menu3.is_selected_p@ >
		  <a href='@menu3.category_url@' id="menu3ElementSelected">@menu3.category_name@</a>
		  <if @menu4:rowcount@ defined>
		    <!--       Menu 4 -->
		    <div id="menu4">
		      <div id="menu4Elements">
		      <multiple name="menu4">
			<if @menu4.is_selected_p@ >
			  <a href='@menu4.category_url@' class="menu4Element" id="menu4ElementSelected">
			</if>
			<else>
			  <a href='@menu4.category_url@' class="menu4Element">
			</else>
			    <div class="menu4Element">@menu4.category_name@</div>
			  </a>
		      </multiple>
		      </div>
		    </div>
		    <script type="text/javascript">
		      $(function() {
			  // Se questo è l'ultimo menu, quindi è appena  comparso...
			  if ($('#menu4ElementSelected').length == 0) {
			    var menu4Height = $('#menu4').outerHeight();
			    
			    // Il menu appare scorrendo dall'alto...
			    $('#menu4').hide().slideDown('slow');
			    
			    // ...e contemporaneamente il suo contenuto si sposta verso il basso.
			    $('#menu4Elements').css('top','-' + menu4Height).animate({
			      top: '+=' + menu4Height
			    }, 'slow');
			  }
			  
			  // Tutti i link del 3° menu, quando cliccati...
			  $('.menuNElement > a').click(function () {
			    // ...fanno sparire il menu4
			    $('#menu4').slideUp('slow');
			    
			    var link = this;
			    // e mandano al loro link.
			    $('#menu4Elements').animate({
			      top: '-=' + menu4Height
			    }, 'slow', 'swing', function () {
			      window.location = link.href;
			    });
			    
			    // Cosa accade alla pressione del link l'ho deciso io. Fermo il gestore di default.
			    return false;
			  });
		      });
		    </script>
		  </if>
		</elseif>
		<else>
		  <a href='@menu3.category_url@' class="menu3ElementUnselected">@menu3.category_name@</a>
		</else>
	      </div>
	    </multiple>
	  </div>
	 </if>
	 &nbsp;
      </div>
      </if>
      <div id="content">
	<if @object_id@ eq @homepage_id@>
	  <include src="homepage" object_id="@object_id@" locale="@locale@"></div>
	</if>
	<elseif @galleryMenu:rowcount@ defined>
	  <include src="gallery-folder" object_id="@object_id@" locale="@locale@"></div>
	</elseif>
	<else>
	  <include src="object" object_id="@object_id@" locale="@locale@"></div>
	</else>
      <if @galleryMenu:rowcount@ defined>
	<div id="galleryMenu">
	  <div class="galleryMenuButton" id="galleryMenuPrevButton">&nbsp;</div>
	    <div id="galleryMenuElements">
	    <multiple name="galleryMenu">
	      <div class="galleryMenuElement">
		<if @galleryMenu.is_selected_p@ >
		  <div class="galleryMenuText" id="galleryMenuTextSelected">@galleryMenu.category_name;noquote@</div>
		  <div href='@galleryMenu.category_url@' prettyurl='@galleryMenu.category_pretty_url@' name="@galleryMenu.facebook_title@" class="galleryMenuImage" id="galleryMenuImageSelected" style="background-image: url(@galleryMenu.thumbnail_url@)"></div>
		</if>
		<else>
		  <div class="galleryMenuText">@galleryMenu.category_name;noquote@</div>
		  <div href='@galleryMenu.category_url@' prettyurl='@galleryMenu.category_pretty_url@' name="@galleryMenu.facebook_title@" class="galleryMenuImage" style="background-image: url(@galleryMenu.thumbnail_url@)"></div>
		</else>
	      </div>
	    </multiple>
	  </div>
	 <div class="galleryMenuButton" id="galleryMenuNextButton">&nbsp;</div>
	</div>
	<script type="text/javascript">
	  $(function() {

	      function galleryMenuSetHover (object) {
		  object.hover(
		      function () {
			  $(this).parent().find('.galleryMenuText').attr('id', 'galleryMenuTextHover')
			  .end().end()
			  .attr('id', 'galleryMenuImageHover');
			  
			  return false;
		      },
		      function () {
			  $(this).parent().find('*').removeAttr('id');
			  
			  return false;
		      }
		  )
	      }
	      
	      galleryMenuSetHover($('.galleryMenuImage').not('#galleryMenuImageSelected'));
	      
	      $('.galleryMenuImage').click(
		  function () {
		     var href = $(this).attr('href');
		     var hrefPretty = 'http://' + location.host + $(this).attr('prettyurl');
		     var title = $(this).attr('name');
		     
 		     window.location = href;
		     
		     $('#galleryMenuTextSelected').removeAttr('id');
		     $('#galleryMenuImageSelected').removeAttr('id');
		     $(this).parent().find('.galleryMenuText').attr('id', 'galleryMenuTextSelected')
		     .end().end()
		     .attr('id', 'galleryMenuImageSelected');
		     
		     $(this).off('hover');
		     galleryMenuSetHover($('.galleryMenuImage').not('#galleryMenuImageSelected'));
		  }
	      );
	      
	      
	      var GALLERYMENUSIZE = 8;
	      
	      
	      var galleryMenuElements = $('#galleryMenuElements');
	      
	      var galleryMenuLength = galleryMenuElements.find('.galleryMenuElement').length;
	      
	      
	      var galleryMenuNextButton = $('#galleryMenuNextButton');
	      var galleryMenuPrevButton = $('#galleryMenuPrevButton');
	      

	      var galleryMenuIndex = 0;
	      
	      $('.galleryMenuImage').each(function (index) {
		  if ($(this).attr('id') == 'galleryMenuImageSelected') {
		      galleryMenuIndex = index;
		  }
	      });
	      
	      var firstVisiblePos = galleryMenuIndex - (galleryMenuIndex % GALLERYMENUSIZE);
	      var lastVisiblePos  = firstVisiblePos + GALLERYMENUSIZE - 1;
	      
	      if (lastVisiblePos > galleryMenuLength - 1) {
		  lastVisiblePos = galleryMenuLength - 1;
		  firstVisiblePos = lastVisiblePos - GALLERYMENUSIZE + 1;
	      }
	      
	      galleryMenuElements
		.find('> :lt(' + firstVisiblePos + ')').hide()
		  .end()
		.find('> :gt(' + lastVisiblePos + ')').hide();
	      
      	      function fadeInvisibles() {
		  galleryMenuElements
		    .find('> :eq(' + (firstVisiblePos - 1) + ')').fadeOut('fast', null, function() {
			galleryMenuElements.find('> :eq(' + lastVisiblePos + ')').fadeIn('fast');
		    })
		      .end()
		    .find('> :eq(' + (lastVisiblePos + 1) + ')').fadeOut('fast', null, function() {
			galleryMenuElements.find('> :eq(' + firstVisiblePos + ')').fadeIn('fast');
		    });
		  
		  if (firstVisiblePos <= 0) {
		      galleryMenuPrevButton.css('visibility','hidden');
		  } else {
		      galleryMenuPrevButton.css('visibility','visible');
		  }
		  
		  if (lastVisiblePos + 1 >= galleryMenuLength) {
		      galleryMenuNextButton.css('visibility','hidden');
		  } else {
		      galleryMenuNextButton.css('visibility','visible');
		  }
	      }
	      
	      fadeInvisibles();
	      
	      galleryMenuNextButton.click(function() {
		  firstVisiblePos++;
		  lastVisiblePos++;
		  
		  fadeInvisibles();
		  
		  return false;
	      });
	      
	      galleryMenuPrevButton.click(function() {
		  firstVisiblePos--;
		  lastVisiblePos--;
		  
		  fadeInvisibles();
		  
		  return false;
	      });

	  });
	</script>
      </if>
    </div>
  </body>
</html>
