return {
  {
    name = "2018-01-10-init_oauth2_social",
    up = [[
      CREATE TABLE IF NOT EXISTS social_oauth2_providers(
        id uuid,
        name text UNIQUE,
        client_id text UNIQUE,
        client_secret text UNIQUE,
        callback_uri text,
        authorization_uri text,
        token_uri text,
        profile_uri text,
        scopes text,
        logo text,
        created_at timestamp without time zone default (CURRENT_TIMESTAMP(0) at time zone 'utc'),
        PRIMARY KEY(id)
        );

        DO $$
          BEGIN
            IF (SELECT to_regclass('social_oauth2_providers_name_idx')) IS NULL THEN
              CREATE INDEX social_oauth2_providers_name_idx ON social_oauth2_providers(name);
            END IF;
            IF (SELECT to_regclass('social_oauth2_providers_client_idx')) IS NULL THEN
              CREATE INDEX social_oauth2_providers_client_idx ON social_oauth2_providers(client_id);
            END IF;
            IF (SELECT to_regclass('social_oauth2_providers_client_secret_idx')) IS NULL THEN
              CREATE INDEX social_oauth2_providers_client_secret_idx ON social_oauth2_providers(client_secret);
            END IF;
        END$$;
    ]],
    down = [[
      DROP TABLE social_oauth2_providers;
    ]]
  }
}
