public with sharing class GLOBAL_DAL {
    
    public class SelectObjectFunctionWrapper{
    	public String objectName {set; get;}
    	public String fieldName {set; get;}
    	public object value {set; get;}
    	public boolean isDesc {set; get;}
    	public Id lastId {set; get;}
    	public String myFilter {set; get;}
    	public Integer numOfResult {set; get;}
    	public String selectedFields {set; get;}
    	public String searchWord {set; get;}
        public String orderBy {set; get;}
    	
    	public SelectObjectFunctionWrapper(){
    		
    	}
    }
    
    public static List<SObject> selectObjectsByChunk(SelectObjectFunctionWrapper sofw){
    	if(sofw != null){
    		return selectObjectsByChunk(sofw.objectName, sofw.fieldName, sofw.value, sofw.isDesc, sofw.lastId, sofw.myFilter, sofw.numOfResult, sofw.selectedFields, sofw.searchWord, sofw.orderBy);
    	}
    	return null;
    }
    
    public static List<SObject> selectObjectsByChunk(string objectName, string fieldName, object value, boolean isDesc, Id lastId, string myFilter, Integer numOfResult, String selectedFields, String searchWord, String orderBy){
        String queryStr = 'select ' + selectedFields + ' from  ' + objectName ;
        if(String.isNotBlank(fieldName) && value != null){
        	if(isDesc){
        		queryStr += ' Where ( ' + fieldName + ' < :value or (' + fieldName + ' = :value and Id > :lastId ) ';
                //if (Utils.isNumber(value) && value == 0){
                //    queryStr += ' or (' + fieldName + ' = null ) ';
                //}
            }
        	else{
        		queryStr += ' Where ( ' + fieldName + ' > :value or (' + fieldName + ' = :value and Id > :lastId ) ';
            }
            queryStr += ' )' ;
        }
        else{
        	queryStr += ' Where  Id > :lastId ';
            //if (String.isNotBlank(fieldName) && value == null && isDesc){
            //    queryStr += ' and ' + fieldName + ' = null ';
            //}
        }
        if(String.isNotBlank(searchWord)){
        	queryStr += ' AND Name Like \'%' + searchWord + '%\' '; 
        }
        if (String.isNotBlank(myFilter)){
            queryStr += myFilter;
        }
        
        //order by
        queryStr += ' order by ';
        if (String.isNotBlank(orderBy)){
            queryStr += orderBy;
        }
        if(String.isNotBlank(fieldName)){
        	queryStr += fieldName;
	        if(isDesc){
	        	queryStr += ' desc NULLS LAST, Id ';
	        }
	        else{
	        	queryStr += ' asc NULLS LAST, Id ';
	        }
        }
        if (String.isBlank(orderBy) && String.isBlank(fieldName)){
        	queryStr += ' Id ';
        }
        
        if(numOfResult != null){
        	queryStr += ' LIMIT :numOfResult';
        }
        system.debug('queryStr');
		system.debug(queryStr);
		system.debug(String.format('fieldName :{0}, value: {1}, lastId: {2}', new List<String> {fieldName, String.valueOf(value), lastId}));
        if (myFilter != null){
            system.debug('searchWord');
            system.debug( searchWord);
        }
        
        List<SObject> LmLKr = Database.query(queryStr);
        return LmLKr;
    }

    public static List<User> getUsers(String fields, Boolean isActive, String username, String profileName){
        if (String.isBlank(fields)){
            return null;
        }
        String queryStr = ' SELECT ';
        queryStr += fields;
        queryStr += ' FROM User WHERE Id != null ';
        if (isActive){
            queryStr += ' AND IsActive = true ';
        }
        if (String.isNotBlank(username)){
            queryStr += ' AND Username = :userName ';
        }
        if (String.isNotBlank(profileName)){
            queryStr += ' AND Profile.Name = :profileName ';
        }
        return Database.query(queryStr);
    }
    
    public static List<User> getUsersByPermissionSet(String fields, Boolean isActive, String username, String permissionSetName){
        if (String.isBlank(fields)){
            return null;
        }
        String queryStr = ' SELECT ';
        queryStr += fields;
        queryStr += ' FROM User WHERE Id != null ';
        if (isActive){
            queryStr += ' AND IsActive = true ';
        }
        if (String.isNotBlank(username)){
            queryStr += ' AND Username = :userName ';
        }
        if (String.isNotBlank(permissionSetName)){
            queryStr += ' AND Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = :permissionSetName )';
        }
        return Database.query(queryStr);
    }

    public static List<Contact> getContactsByIds(String fields, Set<Id> idSet){
        String queryStr = 'SELECT Id ';
        if (String.isNotBlank(fields)){
            queryStr += ', ' + fields;
        }
        queryStr += ' FROM Contact ';
        if (idSet != null && idSet.size() > 0){
            queryStr += ' WHERE Id IN :idSet ';
        }
        return Database.query(queryStr);
    }
}