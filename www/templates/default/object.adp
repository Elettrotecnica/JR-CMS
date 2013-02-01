<if @object_id@ not nil>
  <switch @object_type@>
    <case value="jr_multimedia">
      <include src="multimedia" object_id="@object_id@" locale="@locale@">
    </case>
    <case value="jr_article">
      <include src="article" object_id="@object_id@" locale="@locale@">
    </case>
    <case value="jr_youtube">
      <include src="youtube" object_id="@object_id@" locale="@locale@">
    </case>
    <default>
      <if @object.thumbnail_url@ ne "">
	<img src="@object.thumbnail_url@" width="100">
      </if>
      
      <script type="text/javascript">
	$(function() { $('#content').hide().fadeIn(); });
      </script>
    </default>
  </switch>
</if>
