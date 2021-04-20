/*********************************************************************************
 * Name: ASI_SubmitApprovalController
 * Description: approval controller
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * UNKNOWN       	UNKNOWN             	Created
 * 18/12/2018		Calvin Chiu				Added approval reason 
 * 21/01/2019       SH Ho                   Added Manual Share to PO Owner (SG)         
*/
public without sharing class ASI_SubmitApprovalController {
    
    public ASI_SubmitApprovalController(){
        
    }
    
    public PageReference submit(){
        string id = apexpages.currentpage().getparameters().get('id');
        String reason = apexpages.currentpage().getparameters().get('reason');
        System.debug('------ id ------ : ' + id);
        System.debug('------ reason ------ : ' + reason);
        if(id!=null && id!=''){
            //Modified by Introv Twinkle @20161031, validation related to PAF 
            List<ASI_MFM_Plan__c> plan = [SELECT id, ASI_MFM_Status__c, recordTypeId FROM ASI_MFM_Plan__c WHERE id =: id LIMIT 1];            
            List<ASI_HK_CRM_Pre_Approval_Form__c> paf = [SELECT id, ASI_HK_CRM_PAF_Status__c, LastModifiedDate, ASI_CRM_Converted_Date__c FROM ASI_HK_CRM_Pre_Approval_Form__c WHERE ASI_CRM_Commitment_No__c =: id LIMIT 1];
            
            // Add Manual Share to PO Owner   [SH] 2019-01-21
            Map<id, ASI_TnE_ClaimHeader__Share> ShrMap = new Map<id, ASI_TnE_ClaimHeader__Share>();
            for(ASI_TnE_ClaimHeader__c TnEHeader : [Select id, Ownerid, recordtype.developerName from ASI_TnE_ClaimHeader__c where id =: id limit 1]){
                if(TnEHeader.RecordType.developerName.contains('ASI_TnE_SG')){
                    Set<Id> POid_set = new Set<Id>();
                    
                    for(ASI_TnE_ClaimDetail__c tneD : [Select id, ASI_TnE_MFM_PO__c from ASI_TnE_ClaimDetail__c where ASI_TnE_ClaimHeader__c = :id]){
                        if(tneD.ASI_TnE_MFM_PO__c != null)
                            POid_set.add(tneD.ASI_TnE_MFM_PO__c);
                    }
                    for(ASI_MFM_PO__c po: [Select id, Ownerid from ASI_MFM_PO__c where id IN: POid_set]){
                        if(po.OwnerId != TnEHeader.OwnerId && ShrMap.get(po.OwnerId) == null ){
                            ASI_TnE_ClaimHeader__Share shr = new ASI_TnE_ClaimHeader__Share();
                            shr.ParentId = id;
                            shr.AccessLevel = 'Read';
                            shr.UserOrGroupId = po.OwnerId;
                            ShrMap.put(po.OwnerId, shr);
                        }
                    }                                        
                }
            }
            if(!Test.isRunningTest() && ShrMap != null)
                Database.SaveResult[] saveResult = Database.insert(ShrMap.values(), false);
            // END - [SH]
            
            if(plan != null && plan.size() > 0 && 
               plan[0].recordTypeId == Global_RecordTypeCache.getRTId('ASI_MFM_Plan__cASI_MFM_TW_Plan') && 
               paf != NULL && paf.size() > 0 &&
               (paf[0].ASI_HK_CRM_PAF_Status__c == 'Draft' || paf[0].ASI_CRM_Converted_Date__c == null)){
                ApexPages.Message myMsg;
                System.debug('Converted Date = '+paf[0].ASI_CRM_Converted_Date__c);
                System.debug('Last Modified Date = '+paf[0].LastModifiedDate);
                   
                if(paf[0].ASI_HK_CRM_PAF_Status__c == 'Draft')
                    myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot submit Plan for approval as associated PAF is in \'Draft\' status.');                    
                else if(paf[0].ASI_CRM_Converted_Date__c == null)          
                    myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot submit Plan for approval as it is not updated, please convert again from related PAF.');
                if(myMsg != NULL)
                    ApexPages.addMessage(myMsg);
                   
                return null;  
            }   
            else{
                
                try {
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setObjectId(id);
                    req1.setSubmitterId(UserInfo.getUserId());
                    req1.setComments(reason);
                    System.debug('------ req1 ------ : ' + req1);
                    Approval.ProcessResult result = Approval.process(req1);
                    System.debug('------ result ------ : ' + result); // DC - Added debug for testing [01-04-2016]
                    
                    if (!result.isSuccess()){
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Record failed to submit for approval.');
                        ApexPages.addMessage(myMsg);
                        return null;
                    }
                }
                catch (System.DmlException e){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(0));
                    ApexPages.addMessage(myMsg);
                    return null;
                }
            }
        }
        
        PageReference pageRef = new PageReference('/'+id);
        return pageRef;
    }
    
}