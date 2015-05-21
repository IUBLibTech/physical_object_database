# Be sure to restart your server when you modify this file.

Pod::Application.config.session_store :cookie_store, key: '_pod_session', expire_after: 20.minutes
