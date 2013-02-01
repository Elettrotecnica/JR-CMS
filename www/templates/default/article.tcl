## Parametri richiesti ##
# object_id:integer
# locale:optional

# Recupero i dati dell'articolo
db_1row query "select html_text from jr_articles where article_id = :object_id"

set html_text [lindex $html_text 0]
