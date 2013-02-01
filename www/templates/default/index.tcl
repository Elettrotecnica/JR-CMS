ad_page_contract {

    Homepage Template
    
    @author Antonio Pisano
    @cvs-id $Id:
} {
    {object_id ""}
    {locale ""}
}

# ip del server
set system_address [ns_conn location]

# nome del package
set package_key "jr-cms"

# Nome del sito
set site_name [parameter::get_from_package_key -package_key $package_key -parameter site_name]

# template in uso nel sito
set template [parameter::get_from_package_key -package_key $package_key -parameter template]

# Il template ha bisogno di TUTTI i dati degli oggetti? (peggiora le performance)
set get_all_object_data_p f

# Id dell'albero.
set tree_id [jrcms::tree_id]

# Tutto l'albero del sito, recuperato dalla cache.
set tree [category_tree::get_tree -all $tree_id $locale]

# Se non abbiamo selezionato nulla, prendo l'id della homepage.
set homepage_id [lindex [lindex $tree 0] 0]

if {$object_id eq ""} {
    set object_id $homepage_id
}

# Tutti gli antenati dell'oggetto selezionato (compreso se stesso): sono la 'scia di selezione'.
set ancestors [concat $object_id [jrcms::category::get_ancestors -category_id $object_id]]
foreach ancestor_id $ancestors {
    set is_selected($ancestor_id) 1
}

# Recupero se discendiamo da una galleria
set gallery_id 0
foreach ancestor_id $ancestors {
    if {[db_0or1row query "
	select gallery_id from jr_galleries
      where gallery_id = :ancestor_id"]} {
	  break
    }
}

# I figli diretti dell'oggetto.
if {[set children [category::get_children -category_id $object_id]] == 0} {
    set children [list]
}
foreach child_id $children {
    set is_child($child_id) 1
}

# ...che assieme agli altri 'parenti' dell'oggetto selezionato saranno gli oggetti mostrati.
set relatives [concat $children [jrcms::category::get_relatives -category_id $object_id]]
foreach relative_id $relatives {
    set is_shown($relative_id) 1
}

if {$get_all_object_data_p} {
    # Scorro gli id di tutti gli oggetti che dovrò mostrare. Per ciascuno recupero i dati dell'oggetto, salvandoli in un array chiamato come l'id.
    foreach shown_id [array names is_shown] {
	jrcms::get_object -item_id $shown_id -locale $locale -array $shown_id
    }
}

# Scorro tutto l'albero e...
foreach category $tree {
    util_unlist $category category_id category_name deprecated_p level
    
    set is_gallery_p [expr {$category_id == $gallery_id}]
    
    # ...se la voce è quella selezionata...
    if {$category_id == $object_id} {
	# ...se siamo al quarto livello di menu e ho delle sotto-voci seleziono la prima come predefinita...
	if {$is_gallery_p} {
	    set object_subtree [category_tree::get_tree -all -subtree_id $object_id $tree_id $locale]
	    if {[llength $object_subtree] > 0} {
		set object_id [lindex [lindex $object_subtree 0] 0]
		set is_selected($object_id) 1
	    }
	}
	
	jrcms::api::object::get -item_id $category_id -array object
	set object_name      $category_name
	set object_thumbnail $object(thumbnail_url)
    }
    
    # ...se l'oggetto è da visualizzare...
    if {[info exists is_shown($category_id)]} {
	
	# Le voci verranno inserite in un menu nominato in base alla profondità nell'albero...
	set menu_name "menu${level}"
	if {[info exists gallery_level]} {
	    # ...a meno che non si tratti dei figli diretti di una galleria, che saranno messi in un menu speciale.
	    set gallery_children_level [expr $gallery_level + 1]
	    if {$level == $gallery_children_level} {
		set menu_name "galleryMenu"
	    }
	# Mi segno che da qui in poi tutte le voci al di sotto di questa profondità sono nel sottoalbero della galleria.
	} elseif {$is_gallery_p} {
	    set gallery_level $level
	}
	
	# ...se già non esisteva, creo la multirow che conterrà tutti gli elementi del menu
	if {![template::multirow exists $menu_name]} {
	    template::multirow create $menu_name category_id category_name category_url is_selected_p is_child_p
	}
		
	# costruisco il pretty_url della voce risalendo i suoi genitori.
	set ancestor_names [list [ns_urlencode $category_name]]
	
	foreach ancestor_id [jrcms::category::get_ancestors -category_id $category_id] {
	    set ancestor_names [linsert $ancestor_names 0 [ns_urlencode [category::get_name $ancestor_id $locale]]]
	}
	
	set base_url /[join $ancestor_names "/"]
	
	if {[lindex [ad_conn urlv] 0] eq $package_key} {
	    set base_url "/${package_key}${base_url}"
	}   
	
	set category_url [export_vars -no_empty -base $base_url {locale}]
	
	# ...se è selezionata...
	set is_selected_p [info exists is_selected($category_id)]
	
	# ...se è figlia dell'oggetto selezionato...
	set is_child_p [info exists is_child($category_id)]
	
	template::multirow append $menu_name $category_id $category_name $category_url $is_selected_p $is_child_p
    }
}

# Il menu delle gallerie deve mostrare la thumbnail
if {[template::multirow exists galleryMenu]} {
    template::multirow extend galleryMenu thumbnail_url category_pretty_url facebook_title
    
    template::multirow foreach galleryMenu {
	jrcms::api::object::get -item_id $category_id -array object
	
	set thumbnail_url $object(thumbnail_url)
	
	regsub -all {\r} $category_name "<br/>" category_name
    }
}

set page_title $site_name

if {$object_id != $homepage_id} {
    append page_title " - $object_name"
}

if {$object_thumbnail eq ""} {
    set object_thumbnail "/jr-cms/images/facebook-preview-image.jpg"
}