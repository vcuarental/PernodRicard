public class ASI_eForm_KR_DonationRequestTriggerClass {
    private final static String SHARING_REASON     = 'ASI_eForm_KR_Manual_Share__c';


        public static void routineBeforeUpsert(List<ASI_eForm_Donation_Request__c> triggerNew, Map<Id, ASI_eForm_Donation_Request__c> triggerOldMap) {
        Set<Id> OwnerIdSet = new Set<Id>();
        Map<String,ASI_MFM_Fix_Approval_Route__c>  FixApprovalRouteMap = new Map<String,ASI_MFM_Fix_Approval_Route__c>();
        Map<Id,User> UserMap = new Map<Id,User>();

        for(ASI_eForm_Donation_Request__c obj : triggerNew){
            OwnerIdSet.add(obj.OwnerId);
        }
        if(OwnerIdSet.size()>0 ){
            Set<String> UserSalesTeamSet = new Set<String>();
            List<User> UserList= [SELECT Id,Email,ASI_MFM_Team__c FROM User WHERE Id IN : OwnerIdSet AND ASI_MFM_Team__c!=NULL ];
            for(User u : UserList){
                UserMap.put(u.Id,u);
                UserSalesTeamSet.add(u.ASI_MFM_Team__c);
            }

            List<ASI_MFM_Fix_Approval_Route__c> FARList = new List<ASI_MFM_Fix_Approval_Route__c>([SELECT Id,ASI_MFM_Team__c, ASI_MFM_Corporate_Approver_1__c
                                                                                                   FROM ASI_MFM_Fix_Approval_Route__c
                                                                                                   WHERE ASI_MFM_Team__c IN :UserSalesTeamSet  AND RecordType.DeveloperName LIKE 'ASI_MFM_KR_Fix_Approval_Route'
                                                                                                   AND ASI_MFM_Module__c LIKE 'eForm' AND ASI_MFM_KR_Grand_Category__c ='Donation' AND ASI_MFM_Inactive__c = FALSE ]);

            for(ASI_MFM_Fix_Approval_Route__c FixApprovalRoute : FARList){
                FixApprovalRouteMap.put(FixApprovalRoute.ASI_MFM_Team__c,FixApprovalRoute);
            }
        }

        String handlerUserName = [SELECT Id,ASI_eForm_KR_Donation_Handler__c FROM  ASI_MFM_Setting__c ][0].ASI_eForm_KR_Donation_Handler__c;
        String delegatorId = [SELECT Id, DelegatedApproverId FROM User WHERE Username = :handlerUserName LIMIT 1][0].DelegatedApproverId;

        for(ASI_eForm_Donation_Request__c obj : triggerNew){
            if(FixApprovalRouteMap.containsKey(UserMap.get(obj.OwnerId).ASI_MFM_Team__c) ){
                obj.ASI_eForm_Sys_Approver_1__c = FixApprovalRouteMap.get(UserMap.get(obj.OwnerId).ASI_MFM_Team__c).ASI_MFM_Corporate_Approver_1__c;
            }
            if(delegatorId != null){
                obj.ASI_eForm_Sys_Approver_2__c = delegatorId;
            }
        }


    }

    public static void manualShareToSalesAdmin(List<ASI_eForm_Donation_Request__c> triggerNew, Map<Id, ASI_eForm_Donation_Request__c> triggerOldMap) {
        // Get donation with sales admin changes
        Map<String, Set<String>> donationIdToUserIds = new Map<String, Set<String>>();

        for (ASI_eForm_Donation_Request__c obj : triggerNew) {
            if (triggerOldMap == null || obj.ASI_eForm_Sales_Admin__c != triggerOldMap.get(obj.Id).ASI_eForm_Sales_Admin__c) {
                Set<String> userIds = donationIdToUserIds.containsKey(obj.Id)? donationIdToUserIds.get(obj.Id) : new Set<String>();
                if (obj.ASI_eForm_Sales_Admin__c != null) userIds.add(obj.ASI_eForm_Sales_Admin__c);
                donationIdToUserIds.put(obj.Id, userIds);
            }
        }

        // Delete old manual sharing
        List<ASI_eForm_Donation_Request__Share> shareListToDelete = [
            SELECT id
            FROM ASI_eForm_Donation_Request__Share
            WHERE parentId IN:donationIdToUserIds.keySet()
            AND RowCause = :SHARING_REASON
        ];
        delete shareListToDelete;

        // Insert new manual sharing
        List<ASI_eForm_Donation_Request__Share> newShareList = new List<ASI_eForm_Donation_Request__Share>();
        for (String donationId : donationIdToUserIds.keySet()) {
            Set<String> userIds = donationIdToUserIds.get(donationId);
            for (String userId : userIds) {
                newShareList.add(
                    (ASI_eForm_Donation_Request__Share) ASI_eForm_KR_ReturnOrder_TriggerClass.createCustomShare(
                        donationId, userId, 'ASI_eForm_Donation_Request', 'Edit', SHARING_REASON
                    )
                );
            }
        }
        insert newShareList;
    }

}