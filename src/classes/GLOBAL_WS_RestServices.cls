@RestResource(urlMapping='/api/*/*')
global with sharing class GLOBAL_WS_RestServices{
    
    @HttpGet
    global static void mGet(){
    	try{
	        system.debug(JSON.serialize(RestContext.request.params));
	        GLOBAL_RestClient service = GLOBAL_WS_Utils.getService(RestContext.request, RestContext.response);
	        RestContext.response.addHeader('Content-Type', 'application/json');
	        if (service == null) {
	            RestContext.response.statusCode = 404;
	            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new GLOBAL_RestClient.RestResult(false, null)));
	            GLOBAL_WS_Utils.addWSLog(RestContext.request.requestURI, json.serialize(RestContext.request.params), null, RestContext.response.responseBody.toString());
	            return;
	        } 
	        
	        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(service.get()));
	        GLOBAL_WS_Utils.addWSLog(RestContext.request.requestURI, json.serialize(RestContext.request.params), null, RestContext.response.responseBody.toString());
    	}
    	catch(Exception e){
    		system.debug(e.getMessage());
    		RestContext.response.statusCode = 500;
	        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new GLOBAL_RestClient.RestResult(false, 'Internal Server Error - please try again later')));
	        GLOBAL_WS_Utils.addWSLog(RestContext.request.requestURI, json.serialize(RestContext.request.params), null, 'Internal Server Error', e.getMessage());
    	}
    }
    /*
    @HttpPost
    global static void mPost(){
        system.debug('@@@@ +++ ' + RestContext.request.requestBody.tostring());
        GLOBAL_RestClient service = getService(RestContext.request, RestContext.response);
        RestContext.response.addHeader('Content-Type', 'application/json');
        if (service == null) {
            RestContext.response.statusCode = 404;
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new GLOBAL_RestClient.RestResult(false, null)));
            GLOBAL_WS_Utils.addWSLog(RestContext.request.requestURI, json.serialize(RestContext.request.params), RestContext.request.requestBody.tostring(), RestContext.response.responseBody.toString());
            return;
        }

        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(service.post())); 
        GLOBAL_WS_Utils.addWSLog(RestContext.request.requestURI, json.serialize(RestContext.request.params), RestContext.request.requestBody.tostring(), RestContext.response.responseBody.toString());
    }
    */
}