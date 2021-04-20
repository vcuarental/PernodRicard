/*********************************************************************************
 * Name:ASI_TnE_TW_ClaimHeaderCloneController
 * Description: Clone claim details
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 1/12/2015        Laputa: Hank            Created
*********************************************************************************/

public without sharing class ASI_TnE_TW_ClaimHeaderCloneController{
    public String url {get; set;}
    public ASI_TnE_ClaimHeader__c header;
    public List<ASI_TnE_ClaimDetail__c> detailList;
    public ASI_TnE_TW_ClaimHeaderCloneController(ApexPages.StandardController controller) {
        header = new ASI_TnE_ClaimHeader__c();
        detailList = new List<ASI_TnE_ClaimDetail__c>();
        String headerId = apexpages.currentpage().getparameters().get('id');
        String theQuery = 'Select ';
        Map<String,Schema.SObjectField> headerFieldsMap = Schema.SObjectType.ASI_TnE_ClaimHeader__c.fields.getMap();
        for(String fields:headerFieldsMap.keySet()){
            theQuery += fields + ' ,';
        }
        theQuery = theQuery.subString(0, theQuery.length() - 1);
        theQuery += ' From ASI_TnE_ClaimHeader__c Where Id = :headerId';
        header = (ASI_TnE_ClaimHeader__c)Database.query(theQuery);
        
        //Get detail records
        theQuery = 'Select ';
        Map<String, Schema.SObjectField> detailFieldMap = Schema.SObjectType.ASI_TnE_ClaimDetail__c.fields.getMap();
        for(String fields:detailFieldMap.keySet()){
            theQuery += fields + ' ,';
        }
        thequery = theQuery.subString(0,theQuery.length()-1);
        theQuery += ' From ASI_TnE_ClaimDetail__c Where ASI_TnE_ClaimHeader__c =:headerId';
        detailList = (List<ASI_TnE_ClaimDetail__c>)Database.query(theQuery);
    }
    public void cloneTnE(){
        Savepoint savePoint = Database.setSavepoint();
        
        try {
            ASI_TnE_ClaimHeader__c newHeader = new ASI_TnE_ClaimHeader__c();
            List<ASI_TnE_ClaimDetail__c> newDetailList = new List<ASI_TnE_ClaimDetail__c>();
            newHeader = header.clone(true,true);
            newHeader.Id = null;
            newHeader.ASI_TnE_Total_Amount_Approved__c = 0;
            newHeader.ASI_TnE_Sys_Notified__c = false;
            newHeader.ASI_TnE_Status__c = 'Draft';
            newHeader.ASI_TnE_KR_GL_Date__c = null;
            newHeader.ASI_TnE_Sync_to_JDE_Date__c = null; //20170104, Elufa Support
            newHeader.ASI_TnE_JDE_Document_No__c = ''; //20170104, Elufa Support
            newHeader.ASI_TnE_JDE_Document_Type__c = ''; //20170104, Elufa Support
            newHeader.ASI_TnE_Pymt_Date__c = null; //20170104, Elufa Support
            newHeader.recordtypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_TW_Claim_Header');  
            insert newHeader;
            
            for(ASI_TnE_ClaimDetail__c detail:detailList){
                ASI_TnE_ClaimDetail__c newDetail = new ASI_TnE_ClaimDetail__c();
                newDetail = detail.clone(true,true);
                newDetail.Id = null;
                newDetail.ASI_TnE_Receipt_Date__c = null;
                newDetail.ASI_TnE_ClaimHeader__c = newHeader.Id;
                newDetailList.add(newDetail);      
            }
            insert newDetailList;
            
       		url = newHeader.Id;  
        } catch (Exception e) {
			Database.rollback(savePoint);
            url = null;
        }
               
    }
}