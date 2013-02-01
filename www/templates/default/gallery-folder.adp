<if @elements@ defined>
  
  <div id="galleryElement"><include src="object" object_id="@first_element_id@" locale="@locale@"></div>
  
  <div id="galleryHiddenElements">
    <list name="elements">
      <div><include src="object" object_id="@elements:item@" locale="@locale@"></div>
    </list>
  </div>
  
  <if @n_elements@ gt 1>
  
    <div id="gallerySelectors">
      <list name="elements">
	<if @elements:rownum@ eq 1>
	  <div class="gallerySelector" id="gallerySelectorSelected" onmouseover="getElementBySelector(this);"></div>
	</if>
	<else>
	  <div class="gallerySelector" onmouseover="getElementBySelector(this);"></div>
	</else>
      </list>
    </div>
    
    <script type="text/javascript">
      // Tutti i selettori
      var selectors = new Array();
      
      var selector = document.getElementById('gallerySelectors').firstChild;
      
      while (selector != null) {
	  // Raccolgo solo gli ElementNode, non il testo.
	  if (selector.nodeType == 1) {
	      selectors.push(selector);
	  }
	  selector = selector.nextSibling;
      }
      
      
      // Tutti gli elementi nascosti
      var hiddenElements = new Array();
      
      var hiddenElement = document.getElementById('galleryHiddenElements').firstChild;
      
      while (hiddenElement != null) {
	  // Raccolgo solo gli ElementNode, non il testo.
	  if (hiddenElement.nodeType == 1) {
	      hiddenElements.push(hiddenElement);
	  }
	  hiddenElement = hiddenElement.nextSibling;
      }
      
      
      var selectorElementMap = new Array();
      
      for (var i = 0; i < selectors.length; i++) {
	  selectorElementMap[i] = [selectors[i], hiddenElements[i]];
      }
      
      
      function getElementBySelector (selector) {
	  for (var i = 0; i < selectorElementMap.length; i++) {
	      var map = selectorElementMap[i];
	      if (map[0] == selector) {
		  var newGalleryElement = map[1];
		  break;
	      }
	  }
	  
	  var galleryElement = document.getElementById('galleryElement');
	  
	  var galleryParent = galleryElement.parentNode;
	  galleryParent.replaceChild(newGalleryElement, galleryElement);
	  
	  newGalleryElement.setAttribute('id','galleryElement');
	  
	  var oldSelected = document.getElementById('gallerySelectorSelected');
	  oldSelected.removeAttribute('id');
	  
	  selector.setAttribute('id','gallerySelectorSelected');
      }
      
      
      getElementBySelector(selectors[0]);
      
    </script>
  </if>
</if>
<else>
&nbsp;
</else>
