public with sharing class GLOBAL_WS_Picklist extends GLOBAL_WS_ParentService{

	String picklistFieldName;

	public GLOBAL_WS_Picklist(RestRequest request, RestResponse response, String objectExtId){
		super(request,response, GLOBAL_WS_Picklist.class.getName(), objectExtId);
		picklistFieldName = GLOBAL_RestClient.getRelatedListName(request.requestURI);
	}

	public override String getSObjectName(){
        return objectExtId;
    }

    public override Map<String, String> getFieldsNames(){
    	Map<String, String> fieldsNames = new Map<String, String>();
    	fieldsNames.put(picklistFieldName, picklistFieldName);
    	return fieldsNames;
    }

    public virtual override object get(){
    	if(sobjectDescribe.isAccessible() && String.isNotBlank(objectExtId) && String.isNotBlank(picklistFieldName)){
	    	s200();
	    	system.debug('start get');
	    	system.debug(this.objectExtId);
	    	Map<String, String> fields = getFieldsNames();
	    	if (fields != null && fields.size() > 0 && String.isNotBlank(fields.values()[0])){
	    		Map<String, Map<String, String>> returnMap = new Map<String, Map<String, String>>();
	    		for (String fieldName : fields.values()){
		    		Schema.SObjectField field = fieldMapDescribe.get(fieldName);
		    		if(field != null){
		    			Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
		    			if(fieldDescribe.isAccessible()){
				    		Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectExtId);
						    Sobject Object_name = targetType.newSObject();
						  	Schema.sObjectType sobjType = Object_name.getSObjectType();
						    Schema.DescribeSObjectResult sobjDescribe = sobjType.getDescribe();
						    Map<String, Schema.SObjectField> fieldMap = sobjDescribe.fields.getMap();
						    if (fieldMap.get(fieldName) != null){
							    List<Schema.PicklistEntry> picklistValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
							    Map<String, String> tmpMap = new Map<String, String>();
							    for(Schema.PicklistEntry entry : picklistValues){
							    	tmpMap.put(entry.getLabel(), entry.getValue());
							    }
					    		returnMap.put(fieldName, tmpMap);
					    	}
					    }
					}
			    }
		    	return returnMap;
		    }
		    else{
		    	return s401();
		    }
    	}
    	else{
    		return s401();
    	}
    }

}