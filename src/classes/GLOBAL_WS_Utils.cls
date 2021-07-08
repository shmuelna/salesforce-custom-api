public class GLOBAL_WS_Utils {

	public static final String documentApiUrl = '/services/apexrest/api/contentDocument/';
    
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
        else if(serviceName == 'accounts'){
            if (relatedList == 'contacts'){
                return new WS_Contact(request, response, objectExtId);
            }
            else{
                return new WS_Account(request, response,objectExtId, true);
            }
        }
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

	public static WrapperContentDocuments getContentDocuments(String sobjectIdField, List<sObject> objectList){
        
        Set<Id> relatedIds = new Set<Id>();
        WrapperContentDocuments wcd = new WrapperContentDocuments();
        
        if(objectList != null && !objectList.isEmpty()){
        	for(sObject obj : objectList){
                relatedIds.add((String)obj.get(sobjectIdField));
            }
        }
        //Key: sobjectIdField.Id - Value: Related ContentDocumentLinks
        wcd.contentDocumentLinksByObjectId = !relatedIds.isEmpty() ? getObjectFileLinkMap(relatedIds) : new Map<Id, List<ContentDocumentLink>>();
        Set<Id> docIds = new Set<Id>();
        for (List<ContentDocumentLink> links : wcd.contentDocumentLinksByObjectId.values()){
            for (ContentDocumentLink link : links){
                docIds.add(link.ContentDocumentId);
            }
        }
        //Key: ContentDocument.Id. Value: ContentDocument
        wcd.contentDocumentsBycontentDocumentId = !docIds.isEmpty() ? new Map<Id, ContentDocument>(getContentDocumentsById(docIds)) : new Map<Id, ContentDocument>();
        
        return wcd;
    }
    
    public static Map<Id, List<ContentDocumentLink>> getObjectFileLinkMap(Set<Id> objIds){
        Map<Id, List<ContentDocumentLink>> objMap = new Map<Id, List<ContentDocumentLink>>();
        List<ContentDocumentLink> links = [SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.FileExtension FROM ContentDocumentLink WHERE LinkedEntityId IN :objIds];
        for (ContentDocumentLink cdl : links){
            List<ContentDocumentLink> cdls = objMap.get(cdl.LinkedEntityId);
            if (cdls == null){
                objMap.put(cdl.LinkedEntityId, new List<ContentDocumentLink>());
            }
            objMap.get(cdl.LinkedEntityId).add(cdl);
        }
        return objMap;
    }
    
    public static List<ContentDocument> getContentDocumentsById(Set<Id> docIds){
        return getContentDocumentsById(docIds, null);
    }

	public static List<ContentDocument> getContentDocumentsById(Set<Id> docIds, String additionalFields){
        String queryStr = 'SELECT Id, Description, Title, FileType, FileExtension, LatestPublishedVersionId, LatestPublishedVersion.CreatedDate, ';
        queryStr += ' LatestPublishedVersion.Status__c ';
        if (String.isNotBlank(additionalFIelds)){
            queryStr += additionalFields;
        }
		queryStr += ' FROM ContentDocument ';
		queryStr += ' WHERE Id IN :docIds';
		return Database.query(queryStr);
	}
	
    public class WrapperContentDocuments{
        Map<Id, List<ContentDocumentLink>> contentDocumentLinksByObjectId {get;set;}
        Map<Id, ContentDocument> contentDocumentsBycontentDocumentId {get;set;}
    }
    
    public static void addFilesToJsonObject(String sobjectIdField, WrapperContentDocuments wcd, Map<String, Object> myMap, sObject obj){
        try{
            List<ContentDocument> contentDocuments = new List<ContentDocument>();
            List<ContentDocumentLink> cdls = wcd.contentDocumentLinksByObjectId.get((String)obj.get(sobjectIdField));
            if (cdls != null){
                for (ContentDocumentLink cdl : cdls){
                    ContentDocument tmp = wcd.contentDocumentsBycontentDocumentId.get(cdl.ContentDocumentId);
                    if(tmp != null){
                    	contentDocuments.add(tmp);   
                    }
                }
            }
            if (contentDocuments != null && contentDocuments.size() > 0){
                List<Object> fileList = new List<Object>();
                for (ContentDocument doc : contentDocuments){
                    Map<String, object> tmpFile = new Map<String, object>();
                    tmpFile.put('title', doc.Title);
                    tmpFile.put('fileType', doc.FileType);
                    tmpFile.put('fileExtension', doc.FileExtension);
                    if (doc.LatestPublishedVersion != null && doc.LatestPublishedVersion.CreatedDate != null){
                        tmpFile.put('fileDate', doc.LatestPublishedVersion.CreatedDate);
                    }
                    tmpFile.put('downloadLink', documentApiUrl + doc.id);
                    fileList.add(tmpFile);
                }
                myMap.put('files', fileList);
            }
        }
        catch(Exception e){
            system.debug('**ERROR**' + e);
        }
    }
}