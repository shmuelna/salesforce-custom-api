@RestResource(urlMapping='/api/contentDocument/*')
global with sharing class GLOBAL_WS_ContentDocument{
    
    @HttpGet
    global static void mGet(){
        RestContext.response.addHeader('Content-Type', 'application/octet-stream');
        String serviceName = GLOBAL_RestClient.getServiceName(RestContext.request.requestURI);
        String objectExtId = GLOBAL_RestClient.getObjectExtId(RestContext.request.requestURI);
        if (objectExtId == null) {
            RestContext.response.statusCode = 400;
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new GLOBAL_RestClient.RestResult(false, null)));
            return;
        } 
        else{
            List<ContentDocument> cds = [select id, LatestPublishedVersion.VersionData from ContentDocument where id=: objectExtId];
            if(!cds.isEmpty()){
                RestContext.response.statusCode = 200;
                RestContext.response.responseBody = cds[0].LatestPublishedVersion.VersionData;
            }
            else{
               RestContext.response.statusCode = 404;
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new GLOBAL_RestClient.RestResult(false, null)));
                return; 
            }
        }
        
    }
    
}