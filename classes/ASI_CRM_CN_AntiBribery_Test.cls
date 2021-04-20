@isTest
private class ASI_CRM_CN_AntiBribery_Test {
    
    Private static User tempU = [select id from user where CompanyName = 'Pernod Ricard China' limit 1];
    Private static User tempU2 = [select id,ManagerID from user where CompanyName = 'Pernod Ricard China' AND id !=:tempU.id limit 1];
    Private static User tempU3 = [select id,ManagerID from user where CompanyName = 'Pernod Ricard China' AND id !=:tempU.id AND id !=:tempU2.id limit 1];
    
    Private static List<ASI_CRM_Application_Parameter__c> tmpParameter = new List<ASI_CRM_Application_Parameter__c>();
    Private static List<ASI_CRM_Fix_Approval_Route__c> tmpFixRoute = new List<ASI_CRM_Fix_Approval_Route__c>();
    Private static List<ASI_CRM_Dynamic_Approval_Route__c> tmpDynamicRoute = new List<ASI_CRM_Dynamic_Approval_Route__c>();
    
    static testMethod void testtiggerclass(){
        
        tempU2.ManagerID = tempU.id;
        tempU3.ManagerID = tempU.id;
        update tempU2;
        update tempU3;
        
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case1',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case2',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case3',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case4',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case5',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case6',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case7',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case8',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case9',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case10',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case11',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case12',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case13',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case14',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case15',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case16',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case17',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case18',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case19',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case20',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case21',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case22',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case23',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case24',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case25',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case26',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case27',ASI_CRM_Threshhold__c = 1,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case28',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case29',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case30',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case31',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU2.id,ASI_CRM_CN_Alternative_Approver__c=tempU.id,ASI_CRM_CN_Type__c='Offering Non-PO'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU2.id,ASI_CRM_CN_Alternative_Approver__c=tempU.id,ASI_CRM_CN_Type__c='Offering H- Contract Outlet(Non-PO)'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU2.id,ASI_CRM_CN_Alternative_Approver__c=tempU.id,ASI_CRM_CN_Type__c='Offering PO(Non-Facilitation Fees)'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU2.id,ASI_CRM_CN_Alternative_Approver__c=tempU.id,ASI_CRM_CN_Type__c='Receiving Cash-Notification'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU2.id,ASI_CRM_CN_Alternative_Approver__c=tempU.id,ASI_CRM_CN_Type__c='Receiving G(non cash)&H-Non-Trip'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU2.id,ASI_CRM_CN_Alternative_Approver__c=tempU.id,ASI_CRM_CN_Type__c='Receiving G(non cash)&H-Trip'));
        
		tmpDynamicRoute.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_End_of_Dynamic_Route__c = true,ASI_CRM_Type__c='AB General',ASI_CRM_User__c=tempU.id, ASI_CRM_Approval_Limit__c = -9999999));
        tmpDynamicRoute.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_End_of_Dynamic_Route__c = true,ASI_CRM_Type__c='AB General',ASI_CRM_User__c=tempU3.id, ASI_CRM_Approval_Limit__c = 9999999));
        
        Insert tmpParameter;
        Insert tmpFixRoute;
        Insert tmpDynamicRoute;

        List<ASI_CRM_Anti_Bribery__c> tmpAntiBribery = new List<ASI_CRM_Anti_Bribery__c>();
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Offering_Non_PO'),ASI_CRM_Reporting_Item__c = 'Gift', ASI_CRM_Nature__c = 'a', ASI_CRM_AccumValueOfGiftsPerRecipient__c=1,ASI_CRM_Value_Per_Recipient__c=1));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Offering_Non_PO'),ASI_CRM_Reporting_Item__c = 'Gift',ASI_CRM_Nature__c = 'a', ASI_CRM_AccumValueOfGiftsPerRecipient__c=0,ASI_CRM_Value_Per_Recipient__c=1));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Offering_Non_PO'),ASI_CRM_Reporting_Item__c = 'Hospitality',ASI_CRM_Nature__c = 'a', ASI_CRM_AccumValueHospiPerRecipient__c=1,ASI_CRM_Value_Per_Recipient__c=1));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Offering_Non_PO'),ASI_CRM_Reporting_Item__c = 'Hospitality',ASI_CRM_Nature__c = 'a', ASI_CRM_AccumValueHospiPerRecipient__c=0,ASI_CRM_Value_Per_Recipient__c=1));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Offering_Non_PO'),ASI_CRM_Reporting_Item__c = 'Trips (Travelling Together)',ASI_CRM_Nature__c = 'a', ASI_CRM_AccumValueHospiPerRecipient__c=1,ASI_CRM_Value_Per_Recipient__c=1));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Offering_Non_PO'),ASI_CRM_Reporting_Item__c = 'Trips (Travelling Together)',ASI_CRM_Nature__c = 'a', ASI_CRM_AccumValueHospiPerRecipient__c=0,ASI_CRM_Value_Per_Recipient__c=1));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Offering_Non_PO'),ASI_CRM_Reporting_Item__c = 'Trips (Not Travelling Together)',ASI_CRM_Nature__c = 'a', ASI_CRM_AccumValueOfGiftsPerRecipient__c=1,ASI_CRM_Value_Per_Recipient__c=1));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Offering_Non_PO'),ASI_CRM_Reporting_Item__c = 'Trips (Not Travelling Together)',ASI_CRM_Nature__c = 'a', ASI_CRM_AccumValueOfGiftsPerRecipient__c=0,ASI_CRM_Value_Per_Recipient__c=1));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Offering_Non_PO'),ASI_CRM_Reporting_Item__c = 'Caritible Donation', ASI_CRM_Nature__c = 'a', ASI_CRM_Value_Per_Recipient__c=1));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Offering_Non_PO'),ASI_CRM_Reporting_Item__c = 'Sponsorship/Community Project', ASI_CRM_Nature__c = 'a', ASI_CRM_Value_Per_Recipient__c=1));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Offering_Non_PO'),ASI_CRM_Reporting_Item__c = 'Engagement of Lobbyists', ASI_CRM_Nature__c = 'a', ASI_CRM_Value_Per_Recipient__c=1));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Offering_Non_PO'),ASI_CRM_Within_3_Month__c = 'Contract term > 12 months and within 3 months prior to or after the completion of a competitive bid of tender', ASI_CRM_Nature__c = 'a', ASI_CRM_Value_Per_Recipient__c=1));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Offering_PO_excl_FP'),ASI_CRM_Reporting_Item__c = 'Gift', ASI_CRM_Nature__c = 'a', ASI_CRM_Value_Per_Recipient__c=1));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Offering_PO_excl_FP'),ASI_CRM_Reporting_Item__c = 'Hospitality', ASI_CRM_Nature__c = 'a', ASI_CRM_Value_Per_Recipient__c=1));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Offering_PO_excl_FP'),ASI_CRM_Reporting_Item__c = 'Caritible Donation', ASI_CRM_Nature__c = 'a', ASI_CRM_Value_Per_Recipient__c=1));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Offering_PO_excl_FP'),ASI_CRM_Reporting_Item__c = 'Sponsorship/Community Project', ASI_CRM_Nature__c = 'a', ASI_CRM_Value_Per_Recipient__c=1));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Offering_PO_excl_FP'),ASI_CRM_Reporting_Item__c = 'Political Donation', ASI_CRM_Nature__c = 'a', ASI_CRM_Value_Per_Recipient__c=1));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Offering_PO_excl_FP'),ASI_CRM_Reporting_Item__c = 'Engagement of Lobbyists', ASI_CRM_Nature__c = 'a', ASI_CRM_Value_Per_Recipient__c=1));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Offering_PO_excl_FP'),ASI_CRM_Reporting_Item__c = 'Trips (Not Travelling Together)', ASI_CRM_Nature__c = 'a', ASI_CRM_Value_Per_Recipient__c=1,ASI_CRM_If_trips_provide_more_info__c='test'));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Offering_PO_excl_FP'),ASI_CRM_Reporting_Item__c = 'Trips (Travelling Together)', ASI_CRM_Nature__c = 'a', ASI_CRM_Value_Per_Recipient__c=1,ASI_CRM_If_trips_provide_more_info__c='test'));
        /*tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Offering_H_Contract_OutletNPO'),ASI_CRM_Reporting_Item__c = 'Hospitality', ASI_CRM_Nature__c = 'a', ASI_CRM_Value_Per_Recipient__c=1));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ownerid = tempU3.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Offering_H_Contract_OutletNPO'),ASI_CRM_Reporting_Item__c = 'Trips (Travelling Together)', ASI_CRM_Nature__c = 'a', ASI_CRM_Value_Per_Recipient__c=1));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ownerid = tempU3.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Offering_H_Contract_OutletNPO'),ASI_CRM_Reporting_Item__c = 'Hospitality', ASI_CRM_Nature__c = 'a', ASI_CRM_Value_Per_Recipient__c=1));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Offering_H_Contract_OutletNPO'),ASI_CRM_Reporting_Item__c = 'Trips (Travelling Together)', ASI_CRM_Nature__c = 'a', ASI_CRM_Value_Per_Recipient__c=1));*/
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Receiving_G_non_cash_H'),ASI_CRM_Reporting_Item__c = 'Hospitality', ASI_CRM_Nature__c = 'a', ASI_CRM_Value_Per_Recipient__c=2));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Receiving_G_non_cash_H'),ASI_CRM_Reporting_Item__c = 'Hospitality', ASI_CRM_Nature__c = 'a', ASI_CRM_Within_3_Month__c = 'Contract term > 12 months and within 3 months prior to or after the completion of a competitive bid of tender',ASI_CRM_Value_Per_Recipient__c=1));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Receiving_G_non_cash_H'),ASI_CRM_Reporting_Item__c = 'Hospitality',ASI_CRM_Nature__c = 'a', ASI_CRM_Accum_Value_per_Recipient__c = 1,ASI_CRM_Value_Per_Recipient__c=0));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Receiving_G_non_cash_H'),ASI_CRM_Reporting_Item__c = 'Trip', ASI_CRM_Nature__c = 'a', ASI_CRM_Value_Per_Recipient__c=1,ASI_CRM_Nature_of_Report__c='Pre-approval'));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Receiving_G_non_cash_H'),ASI_CRM_Reporting_Item__c = 'Gift', ASI_CRM_Nature__c = 'a', ASI_CRM_Value_Per_Recipient__c=1));
        tmpAntiBribery.add(new ASI_CRM_Anti_Bribery__c(ASI_CRM_Auto_Submission_Flag__c = true, ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Receiving_Cash'), ASI_CRM_Nature__c = 'a', ASI_CRM_Status__c='draft'));
      
        Test.startTest();
        
        Insert tmpAntiBribery;
        update tmpAntiBribery;
        
        Apexpages.standardController sc = new apexpages.standardController(tmpAntiBribery[0]);
        ASI_CRM_CN_AntiBribery_SubmitController testAb = new ASI_CRM_CN_AntiBribery_SubmitController(sc);
        
        testAb.submitForApproval();
        testAb.cancel();
        
        Test.stopTest();
    }
    
    static testMethod void testSubmitCRTLLER(){
        
        tempU2.ManagerID = tempU.id;
        update tempU2;
        tempU.ManagerID = tempU3.id;
        update tempU;
        
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case29',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU2.id,ASI_CRM_CN_Alternative_Approver__c=tempU.id,ASI_CRM_CN_Type__c='Offering Non-PO',ASI_CRM_CN_Entry_Limit__c=-99999));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Alternative_Approver__c=tempU.id,ASI_CRM_CN_Type__c='Offering H- Contract Outlet(Non-PO)',ASI_CRM_CN_Entry_Limit__c=-99999));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU2.id,ASI_CRM_CN_Alternative_Approver__c=tempU.id,ASI_CRM_CN_Type__c='Offering PO(Non-Facilitation Fees)',ASI_CRM_CN_Entry_Limit__c=-99999));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Alternative_Approver__c=tempU.id,ASI_CRM_CN_Type__c='Receiving Cash-Notification',ASI_CRM_CN_Entry_Limit__c=-99999));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU2.id,ASI_CRM_CN_Alternative_Approver__c=tempU.id,ASI_CRM_CN_Type__c='Receiving G(non cash)&H-Non-Trip',ASI_CRM_CN_Entry_Limit__c=-99999));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Alternative_Approver__c=tempU.id,ASI_CRM_CN_Type__c='Receiving G(non cash)&H-Trip',ASI_CRM_CN_Entry_Limit__c=-99999));
        
        tmpDynamicRoute.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_End_of_Dynamic_Route__c = true,ASI_CRM_Type__c='AB General',ASI_CRM_User__c=tempU.id, ASI_CRM_Approval_Limit__c = -9999999));
        tmpDynamicRoute.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_End_of_Dynamic_Route__c = true,ASI_CRM_Type__c='AB General',ASI_CRM_User__c=tempU3.id, ASI_CRM_Approval_Limit__c = 9999999));
        
        Insert tmpParameter;
        Insert tmpFixRoute;
        Insert tmpDynamicRoute;
        
        ASI_CRM_Anti_Bribery__c tmpAB = new ASI_CRM_Anti_Bribery__c(ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Receiving_G_non_cash_H'), ASI_CRM_Nature__c = 'a', ASI_CRM_Reporting_Item__c = 'Hospitality',ASI_CRM_Value_Per_Recipient__c=800,ASI_CRM_Nature_of_Report__c='Pre-approval');
        ASI_CRM_Anti_Bribery__c tmpAB2 = new ASI_CRM_Anti_Bribery__c(ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Receiving_Cash'), ASI_CRM_Nature__c = 'a' );
        insert tmpAB;
        insert tmpAB2;
        
        Apexpages.standardController sc = new apexpages.standardController(tmpAB);
        Apexpages.standardController sc2 = new apexpages.standardController(tmpAB2);
        ASI_CRM_CN_AntiBribery_SubmitController testAb = new ASI_CRM_CN_AntiBribery_SubmitController(sc);
        ASI_CRM_CN_AntiBribery_SubmitController testAb2 = new ASI_CRM_CN_AntiBribery_SubmitController(sc2);
        
        Test.startTest();
        
        testAb.submitForApproval();
        testAb2.submitForApproval();
        testAb.cancel();
        
        Test.stopTest();
    }
    
    //20170116, Elufa
    static testMethod void testAdminDelCtrl(){
        
        tempU2.ManagerID = tempU.id;
        update tempU2;
        tempU.ManagerID = tempU3.id;
        update tempU;
        
        tmpParameter.add(new ASI_CRM_Application_Parameter__c(ASI_CRM_Parameter_Key__c = 'case29',ASI_CRM_Threshhold__c = 0,ASI_CRM_Module__c='AB'));
        
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU2.id,ASI_CRM_CN_Alternative_Approver__c=tempU.id,ASI_CRM_CN_Type__c='Offering Non-PO',ASI_CRM_CN_Entry_Limit__c=-99999));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Alternative_Approver__c=tempU.id,ASI_CRM_CN_Type__c='Offering H- Contract Outlet(Non-PO)',ASI_CRM_CN_Entry_Limit__c=-99999));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU2.id,ASI_CRM_CN_Alternative_Approver__c=tempU.id,ASI_CRM_CN_Type__c='Offering PO(Non-Facilitation Fees)',ASI_CRM_CN_Entry_Limit__c=-99999));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Alternative_Approver__c=tempU.id,ASI_CRM_CN_Type__c='Receiving Cash-Notification',ASI_CRM_CN_Entry_Limit__c=-99999));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU2.id,ASI_CRM_CN_Alternative_Approver__c=tempU.id,ASI_CRM_CN_Type__c='Receiving G(non cash)&H-Non-Trip',ASI_CRM_CN_Entry_Limit__c=-99999));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Alternative_Approver__c=tempU.id,ASI_CRM_CN_Type__c='Receiving G(non cash)&H-Trip',ASI_CRM_CN_Entry_Limit__c=-99999));
        
        tmpDynamicRoute.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_End_of_Dynamic_Route__c = true,ASI_CRM_Type__c='AB General',ASI_CRM_User__c=tempU.id, ASI_CRM_Approval_Limit__c = -9999999));
        tmpDynamicRoute.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_End_of_Dynamic_Route__c = true,ASI_CRM_Type__c='AB General',ASI_CRM_User__c=tempU3.id, ASI_CRM_Approval_Limit__c = 9999999));
        
        Insert tmpParameter;
        Insert tmpFixRoute;
        Insert tmpDynamicRoute;
        
        ASI_CRM_Anti_Bribery__c tmpAB = new ASI_CRM_Anti_Bribery__c(ASI_CRM_Sys_Approver_1__c = tempU.id, ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Receiving_G_non_cash_H'), ASI_CRM_Nature__c = 'a', ASI_CRM_Reporting_Item__c = 'Hospitality',ASI_CRM_Value_Per_Recipient__c=800,ASI_CRM_Nature_of_Report__c='Pre-approval');
        ASI_CRM_Anti_Bribery__c tmpAB2 = new ASI_CRM_Anti_Bribery__c(ownerid = tempU2.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Anti_Bribery__cASI_CRM_CN_Receiving_Cash'), ASI_CRM_Nature__c = 'a' );
        insert tmpAB;
        insert tmpAB2;
        
        Apexpages.standardController sc = new apexpages.standardController(tmpAB);
        Apexpages.standardController sc2 = new apexpages.standardController(tmpAB2);
        ASI_CRM_CN_AB_AdminDelCtrl testAb = new ASI_CRM_CN_AB_AdminDelCtrl(sc);
        ASI_CRM_CN_AB_AdminDelCtrl testAb2 = new ASI_CRM_CN_AB_AdminDelCtrl(sc2);
        
        Test.startTest();        
        testAb.adminDel();
        testAb2.adminDel();
        Test.stopTest();
    }
    //20170116, Elufa
}