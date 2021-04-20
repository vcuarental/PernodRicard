public without sharing class GDT_Data_Backup {
	
	public final static String toolingendpoint = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v48.0/tooling/';
	public final static String sandboxInfo = toolingendpoint + 'sobjects/SandboxInfo/';
	
    @future(callout=true)
	public static void updateBackupFields(){
		PermissionSet GDT_DATA_BACKUP_PS = [SELECT id FROM permissionset WHERE Name = 'GDT_ADMIN_DATA_BACKUP_RESTORE' limit 1];

		Map<String, Schema.SObjectField> fieldsMap = new Map<String,Schema.SObjectField>();
		for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){
		    if(objTyp.getDescribe().isQueryable()){ 
		    	String obj = objTyp.getDescribe().getName();
                if(obj != 'Macro'){
                    Map <String, Schema.SObjectField> fieldMap = objTyp.getDescribe().fields.getMap();
                    for(Schema.SObjectField sfield : fieldMap.Values()){
                        Schema.DescribeFieldResult fieldResult = sfield.getDescribe();
                        if(fieldResult.isPermissionable() && !fieldResult.getName().endsWith('__pc') && fieldResult.getCompoundFieldName()== null){
                            fieldsMap.put(obj + '.' + fieldResult.getname(), sfield);
                        }
                    }
                }
		    }
		}

		system.debug('NUMBER OF UPDATABLE FIELDS ON THE ORG ' + fieldsMap.size());
		for(FieldPermissions fp : [SELECT Id, Field, SObjectType, PermissionsRead, PermissionsEdit FROM FieldPermissions WHERE parentId =: GDT_DATA_BACKUP_PS.Id ]){
			fieldsMap.remove(fp.field);
		}

		List<FieldPermissions> toInsert = new List<FieldPermissions>();
		system.debug('NUMBER OF FIELDS WITHOUT AT LEAST READ ACCESS ON GDT PROFILE ' + fieldsMap.size());

		for(String  str: fieldsMap.keySet()){
			Schema.DescribeFieldResult field = fieldsMap.get(str).getDescribe();
			FieldPermissions fp = new FieldPermissions();
			system.debug(str);
			fp.parentId = GDT_DATA_BACKUP_PS.Id;
			fp.SobjectType = str.split('\\.')[0];
			fp.Field = str;
			if(!field.isCalculated() && !field.isAutoNumber() ){
				fp.PermissionsEdit = true;
			}
			fp.PermissionsRead = true;
			toInsert.add(fp);
		}
		database.insert(toInsert,false);
		system.debug('NUMBER OF INSERTED FIELDS PERMISSIONS ' + toInsert.size());
	}

	@future(callout=true)
	public static void updateBackupObject(){
		PermissionSet GDT_DATA_BACKUP_PS = [SELECT id FROM permissionset WHERE Name = 'GDT_ADMIN_DATA_BACKUP_RESTORE' limit 1];
		Set<String> objectsSet = new Set<String>();

		for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){
		    if(objTyp.getDescribe().isQueryable() && !objTyp.getDescribe().isCustomSetting()){
		        String obj = objTyp.getDescribe().getName();
		        if(!obj.endsWith('__mdt') && !obj.endsWith('__Feed') && !obj.endsWith('__Tag') && !obj.endsWith('__History') && !obj.endsWith('__Share')){
		       		objectsSet.add(obj);
		       	}
		    }
		}   
		system.debug('NUMBER OF UPDATABLE OBJECTS ON THE ORG ' + objectsSet.size());
		for(ObjectPermissions op : [SELECT Id,ParentId, Parent.Profile.Name, PermissionsRead,PermissionsCreate,SobjectType FROM ObjectPermissions WHERE parentId =: GDT_DATA_BACKUP_PS.id ]){
			objectsSet.remove(op.SobjectType);
		}

		List<ObjectPermissions> toInsert = new List<ObjectPermissions>();
		system.debug('NUMBER OF OBJECTS WITHOUT AT LEAST READ ACCESS ON GDT PROFILE ' + objectsSet.size());

		for(String  str: objectsSet){
			ObjectPermissions fp = new ObjectPermissions();
			system.debug(str);
			fp.parentId = GDT_DATA_BACKUP_PS.Id;
			fp.SobjectType = str;
			fp.PermissionsViewAllRecords = true;
			fp.PermissionsRead = true;
			toInsert.add(fp);
		}
		database.insert(toInsert,false);

		system.debug('NUMBER OF INSERTED OBJECT PERMISSIONS ' + toInsert.size());

		
	}

	@future(callout=true)
	public static void refreshTodaysSandbox(){
		try{
			String todaySandboxId = getTodaysSandboxId();
			if(todaySandboxId != ''){
				String refreshURL = sandboxInfo + todaySandboxId + '?_HttpMethod=PATCH';
				HttpRequest req = createRequest(refreshURL , 'POST','{ "licenseType": "DEVELOPER","Description" : "METADATA BACKUP, Day ' + String.valueOf(date.today().day()) + '","AutoActivate" : true}');
				req.setHeader('X-HTTP-Method-Override','PATCH');
				if(!Test.isRunningTest())new Http().send(req);
			}else{
				createSandbox();
			}
		}catch(Exception ex){
			system.debug('Exception ' + ex.getMessage());
		}
	}

	public Static String getTodaysSandboxId(){
		try{
			String sbName = getSandboxName();
			String queryField =  'query?q=SELECT+Id,SandboxName+FROM+SandboxInfo+WHERE+SandboxName+in+(\'' + sbName + '\')';
			HttpRequest req = createRequest(toolingendpoint + queryField , 'GET','');
			req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());

			Http h = new Http();
			string idOfField = '';
			if(!Test.isRunningTest()){
				HttpResponse res = h.send(req);
			 	idOfField = res.getBody().substringBetween('"Id":"','"');
				system.debug(idOfField);
				return idOfField == null ? '' : idOfField;
			}else{
				return 'idTest';
			}
		}catch(Exception e){
			return '';
		}
	}

	public Static void createSandbox(){
		String sbName = getSandboxName();
		HttpRequest req = createRequest(sandboxInfo,'POST','{ "licenseType": "DEVELOPER", "Description" : "METADATA BACKUP, Day ' + String.valueOf(date.today().day()) + '","AutoActivate" : true, "SandboxName" : "' + sbName + '"}');
		if(!Test.isRunningTest()){
			new Http().send(req);
		}
	}

	public static HttpRequest createRequest(String endpoint, String method, String body){
		HttpRequest req = new HttpRequest();
		req.setEndpoint(endpoint);
		if(body != '')req.setBody(body);
		req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
		req.setHeader('Content-Type', 'application/json;');
		req.setMethod(method);
		return req;

	}

	public Static String getSandboxName(){
		Date d = date.today();
		String day = String.valueOf(d.day());
		return 'GDTBKD' + day;
	}
}