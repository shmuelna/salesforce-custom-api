public with sharing abstract class GLOBAL_RestClient {
    protected RestRequest request;
    protected RestResponse response;

    public GLOBAL_RestClient (RestRequest request, RestResponse response) {
        this.request = request;
        this.response = response;
        for(String paramKey : request.params.keySet()){
        	String value = request.params.get(paramKey);
        	request.params.put(paramKey, value != null ? String.escapeSingleQuotes(value) : null);
        }
    }

    public abstract object get();
    public abstract object post();
    
    public class RestResult {
        public RestResult (Boolean success, String errorMsg) {
            this.success = success;
            //this.isLast = null;
            this.errorMsg = errorMsg;
            //this.result = data;
        }

        public Boolean success;
        //public Boolean isLast;
        public String errorMsg;
        //public Object result;
    }
    
    public void s200(){
    	response.statusCode = 200;
    }
    
    public object s400(){
    	response.statusCode = 400;
    	return new RestResult(false, 'Bad Request');
    }
    
    public object s401(){
    	response.statusCode = 401;
    	return new RestResult(false, 'Unauthorized');
    }
    
    public object s403(){
    	response.statusCode = 403;
    	return new RestResult(false, 'Forbidden');
    }
    
    public object s404(){
    	response.statusCode = 404;
    	return new RestResult(false, 'Not Found');
    }
    
    public object s405(){
    	response.statusCode = 405;
    	return new RestResult(false, 'Method Not Allowed');
    }
    
    public object s500(){
    	response.statusCode = 500;
    	return new RestResult(false, 'Internal Server Error');
    }
    
    public static String getServiceName(String uri){
        if(!String.isEmpty(uri)){
            String[] uriSplitted = uri.split('/');
            return uriSplitted.size() > 2 ? uriSplitted[2] : null;
        }
        else{
            return null;
        }
    }
    
    public static String getObjectExtId(String uri){
        if(!String.isEmpty(uri)){
            String[] uriSplitted = uri.split('/');
            return uriSplitted.size() > 3 ? uriSplitted[3] : null;
        }
        else{
            return null;
        }
    }

    public static String getRelatedListName(String uri){
        if (!String.isEmpty(uri)){
            String[] uriSplitted = uri.split('/');
            return uriSplitted.size() > 4 ? uriSplitted[4] : null;
        }
        else{
            return null;
        }
    }
}