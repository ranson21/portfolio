CREATE TABLE accounts.application (
  id integer NOT NULL PRIMARY KEY,
  name varchar(30),
  -- Auditing Columns
  "created_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "created_by" integer NOT NULL,
  "updated_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "updated_by" integer NOT NULL
);

CREATE TABLE accounts.identities (
  id integer NOT NULL PRIMARY KEY,
  name varchar(100) NOT NULL,
  "type" varchar(30) DEFAULT 'external',
  -- Auditing Columns
  "created_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "created_by" integer NOT NULL,
  "updated_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "updated_by" integer NOT NULL
);

CREATE TABLE accounts.login (
  id integer NOT NULL PRIMARY KEY,
  login_time timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  account_id integer NOT NULL FOREIGN KEY REFERENCES accounts.account (id),
  status varchar(10) DEFAULT 'pending',
  -- Auditing Columns
  "created_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "created_by" integer NOT NULL,
  "updated_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "updated_by" integer NOT NULL
);

CREATE TABLE accounts.member_identities (
  id integer NOT NULL PRIMARY KEY,
  member_id integer NOT NULL FOREIGN KEY REFERENCES accounts.member (id),
  identity_id integer NOT NULL FOREIGN KEY REFERENCES accounts.identities (id),
  provider_id integer NOT NULL,
  -- Auditing Columns
  "created_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "created_by" integer NOT NULL,
  "updated_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "updated_by" integer NOT NULL
);

CREATE TABLE accounts.members (
  id integer NOT NULL PRIMARY KEY,
  display_name varchar(100),
  username varchar(100),
  -- Auditing Columns
  "created_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "created_by" integer NOT NULL,
  "updated_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "updated_by" integer NOT NULL
);

CREATE TABLE accounts.permission (
  id integer NOT NULL PRIMARY KEY,
  name varchar(100),
  "group" varchar(30),
  -- Auditing Columns
  "created_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "created_by" integer NOT NULL,
  "updated_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "updated_by" integer NOT NULL
);

CREATE TABLE accounts.product (
  id integer NOT NULL PRIMARY KEY,
  name varchar,
  COST decimal,
  -- Auditing Columns
  "created_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "created_by" integer NOT NULL,
  "updated_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "updated_by" integer NOT NULL
);

CREATE TABLE accounts."role" (
  id integer NOT NULL PRIMARY KEY,
  name varchar,
  -- Auditing Columns
  "created_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "created_by" integer NOT NULL,
  "updated_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "updated_by" integer NOT NULL
);

CREATE TABLE accounts.role_permissions (
  id integer NOT NULL PRIMARY KEY,
  role_id integer NOT NULL FOREIGN KEY REFERENCES accounts."role" (id),
  permission_id integer NOT NULL FOREIGN KEY REFERENCES accounts.permission (id),
  -- Auditing Columns
  "created_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "created_by" integer NOT NULL,
  "updated_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "updated_by" integer NOT NULL
);

CREATE INDEX idx_role_permissions_role_id ON accounts.role_permissions (role_id);

CREATE INDEX idx_role_permissions_permission_id ON accounts.role_permissions (permission_id);

CREATE TABLE accounts.account (
  id integer NOT NULL PRIMARY KEY,
  name varchar(100),
  "type" varchar(30) DEFAULT 'personal',
  -- Auditing Columns
  "created_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "created_by" integer NOT NULL,
  "updated_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "updated_by" integer NOT NULL
);

CREATE TABLE accounts.account_roles (
  id integer NOT NULL PRIMARY KEY,
  account_id integer NOT NULL FOREIGN KEY REFERENCES accounts.account (id),
  role_id integer NOT NULL FOREIGN KEY REFERENCES accounts."role" (id),
  -- Auditing Columns
  "created_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "created_by" integer NOT NULL,
  "updated_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "updated_by" integer NOT NULL
);

CREATE TABLE accounts.license (
  id integer NOT NULL PRIMARY KEY,
  start_date date,
  end_date date,
  "type" varchar(30) DEFAULT 'standard',
  "owner" integer FOREIGN KEY REFERENCES accounts.account (id),
  product_id integer FOREIGN KEY REFERENCES accounts.product (id),
  application_id integer NOT NULL FOREIGN KEY REFERENCES accounts.application (id),
  -- Auditing Columns
  "created_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "created_by" integer NOT NULL,
  "updated_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "updated_by" integer NOT NULL
);

CREATE TABLE accounts.member_accounts (
  id integer NOT NULL PRIMARY KEY,
  member_id integer NOT NULL FOREIGN KEY REFERENCES accounts.members (id),
  account_id integer NOT NULL FOREIGN KEY REFERENCES accounts.account (id),
  "primary" boolean DEFAULT FALSE NOT NULL UNIQUE,
  "type" varchar(30) DEFAULT "account_owner",
  -- Auditing Columns
  "created_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "created_by" integer NOT NULL,
  "updated_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "updated_by" integer NOT NULL
);

CREATE TABLE accounts.account_licenses (
  id integer NOT NULL PRIMARY KEY,
  account_id integer NOT NULL FOREIGN KEY REFERENCES accounts.account (id),
  license_id integer NOT NULL FOREIGN KEY REFERENCES accounts.license (id),
  -- Auditing Columns
  "created_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "created_by" integer NOT NULL,
  "updated_at" timestamptz(12) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "updated_by" integer NOT NULL
);

CREATE INDEX idx_account_licenses_account_id ON accounts.account_licenses (account_id);

CREATE INDEX idx_account_licenses_license_id ON accounts.account_licenses (license_id);

