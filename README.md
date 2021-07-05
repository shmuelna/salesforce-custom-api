# salesforce-custom-api
Create a new Digital Experience (Customer Account Portal is good)
activate it
add the profile to the members of the Digital Experience
add the class GLOBAL_WS_Login to the plubic access settings
add a remote site setting of the new site

if the user is internal user, you must add the security token to the password
the login url is:
https://{{url of the new community}}/services/apexrest/api/login

Body:
{
    "username":"{{Your Username}}", 
    "password":"{{Your password (and security token if you have)}}"
}


Response:
{
"sessionId": "00D1ddfXf000DSV!SSSSSSSSSSSSSSSSSSSSSSSSSSSSFDFDDDDDDDDDD"
}


Add the "Apex REST Services" in system permission of the Profile or Permission Set assigned to the Api Users 







