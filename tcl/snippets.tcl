# Recupero le le variabili get extra, non previste nell'ad_page_contract                                                                                                        
    set query [ns_conn query]
    set get_variables_set [ns_parsequery $query]

    set search_tornieri_project [ns_set get $get_variables_set "search_tornieri_project"]
    set f_tornieri_bid_type [ns_set get $get_variables_set "f_tornieri_bid_type"]


select pretty_name, object_type from acs_object_types t where acs_object_type__is_subtype_p('jr_object', t.object_type)

<%=[set [set menu_1(category_id)](description)]%>