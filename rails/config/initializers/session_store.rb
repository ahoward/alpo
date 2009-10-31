# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_test_session',
  :secret      => '7b919f6f8d07a9582d584f3ca60f92577e415cbb8f418d0baa8f581aea6d2a444506ae720d4cfab8df9420be78587ac86eca3e1c6fd781622f2bfb0e6a458227'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
