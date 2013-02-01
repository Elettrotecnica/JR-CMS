begin;

--
-- Jacopo Rondinelli CMS
--
-- @author Antonio Pisano
--

-- Galleria

drop table jr_galleries;

select acs_object_type__drop_type('jr_gallery', 't');


-- Youtube

drop table jr_youtubes;

select acs_object_type__drop_type('jr_youtube', 't');


-- Multimedia

drop table jr_multimedia;

select acs_object_type__drop_type('jr_multimedia', 't');


-- Articolo

drop table jr_articles;

select acs_object_type__drop_type('jr_article', 't');


-- Restanti ggetti del CMS

drop table jr_objects;

select acs_object_type__drop_type('jr_object', 't');


end;