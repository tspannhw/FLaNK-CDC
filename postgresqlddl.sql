CREATE TABLE public.newjerseybus (
	title varchar(255) NULL,
	description varchar(255) NULL,
	link varchar(255) NULL,
	guid varchar(255) NULL,
	advisoryalert varchar(255) NULL,
	pubdate varchar(255) NULL,
	ts varchar(255) NULL,
	companyname varchar(255) NULL,
	uuid varchar(255) NULL,
	servicename varchar(255) NULL
);

CREATE TABLE public.newjerseytransit (
	title varchar(255) NOT NULL,
	description varchar(255) NOT NULL,
	link varchar(255) NULL,
	guid varchar(255) NULL,
	advisoryalert varchar(255) NULL,
	pubdate varchar(255) NOT NULL,
	ts varchar(255) NOT NULL,
	companyname varchar(255) NULL,
	uuid varchar(255) NOT NULL ,
	servicename varchar(255) NULL,
  CONSTRAINT "primary" PRIMARY KEY (uuid),
  UNIQUE (uuid)
);
