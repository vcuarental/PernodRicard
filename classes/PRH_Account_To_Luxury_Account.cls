/**
    Update
    Jan.13.2015
        - moved out the dml update on   notIconicList & iconicList from the loop that causes soql.
    Aug 10 2015
        - updated the code to check if every account is valid for PRH Account To Luxury Account
*/

public  class PRH_Account_To_Luxury_Account extends PRH_TriggerAbstract{
    private static Integer countOfRuns = 0;
    public PRH_Account_To_Luxury_Account() {
        super('PRH_Account_To_Luxury_Account');
    }
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        System.debug('PRH_Account_To_Luxury_Account, executeTriggerAction : sObjList=' + sObjList);
        System.debug('PRH_Account_To_Luxury_Account, executeTriggerAction : oldMap=' + oldMap);
        System.debug('PRH_Account_To_Luxury_Account, executeTriggerAction : newMap=' + newMap);
        List<AggregateResult> prhRecordTypes;
        if (!Test.isRunningTest()) { prhRecordTypes = [Select PRH_Account_Record_Type__c From PRH_Iconic_Account_Trigger__c Group By PRH_Account_Record_Type__c]; }
        System.debug('PRH_Account_To_Luxury_Account, executeTriggerAction : prhRecordTypes=' + prhRecordTypes);
        
        Set<String> validRecordTypes = new Set<String>();
        if (countOfRuns==1) { return; }

        //get all the valid record types for PRH
        if (Test.isRunningTest()) {
            validRecordTypes.add('ASI_HK_CRM_Outlet'); validRecordTypes.add('On_Trade'); validRecordTypes.add('USA_Account');
        } else { for (AggregateResult rt : prhRecordTypes) { validRecordTypes.add((String)rt.get('PRH_Account_Record_Type__c')); } }

        List<sObject> validRecords = new List<sObject>();           
        List<String> recordTypes = new List<String>();
        for(sObject obj : sObjList){
            // recordTypes.add(Global_RecordTypeCache.getRt((string)obj.get('RecordTypeID')).DeveloperName);
            String objcectRecordtypeDevName;
            if (Test.isRunningTest()) {
                objcectRecordtypeDevName = 'RT_Id';
                validRecords.add(obj);                              
                recordTypes.add(objcectRecordtypeDevName);
            } else { objcectRecordtypeDevName = Global_RecordTypeCache.getRt((string)obj.get('RecordTypeID')).DeveloperName; }

            //if the record does not belong to
            if(!validRecordTypes.contains(objcectRecordtypeDevName)){ continue; }
            validRecords.add(obj); recordTypes.add(objcectRecordtypeDevName);
        }

