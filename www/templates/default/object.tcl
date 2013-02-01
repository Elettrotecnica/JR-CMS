## Parametri richiesti ##
# object_id:integer
# locale:optional

if {[exists_and_not_null object_id]} {
  
  # Recupero i dati dell'oggetto richiesto
  db_1row query "select object_type from acs_objects where object_id = :object_id"
  
  if {$object_type eq "jr_object"} {
      jrcms::api::object::get -item_id $object_id -locale $locale -array object
  }
  
}
