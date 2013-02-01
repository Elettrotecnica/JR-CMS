ad_library {
    Proc per la gestione degli articoli
}

namespace eval jrcms {}


# API

namespace eval jrcms::api {}
namespace eval jrcms::api::youtube {}

ad_proc -public jrcms::api::youtube::get {
    -item_id:required
    -array:required
    {-locale ""}
} {
    Ottiene i dati di un articolo.
} {
    upvar 1 $array row
    
    # Ottengo i dati dell'articolo
    db_1row query {
	select y.*
	from   jr_youtubes y
        where  y.youtube_id = :item_id
    } -column_array row
    
    # Ottengo i dati ereditati dall'oggetto
    jrcms::api::object::get -item_id $item_id -locale $locale -array object
    
    array set row [array get object]
}

ad_proc -public jrcms::api::youtube::add {
    -title:required
    {-parent_id         ""}
    {-locale            ""}
    {-description       ""}
    {-thumbnail         ""}
    {-thumbnail.tmpfile ""}
    {-youtube_code      ""}
} { 
    Crea un nuovo articolo
} {

    set youtube_id [jrcms::api::object::add \
			-title              $title \
			-parent_id          $parent_id \
			-description        $description \
			-locale             $locale \
			-thumbnail          $thumbnail \
			-thumbnail.tmpfile  ${thumbnail.tmpfile}]
    
    # Imposto che il tipo di questo oggetto non è 'jr_object',
    # ma il suo tipo figlio 'jr_youtube'
    db_dml query "
      update acs_objects set
	  object_type = 'jr_youtube'
	where object_id = :youtube_id"

    db_dml query {
 	insert into jr_youtubes (
	        youtube_id,
	        youtube_code
            ) values (
	        :youtube_id,
	        :youtube_code
	    )
    }

    return $youtube_id
}

ad_proc -public jrcms::api::youtube::edit {
    -item_id:required
    {-title             "omit"}
    {-description       "omit"}
    {-parent_id         "omit"}
    {-locale            "omit"}
    {-thumbnail         "omit"}
    {-thumbnail.tmpfile "omit"}
    {-youtube_code      "omit"}
} { 
    Edita un articolo
} {
    db_1row query "
      select youtube_code 
	  from jr_youtubes 
	where youtube_id = :item_id
    " -column_array youtube
    
    if {$youtube_code eq "omit"} {
	set youtube_code $youtube(youtube_code)
    }
    
    jrcms::api::object::edit -item_id $item_id \
	-title             $title \
	-parent_id         $parent_id \
	-description       $description \
	-locale            $locale \
	-thumbnail         $thumbnail \
	-thumbnail.tmpfile ${thumbnail.tmpfile}

    db_dml youtube_edit {
	update jr_youtubes set
	    youtube_code = :youtube_code
	where youtube_id = :item_id
    }
}

ad_proc -public jrcms::api::youtube::delete {
    -item_id:required
} { 
    Elimina un'articolo
} { 
    db_dml query "delete from jr_youtubes where youtube_id = :item_id"
    
    jrcms::api::object::delete -item_id $item_id
}


# FORM

namespace eval jrcms::form {}
namespace eval jrcms::form::youtube {}

ad_proc -public jrcms::form::youtube::get_form {
} { 
    Restituisce il campo form nel formato della ad_form per la gestione dell'articolo.
} {
    set form [jrcms::form::object::get_form]
    
    append form {
	{youtube_code:text(textarea)
	    {label "Codice Youtube"}
	    {html {rows 4 cols 50}}
	}
    }
    
    
    return $form
}

ad_proc -public jrcms::form::youtube::get_new_request {
} { 
    Codice per la new_request nella form di gestione dell'oggetto
} {
    set new_request [jrcms::form::object::get_new_request]
    
    
    return $new_request
}

ad_proc -public jrcms::form::youtube::get_edit_request {
} { 
    Codice per la edit_request nella form di gestione dell'oggetto
} {
    set edit_request [jrcms::form::object::get_edit_request]
    
    append edit_request {
	db_1row query "
	  select youtube_code
	      from jr_youtubes 
	    where youtube_id = :form_key"
	
	set youtube_frame "<iframe width='450' height='360' src='$youtube_code' frameborder='0' allowfullscreen></iframe>"
	
	template::element::set_properties $form_name youtube_code before_html "${youtube_frame}<br />"
    }
    
    
    return $edit_request
}

ad_proc -public jrcms::form::youtube::get_on_submit {
} { 
    Codice per la on_submit nella form di gestione dell'oggetto
} {
    set on_submit [jrcms::form::object::get_on_submit]
    
    
    return $on_submit
}

ad_proc -public jrcms::form::youtube::get_new_data {
} { 
    Codice per la new_data nella form di gestione dell'oggetto
} {
    set new_data {
	jrcms::api::youtube::add \
	    -title             $title \
	    -parent_id         $parent_id \
	    -description       $description \
	    -locale            $locale \
	    -thumbnail         $thumbnail \
	    -thumbnail.tmpfile ${thumbnail.tmpfile} \
	    -youtube_code      $youtube_code
    }
    
    
    return $new_data
}

ad_proc -public jrcms::form::youtube::get_edit_data {
} { 
    Codice per la edit_data nella form di gestione dell'oggetto
} {
    set edit_data {
	jrcms::api::youtube::edit -item_id $form_key \
	    -title             $title \
	    -description       $description \
	    -locale            $locale \
	    -thumbnail         $thumbnail \
	    -thumbnail.tmpfile ${thumbnail.tmpfile} \
	    -youtube_code      $youtube_code
    }
    
    
    return $edit_data
}