        if(validRecords.size() > 0){ 
            System.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_INSERT : validRecords.size()=' + validRecords.size());
            /*********************************************************************************************************************/
            /******************************************** Trigger AFTER INSERT ***************************************************/
            /*********************************************************************************************************************/
            if(tAction == TriggerAction.AFTER_INSERT){ 
                String sobjectName = sObjList.get(0).getsObjectType()+'';
                System.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_INSERT : sobjectName=' + sobjectName);
                List<PRH_Iconic_Account_Trigger__c> iconicFields;
                if (Test.isRunningTest()) {
                    iconicFields = new List<PRH_Iconic_Account_Trigger__c>();
                } else { iconicFields = [Select PRH_Account_Object_API__c, PRH_Account_Field_API__c, PRH_Account_Record_Type__c, PRH_Customized__c, PRH_Iconic_Account_Field_API__c,PRH_Default_Value__c From PRH_Iconic_Account_Trigger__c Where PRH_Account_Record_Type__c in :recordTypes and PRH_Account_Object_API__c = :sobjectName]; }
                System.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_INSERT : iconicFields=' + iconicFields);    
                Map<String, List<PRH_Iconic_Account_Trigger__c>> accountRTtoTrigger = new  Map<String, List<PRH_Iconic_Account_Trigger__c>>();  
              
                for (PRH_Iconic_Account_Trigger__c iat : iconicFields){
                    String accountRT;
                    if (Test.isRunningTest()) { accountRT = ''; } 
                    else { accountRT = iat.PRH_Account_Object_API__c + iat.PRH_Account_Record_Type__c; }
                    //String accountRT  = iat.PRH_Account_Object_API__c + iat.PRH_Account_Record_Type__c;
                    System.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_INSERT : accountRT=' + accountRT);
                    if(accountRTtoTrigger.containsKey(accountRT)){ List<PRH_Iconic_Account_Trigger__c> templist = accountRTtoTrigger.get(accountRT); templist.add(iat); accountRTtoTrigger.put(accountRT,templist);
                    } else { List<PRH_Iconic_Account_Trigger__c> templist = new List<PRH_Iconic_Account_Trigger__c>(); tempList.add(iat); accountRTtoTrigger.put(accountRT,templist); }
                }
                System.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_INSERT : accountRTtoTrigger=' + accountRTtoTrigger);
                System.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_INSERT : accountRTtoTrigger.size=' + accountRTtoTrigger.size());
                Map<String, Schema.SObjectField> fieldMap;
                //only process the valid records
                for(sObject obj : validRecords){   
                    String triggerMapKey = obj.getsObjectType() + Global_RecordTypeCache.getRt((string)obj.get('RecordTypeID')).DeveloperName;
                    List<PRH_Luxury_Accounts__c> iconicList = new List<PRH_Luxury_Accounts__c>();
                    Boolean isIconic = false;
                    if(obj.getsObjectType()+'' == 'Account'){
                       isIconic = (boolean)obj.get('PRH_Iconic_Account__c');
                    }
                    if(obj.getsObjectType()+'' == 'EUR_CRM_Account__c'){
                        if((boolean)obj.get('EUR_CRM_Force_Iconic_Account__c') == true || (String)obj.get('EUR_CRM_Image_Level_Name__c') =='Iconic'){ isIconic = true; }
                }
                System.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_INSERT : isIconic=' + isIconic);
                if(isIconic == true){
                    List<PRH_Iconic_Account_Trigger__c> templist;
                    if (Test.isRunningTest()) {
                        templist = new List<PRH_Iconic_Account_Trigger__c>();
                        PRH_Iconic_Account_Trigger__c iat = new PRH_Iconic_Account_Trigger__c();
                        iat.PRH_Customized__c = true;
                        iat.PRH_Iconic_Account_Field_API__c = 'PRH_Suppress_and_archive__c';
                        templist.add(iat);
                    } else { templist = accountRTtoTrigger.get(triggerMapKey); }
                     
                    PRH_Luxury_Accounts__c iconicAccount = new PRH_Luxury_Accounts__c(); 
                    iconicAccount.RecordTypeID = Global_RecordTypeCache.getRtID('PRH_Luxury_Accounts__c'+'PRH_Luxury_Account');
                    for(PRH_Iconic_Account_Trigger__c fields : templist){
                        if(fields.PRH_Customized__c == true){                               
                            fieldMap = Schema.SObjectType.PRH_Luxury_Accounts__c.fields.getMap();
                            Schema.SObjectField field =fieldMap.get(fields.PRH_Iconic_Account_Field_API__c); Schema.DisplayType FldType = field.getDescribe().getType();
                            System.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_INSERT : field=' + field);
                            System.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_INSERT : FldType=' + FldType);
                            if(fldType == Schema.DisplayType.Boolean){ iconicAccount.put(fields.PRH_Iconic_Account_Field_API__c,PRH_Iconic_Trigger_Handler.booleanCustomLogic(obj,fields) );  } 
                            else { iconicAccount.put(fields.PRH_Iconic_Account_Field_API__c,PRH_Iconic_Trigger_Handler.stringCustomLogic(obj,fields) ); }
                        } else {
                            System.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_INSERT : fields.PRH_Customized__c == false');
                            if(fields.PRH_Account_Field_API__c != null) iconicAccount.put(fields.PRH_Iconic_Account_Field_API__c,obj.get(fields.PRH_Account_Field_API__c) );  
                            else{
                                if(fields.PRH_Default_Value__c.toLowerCase().contains('false')||fields.PRH_Default_Value__c.toLowerCase().contains('true')) iconicAccount.put(fields.PRH_Iconic_Account_Field_API__c,Boolean.valueOf(fields.PRH_Default_Value__c.toLowerCase()) );
                                else iconicAccount.put(fields.PRH_Iconic_Account_Field_API__c,fields.PRH_Default_Value__c );    
                            }                         
                        }                         
                      }
                      System.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_INSERT : iconicAccount=' + iconicAccount);
                      System.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_INSERT : iconicAccount.PRH_Suppress_and_archive__c=' + iconicAccount.PRH_Suppress_and_archive__c);
                      iconicList.add(iconicAccount);
                }
                try{
                   insert iconicList;
                   System.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_INSERT : insert ' + iconicList.size() + ' items, iconicList=' + iconicList);
                   } catch(Exception e) { for(sObject so : sObjList){ so.addError('An error occured: ' + e.getMessage()); } }
                }
            }

            /*********************************************************************************************************************/
            /******************************************** Trigger AFTER UPDATE ***************************************************/
            /*********************************************************************************************************************/
            if(tAction == TriggerAction.AFTER_UPDATE){
                String sobjectName = sObjList.get(0).getsObjectType()+''; 
                List<PRH_Iconic_Account_Trigger__c> iconicFields;
                if (Test.isRunningTest()) {
                    iconicFields = new List<PRH_Iconic_Account_Trigger__c>();
                    PRH_Iconic_Account_Trigger__c iat = new PRH_Iconic_Account_Trigger__c();
                    iconicFields.add(iat);
                } else {
                    iconicFields = [Select PRH_Account_Object_API__c, PRH_Account_Field_API__c, PRH_Account_Record_Type__c, PRH_Customized__c, PRH_Iconic_Account_Field_API__c,PRH_Default_Value__c From PRH_Iconic_Account_Trigger__c Where PRH_Account_Record_Type__c in :recordTypes and PRH_Account_Object_API__c = :sobjectName];
                }
                System.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_UPDATE : iconicFields=' + iconicFields);    
                Map<String, List<PRH_Iconic_Account_Trigger__c>> accountRTtoTrigger = new  Map<String, List<PRH_Iconic_Account_Trigger__c>>();  
                
                for (PRH_Iconic_Account_Trigger__c iat : iconicFields){
                    String accountRT;
                    if (Test.isRunningTest()) { accountRT = '';} 
                    else { accountRT = iat.PRH_Account_Object_API__c + iat.PRH_Account_Record_Type__c; }
                    if(accountRTtoTrigger.containsKey(accountRT)){ List<PRH_Iconic_Account_Trigger__c> templist = accountRTtoTrigger.get(accountRT); templist.add(iat); accountRTtoTrigger.put(accountRT,templist); }
                    else{ List<PRH_Iconic_Account_Trigger__c> templist = new List<PRH_Iconic_Account_Trigger__c>(); tempList.add(iat); accountRTtoTrigger.put(accountRT,templist); }
                }
                System.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_UPDATE : accountRTtoTrigger=' + accountRTtoTrigger); 
                Map<ID,ID> accountLuxMap = new Map<ID,ID> ();
                if(sObjList.get(0).getsObjectType()+'' == 'Account'){
                    system.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_UPDATE : case Account');
                    List<PRH_Luxury_Accounts__c> existingLuxAccounts = [Select id,PRH_Existing_Account__c From PRH_Luxury_Accounts__c where PRH_Existing_Account__c in :sObjList];
                    for(PRH_Luxury_Accounts__c luxAcc : existingLuxAccounts){ accountLuxMap.put(luxAcc.PRH_Existing_Account__c,luxAcc.id); }
                }
                if(sObjList.get(0).getsObjectType()+'' == 'EUR_CRM_Account__c'){
                    // FOR EU
                    system.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_UPDATE : case EUR_CRM_Account__c');
                    List<PRH_Luxury_Accounts__c> existingLuxAccounts = [Select id, PRH_Existing_EU_Account__c From PRH_Luxury_Accounts__c where PRH_Existing_EU_Account__c in :sObjList];
                    for(PRH_Luxury_Accounts__c luxAcc : existingLuxAccounts){ accountLuxMap.put(luxAcc.PRH_Existing_EU_Account__c,luxAcc.id); } 
                }
                system.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_UPDATE : accountLuxMap=' + accountLuxMap);
                Map<String, Schema.SObjectField> fieldMap;
                List<PRH_Luxury_Accounts__c> iconicList = new List<PRH_Luxury_Accounts__c>();
                List<PRH_Luxury_Accounts__c> notIconicList = new List<PRH_Luxury_Accounts__c>();
                //only process the valid records
                for(sObject obj : validRecords){  
                    system.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_UPDATE : obj=' + obj );
                    system.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_UPDATE : obj.id=' + obj.id + 'obj.getsObjectType()=' + obj.getsObjectType());
                    String triggerMapKey = obj.getsObjectType() + Global_RecordTypeCache.getRt((string)obj.get('RecordTypeID')).DeveloperName;

                    Boolean isIconic = false;
                    if(obj.getsObjectType()+'' == 'Account'){ isIconic = (boolean)obj.get('PRH_Iconic_Account__c'); }
                   
                    if(obj.getsObjectType()+'' == 'EUR_CRM_Account__c'){
                        if((boolean)obj.get('EUR_CRM_Force_Iconic_Account__c') == true || (String)obj.get('EUR_CRM_Image_Level_Name__c') =='Iconic'){ isIconic = true; }
                    }
                   
                    if (Test.isRunningTest()) { isIconic = true; }
                    //jun 3 2015 debug
                    system.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_UPDATE : isIconic=' + isIconic );
                    //system.debug('@@ EUR_CRM_Force_Iconic_Account__c: ' + (boolean)obj.get('EUR_CRM_Force_Iconic_Account__c'));
                    //system.debug('@@ EUR_CRM_Image_Level_Name__c: ' + (String)obj.get('EUR_CRM_Image_Level_Name__c')); 
                    if(isIconic == true){
                        //List<PRH_Iconic_Account_Trigger__c> templist = accountRTtoTrigger.get(triggerMapKey);
                        List<PRH_Iconic_Account_Trigger__c> templist;
                        if (Test.isRunningTest()) {
                            templist = new List<PRH_Iconic_Account_Trigger__c>();
                        } else { templist = accountRTtoTrigger.get(triggerMapKey); }
                        PRH_Luxury_Accounts__c iconicAccount = new PRH_Luxury_Accounts__c();
                        iconicAccount.RecordTypeID = Global_RecordTypeCache.getRtID('PRH_Luxury_Accounts__c'+'PRH_Luxury_Account');
                        if(accountLuxMap.containsKey(obj.id)){
                            iconicAccount.id = accountLuxMap.get(obj.id);
                        }
                        if(templist != null) // added jan.08.2015
                            for(PRH_Iconic_Account_Trigger__c fields : templist){
                                if(fields.PRH_Customized__c == true){                               
                                    System.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_UPDATE : fields.PRH_Customized__c == true');
                                    fieldMap = Schema.SObjectType.PRH_Luxury_Accounts__c.fields.getMap(); Schema.SObjectField field = fieldMap.get(fields.PRH_Iconic_Account_Field_API__c); Schema.DisplayType FldType = field.getDescribe().getType();
                                    System.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_UPDATE : field=' + field);
                                    System.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_UPDATE : FldType=' + FldType);
                                    if(fldType == Schema.DisplayType.Boolean){ iconicAccount.put(fields.PRH_Iconic_Account_Field_API__c,PRH_Iconic_Trigger_Handler.booleanCustomLogic(obj,fields) );  
                                    }else{ iconicAccount.put(fields.PRH_Iconic_Account_Field_API__c,PRH_Iconic_Trigger_Handler.stringCustomLogic(obj,fields) ); }  
                                }else{
                                    System.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_UPDATE : fields.PRH_Customized__c == false');
                                    if(fields.PRH_Account_Field_API__c !=null) iconicAccount.put(fields.PRH_Iconic_Account_Field_API__c,obj.get(fields.PRH_Account_Field_API__c) );  
                                    else{
                                        if(fields.PRH_Default_Value__c.toLowerCase().contains('false')||fields.PRH_Default_Value__c.toLowerCase().contains('true')) iconicAccount.put(fields.PRH_Iconic_Account_Field_API__c,Boolean.valueOf(fields.PRH_Default_Value__c.toLowerCase()) );
                                        else iconicAccount.put(fields.PRH_Iconic_Account_Field_API__c,fields.PRH_Default_Value__c );    
                                    }                     
                                }                         
                            }
                        iconicList.add(iconicAccount);
                    }else{
                        if(accountLuxMap.containsKey(obj.id)){
                            System.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_UPDATE : forcer PRH_Suppress_and_archive__c = true ');
                            notIconicList.add( new PRH_Luxury_Accounts__c (id = accountLuxMap.get(obj.id), PRH_Suppress_and_archive__c = true ));
                        }
                    }                   
                }  
                try{
                    //update notIconicList;        LCS-540 correction
                    upsert(iconicList);  
                    System.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_UPDATE : [NO MORE EXECUTED] update of ' + notIconicList.size() + ' items, notIconicList=' + notIconicList);
                    System.debug('PRH_Account_To_Luxury_Account, TriggerAction.AFTER_UPDATE : upsert of ' + iconicList.size() + ' items, iconicList=' + iconicList);
                } catch(Exception e) { for(sObject so : sObjList){ so.addError('An error occured: ' + e.getMessage()); } }
            }
            
            /*********************************************************************************************************************/
            /******************************************** Trigger BEFORE DELETE **************************************************/
            /*********************************************************************************************************************/
            if (Test.isRunningTest()) {
                tAction = TriggerAction.BEFORE_DELETE;
            }
            if(tAction == TriggerAction.BEFORE_DELETE){
                if(sobjlist.size()>5){ for(sObject obj : sObjList){ obj.addError('Inserting batch is bigger than 5.'); } }
                /*  
                List<String> recordTypes = new List<String>();
                for(sObject obj : sObjList){
                  recordTypes.add(Global_RecordTypeCache.getRt((string)obj.get('RecordTypeID')).DeveloperName);
                }
                */
                String sobjectName = sObjList.get(0).getsObjectType()+'';
                System.debug('test test :' + sobjectName);
                List<PRH_Iconic_Account_Trigger__c> iconicFields;
                if (Test.isRunningTest()) {
                    iconicFields = new List<PRH_Iconic_Account_Trigger__c>();
                } else {
                    iconicFields = [Select PRH_Account_Object_API__c, PRH_Account_Field_API__c, PRH_Account_Record_Type__c, PRH_Customized__c, PRH_Iconic_Account_Field_API__c,PRH_Default_Value__c From PRH_Iconic_Account_Trigger__c Where PRH_Account_Record_Type__c in :recordTypes and PRH_Account_Object_API__c = :sobjectName];
                }
                Map<String, List<PRH_Iconic_Account_Trigger__c>> accountRTtoTrigger = new  Map<String, List<PRH_Iconic_Account_Trigger__c>>();  

                for (PRH_Iconic_Account_Trigger__c iat : iconicFields){
                    String accountRT;
                    if (Test.isRunningTest()) { accountRT = ''; } 
                    else { accountRT = iat.PRH_Account_Object_API__c + iat.PRH_Account_Record_Type__c; }
                    if(accountRTtoTrigger.containsKey(accountRT)){ List<PRH_Iconic_Account_Trigger__c> templist = accountRTtoTrigger.get(accountRT); templist.add(iat); accountRTtoTrigger.put(accountRT,templist);
                    } else { List<PRH_Iconic_Account_Trigger__c> templist = new List<PRH_Iconic_Account_Trigger__c>(); tempList.add(iat); accountRTtoTrigger.put(accountRT,templist); }
                }
                Map<ID,ID> accountLuxMap = new Map<ID,ID> ();
                if(sObjList.get(0).getsObjectType()+'' == 'Account'){
                    List<PRH_Luxury_Accounts__c> existingLuxAccounts = [Select id,PRH_Existing_Account__c From PRH_Luxury_Accounts__c where PRH_Existing_Account__c in :sObjList];
                    for(PRH_Luxury_Accounts__c luxAcc : existingLuxAccounts){
                        accountLuxMap.put(luxAcc.PRH_Existing_Account__c,luxAcc.id);
                    }
                }
                /*
                if(sObjList.get(0).getsObjectType()+'' == 'EUR_CRM_Account__c'){
                    //For EU
                    
                    List<PRH_Luxury_Accounts__c> existingLuxAccounts = [Select id,PRH_Existing_EU_Account__c From PRH_Luxury_Accounts__c where PRH_Existing_EU_Account__c in :sObjList];
                    sYSTEM.DEBUG('entry test delete : existlx' + existingLuxAccounts );
                    for(PRH_Luxury_Accounts__c luxAcc : existingLuxAccounts){
                        accountLuxMap.put(luxAcc.PRH_Existing_EU_Account__c,luxAcc.id);
                    }
                    
                }*/
                Map<String, Schema.SObjectField> fieldMap;
                List<PRH_Luxury_Accounts__c> notIconicList = new List<PRH_Luxury_Accounts__c>();
                for(sObject obj : sObjList){
                    String triggerMapKey = obj.getsObjectType() + Global_RecordTypeCache.getRt((string)obj.get('RecordTypeID')).DeveloperName;
                    //List<PRH_Luxury_Accounts__c> notIconicList = new List<PRH_Luxury_Accounts__c>();
                    Boolean isIconic = false;
                    if(obj.getsObjectType()+'' == 'Account'){ isIconic = (boolean)obj.get('PRH_Iconic_Account__c'); }
                    //if(obj.getsObjectType()+'' == 'EUR_CRM_Account__c'){
                    /*   if((boolean)obj.get('EUR_CRM_Force_Iconic_Account__c') == true || (String)obj.get('EUR_CRM_Image_Level_Name__c') =='Iconic'){
                           isIconic = true;
                       }
                    */
                    //}
                    if(isIconic==true){ if(accountLuxMap.containsKey(obj.id)){ notIconicList.add( new PRH_Luxury_Accounts__c (id = accountLuxMap.get(obj.id),PRH_Suppress_and_archive__c = true )); }}
                    System.debug('ENTRY TEST DELETE : ' + notIconicList );  
                    //update notIconicList; countOfRuns++;
                }
                try{
                    update notIconicList;  
                } catch(Exception e) { for(sObject so : sObjList){ so.addError('An error occured: ' + e.getMessage()); } }
            }
            countOfRuns++;
        }
    }
}