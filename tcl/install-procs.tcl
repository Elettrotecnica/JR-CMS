ad_library {

    Proc eseguite all'installazione del package
    
}

namespace eval jrcms {}

ad_proc -private jrcms::after-instantiate {
  -package_id:required
} {
    Inizializza alcune strutture all'atto dell'installazione
} {
    ##Creo l'albero dei menu
   
    # Creo l'albero della struttura del sito
    set tree_name "jr-tree-$package_id"
    
    category_tree::add -name $tree_name -description $tree_name -context_id $package_id
    
    
    ### Creo la cartella del package
    
    set creation_user [ad_conn user_id]
    set creation_ip   [ad_conn peeraddr]
    
    # get file-storage package id
    set fs_package_id [apm_package_id_from_key file-storage]
    
    # get the root folder of the file-storage instance
    set root_folder_id [fs::get_root_folder -package_id $fs_package_id]
    
    fs::new_folder \
	-name          "jr-cms-$package_id" \
	-pretty_name   "JR CMS - $package_id" \
	-parent_id     $root_folder_id \
	-creation_user $creation_user \
	-creation_ip   $creation_ip \
	-description   "JR CMS folder for package $package_id" \
	-package_id    $fs_package_id
}

ad_proc -private jrcms::before-uninstantiate {
  -package_id:required
} {
    Elimino gli alberi e le categorie creati dal package
} {
    ##Elimino tutte le categories create dal package
    
    set trees [category_tree::get_mapped_trees $package_id]
    
    foreach tree $trees {
	category_tree::delete [lindex $tree 0]
    }
}