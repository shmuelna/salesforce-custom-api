@RestResource(urlMapping='/api/login')
global with sharing class GLOBAL_WS_Login{
	    
    @HttpPost
    global static void mPost(){
		object loginRes = login(RestContext.request, RestContext.response);
		RestContext.response.addHeader('Content-Type', 'application/json');
		if(loginRes != null){
			RestContext.response.responseBody = Blob.valueOf(JSON.serialize(loginRes));
		}
    }
    
    public static object login(RestRequest request, RestResponse response){
    	if(request.requestBody != null){
    		try{ 
				LoginCredentials lc = (LoginCredentials) Json.deserialize(request.requestBody.tostring(), LoginCredentials.class);   
				if(String.isNotBlank(lc.username) && String.isNotBlank(lc.password)){
					String baseUrl = request.headers.get('Host');
					if(baseUrl != null){
						baseUrl = 'https://' + baseUrl;
					}
					else{
						response.statusCode = 500;
    					return new GLOBAL_RestClient.RestResult(false, 'Host Not Found');
					}
					String sessionId = GLOBAL_HttpRequests.getSessionFromSoapResponse(GLOBAL_HttpRequests.soapLogin(lc.username, lc.password, baseUrl));
	        		if(!String.isEmpty(sessionId)){
	        			response.statusCode = 200;
	        			return new map<String, String>{'sessionId' => sessionId};
	        		}
	        		else{
	        			return s400(response);
	        		}
				}
				else{
					return s400(response);
				}
    		}
    		catch(Exception e){return s400(response);}
    	}
    	else{
			return s400(response);
    	}
    }
    
    public static object s400(RestResponse response){
    	response.statusCode = 400;
    	return new GLOBAL_RestClient.RestResult(false, 'Bad Request');
    }
    
    
    public class LoginCredentials{
    	public String username {get;set;}
    	public String password {get;set;}
    }
}