# Salesforce-custom-api
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

After the login the user get the option to use a diffrent services: 
you must to add HEADERS with Authorization and the sessionId for any next request. 
For example: 
Authorization Bearer 00D1ddfXf000DSV!SSSSSSSSSSSSSSSSSSSSSSSSSSSSFDFDDDDDDDDDD

## Examples of requests

#### PICKLIST:
https://[SalesforceOrg].force.com/egazette/services/apexrest/api/picklist/Account/AccountSource
Get all the picklist data from (key, value), in that example the request ask for AccountSource field from Account object

#### QUERY PARAMETERS:
Have an option to add qurery paramters to the object. 
By adding to query parameters 
filter = name= "ארכיון המדינה";accountId=:0011w00001E2pkQAAR,0011w00001E2pkQAAE
https://[SalesforceOrg].force.com/egazette/services/apexrest/api/accounts?filter=name="ארכיון המדינה";accountId=:0011w00001E2pkQAAR,0011w00001E2pkQAAE


#### GET ALL OBJECT DATA: 
For example if we want all the accounts:
https://[SalesforceOrg].cs105.force.com/egazette/services/apexrest/api/accounts

Get the data by account Id:
https://[SalesforceOrg].cs105.force.com/egazette/services/apexrest/api/accounts/

Get the contacts data from account by id: 
https://[SalesforceOrg].cs105.force.com/egazette/services/apexrest/api/accounts/0011w00001E2pkQAAR/contacts



