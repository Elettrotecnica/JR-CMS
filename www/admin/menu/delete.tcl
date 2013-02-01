ad_page_contract {

    Elimina un oggetto dal CMS

    @author Antonio Pisano
    @cvs-id $Id:
} {
    category_id:integer,multiple
    {locale ""}
}

set tree_id [jrcms::tree_id]


set page_title "Elimina voce"
set context [list $page_title]


set delete_url [export_vars -no_empty -base delete-2 { tree_id category_id:multiple locale }]
set cancel_url [export_vars -no_empty -base list { tree_id locale }]


multirow create categories category_id category_name

foreach id $category_id {
    multirow append categories \
	$id \
	[category::get_name $id $locale]
}

multirow sort categories -dictionary category_name


template::list::create \
    -name categories \
    -no_data "None" \
    -elements {
	category_name {
	    label "Nome"
	}
    }
