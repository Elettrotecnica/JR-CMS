ad_library {
    Proc per la gestione degli articoli
}

namespace eval jrcms {}
namespace eval jrcms::api {}
namespace eval jrcms::api::multimedia {}

ad_proc -public jrcms::api::multimedia::get {
    -item_id:required
    -array:required
    {-locale ""}
} {
    Ottiene i dati di un oggetto multimediale.
} {
    upvar 1 $array row
    
    # Ottengo i dati dell'articolo
    db_1row query {
	select m.*
	from   jr_multimedia m
        where  m.multimedia_id = :item_id
    } -column_array row
    
    set file_id $row(file_id)
    
    # recupero l'url del file
    jrcms::fs::get_file -item_id $file_id -array file
    set row(file_type) $file(type)
    set row(file_url)  $file(url)
    
    # Ottengo i dati ereditati dall'oggetto
    jrcms::api::object::get -item_id $item_id -locale $locale -array object
    
    array set row [array get object]
}

ad_proc -public jrcms::api::multimedia::add {
    -title:required
    {-parent_id         ""}
    {-locale            ""}
    {-description       ""}
    {-thumbnail         ""}
    {-thumbnail.tmpfile ""}
    -file:required
    -file.tmpfile:required
} { 
    Crea un nuovo oggetto multimediale
} {

    set multimedia_id [jrcms::api::object::add \
		      -title              $title \
		      -parent_id          $parent_id \
		      -description        $description \
		      -locale             $locale \
		      -thumbnail          $thumbnail \
		      -thumbnail.tmpfile  ${thumbnail.tmpfile}]
    
    # Imposto che il tipo di questo oggetto non è 'jr_object',
    # ma il suo tipo figlio 'jr_multimedia'
    db_dml query "
      update acs_objects set
	  object_type = 'jr_multimedia'
	where object_id = :multimedia_id"
    
    set file_id [jrcms::fs::add_file \
	-name          $file \
	-tmp_filename  ${file.tmpfile} \
	-description   "Multimedia $multimedia_id"]

    db_dml query {
 	insert into jr_multimedia (
	        multimedia_id,
	        file_id
            ) values (
	        :multimedia_id,
	        :file_id
	    )
    }

    return $multimedia_id
}

ad_proc -public jrcms::api::multimedia::edit {
    -item_id:required
    {-title             "omit"}
    {-description       "omit"}
    {-parent_id         "omit"}
    {-locale            "omit"}
    {-thumbnail         "omit"}
    {-thumbnail.tmpfile "omit"}
    {-file              "omit"}
    {-file.tmpfile      "omit"}
} { 
    Edita un oggetto multimediale
} {
    jrcms::api::multimedia::get -item_id $item_id -locale $locale -array multimedia
    
    if {$title eq "omit"} {
	set title $multimedia(title)
    }
    if {$description eq "omit"} {
	set description $multimedia(description)
    }
    if {$parent_id eq "omit"} {
	set parent_id $multimedia(parent_id)
    }
    
    jrcms::api::object::edit -item_id $item_id \
	-title             $title \
	-parent_id         $parent_id \
	-description       $description \
	-locale            $locale \
	-thumbnail         $thumbnail \
	-thumbnail.tmpfile ${thumbnail.tmpfile}
    
    # Se viene fornito un nuovo file...
    if {$file ne "omit" && $file ne ""} {
	
	set file_id $multimedia(file_id)
	
	# ...scollego il vecchio file...
	db_dml query {
	    update jr_multimedia set
		file_id = null
	      where multimedia_id = :item_id
	}
	
	# ...e lo elimino.
	db_1row query "select live_revision from fs_objects where object_id = :file_id"
	fs::delete_version -item_id $file_id -version_id $live_revision
	
	# Creo il nuovo file...
	set file_id [jrcms::fs::add_file \
	    -name          $file \
	    -tmp_filename  ${file.tmpfile} \
	    -description   "Multimedia $item_id"]
	
	# ...e lo allego all'oggetto.
	db_dml query {
	    update jr_multimedia set
		file_id = :file_id
	      where multimedia_id = :item_id
	}
    }
}

ad_proc -public jrcms::api::multimedia::delete {
    -item_id:required
} { 
    Elimina un oggetto multimediale.
} { 
    db_1row query "select file_id from jr_multimedia where multimedia_id = :item_id"
    
    db_dml query "delete from jr_multimedia where multimedia_id = :item_id"
      
    if {$file_id ne ""} {
	db_1row query "select live_revision from fs_objects where object_id = :file_id"
	fs::delete_version -item_id $file_id -version_id $live_revision
    }
    
    jrcms::api::object::delete -item_id $item_id
}



# FORM

