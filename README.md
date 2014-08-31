phone_home
==========

An alternative to using dynamic dns for connecting to your home location.

How
===

Phone Home stores location ips in a single redis hash at key `locations`

Endpoints
=========

* GET "/track" - Returns JSON of all locations
* GET "/track/:location" - return the ip for a registered location as text
* POST "/track/:location" - store the remote addr ip for a location
* DELETE "/track/:location" - remove the location

Sample Use
==========

Keeping your IP up to date, in a crontab:
```
*/30 * * * * curl -X POST https://:password@app.herokuapp.com/track/home > /dev/null 2>&1
```

Getting the ip:
```shell
curl -s https://:password@app.herokuapp.com/track/home
```
