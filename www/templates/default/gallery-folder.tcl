## Parametri richiesti ##
# object_id:integer
# locale:optional

if {![info exists object_id]} {
    set query [ns_conn query]
    set get_variables_set [ns_parsequery $query]

    set object_id [ns_set get $get_variables_set "object_id"]
    set locale [ns_set get $get_variables_set "locale"]
}


# Id dell'albero.
set tree_id [jrcms::tree_id]

set tree [category_tree::get_tree -all -subtree_id $object_id $tree_id $locale]

set first_element_id [lindex [lindex $tree 0] 0]

foreach category $tree {
    lappend elements [lindex $category 0]
}

if {[info exists elements]} {
    set n_elements [llength $elements]
}
    
    
    
    
    



