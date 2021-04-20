/*********************************************************************************
 * Name:ASI_GnH_KR_ManageRecipientAllCtrl 
 * Description: Controller for ASI_GnH_KR_ManageRecipientAll page
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -------------------------------------
 * 29/5/2017         Laputa: Kevin Choi      Created
*********************************************************************************/
public class ASI_GnH_KR_ManageRecipientAllCtrl{
    public ASI_GnH_Request__c gnhRequest {get; set;}
    public Decimal paxNo {get; set;}
    public Integer isEditable{get; set;}
    
    public String paxNoJSON {get {return toJsonString(paxNo);}}
    
    private final static String koreaRecipientMasterRt = 'ASI_GnH_KR_Recipient_Master';
    private final static String koreaStaffMasterRt = 'ASI_GnH_KR_PR_Staffs_Master';

    
    public ASI_GnH_KR_ManageRecipientAllCtrl(ApexPages.StandardSetController stdController) {
        system.debug('Start Init');
        try {            
            String RequestId = ApexPages.currentPage().getParameters().get('Id');
            gnhRequest = [SELECT ID,Name,ASI_GnH_PAX__c,ASI_GnH_Status__c FROM ASI_GnH_Request__c WHERE ID =:RequestId];
            paxNo = gnhRequest.ASI_GnH_PAX__c;
            system.debug('PAX No.:'+ paxNo);
            if (gnhRequest.ASI_GnH_Status__c == 'Draft'||gnhRequest.ASI_GnH_Status__c == 'Rejected'){
				isEditable = 1;            
            }else{
            	isEditable = 2;
            }
            system.debug('isEditable:'+ isEditable);
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage()));
            return;
        }
        
    }
    
    /**************************************************
	get values from sObject for all auto-complete field
    ***************************************************/

    @RemoteAction
    public static List<sObject> findList(string obj,string statement, string qry){
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null){
            return null;// Object name not valid
        }//end if
        // create the filter text
        String filter = qry;       
        //begin building the dynamic soql query
        String soql;
        if(filter != '' || filter != null)
            if(obj != 'ASI_GnH_Threshold__c')
                soql = 'select '+statement+' from ' + obj + filter +' order by Name';
        else
            soql = 'select '+statement+' from ' + obj + filter +' order by ASI_GnH_Threshold_Amount__c ASC';
        else
            soql = 'select '+statement+' from ' + obj +' order by Name';

        List<sObject> sobjs = new List<sObject>();        
        List<String> results = new List<String>();        
        System.debug('soql:' + soql);

        try{
            SYSTEM.debug('TEST SQL AND COMPLETE: '+soql);
            sobjs = Database.query(soql);
            System.debug('Results Found: ' + sobjs);
            return sobjs; 
        }//end try
        catch (QueryException e){
            return null;
        }//end catch
        return sobjs;
    }
    /************************************
	get all recipient Master data for KR
    *************************************/
    @RemoteAction
    public static String getRecipientMaster(){
        List<ASI_GnH_Recipient_Master__c> recipientMasterList = [SELECT Id, Name
                                                                 ,ASI_GnH_Email__c
                                                                 ,ASI_GnH_Mobile__c
                                                                 ,ASI_GnH_Organization__c
                                                                 ,ASI_GnH_Company_Address__c
                                                                 ,ASI_GnH_Title__c 
                                                                 FROM ASI_GnH_Recipient_Master__c
                                                                WHERE recordType.developerName =: koreaRecipientMasterRt OR recordType.developerName =:koreaStaffMasterRt];

        Map<String,ASI_GnH_Recipient_Master__c> recipientMasterMap= new Map<String,ASI_GnH_Recipient_Master__c>();
        for (ASI_GnH_Recipient_Master__c recipientMaster : recipientMasterList){
            recipientMasterMap.put(recipientMaster.Id,recipientMaster);
        }
        String recipientMasterJsonList = JSON.serialize(recipientMasterMap);
        return recipientMasterJsonList;
    }

 	/**********************************************
	get all recipient  data for current GnH request
    ***********************************************/
    @RemoteAction
    public static string getGnHRecipient(Id gnhRequestId){
        List<ASI_GnH_Request_Recipient__c> recipientList = [SELECT Id,ASI_GnH_Title__c,ASI_GnH_Organization__c,ASI_GnH_Mobile__c,ASI_GnH_Email__c,
                                                            ASI_GnH_Request__c,
                                                            ASI_GnH_Recipient__c,
                                                            ASI_GnH_Recipient__r.Name,
                                                            ASI_GnH_Recipient__r.ASI_GnH_Title__c,
                                                            ASI_GnH_Recipient__r.ASI_GnH_Organization__c,
                                                            ASI_GnH_Recipient__r.ASI_GnH_Company_Address__c,
                                                            ASI_GnH_Recipient__r.ASI_GnH_Mobile__c,
                                                            ASI_GnH_Recipient__r.ASI_GnH_Email__c
                                                            FROM ASI_GnH_Request_Recipient__c
                                                            WHERE ASI_GnH_Request__c = :gnhRequestId ORDER BY Id];

        String JSONrecipientList = JSON.serialize(recipientList);  
        return JSONrecipientList;    
    }
	/************
	Save Function
    *************/
    @RemoteAction
    public static remoteActionResult doCashSave(Map<Integer, ASI_GnH_Request_Recipient__c> apexRequestRecipient, String delRecipientIdsObjJSON){
        Savepoint sp = Database.setSavepoint();
        ASI_GnH_KR_ManageRecipientAllCtrl.remoteActionResult result = new ASI_GnH_KR_ManageRecipientAllCtrl.remoteActionResult();   
        try{
            if (String.isNotEmpty(delRecipientIdsObjJSON)) {
                system.debug('delClaimListJSON: ' + delRecipientIdsObjJSON);
                List<Object> delRecipientIdList = (List<Object>) JSON.deserializeUntyped(delRecipientIdsObjJSON);
                Set<Id> delRecipientIds = ASI_GnH_KR_ManageRecipientAllCtrl.getdeleteRecipientId(delRecipientIdList);
                List<ASI_GnH_Request_Recipient__c> delList =  ASI_GnH_KR_ManageRecipientAllCtrl.getdeleteRecipient(delRecipientIds);
                delete delList;
                system.debug('Delete Successful');
            }

            if(!apexRequestRecipient.keySet().isEmpty()){
                system.debug('apexRequestRecipient: ' + apexRequestRecipient.keySet());
                List<ASI_GnH_Request_Recipient__c> recipientInsertList = ASI_GnH_KR_ManageRecipientAllCtrl.getRecipientByApexMap(apexRequestRecipient);
                upsert recipientInsertList;
                //change update->upsert,cash claim
                system.debug('Save Successful');
            }

        } catch(DmlException e) {
            Database.rollback(sp);
            result.SuccessFlag = false;
            for (Integer i = 0; i < e.getNumDml(); i++) {
                integer index = Integer.valueOf(e.getDmlIndex(i)) + 1; 
                result.errorMessages.add('#' + index +': ' + e.getDmlMessage(i));
            }
            return result;
        }catch(Exception e) {
            Database.rollback(sp);
            result.SuccessFlag = false;
            result.errorMessages.add(e.getMessage());
            return result;
        }

        return result;
    }

    public static Set<Id> getdeleteRecipientId(List<Object> delRecipientIdList) {
        Set<Id> delRecipientIds = new Set<Id>();
        for (Object item : delRecipientIdList) {
            delRecipientIds.add((String)item);
        }
        return delRecipientIds;
    }

    public static List<ASI_GnH_Request_Recipient__c> getdeleteRecipient(Set<Id> delRecipientIds){
        return [SELECT Id FROM ASI_GnH_Request_Recipient__c WHERE Id IN: delRecipientIds];
    } 

    public static List<ASI_GnH_Request_Recipient__c> getRecipientByApexMap(Map<Integer, ASI_GnH_Request_Recipient__c> apexRequestRecipientMap){
        List<ASI_GnH_Request_Recipient__c> recipientInsertList = new List<ASI_GnH_Request_Recipient__c>();
        for(Integer key : apexRequestRecipientMap.keyset()){
            ASI_GnH_Request_Recipient__c newRecipient = apexRequestRecipientMap.get(key);
            system.debug('Record '+key+': '+newRecipient);
            recipientInsertList.add(newRecipient);                 
        }
        return recipientInsertList;
    }
    
      private String toJsonString(Object obj) {
    	return System.JSON.serialize(obj);
	}
    

    public class remoteActionResult{
        public Boolean SuccessFlag {set;get;} 
        public List<String> errorMessages {set;get;}

        public remoteActionResult(){
            this.SuccessFlag = true;
            this.errorMessages = new List<String>();
        }
    }
}