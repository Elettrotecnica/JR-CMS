ad_library {
    Proc per la gestione delle gallerie
}

namespace eval jrcms {}
namespace eval jrcms::api {}
namespace eval jrcms::api::gallery {}

ad_proc -public jrcms::api::gallery::check {
    -parent_id:required
} {
    Controlli da eseguire alla manipolazione di un oggetto.
} {
    # Se la galleria non si trova (troverà) in cima all'albero...
    if {$parent_id ne ""} {
	# ...verifico che tra i suoi antenati non ci sia (o ci sarà) un'altra galleria...
	set new_ancestors [concat [list $parent_id] [jrcms::category::get_ancestors -category_id $parent_id]]
	
	foreach ancestor $new_ancestors {
	    set object_type [db_string query "
	      select object_type from acs_objects 
		  where object_id = :ancestor"]
	    #`...e se è così esco.
	    if {$object_type eq "jr_gallery"} {
		return 0
	    }
	}
    }
    
    # Se fin'adesso non ne ho trovate, tutto OK
    return 1
}

ad_proc -public jrcms::api::gallery::get {
    -item_id:required
    -array:required
    {-locale ""}
} {
    Ottiene i dati di un articolo.
} {
    upvar 1 $array row
    
    # Ottengo i dati ereditati dall'oggetto
    jrcms::api::object::get -item_id $item_id -locale $locale -array row
    
    set row(gallery_id) $row(object_id)
}

ad_proc -public jrcms::api::gallery::add {
    -title:required
    {-locale            ""}
    {-parent_id         ""}
    {-description       ""}
    {-thumbnail         ""}
    {-thumbnail.tmpfile ""}
} { 
    Crea un nuovo articolo
} {

    set gallery_id [jrcms::api::object::add \
		      -title              $title \
		      -parent_id          $parent_id \
		      -description        $description \
		      -locale             $locale \
		      -thumbnail          $thumbnail \
		      -thumbnail.tmpfile  ${thumbnail.tmpfile}]
    
    # Imposto che il tipo di questo oggetto non è 'jr_object',
    # ma il suo tipo figlio 'jr_gallery'
    db_dml query "
      update acs_objects set
	  object_type = 'jr_gallery'
	where object_id = :gallery_id"

    db_dml query {
 	insert into jr_galleries (
	        gallery_id
            ) values (
	        :gallery_id
	    )
    }

    return $gallery_id
}

ad_proc -public jrcms::api::gallery::edit {
    -item_id:required
    {-title             "omit"}
    {-description       "omit"}
    {-locale            "omit"}
    {-parent_id         "omit"}
    {-thumbnail         "omit"}
    {-thumbnail.tmpfile "omit"}
} { 
    Edita una galleria
} {
    jrcms::api::gallery::get -item_id $item_id -locale $locale -array gallery
    
    if {$title eq "omit"} {
	set title $gallery(title)
    }
    if {$description eq "omit"} {
	set description $gallery(description)
    }
    if {$parent_id eq "omit"} {
	set parent_id $gallery(parent_id)
    
    } elseif {![jrcms::api::gallery::check -parent_id $parent_id]} {
	set parent_id "omit"
	util_user_message -message "Impossibile collocare la galleria \"$title\" all'interno di un'altra galleria."
    }
    
    jrcms::api::object::edit -item_id $item_id \
	-title             $title \
	-parent_id         $parent_id \
	-description       $description \
	-locale            $locale \
	-thumbnail         $thumbnail \
	-thumbnail.tmpfile ${thumbnail.tmpfile}
}

ad_proc -public jrcms::api::gallery::delete {
    -item_id:required
} { 
    Elimina un'articolo
} { 
    db_dml query "delete from jr_galleries where gallery_id = :item_id"
    
    jrcms::api::object::delete -item_id $item_id
}


# FORM

namespace eval jrcms::form {}
namespace eval jrcms::form::gallery {}

ad_proc -public jrcms::form::gallery::get_form {
} { 
    Restituisce il campo form nel formato della ad_form per la gestione dell'oggetto.
} {
    set form [jrcms::form::object::get_form]
    
    
    return $form
}

ad_proc -public jrcms::form::gallery::get_new_request {
} { 
    Codice per la new_request nella form di gestione dell'oggetto
} {
    set new_request [jrcms::form::object::get_new_request]
    
    
    return $new_request
}

ad_proc -public jrcms::form::gallery::get_edit_request {
} { 
    Codice per la edit_request nella form di gestione dell'oggetto
} {
    set edit_request [jrcms::form::object::get_edit_request]
    
    
    return $edit_request
}

ad_proc -public jrcms::form::gallery::get_on_submit {
} { 
    Codice per la on_submit nella form di gestione dell'oggetto
} {
    set on_submit [jrcms::form::object::get_on_submit]
    
    append on_submit {
	if {![jrcms::api::gallery::check -parent_id $parent_id]} {
	    template::form::set_error $form_name title "Non è consentito collocare una galleria all'interno di un'altra galleria."
	}
    }
    
    
    return $on_submit
}

ad_proc -public jrcms::form::gallery::get_new_data {
} { 
    Codice per la new_data nella form di gestione dell'oggetto
} {
    set new_data {
	jrcms::api::gallery::add \
	    -title             $title \
	    -parent_id         $parent_id \
	    -description       $description \
	    -locale            $locale \
	    -thumbnail         $thumbnail \
	    -thumbnail.tmpfile ${thumbnail.tmpfile}
    }
    
    
    return $new_data
}

ad_proc -public jrcms::form::gallery::get_edit_data {
} { 
    Codice per la edit_data nella form di gestione dell'oggetto
} {
    set edit_data {
	jrcms::api::gallery::edit -item_id $form_key \
	    -title             $title \
	    -description       $description \
	    -locale            $locale \
	    -thumbnail         $thumbnail \
	    -thumbnail.tmpfile ${thumbnail.tmpfile}
    }
    
    
    return $edit_data
}