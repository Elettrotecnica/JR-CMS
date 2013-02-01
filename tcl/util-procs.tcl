ad_library {
    Proc per la delle caratteristiche comuni a tutti gli oggetti del cms
}

namespace eval jrcms {}

ad_proc -public jrcms::get_script_name {
} {
    Recupera il nome dello script in esecuzione, privo di percorso ed estensione.
} { 
    return [lindex [split [lindex [split [ad_conn file] "/"] end] "."] 0]
}

# File

namespace eval jrcms::fs {}

ad_proc -public jrcms::fs::get_file {
    -item_id:required
    -array:required
} {
    Ritorna i dati di un file, incluso l'url del file-storage per visualizzarlo
} { 
    upvar 1 $array row
    if {![db_0or1row query "
      select *, parent_id as folder_id from fs_objects 
	where object_id = :item_id
	  and type not in ('folder', 'symlink')" -column_array row]} {
	return 0
    }
    
    set type  $row(type)
    
    if {$type eq "url"} {
	
	set file_url $row(url)
    
    } else {
	
	# get file-storage package id
	set fs_package_id [apm_package_id_from_key file-storage]

	# get file-storage package url
	set fs_url [apm_package_url_from_id $fs_package_id]
	
	set like_filesystem_p [parameter::get -parameter BehaveLikeFilesystemP -package_id $fs_package_id -default 1]
	
	if {$like_filesystem_p} {
	    set title $row(title)
	    
	    set file_url [export_vars -base "${fs_url}download/[ad_urlencode $title]" {{file_id $item_id}}]
	} else {
	    set name      $row(name)
	    set folder_id $row(folder_id)
	    
	    # get the root folder of the file-storage instance
	    set root_folder_id [fs::get_root_folder -package_id $fs_package_id]
	    
	    if {$root_folder_id ne $folder_id} {
		set folder_path [db_string query "select content_item__get_path(:folder_id, :root_folder_id)"]
	    } else {
		set folder_path ""
	    }
	    
	    set file_url "${fs_url}view/${folder_path}/${name}"
	}
    }
    
    set row(url) $file_url
    
    
    return 1
}

ad_proc -public jrcms::fs::add_file {
    -name:required
    -description:required
    -tmp_filename:required
} {
    Crea un file nella cartella del CMS
} { 
    # get file-storage package id
    set fs_package_id [apm_package_id_from_key file-storage]
    
    # Recupero la cartella del cms
    set folder_id [jrcms::folder_id]
    
    set file_id [db_nextval acs_object_id_seq]
    
    # Controllo se un file con quel nome esiste già.
    if {[db_0or1row query "select 1 from cr_items where name = :name"]} {
	set name "$file_id-$name"
    }
    
    # Salvo la thumbnail nel file-storage
    fs::add_file -item_id $file_id \
	-name          $name \
	-parent_id     $folder_id \
	-tmp_filename  $tmp_filename \
	-title         $description \
	-description   $description \
	-package_id    $fs_package_id
    
    
    return $file_id
}


# Categories

namespace eval jrcms::category {}

ad_proc -public jrcms::category::get_ancestors {
    -category_id:required
} {
    Ottiene tutti gli antenati di una category
    
    L'ordinamento è gerarchicamente crescente: l'ultimo elemento è l'antenato comune di tutti gli altri.
} { 
    if {$category_id eq ""} {
	return [list]
    }
    
    set parent_id [category::get_parent -category_id $category_id]
    
    if {$parent_id == 0} {
	set parent_id ""
    }
    
    set ancestors [concat $parent_id [get_ancestors -category_id $parent_id]]
    
    
    return $ancestors
}

ad_proc -public jrcms::category::get_siblings {
    -category_id:required
} {
    Ottiene tutti i fratelli di un oggetto del CMS
    
    Una category è sorella di se stessa.
} {
    set parent_id [category::get_parent -category_id $category_id]
    
    if {$parent_id == 0} {
	set where_clause "parent_id is null"
    } else {
	set where_clause "parent_id = :parent_id"
    }
    
    set siblings [db_list query "
      select category_id from categories 
	where $where_clause"]
    
    
    return $siblings
}

ad_proc -public jrcms::category::get_relatives {
    -category_id:required
} {
    Ottiene tutti i nodi 'imparentati': i fratelli, gli antenati e i fratelli degli antenati.
} { 
    # Tra gli antenati ci metto anche la category stessa, come se fosse antenata di se stessa.
    set ancestors [concat $category_id [get_ancestors -category_id $category_id]]
    
    set relatives [list]
    
    foreach ancestor $ancestors {
	set relatives [concat [get_siblings -category_id $ancestor] $relatives]
    }
    
    
    return $relatives
}
