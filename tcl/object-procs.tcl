ad_library {
    Proc per la gestione degli oggetti del CMS
}

namespace eval jrcms {}

ad_proc -public jrcms::tree_id {
} {
    Ottiene l'albero di categories del CMS
} {
    set package_id [apm_package_id_from_key "jr-cms"]

    set tree_id [category_tree::get_id "jr-tree-$package_id"]
    
    
    return $tree_id
}

ad_proc -public jrcms::folder_id {
} {
    Ottiene la cartella del CMS
} {
    set package_id [apm_package_id_from_key "jr-cms"]
    
    # get file-storage package id
    set fs_package_id [apm_package_id_from_key "file-storage"]

    # get the root folder of the file-storage instance
    set root_folder_id [fs::get_root_folder -package_id $fs_package_id]
    
    # Recupero la cartella del cms
    set folder_id [fs::get_folder -name "jr-cms-$package_id" -parent_id $root_folder_id]
    
    
    return $folder_id
}

ad_proc -public jrcms::get_object_prefix {
    {-item_id ""}
} {
    Ottiene il tipo di un oggetto del CMS
} {
    set object_type [db_string query "
      select object_type from acs_objects o
	where object_id = :item_id and acs_object_type__is_subtype_p('jr_object', o.object_type)
    " -default "jr_object"]
    
    if {![regexp {(^jr_)(.*)} $object_type match jr_prefix prefix]} {
	set prefix object_type
    }
    
    
    return $prefix
}

ad_proc -public jrcms::get_object {
    -item_id:required
    -array:required
    {-locale ""}
} {
    Ottiene il tipo di un oggetto del CMS
} {
    upvar 1 $array object
    
    set prefix [get_object_prefix -item_id $item_id]
    
    api::${prefix}::get -item_id $item_id -locale $locale -array object
}


# API

namespace eval jrcms::api {}
namespace eval jrcms::api::object {}

ad_proc -public jrcms::api::object::get {
    -item_id:required
    -array:required
    {-locale ""}
} {
    Ottiene i dati di un oggetto del CMS
} {
    upvar 1 $array row
    # Se non è stata fornita una lingua, o se non ho una traduzione per questo oggetto userò la lingua di default.
    if {$locale == "" || ![db_0or1row query "
      select 1 from category_translations 
	where category_id = :item_id and locale = :locale"]} {
	set locale [parameter::get -parameter DefaultLocale -default it_IT]
    }
    db_1row query {
	select jo.*,
               ct.name as title,
               ct.description,
               c.parent_id,
               o.object_type,
               o.creation_user,
               o.creation_date,
               o.creation_ip,
               o.last_modified,
               o.modifying_user,
               o.modifying_ip
	from jr_objects jo
             inner join acs_objects o on jo.object_id = o.object_id
             inner join categories c on jo.object_id = c.category_id
             inner join category_translations ct on jo.object_id = ct.category_id
        where ct.locale = :locale
          and jo.object_id = :item_id
    } -column_array row
    
    set thumbnail_id $row(thumbnail_id)
    
    # recupero l'url della thumbnail
    if {[jrcms::fs::get_file -item_id $thumbnail_id -array thumbnail]} {
	set row(thumbnail_url) $thumbnail(url)
    } else {
	set row(thumbnail_url) ""
    }
}

ad_proc -public jrcms::api::object::add {
    -title:required
    {-parent_id         ""}
    {-description       ""}
    {-locale            ""}
    {-thumbnail         ""}
    {-thumbnail.tmpfile ""}
} { 
    Aggiunge un oggetto del CMS
} {
    # Albero dei jr_objects
    set tree_id [jrcms::tree_id]
    
    if {$locale == ""} {
	set locale [parameter::get -parameter DefaultLocale -default it_IT]
    }
    
    # Creo la category
    set object_id [category::add \
	-tree_id     $tree_id  \
	-parent_id   $parent_id \
	-locale      $locale \
	-name        $title \
	-description $description]
    
    # Imposto che il tipo di questo oggetto non è category, 
    # ma il suo tipo figlio 'jr_object'
    db_dml query "
      update acs_objects set
	  object_type = 'jr_object'
	where object_id = :object_id"
    
    # Se viene fornita una thumbnail la allego
    if {$thumbnail ne "" && [file exists ${thumbnail.tmpfile}] && [file size ${thumbnail.tmpfile}] > 0} {
	set thumbnail_id [jrcms::fs::add_file \
	    -name          $thumbnail \
	    -tmp_filename  ${thumbnail.tmpfile} \
	    -description   "Thumbnail $object_id"]
    } else {
	set thumbnail_id ""
    }
    
    db_dml query {
 	insert into jr_objects (
	        object_id,
	        thumbnail_id
            ) values (
	        :object_id,
	        :thumbnail_id
	    )
    }
    
    
    return $object_id
}

ad_proc -public jrcms::api::object::delete_thumbnail {
    -item_id:required
} { 
    Aggiunge una thumbnail ad un oggetto del cms
} {
    if {![db_0or1row query "
      select thumbnail_id from jr_objects 
	where object_id = :item_id 
	  and thumbnail_id is not null"]} {
	return
    }
    
    # ...scollego la vecchia thumbnail...
    db_dml query {
	update jr_objects set
	    thumbnail_id = null
	  where object_id = :item_id
    }
    
    # ...e la elimino.
    db_1row query "select live_revision from fs_objects where object_id = :thumbnail_id"
    fs::delete_version -item_id $thumbnail_id -version_id $live_revision
}

ad_proc -public jrcms::api::object::edit {
    -item_id:required
    {-title             "omit"}
    {-description       "omit"}
    {-parent_id         "omit"}
    {-locale            "omit"}
    {-thumbnail         "omit"}
    {-thumbnail.tmpfile "omit"}
} { 
    Aggiunge una thumbnail ad un oggetto del cms
} {
    # Albero dei jr_objects
    set tree_id [jrcms::tree_id]
    
    if {$locale eq "omit"} {
	set locale [parameter::get -parameter DefaultLocale -default it_IT]
    }
    
    jrcms::api::object::get -item_id $item_id -locale $locale -array object
    
    if {$title eq "omit"} {
	set title $object(title)
    }
    if {$description eq "omit"} {
	set description $object(description)
    }
    
    set old_parent_id $object(parent_id)
    
    if {$parent_id ne "omit" && $parent_id != $old_parent_id} {
	category::change_parent -category_id $item_id \
	    -tree_id $tree_id \
	    -parent_id $parent_id \
    }
    
    # Se viene fornita una nuova thumbnail la creo...
    if {$thumbnail ne "" && [file exists ${thumbnail.tmpfile}] && [file size ${thumbnail.tmpfile}] > 0} {
	
	jrcms::api::object::delete_thumbnail -item_id $item_id
	
	# Creo la nuova thumbnail...
	set thumbnail_id [jrcms::fs::add_file \
	    -name          $thumbnail \
	    -tmp_filename  ${thumbnail.tmpfile} \
	    -description   "Thumbnail $item_id"]
	
	# ...e la allego all'oggetto.
	db_dml query {
	    update jr_objects set
		thumbnail_id = :thumbnail_id
	      where object_id = :item_id
	}
    }
    
    # Edito la category
    category::update -category_id $item_id \
	-name        $title \
	-locale      $locale \
	-description $description
}

ad_proc -public jrcms::api::object::delete {
    -item_id:required
} { 
    Elimina un oggetto del CMS
} {
    jrcms::api::object::delete_thumbnail -item_id $item_id
    
    db_dml query "delete from jr_objects where object_id = :item_id"
      
    category::delete $item_id
    
    category_tree::flush_cache [jrcms::tree_id]
}


# FORM

namespace eval jrcms::form {}
namespace eval jrcms::form::object {}

ad_proc -public jrcms::form::object::get_form {
} { 
    Restituisce il campo form nel formato della ad_form per la gestione dell'oggetto.
} {
    set form {
	{category_id:key}
	{title:text(textarea),nospell
	    {label "Nome"} {html {rows 1 cols 80}}
	}
	{description:text(textarea),optional,nospell
	    {label "Descrizione"} {html {rows 5 cols 80}}
	}
	{thumbnail:file(file),optional
	    {label "Immagine di anteprima"}
	}
	{thumbnail.tmpfile:text(hidden),optional}
    }
    
    
    return $form
}

ad_proc -public jrcms::form::object::get_new_request {
} { 
    Codice per la new_request nella form di gestione dell'oggetto
} {
    set new_request ""
    
    
    return $new_request
}

ad_proc -public jrcms::form::object::get_edit_request {
} { 
    Codice per la edit_request nella form di gestione dell'oggetto
} {
    set edit_request {
	jrcms::api::object::get -item_id $form_key -locale $locale -array object
	
	set title         $object(title)
	set description   $object(description)
	set thumbnail_url $object(thumbnail_url)
	
	if {$thumbnail_url ne ""} {
	    template::element::set_properties $form_name thumbnail before_html "<img src='$thumbnail_url' width='200'><br />"
	}
    }
    
    
    return $edit_request
}

ad_proc -public jrcms::form::object::get_on_submit {
} { 
    Codice per la on_submit nella form di gestione dell'oggetto
} {
    set on_submit {
	if {$thumbnail ne ""} {
	    # Prendo solo il nome file
	    set thumbnail_data [split $thumbnail " "]
	    set thumbnail      [lindex $thumbnail_data 0]
	    set thumbnail_type [lindex $thumbnail_data 2]
	    
	    if {![regexp ^image/.* $thumbnail_type]} {
		template::form::set_error $form_name thumbnail "Il formato del file inviato non è supportato."
	    }
	    
	    # Verifico che la thumbnail non sia troppo grande.
	    set n_bytes [file size ${thumbnail.tmpfile}]
	    set max_bytes [ad_parameter "MaximumFileSize"]
	    if { $max_bytes ne "" && $n_bytes > $max_bytes } {
		# Max number of bytes is used in the error message
		set max_number_of_bytes [util_commify_number $max_bytes]
		template::form::set_error $form_name thumbnail "Il file allegato supera la dimensione massima consentita. $n_bytes "
	    }
	}
    }
    
    
    return $on_submit
}

ad_proc -public jrcms::form::object::get_new_data {
} { 
    Codice per la new_data nella form di gestione dell'oggetto
} {
    set new_data {
	jrcms::api::object::add \
	    -title             $title \
	    -parent_id         $parent_id \
	    -description       $description \
	    -locale            $locale \
	    -thumbnail         $thumbnail \
	    -thumbnail.tmpfile ${thumbnail.tmpfile}
    }
    
    
    return $new_data
}

ad_proc -public jrcms::form::object::get_edit_data {
} { 
    Codice per la edit_data nella form di gestione dell'oggetto
} {
    set edit_data {
	jrcms::api::object::edit -item_id $form_key \
	    -title             $title \
	    -description       $description \
	    -locale            $locale \
	    -thumbnail         $thumbnail \
	    -thumbnail.tmpfile ${thumbnail.tmpfile}
    }
    
    
    return $edit_data
}