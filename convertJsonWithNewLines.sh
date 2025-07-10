#!/bin/bash

input_string="#kamon.datadog.hostname = \"datadog-monitoring.default\"\n#kamon.datadog.port
    = \"8125\"\n#kamon.datadog.application-name = \"snir-load-testing-2-auth-control\"\n#kamon.modules
    {\n#  kamon-datadog.auto-start = true\n#}\n#kamon {\n#      statsd {\n#             hostname
    = \"datadog-monitoring\"\n#              port = 8125\n#             }\n#  modules.kamonstatsd.autostart=
    yes\n#}\nts {\n  monitoring {\n    enabeld = false\n    promEndpoint = \"https://\"\n
    \   tenantId = test \n  }\n  actuator {\n    recovery {\n      enabled = true\n
    \     codeLength = 10\n      authentication {\n            tokenHash = \"$2a$10$GDbb4HKPpOMBu2Zje35//OfhdrAQu47zUP.Ywn8khKFLBJBAwu3ny\"\n
    \       }\n    }\n  }\n  policy.expressionCache {\n    enabled = true\n    maxCapacity
    = 10000\n    initialCapacity = 5000\n  }\n  profiling.location {\n    reverseGeocoder
    {\n      fsPollPeriod = \"30 second\"\n      citiesPath = \"config/location/geonames-db/cities500.txt\"\n
    \     adminCodesPath = \"config/location/geonames-db/admin1CodesASCII.txt\"\n
    \   },\n    ipGeocoder {\n      cityDbPath = \"/GeoLite2-City.mmdb\"\n      fsPollPeriod
    = \"1 day\"\n      timeout = \"60 seconds\"\n    }\n  }\n  fido2 {\n    metadata
    {\n      metadataPath = \"config/fido2-metadata-statements\"\n      # Enable the
    below flags for a less strict attestation certificate verification\n      disableCrlCheck
    = true\n      disablePolicyQualifiersRejection = true\n    }\n  }\n  session {\n
    \   expiryInSeconds = 3600\n  }\n  systemSettings {\n    refreshPeriod = 10 seconds\n
    \   refreshTimeout = 30 seconds\n  }\n  externalConnections {\n    loadingTimeout
    = \"60 seconds\"\n    refreshTimeout = \"60 seconds\"\n  }\n\n  localizationConfig
    {\n    loadTsKeysTimeout = 30 seconds\n  }\n  db {\n    config = {\n      database
    = \"snir-load-testing-2-auth-control-config\"\n      servers = [\"development-dedicated-o-shard-00-00-pri.wflhp.mongodb.net:27017\",
    \"development-dedicated-o-shard-00-01-pri.wflhp.mongodb.net:27017\", \"development-dedicated-o-shard-00-02-pri.wflhp.mongodb.net:27017\"]\n
    \     ssl.enabled = true\n      connections = 10\n      authentication = {\n        username
    = snir-load-testing-2-admin\n        password = ${MONGO_DB_PW}\n        database
    = \"admin\"\n        mode = \"sha1\"\n      }\n    }\n  }\n  operational {\n    config
    = {\n      database = \"snir-load-testing-2-auth-control\"\n      servers = [\"development-dedicated-o-shard-00-00-pri.wflhp.mongodb.net:27017\",
    \"development-dedicated-o-shard-00-01-pri.wflhp.mongodb.net:27017\", \"development-dedicated-o-shard-00-02-pri.wflhp.mongodb.net:27017\"]\n
    \     ssl.enabled = true\n      connections = 10\n      authentication = {\n        username
    = snir-load-testing-2-admin\n        password = ${MONGO_DB_PW}\n        database
    = \"admin\"\n        mode = \"sha1\"\n      }\n    }\n  }\n  server {\n    interfaces
    = [\n      {\n        routeTypes = [\"management_ui\", \"internal\", \"external\"]\n
    \       config = {\n          host = \"0.0.0.0\"\n          port = 8080\n          startTimeoutInSeconds
    = 5\n          ssl = null\n        }\n      },\n      {\n        routeTypes =
    [\"cluster\"]\n        config = {\n          host = \"0.0.0.0\"\n          port
    = 8090\n          startTimeoutInSeconds = 5\n          ssl = null\n        }\n
    \     }\n    ]\n    statusCheckConfig {\n      authentication {\n        enabled
    = true\n        tokenId = \"status\"\n        token = \"status\"\n      }\n    }\n
    \   logging {\n      infoHeaders {\n        X-Forwarded-For = true\n        User-Agent
    = true\n        Accept-Language = true\n      }\n      debugHeaders {\n        Cookie
    = true\n        Set-Cookie = true\n        Authorization = true\n      }\n      contextHeaders
    {\n        X-Forwarded-For = true\n        User-Agent = true\n      }\n    }\n
    \ }\n  websdk {\n    wwwPath = \"www/websdk\"\n  }\n  management {\n    wwwPath
    = \"www\"\n    metrics {\n      hostname = \"localhost\"\n      port = 80\n      ssl
    = false\n    }\n    administrators {\n      session {\n        origin = \"https://snir-load-testing-2.flexid-dev.com\"\n
    \       enableRefererHeaderValidation = false\n        #origin = \"*\"\n        expiryInSeconds
    = 36000\n      }\n    }\n    authScriptRefPath = \"www/authscript_ref\"\n    uiConfig
    {\n      monitoringDashboards = false\n      entitlementPath = \"https://snir-load-testing-2.flexid-dev.com/\"\n
    \     deploymentType = \"flexid\"\n      environmentType = \"dev\"\n    }\n  }\n
    \ deployment {\n    deploymentType = \"cloud\"\n    environmentType = \"dev\"\n
    \ }\n\n  # IMPORTANT - update the default secret with a random secret post installation.\n
    \ # MUST be identical across servers in the same cluster.\n  token.jwt.secret
    = \"/pfipLi2guvx9p3b3XTtfGg36JNqrR6T/ZPGNUc8bCY=\"\n\n  idp {\n    wwwPath = \"www/idp\"\n
    \   oidc {\n      authCodeExpiry = \"10\"\n    }\n  }\n  metrics {\n    engineType
    = \"prometheus\"\n    prometheus {\n      enabled = true\n      port = 9125\n
    \     buckets = [50, 100, 250, 500, 1500, 2000]\n      bucketsOverride = {\n        session
    = [500, 1000, 5000, 30000, 60000, 300000]\n       }\n    }\n    statsd {\n      enabled
    = false\n      hosts = [\"prometheus-statsd-exporter.monitoring\"]\n      port
    = 8125\n    }\n    jmx {\n      enabled = false\n    }\n    subscriptions {\n
    \     api = true\n      db = true\n      authenticator = true\n      device =
    true\n      function-provider = true\n      session = true\n      biometric-id-provider
    = true\n      email-provider = true\n      kyc-provider = true\n      sms-provider
    = true\n      user-provider = true\n      voice-provider = true\n    }\n  }\n
    \ security {\n    httpClient {\n      internalIpBlacklistConfig: {\n        ipBlacklist
    = [],\n        enabled = true\n      }\n    }\n  }\n  userLocking {\n    lockType
    = DbLock\n    lockExpiry = 15000\n    maxAttempts = 8\n    rateLimit = {\n      enabled
    = true\n      cacheMaxSize = 10000\n      limit = 10\n    }\n  }\n}\n"


# Replace escaped newlines and backslashes
cleaned_string=$(echo -e "$input_string" | sed -e 's/\\[n\\]//g')

# Convert cleaned string to a JSON object
json_string=$(echo "$cleaned_string" | jq -Rs 'split("\n") | map(select(length > 0)) | {data: .}')

echo "$json_string"