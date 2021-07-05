public with sharing class WS_Contact extends GLOBAL_WS_ParentService{

	public static final String SOBJECT_NAME = 'Contact';

	public WS_Contact(RestRequest request, RestResponse response, String objectExtId){
		super(request,response, WS_Contact.class.getName(), objectExtId);
	}

	public override String getSObjectName(){
        return SOBJECT_NAME;
    }

    public override Map<String, String> getFieldsNames(){
    	Map<String, String> fieldsNames = new Map<String, String>();
    	fieldsNames.put('name', 'Name');
        fieldsNames.put('contactId', 'Id');
        fieldsNames.put('accountId', 'AccountId');
        fieldsNames.put('accountName', 'Account.Name');
    	return fieldsNames;
    }

    public override String getConditionClause(){
    	String filter = '';
        if(String.isNotBlank(this.objectExtId)){
    		filter += ' AND AccountId = \'' + this.objectExtId + '\' ';
    	}
        return filter;
    }

    public override Object getJSONObjectList(List<sObject> objectList){
        return super.getJSONObjectList(objectList);
    }
    
    public override Map<String, Object> getJSONObject(sObject obj){
    	Map<String, Object> myMap = super.getJSONObject(obj);
        return editObjectBeforeSending(myMap, obj);
    }
    
    public Map<String, Object> editObjectBeforeSending(Map<String, Object> myMap, sObject obj){
    	if(myMap != null){
    		myMap.put('nameExample', ((String)obj.get('Name')).substring(0,3));
    	}
    	return myMap;
    }
}