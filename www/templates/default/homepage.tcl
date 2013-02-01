## Parametri richiesti ##
# object_id:integer
# locale:optional
  
set cms_root_folder [jrcms::folder_id]

set folder_id [fs::get_folder -name [string tolower "Homepage"] -parent_id $cms_root_folder]

set files [db_list query "select file_id from fs_files where parent_id = :folder_id order by name asc"]


set images [list]

foreach file_id $files {

    jrcms::fs::get_file -item_id $file_id -array file
    
    if {[regexp {(^image)(.*)} $file(type) match file_type]} {
	if {$file(url) ne ""} {
	    lappend images $file(url)
	}
    }
}
  
