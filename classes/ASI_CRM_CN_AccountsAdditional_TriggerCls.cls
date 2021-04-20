/* Filename:    ASI_CRM_CN_AccountsAdditional_TriggerCls.cls
* Author:      Michael Yip (Introv Limited)
* Purpose:     Handle CN Customer Trigger Logic
*
*
* History
* -----------------------------------------------------------------------------
* 2014-06-06   michael.yip@introv.com      Create
* 2014-07-31   michael.yip@introv.com      Update account field when customer record update
* 2014-10-08   twinkle.li@introv.com       Check for duplication of Customers(Chinese Name, English Name, Legal Name)
* 2015-01-05   twinkle.li@introv.com       Apex sharing 
*/
public with sharing class ASI_CRM_CN_AccountsAdditional_TriggerCls {
    public static String className = 'ASI_CRM_CN_AccountsAdditional_TriggerCls';
    //20160418 Ben @ Elufa
    Private Static List<ASI_CRM_KA_Account__c> kaAccList = new List<ASI_CRM_KA_Account__c>([SELECT Id
                                                                                            , Name
                                                                                            , ASI_CRM_Chi_Name__c
                                                                                            , ASI_CRM_Sequence__c
                                                                                            , ASI_CRM_National_Group__c
                                                                                            , ASI_CRM_Apply_National_Approval__c
                                                                                            FROM ASI_CRM_KA_Account__c
                                                                                            WHERE recordType.DeveloperName = 'ASI_CRM_CN_KA_Account'
                                                                                            AND ASI_CRM_Inactive__c = FALSE
                                                                                           ]);
    //20160418 End
    Private Static Id prospectRTID = null;//Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_Prospect');//20161007 Ben @ Elufa, 20170426 Commented for CD Phase 1 Deployment.
    Private Static String outletRTID = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');//20161007 Ben @ Elufa
    Private Static List<ASI_CRM_Sales_Team__c> salesTeamList = new List<ASI_CRM_Sales_Team__c>([SELECT id, Name, ASI_CRM_Commercial_Team__c FROM ASI_CRM_Sales_Team__c WHERE RecordType.developerName Like 'ASI_CRM_CN_Sales_Team']);//20170130 Elufa
    //Private Static Map<id, ASI_CRM_Customer_Group__c> mapNationalGroup = new Map<Id, ASI_CRM_Customer_Group__c>([SELECT id, Name, ASI_CRM_Greater_Region_Code__c, ASI_CRM_Commercial_Team__c FROM ASI_CRM_Customer_Group__c WHERE RecordType.developerName Like 'ASI_CRM_CN_National_Group']);//20170202 Elufa
    
    public static void routineBeforeUpdate(list<ASI_CRM_AccountsAdditionalField__c > trigger_new, map<id, ASI_CRM_AccountsAdditionalField__c > trigger_oldMap) {    
        
        //Added by Twinkle 8th Oct 2014 Check for duplication of Customers(Chinese Name, English Name, Legal Name)
        if(!ASI_CRM_CN_Function.IsBypassTrigger(className)) {
            List<String> LNewCustChiName = new List<String>();
            List<String> LNewCustEngName = new List<String>();
            List<String> LNewCustLegalname = new List<String>();
            List<String> LNewCustCity = new List<String>();
            List<String> LNewCustRecordType = new List<String>();
            Map<String, ASI_CRM_AccountsAdditionalField__c> MdulChiName = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
            Map<String, ASI_CRM_AccountsAdditionalField__c> MdulEngName = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
            Map<String, ASI_CRM_AccountsAdditionalField__c> MdulLegalName = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
            Map<String, ASI_CRM_Sales_Team__c> mapCommercialTeam = new Map<String, ASI_CRM_Sales_Team__c>();//20170130 Elufa
            Set<Id> parentSet = new Set<id>();//20170205 Elufa
            Map<Id, ASI_CRM_AccountsAdditionalField__c> mapParentNationalGroup = new Map<Id, ASI_CRM_AccountsAdditionalField__c>();//20170205 Elufa
            //Map<String, ASI_CRM_Customer_Group__c> mapNationalGroupName = new Map<String, ASI_CRM_Customer_Group__c>();//20170327 Elufa
            Map<Id, ASI_CRM_AccountsAdditionalField__c> attachmentCheckMap = new Map<Id, ASI_CRM_AccountsAdditionalField__c>();
            Set<Id> attachmentCheckIds = new Set<Id>();
            //20170130 Elufa
            for(ASI_CRM_Sales_Team__c st : salesTeamList){
                
                mapCommercialTeam.put(st.name.toLowerCase(), st);
            }
            //20170130 End
            
            //20160418 Ben @ Elufa
            Map<Id, ASI_CRM_KA_Account__c> mapKAAcc = new Map<Id, ASI_CRM_KA_Account__c>();
            for(ASI_CRM_KA_Account__c obj : kaAccList){
                mapKAAcc.put(obj.id, obj);
            }
            //20160418 End
            
            for(ASI_CRM_AccountsAdditionalField__c cust : trigger_new){
                
                if(cust.ASI_CRM_CN_Parent_Outlet__c != Null)
                    parentSet.add(cust.ASI_CRM_CN_Parent_Outlet__c);
                ASI_CRM_AccountsAdditionalField__c oldCust = trigger_oldMap.get(cust.id);
                // 营业执照附件校验
                if ( (cust.ASI_CRM_CN_BusinessLicenseUploading__c != oldCust.ASI_CRM_CN_BusinessLicenseUploading__c 
                    && cust.ASI_CRM_CN_BusinessLicenseUploading__c ) ||
                    (cust.ASI_CRM_CN_Busi_License_ExpireDate_Perm__c != oldCust.ASI_CRM_CN_Busi_License_ExpireDate_Perm__c 
                    && cust.ASI_CRM_CN_Busi_License_ExpireDate_Perm__c ) ||
                    (cust.ASI_CRM_CN_Business_License_Start_Date__c != oldCust.ASI_CRM_CN_Business_License_Start_Date__c 
                    && cust.ASI_CRM_CN_Business_License_Start_Date__c != null) ||
                    (cust.ASI_CRM_CN_Business_License_Expire_date__c != oldCust.ASI_CRM_CN_Business_License_Expire_date__c 
                    && cust.ASI_CRM_CN_Business_License_Expire_date__c != null )
                    ) {
                    attachmentCheckIds.add(cust.Id);
                }

            }
            
            //20170205 Elufa
            if(parentSet.size() > 0){
                mapParentNationalGroup = ASI_CRM_CN_AccountsAdditional_HelperCls.getParentOutlet(parentSet);//new Map<Id, ASI_CRM_AccountsAdditionalField__c>([SELECT id, ASI_CRM_National_Group__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id IN : parentSet]);
            }
            // 营业执照附件校验
            if (!attachmentCheckIds.isEmpty()) {
                attachmentCheckMap = new Map<Id, ASI_CRM_AccountsAdditionalField__c>([
                                                SELECT  Id, (SELECT Id 
                                                             FROM Attachments 
                                                             // WHERE Name LIKE '%营业执照%'
                                                             )
                                                FROM ASI_CRM_AccountsAdditionalField__c
                                                WHERE Id IN:attachmentCheckIds]);
            }
            //for(ASI_CRM_Customer_Group__c obj : mapNationalGroup.values()){
                
            //    mapNationalGroupName.put(obj.Name, obj);
            //}
            
            for(ASI_CRM_AccountsAdditionalField__c cust : trigger_new){
                
                //20170327 Elufa
                /*if(cust.ASI_CRM_CN_Parent_Outlet__c != Null && mapParentNationalGroup.containsKey(cust.ASI_CRM_CN_Parent_Outlet__c)){
                    
                    cust.ASI_CRM_National_Group__c = mapParentNationalGroup.get(cust.ASI_CRM_CN_Parent_Outlet__c).ASI_CRM_National_Group__c;
                    cust.ASI_CRM_National_Group_Picklist__c = mapParentNationalGroup.get(cust.ASI_CRM_CN_Parent_Outlet__c).ASI_CRM_National_Group__r.Name;
                    
                }else if(cust.ASI_CRM_National_Group_Picklist__c != '' && cust.ASI_CRM_National_Group_Picklist__c != Null && mapNationalGroupName.containsKey(cust.ASI_CRM_National_Group_Picklist__c)){
                    
                    cust.ASI_CRM_National_Group__c = mapNationalGroupName.get(cust.ASI_CRM_National_Group_Picklist__c).id;
                    
                }else if(cust.ASI_CRM_National_Group_Picklist__c == Null || cust.ASI_CRM_National_Group_Picklist__c == ''){
                    
                    cust.ASI_CRM_National_Group__c = Null;
                }*/
                //20170327 End
                
                //20170130 Elufa, 20170519 commented
                /*String ownerSalesTeam = ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUser(cust.ownerId) != Null && ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUser(cust.ownerId).ASI_CRM_Sales_Team__c != Null && ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUser(cust.ownerId).ASI_CRM_Sales_Team__c != '' ? ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUser(cust.ownerId).ASI_CRM_Sales_Team__c.toLowerCase() : '';
                if(mapCommercialTeam.containsKey(ownerSalesTeam) && mapCommercialTeam.get(ownerSalesTeam).ASI_CRM_Commercial_Team__c != Null && mapCommercialTeam.get(ownerSalesTeam).ASI_CRM_Commercial_Team__c != ''){
                    cust.ASI_CRM_CN_Commercial_Team__c = mapCommercialTeam.get(ownerSalesTeam).ASI_CRM_Commercial_Team__c;
                }*/
                //20170130 End
                
                //20170128 Elufa Commented, replace with ASI_CRM_CN_AccountsAdditional_HelperCls.validationCustomerName(trigger_new);
                /*if(cust.ASI_CRM_CN_Chi_Name__c != null && cust.ASI_CRM_CN_Chi_Name__c != '' && cust.ASI_CRM_CN_Chi_Name__c != trigger_oldMap.get(cust.id).ASI_CRM_CN_Chi_Name__c)
                    LNewCustChiName.add(cust.ASI_CRM_CN_Chi_Name__c);
                if(cust.ASI_CRM_CN_Eng_Name__c != null && cust.ASI_CRM_CN_Eng_Name__c != '' && cust.ASI_CRM_CN_Eng_Name__c != trigger_oldMap.get(cust.id).ASI_CRM_CN_Eng_Name__c)
                    LNewCustEngName.add(cust.ASI_CRM_CN_Eng_Name__c);
                if(cust.ASI_CRM_CN_Legal_Name__c != null && cust.ASI_CRM_CN_Legal_Name__c != '' && cust.ASI_CRM_CN_Legal_Name__c != trigger_oldMap.get(cust.id).ASI_CRM_CN_Legal_Name__c)
                    LNewCustLegalname.add(cust.ASI_CRM_CN_Legal_Name__c);*/
                
                //20160720 Ben @ Elufa
                
                //20161006 Ben @ Elufa added cust.RecordtypeId != prospectRTID
                /*if(cust.RecordtypeId != prospectRTID && trigger_oldMap.get(cust.id).ASI_CRM_CN_Commercial_Team__c != NULL && trigger_oldMap.get(cust.id).ASI_CRM_CN_Commercial_Team__c != cust.ASI_CRM_CN_Commercial_Team__c){
                    
                    cust.ASI_CRM_CN_Commercial_Team__c.addError('Not Allowed to Change Commercial Team.');
                    break;
                }*///20170130 Elufa Commented replaced with Auto set commercial team logic
                
                //20160720 End
                
                //20161027 Elufa
                if(cust.RecordtypeId != prospectRTID && trigger_oldMap.get(cust.id).ASI_CRM_CN_NewChannel__c != NULL && trigger_oldMap.get(cust.id).ASI_CRM_CN_NewChannel__c != cust.ASI_CRM_CN_NewChannel__c){
                    
                    cust.ASI_CRM_CN_NewChannel__c.addError('Not Allowed to Change New Channel.');
                    break;
                }
                //20161027 End
                // 营业执照校验
                if (
                    attachmentCheckMap.containsKey(cust.Id) 
                    && (String.isBlank(cust.ASI_CRM_CN_Legal_Name__c) 
                            || attachmentCheckMap.get(cust.Id).Attachments.isEmpty())
                    && !Test.isRunningTest()) {
                    cust.addError(Label.ASI_CRM_CN_TP_CHECK_ASI_CRM_CN_BusinessLicenseUploading);
                }
                //20170202 Elufa
                
                /*if((cust.ASI_CRM_CN_Greater_Region_Code__c != Null && cust.ASI_CRM_CN_Greater_Region_Code__c != '' && cust.ASI_CRM_National_Group__c != Null && mapNationalGroup.containsKey(cust.ASI_CRM_National_Group__c))
                   && (
                       (
                           (cust.ASI_CRM_CN_Commercial_Team__c == 'Prestige' && !mapNationalGroup.get(cust.ASI_CRM_National_Group__c).ASI_CRM_Greater_Region_Code__c.contains(cust.ASI_CRM_CN_Greater_Region_Code__c))
                       )
                       || 
                       (
                           (cust.ASI_CRM_CN_Commercial_Team__c == 'Premium' && mapNationalGroup.get(cust.ASI_CRM_National_Group__c).ASI_CRM_Commercial_Team__c != 'Premium'
                            ||
                            mapNationalGroup.get(cust.ASI_CRM_National_Group__c).ASI_CRM_Commercial_Team__c == 'Premium' && cust.ASI_CRM_CN_Commercial_Team__c != 'Premium')
                       )
                       || 
                       (
                           (mapNationalGroup.get(cust.ASI_CRM_National_Group__c).ASI_CRM_Commercial_Team__c == 'HQ/Hotel' && cust.ASI_CRM_CN_Commercial_Team__c != 'HQ/Hotel')
                           || (mapNationalGroup.get(cust.ASI_CRM_National_Group__c).ASI_CRM_Commercial_Team__c != 'HQ/Hotel' && cust.ASI_CRM_CN_Commercial_Team__c == 'HQ/Hotel')
                       )
                   )
                  ){
                      cust.ASI_CRM_National_Group_Picklist__c.addError('This National Group(' + mapNationalGroup.get(cust.ASI_CRM_National_Group__c).Name + ') is invalid for ' + cust.Name);
                      break;
                  }*/
                
                //20170202 End
                
                //20160418 Ben @ Elufa
                
                //cust.ASI_CRM_KA_Event__c = NULL;
                cust.ASI_CRM_KA_Account_Sequence__c = NULL;
                cust.ASI_CRM_KA_Account_CN_Name__c = NULL;
                
                if(cust.ASI_CRM_CN_KA_Account_Chain__c != NULL && mapKAAcc.containsKey(cust.ASI_CRM_CN_KA_Account_Chain__c)){
                    
                    //cust.ASI_CRM_KA_Event__c = mapKAEvent.get(cust.ASI_CRM_CN_KA_Account__c).id;
                    cust.ASI_CRM_KA_Account_Sequence__c = mapKAAcc.get(cust.ASI_CRM_CN_KA_Account_Chain__c).ASI_CRM_Sequence__c;
                    cust.ASI_CRM_KA_Account_CN_Name__c = mapKAAcc.get(cust.ASI_CRM_CN_KA_Account_Chain__c).ASI_CRM_Chi_Name__c;
                }
                //20160418 End
                
                LNewCustCity.add(cust.ASI_CRM_CN_CCity__c);
                LNewCustRecordType.add(cust.RecordTypeid);
            }
            
            //20170128 Elufa Commented, replace with ASI_CRM_CN_AccountsAdditional_HelperCls.validationCustomerName(trigger_new);
            /*if((LNewCustChiName != null && LNewCustChiName.size() >0) || (LNewCustEngName != null && LNewCustEngName.size() >0) || (LNewCustLegalname != null && LNewCustLegalname.size() >0)){
                List<ASI_CRM_AccountsAdditionalField__c> LDupCustName = [SELECT id, ASI_CRM_CN_CCity__c, ASI_CRM_CN_Chi_Name__c,ASI_CRM_CN_Eng_Name__c, ASI_CRM_CN_Legal_Name__c FROM ASI_CRM_AccountsAdditionalField__c WHERE (ASI_CRM_CN_Chi_Name__c IN: LNewCustChiName OR ASI_CRM_CN_Eng_Name__c IN: LNewCustEngName OR ASI_CRM_CN_Legal_Name__c IN: LNewCustLegalname) AND ASI_CRM_CN_CCity__c IN: LNewCustCity AND RecordTypeid IN: LNewCustRecordType ];
//                  List<ASI_CRM_AccountsAdditionalField__c> LDupCustName = [SELECT id, ASI_CRM_CN_CCity__c, ASI_CRM_CN_Chi_Name__c,ASI_CRM_CN_Eng_Name__c, ASI_CRM_CN_Legal_Name__c FROM ASI_CRM_AccountsAdditionalField__c WHERE (ASI_CRM_CN_Chi_Name__c IN: LNewCustChiName OR ASI_CRM_CN_Eng_Name__c IN: LNewCustEngName OR ASI_CRM_CN_Legal_Name__c IN: LNewCustLegalname)];
//                  List<ASI_CRM_AccountsAdditionalField__c> LDupCustName = [SELECT id, ASI_CRM_CN_CCity__c, ASI_CRM_CN_Chi_Name__c,ASI_CRM_CN_Eng_Name__c, ASI_CRM_CN_Legal_Name__c FROM ASI_CRM_AccountsAdditionalField__c WHERE (ASI_CRM_CN_Chi_Name__c IN: LNewCustChiName OR ASI_CRM_CN_Eng_Name__c IN: LNewCustEngName OR ASI_CRM_CN_Legal_Name__c IN: LNewCustLegalname) AND ASI_CRM_CN_CCity__c IN: LNewCustCity];
//                  List<ASI_CRM_AccountsAdditionalField__c> LDupCustName = [SELECT id, ASI_CRM_CN_CCity__c, ASI_CRM_CN_Chi_Name__c,ASI_CRM_CN_Eng_Name__c, ASI_CRM_CN_Legal_Name__c FROM ASI_CRM_AccountsAdditionalField__c WHERE (ASI_CRM_CN_Chi_Name__c IN: LNewCustChiName OR ASI_CRM_CN_Eng_Name__c IN: LNewCustEngName OR ASI_CRM_CN_Legal_Name__c IN: LNewCustLegalname) AND (RecordTypeid =: Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS') OR RecordTypeid=: Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'))];
                                                                               
                for(ASI_CRM_AccountsAdditionalField__c d : LDupCustName){
                    if(!MdulChiName.containsKey(d.ASI_CRM_CN_Chi_Name__c))
                        MdulChiName.put(d.ASI_CRM_CN_Chi_Name__c, d);
                    if(!MdulEngName.containsKey(d.ASI_CRM_CN_Eng_Name__c))
                        MdulEngName.put(d.ASI_CRM_CN_Eng_Name__c, d);
                    if(!MdulLegalName.containsKey(d.ASI_CRM_CN_Legal_Name__c))
                        MdulLegalName.put(d.ASI_CRM_CN_Legal_Name__c, d);
                }
                
                for(ASI_CRM_AccountsAdditionalField__c cust : trigger_new){
                    if(cust.RecordtypeId != prospectRTID){//20161026 Ben @ Elufa added if(a.RecordtypeId != prospectRTID){}
                        if(cust.ASI_CRM_CN_Chi_Name__c != NULL && MdulChiName.get(cust.ASI_CRM_CN_Chi_Name__c) != null && MdulChiName.get(cust.ASI_CRM_CN_Chi_Name__c).id != cust.id && cust.ASI_CRM_CN_CCity__c == MdulChiName.get(cust.ASI_CRM_CN_Chi_Name__c).ASI_CRM_CN_CCity__c){
                            cust.addError(Label.ASI_CRM_CN_CustomerChiNameDuplicateErrMsg);
                            break;
                        }
                        else if(cust.ASI_CRM_CN_Eng_Name__c != NULL && MdulEngName.get(cust.ASI_CRM_CN_Eng_Name__c) != null && MdulEngName.get(cust.ASI_CRM_CN_Eng_Name__c).id != cust.id && cust.ASI_CRM_CN_CCity__c == MdulEngName.get(cust.ASI_CRM_CN_Eng_Name__c).ASI_CRM_CN_CCity__c){
                            cust.addError(Label.ASI_CRM_CN_CustomerEngNameDuplicateErrMsg);
                            break;
                        }
                        /*else if(cust.ASI_CRM_CN_Legal_Name__c != NULL && MdulLegalName.get(cust.ASI_CRM_CN_Legal_Name__c) != null && MdulLegalName.get(cust.ASI_CRM_CN_Legal_Name__c).id != cust.id && cust.ASI_CRM_CN_CCity__c == MdulLegalName.get(cust.ASI_CRM_CN_Legal_Name__c).ASI_CRM_CN_CCity__c){
                            cust.addError(Label.ASI_CRM_CN_CustomerLegalNameDuplicateErrMsg);
                            break;
                        }*/
            //        }
            //    }
            //}
            ASI_CRM_CN_AccountsAdditional_HelperCls.validationCustomerName(trigger_new, trigger_oldMap);//20170128 Elufa
            prosSegmentationMapping(trigger_new, trigger_oldMap); //20160613, Leo@Elufa
        }
         //End - Twinkle 8th Oct 2014  
            
        // Added by Michael Yip (Introv) 06Jun2014 Validation on inactive outlet, need to terminate all active contract before inactive an outlet (Status = Final or submitted)
        List<ASI_CRM_CN_Brand_T1_Group__c > Brand_T1_Group_list= [Select id ,Name from ASI_CRM_CN_Brand_T1_Group__c ];
        Map<String,ASI_CRM_CN_Brand_T1_Group__c > Brand_T1_Group_map= new Map<String,ASI_CRM_CN_Brand_T1_Group__c >();
        for(ASI_CRM_CN_Brand_T1_Group__c  a:Brand_T1_Group_list){
            Brand_T1_Group_map.put(a.Name,a);
        }
        
        Set<id> SCustomerIDInactive = new Set<id>();
        for(ASI_CRM_AccountsAdditionalField__c a : trigger_new){
            if(a.recordtypeid != null && Global_RecordTypeCache.getRt(a.recordTypeId).developerName.contains('ASI_CRM_Outlet_CN')){
                if(a.ASI_CRM_CN_Inactive_Flag__c && !trigger_oldMap.get(a.id).ASI_CRM_CN_Inactive_Flag__c){
                    SCustomerIDInactive.add(a.id);
                }
            }
        }
        Set<id> SCustomerWithActiveContractID = new Set<id>();
        for(ASI_TH_CRM_Contract__c c : [select id, name, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_Outlet_WS__r.name, ASI_TH_CRM_Contract_Status__c, 
                                        ASI_CRM_CN_Status__c  
                                        from ASI_TH_CRM_Contract__c 
                                        where ASI_CRM_CN_PO_Start_Date__c <= today and ASI_CRM_CN_PO_End_Date__c >= today and 
                                        (ASI_CRM_CN_Status__c = 'Final' or ASI_CRM_CN_Status__c  = 'Submitted') and ASI_CRM_CN_Outlet_WS__c IN :SCustomerIDInactive]){
                                            System.debug(c);
                                            SCustomerWithActiveContractID.add(c.ASI_CRM_CN_Outlet_WS__c);
                                        }
        
        for(ASI_CRM_AccountsAdditionalField__c a : trigger_new){
            if(SCustomerWithActiveContractID.contains(a.id)){
                a.addError('Please terminate all active contract before inactive an outlet!');
            }
            //set brand name look up Lokman 18/6/2014
            if(a.recordtypeid != null && Global_RecordTypeCache.getRt(a.recordTypeId).developerName.contains('ASI_CRM_CN_WS')){
                if(a.ASI_CRM_CN_Brand__c!=null && a.ASI_CRM_CN_Brand__c!=''){
                    if(Brand_T1_Group_map.containsKey(a.ASI_CRM_CN_Brand__c)){
                        a.ASI_CRM_CN_Brand_Lookup__c=Brand_T1_Group_map.get(a.ASI_CRM_CN_Brand__c).id;
                    }                    
                }
            }       
        }
        
        // Added by Alan Wong (Elufa) 20150727
        Set<id> CustomerWithT1WS = new Set<id>();
        Set<id> CustomerWithT1WS2 = new Set<id>();
        
        for(ASI_CRM_AccountsAdditionalField__c a : trigger_new){
            if (a.ASI_CRM_T1_WS_Account__c != null && ((a.ASI_CRM_T1_WS_Account__c != trigger_oldMap.get(a.id).ASI_CRM_T1_WS_Account__c ) || ( a.ASI_CRM_CN_T1_WS1__c == NULL && trigger_oldMap.get(a.id).ASI_CRM_CN_T1_WS1__c == NULL ))){
                CustomerWithT1WS.add(a.ASI_CRM_T1_WS_Account__c);
            }
            //20160125 Ben @ Elufa
            if( a.ASI_CRM_CN_T1_WS1__c != null && ((a.ASI_CRM_CN_T1_WS1__c != trigger_oldMap.get(a.id).ASI_CRM_CN_T1_WS1__c) || (a.ASI_CRM_T1_WS_Account__c == NULL && trigger_oldMap.get(a.id).ASI_CRM_T1_WS_Account__c == NULL))){
                CustomerWithT1WS2.add(a.ASI_CRM_CN_T1_WS1__c);
            }
            
        }
        
        Map<id,id> WSMap = new Map<id,id>();
        if(CustomerWithT1WS.size()>0) {
        	WSMap = ASI_CRM_CN_AccountsAdditional_HelperCls.GetT1WSID(CustomerWithT1WS);
        }
        for(ASI_CRM_AccountsAdditionalField__c a : trigger_new){
            
            if(a.RecordtypeId != prospectRTID){//20161007 Ben @ Elufa added if(a.RecordtypeId != prospectRTID){
                
                if(WSMap.containsKey(a.ASI_CRM_T1_WS_Account__c) && CustomerWithT1WS.contains(a.ASI_CRM_T1_WS_Account__c)) {
                    
                    a.ASI_CRM_CN_T1_WS1__c = WSMap.get(a.ASI_CRM_T1_WS_Account__c);
                }else if(!WSMap.containsKey(a.ASI_CRM_T1_WS_Account__c) && a.ASI_CRM_T1_WS_Account__c != null && CustomerWithT1WS.contains(a.ASI_CRM_T1_WS_Account__c) ){
                    a.ASI_CRM_CN_T1_WS1__c = null;
                    
                    //20151221 Ben @ Elufa System
                    if(USerInfo.getLanguage()=='zh_CN')
                        a.ASI_CRM_CN_T1_WS1__c.addError('请选择一批');
                    else
                        a.ASI_CRM_CN_T1_WS1__c.addError('Please select a T1 wholesaler for T1 WS (Account)');
                    break;
                    //20151221 End
                }
                
                if((a.ASI_CRM_T1_WS_Account__c == null && trigger_oldMap.get(a.id).ASI_CRM_T1_WS_Account__c != null)){
                    a.ASI_CRM_CN_T1_WS1__c = null;
                }
            }
        }
        
        Map<id, ASI_CRM_AccountsAdditionalField__c> WSMap2 = new Map<id, ASI_CRM_AccountsAdditionalField__c>();
        WSMap2 = ASI_CRM_CN_AccountsAdditional_HelperCls.getCustomerMap(CustomerWithT1WS2);
        
        for(ASI_CRM_AccountsAdditionalField__c a : trigger_new){
            
            if(a.RecordtypeId != prospectRTID){//20161007 Ben @ Elufa added if(a.RecordtypeId != prospectRTID){
                
                if(CustomerWithT1WS2.contains(a.ASI_CRM_CN_T1_WS1__c) && WSMap2.containsKey(a.ASI_CRM_CN_T1_WS1__c)){
                    
                    a.ASI_CRM_T1_WS_Account__c = WSMap2.get(a.ASI_CRM_CN_T1_WS1__c).ASI_CRM_Account__c;
                    
                }else if(!WSMap2.containsKey(a.ASI_CRM_CN_T1_WS1__c) && a.ASI_CRM_CN_T1_WS1__c != null && CustomerWithT1WS2.contains(a.ASI_CRM_CN_T1_WS1__c) ){
                    a.ASI_CRM_T1_WS_Account__c = null;
                    
                    //20151221 Ben @ Elufa System
                    if(USerInfo.getLanguage()=='zh_CN')
                        a.ASI_CRM_CN_T1_WS1__c.addError('请选择一批');
                    else
                        a.ASI_CRM_CN_T1_WS1__c.addError('Please select a T1 wholesaler for T1 WS');
                    break;
                    //20151221 End
                }
                
                //20151221 Ben @ Elufa System
                if(a.ASI_CRM_CN_T1_WS1__c == null && trigger_oldMap.get(a.id).ASI_CRM_CN_T1_WS1__c != null){
                    a.ASI_CRM_T1_WS_Account__c = null;
                }
                //20151221 End
            }
        }
        /*for(ASI_CRM_AccountsAdditionalField__c a : trigger_new){
            if ((a.ASI_CRM_T1_WS_Account__c != a.ASI_CRM_CN_T1_WS1__c && a.ASI_CRM_T1_WS_Account__c != null) || (a.ASI_CRM_T1_WS_Account__c == null && trigger_oldMap.get(a.id).ASI_CRM_T1_WS_Account__c != null)){
                CustomerWithT1WS.add(a.ASI_CRM_T1_WS_Account__c);
            }
            //20160125 Ben @ Elufa
            if(a.ASI_CRM_T1_WS_Account__c == null && trigger_oldMap.get(a.id).ASI_CRM_T1_WS_Account__c == null && a.ASI_CRM_CN_T1_WS1__c != NULL){
                CustomerWithT1WS2.add(a.ASI_CRM_CN_T1_WS1__c);
            }
            
        }
        if(CustomerWithT1WS2.size() > 0){
            Map<id, ASI_CRM_AccountsAdditionalField__c> WSMap2 = new Map<id, ASI_CRM_AccountsAdditionalField__c>([SELECT id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id IN : CustomerWithT1WS2]);
            for(ASI_CRM_AccountsAdditionalField__c a : trigger_new){
                if(CustomerWithT1WS2.contains(a.ASI_CRM_CN_T1_WS1__c) && WSMap2.containsKey(a.ASI_CRM_CN_T1_WS1__c)){
                    a.ASI_CRM_T1_WS_Account__c = WSMap2.get(a.ASI_CRM_CN_T1_WS1__c).ASI_CRM_Account__c;
                }
            }
        }
        //20160125 End
        if(CustomerWithT1WS.size()>0) {
            Map<id,id> WSMap = new Map<id,id>();
            WSMap = ASI_CRM_CN_AccountsAdditional_HelperCls.GetT1WSID(CustomerWithT1WS);
            for(ASI_CRM_AccountsAdditionalField__c a : trigger_new){
                if (a.ASI_CRM_T1_WS_Account__c != a.ASI_CRM_CN_T1_WS1__c && a.ASI_CRM_T1_WS_Account__c != null){
                    if(WSMap.containsKey(a.ASI_CRM_T1_WS_Account__c)) {
                        
                        a.ASI_CRM_CN_T1_WS1__c = WSMap.get(a.ASI_CRM_T1_WS_Account__c);
                    }
                    else
                    {
                        a.ASI_CRM_CN_T1_WS1__c = null;
                        
                        //20151221 Ben @ Elufa System
                        if(USerInfo.getLanguage()=='zh_CN')
                            a.ASI_CRM_CN_T1_WS1__c.addError('请选择一批');
                        else
                            a.ASI_CRM_CN_T1_WS1__c.addError('Please select a T1 wholesaler for T1 WS (Account)');
                        break;
                        //20151221 End
                    }
                }
                if((a.ASI_CRM_T1_WS_Account__c == null && trigger_oldMap.get(a.id).ASI_CRM_T1_WS_Account__c != null)){
                    a.ASI_CRM_CN_T1_WS1__c = null;
                }
                //20151221 Ben @ Elufa System
                if(a.ASI_CRM_CN_T1_WS1__c == null && trigger_oldMap.get(a.id).ASI_CRM_CN_T1_WS1__c != null){
                    a.ASI_CRM_T1_WS_Account__c = null;
                }
                //20151221 End
            }
        }*/
        // -- End -- //
    }
    
    public static void routineBeforeInsert(list<ASI_CRM_AccountsAdditionalField__c > trigger_new, map<id, ASI_CRM_AccountsAdditionalField__c > trigger_oldMap) {
        if(!ASI_CRM_CN_Function.IsBypassTrigger(className)) {
            //Added by Twinkle 8th Oct 2014 Check for duplication of Customers(Chinese Name, English Name, Legal Name)
            List<String> LNewCustChiName = new List<String>();
            List<String> LNewCustEngName = new List<String>();
            List<String> LNewCustLegalname = new List<String>();
            List<String> LNewCustCity = new List<String>();
            List<String> LNewCustRecordType = new List<String>();
            Map<String, ASI_CRM_AccountsAdditionalField__c> MdulChiName = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
            Map<String, ASI_CRM_AccountsAdditionalField__c> MdulEngName = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
            Map<String, ASI_CRM_AccountsAdditionalField__c> MdulLegalName = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
            Map<String, ASI_CRM_Sales_Team__c> mapCommercialTeam = new Map<String, ASI_CRM_Sales_Team__c>();//20170130 Elufa
            
            //20170130 Elufa
            for(ASI_CRM_Sales_Team__c st : salesTeamList){
                
                mapCommercialTeam.put(st.name.toLowerCase(), st);
            }
            //20170130 End
            
            //20160418 Ben @ Elufa
            Map<Id, ASI_CRM_KA_Account__c> mapKAAcc = new Map<Id, ASI_CRM_KA_Account__c>();
            for(ASI_CRM_KA_Account__c obj : kaAccList){
                mapKAAcc.put(obj.Id, obj);
            }
            //20160418 End

            for(ASI_CRM_AccountsAdditionalField__c cust : trigger_new){
                
                //20170130 Elufa
                String ownerSalesTeam = ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUser(cust.ownerId) != Null && ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUser(cust.ownerId).ASI_CRM_Sales_Team__c != Null ? ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUser(cust.ownerId).ASI_CRM_Sales_Team__c.toLowerCase() : '';
                if(mapCommercialTeam.containsKey(ownerSalesTeam)){
                    cust.ASI_CRM_CN_Commercial_Team__c = mapCommercialTeam.get(ownerSalesTeam).ASI_CRM_Commercial_Team__c;
                }
                //20170130 End
                
                //20160808 Ben @ Elufa
                /*if(cust.ASI_CRM_CN_Commercial_Team__c == NULL && cust.recordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN')){
                    cust.ASI_CRM_CN_Commercial_Team__c.addError('Please input Commercial Team');
                    BREAK;
                }*///20170130 Elufa Commented
                //20160808
                
                //20170128 Elufa Commented, replace with ASI_CRM_CN_AccountsAdditional_HelperCls.validationCustomerName(trigger_new);
                /*LNewCustChiName.add(cust.ASI_CRM_CN_Chi_Name__c);
                LNewCustEngName.add(cust.ASI_CRM_CN_Eng_Name__c);
                LNewCustCity.add(cust.ASI_CRM_CN_CCity__c);
                LNewCustRecordType.add(cust.RecordTypeid);*/
                
                //20160418 Ben @ Elufa
                if(cust.ASI_CRM_CN_KA_Account_Chain__c != NULL && mapKAAcc.containsKey(cust.ASI_CRM_CN_KA_Account_Chain__c)){
                    
                    //cust.ASI_CRM_KA_Event__c = mapKAEvent.get(cust.ASI_CRM_CN_KA_Account__c).id;
                    cust.ASI_CRM_KA_Account_Sequence__c = mapKAAcc.get(cust.ASI_CRM_CN_KA_Account_Chain__c).ASI_CRM_Sequence__c;
                    cust.ASI_CRM_KA_Account_CN_Name__c = mapKAAcc.get(cust.ASI_CRM_CN_KA_Account_Chain__c).ASI_CRM_Chi_Name__c;
                }
                //20160418 End

                // Add By Zhonghui, 2020-12-04, 新建不能勾选上传客户资质
                if ( (cust.ASI_CRM_CN_BusinessLicenseUploading__c 
                        || cust.ASI_CRM_CN_Business_License_Start_Date__c != null
                        || cust.ASI_CRM_CN_Busi_License_ExpireDate_Perm__c
                        || cust.ASI_CRM_CN_Business_License_Expire_date__c !=null) 
                    && !Test.isRunningTest()) {
                    cust.addError(Label.ASI_CRM_CN_TP_CHECK_ASI_CRM_CN_BusinessLicenseUploading);
                }                
            }
            
            //20170128 Elufa Commented, replace with ASI_CRM_CN_AccountsAdditional_HelperCls.validationCustomerName(trigger_new);
            /*if((LNewCustChiName != null && LNewCustChiName.size() >0) || (LNewCustEngName != null && LNewCustEngName.size() >0) || (LNewCustLegalname != null && LNewCustLegalname.size() >0)){
                    List<ASI_CRM_AccountsAdditionalField__c> LDupCustName = [SELECT id, ASI_CRM_CN_CCity__c, ASI_CRM_CN_Chi_Name__c,ASI_CRM_CN_Eng_Name__c, ASI_CRM_CN_Legal_Name__c FROM ASI_CRM_AccountsAdditionalField__c WHERE (ASI_CRM_CN_Chi_Name__c IN: LNewCustChiName OR ASI_CRM_CN_Eng_Name__c IN: LNewCustEngName OR ASI_CRM_CN_Legal_Name__c IN: LNewCustLegalname) AND RecordTypeid IN: LNewCustRecordType AND ASI_CRM_CN_CCity__c IN: LNewCustCity];
                
                /*    List<ASI_CRM_AccountsAdditionalField__c> LDupCustName = [SELECT id, ASI_CRM_CN_CCity__c, ASI_CRM_CN_Chi_Name__c,ASI_CRM_CN_Eng_Name__c, ASI_CRM_CN_Legal_Name__c
                                                                         FROM ASI_CRM_AccountsAdditionalField__c 
                                                                         WHERE (ASI_CRM_CN_Chi_Name__c IN: LNewCustChiName OR ASI_CRM_CN_Eng_Name__c IN: LNewCustEngName OR ASI_CRM_CN_Legal_Name__c IN: LNewCustLegalname) AND
                                                                               (RecordTypeid =: Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS') OR RecordTypeid=: Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'))]; */
                /*for(ASI_CRM_AccountsAdditionalField__c d : LDupCustName){
                    if(!MdulChiName.containsKey(d.ASI_CRM_CN_Chi_Name__c))
                        MdulChiName.put(d.ASI_CRM_CN_Chi_Name__c, d);
                    if(!MdulEngName.containsKey(d.ASI_CRM_CN_Eng_Name__c))
                        MdulEngName.put(d.ASI_CRM_CN_Eng_Name__c, d);
                    if(!MdulLegalName.containsKey(d.ASI_CRM_CN_Legal_Name__c))
                        MdulLegalName.put(d.ASI_CRM_CN_Legal_Name__c, d);
                }

                for(ASI_CRM_AccountsAdditionalField__c cust : trigger_new){
                    if(cust.RecordtypeId != prospectRTID){//20161026 Ben @ Elufa added if(a.RecordtypeId != prospectRTID){}
                        if(cust.ASI_CRM_CN_Chi_Name__c != NULL && MdulChiName.get(cust.ASI_CRM_CN_Chi_Name__c) != null && MdulChiName.get(cust.ASI_CRM_CN_Chi_Name__c).id != cust.id && cust.ASI_CRM_CN_CCity__c == MdulChiName.get(cust.ASI_CRM_CN_Chi_Name__c).ASI_CRM_CN_CCity__c){
                            cust.addError(Label.ASI_CRM_CN_CustomerChiNameDuplicateErrMsg);
                            break;
                        }
                        else if(cust.ASI_CRM_CN_Eng_Name__c != NULL && MdulEngName.get(cust.ASI_CRM_CN_Eng_Name__c) != null && MdulEngName.get(cust.ASI_CRM_CN_Eng_Name__c).id != cust.id && cust.ASI_CRM_CN_CCity__c == MdulEngName.get(cust.ASI_CRM_CN_Eng_Name__c).ASI_CRM_CN_CCity__c){
                            cust.addError(Label.ASI_CRM_CN_CustomerEngNameDuplicateErrMsg);
                            break;
                        }
                        /*else if(cust.ASI_CRM_CN_Legal_Name__c !=NULL && MdulLegalName.get(cust.ASI_CRM_CN_Legal_Name__c) != null && MdulLegalName.get(cust.ASI_CRM_CN_Legal_Name__c).id != cust.id && cust.ASI_CRM_CN_CCity__c == MdulLegalName.get(cust.ASI_CRM_CN_Legal_Name__c).ASI_CRM_CN_CCity__c){
                            cust.addError(Label.ASI_CRM_CN_CustomerLegalNameDuplicateErrMsg);
                            break;
                        }*/
            //        }
            //    }
            //}
            //End - Twinkle 8th Oct 2014
            
            List<ASI_CRM_CN_Brand_T1_Group__c > Brand_T1_Group_list= [Select id ,Name from ASI_CRM_CN_Brand_T1_Group__c ];
            Map<String,ASI_CRM_CN_Brand_T1_Group__c > Brand_T1_Group_map= new Map<String,ASI_CRM_CN_Brand_T1_Group__c >();
            for(ASI_CRM_CN_Brand_T1_Group__c  a:Brand_T1_Group_list){
                Brand_T1_Group_map.put(a.Name,a);
            }
            
            for(ASI_CRM_AccountsAdditionalField__c a : trigger_new){
                //set brand name look up Lokman 18/6/2014
                if(a.recordtypeid != null && Global_RecordTypeCache.getRt(a.recordTypeId).developerName.contains('ASI_CRM_CN_WS')){
                    if(a.ASI_CRM_CN_Brand__c!=null && a.ASI_CRM_CN_Brand__c!=''){
                        if(Brand_T1_Group_map.containsKey(a.ASI_CRM_CN_Brand__c)){
                            a.ASI_CRM_CN_Brand_Lookup__c=Brand_T1_Group_map.get(a.ASI_CRM_CN_Brand__c).id;
                        }                    
                    }
                }
            }
            ASI_CRM_CN_AccountsAdditional_HelperCls.validationCustomerName(trigger_new, Null);//20170128 Elufa
            prosSegmentationMapping(trigger_new, trigger_oldMap); //20160613, Leo@Elufa
        }
    }
    public static void routineAfterInsert(list<ASI_CRM_AccountsAdditionalField__c > trigger_new, map<id, ASI_CRM_AccountsAdditionalField__c > trigger_oldMap) {
        if(!ASI_CRM_CN_Function.IsBypassTrigger(className)) {
            List<ASI_CRM_AccountsAdditionalField__c> updateAccountsAdditionalFieldList = new List<ASI_CRM_AccountsAdditionalField__c>();
            Set<Id> ids = new Set<Id>();
            //Get Account Record Type
            String OutletRCid;
            String WholeSalesRCid;
            for (RecordType rc : Global_RecordTypeCache.getRtList('Account')){
                if (rc.developerName.contains('ASI_MFM_CN_Outlet'))
                    OutletRCid = rc.id;
                if (rc.developerName.contains('ASI_CRM_CN_Wholesales_CN'))
                    WholeSalesRCid = rc.id;
            }
            System.debug('OutletRCid '+ OutletRCid + 'WholeSalesRCid '+ WholeSalesRCid );
            
            
            List<ASI_CRM_Approval_Comment__c> LNewContractComment_Insert = new List<ASI_CRM_Approval_Comment__c>();
            //2014-07-29 Stella Sing Fix linked Parent Account in list
            map<id, Account> MapAccountChild = new map<id, Account>();
            for (ASI_CRM_AccountsAdditionalField__c a : trigger_new){
                LNewContractComment_Insert.add(new ASI_CRM_Approval_Comment__c(ASI_CRM_Customer__c = a.id, recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_Customer_Comment')));
                
                if(a.RecordtypeId != prospectRTID){//20161007 Ben @ Elufa added if(a.RecordtypeId != prospectRTID){
                    
                    Account linkedAcct = new Account();
                    list<Account> linkedAcct_templist = new list<Account>();
                    if(a.OwnerId != null)
                        linkedAcct.OwnerId = a.OwnerId;
                    linkedAcct.Name = a.Name;
                    if (Global_RecordTypeCache.getRt(a.recordTypeid).developerName.contains('ASI_CRM_Outlet_CN'))
                        linkedAcct.recordTypeid  = OutletRCid;
                    else if (Global_RecordTypeCache.getRt(a.recordTypeid).developerName.contains('ASI_CRM_CN_WS'))
                        linkedAcct.recordTypeid  = WholeSalesRCid;
                    
                    MapAccountChild.put(a.id, linkedAcct); 
                    ids.add(a.id);
                }
            }
            
            if(LNewContractComment_Insert !=null && LNewContractComment_Insert.size() > 0){
                insert LNewContractComment_Insert;
            } 
            
            
            
            if (MapAccountChild.size() > 0){
                list<Account> insertNewAccount = new list<Account>();
                insertNewAccount.addAll(MapAccountChild.values());
                insert insertNewAccount;
                system.debug('MapAccountChild: ' + MapAccountChild);
                
                list<ASI_CRM_AccountsAdditionalField__c> accountsAdditionalField = [SELECT id, Name,
                    ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name,
                    ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.Name,
                    ASI_CRM_CN_CCity__r.Name, ASI_CRM_CN_JDE_Code__c, ASI_CRM_CN_Chi_Name__c,
                    ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.Name, ASI_CRM_CN_Sub_Channel__r.Name,
                    ASI_CRM_CN_Address__c, ASI_CRM_CN_CRM_Code__c, ASI_CRM_CN_Email__c,
                    ASI_CRM_CN_Phone_Number__c
                                                                                    FROM ASI_CRM_AccountsAdditionalField__c WHERE id in :ids];
                
                // Added by Michael Yip (Introv) for updating account fields
                List<Account> LAcctUpdate = updateAccountByCustomer(MapAccountChild, accountsAdditionalField);
                if(LAcctUpdate.size()>0){
                    update LAcctUpdate;
                }
                
                for (ASI_CRM_AccountsAdditionalField__c b : accountsAdditionalField){
                    if (MapAccountChild.containskey(b.id)){
                        b.ASI_CRM_Account__c = MapAccountChild.get(b.id).id;
                        updateAccountsAdditionalFieldList.add(b);
                    }
                }
                if (updateAccountsAdditionalFieldList.size() > 0)
                    ASI_CRM_CN_AccountsAdditional_HelperCls.updateRecord(updateAccountsAdditionalFieldList);
                    //update updateAccountsAdditionalFieldList;
            }
            SetCustomGroupFlag(trigger_new, trigger_oldMap);
            
            //Added by Twinkle 20150105 - Apex Sharing (Share Customer to PG Head)
            /*if(trigger_oldMap == null){
                List<ASI_CRM_AccountsAdditionalField__Share> sharesToCreate = new List<ASI_CRM_AccountsAdditionalField__Share>();
            
                for(ASI_CRM_AccountsAdditionalField__c cust : trigger_new){
                     if(cust.ASI_CRM_CN_PG_Head__c != null){
                        ASI_CRM_AccountsAdditionalField__Share newRecord = new ASI_CRM_AccountsAdditionalField__Share();
                        newRecord.ParentId = cust.Id;
                        newRecord.UserOrGroupId = cust.ASI_CRM_CN_PG_Head__c;
                        newRecord.AccessLevel = 'Read';         
                        newRecord.RowCause = Schema.ASI_CRM_AccountsAdditionalField__Share.RowCause.PG_Head_Sharing__c;
                        sharesToCreate.add(newRecord);
                    }
                }
                if (!sharesToCreate.isEmpty())
                    insert sharesToCreate;  
            }*/
            //End - Twinkle 20150105
        }
    }
    
    public static void routineAfterUpdate(list<ASI_CRM_AccountsAdditionalField__c > trigger_new, map<id, ASI_CRM_AccountsAdditionalField__c > trigger_oldMap) {
        if(!ASI_CRM_CN_Function.IsBypassTrigger(className)) {            
            Map<id, account> MapAccountChild = new Map<id, account>();
            Set<Id> ids = new Set<Id>();
            List<ASI_CRM_AccountsAdditionalField__c> convertProspectCloneList = new List<ASI_CRM_AccountsAdditionalField__c>(); //20161017 Ben @ Elufa
            List<ASI_CRM_AccountsAdditionalField__c> ProspectList = new List<ASI_CRM_AccountsAdditionalField__c>(); //20161017 Ben @ Elufa
            List<ASI_CRM_AccountsAdditionalField__c> triggerList = new List<ASI_CRM_AccountsAdditionalField__c>(); //20161025 Ben @ Elufa
            
            for (ASI_CRM_AccountsAdditionalField__c a : trigger_new){
                
                if(a.RecordtypeId != prospectRTID){//20161007 Ben @ Elufa added if(a.RecordtypeId != prospectRTID){
                    
                    if(a.ASI_CRM_CN_CCity__c != trigger_oldMap.get(a.id).ASI_CRM_CN_CCity__c ||
                       a.ASI_CRM_CN_JDE_Code__c!= trigger_oldMap.get(a.id).ASI_CRM_CN_JDE_Code__c ||
                       a.ASI_CRM_CN_Chi_Name__c!= trigger_oldMap.get(a.id).ASI_CRM_CN_Chi_Name__c ||
                       a.name != trigger_oldMap.get(a.id).name||
                       a.ASI_CRM_CN_Sub_Channel__c != trigger_oldMap.get(a.id).ASI_CRM_CN_Sub_Channel__c ||
                       a.ASI_CRM_CN_Address__c != trigger_oldMap.get(a.id).ASI_CRM_CN_Address__c ||
                       a.ASI_CRM_CN_CRM_Code__c != trigger_oldMap.get(a.id).ASI_CRM_CN_CRM_Code__c ||
                       a.ASI_CRM_CN_Email__c  != trigger_oldMap.get(a.id).ASI_CRM_CN_Email__c ||
                       a.ASI_CRM_CN_Phone_Number__c != trigger_oldMap.get(a.id).ASI_CRM_CN_Phone_Number__c){
                           if(a.ASI_CRM_Account__c != null){
                               MapAccountChild.put(a.id,new Account(id=a.ASI_CRM_Account__c)); 
                           }
                           ids.add(a.id);     
                    }
                }
                
                //20161017 Ben @ Elufa
                /*if(trigger_oldMap.get(a.id).recordTypeId == prospectRTID && a.recordTypeId == outletRTID){
                    
                    ASI_CRM_AccountsAdditionalField__c tmpCust = a.clone(false, true);
                    
                    tmpCust.id = NULL;
                    tmpCust.ASI_CRM_Customer__c = a.id;
                    tmpCust.RecordTypeId = outletRTID;
                    
                    ASI_CRM_AccountsAdditionalField__c tmpCust2 = new ASI_CRM_AccountsAdditionalField__c();
                    tmpCust2.RecordTypeId = prospectRTID;
                    tmpCust2.ASI_CRM_Status__c = 'Converted';
                    tmpCust2.id = a.id;
                    
                    ProspectList.add(tmpCust2);
                    convertProspectCloneList.add(tmpCust);
                    triggerList.add(a);
                }*/ //20170426 commented for CD Phase 1 Deployment
            }
            /*if(convertProspectCloneList.size() > 0){
                
                try{
                    
                    database.Update(ProspectList, TRUE);
                    database.insert(convertProspectCloneList, TRUE);
                    
                }catch(dmlException dmle){
                    
                    integer i = 0;
                    for(ASI_CRM_AccountsAdditionalField__c a : triggerList){
                        
                        a.addError(a.Name + ' : ' + dmle.getDmlMessage(i));
                        i++;
                    }
                }
            }*/
            //20161017 End //20170426 commented for CD Phase 1 Deployment
            
            list<ASI_CRM_AccountsAdditionalField__c> LCust= [SELECT id, Name,
                    ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name,
                    ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.Name,
                    ASI_CRM_CN_CCity__r.Name, ASI_CRM_CN_JDE_Code__c, ASI_CRM_CN_Chi_Name__c,
                    ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.Name, ASI_CRM_CN_Sub_Channel__r.Name,
                    ASI_CRM_CN_Address__c, ASI_CRM_CN_CRM_Code__c, ASI_CRM_CN_Email__c,
                    ASI_CRM_CN_Phone_Number__c
                    FROM ASI_CRM_AccountsAdditionalField__c WHERE id in :ids];
            
            if(MapAccountChild != null & MapAccountChild.size()>0){
                List<Account> LAcctUpdate = updateAccountByCustomer(MapAccountChild, LCust);
                if(LAcctUpdate.size()>0){
                    update LAcctUpdate;
                }
            }                       
            SetCustomGroupFlag(trigger_new, trigger_oldMap);
           // SetSubBrandVolVal(trigger_new, trigger_oldMap);
            
            //Added by Twinkle 20150105 - Apex Sharing(Share Customer to PG Head)
            /*List<ASI_CRM_AccountsAdditionalField__Share> sharesToCreate  = new List<ASI_CRM_AccountsAdditionalField__Share>();
            List<ID> shareIdsToDelete = new List<ID>();
            
            for(ASI_CRM_AccountsAdditionalField__c cust : trigger_new){
                if(cust.ASI_CRM_CN_PG_Head__c != null){
                    if(cust.ASI_CRM_CN_PG_Head__c != trigger_oldMap.get(cust.id).ASI_CRM_CN_PG_Head__c){
                        ASI_CRM_AccountsAdditionalField__Share newRecord = new ASI_CRM_AccountsAdditionalField__Share();
                        newRecord.ParentId = cust.Id;
                        newRecord.UserOrGroupId = cust.ASI_CRM_CN_PG_Head__c;
                        newRecord.AccessLevel = 'Read';         
                        newRecord.RowCause = Schema.ASI_CRM_AccountsAdditionalField__Share.RowCause.PG_Head_Sharing__c;
                        sharesToCreate.add(newRecord);
                        shareIdsToDelete.add(cust.id);
                    }
                }
                else{
                    shareIdsToDelete.add(cust.id);
                }
            }
            if (!shareIdsToDelete.isEmpty())
                delete [select id from ASI_CRM_AccountsAdditionalField__Share where ParentId IN :shareIdsToDelete and RowCause =: Schema.ASI_CRM_AccountsAdditionalField__Share.RowCause.PG_Head_Sharing__c];
            if (!sharesToCreate.isEmpty())
                insert sharesToCreate; 
            */ 
            //End - Twinkle 20150105
        }
    }
    
    public static void routineAfterDelete(list<ASI_CRM_AccountsAdditionalField__c > trigger_old, map<id, ASI_CRM_AccountsAdditionalField__c > trigger_oldMap) {
        if(!ASI_CRM_CN_Function.IsBypassTrigger(className)) {        
            SetCustomGroupFlag(trigger_old, trigger_oldMap);
        }
    }
    
    public static void routineBeforeDelete(list<ASI_CRM_AccountsAdditionalField__c> trigger_old, map<id, ASI_CRM_AccountsAdditionalField__c> trigger_oldMap) {
        if(!ASI_CRM_CN_Function.IsBypassTrigger(className)) {
            List <ASI_TH_CRM_Contract__c> contract = [Select ASI_CRM_CN_Outlet_WS__c from ASI_TH_CRM_Contract__c where ASI_CRM_CN_Outlet_WS__c IN :trigger_old];
            List <ASI_TH_CRM_PaymentRequest__c> payReq = [Select ASI_CRM_CN_OutletWS__c from ASI_TH_CRM_PaymentRequest__c where ASI_CRM_CN_OutletWS__c IN :trigger_old];
            List <ASI_CRM_Subbrand_Volume__c> volume = [Select ASI_CRM_Account__c from ASI_CRM_Subbrand_Volume__c where ASI_CRM_Account__c IN :trigger_old];
            for(ASI_CRM_AccountsAdditionalField__c a : trigger_old){
                system.debug(a);
                
                if(a.recordtypeid != null && (Global_RecordTypeCache.getRt(a.recordTypeId).developerName.contains('ASI_CRM_Outlet_CN')|| Global_RecordTypeCache.getRt(a.recordTypeId).developerName.contains('ASI_CRM_CN_WS'))){       
                    for(ASI_TH_CRM_Contract__c b: contract ){                                  
                        if( a.ID == b.ASI_CRM_CN_Outlet_WS__c ){
                             a.addError('Cannot delete Customer with transaction(s)');
                        }
                    }
                    for(ASI_TH_CRM_PaymentRequest__c c: payReq  ){                
                        if( a.ID == c.ASI_CRM_CN_OutletWS__c ){
                             a.addError('Cannot delete Customer with transaction(s).');
                        }
                    }
                    for(ASI_CRM_Subbrand_Volume__c c: volume  ){                
                        if( a.ID == c.ASI_CRM_Account__c ){
                             a.addError(' This outlet/WS has already volume and can’t be deleted. / 该店家/批发商已有销量，无法删除');
                        }
                    }
                }
            }
        }
    }
    
    /*    Added by Michael Yip (Introv) 31Jul2014 to update account record for insert/update customer
          Map<id, Account>: id of customer => account
    */
    public static List<Account> updateAccountByCustomer(Map<id, Account> MAcctID, List<ASI_CRM_AccountsAdditionalField__c> LCust){
        List<Account> LAcctResult = new List<Account>();
        for(ASI_CRM_AccountsAdditionalField__c customer : LCust){
            if(MAcctID.containsKey(customer.id)){
                Account tempAcct = MAcctID.get(customer.id);
                LAcctResult.add(copyAccountFromCustomer(MAcctID.get(customer.id),customer));
            }
        }
        return LAcctResult;
    }
    public static Account copyAccountFromCustomer(Account acct, ASI_CRM_AccountsAdditionalField__c customer){        
        acct.ASI_KOR_Addr_Region__c = customer.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name;
        acct.ASI_HK_CRM_Location__c = customer.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.Name;
        acct.ASI_MFM_City__c        = customer.ASI_CRM_CN_CCity__r.Name;
        acct.ASI_HK_CRM_JDE_Account_Number__c = customer.ASI_CRM_CN_JDE_Code__c;
        acct.ASI_HK_CRM_Chinese_Name__c = customer.ASI_CRM_CN_Chi_Name__c;
        acct.name = customer.name;
        acct.ASI_HK_CRM_Channel__c = customer.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.Name;
        acct.Sub_Channel__c = customer.ASI_CRM_CN_Sub_Channel__r.Name;
        acct.ASI_MFM_Address_Line_1__c = customer.ASI_CRM_CN_Address__c;
        acct.ASI_MFM_Customer_Supplier_Number__c = customer.ASI_CRM_CN_CRM_Code__c;
        acct.ASI_LUX_Email_Business__c = customer.ASI_CRM_CN_Email__c;
        acct.Phone = customer.ASI_CRM_CN_Phone_Number__c;

        return acct;
    }
    
    public static void SetCustomGroupFlag(list<ASI_CRM_AccountsAdditionalField__c > tempList, map<id, ASI_CRM_AccountsAdditionalField__c > trigger_oldMap) {
        
        //20170202 Elufa move logic to without sharing class "ASI_CRM_CN_AccountsAdditional_HelperCls"
        ASI_CRM_CN_AccountsAdditional_HelperCls.SetCustomGroupFlag(tempList, trigger_oldMap);
        /*
        Set<ID> parentOutletIDSet = new Set<ID>();
        if(tempList != null)
        {
            for(ASI_CRM_AccountsAdditionalField__c a : tempList){
                // Modified by Michael Yip (Introv) 31Jul2014 to reduce soql
                if(trigger_oldMap == null){
                    if(a.ASI_CRM_CN_Parent_Outlet__c != null)
                    {
                        if(!parentOutletIDSet.contains(a.ASI_CRM_CN_Parent_Outlet__c))
                            parentOutletIDSet.add(a.ASI_CRM_CN_Parent_Outlet__c);
                    }
                }
                else{
                    if(a.ASI_CRM_CN_Parent_Outlet__c != null && trigger_oldMap.get(a.id).ASI_CRM_CN_Parent_Outlet__c==null )
                    {
                        if(!parentOutletIDSet.contains(a.ASI_CRM_CN_Parent_Outlet__c))
                            parentOutletIDSet.add(a.ASI_CRM_CN_Parent_Outlet__c);
                    }
                    else if(a.ASI_CRM_CN_Parent_Outlet__c == null && trigger_oldMap.get(a.id).ASI_CRM_CN_Parent_Outlet__c !=null )
                    {
                        if(!parentOutletIDSet.contains(trigger_oldMap.get(a.id).ASI_CRM_CN_Parent_Outlet__c))
                            parentOutletIDSet.add(trigger_oldMap.get(a.id).ASI_CRM_CN_Parent_Outlet__c);
                    }
                }
                
            }
        }
        
        List <ASI_CRM_AccountsAdditionalField__c > childOutletList = 
            [SELECT ASI_CRM_CN_Parent_Outlet__c,id,ASI_CRM_CN_Group_Flag__c  from ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_CN_Parent_Outlet__c IN: parentOutletIDSet];
        
        List <ASI_CRM_AccountsAdditionalField__c > parentOutletUpdateList = new List <ASI_CRM_AccountsAdditionalField__c >();
        
        // Added by Michael Yip(Introv) 07JUl2014 to handle deleting parent and child at same trigger
        List<ASI_CRM_AccountsAdditionalField__c > LExistingParent = 
            [SELECT ASI_CRM_CN_Parent_Outlet__c,id from ASI_CRM_AccountsAdditionalField__c WHERE id IN: parentOutletIDSet];
        
        if(LExistingParent != null)
        {
            for(ASI_CRM_AccountsAdditionalField__c tempCustomer :LExistingParent ) {
                Boolean hasChild = false;
                
                if(childOutletList != null && childOutletList.size()>0)
                {
                    for(ASI_CRM_AccountsAdditionalField__c childCustomer : childOutletList) {
                        if(childCustomer.ASI_CRM_CN_Parent_Outlet__c == tempCustomer.id)
                        {
                            hasChild = true;
                        }
                    }
                }
                
                tempCustomer.ASI_CRM_CN_Group_Flag__c = hasChild;
                
                parentOutletUpdateList.add(tempCustomer);
            }
        }        
        if(parentOutletUpdateList != null && parentOutletUpdateList.size()>0) {
            update parentOutletUpdateList;
        }
*/
        
    }

   /* public static void SetSubBrandVolVal(list<ASI_CRM_AccountsAdditionalField__c > trigger_new, map<id, ASI_CRM_AccountsAdditionalField__c > trigger_oldMap) {
        Set<ID> customerIDSet = new Set<ID>();

        for(Integer i = 0; i < trigger_new.size(); i++){
            if ((trigger_new[i].ASI_CRM_CN_WS_Tier__c != trigger_oldMap.get(trigger_new[i].id).ASI_CRM_CN_WS_Tier__c) || (trigger_new[i].ASI_CRM_CN_CCity__c != trigger_oldMap.get(trigger_new[i].id).ASI_CRM_CN_CCity__c))
            {
                customerIDSet.add(trigger_new[i].id);
            }
        }

        List <ASI_CRM_Subbrand_Volume__c> volList = 
            [SELECT id, ASI_CRM_CN_WS_Tier__c, ASI_CRM_CN_Region__c FROM ASI_CRM_Subbrand_Volume__c WHERE ASI_CRM_Account__c IN: customerIDSet];

        update volList;
    }*/
    
    //20160613, Leo @Elufa
    public static void prosSegmentationMapping(List<ASI_CRM_AccountsAdditionalField__c> triggerList, Map<id,ASI_CRM_AccountsAdditionalField__c> trigger_oldMap)
    {
        Set<Id> newChannelSet = new Set<Id>();
        Set<Id> subChannelSet = new Set<Id>();
        List<ASI_CRM_AccountsAdditionalField__c> cusList = new List<ASI_CRM_AccountsAdditionalField__c>();
        List<ASI_CRM_PROS_Segmentation_Mapping__c> segmentMappingList = new List<ASI_CRM_PROS_Segmentation_Mapping__c>();
        Map<String,ASI_CRM_PROS_Segmentation_Mapping__c> segmentMappingMap = new Map<String,ASI_CRM_PROS_Segmentation_Mapping__c>();
        List<ASI_CRM_CN_Channel__c> newChnnelList = new List<ASI_CRM_CN_Channel__c>();
        Map<String,ASI_CRM_CN_Channel__c> newChannelMap3 = new Map<String,ASI_CRM_CN_Channel__c>();
        //String errMsgCN = '请输入 ';
        //String errMsgEG = 'Please input ';
        //Boolean hasError = false;
        id outletType = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        //20160930 Ben @ Elufa
        newChnnelList = new List<ASI_CRM_CN_Channel__c>([SELECT id, Name,
                                                         ASI_CRM_CN_On_Off__c,
                                                         ASI_CRM_CN_Channel_Group__c
                                                         FROM ASI_CRM_CN_Channel__c
                                                         WHERE recordType.developerName = 'ASI_CRM_CN_New_Channel']);
        
        if(newChnnelList.size() > 0)
        {
            for(ASI_CRM_CN_Channel__c obj: newChnnelList)
            {
                if(!newChannelMap3.containsKey(obj.Id))
                    newChannelMap3.put(obj.Id,obj);
            }
        }
        //20160930 End
        
        for(ASI_CRM_AccountsAdditionalField__c obj: triggerList)
        {
            //20160930 Ben @ Elufa
            if(newChannelMap3.containsKey(obj.ASI_CRM_CN_NewChannel__c)){
                obj.ASI_CRM_Channel_Group__c = newChannelMap3.get(obj.ASI_CRM_CN_NewChannel__c).ASI_CRM_CN_Channel_Group__c;
            }else{
                obj.ASI_CRM_Channel_Group__c = NULL;
            }
            //20160930 End
            
            if(obj.RecordTypeId == outletType)
            {
                if(obj.ASI_CRM_CN_NewChannel__c!=null)
                {
                    newChannelSet.add(obj.ASI_CRM_CN_NewChannel__c);
                }
                subChannelSet.add(obj.ASI_CRM_CN_Sub_Channel__c);
                cusList.add(obj);
            }
        }//end for
        if(newChannelSet.size() > 0)
        {
            segmentMappingList 
                = new List<ASI_CRM_PROS_Segmentation_Mapping__c>([SELECT id, Name
                                                                  ,ASI_CRM_New_Channel__c
                                                                  ,ASI_CRM_New_Channel__r.Name
                                                                  ,ASI_CRM_Energy__c
                                                                  ,ASI_CRM_Hostess__c
                                                                  ,ASI_CRM_Outlet_Type__c
                                                                  ,ASI_CRM_Outlet_Channel_Type__c
                                                                  ,ASI_CRM_PROS_Segmentation__c
                                                                  FROM ASI_CRM_PROS_Segmentation_Mapping__c
                                                                  WHERE ASI_CRM_New_Channel__c IN: newChannelSet]);
        }
        
        if(segmentMappingList.size() > 0)
        {
            for(ASI_CRM_PROS_Segmentation_Mapping__c obj: segmentMappingList)
            {
                if(!segmentMappingMap.containsKey(''+(obj.ASI_CRM_New_Channel__c!=NULL ? obj.ASI_CRM_New_Channel__c:null)
                                                  +(obj.ASI_CRM_Energy__c!=''&&obj.ASI_CRM_Energy__c!=NULL ? obj.ASI_CRM_Energy__c:'')
                                                  +(obj.ASI_CRM_Hostess__c!=''&&obj.ASI_CRM_Hostess__c!=NULL ? 'TRUE':'FALSE')
                                                  +(obj.ASI_CRM_Outlet_Type__c!=''&&obj.ASI_CRM_Outlet_Type__c!=NULL ? obj.ASI_CRM_Outlet_Type__c:'')
                                                  +(obj.ASI_CRM_Outlet_Channel_Type__c!=''&&obj.ASI_CRM_Outlet_Channel_Type__c!=NULL ? obj.ASI_CRM_Outlet_Channel_Type__c:'')))
                    
                    segmentMappingMap.put(''+(obj.ASI_CRM_New_Channel__c!=NULL ? obj.ASI_CRM_New_Channel__c:null)
                                          +(obj.ASI_CRM_Energy__c!=''&&obj.ASI_CRM_Energy__c!=NULL ? obj.ASI_CRM_Energy__c:'')
                                          +(obj.ASI_CRM_Hostess__c!=''&&obj.ASI_CRM_Hostess__c!=NULL ? 'TRUE':'FALSE')
                                          +(obj.ASI_CRM_Outlet_Type__c!=''&&obj.ASI_CRM_Outlet_Type__c!=NULL ? obj.ASI_CRM_Outlet_Type__c:'')
                                          +(obj.ASI_CRM_Outlet_Channel_Type__c!=''&&obj.ASI_CRM_Outlet_Channel_Type__c!=NULL ? obj.ASI_CRM_Outlet_Channel_Type__c:''),obj);
                
            }//end for
        }
        
        if(cusList.size() > 0)
        {
            for(ASI_CRM_AccountsAdditionalField__c obj: cusList)
            {
                String errMsgCN = '请输入 ';
                String errMsgEG = 'Please input ';
                Boolean hasError = false;
                if(newChannelMap3.containsKey(obj.ASI_CRM_CN_NewChannel__c))
                {
                    if(newChannelMap3.get(obj.ASI_CRM_CN_NewChannel__c).Name == 'Bar'
                       ||newChannelMap3.get(obj.ASI_CRM_CN_NewChannel__c).Name == 'Nightclub')
                    {
                        if(newChannelMap3.get(obj.ASI_CRM_CN_NewChannel__c).Name == 'Bar'
                           &&(obj.ASI_CRM_CN_Energy__c == null
                              ||obj.ASI_CRM_CN_Energy__c == ''))
                        {
                            hasError=true;
                            errMsgCN+='动感, ';
                            errMsgEG+='Energy, ';
                        }
                        if(obj.ASI_CRM_CN_Size_sqm__c == null
                           ||obj.ASI_CRM_CN_Size_sqm__c == '')
                        {
                            hasError=true;
                            errMsgCN+='面积（平方米）, ';
                            errMsgEG+='Size (sqm), '; 
                        }
                        if(obj.ASI_CRM_CN_IS_Volume__c == null
                                ||obj.ASI_CRM_CN_IS_Volume__c == '')
                        {
                            hasError=true;
                            errMsgCN+='烈酒份额%, ';
                            errMsgEG+='IS Volume %, ';
                        }
                        /*if(newChannelMap3.get(obj.ASI_CRM_CN_NewChannel__c).Name == 'Nightclub'
                           &&obj.ASI_CRM_CN_Sofa_Table_Price__c == null)
                        {
                            hasError=true;
                            errMsgCN+='卡座低消, ';
                            errMsgEG+='Sofa Table Price, ';
                        }
                        if(obj.ASI_CRM_CN_Occupancy_Rate__c == null
                                ||obj.ASI_CRM_CN_Occupancy_Rate__c == '')
                        {
                            hasError=true;
                            errMsgCN+='上座率, ';
                            errMsgEG+='Occupancy Rate, ';
                        }
                        if(newChannelMap3.get(obj.ASI_CRM_CN_NewChannel__c).Name == 'Bar'
                           &&obj.ASI_CRM_CN_Beer_Price__c == null)
                        {
                            hasError=true;
                            errMsgCN+='啤酒价格, ';
                            errMsgEG+='Beer Price, ';
                        }
                        if(obj.ASI_CRM_SG_Outlet_Capacity__c == null
                           ||obj.ASI_CRM_SG_Outlet_Capacity__c == '')
                        {
                            hasError=true;
                            errMsgCN+='容纳人数, ';
                            errMsgEG+='Outlet Capacity, ';
                        }*/ //coming soon on Oct
                    }
                    else if(newChannelMap3.get(obj.ASI_CRM_CN_NewChannel__c).Name == 'KTV'
                            ||newChannelMap3.get(obj.ASI_CRM_CN_NewChannel__c).Name == 'FKTV')
                    {
                        if(obj.ASI_CRM_CN_IS_Volume__c == null
                                ||obj.ASI_CRM_CN_IS_Volume__c == '')
                        {
                            hasError=true;
                            errMsgCN+='烈酒份额%, ';
                            errMsgEG+='IS Volume %, ';
                        }
                        /*if(obj.ASI_CRM_CN_Occupancy_Rate__c == null
                                ||obj.ASI_CRM_CN_Occupancy_Rate__c == '')
                        {
                            hasError=true;
                            errMsgCN+='上座率, ';
                            errMsgEG+='Occupancy Rate, ';
                        }
                        if(obj.ASI_CRM_CN_No_of_Room__c == null)
                        {
                            hasError=true;
                            errMsgCN+='No. of Room, ';
                            errMsgEG+='No. of Room, ';
                        }
                        if(obj.ASI_CRM_CN_Room_Price__c == null)
                        {
                            hasError=true;
                            errMsgCN+='包房低消, ';
                            errMsgEG+='Room Price, '; 
                        }
                        if(newChannelMap3.get(obj.ASI_CRM_CN_NewChannel__c).Name == 'KTV'
                           &&obj.ASI_CRM_CN_Service_Tips_Price__c == null)
                        {
                            hasError=true;
                            errMsgCN+='小费, ';
                            errMsgEG+='Service Tips Price, ';
                        }*/ //coming soon on OCt
                    }
                    else if(newChannelMap3.get(obj.ASI_CRM_CN_NewChannel__c).Name == 'Restaurant')
                    {
                        if(obj.ASI_CRM_CN_Type_of_Restaurant__c == null
                           ||obj.ASI_CRM_CN_Type_of_Restaurant__c == '')
                        {
                            hasError=true;
                            errMsgCN+='餐厅类型, ';
                            errMsgEG+='Type of Restaurant, ';
                        }
                        /*if(obj.ASI_CRM_CN_Occupancy_Rate__c == null
                                ||obj.ASI_CRM_CN_Occupancy_Rate__c == '')
                        {
                            hasError=true;
                            errMsgCN+='上座率, ';
                            errMsgEG+='Occupancy Rate, ';
                        }
                        if(obj.ASI_CRM_CN_Spending_per_head__c == null)
                        {
                            hasError=true;
                            errMsgCN+='人均消费, ';
                            errMsgEG+='Spending per Head, ';
                        }*/ //coming soon on Oct
                    }
                    else if(newChannelMap3.get(obj.ASI_CRM_CN_NewChannel__c).Name == 'Hotel')
                    {
                        if(obj.ASI_CRM_CN_IS_Volume__c == null
                                ||obj.ASI_CRM_CN_IS_Volume__c == '')
                        {
                            hasError=true;
                            errMsgCN+='烈酒份额%, ';
                            errMsgEG+='IS Volume %, ';
                        }
                        if(obj.ASI_CRM_CN_Brand2__c == null
                           ||obj.ASI_CRM_CN_Brand2__c == '')
                        {
                            hasError=true;
                            errMsgCN+='品牌, ';
                            errMsgEG+='Brand, ';
                        }
                        if(obj.ASI_CRM_CN_Outlet_Channel_type__c == null
                                ||obj.ASI_CRM_CN_Outlet_Channel_type__c == '')
                        {
                            hasError=true;
                            errMsgCN+='附带店家类型, ';
                            errMsgEG+='Outlet Channel Type, ';
                        }
                        /*if(obj.ASI_CRM_CN_No_of_Room__c == null)
                        {
                            hasError=true;
                            errMsgCN+='No. of Room, ';
                            errMsgEG+='No. of Room, ';
                        }
                        if(obj.ASI_CRM_CN_Guest_room_price__c == null)
                        {
                            hasError=true;
                            errMsgCN+='客房最低价格, ';
                            errMsgEG+='Guest Room Price, ';
                        }
                        if(obj.ASI_CRM_CN_Number_of_Stars__c == null
                                ||obj.ASI_CRM_CN_Number_of_Stars__c == '')
                        {
                            hasError=true;
                            errMsgCN+='星级, ';
                            errMsgEG+='Number of Stars, ';
                        }*/ //coming soon on Oct
                    }
                }
                if(hasError)
                {
                    errMsgCN = errMsgCN.substring(0, errMsgCN.length()-2);
                    errMsgEG = errMsgEG.substring(0, errMsgEG.length()-2);
                    if(USerInfo.getLanguage()=='zh_CN'){
                        if(!test.isRunningTest()){
                        	obj.addError(obj.Name+': '+errMsgCN);
                        }
                    }else{
                        if(!test.isRunningTest()){
                        	obj.addError(obj.Name+': '+errMsgEG);
                        }
                    }
                    break;
                }
                String key = (obj.ASI_CRM_CN_NewChannel__c!=NULL ? obj.ASI_CRM_CN_NewChannel__c:null)
                    +(obj.ASI_CRM_CN_Energy__c!=''&&obj.ASI_CRM_CN_Energy__c!=NULL ? obj.ASI_CRM_CN_Energy__c:'')
                    +(obj.ASI_CRM_CN_Hostesses__c ? 'TRUE':'FALSE')
                    +(obj.ASI_CRM_CN_OutletType__c!=''&&obj.ASI_CRM_CN_OutletType__c!=NULL ? obj.ASI_CRM_CN_OutletType__c:'')
                    +(obj.ASI_CRM_CN_Outlet_Channel_type__c!=''&&obj.ASI_CRM_CN_Outlet_Channel_type__c!=NULL ? obj.ASI_CRM_CN_Outlet_Channel_type__c:'');
                
                if(segmentMappingMap.containsKey(key))
                    obj.ASI_CRM_CN_PROS_Segmentation__c = segmentMappingMap.get(key).ASI_CRM_PROS_Segmentation__c;
                else
                    obj.ASI_CRM_CN_PROS_Segmentation__c = null;
            }//end for*/
        }
    }//end method
    //20160613, Leo @Elufa
}