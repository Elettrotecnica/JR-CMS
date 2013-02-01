ad_page_contract {

    Elimina uno o più oggetti del CMS

    @author Antonio Pisano
    @cvs-id $Id:
} {
    category_id:integer
    {locale ""}
}


set message "Anteprima rimossa."

db_transaction {
    jrcms::api::object::delete_thumbnail -item_id $category_id
} on_error {
    set message "Impossibile eliminare una voce senza eliminare anche le sue sotto voci."
}

ad_returnredirect -message $message [export_vars -no_empty -base list {locale}]
ad_script_abort
