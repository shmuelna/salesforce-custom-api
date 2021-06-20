public class GLOBAL_WS_Utils {

    public static void addWSLog(String url, String params, String body, String response){
        addWSLog(url, params, body, response, null);
    }
    
    @future
    public static void addWSLog(String url, String params, String body, String response, String errorMessage){
        if(Test.isRunningTest()){
            return;
        }
        /*
        API_Log__b wsLog = new API_Log__b();
        wsLog.Url__c = url;
        wsLog.Params__c = params;
        wsLog.Body__c = body;
        wsLog.Response__c = response;
        wsLog.ErrorMessage__c = errorMessage;
        wsLog.User__c = UserInfo.getUserId();
        wsLog.CreatedDate__c = DateTime.now();
        Database.insertImmediate(wsLog);
        //*/
    } 

    public static GLOBAL_RestClient getService(RestRequest request, RestResponse response){
        String serviceName = GLOBAL_RestClient.getServiceName(request.requestURI);
        String objectExtId = GLOBAL_RestClient.getObjectExtId(request.requestURI);
        String relatedList = GLOBAL_RestClient.getRelatedListName(request.requestURI);
        system.debug(serviceName);
        system.debug(objectExtId);
        
        if (serviceName == 'picklist'){
            return new GLOBAL_WS_Picklist(request, response, objectExtId);
        }
        /*
        else if(serviceName == 'organizations'){
            if (relatedList == 'users'){
                return new GSTAR_WS_MalkarAdminUser(request, response, objectExtId);
            }
            else if( relatedList =='malkarPeople'){
                return new GSTAR_WS_MalkarAdminContact(request, response, objectExtId);
            }
            else if (relatedList == 'reports'){
                return new GSTAR_WS_MalkarReports(request, response, objectExtId);
            }
            else if (relatedList == 'branches'){
                return new GSTAR_WS_MalkarBranch(request, response, objectExtId);
            }
            else{
                return new GSTAR_WS_Malkar(request, response, objectExtId);
            }
        }
        else if (serviceName == 'contacts'){
            return new GLOBAL_WS_Contact(request,response, objectExtId);
        }
        else if (serviceName == 'organizationUsers'){
            return new GSTAR_WS_MalkarAdminUser(request,response, objectExtId);
        }
        else if (serviceName == 'organizationMalkarPeople'){
            return new GSTAR_WS_MalkarAdminContact(request,response, objectExtId);
        }
        else if (serviceName == 'organizationReports'){
            return new GSTAR_WS_MalkarReports(request,response, objectExtId);
        }
        else if (serviceName == 'organizationBranches'){
            return new GSTAR_WS_MalkarBranch(request,response, objectExtId);
        }
        else if (serviceName == 'jointSupportRequests'){
            return new GSTAR_WS_JointSupportRequest(request,response, objectExtId);
        }
        else if (serviceName == 'koronaSupportRequests'){
            return new GSTAR_WS_KoronaSupportRequest(request,response, objectExtId);
        }
        //*/
        else{
            return null;
        }
    }

    public static object getRealObject(object value, String sObjectName, String fieldName){
    	if(value != null){
	    	Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName);
			Schema.DescribeSObjectResult r = t.getDescribe();
			Schema.DescribeFieldResult f = r.fields.getMap().get(fieldName).getDescribe();
			try{
				if (f.getType() == Schema.DisplayType.String){
					//no need to convert it
				    //return String.valueOf(value);
				}
				else if (f.getType() == Schema.DisplayType.Date){
				    return DateTime.valueOf(value);
				}
				else if (f.getType() == Schema.DisplayType.DateTime){
					String UTCString = (String) value;
					if(UTCString.contains('T')){
						UTCString = UTCString.replaceAll('T', ' ');
					}
					if(UTCString.contains('.')){
						UTCString = UTCString.substring(0, UTCString.indexof('.'));
					}
	        		return DateTime.valueOfGmt(UTCString);
				}
				else if (f.getType() == Schema.DisplayType.Double){
				    return Double.valueOf(value);
				}
				else if (f.getType() == Schema.DisplayType.Integer){
				    return Integer.valueOf(value);
				}
				else if (f.getType() == Schema.DisplayType.Long){
				    return Double.valueOf(value).longValue();
				}
				else if (f.getType() == Schema.DisplayType.MultiPicklist){
				    //return DateTime.valueOf(value);
				}
				else if (f.getType() == Schema.DisplayType.Boolean){
				    return Boolean.valueOf(value);
				}
				else if (f.getType() == Schema.DisplayType.Currency){
				    return Double.valueOf(value);
				}
			}
			catch(Exception e){
				system.debug(e.getMessage());
			}
    	}
		return value;
    }
}