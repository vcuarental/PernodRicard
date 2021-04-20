/*
 * 20200328:AM@Introv - approval of POSM/FOC/Payment start
 * "ASI_MFM_Payment_TriggerClass" is found being used by many regions: TW, JP, KR, MY, TH
 * Moreover, the versions of "ASI_MFM_Payment_TriggerClass" are different among SANDBOX (B6), B1FULL, PRODUCTION.
 * For better maintenance and test class coverage, the approval logic will be using this new class.
 * 20200328:AM@Introv - approval of POSM/FOC/Payment end
 */ 

/*
 * 20200328:AM@Introv - approval of POSM/FOC/Payment start
 * similar logic of FOC approval
 * copy from "ASI_CRM_TW_FreeGoodsRequest_TriggerCls"
 * 20200328:AM@Introv - approval of POSM/FOC/Payment end
 */

public without sharing class ASI_MFM_TW_Payment_ApprovalCls {

    Private Static Final Map<String, Schema.SObjectField> Payment_FIELD_MAP = Schema.SObjectType.ASI_MFM_Payment__c.fields.getMap();
    Private Static Final Map<String, Schema.SObjectField> MFM_Fix_Approval_Route_FIELD_MAP = Schema.SObjectType.ASI_MFM_Fix_Approval_Route__c.fields.getMap();
    
    Private Static Final List<ASI_MFM_Dynamic_Approval_Route__c> G_AppRoute_Dynamic = [SELECT Id, ASI_MFM_User__c, ASI_MFM_Approval_Limit__c, ASI_MFM_Manager_ID__c, ASI_MFM_End_of_1st_Route__c, ASI_MFM_Skip_to_Next_Level__c, ASI_MFM_Inactive__c 
                                                                                       FROM ASI_MFM_Dynamic_Approval_Route__c 
                                                                                       WHERE RecordType.DeveloperName = 'ASI_MFM_TW_Dynamic_Approval_Route' AND ASI_MFM_Inactive__c = FALSE];
    Private Static Final List<ASI_MFM_Fix_Approval_Route__c> G_AppRoute_Fix = [SELECT Id, ASI_MFM_Department__c, ASI_MFM_Finance__c, ASI_MFM_Marketing_Director__c, ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c, ASI_MFM_Region_Area_Channel__c, ASI_MFM_Company__c
                                                                               		,ASI_MFM_Corporate_Approver_1__c,ASI_MFM_Corporate_Approver_2__c,ASI_MFM_Corporate_Approver_3__c,ASI_MFM_Corporate_Approver_4__c,ASI_MFM_Corporate_Approver_5__c,ASI_MFM_Corporate_Approver_6__c,ASI_MFM_Corporate_Approver_7__c,ASI_MFM_Corporate_Approver_8__c,ASI_MFM_Corporate_Approver_9__c,ASI_MFM_Corporate_Approver_10__c,ASI_MFM_Corporate_Approver_11__c,ASI_MFM_Corporate_Approver_12__c
                                                                               		,ASI_MFM_Approval_Limit_CA1__c,ASI_MFM_Approval_Limit_CA2__c,ASI_MFM_Approval_Limit_CA3__c,ASI_MFM_Approval_Limit_CA4__c,ASI_MFM_Approval_Limit_CA5__c,ASI_MFM_Approval_Limit_CA6__c,ASI_MFM_Approval_Limit_CA7__c,ASI_MFM_Approval_Limit_CA8__c,ASI_MFM_Approval_Limit_CA9__c,ASI_MFM_Approval_Limit_CA10__c,ASI_MFM_Approval_Limit_CA11__c,ASI_MFM_Approval_Limit_CA12__c 
                                                                               FROM ASI_MFM_Fix_Approval_Route__c WHERE RecordType.DeveloperName = 'ASI_MFM_TW_Fix_Approval_Route'];
    Private Static Final List<ASI_CRM_TW_Field_Mapping__mdt> G_MDT_FieldMap = [SELECT Id, ASI_CRM_Type__c, ASI_CRM_From_Value__c, ASI_CRM_To_Value__c, ASI_CRM_Channel__c
                                                                                FROM ASI_CRM_TW_Field_Mapping__mdt 
                                                                            	WHERE ASI_CRM_Type__c IN ('Department','Account Type')];
    
    public static void setApprovers(List<ASI_MFM_Payment__c> trigger_new, Map<Id, ASI_MFM_Payment__c> trigger_oldMap) {
        Map<Id, ASI_MFM_Dynamic_Approval_Route__c> oDynRoute = new Map<Id, ASI_MFM_Dynamic_Approval_Route__c>();
        List<ASI_MFM_Fix_Approval_Route__c> oFixRoute = new List<ASI_MFM_Fix_Approval_Route__c>();

        Map<String,String> oFieldMap_Dept = new Map<String,String>();
        Map<String,String> oFieldMap_Channel = new Map<String,String>();
        Map<String,String> oFieldMap_AccType = new Map<String,String>();
        
        Map<Id, ASI_MFM_Payment__c> oMap_Header = new Map<Id, ASI_MFM_Payment__c>([
            SELECT Id, ASI_MFM_Plan__c, ASI_MFM_Plan__r.ASI_MFM_Prefix__c
            	, (SELECT Id, Name, ASI_MFM_Sub_brand__c, ASI_MFM_Sub_brand__r.ASI_TH_CRM_Brand_Code__c , ASI_MFM_PO_Line_Item__c
                   , ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.ASI_MFM_Reporting_Category__c
                   , ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_Brand_Code_Only__c
                   FROM Payment_Line_Items__r)
            FROM ASI_MFM_Payment__c 
            WHERE Id IN :trigger_new]);
        
        //setup dynamic route
        for(ASI_MFM_Dynamic_Approval_Route__c oRoute : G_AppRoute_Dynamic) {
            oDynRoute.put(oRoute.ASI_MFM_User__c, oRoute);
        }
        
        //setup fix route
        for(ASI_MFM_Fix_Approval_Route__c oRoute : G_AppRoute_Fix) {
            oFixRoute.add(oRoute);
        }
        
        //setup field mapping
        for(ASI_CRM_TW_Field_Mapping__mdt oFieldMap : G_MDT_FieldMap) 
        {
            if (oFieldMap.ASI_CRM_Type__c == 'Department') oFieldMap_Dept.put(oFieldMap.ASI_CRM_From_Value__c, oFieldMap.ASI_CRM_To_Value__c);
            if (oFieldMap.ASI_CRM_Type__c == 'Department') oFieldMap_Channel.put(oFieldMap.ASI_CRM_From_Value__c, oFieldMap.ASI_CRM_Channel__c);
            if (oFieldMap.ASI_CRM_Type__c == 'Account Type') oFieldMap_AccType.put(oFieldMap.ASI_CRM_From_Value__c, oFieldMap.ASI_CRM_To_Value__c);
        }
        
        //setup Owner - check owner department
        List<Id> ltOwnerId = new List<Id>();
        for(ASI_MFM_Payment__c oHeader: trigger_new) {
            ltOwnerId.add(oHeader.OwnerId);
        }
        Map<ID, User> oMap_Owner = new Map<ID, User>([SELECT Id,Department,ASI_MFM_Department__c,ManagerId,ASI_Line_Manager__c,ASI_MFM_Direct_Report__c FROM User WHERE Id IN :ltOwnerId]);
        
        /*
        //setup fix route for FOC
        Map<String, Decimal> oPayRoute_FIN = new Map<String, Decimal>();
        Map<String, Decimal> oPayRoute_HR = new Map<String, Decimal>();
        Map<String, Decimal> oPayRoute_MKT = new Map<String, Decimal>();
        Map<String,Map<String, Decimal>> oPayRoute_Sales = new Map<String,Map<String, Decimal>>();
        
        for(ASI_MFM_Fix_Approval_Route__c oRoute : oFixRoute)
        {
            switch on oRoute.ASI_MFM_Department__c {
                when 'FIN' {
                    oPayRoute_FIN = getFixApproversWLimit(oRoute);
                }
                when 'HR' {
                    oPayRoute_HR = getFixApproversWLimit(oRoute);
                }
                when 'MKT' {
                    if (oRoute.ASI_MFM_Brand__c == NULL) oPayRoute_MKT = getFixApproversWLimit(oRoute);
                }
                when 'Sales' {
                    if (oRoute.ASI_MFM_Region_Area_Channel__c != NULL) {
                        Map<String, Decimal> oPayRoute_Temp = getFixApproversWLimit(oRoute);
                        oPayRoute_Sales.put(oRoute.ASI_MFM_Region_Area_Channel__c, oPayRoute_Temp);
                    }
                }
            }
        }
		*/
        
        //set approvers
        for(ASI_MFM_Payment__c oHeader : trigger_new) {
            string sStatus = oHeader.ASI_MFM_Status__c;
            Id id_RT = oHeader.RecordTypeId;
            
            if(sStatus == 'Draft' || sStatus == 'Submitted') {
                /*
                setApprovers4Payment(oHeader,oMap_Header,oDynRoute
                                     ,oMap_Owner,oPayRoute_Sales,oPayRoute_MKT
                                     ,oPayRoute_HR,oPayRoute_FIN
                                     ,oFieldMap_Dept,oFieldMap_Channel,oFieldMap_AccType);
                */
                setApprovers4Payment(oHeader,oMap_Header,oDynRoute
                                     ,oMap_Owner,oFixRoute
                                     ,oFieldMap_Dept,oFieldMap_Channel,oFieldMap_AccType);
            }
        }

    }
    
    private static void setApprovers4Payment(ASI_MFM_Payment__c oHeader, Map<Id, ASI_MFM_Payment__c> oMap_Header, Map<Id, ASI_MFM_Dynamic_Approval_Route__c> oDynRoute
	, Map<ID, User> oMap_Owner, List<ASI_MFM_Fix_Approval_Route__c> oFixRoute_Payment
	, Map<String,String> oFieldMap_Dept, Map<String,String> oFieldMap_Channel, Map<String,String> oFieldMap_AccType) {
    	
        setApproverToNull(oHeader);
		Set<String> oSet_Approver = new Set<String>();

        Boolean bIsTrade = oHeader.ASI_MFM_Trade__c;
        
        Decimal dCheckAmount = oHeader.ASI_MFM_Payment_Amount__c;
		dCheckAmount = dCheckAmount.setScale(2, RoundingMode.HALF_UP);

        String sOwnerDept = '';
        if(oMap_Owner.get(oHeader.OwnerId).ASI_MFM_Department__c != NULL && oFieldMap_Dept.get(oMap_Owner.get(oHeader.OwnerId).ASI_MFM_Department__c) != NULL)
			sOwnerDept = oFieldMap_Dept.get(oMap_Owner.get(oHeader.OwnerId).ASI_MFM_Department__c);
        String sOwnerChannel = '';
        if(oMap_Owner.get(oHeader.OwnerId).ASI_MFM_Department__c != NULL && oFieldMap_Channel.get(oMap_Owner.get(oHeader.OwnerId).ASI_MFM_Department__c) != NULL)
			sOwnerChannel = oFieldMap_Channel.get(oMap_Owner.get(oHeader.OwnerId).ASI_MFM_Department__c);
        
        //assign fix route
        Map<String, Decimal> oPayRoute_DEPT = new Map<String, Decimal>();
        
        for(ASI_MFM_Fix_Approval_Route__c oRoute : oFixRoute_Payment) {
            if (
                (oRoute.ASI_MFM_Department__c == sOwnerDept)
                &&
            	((bIsTrade && oRoute.ASI_MFM_Company__c == 'TRADE') || (!bIsTrade && oRoute.ASI_MFM_Company__c == 'NON-TRADE'))
            )
            {
                if (sOwnerDept == 'Sales') {
                    if ((sOwnerChannel != '') && (sOwnerChannel != NULL) && (oRoute.ASI_MFM_Region_Area_Channel__c != NULL) && (oRoute.ASI_MFM_Region_Area_Channel__c == sOwnerChannel)) {
                        oPayRoute_DEPT = getFixApproversWLimit(oRoute);
                    }
                } else {
                    oPayRoute_DEPT = getFixApproversWLimit(oRoute);
                }
            }
        }

        if (!bIsTrade) {
            Set<String> oSet_Approver_Dynamic = setDynamicApprovers(oHeader.OwnerId, oDynRoute, oMap_Owner, dCheckAmount);
            if (oSet_Approver_Dynamic.size()>0) oSet_Approver.addAll(oSet_Approver_Dynamic);
        }
        
        Set<String> oSet_Approver_Fix = setApprovers_CheckLimit(dCheckAmount, oPayRoute_DEPT);
		if (oSet_Approver_Fix.size()>0) oSet_Approver.addAll(oSet_Approver_Fix);
        
        //assign approvers
        if (oSet_Approver.size()>0) {
            List<String> ltFinalApprover = new List<String>();
            ltFinalApprover.addAll(oSet_Approver);
            setApprover(oHeader, ltFinalApprover);
        }
        
    }
    /*
    private static void setApprovers4Payment(ASI_MFM_Payment__c oHeader, Map<Id, ASI_MFM_Payment__c> oMap_Header, Map<Id, ASI_MFM_Dynamic_Approval_Route__c> oDynRoute
	, Map<ID, User> oMap_Owner, Map<String,Map<String, Decimal>> oPayRoute_Sales, Map<String, Decimal> oPayRoute_MKT
	, Map<String, Decimal> oPayRoute_HR, Map<String, Decimal> oPayRoute_FIN
	, Map<String,String> oFieldMap_Dept, Map<String,String> oFieldMap_Channel, Map<String,String> oFieldMap_AccType) {

        setApproverToNull(oHeader);
		Set<String> oSet_Approver = new Set<String>();

        Decimal dCheckAmount = oHeader.ASI_MFM_Payment_Amount__c;
		dCheckAmount = dCheckAmount.setScale(2, RoundingMode.HALF_UP);

        String sOwnerDept = '';
        if(oMap_Owner.get(oHeader.OwnerId).ASI_MFM_Department__c != NULL && oFieldMap_Dept.get(oMap_Owner.get(oHeader.OwnerId).ASI_MFM_Department__c) != NULL)
			sOwnerDept = oFieldMap_Dept.get(oMap_Owner.get(oHeader.OwnerId).ASI_MFM_Department__c);
        String sOwnerChannel = '';
        if(oMap_Owner.get(oHeader.OwnerId).ASI_MFM_Department__c != NULL && oFieldMap_Channel.get(oMap_Owner.get(oHeader.OwnerId).ASI_MFM_Department__c) != NULL)
			sOwnerChannel = oFieldMap_Channel.get(oMap_Owner.get(oHeader.OwnerId).ASI_MFM_Department__c);

        boolean bHas_FINRoute = FALSE;
        switch on sOwnerDept {
            when 'HR' {
                Set<String> oSet_Approver_HR = setApprovers_CheckLimit(dCheckAmount, oPayRoute_HR);
        		if (oSet_Approver_HR.size()>0) oSet_Approver.addAll(oSet_Approver_HR);
                bHas_FINRoute = TRUE;
            }
            when 'FIN' {
                bHas_FINRoute = TRUE;
            }
            when 'MKT' {
                Set<String> oSet_Approver_Dynamic = setDynamicApprovers(oHeader.OwnerId, oDynRoute, oMap_Owner, dCheckAmount);
                if (oSet_Approver_Dynamic.size()>0) oSet_Approver.addAll(oSet_Approver_Dynamic);
                
                Set<String> oSet_Approver_MKT = setApprovers_CheckLimit(dCheckAmount, oPayRoute_MKT);
        		if (oSet_Approver_MKT.size()>0) oSet_Approver.addAll(oSet_Approver_MKT);
				bHas_FINRoute = TRUE;
			}
            when 'Sales' {
                //1) check trade
                //2) if trade, fix route (check channel)
                //3) if non-trade, dynamic route
                //4) SD
                //5) M Type / MKT Type
                
                boolean bCheck_Trade_Type = FALSE;
                boolean bCheck_MKT_Type = FALSE;

                if (oHeader.Id != NULL && oMap_Header.get(oHeader.Id) != NULL) {
					for (ASI_MFM_Payment_Line_Item__c oItem: oMap_Header.get(oHeader.Id).Payment_Line_Items__r) {
                        if (oItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.ASI_MFM_Reporting_Category__c != NULL) {
                            if (oFieldMap_AccType.containsKey(oItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.ASI_MFM_Reporting_Category__c)) {
                                if (oFieldMap_AccType.get(oItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.ASI_MFM_Reporting_Category__c) == 'Trade A&P') bCheck_Trade_Type = true;
                                if (oFieldMap_AccType.get(oItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.ASI_MFM_Reporting_Category__c) == 'MKT A&P') bCheck_MKT_Type = true;
                            }
                        }
                    }
                }

                if (bCheck_Trade_Type) {
                    if ((sOwnerChannel != '') && (sOwnerChannel != NULL) && (oPayRoute_Sales.containsKey(sOwnerChannel))) {
                        Map<String, Decimal> oPayRoute_Sales_Channel = oPayRoute_Sales.get(sOwnerChannel);
                        
                        Set<String> oSet_Approver_Sales = setApprovers_CheckLimit(dCheckAmount, oPayRoute_Sales_Channel);
                        if (oSet_Approver_Sales.size()>0) oSet_Approver.addAll(oSet_Approver_Sales);
                    }
                }
                else {
                    Set<String> oSet_Approver_Dynamic = setDynamicApprovers(oHeader.OwnerId, oDynRoute, oMap_Owner, dCheckAmount);
                	if (oSet_Approver_Dynamic.size()>0) oSet_Approver.addAll(oSet_Approver_Dynamic);
                }
                
                //SD
                string sSalesDirectorValue = 'SD';
                if ((sSalesDirectorValue != '') && (sSalesDirectorValue != NULL) && (oPayRoute_Sales.containsKey(sSalesDirectorValue))) {
                    Map<String, Decimal> oPayRoute_Sales_SD = oPayRoute_Sales.get(sSalesDirectorValue);
                    Set<String> oSet_Approver_SD = setApprovers_CheckLimit(dCheckAmount, oPayRoute_Sales_SD);
					if (oSet_Approver_SD.size()>0) oSet_Approver.addAll(oSet_Approver_SD);
                }

                //M Type / MKT Type             
                if ((bCheck_MKT_Type) && (dCheckAmount >= 1000000)) {
                    if (oPayRoute_MKT.size() > 0) {
                        for (string sApproverId : oPayRoute_MKT.keySet()) {
                            oSet_Approver.add(sApproverId);
                        }
                    }
                }
                
                bHas_FINRoute = TRUE;
            }
        }
        
        //FINANCE [fix]
		if (bHas_FINRoute) {
            Set<String> oSet_Approver_FIN = setApprovers_CheckLimit(dCheckAmount, oPayRoute_FIN);
            if (oSet_Approver_FIN.size()>0) oSet_Approver.addAll(oSet_Approver_FIN);
		}

        //assign approvers
        if (oSet_Approver.size()>0) {
            List<String> ltFinalApprover = new List<String>();
            ltFinalApprover.addAll(oSet_Approver);
            setApprover(oHeader, ltFinalApprover);
        }
	}
    */
    @TestVisible
    private static Set<String> setApprovers_CheckLimit(Decimal dCheckAmount, Map<String, Decimal> oRouteWLimit) {
		Set<String> oSet_Approver = new Set<String>();
        
        if (oRouteWLimit.size() > 0) {
            for (String sApproverID : oRouteWLimit.keySet()){
                Decimal dTmpLimit = oRouteWLimit.get(sApproverID);
                if (dCheckAmount>=dTmpLimit) oSet_Approver.add(sApproverID);
            }
        }
        
        return oSet_Approver;
    }
    
    @TestVisible
    private static Set<String> setDynamicApprovers(Id oOwnerId, Map<Id, ASI_MFM_Dynamic_Approval_Route__c> oDynRoute, Map<ID, User> oMap_Owner, Decimal dCheckAmount) {
        Set<String> oSet_Approver = new Set<String>();

        Id oCurApprover = oMap_Owner.get(oOwnerId).ASI_Line_Manager__c;
        if (oMap_Owner.get(oOwnerId).ASI_MFM_Direct_Report__c) {
            oSet_Approver.add(oCurApprover);
        }
        else {
            Boolean bEndRoute = FALSE;
            while (!bEndRoute)
            {
                if (oDynRoute.get(oCurApprover) != NULL)
                {
                    if (!oDynRoute.get(oCurApprover).ASI_MFM_Skip_to_Next_Level__c) {
                        if(oDynRoute.get(oCurApprover).ASI_MFM_Approval_Limit__c != NULL) {
                            Decimal dTmpLimit = oDynRoute.get(oCurApprover).ASI_MFM_Approval_Limit__c;
							dTmpLimit = dTmpLimit.setScale(2, RoundingMode.HALF_UP);
                            
                            if(dCheckAmount >= dTmpLimit) oSet_Approver.add(oCurApprover);
                        }
                        else {
                            oSet_Approver.add(oCurApprover);
                        }
					}

                    bEndRoute = oDynRoute.get(oCurApprover).ASI_MFM_End_of_1st_Route__c;
                    oCurApprover = oDynRoute.get(oCurApprover).ASI_MFM_Manager_ID__c;
                }
                else bEndRoute = TRUE;
            }
        }
        
        return oSet_Approver;
    }
    
    @TestVisible
    private static Map<String, Decimal> getFixApproversWLimit(ASI_MFM_Fix_Approval_Route__c oRoute) {
        Map<String, Decimal> oApprovers = new Map<String, Decimal>();
        
        Integer i = 1;
        String sApproverField = 'ASI_MFM_Corporate_Approver_' + i + '__c';
        String sLimitField = 'ASI_MFM_Approval_Limit_CA' + i + '__c';

        While(MFM_Fix_Approval_Route_FIELD_MAP.containsKey(sApproverField))
        {
            Id idTmpApprover = NULL;
            Decimal dTmpLimit = 0;
            if (oRoute.get(sApproverField) != NULL) idTmpApprover = String.valueof(oRoute.get(sApproverField));
            if (oRoute.get(sLimitField) != NULL) dTmpLimit = Decimal.valueof(String.valueof(oRoute.get(sLimitField)));
            
            dTmpLimit = dTmpLimit.setScale(2, RoundingMode.HALF_UP);
            if (idTmpApprover != NULL) oApprovers.put(idTmpApprover, dTmpLimit);

            i++;
            sApproverField = 'ASI_MFM_Corporate_Approver_' + i + '__c';
            sLimitField = 'ASI_MFM_Approval_Limit_CA' + i + '__c';
        }
        
        return oApprovers;
    }
    
    //copy from "ASI_MFM_Payment_TriggerClass" start
    public static void setApproverToNull(ASI_MFM_Payment__c p){   
        p.ASI_MFM_Sys_Approver_1__c = null;
        p.ASI_MFM_Sys_Approver_2__c = null;
        p.ASI_MFM_Sys_Approver_3__c = null;
        p.ASI_MFM_Sys_Approver_4__c = null;
        p.ASI_MFM_Sys_Approver_5__c = null;
        p.ASI_MFM_Sys_Approver_6__c = null;
        p.ASI_MFM_Sys_Approver_7__c = null;
        p.ASI_MFM_Sys_Approver_8__c = null;
        p.ASI_MFM_Sys_Approver_9__c = null;
        p.ASI_MFM_Sys_Approver_10__c = null;
        p.ASI_MFM_CN_Finance__c = null;    
        p.ASI_MFM_CN_Return_Approver_1__c = null;
        p.ASI_MFM_CN_Return_Approver_2__c = null;
        p.ASI_MFM_CN_Return_Approver_3__c = null; 
    }
    
    public static void setApprover(ASI_MFM_Payment__c pm, List<String> approverIdList){
        Integer i = 1;
        String currentApprover = 'ASI_MFM_Sys_Approver_' + i + '__c';
        Set<String> approverIdSet = new Set<String>();
        for(String s : approverIdList)
        {
            approverIdSet.add(s);
        }
        approverIdList = new List<String>();
        for(String s : approverIdSet)
        {
            approverIdList.add(s);
        }
        While(Payment_FIELD_MAP.containsKey(currentApprover) && i <= approverIdList.size() && i <= 10){
            pm.put(currentApprover, approverIdList[i - 1]);
            i++;
            currentApprover = 'ASI_MFM_Sys_Approver_' + i + '__c';
        }
    }
    //copy from "ASI_MFM_Payment_TriggerClass" end
    
}