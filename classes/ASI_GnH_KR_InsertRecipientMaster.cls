/*******************************************************************************************
 * Name:ASI_GnH_KR_InsertRecipientMaster 
 * Description: Handler for ASI_GnH_Request_Recipient__c to 
 * 				compare with Recipient Master Table, Insert new record if no exsiting found 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------
 * 29/5/2017         Laputa: Kevin Choi      Created
*******************************************************************************************/
public with sharing class ASI_GnH_KR_InsertRecipientMaster extends ASI_TnE_TriggerAbstract {

    public ASI_GnH_KR_InsertRecipientMaster() {
        super('ASI_GnH_KR_InsertRecipientMaster');
    }

    private final static String koreaRecipientMasterRt = 'ASI_GnH_KR_Recipient_Master';
    private final static String koreaStaffMasterRt = 'ASI_GnH_KR_PR_Staffs_Master';

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        system.debug('Check Recipient Master Started!');
        List<ASI_GnH_Request_Recipient__c> recipientList = (List<ASI_GnH_Request_Recipient__c>) sObjList;
        Map<String, ASI_GnH_Request_Recipient__c> recipientMap = new Map<String, ASI_GnH_Request_Recipient__c>();
        system.debug('sObjList: '+recipientList);
        for (ASI_GnH_Request_Recipient__c recipient : recipientList){
            //system.debug('RecordType: '+Global_RecordTypeCache.getRt(recipient.recordTypeid).developerName.contains('ASI_GnH_KR_Request_Recipient'));
            //system.debug(recipient.RecordType.developerName);
            if(string.isEmpty(recipient.ASI_GnH_Recipient__c)){
                String keyset = generateKey(recipient.ASI_GnH_Sys_Name__c, recipient.ASI_GnH_Sys_Organization__c, recipient.ASI_GnH_Sys_Title__c,recipient.ASI_GnH_Sys_Company_Address__c);
                recipientMap.put(keyset,recipient);
            }
        }
        system.debug(recipientMap);
        if (recipientMap.keyset().size()>0){
            system.debug('Pass Into Compare: '+recipientMap);
            compareWithMasterTable(recipientMap);
        }
    }

    /************************************************
    Comapre with Recipient Master Record, 
    If no such existing record, then create a new one
    **************************************************/
    private void compareWithMasterTable(Map<String, ASI_GnH_Request_Recipient__c> recipientMap){
        Map<String,ASI_GnH_Recipient_Master__c> recipientMasterMap = new Map<String,ASI_GnH_Recipient_Master__c>();

        RecordType krRecipientMaster = [SELECT Id,Name from RecordType where recordType.developername = 'ASI_GnH_KR_Recipient_Master' limit 1];

        List<ASI_GnH_Recipient_Master__c> recipientMasterList = [SELECT Id, Name, ASI_GnH_Organization__c, ASI_GnH_Title__c, ASI_GnH_Mobile__c, ASI_GnH_Email__c, ASI_GnH_Company_Address__c, ASI_GnH_Active__c  
                                                                 FROM ASI_GnH_Recipient_Master__c 
                                                                 WHERE recordType.developerName =: koreaRecipientMasterRt OR recordType.developerName =:koreaStaffMasterRt];

        for (ASI_GnH_Recipient_Master__c recipientMaster : recipientMasterList){

            String masterKey = generateKey(recipientMaster.Name, recipientMaster.ASI_GnH_Organization__c, recipientMaster.ASI_GnH_Title__c, recipientMaster.ASI_GnH_Company_Address__c);
            recipientMasterMap.put(masterKey,recipientMaster);

        }

        Set<ASI_GnH_Recipient_Master__c> newRecordInsertSet = new Set<ASI_GnH_Recipient_Master__c>();
        List<ASI_GnH_Recipient_Master__c> newRecordInsertList = new List<ASI_GnH_Recipient_Master__c>();
        Map<String,ASI_GnH_Request_Recipient__c> recordNotAssigned = new Map<String,ASI_GnH_Request_Recipient__c>();

        for (string recipientKey: recipientMap.keyset()){
            //Check if the Master record have recipient's information
            if(recipientMasterMap.get(recipientKey) == null){
                system.debug('Master Record Not Found: '+ recipientKey);
                ASI_GnH_Request_Recipient__c originRecipient = recipientMap.get(recipientKey);
                //create a new record 
                ASI_GnH_Recipient_Master__c newMasterRecord = new ASI_GnH_Recipient_Master__c(Name = originRecipient.ASI_GnH_Sys_Name__c,
                                                                                              recordTypeid = krRecipientMaster.Id,
                                                                                              ASI_GnH_Organization__c = originRecipient.ASI_GnH_Sys_Organization__c,
                                                                                              ASI_GnH_Company_Address__c = originRecipient.ASI_GnH_Sys_Company_Address__c,
                                                                                              ASI_GnH_Title__c = originRecipient.ASI_GnH_Sys_Title__c,
                                                                                              ASI_GnH_Mobile__c = originRecipient.ASI_GnH_Sys_Mobile__c,
                                                                                              ASI_GnH_Email__c = originRecipient.ASI_GnH_Sys_Email__c,
                                                                                              ASI_GnH_Active__c = true);
                newRecordInsertSet.add(newMasterRecord);
                recordNotAssigned.put(recipientKey,originRecipient);
            }else{
                system.debug('Master Record Found: '+ recipientKey);
                if (recipientMasterMap.get(recipientKey).ASI_GnH_Active__c == false){
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Recipient trying to upload is inactive!'));
                    recipientMap.get(recipientKey).addError('Recipient trying to upload is inactive!',false);
                    system.debug('Error Encountered!');
                    
                }else{
                    recipientMap.get(recipientKey).ASI_GnH_Recipient__c = recipientMasterMap.get(recipientKey).Id;
                }
            }
        }
        if (newRecordInsertSet.size()>0){
            newRecordInsertList.addAll(newRecordInsertSet);
            insert newRecordInsertList;
            system.debug('Insert Again: '+ newRecordInsertList);
            assignRecipientId(newRecordInsertList,recordNotAssigned);
        }
    }
    /****************************************
   	Assign newly inserted Master Record Id 
    to ASI_GnH_Request_Recipient__c 
    ****************************************/

    private void assignRecipientId (List<ASI_GnH_Recipient_Master__c>newRecordInsert, Map<String, ASI_GnH_Request_Recipient__c> recipientMap){
        Map<String,Id> newRecordIdMap = new Map<String,Id>(); 
        for (ASI_GnH_Recipient_Master__c newRecord : newRecordInsert){
            String newRecordKey = generateKey(newRecord.Name,newRecord.ASI_GnH_Organization__c,newRecord.ASI_GnH_Title__c,newRecord.ASI_GnH_Company_Address__c);
            newRecordIdMap.put(newRecordKey,newRecord.Id);
        }

        for (string key: recipientMap.keyset()){
            if(newRecordIdMap.get(key)!=null){
                recipientMap.get(key).ASI_GnH_Recipient__c = newRecordIdMap.get(key);
            }
        }        
    }
    /********************
    Tool Function
    ********************/
    private string generateKey(String name,String organisation,String title, String address){
        string key = name+organisation+title+address;
        return key;        
    }

}