ad_page_contract {
    Seleziono la tipologia di oggetto del CMS prima di crearlo

    @author Antonio Pisano
    @cvs-id $Id:
} {
    tree_id:integer
    {parent_id:integer,optional [db_null]}
    {locale ""}
}


set page_title "Seleziona il tipo di oggetto che desideri pubblicare."
set context [list $page_title]


db_foreach query "
  select pretty_name, object_type from acs_object_types t 
      where acs_object_type__is_subtype_p('jr_object', t.object_type)" {
    
    if {[regexp {(^JR\ )(.*)} $pretty_name match prefix type]} {
	set pretty_name $type
    }
    
    lappend objects [list $pretty_name $object_type]
}


ad_form -name select \
  -export {tree_id parent_id locale} \
  -form {
      
      {object_type:text(select)
	  {label "Oggetti disponibili"}
	  {options { {"..." ""} $objects } }
	  {value ""}
      }
  
} -on_submit {
      
    
      
} -after_submit {
    
    ad_returnredirect [export_vars -no_empty -base "add-edit" {tree_id parent_id locale object_type}]
    ad_script_abort
}

