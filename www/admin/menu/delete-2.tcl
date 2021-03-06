ad_page_contract {

    Elimina uno o più oggetti del CMS

    @author Antonio Pisano
    @cvs-id $Id:
} {
    category_id:integer,multiple
    {locale ""}
}


set tree_id [jrcms::tree_id]


set message ""

db_transaction {
    foreach category_id [db_list order_categories_for_delete ""] {
	set prefix [jrcms::get_object_prefix -item_id $category_id]
	jrcms::api::${prefix}::delete -item_id $category_id
    }
} on_error {
    set message "Impossibile eliminare una voce senza eliminare anche le sue sotto voci."
}

ad_returnredirect -message $message [export_vars -no_empty -base list {locale}]
ad_script_abort
