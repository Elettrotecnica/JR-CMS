begin;

--
-- Jacopo Rondinelli CMS
--
-- @author Antonio Pisano
--



-- Oggetti del CMS

select acs_object_type__create_type (
    'jr_object',          -- object_type
    'JR Object',          -- pretty_name
    'JR Objects',         -- pretty_plural
    'category',           -- supertype
    'jr_objects',         -- table_name
    'object_id',          -- id_column
    null,                 -- name_method
    'f',
    null,
    null
);

-- Ogni oggetto del cms avrà una thumbnail
create table jr_objects (
       object_id     integer primary key references categories(category_id) on delete cascade,
       thumbnail_id  integer references cr_items(item_id)
);



-- Articolo

select acs_object_type__create_type (
    'jr_article',          -- object_type
    'JR Article',          -- pretty_name
    'JR Articles',         -- pretty_plural
    'jr_object',           -- supertype
    'jr_articles',         -- table_name
    'article_id',          -- id_column
    null,                  -- name_method
    'f',
    null,
    null
);

-- Un articolo è un oggetto con allegato un testo html
create table jr_articles (
       article_id       integer primary key references jr_objects(object_id) on delete cascade,
       html_text        text
);



-- Oggetto multimediale

select acs_object_type__create_type (
    'jr_multimedia',     -- object_type
    'JR Multimedia',     -- pretty_name
    'JR Multimedia',     -- pretty_plural
    'jr_object',         -- supertype
    'jr_multimedia',     -- table_name
    'multimedia_id',     -- id_column
    null,                -- name_method
    'f',
    null,
    null
);

-- Un oggetto multimediale è un oggetto con un file allegato.
create table jr_multimedia (
       multimedia_id  integer primary key references jr_objects(object_id) on delete cascade,
       file_id        integer references cr_items(item_id)
);



-- Youtube

select acs_object_type__create_type (
    'jr_youtube',        -- object_type
    'JR Youtube',        -- pretty_name
    'JR Youtubes',       -- pretty_plural
    'jr_object',         -- supertype
    'jr_youtubes',       -- table_name
    'youtube_id',        -- id_column
    null,                -- name_method
    'f',
    null,
    null
);

-- Un oggetto youtube è un oggetto con un codice di inclusione Youtube allegato.
create table jr_youtubes (
       youtube_id       integer primary key references jr_objects(object_id) on delete cascade,
       youtube_code     varchar(600)
);



-- Galleria di oggetti

select acs_object_type__create_type (
    'jr_gallery',           -- object_type
    'JR Gallery',           -- pretty_name
    'JR Galleries',         -- pretty_plural
    'jr_object',            -- supertype
    'jr_galleries',         -- table_name
    'gallery_id',           -- id_column
    null,                   -- name_method
    'f',
    null,
    null
);

-- Al momento la galleria non contiene alcuna informazione aggiuntiva...
create table jr_galleries (
       gallery_id       integer primary key references jr_objects(object_id) on delete cascade
);


end;