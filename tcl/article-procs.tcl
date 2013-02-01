ad_library {
    Proc per la gestione degli articoli
}

namespace eval jrcms {}


# API

namespace eval jrcms::api {}
namespace eval jrcms::api::article {}

ad_proc -public jrcms::api::article::get {
    -item_id:required
    -array:required
    {-locale ""}
} {
    Ottiene i dati di un articolo.
} {
    upvar 1 $array row
    
    # Ottengo i dati dell'articolo
    db_1row query {
	select a.*
	from   jr_articles a
        where  a.article_id = :item_id
    } -column_array row
    
    # Ottengo i dati ereditati dall'oggetto
    jrcms::api::object::get -item_id $item_id -locale $locale -array object
    
    array set row [array get object]
}

ad_proc -public jrcms::api::article::add {
    -title:required
    {-locale            ""}
    {-parent_id         ""}
    {-description       ""}
    {-html_text         ""}
    {-thumbnail         ""}
    {-thumbnail.tmpfile ""}
} { 
    Crea un nuovo articolo
} {

    set article_id [jrcms::api::object::add \
		      -title              $title \
		      -parent_id          $parent_id \
		      -description        $description \
		      -locale             $locale \
		      -thumbnail          $thumbnail \
		      -thumbnail.tmpfile  ${thumbnail.tmpfile}]
    
    # Imposto che il tipo di questo oggetto non è 'jr_object',
    # ma il suo tipo figlio 'jr_article'
    db_dml query "
      update acs_objects set
	  object_type = 'jr_article'
	where object_id = :article_id"

    db_dml query {
 	insert into jr_articles (
	        article_id,
	        html_text
            ) values (
	        :article_id,
	        :html_text
	    )
    }

    return $article_id
}

ad_proc -public jrcms::api::article::edit {
    -item_id:required
    {-title             "omit"}
    {-description       "omit"}
    {-locale            "omit"}
    {-parent_id         "omit"}
    {-thumbnail         "omit"}
    {-thumbnail.tmpfile "omit"}
    {-html_text         "omit"}
} { 
    Edita un articolo
} {
    db_1row query "
      select html_text
	  from jr_articles
	where article_id = :item_id
    " -column_array article
    
    if {$html_text eq "omit"} {
	set html_text $article(html_text)
    }
    
    jrcms::api::object::edit -item_id $item_id \
	-title             $title \
	-parent_id         $parent_id \
	-description       $description \
	-locale            $locale \
	-thumbnail         $thumbnail \
	-thumbnail.tmpfile ${thumbnail.tmpfile}

    db_dml article_edit {
	update jr_articles set
	    html_text = :html_text
	where article_id = :item_id
    }
}

ad_proc -public jrcms::api::article::delete {
    -item_id:required
} { 
    Elimina un'articolo
} { 
    db_dml query "delete from jr_articles where article_id = :item_id"
    
    jrcms::api::object::delete -item_id $item_id
}



# FORM

namespace eval jrcms::form {}
namespace eval jrcms::form::article {}

ad_proc -public jrcms::form::article::get_form {
} { 
    Restituisce il campo form nel formato della ad_form per la gestione dell'articolo.
} {
    set form [jrcms::form::object::get_form]
    
    append form {
	{html_text:richtext(richtext),optional
	    {label "Testo dell'articolo"}
	    {html {rows 50 cols 100}}
	}
    }
    
    
    return $form
}

ad_proc -public jrcms::form::article::get_new_request {
} { 
    Codice per la new_request nella form di gestione dell'oggetto
} {
    set new_request [jrcms::form::object::get_new_request]
    
    
    return $new_request
}

ad_proc -public jrcms::form::article::get_edit_request {
} { 
    Codice per la edit_request nella form di gestione dell'oggetto
} {
    set edit_request [jrcms::form::object::get_edit_request]
    
    append edit_request {
	db_1row query "
	  select html_text
	      from jr_articles 
	    where article_id = :form_key"
    }
    
    
    return $edit_request
}

ad_proc -public jrcms::form::article::get_on_submit {
} { 
    Codice per la on_submit nella form di gestione dell'oggetto
} {
    set on_submit [jrcms::form::object::get_on_submit]
    

    return $on_submit
}

ad_proc -public jrcms::form::article::get_new_data {
} { 
    Codice per la new_data nella form di gestione dell'oggetto
} {
    set new_data {
	jrcms::api::article::add \
	    -title             $title \
	    -parent_id         $parent_id \
	    -description       $description \
	    -locale            $locale \
	    -thumbnail         $thumbnail \
	    -thumbnail.tmpfile ${thumbnail.tmpfile} \
	    -html_text         $html_text
    }
    
    
    return $new_data
}

ad_proc -public jrcms::form::article::get_edit_data {
} { 
    Codice per la edit_data nella form di gestione dell'oggetto
} {
    set edit_data {
	jrcms::api::article::edit -item_id $form_key \
	    -title             $title \
	    -description       $description \
	    -locale            $locale \
	    -thumbnail         $thumbnail \
	    -thumbnail.tmpfile ${thumbnail.tmpfile} \
	    -html_text         $html_text
    }
    
    
    return $edit_data
}