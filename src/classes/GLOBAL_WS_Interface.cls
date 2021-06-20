public interface GLOBAL_WS_Interface {
    
    List<sObject> getRecords();
    sObject getRecord();
    
    String getAPIFieldNameSorting(); 
    String getConditionClause(); 
    String getSelectedFields(); 
    
    String getSObjectName(); 
    SObjectType getSObjectType();
    Map<String, Object> getJSONObject(sObject obj);
    Map<String, String> getFieldsNames();
    sObject getsObject(Map<String, Object> myMap);
    Object getJSONObjectList(List<sObject> objectList);
    
    Map<String, Object> getFullJSONObject(sObject obj);
    Map<String, String> getFullFieldsNames();
}