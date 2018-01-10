return {
  {
    name = "2018-01-10-init_oauth2_social",
    up = [[
      CREATE TABLE IF NOT EXISTS social_oauth2_providers(
        id uuid,
        name text,
        client_id text,
        client_secret text,
        callback_uri text,
        authorization_uri text,
        token_uri text,
        profile_uri text,
        scopes text,
        logo text,
        created_at timestamp,
        PRIMARY KEY(id)
      );

      CREATE INDEX IF NOT EXISTS ON social_oauth2_providers(name);
      CREATE INDEX IF NOT EXISTS ON social_oauth2_providers(client_id);
      CREATE INDEX IF NOT EXISTS ON social_oauth2_providers(client_secret);
    ]],
    down = [[
      DROP TABLE social_oauth2_providers;
    ]]
  }
}
