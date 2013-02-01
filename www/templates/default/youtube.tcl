## Parametri richiesti ##
# object_id:integer
# locale:optional

jrcms::api::youtube::get -item_id $object_id -locale $locale -array object

set youtube_code $object(youtube_code)

if {![regexp {(^http://)(.*)} $youtube_code match http rest]} {
    set youtube_frame $youtube_code
} else {
    set youtube_frame "<iframe width='450' height='360' src='$youtube_code' frameborder='0' allowfullscreen></iframe>"
}

regsub -all {\r} $object(description) "<br/>" object(description)

