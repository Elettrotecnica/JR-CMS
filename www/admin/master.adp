<master src="/www/default-master">
<property name="title">@page_title;noquote@</property>
<property name="context">@context;noquote@</property>
<if @focus@ not nil><property name="focus">@focus;noquote@</property></if>

<if @page_title@ not nil>
  <h1>@page_title@</h1>
</if>

<slave>

  
