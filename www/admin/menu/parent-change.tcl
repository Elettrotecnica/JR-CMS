ad_page_contract {
    
    Changes the parent category of a category.

    @author Timo Hentschel (timo@timohentschel.de)
    @cvs-id $Id:
} {
    tree_id:integer
    category_id:integer
    {locale ""}
}

set category_name [category::get_name $category_id $locale]
set page_title "Cambia la voce padre di \"$category_name\""
set context [list $page_title]


template::multirow create tree category_name category_id deprecated_p level left_indent parent_url

if {[category::get_parent -category_id $category_id] != 0} {
    template::multirow append tree "Livello radice" 0 f 0 "" \
	[export_vars -no_empty -base "parent-change-2" { tree_id category_id locale }]
    
    set can_change_p 1
}

foreach descendant [db_list get_subtree ""] {
    set descendants($descendant) 1
}

foreach category [category_tree::get_tree -all $tree_id $locale] {
    util_unlist $category parent_id category_name deprecated_p level

    set parent_url ""
    
    if {![info exists descendants($parent_id)]} {
	set parent_url [export_vars -no_empty -base "parent-change-2" { parent_id tree_id category_id locale }]
	set can_change_p 1
    }
    
    template::multirow append tree $category_name $category_id $deprecated_p $level [string repeat "&nbsp;" [expr ($level-1)*5]] $parent_url
}


# Se non ci sono genitori ammissibili esco.
if {![info exists can_change_p]} {
    ad_returnredirect -message "Nessun genitore disponibile. Impossibile procedere." [export_vars -base list { tree_id locale }]
    ad_script_abort
}


template::list::create \
    -name tree \
    -no_data "Nessuna voce" \
    -elements {
	category_name {
	    label "Nome"
	    display_template {
		@tree.left_indent;noquote@ @tree.category_name@
	    }
	}
	set_parent {
	    label "Azione"
	    display_template {
		<if @tree.parent_url@ not nil><a href="@tree.parent_url@">Imposta genitore</a></if>
	    }
	}
    }


