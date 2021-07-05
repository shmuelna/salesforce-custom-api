public with sharing class WS_Account extends GLOBAL_WS_ParentService{

	public static final String SOBJECT_NAME = 'Account';

	public WS_Account(RestRequest request, RestResponse response, String objectExtId){
		super(request,response, WS_Account.class.getName(), objectExtId);
	}

	public override String getSObjectName(){
        return SOBJECT_NAME;
    }

    public override Map<String, String> getFieldsNames(){
    	Map<String, String> fieldsNames = new Map<String, String>();
    	fieldsNames.put('name', 'Name');
    	fieldsNames.put('accountId', 'Id');
    	return fieldsNames;
    }

    public override String getConditionClause(){
    	String filter = '';
        if(String.isNotBlank(this.objectExtId)){
    		String extId = this.objectExtId;
    		filter += ' AND Id = \'' + this.objectExtId + '\' ';
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