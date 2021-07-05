public with sharing abstract class GLOBAL_WS_ParentService extends GLOBAL_RestClient implements GLOBAL_WS_Interface{
    
    public static final String IGNORESYNCDATE = 'ignoreSyncDate';
    public static final String KEEPFIELDS = 'keepFields';
    public static final String DEVICEID = 'deviceId';
    public static final String OBJID = 'objId';
    public static final String PAGEINDEX = 'pageIndex';
    public static final String BODY_RECORDS = 'records';
    
    public static final String LAST_VALUE = 'lastValue';
    public static final String ISDESC = 'isDesc';
    public static final String LASTID = 'lastId';
    public static final String NUMOFRESULT = 'numOfResult';
    public static final String SORT_FIELDNAME = 'sort';
    public static final String USER_FILTER = 'filter';
    public static final String FULL_OBJECT = 'fullObject';
    
    public Schema.DescribeSObjectResult sobjectDescribe;// = Schema.getGlobalDescribe().get(this.getSObjectName()).getDescribe();
    public Map<String,Schema.SObjectField> fieldMapDescribe;// = sobjectDescribe.fields.getMap();
    public List<Schema.ChildRelationship> fieldMapChildsDescribe;// = sobjectDescribe.getChildRelationships();
    public Boolean showFullObject;
    //public Map<String, String> _fieldsNames;
    
    public virtual String getAPIFieldNameSorting(){
        String sortFieldName = request.params.get(SORT_FIELDNAME);
    	String sortApiName = showFullObject ? this.getFullFieldsNames().get(sortFieldName) : this.getFieldsNames().get(sortFieldName);
    	if(String.isNotBlank(sortFieldName) &&  String.isNotBlank(sortApiName)){
    		return sortApiName;
    	}
        return 'Name';
    }
    
    public virtual String getConditionClause(){
    	return '';	
    }
    
    public virtual String getSelectedFields(){
    	Map<String, String> tmp;
    	if(showFullObject || String.isNotBlank(this.objectExtId)){
    		tmp = this.getFullFieldsNames();
    	}
    	else{
    		tmp = this.getFieldsNames();
    	}
    	
    	Map<String, String> fieldsNames = new Map<String, String>();
    	for(String fieldName : tmp.values()){
    		//check each field if he has access
    		Schema.SObjectField field = fieldMapDescribe.get(fieldName);
    		if(field != null){
    			Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
    			if(fieldDescribe.isAccessible()){
    				fieldsNames.put(fieldName, fieldName);
    				system.debug(fieldName + ' is accessible');
    			}
    			else{
    				system.debug(fieldName + ' is not accessible');
    			}
    		}
    		else if(fieldName.trim().startsWith('(')){
            	system.debug('start related list');
            	String apiNameRelated = fieldName;
            	Integer indexOfSelect = apiNameRelated.indexOfIgnoreCase('select'); 
            	Integer indexOfFrom = apiNameRelated.indexOfIgnoreCase('from'); 
            	if(indexOfFrom > 0){
            		apiNameRelated = apiNameRelated.substring(indexOfFrom + 4);
            		apiNameRelated = apiNameRelated.trim();
            		apiNameRelated = apiNameRelated.contains(' ') ? apiNameRelated.substring(0, apiNameRelated.indexOf(' ')) : apiNameRelated.substring(0, apiNameRelated.indexOf(')')) ;
            		Schema.ChildRelationship child = null;
            		for(Schema.ChildRelationship ch : fieldMapChildsDescribe){
            			if(ch.relationshipName != null && ch.relationshipName.equalsIgnoreCase(apiNameRelated)){
            				child = ch;
            				break;
            			}
            		}
            		if(child != null){
            			Schema.SObjectType relatedSobject = child.getChildSObject();
            			Schema.SObjectField  relatedSobjectField = child.getField();
            			Schema.DescribeFieldResult relatedSobjectFieldDescribe = relatedSobjectField != null ? relatedSobjectField.getDescribe() : null;
            			
            			if(relatedSobjectFieldDescribe != null && relatedSobjectFieldDescribe.isAccessible()){
            				Schema.DescribeSObjectResult relatedSobjectDescribe = relatedSobject != null ? relatedSobject.getDescribe() : null;
            				Map<String,Schema.SObjectField> fieldMapDescribeRelatedSobject = relatedSobjectDescribe != null ? relatedSobjectDescribe.fields.getMap() : null;
            				String childFieldsStr = fieldName.substring(indexOfSelect + 6, indexOfFrom -1);
            				List<String> childFields = childFieldsStr.split(',');
            				List<String> accessibleFields = new List<String>();
            				
            				if(relatedSobjectDescribe != null){
	            				for(String childField : childFields){
	            					childField = childField.trim();
	            					if(childField.contains('.')){
	            						
						                String[] apiNameSplitted = childField.split('\\.');
						                
						                Map<String,Schema.SObjectField> tmpsobjFields = fieldMapDescribeRelatedSobject; 
						                Schema.DescribeFieldResult fieldDescribeFromLookup = null;
						                Schema.SObjectField tmpField = null;
						                List<Schema.SObjectType> referenceTo;
						                Schema.SObjectType tmpReferenceTo = null;
						                Schema.DescribeSObjectResult tmpsobjResult = null;
						                Integer i = 0;
						                
						                for( ; i < (apiNameSplitted.size() - 1); i++){
						                	
					            			fieldDescribeFromLookup = getRelationshipFieldDescribe(apiNameSplitted[i], tmpsobjFields);
					            			referenceTo = fieldDescribeFromLookup != null ? fieldDescribeFromLookup.getReferenceTo() : null;               	
						                	tmpReferenceTo = referenceTo != null ? referenceTo[0] : null;
						                	tmpsobjResult = tmpReferenceTo != null ? tmpReferenceTo.getDescribe() : null;
            								tmpsobjFields = tmpsobjResult != null ? tmpsobjResult.fields.getMap() : null;
            								
            								system.debug(fieldDescribeFromLookup);
            								system.debug(referenceTo);
            								system.debug(tmpReferenceTo);
            								system.debug(tmpsobjResult);
            								system.debug(tmpsobjFields);
						                }
						                
						                tmpField = tmpsobjFields != null ? tmpsobjFields.get(apiNameSplitted[i]) : null;
					            		fieldDescribeFromLookup = tmpField != null ? tmpField.getDescribe() : null;
										if(fieldDescribeFromLookup != null && fieldDescribeFromLookup.isAccessible()){
					                		accessibleFields.Add(childField);
						                }						                	
						            }
						            else{
						                Schema.DescribeFieldResult fieldDescribeFromLookup = fieldMapDescribeRelatedSobject.containsKey(childField) ? fieldMapDescribeRelatedSobject.get(childField).getDescribe() : null;
		            					if(fieldDescribeFromLookup != null && fieldDescribeFromLookup.isAccessible()){
		            						accessibleFields.Add(childField);
		            					}
						            }
	            				}
	            				
	            				if(!accessibleFields.isEmpty()){
	            					String childFieldsStrAccessible = fieldName.substring(0, indexOfSelect + 6) + ' ' + String.join(accessibleFields, ' , ') + ' ' + fieldName.substring(indexOfFrom -1);
	            					fieldsNames.put(childFieldsStrAccessible, childFieldsStrAccessible);
	            				}
            				}
            			}
            		}
            	}
            	system.debug(apiNameRelated);
            	system.debug('end related list');
            }
    		else{
    			system.debug(fieldName + ' is not found in sobject');
    			fieldsNames.put(fieldName, fieldName);
    		}
    	}
    	fieldsNames.put('Name', 'Name');
        return String.join(fieldsNames.values(), ' , ');
    }
    
    public Schema.DescribeFieldResult getRelationshipFieldDescribe(String lookupFieldName, Map<String,Schema.SObjectField> sobjFields){
    	if(sobjFields != null && !sobjFields.isEmpty()){
    		for(Schema.SObjectField objField : sobjFields.values()){
    			Schema.DescribeFieldResult tmpFieldDescribe = objField.getDescribe();
    			String tmp = tmpFieldDescribe.getRelationshipName();
    			if(tmp != null && tmp.equalsIgnoreCase(lookupFieldName)){
    				return tmpFieldDescribe;
    			}
    		}
    	}
    	return null;
    }
    
    public abstract String getSObjectName();
    public abstract Map<String, String> getFieldsNames();
    public virtual Map<String, String> getFieldsNamesPost(){
    	return this.getFieldsNames();
    }
    
    public virtual List<sObject> getRecords(){
    	GLOBAL_DAL.SelectObjectFunctionWrapper sofw = new GLOBAL_DAL.SelectObjectFunctionWrapper();
        sofw.objectName = this.getSObjectName();
		sofw.fieldName = this.getAPIFieldNameSorting();
		object value = request.params.get(LAST_VALUE) != null ? EncodingUtil.urlDecode(request.params.get(LAST_VALUE), 'UTF-8') : null;
		sofw.value = GLOBAL_WS_Utils.getRealObject(value, sofw.objectName, sofw.fieldName);
		sofw.isDesc = request.params.get(ISDESC) != null ? Boolean.valueOf(request.params.get(ISDESC)) : false;
		sofw.lastId = request.params.get(LASTID) != null ? EncodingUtil.base64Decode(request.params.get(LASTID)).toString() : null;
		sofw.myFilter = this.getConditionClause();
        String userFilter = request.params.get(USER_FILTER);
		if(String.isNotBlank(userFilter)){
			String additionalFilters = parseFilter(userFilter);
			sofw.myFilter += additionalFilters;
		}
		sofw.numOfResult = request.params.get(NUMOFRESULT) != null ? Integer.valueOf(request.params.get(NUMOFRESULT)) : 200;
		sofw.selectedFields = this.getSelectedFields();
		//sofw.searchWord = searchWord;
        system.debug('getRecords');
        system.debug('sofw');
        system.debug(sofw);
        List<SObject> sobjs = GLOBAL_DAL.selectObjectsByChunk(sofw);
        
        system.debug('sobjs');
        system.debug(sobjs);
        return sobjs;
    }
    
    public String parseFilter(String userFilter){
        String filterStr = '';
        List<String> filters = userFilter.split(';');
        List<String> operators = new List<String>{'=:', '!=', '>=', '<=', '=', '>', '<'};
        for(String filter : filters){
            Integer indexOfOperator = -1;
            Integer length = filter.length();
            String subString = length > 2 ? filter.substring(1, length - 1) : '';
            for(String op : operators){
                if(subString.contains(op)){
                    List<String> filterParts = filter.split(op);
                    if(!filterParts.isEmpty() && filterParts.size() == 2){
                        filterStr += getFilter(filterParts[0], op, filterParts[1]);
                    }
                    break;
                }
            }
        }
        return filterStr;
    }
    
    public String getFilter(String fieldName, String operator, String value){
        String result = '';
        String apiName = showFullObject ? this.getFullFieldsNames().get(fieldName) : this.getFieldsNames().get(fieldName);
        system.debug('filter');
        system.debug(apiName);
        if(apiName != null){
        	if(operator == '=:'){
        		operator = 'IN';
        	}
            result += ' AND ' + apiName + ' ' + operator + ' ';
            Schema.SObjectField field = fieldMapDescribe.get(apiName);
            Schema.DescribeFieldResult fieldDescribe = field != null ? field.getDescribe() : null;
            Schema.DisplayType dt = fieldDescribe != null ? fieldDescribe.getType() : null;
            if(value.equalsIgnoreCase('null')
              || (dt != null && (dt == Schema.DisplayType.BOOLEAN 
				              || dt == Schema.DisplayType.CURRENCY
				              || dt == Schema.DisplayType.DATE
				              || dt == Schema.DisplayType.DATETIME
				              || dt == Schema.DisplayType.DOUBLE
				              || dt == Schema.DisplayType.INTEGER
				              || dt == Schema.DisplayType.LONG
				              || dt == Schema.DisplayType.PERCENT
				              || dt == Schema.DisplayType.TIME))){
              	if(operator == 'IN'){
              		result += ' (' + value + ') ';
              	}
              	else{
                	result += value + ' ';
              	}
            }
            else{
            	system.debug('it is a string');
            	if(operator == 'IN'){
              		result += ' (\'' + value.replaceAll(',', '\',\'') + '\') ';
              	}
              	else{
                	result += '\'' + value + '\' ';
              	}
            }
        }
        system.debug('result');
        system.debug(result);
        return result;
    }
    
    public virtual sObject getRecord(){
    	GLOBAL_DAL.SelectObjectFunctionWrapper sofw = new GLOBAL_DAL.SelectObjectFunctionWrapper();
        sofw.objectName = this.getSObjectName();
		sofw.myFilter = this.getConditionClause();
		sofw.selectedFields = this.getSelectedFields();
        List<SObject> sobjs = GLOBAL_DAL.selectObjectsByChunk(sofw);
        system.debug('end getRecord');
        system.debug(JSON.serialize(sobjs));
        return !sobjs.isEmpty() ? sobjs[0] : null;
    }
    
    public virtual Map<String, String> getFullFieldsNames(){
    	return this.getFieldsNames();
    }
    
    public virtual override object get(){
    	if(sobjectDescribe.isAccessible()){
	    	s200();
	    	system.debug('start get');
	    	system.debug(this.objectExtId);
	    	if(String.isBlank(this.objectExtId) || this.isRelatedList){
	    		List<sObject> lst = this.getRecords();
	    		String nextPageUrl = '/services/apexrest/' + request.requestURI;
	    		map<String, object> newParams = new map<String, object>();
	    		newParams.putAll(request.params);
		        if(!lst.isEmpty()){
		        	sObject lastObj = lst.get(lst.size() -1);	
		        	newParams.put(LASTID, EncodingUtil.base64Encode(Blob.valueOf((String)lastObj.get('Id'))));
		        }
		        
		        List<object> jsonLst = (List<object>) getJSONObjectList(lst);
		        if(!jsonLst.isEmpty()){
		        	newParams.put(LAST_VALUE, ((Map<String, Object>) jsonLst[jsonLst.size() - 1]).get(request.params.get(SORT_FIELDNAME)));
		        }
		        nextPageUrl += GLOBAL_HttpRequests.getParamsForURL(newParams);
	        	response.addHeader('Link', '<' + nextPageUrl + '>; rel="next"');
	        	system.debug(nextPageUrl);
	        	
		        return 	jsonLst;
	    	}
	    	else{
	    		sObject obj = this.getRecord();
	    		return obj != null ? this.getFullJSONObject(obj) : null;
	    	}
    	}
    	else{
    		return s401();
    	}
    }
    
    public virtual override object post(){
    	s200();
    	Object requestBody = Json.deserializeUntyped(request.requestBody.tostring());
        List<Object> objList = null;//CNT_WS_Utils.getListFromBody(requestBody, BODY_RECORDS);
        
        Map<String, object> objMap;
        if(objList == null){
        	objMap = null;//CNT_WS_Utils.getMapFromBody(requestBody, BODY_RECORDS);
        	if(objMap != null){
        		objList = objMap.values();
        	}
        }
        
		if(objList != null){
	        List<sObject> sobjList = upsertAndReorderDynamicList(objList);
	        // remove all the fields Except id fields
	        //Map<String, Object> objMap = CNT_WS_Utils.listToMap(objList, OBJID);
	        //--CNT_WS_Utils.clear(objList, getKeepFields());
	        
	        if(objMap != null){
            	return objMap;
            }
            else{
            	return objList;
            }
		}
		else{
			return s400();
		}
    }
    
    protected List<sObject> records;
    protected Set<Id> allIds;
    protected Set<Id> allIdsForThisPageIndex;
    //protected CNT_WebServiceSync__c myWSSync;
    
    public String className;
    public String objectExtId;
    public boolean isRelatedList;
    public GLOBAL_WS_ParentService(RestRequest request, RestResponse response, String className) {
        super(request,response);
        this.className = className;
        setSobjectDetails();
        this.showFullObject = request.params.get(FULL_OBJECT) != null ? Boolean.valueOf(request.params.get(FULL_OBJECT)) : false;
        //this._fieldsNames = this.getFieldsNames();
    }
    
    public GLOBAL_WS_ParentService(RestRequest request, RestResponse response, String className, String objectExtId) {
        super(request,response);
        this.className = className;
        this.objectExtId = objectExtId;
        setSobjectDetails();
        //this._fieldsNames = this.getFieldsNames();
        String relatedListName = GLOBAL_RestClient.getRelatedListName(request.requestURI);
        this.isRelatedList = String.isNotBlank(relatedListName);
        this.showFullObject = request.params.get(FULL_OBJECT) != null ? Boolean.valueOf(request.params.get(FULL_OBJECT)) : false;
    }

    public void setSobjectDetails(){
        this.sobjectDescribe = Schema.getGlobalDescribe().get(this.getSObjectName()).getDescribe();
        this.fieldMapDescribe = sobjectDescribe.fields.getMap();
        this.fieldMapChildsDescribe = sobjectDescribe.getChildRelationships();
    }
    
    public virtual SObjectType getSObjectType(){
        Schema.DescribeSObjectResult[] result = Schema.describeSObjects(new String[]{this.getSObjectName()});
        if(!result.isEmpty() && result[0].isAccessible()){
            return result[0].getSobjectType();
        }
        return null;
    }
    
    public virtual Map<String, Object> getJSONObject(sObject obj){
        if (showFullObject){
            return this.getJSONObject(obj, this.getFullFieldsNames());
        }
        else{
            return this.getJSONObject(obj, this.getFieldsNames());
        }
    }
    
    public virtual Map<String, Object> getFullJSONObject(sObject obj){
        return this.getJSONObject(obj, this.getFullFieldsNames());
    }
    
    public virtual Map<String, Object> getJSONObject(sObject obj, Map<String, String> fieldsName){
        Map<String, Object> JSONObj = new Map<String, Object>();
        for(String label : fieldsName.keySet()){
            string apiName = fieldsName.get(label);
            Schema.SObjectField field = fieldMapDescribe.get(apiName);
            Schema.DescribeFieldResult fieldDescribe = field != null ? field.getDescribe() : null;
            
            if(apiName.trim().startsWith('(')){
            	system.debug('start related list');
            	String apiNameRelated = apiName;
            	Integer indexOfFrom = apiNameRelated.indexOfIgnoreCase('from'); 
            	if(indexOfFrom > 0){
            		apiNameRelated = apiNameRelated.substring(indexOfFrom + 4);
            		apiNameRelated = apiNameRelated.trim();
            		apiNameRelated = apiNameRelated.contains(' ') ? apiNameRelated.substring(0, apiNameRelated.indexOf(' ')) : apiNameRelated.substring(0, apiNameRelated.indexOf(')')) ;
            		try{
						JSONObj.put(label, obj.getSObjects(apiNameRelated));            			
            		}
            		catch(Exception e){
            			system.debug(e.getMessage());
            		}
            	}
            	system.debug(apiNameRelated);
            	system.debug('end related list');
            }
            
            //apply restrictions on fields lookups
            else if(fieldDescribe == null || fieldDescribe.isAccessible()){
	            Object value;
	            if(apiName.contains('.')){
	                String[] apiNameSplitted = apiName.split('\\.');
	                sObject objTmp = obj.clone();
	                for(Integer i = 0 ; i < (apiNameSplitted.size() - 1) && objTmp != null ; i++){
	                    objTmp = objTmp.getSObject(apiNameSplitted[i]);
	                }
	                if(objTmp != null){
	                	Schema.DescribeSObjectResult sobjectDescribeFromLookup = objTmp.getSobjectType().getDescribe();
						Map<String,Schema.SObjectField> fieldMapDescribeFromLookup = sobjectDescribeFromLookup.fields.getMap();
						Schema.SObjectField fieldFromLookup = fieldMapDescribeFromLookup.get(apiNameSplitted[apiNameSplitted.size() - 1]);
						Schema.DescribeFieldResult fieldDescribeFromLookup = fieldFromLookup != null ? fieldFromLookup.getDescribe() : null;
						//i am checking only the last field because if one parent is not accessible then also the last child is not
		                if(fieldDescribeFromLookup != null && fieldDescribeFromLookup.isAccessible()){
		                	value = objTmp.get(apiNameSplitted[apiNameSplitted.size() - 1]);
		                	JSONObj.put(label, value);
		                }
	                }
	            }
	            else{
	                value = obj.get(apiName);
	                JSONObj.put(label, value);
	            }
            }
    		else{
    			system.debug(apiName + ' is not accessible');
    		}
        }
        return JSONObj;
    }
    
    public virtual Object getJSONObjectList(List<sObject> objectList){
        List<Map<String, Object>> lst = new List<Map<String, Object>>();
        if(objectList != null && !objectList.isEmpty()){
        	for(sObject obj : objectList){
	            lst.add(this.getJSONObject(obj));
	        }
        }
        return lst;
    }
    
    public virtual Object getJSONObjectList(){
        return getJSONObjectList(this.getRecords());
    }
    
    public virtual sObject getsObject(Map<String, Object> myMap){
        Map<String, String> fieldsName = this.getFieldsNamesPost();
        sObject obj = this.getSObjectType().newSObject();
        for(String key : myMap.keySet()){
            string apiName = fieldsName.get(key);
            Object value = myMap.get(key);
            system.debug('apiName : ' + apiName);
            system.debug('value : ' + value);
            if(apiName != null){
                obj.put(apiName, value);
            }
        }
        system.debug('obj : ' + json.serialize(obj)); 
        return obj;
    }
    
    protected virtual DateTime getLastSyncDate(){
        //myWSSync = CNT_WS_DAL.getWebServiceSync(UserInfo.getUserId(), className, request.params.get(DEVICEID));
        DateTime lastSyncDate;
        String ignoreSyncDat = request.params.get(IGNORESYNCDATE);
        /*if((!String.isEmpty(ignoreSyncDat) && ignoreSyncDat == '1') || myWSSync == null || myWSSync.CNT_LastSyncDate__c == null){
            lastSyncDate = DateTime.newInstance(0);
        }
        else{
            lastSyncDate = myWSSync.CNT_LastSyncDate__c;
        }*/
        
        
        return lastSyncDate;
    }
    
    protected virtual Set<String> getKeepFields(){
        Set<String> fieldNamesSet = new Set<String>();
        String fieldNamesStr = request.params.get(KEEPFIELDS);
        if(!String.isEmpty(fieldNamesStr)){
            fieldNamesSet.addAll(fieldNamesStr.split(','));
        }
        return fieldNamesSet;
    }
    
    protected virtual void updateWebServiceSync(){
    	//myWSSync = CNT_WS_DAL.getWebServiceSync(UserInfo.getUserId(), className, request.params.get(DEVICEID));
    	//CNT_WS_Utils.updateWebServiceSync(UserInfo.getUserId(), className, request.params.get(DEVICEID), myWSSync);
    }
    
    protected virtual Integer getIndex(){
        String pageIndexStr = request.params.get(PAGEINDEX);
        return pageIndexStr != null ? Integer.valueOf(pageIndexStr) : 0;
    }
    
    protected virtual Boolean isLast(Integer itemsPerRequest){
        if(allIdsForThisPageIndex != null && allIds != null && (this.getIndex() * itemsPerRequest + allIdsForThisPageIndex.size() >= allIds.size())){
            return true;
        }
        else{
            return false;
        }
    }
    
    /*
    	Start Functions for post methods
    */
    public class MapsToInsertAndUpdate{
        public Map<Integer, sObject> insertObjects{set; get;}  
        public Map<Integer, sObject> updateObjects{set; get;}
        
        public MapsToInsertAndUpdate(){
        	insertObjects = new Map<Integer, sObject>();
        	updateObjects = new Map<Integer, sObject>();
        }
    }
    
	public List<sObject> upsertAndReorderDynamicList(List<Object> myList){
		return upsertAndReorderDynamicList(myList, true);
	}
	
	public List<sObject> upsertAndReorderDynamicList(List<Object> myList, Boolean isDMLNeeded){
		List<sObject> responseList = new List<sObject>();
		MapsToInsertAndUpdate listsForDML = getsObjectListFromJsonList(myList);
		if(isDMLNeeded == true){
			listsForDML = upsertDynamicList(listsForDML);
		}
		Map<Integer, sObject> responseMap = listsForDML.insertObjects;
		responseMap.putAll(listsForDML.updateObjects);
		sObject myObj;
		for(Integer i = 0 ; i < myList.size() ; i++){
			myObj = responseMap.get(i);
			if(myObj != null){
				if(myObj.get('Id') != null){
					((map<String, Object>) myList[i]).put('id', myObj.get('Id'));
				}
			}
			responseList.add(myObj);
		}
		
		return responseList;
	}
	
	protected void updateObjectListAfterDML(List<Object> myList, List<sObject> myListAfterDML){
		sObject myObj;
		if(myList.size() == myListAfterDML.size()){
			for(Integer i = 0 ; i < myList.size() ; i++){
				myObj = myListAfterDML[i];
				if(myObj.get('Id') != null){
					((map<String, Object>) myList[i]).put('id', myObj.get('Id'));
				}
			}
		}
	}
	
	protected MapsToInsertAndUpdate upsertDynamicList(MapsToInsertAndUpdate lsts){
		if(lsts != null){
			/*if(lsts.updateObjects != null && !lsts.updateObjects.isEmpty())
				Database.update(lsts.updateObjects.values(), false);
			if(lsts.insertObjects != null && !lsts.insertObjects.isEmpty())
				Database.insert(lsts.insertObjects.values(), false);*/
			if(lsts.updateObjects != null && !lsts.updateObjects.isEmpty())
				update lsts.updateObjects.values();
			if(lsts.insertObjects != null && !lsts.insertObjects.isEmpty())
				insert lsts.insertObjects.values();
		}
		return lsts;
	}
	
	protected MapsToInsertAndUpdate getsObjectListFromJsonList(List<Object> objectList){
	    MapsToInsertAndUpdate lst = new MapsToInsertAndUpdate();
	    Map<String, Object> myMap;
	    Integer i = 0;
	    for(Object obj : objectList){
	    	myMap = (Map<String, Object>) obj;
	        if(myMap.containsKey('id'))
				lst.updateObjects.put(i, this.getsObject(myMap));
	        else
	        	lst.insertObjects.put(i, this.getsObject(myMap));
	    	i++;
	    }
	    return lst;
	}
	
	/*
    	End Functions for post methods
    */
        
    public class ResponseData{
        public List<Object> records{set; get;}  
        public Set<id> allRecordIds{set; get;} 
        public Integer totalSize{set; get;}
        
        public ResponseData(List<Object> records, Set<id> allRecordIds){
            if(records != null){
            	this.records = records;
            	this.totalSize = records.size();
            }
            else{
            	this.records = new List<Object>();
            	this.totalSize = 0;
            }
            this.allRecordIds = allRecordIds;
        }
    }
    
    public class ResponseItem{
        public map<String,ResponseData> Items;
        
        public ResponseItem(){
            Items = new map<String,ResponseData>();
        }
        
        public ResponseItem(String objectName, List<Object> updatedItems, Set<id> allItemsId){
            this.Items = new map<String,ResponseData>{objectName => new ResponseData(updatedItems, allItemsId)};
        }
        
        public void addItem(String objectName, List<Object> updatedItems, Set<id> allItemsId){
            this.Items.put(objectName, new ResponseData(updatedItems, allItemsId));
        }
    }
}