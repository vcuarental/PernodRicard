/*********************************************************************************
 * Name:ASI_TnE_ClaimsDetailGenAccountNo
 * Description: Generate account number for Claims Detail
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 4/9/2015         Laputa: Hank            Created
*********************************************************************************/

public without sharing class ASI_TnE_ClaimsDetailGenAccountNo extends ASI_TnE_TriggerAbstract {

    public ASI_TnE_ClaimsDetailGenAccountNo() {
        super('ASI_TnE_ClaimsDetailGenAccountNo');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        system.debug('**executeTriggerAction Limits***' + System.Limits.getQueries());
        
        List<ASI_TnE_ClaimDetail__c> detailList = (List<ASI_TnE_ClaimDetail__c>)sObjList;
        Set<Id> headerIdSet = new Set<Id>();
        Set<Id> BUIdSet = new Set<Id>();
        Set<Id> ACIdSet = new Set<Id>();
        Set<Id> typeIdSet = new Set<Id>();
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> subBrandSet = new Set<Id>();
        Set<Id> poIdSet = new Set<Id>();
        Set<String> mktSet = new Set<String>();
        if(oldMap == null){
            for(ASI_TnE_ClaimDetail__c detail:detailList){
                headerIdSet.add(detail.ASI_TnE_ClaimHeader__c);
                if(detail.ASI_TnE_BU__c != null){
                    BUIdSet.add(detail.ASI_TnE_BU__c);
                }else if(detail.ASI_TnE_Market_Charged_To__c != null){
                    mktSet.add(detail.ASI_TnE_Market_Charged_To__c);
                }else if(Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_TnE_TH') && detail.ASI_TnE_MFM_PO__c != null){
                    poIdSet.add(detail.ASI_TnE_MFM_PO__c);
                }
                    
                if(detail.ASI_TnE_Charge_To_Acc__c != null){
                    accIdSet.add(detail.ASI_TnE_Charge_To_Acc__c);
                }
                        
                if(detail.ASI_TnE_SubBrand__c != null){
                    subBrandSet.add(detail.ASI_TnE_SubBrand__c);
                }
                    
                if(detail.ASI_TnE_A_C_Code__c != null){
                    ACIdSet.add(detail.ASI_TnE_A_C_Code__c);
                }
                
                typeIdSet.add(detail.ASI_TnE_Expense_Classification__c);       
            }
        }else{
            Map<Id, ASI_TnE_ClaimDetail__c> detailOldMap = (Map<Id, ASI_TnE_ClaimDetail__c>)oldMap;
            for(ASI_TnE_ClaimDetail__c detail:detailList){
                if(detail.ASI_TnE_Account_Number__c != detailOldMap.get(detail.Id).ASI_TnE_Account_Number__c ||
                        detail.ASI_TnE_BU__c != detailOldMap.get(detail.Id).ASI_TnE_BU__c ||
                        detail.ASI_TnE_A_C_Code__c != detailOldMap.get(detail.Id).ASI_TnE_A_C_Code__c ||
                        detail.ASI_TnE_Market_Charged_To__c != detailOldMap.get(detail.Id).ASI_TnE_Market_Charged_To__c ||
                        detail.ASI_TnE_Expense_Classification__c != detailOldMap.get(detail.Id).ASI_TnE_Expense_Classification__c ||
                        detail.ASI_TnE_SubBrand__c != detailOldMap.get(detail.Id).ASI_TnE_SubBrand__c ||
                        detail.ASI_TnE_Charge_To_Acc__c != detailOldMap.get(detail.Id).ASI_TnE_Charge_To_Acc__c ||
                        (Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_TnE_TH') && detail.ASI_TnE_MFM_PO__c != detailOldMap.get(detail.Id).ASI_TnE_MFM_PO__c)){
                    headerIdSet.add(detail.ASI_TnE_ClaimHeader__c);
                    if(detail.ASI_TnE_BU__c != null){
                        BUIdSet.add(detail.ASI_TnE_BU__c);
                    }else if(detail.ASI_TnE_Market_Charged_To__c != null){
                        mktSet.add(detail.ASI_TnE_Market_Charged_To__c);
                    }else if(Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_TnE_TH') && detail.ASI_TnE_MFM_PO__c != null){
                        poIdSet.add(detail.ASI_TnE_MFM_PO__c);
                    }
                    
                    if(detail.ASI_TnE_Charge_To_Acc__c != null){
                        accIdSet.add(detail.ASI_TnE_Charge_To_Acc__c);
                    }
                    
                    
                    if(detail.ASI_TnE_SubBrand__c != null){
                        subBrandSet.add(detail.ASI_TnE_SubBrand__c);
                    }
                    
                    if(detail.ASI_TnE_A_C_Code__c != null){
                        ACIdSet.add(detail.ASI_TnE_A_C_Code__c);
                    }
                    typeIdSet.add(detail.ASI_TnE_Expense_Classification__c);      
                }
            }
        }
        
        Map<Id, ASI_TnE_ClaimHeader__c> headerMap = new Map<Id, ASI_TnE_ClaimHeader__c>([Select OwnerId, ASI_TnE_Payee_Employee__c From ASI_TnE_ClaimHeader__c Where Id In :headerIdSet]);
        for(ASI_TnE_ClaimHeader__c header: headerMap.values()){
            userIdSet.add(header.ownerId);
            if(header.ASI_TnE_Payee_Employee__c != null){
                userIdSet.add(header.ASI_TnE_Payee_Employee__c); 
            }
        }
        userIdSet.add(UserInfo.getUserId());
        Map<Id, User> userMap = new Map<Id, User>([Select Id, ASI_TnE_Department_Code__c From User Where Id In :userIdSet]);
        Map<Id, ASI_MFM_BU__c> BUMap = new Map<Id, ASI_MFM_BU__c>([Select Id, ASI_MFM_BU_Code__c From ASI_MFM_BU__c Where Id In :BUIdSet]);
        Map<String, String> mktMap = new Map<String, String>();
        for(ASI_TnE_Employee_Code_Mapping__c mkt:[Select Id, ASI_TnE_Employee_Name__c, ASI_TnE_Market__c, ASI_TnE_Department_Code__c From ASI_TnE_Employee_Code_Mapping__c Where ASI_TnE_Employee_Name__c In :userIdSet And ASI_TnE_Market__c In :mktSet]){
            mktMap.put(mkt.ASI_TnE_Employee_Name__c + mkt.ASI_TnE_Market__c, mkt.ASI_TnE_Department_Code__c);
        }
        Map<Id, String> subBrandMap = new Map<Id, String>();
        for(ASI_MFM_Sub_brand__c sub:[Select Id, ASI_MFM_Sub_brand_Code__c From ASI_MFM_Sub_brand__c Where Id In :subBrandSet]){
            subBrandMap.put(sub.Id, sub.ASI_MFM_Sub_brand_Code__c);
            system.debug('Check 1: ' + sub.ASI_MFM_Sub_brand_Code__c);
        }
        Map<Id, ASI_MFM_A_C_Code__c> ACMap = new Map<Id, ASI_MFM_A_C_Code__c>([Select Id, ASI_MFM_A_C_Code__c From ASI_MFM_A_C_Code__c Where Id In :ACIdSet]);
        Map<Id, ASI_JP_TnE_Expense_Classification__c> typeMap = new Map<Id, ASI_JP_TnE_Expense_Classification__c>([Select Id, ASI_TnE_DM_BS__c, ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c From ASI_JP_TnE_Expense_Classification__c Where Id In :typeIdSet]);
        System.debug('------ typeMap ------ : ' + typeMap);        
        Map<Id, Account> accMap = new Map<Id, Account>([Select Id, ASI_HK_CRM_Address__c From Account Where Id In :accIdSet]);
        Map<Id, ASI_MFM_PO__c> poMap = new Map<Id,ASI_MFM_PO__c>();
        if(poIdSet.size() > 0){
            poMap = new Map<Id, ASI_MFM_PO__c>([Select Id, (Select Id, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_Customer_Name__r.ASI_MFM_Site_Code__c, ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c From PO_Line_Items__r Limit 1) From ASI_MFM_PO__c Where Id In :poIdSet]);
        }
        if(oldMap == null){
            for(ASI_TnE_ClaimDetail__c detail:detailList){
                Id userId = UserInfo.getUserId();
                if(headerMap.get(detail.ASI_TnE_ClaimHeader__c) != null){
                    userId = headerMap.get(detail.ASI_TnE_ClaimHeader__c).ASI_TnE_Payee_Employee__c == null?headerMap.get(detail.ASI_TnE_ClaimHeader__c).OwnerId:headerMap.get(detail.ASI_TnE_ClaimHeader__c).ASI_TnE_Payee_Employee__c;
                }
                if(!Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_TnE_HK') && !Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_TnE_TW')){
                    if(typeMap.get(detail.ASI_TnE_Expense_Classification__c) == null || typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_TnE_DM_BS__c == null){
                        if(detail.ASI_TnE_BU__c != null){
                            detail.ASI_TnE_Account_Number__c = BUMap.get(detail.ASI_TnE_BU__c).ASI_MFM_BU_Code__c;
                        }else if(detail.ASI_TnE_Charge_To_Acc__c != null){
                            detail.ASI_TnE_Account_Number__c = accMap.get(detail.ASI_TnE_Charge_To_Acc__c).ASI_HK_CRM_Address__c;
                        }else if(detail.ASI_TnE_Market_Charged_To__c != null || detail.ASI_TnE_SubBrand__c != null){
                            detail.ASI_TnE_Account_Number__c = userMap.get(userId).ASI_TnE_Department_Code__c;
                            if(detail.ASI_TnE_Market_Charged_To__c != null){
                                detail.ASI_TnE_Account_Number__c = (detail.ASI_TnE_Account_Number__c == null?'':(detail.ASI_TnE_Account_Number__c).subString(0,3)) + (mktMap.get(userId + detail.ASI_TnE_Market_Charged_To__c) == null?'':mktMap.get(userId + detail.ASI_TnE_Market_Charged_To__c));
                            }
                            if(detail.ASI_TnE_SubBrand__c != null && subBrandMap.get(detail.ASI_TnE_SubBrand__c) != null && detail.ASI_TnE_Account_Number__c != null){
                                detail.ASI_TnE_Account_Number__c = (detail.ASI_TnE_Account_Number__c).subString(0,4) + 'P' + subBrandMap.get(detail.ASI_TnE_SubBrand__c) + (detail.ASI_TnE_Account_Number__c).subString(8,10);    
                            }
                        }else if(Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_TnE_TH') && detail.ASI_TnE_MFM_PO__c != null){
                            detail.ASI_TnE_Account_Number__c = '5581P';
                            ASI_MFM_PO_Line_Item__c item = poMap.get(detail.ASI_TnE_MFM_PO__c).PO_Line_Items__r[0];
                            detail.ASI_TnE_Account_Number__c += item.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c + item.ASI_MFM_Customer_Name__r.ASI_MFM_Site_Code__c;
                        }else{
                            detail.ASI_TnE_Account_Number__c = userMap.get(userId).ASI_TnE_Department_Code__c;
                        }
                    }else{
                        detail.ASI_TnE_Account_Number__c = userMap.get(userId).ASI_TnE_Department_Code__c;
                        if(typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_TnE_DM_BS__c != null && detail.ASI_TnE_Account_Number__c != null){
                            detail.ASI_TnE_Account_Number__c = (typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_TnE_DM_BS__c).subString(0,8) + (detail.ASI_TnE_Account_Number__c).subString(8,10);
                        }
                        if(detail.ASI_TnE_Market_Charged_To__c != null && detail.ASI_TnE_Account_Number__c != null){
                            detail.ASI_TnE_Account_Number__c = (detail.ASI_TnE_Account_Number__c).subString(0,8) + (mktMap.get(userId + detail.ASI_TnE_Market_Charged_To__c) == null?'':(mktMap.get(userId + detail.ASI_TnE_Market_Charged_To__c)).subString(5,7));
                        } 
                    }    
                
                    if(detail.ASI_TnE_A_C_Code__c != null && detail.ASI_TnE_Account_Number__c != null){
                        detail.ASI_TnE_Account_Number__c += '.' + ACMap.get(detail.ASI_TnE_A_C_Code__c).ASI_MFM_A_C_Code__c;
                    }else if(Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_TnE_TH') && detail.ASI_TnE_MFM_PO__c != null){
                        ASI_MFM_PO_Line_Item__c item = poMap.get(detail.ASI_TnE_MFM_PO__c).PO_Line_Items__r[0];
                        detail.ASI_TnE_Account_Number__c += '.' + item.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c;
                    }else if(typeMap.get(detail.ASI_TnE_Expense_Classification__c) != null){
                        detail.ASI_TnE_Account_Number__c += '.' + typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c;
                    }
                }else{
                    if(detail.ASI_TnE_BU__c != null){
                        detail.ASI_TnE_Account_Number__c = BUMap.get(detail.ASI_TnE_BU__c).ASI_MFM_BU_Code__c;
                        if(detail.ASI_TnE_A_C_Code__c != null && detail.ASI_TnE_Account_Number__c != null){
                            detail.ASI_TnE_Account_Number__c += '.' + ACMap.get(detail.ASI_TnE_A_C_Code__c).ASI_MFM_A_C_Code__c;
                        }else if(typeMap.get(detail.ASI_TnE_Expense_Classification__c) != null){
                            detail.ASI_TnE_Account_Number__c += '.' + typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c;
                        }
                    }else if(detail.ASI_TnE_Charge_To_Acc__c != null && accMap.get(detail.ASI_TnE_Charge_To_Acc__c).ASI_HK_CRM_Address__c == 'AFFILIATE' && userMap.get(userId).ASI_TnE_Department_Code__c != null){
                        detail.ASI_TnE_Account_Number__c = (userMap.get(userId).ASI_TnE_Department_Code__c).subString(0,3) + '9000001.1270.060000';
                    }else if(detail.ASI_TnE_Charge_To_Acc__c != null && accMap.get(detail.ASI_TnE_Charge_To_Acc__c).ASI_HK_CRM_Address__c != 'AFFILIATE' && userMap.get(userId).ASI_TnE_Department_Code__c != null){
                        if(typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_TnE_DM_BS__c != null && accMap.get(detail.ASI_TnE_Charge_To_Acc__c).ASI_HK_CRM_Address__c != null){
                            detail.ASI_TnE_Account_Number__c = (accMap.get(detail.ASI_TnE_Charge_To_Acc__c).ASI_HK_CRM_Address__c).subString(0,3) + typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_TnE_DM_BS__c;
                            if(detail.ASI_TnE_A_C_Code__c != null && detail.ASI_TnE_Account_Number__c != null){
                                detail.ASI_TnE_Account_Number__c += '.' + ACMap.get(detail.ASI_TnE_A_C_Code__c).ASI_MFM_A_C_Code__c;
                            }else if(typeMap.get(detail.ASI_TnE_Expense_Classification__c) != null){
                                detail.ASI_TnE_Account_Number__c += '.' + typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c;
                            }
                        }else{
                            detail.ASI_TnE_Account_Number__c = accMap.get(detail.ASI_TnE_Charge_To_Acc__c).ASI_HK_CRM_Address__c;
                            if(detail.ASI_TnE_A_C_Code__c != null && detail.ASI_TnE_Account_Number__c != null){
                                detail.ASI_TnE_Account_Number__c += '.' + ACMap.get(detail.ASI_TnE_A_C_Code__c).ASI_MFM_A_C_Code__c;
                            }else if(typeMap.get(detail.ASI_TnE_Expense_Classification__c) != null){
                                detail.ASI_TnE_Account_Number__c += '.' + typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c;
                            }
                        }
                    }else if(typeMap.get(detail.ASI_TnE_Expense_Classification__c) != null && typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_TnE_DM_BS__c != null){
                        detail.ASI_TnE_Account_Number__c = (userMap.get(userId).ASI_TnE_Department_Code__c).subString(0,3) + typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_TnE_DM_BS__c;
                        if(detail.ASI_TnE_A_C_Code__c != null && detail.ASI_TnE_Account_Number__c != null){
                            detail.ASI_TnE_Account_Number__c += '.' + ACMap.get(detail.ASI_TnE_A_C_Code__c).ASI_MFM_A_C_Code__c;
                        }else if(typeMap.get(detail.ASI_TnE_Expense_Classification__c) != null){
                            detail.ASI_TnE_Account_Number__c += '.' + typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c;
                        }
                    }else{
                        detail.ASI_TnE_Account_Number__c = userMap.get(userId).ASI_TnE_Department_Code__c;
                        if(detail.ASI_TnE_A_C_Code__c != null && detail.ASI_TnE_Account_Number__c != null){
                            detail.ASI_TnE_Account_Number__c += '.' + ACMap.get(detail.ASI_TnE_A_C_Code__c).ASI_MFM_A_C_Code__c;
                        }else if(typeMap.get(detail.ASI_TnE_Expense_Classification__c) != null){
                            detail.ASI_TnE_Account_Number__c += '.' + typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c;
                        }
                    }
                }
            }
        }else{
            Map<Id, ASI_TnE_ClaimDetail__c> detailOldMap = (Map<Id, ASI_TnE_ClaimDetail__c>)oldMap;
            for(ASI_TnE_ClaimDetail__c detail:detailList){
                if(detail.ASI_TnE_Account_Number__c != detailOldMap.get(detail.Id).ASI_TnE_Account_Number__c ||
                        detail.ASI_TnE_BU__c != detailOldMap.get(detail.Id).ASI_TnE_BU__c ||
                        detail.ASI_TnE_A_C_Code__c != detailOldMap.get(detail.Id).ASI_TnE_A_C_Code__c ||
                        detail.ASI_TnE_Market_Charged_To__c != detailOldMap.get(detail.Id).ASI_TnE_Market_Charged_To__c ||
                        detail.ASI_TnE_Expense_Classification__c != detailOldMap.get(detail.Id).ASI_TnE_Expense_Classification__c ||
                        detail.ASI_TnE_SubBrand__c != detailOldMap.get(detail.Id).ASI_TnE_SubBrand__c ||
                        detail.ASI_TnE_Charge_To_Acc__c != detailOldMap.get(detail.Id).ASI_TnE_Charge_To_Acc__c ||
                        (Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_TnE_TH') && detail.ASI_TnE_MFM_PO__c != detailOldMap.get(detail.Id).ASI_TnE_MFM_PO__c)){
                    Id userId = headerMap.get(detail.ASI_TnE_ClaimHeader__c).ASI_TnE_Payee_Employee__c == null?headerMap.get(detail.ASI_TnE_ClaimHeader__c).OwnerId:headerMap.get(detail.ASI_TnE_ClaimHeader__c).ASI_TnE_Payee_Employee__c;
                    if(!Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_TnE_HK') && !Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_TnE_TW')){
                        if(typeMap.get(detail.ASI_TnE_Expense_Classification__c) == null || typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_TnE_DM_BS__c == null){
                            if(detail.ASI_TnE_BU__c != null){
                                detail.ASI_TnE_Account_Number__c = BUMap.get(detail.ASI_TnE_BU__c).ASI_MFM_BU_Code__c;
                            }else if(detail.ASI_TnE_Charge_To_Acc__c != null){
                                detail.ASI_TnE_Account_Number__c = accMap.get(detail.ASI_TnE_Charge_To_Acc__c).ASI_HK_CRM_Address__c;
                            }else if(detail.ASI_TnE_Market_Charged_To__c != null || detail.ASI_TnE_SubBrand__c != null){
                                detail.ASI_TnE_Account_Number__c = userMap.get(userId).ASI_TnE_Department_Code__c;
                                if(detail.ASI_TnE_Market_Charged_To__c != null){
                                    detail.ASI_TnE_Account_Number__c = (detail.ASI_TnE_Account_Number__c == null?'':(detail.ASI_TnE_Account_Number__c).subString(0,3)) + (mktMap.get(userId + detail.ASI_TnE_Market_Charged_To__c) == null?'':mktMap.get(userId + detail.ASI_TnE_Market_Charged_To__c));
                                }
                                if(detail.ASI_TnE_SubBrand__c != null && subBrandMap.get(detail.ASI_TnE_SubBrand__c) != null && detail.ASI_TnE_Account_Number__c != null){
                                    detail.ASI_TnE_Account_Number__c = (detail.ASI_TnE_Account_Number__c).subString(0,4) + 'P' + subBrandMap.get(detail.ASI_TnE_SubBrand__c) + (detail.ASI_TnE_Account_Number__c).subString(8,10);    
                                }
                            }else if(Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_TnE_TH') && detail.ASI_TnE_MFM_PO__c != null){
                                detail.ASI_TnE_Account_Number__c = '5581P';
                                ASI_MFM_PO_Line_Item__c item = poMap.get(detail.ASI_TnE_MFM_PO__c).PO_Line_Items__r[0];
                                detail.ASI_TnE_Account_Number__c += item.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c + item.ASI_MFM_Customer_Name__r.ASI_MFM_Site_Code__c;
                            }else{
                                detail.ASI_TnE_Account_Number__c = userMap.get(userId).ASI_TnE_Department_Code__c;
                            }
                        }else{
                            detail.ASI_TnE_Account_Number__c = userMap.get(userId).ASI_TnE_Department_Code__c;
                            if(typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_TnE_DM_BS__c != null && detail.ASI_TnE_Account_Number__c != null){
                                detail.ASI_TnE_Account_Number__c = (typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_TnE_DM_BS__c).subString(0,8) + (detail.ASI_TnE_Account_Number__c).subString(8,10);
                            }
                            if(detail.ASI_TnE_Market_Charged_To__c != null && detail.ASI_TnE_Account_Number__c != null){
                                detail.ASI_TnE_Account_Number__c = (detail.ASI_TnE_Account_Number__c).subString(0,8) + (mktMap.get(userId + detail.ASI_TnE_Market_Charged_To__c) == null?'':(mktMap.get(userId + detail.ASI_TnE_Market_Charged_To__c)).subString(5,7));
                            } 
                        }    
                
                        if(detail.ASI_TnE_A_C_Code__c != null && detail.ASI_TnE_Account_Number__c != null){
                            detail.ASI_TnE_Account_Number__c += '.' + ACMap.get(detail.ASI_TnE_A_C_Code__c).ASI_MFM_A_C_Code__c;
                        }else if(Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_TnE_TH') && detail.ASI_TnE_MFM_PO__c != null){
                            ASI_MFM_PO_Line_Item__c item = poMap.get(detail.ASI_TnE_MFM_PO__c).PO_Line_Items__r[0];
                            detail.ASI_TnE_Account_Number__c += '.' + item.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c;
                        }else if(typeMap.get(detail.ASI_TnE_Expense_Classification__c) != null){
                            detail.ASI_TnE_Account_Number__c += '.' + typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c;
                        }
                    }else{
                        if(detail.ASI_TnE_BU__c != null){
                            detail.ASI_TnE_Account_Number__c = BUMap.get(detail.ASI_TnE_BU__c).ASI_MFM_BU_Code__c;
                            if(detail.ASI_TnE_A_C_Code__c != null && detail.ASI_TnE_Account_Number__c != null){
                                detail.ASI_TnE_Account_Number__c += '.' + ACMap.get(detail.ASI_TnE_A_C_Code__c).ASI_MFM_A_C_Code__c;
                            }else if(typeMap.get(detail.ASI_TnE_Expense_Classification__c) != null){
                                detail.ASI_TnE_Account_Number__c += '.' + typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c;
                            }
                        }else if(detail.ASI_TnE_Charge_To_Acc__c != null && accMap.get(detail.ASI_TnE_Charge_To_Acc__c).ASI_HK_CRM_Address__c == 'AFFILIATE' && userMap.get(userId).ASI_TnE_Department_Code__c != null){
                            detail.ASI_TnE_Account_Number__c = (userMap.get(userId).ASI_TnE_Department_Code__c).subString(0,3) + '9000001.1270.060000';
                        }else if(detail.ASI_TnE_Charge_To_Acc__c != null && accMap.get(detail.ASI_TnE_Charge_To_Acc__c).ASI_HK_CRM_Address__c != 'AFFILIATE' && userMap.get(userId).ASI_TnE_Department_Code__c != null){
                            if(typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_TnE_DM_BS__c != null && accMap.get(detail.ASI_TnE_Charge_To_Acc__c).ASI_HK_CRM_Address__c != null){
                                detail.ASI_TnE_Account_Number__c = (accMap.get(detail.ASI_TnE_Charge_To_Acc__c).ASI_HK_CRM_Address__c).subString(0,3) + typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_TnE_DM_BS__c;
                                if(detail.ASI_TnE_A_C_Code__c != null && detail.ASI_TnE_Account_Number__c != null){
                                    detail.ASI_TnE_Account_Number__c += '.' + ACMap.get(detail.ASI_TnE_A_C_Code__c).ASI_MFM_A_C_Code__c;
                                }else if(typeMap.get(detail.ASI_TnE_Expense_Classification__c) != null){
                                    detail.ASI_TnE_Account_Number__c += '.' + typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c;
                                }
                            }else{
                                detail.ASI_TnE_Account_Number__c = accMap.get(detail.ASI_TnE_Charge_To_Acc__c).ASI_HK_CRM_Address__c;
                                if(detail.ASI_TnE_A_C_Code__c != null && detail.ASI_TnE_Account_Number__c != null){
                                    detail.ASI_TnE_Account_Number__c += '.' + ACMap.get(detail.ASI_TnE_A_C_Code__c).ASI_MFM_A_C_Code__c;
                                }else if(typeMap.get(detail.ASI_TnE_Expense_Classification__c) != null){
                                    detail.ASI_TnE_Account_Number__c += '.' + typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c;
                                }
                            }
                        }else if(typeMap.get(detail.ASI_TnE_Expense_Classification__c) != null && typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_TnE_DM_BS__c != null){
                            detail.ASI_TnE_Account_Number__c = (userMap.get(userId).ASI_TnE_Department_Code__c).subString(0,3) + typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_TnE_DM_BS__c;
                            if(detail.ASI_TnE_A_C_Code__c != null && detail.ASI_TnE_Account_Number__c != null){
                                detail.ASI_TnE_Account_Number__c += '.' + ACMap.get(detail.ASI_TnE_A_C_Code__c).ASI_MFM_A_C_Code__c;
                            }else if(typeMap.get(detail.ASI_TnE_Expense_Classification__c) != null){
                                detail.ASI_TnE_Account_Number__c += '.' + typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c;
                            }
                        }else{
                            detail.ASI_TnE_Account_Number__c = userMap.get(userId).ASI_TnE_Department_Code__c;
                            if(detail.ASI_TnE_A_C_Code__c != null && detail.ASI_TnE_Account_Number__c != null){
                                detail.ASI_TnE_Account_Number__c += '.' + ACMap.get(detail.ASI_TnE_A_C_Code__c).ASI_MFM_A_C_Code__c;
                            }else if(typeMap.get(detail.ASI_TnE_Expense_Classification__c) != null){
                                detail.ASI_TnE_Account_Number__c += '.' + typeMap.get(detail.ASI_TnE_Expense_Classification__c).ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c;
                            }
                        }
                    }
                }
            }
        }
    }
}