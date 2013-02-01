ad_page_contract {
    Form per aggiungere/editare un oggetto del CMS

    @author Antonio Pisano
    @cvs-id $Id:
} {
    tree_id:integer
    category_id:integer,optional
    {parent_id:integer,optional [db_null]}
    {locale ""}
    object_type:optional
}


if {[info exists category_id]} {
    set page_title "Edita"
    
    if {![info exists object_type]} {
	db_1row query "select object_type from acs_objects where object_id = :category_id"
    }
    
} elseif {[info exists object_type]} {
    set page_title "Aggiungi"

} else {   
    ad_returnredirect [export_vars -base "select-object-type" {tree_id parent_id locale}]
    ad_script_abort
}

# Recupero il nome 'umano' dell'oggetto.
db_1row query "select pretty_name from acs_object_types where object_type = :object_type"


# Tolgo il suffisso 'JR ' dai nomi oggetto
if {[regexp {(^JR\ )(.*)} $pretty_name match prefix type]} {
    set pretty_name $type
}

# Tolgo il suffisso 'jr_' dai tipi oggetto
if {![regexp {(^jr_)(.*)} $object_type match jr_prefix prefix]} {
    set prefix $object_type
}


append page_title " $pretty_name"
set context [list $page_title]


#Le proc parametriche di costruzione della form si aspetteranno l'esistenza di 'form_name' e 'form_key'
set form_name $prefix

if {[info exists category_id]} {
    set form_key $category_id
}


ad_form -name $form_name \
  -html {enctype multipart/form-data} \
  -export {tree_id parent_id locale object_type} \
  -form         [jrcms::form::${prefix}::get_form] \
  -new_request  [jrcms::form::${prefix}::get_new_request] \
  -edit_request [jrcms::form::${prefix}::get_edit_request] \
  -new_data {
      
      db_transaction [jrcms::form::${prefix}::get_new_data]
      
} -edit_data {
      
      db_transaction [jrcms::form::${prefix}::get_edit_data]
      
} -on_submit {
      
      eval [jrcms::form::${prefix}::get_on_submit]

      if {![template::form::is_valid $form_name]} {
	  break
      }
      
} -after_submit {
    
    ad_returnredirect [export_vars -no_empty -base list {tree_id locale}]
    ad_script_abort
}

