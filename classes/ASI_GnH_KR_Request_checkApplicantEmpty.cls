/*********************************************************************************
 * Name:ASI_GnH_KR_Request_checkApplicantEmpty
 * Description: Auto fill the applicant field as owner if it is empty
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 2017-05-04       Laputa: Kevin Choi      Created
*********************************************************************************/
public without sharing class ASI_GnH_KR_Request_checkApplicantEmpty extends ASI_GnH_Request_TriggerAbstract{


    public override void executeTriggerAction(TriggerAction tAction, List<sObject> newList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<ASI_GnH_Request__c> requestList = (List<ASI_GnH_Request__c>) newList;

        for (ASI_GnH_Request__c request : requestList){
            if (String.isEmpty(request.ASI_GnH_Applicant__c)){
                system.debug(request.OwnerId);
                Id requestOwner = request.OwnerId;
                request.ASI_GnH_Applicant__c = requestOwner;
            }        
        }    
    }
}