namespace eval jrcms::form {}
namespace eval jrcms::form::multimedia {}

ad_proc -public jrcms::form::multimedia::get_form {
} { 
    Restituisce il campo form nel formato della ad_form per la gestione dell'oggetto.
} {
    
    set form [jrcms::form::object::get_form]
    
    append form {
	{file:file(file),optional
	    {label "Contenuto multimediale"}
	}
	{file.tmpfile:text(hidden),optional}
    }
    
    
    return $form
}

ad_proc -public jrcms::form::multimedia::get_new_request {
} { 
    Codice per la new_request nella form di gestione dell'oggetto
} {
    set new_request ""
    
    
    return $new_request
}

ad_proc -public jrcms::form::multimedia::get_edit_request {
} { 
    Codice per la edit_request nella form di gestione dell'oggetto
} {
    set edit_request [jrcms::form::object::get_edit_request]
    
    append edit_request {
	db_1row query "select file_id from jr_multimedia where multimedia_id = :form_key"
	
	jrcms::fs::get_file -item_id $file_id -array multimedia
	
	set file_type  $multimedia(type)
	set file_url   $multimedia(url)
	
	# Se il file è un'immagine la mostrerò in un tag img
	if {[regexp ^image/.* $file_type]} {
	    set before_html "<img src='$file_url' width='200'><br />"
	
	# Se è un video o un audio caricherò jwplayer per visualizzarla.
	} elseif {[regexp {^audio/.*|^video/.*} $file_type]} {
	    if {[regexp ^audio/.* $file_type]} {
		set height 70
		set width 480
	    } else {
		set height 240
		set width 320
	    }
	    
	    template::head::add_javascript -src "/resources/jwplayer/jwplayer.js"
	    set jwpscript "
	      <script type='text/javascript'>
		jwplayer('jwplayer').setup({
		    flashplayer: '/resources/jwplayer/player.swf',
		    file: '$file_url',
		    height: $height,
		    width: $width
		});
	      </script>
	    "
	    
	    set before_html "<video src='$file_url' height='480' id='jwplayer' width='640'></video>$jwpscript<br />"
	    
	} else {
	    set before_html "Il tipo di file caricato non è supportato...<br />"
	}
	
	template::element::set_properties $form_name file before_html $before_html
    }
    
    
    return $edit_request
}

ad_proc -public jrcms::form::multimedia::get_on_submit {
} { 
    Codice per la on_submit nella form di gestione dell'oggetto
} {
    set on_submit [jrcms::form::object::get_on_submit]
    
    append on_submit {
	if {$file ne ""} {
	    # Prendo solo il nome file
	    set file_data [split $file " "]
	    set file      [lindex $file_data 0]
	    set file_type [lindex $file_data 2]
	    
	    if {![regexp {^audio/.*|^video/.*|^image/.*} $file_type]} {
		template::form::set_error $form_name file "Il formato del file inviato non è supportato."
	    }
	    
	    # Verifico che il file non sia troppo grande.
	    set n_bytes [file size ${thumbnail.tmpfile}]
	    set max_bytes [ad_parameter "MaximumFileSize"]
	    if { $max_bytes ne "" && $n_bytes > $max_bytes } {
		# Max number of bytes is used in the error message
		set max_number_of_bytes [util_commify_number $max_bytes]
		template::form::set_error $form_name file "Il file allegato supera la dimensione massima consentita. $n_bytes"
	    }
	}
    }
    
    
    return $on_submit
}

ad_proc -public jrcms::form::multimedia::get_new_data {
} { 
    Codice per la new_data nella form di gestione dell'oggetto
} {
    set new_data {
	
	if {$file eq ""} {
	    template::form::set_error $form_name file "È necessario fornire un file multimediale."
	    break
	}
	
	jrcms::api::multimedia::add \
	    -title             $title \
	    -parent_id         $parent_id \
	    -description       $description \
	    -locale            $locale \
	    -thumbnail         $thumbnail \
	    -thumbnail.tmpfile ${thumbnail.tmpfile} \
	    -file              $file \
	    -file.tmpfile      ${file.tmpfile}
    }
    
    
    return $new_data
}

ad_proc -public jrcms::form::multimedia::get_edit_data {
} { 
    Codice per la edit_data nella form di gestione dell'oggetto
} {
    set edit_data {
	jrcms::api::multimedia::edit -item_id $form_key \
	    -title             $title \
	    -description       $description \
	    -locale            $locale \
	    -thumbnail         $thumbnail \
	    -thumbnail.tmpfile ${thumbnail.tmpfile} \
	    -file              $file \
	    -file.tmpfile      ${file.tmpfile}
    }
    
    
    return $edit_data
}