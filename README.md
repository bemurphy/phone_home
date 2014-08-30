phone_home
==========

An alternative to using dynamic dns for connecting to your home location.

How
===

Phone Home stores location ips in a single redis hash at key `locations`

Endpoints
=========

GET "/track" - Show a JSON hash of all locations
GET "/track/:location" - return the ip for a registered location
POST "/track/:location" - store the remote addr ip for a location
