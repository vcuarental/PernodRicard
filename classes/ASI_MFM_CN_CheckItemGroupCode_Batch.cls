Global class ASI_MFM_CN_CheckItemGroupCode_Batch implements Database.Batchable<sObject>, Database.Stateful{
    
    Private Static Final Id New_POSM_Item_Group_Region_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_New_POSM_Item_Group_Region');
    Private Static Final Id New_POSM_Item_Group_RO_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_New_POSM_Item_Group_RO');
    Private Static Final Id New_POSM_Item_Group_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_New_POSM_Item_Group');
    Private Static Final Id New_POSM_Item_Group_RO_Region_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_New_POSM_Item_Group_RO_Region');
    Private Static Final Id POSM_Item_Group_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
    
    Set<Id> P_RecTypeID = new Set<Id>{ New_POSM_Item_Group_Region_RECORD_TYPE_ID,New_POSM_Item_Group_RO_RECORD_TYPE_ID,New_POSM_Item_Group_RECORD_TYPE_ID,New_POSM_Item_Group_RO_Region_RECORD_TYPE_ID,POSM_Item_Group_RECORD_TYPE_ID };
    
    // public Id LogId;
    //private static Final Integer LOG_DETAIL_SIZE = 4000;
    // Private Static Map<Id, ASI_MFM_Sub_Brand__c> subbrandMap = new Map<Id, ASI_MFM_Sub_Brand__c>();

	Global Database.QueryLocator start(Database.BatchableContext BC){
        string sSQL = ' SELECT ID,NAME,ASI_MFM_Item_Group_Code__c,ASI_MFM_CheckDuplicate__c,ASI_MFM_OldItemGroupCode__c,ASI_MFM_NotifyITGroup__c ' +
            			' FROM ASI_MFM_Item_Group__c ' + 
            			' WHERE ASI_MFM_CheckDuplicate__c=TRUE AND RecordTypeId IN :P_RecTypeID ORDER BY CREATEDDATE ';
        return Database.getQueryLocator(sSQL);
    }
    
    Global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<ASI_MFM_Item_Group__c> ltOrgScope = (List<ASI_MFM_Item_Group__c>) scope;
        Map<Id, ASI_MFM_Item_Group__c> mapUpdateItemGrp = new Map<Id, ASI_MFM_Item_Group__c>();		// list for update the database
        
        //1) get checking code
        Set<String> setCheckCode = new Set<String>();
        for(ASI_MFM_Item_Group__c oTmpItemGroup : ltOrgScope){
            setCheckCode.add(oTmpItemGroup.ASI_MFM_Item_Group_Code__c);
        }
        
        //2) get duplicate code >1
		AggregateResult[] oGrpResults = [SELECT ASI_MFM_Item_Group_Code__c itemGroupCode
                                             FROM ASI_MFM_Item_Group__c 
                                             WHERE RecordTypeId IN :P_RecTypeID
                                             	AND ASI_MFM_Item_Group_Code__c IN :setCheckCode
                                             GROUP BY ASI_MFM_Item_Group_Code__c
                                             HAVING Count(Id) > 1];
        Set<String> setDupCode = new Set<String>();
        for(AggregateResult ar : oGrpResults){
            setDupCode.add(String.valueOf(ar.get('itemGroupCode')));
        }
        
        if (setDupCode.size() > 0) {
            //3) get raw data with duplicate code - not update 1st one
            List<ASI_MFM_Item_Group__c> ltDupCode = [SELECT ID,ASI_MFM_Item_Group_Code__c,ASI_MFM_CheckDuplicate__c,ASI_MFM_OldItemGroupCode__c,ASI_MFM_NotifyITGroup__c 
                                                            FROM ASI_MFM_Item_Group__c 
                                                            WHERE RecordTypeId IN :P_RecTypeID
                                             					AND ASI_MFM_Item_Group_Code__c IN :setDupCode
                                                            ORDER BY CreatedDate];
            
            for(String sCode : setDupCode) {
                integer iCount = 1;
                for(ASI_MFM_Item_Group__c oItem : ltDupCode) {
                    if (oItem.ASI_MFM_Item_Group_Code__c == sCode) {
                        if (iCount > 1) {
                            oItem.ASI_MFM_CheckDuplicate__c = FALSE;
                            oItem.ASI_MFM_NotifyITGroup__c = TRUE;                        
                            oItem.ASI_MFM_OldItemGroupCode__c = oItem.ASI_MFM_Item_Group_Code__c;
                            oItem.ASI_MFM_Item_Group_Code__c = '';		//reset item group code to blank
                            mapUpdateItemGrp.put(oItem.Id, oItem);
                        }
                        
                        iCount++;
                    }
                }
            }
            
            /*
            for(String itemGroupCode : duplicateCodeList) {
               List<ASI_MFM_Item_Group__c> duplicateList = [SELECT ASI_MFM_Item_Group_Code__c,ASI_MFM_CheckDuplicate__c,ASI_MFM_OldItemGroupCode__c,ASI_MFM_NotifyITGroup__c 
                                                            FROM ASI_MFM_Item_Group__c 
                                                            WHERE ASI_MFM_Item_Group_Code__c =:itemGroupCode AND RecordTypeId IN:records
                                                            ORDER BY CreatedDate];
                System.debug('Duplicate List = '+duplicateList);
                duplicateList.get(0).ASI_MFM_CheckDuplicate__c = false;
                updateList.add(duplicateList.get(0));
                for(Integer i = 1 ; i < duplicateList.size() ; i++) {
                    duplicateList.get(i).ASI_MFM_CheckDuplicate__c = false;
                    duplicateList.get(i).ASI_MFM_NotifyITGroup__c = true;                        
                    duplicateList.get(i).ASI_MFM_OldItemGroupCode__c = duplicateList.get(i).ASI_MFM_Item_Group_Code__c;
                    duplicateList.get(i).ASI_MFM_Item_Group_Code__c = '';	//set item group code to blank
                    updateList.add(duplicateList.get(i));
                }
            }
			*/
       }

        //4) reset field with no duplication
       for(ASI_MFM_Item_Group__c oTmpItemGroup : ltOrgScope){
           if (!mapUpdateItemGrp.containsKey(oTmpItemGroup.Id)) {
               oTmpItemGroup.ASI_MFM_CheckDuplicate__c = FALSE;
               mapUpdateItemGrp.put(oTmpItemGroup.Id, oTmpItemGroup);
           }
		}
        
        // System.debug('Size of itemGroupList = ' + itemGroupList.size());
        // for(ASI_MFM_Item_Group__c itemGroup : itemGroupList){
        //     if(itemGroup.ASI_MFM_CheckDuplicate__c){
        //         System.debug('Checking Item Group Code :'+itemGroup.ASI_MFM_Item_Group_Code__c);
        //         List<Integer> tempList = new List<Integer>();
        //     	for(Integer j = 0 ; j < itemGroupList.size() ; j++){
        //         if(itemGroup.ASI_MFM_Item_Group_Code__c.equals(itemGroupList.get(j).ASI_MFM_Item_Group_Code__c)){
        //             tempList.add(j);//save the index of duplicate records
        //             itemGroupList.get(j).ASI_MFM_CheckDuplicate__c = false;//set checkDuplicate to false
        //         }
        //     }
        //         System.debug('there are '+ tempList.size()+' duplicate cases');
        //         if(tempList.size()>1){//count more than one
        //             for(Integer i = 1 ; i < tempList.size() ; i++){
        //                 itemGroupList.get(tempList[i]).ASI_MFM_NotifyITGroup__c = true;                        
        //                 itemGroupList.get(tempList[i]).ASI_MFM_OldItemGroupCode__c = itemGroupList.get(tempList[i]).ASI_MFM_Item_Group_Code__c;
        //                 itemGroupList.get(tempList[i]).ASI_MFM_Item_Group_Code__c = '';//set item group code to blank
        //             }
        //         }
        //     itemGroup.ASI_MFM_CheckDuplicate__c = false;//set checkDuplicate to false
        //     }
        // }
        
        //String errMsg = '';
        if(mapUpdateItemGrp.size() > 0) {
            Database.SaveResult[] oInsertResults = Database.update(mapUpdateItemGrp.values(), false);
            for(integer i=0; i<oInsertResults.size(); i++){
                Database.SaveResult sr = oInsertResults.get(i);
                if(sr.isSuccess()){
                    // success updated record;
                } else {
                    /*
                    if(errMsg.length()<LOG_DETAIL_SIZE) {
                        errMsg += 'Item Group Code :('+updateList.get(i).ASI_MFM_Item_Group_Code__c+')\n';
                        for(Database.Error err : sr.getErrors()) {
                            errMsg += err.getStatusCode() + ': ' + err.getMessage() + err.getFields()+'\n';
                        }
                    }
					*/
                }
            }
		}
        
  		/*      
   		if(errMsg!='' && LogId!=null) {
            ASI_MFM_BatchLog__c logger = [SELECT id, ASI_MFM_Log_Detail__c  FROM ASI_MFM_BatchLog__c WHERE id =:LogId];
            if(logger.ASI_MFM_Log_Detail__c==null) logger.ASI_MFM_Log_Detail__c='';
            if(logger.ASI_MFM_Log_Detail__c.length()+errMsg.length() < LOG_DETAIL_SIZE ) {
                logger.ASI_MFM_Log_Detail__c += errMsg;
            } else {
                logger.ASI_MFM_Log_Detail__c = (logger.ASI_MFM_Log_Detail__c+errMsg).substring(0, LOG_DETAIL_SIZE)+'...';
            }
            update logger;
        }        
        */
    }
    
    Global void finish(Database.BatchableContext BC){
     	/*   
        if(LogId!=null) {
            ASI_MFM_BatchLog__c logger = [SELECT id, ASI_MFM_Log_Detail__c  FROM ASI_MFM_BatchLog__c WHERE id =:LogId];
            if(logger.ASI_MFM_Log_Detail__c==null || logger.ASI_MFM_Log_Detail__c=='') {
                delete logger;
            }
        }
		*/
    }

}