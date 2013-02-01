## Parametri richiesti ##
# object_id:integer
# locale:optional

# Recupero i dati dell'oggetto richiesto
jrcms::api::multimedia::get -item_id $object_id -locale $locale -array object

if { \
![regexp {(^audio)(.*)} $object(file_type) match file_type] && \
![regexp {(^video)(.*)} $object(file_type) match file_type] && \
![regexp {(^image)(.*)} $object(file_type) match file_type] \
} {
    set file_type "unsupported"
}

regsub -all {\r} $object(title) "<br/>" object(title)

regsub -all {\r} $object(description) "<br/>" object(description)
