ad_page_contract {

    Changes the parent category of a category.

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id:
} {
    tree_id:integer
    category_id:integer
    {parent_id:integer,optional [db_null]}
    {locale ""}
}


set return_url [export_vars -no_empty -base list { tree_id locale }]


db_transaction {
    
    # Spostare in cima all'albero un elemento già in cima genera un errore e lo evitiamo.
    if {[category::get_parent -category_id $category_id] == 0 && $parent_id eq ""} {
	ad_returnredirect -message "La voce selezionata è già al livello radice dell'albero. Impossibile procedere." $return_url
	ad_script_abort
    }
    
    set prefix [jrcms::get_object_prefix -item_id $category_id]

    jrcms::api::${prefix}::edit -item_id $category_id -parent_id $parent_id

}


ad_returnredirect $return_url
ad_script_abort
