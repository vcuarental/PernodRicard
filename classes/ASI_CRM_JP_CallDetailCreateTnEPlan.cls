/*********************************************************************************
 * Name:ASI_CRM_JP_CallDetailCreateTnEPlan
 * Description: Create TnE Call Plan when status changes to 'Achieved' 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 27/11/2014       Laputa: Hank          Created
*********************************************************************************/

public with sharing class ASI_CRM_JP_CallDetailCreateTnEPlan extends ASI_CRM_JP_TriggerAbstract {

    public ASI_CRM_JP_CallDetailCreateTnEPlan() {
        super('ASI_CRM_JP_CallDetailCreateTnEPlan');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_CRM_Call_Detail__c> detailList = (List<ASI_CRM_Call_Detail__c>)sObjList;
        Set<Id> detailIdSet = new Set<Id>();
        Set<String> postalSet = new Set<String>();
        Map<String, Object> taxRoutingTbl;
        Set<Id> userIdSet = new Set<Id>();
        
        Map<ID, ASI_CRM_Call_Detail__c> oldDetailMap= new Map<ID, ASI_CRM_Call_Detail__c>();
        if (oldMap != null) {
            oldDetailMap = (Map<ID, ASI_CRM_Call_Detail__c>) oldMap;
        }
        if (oldMap == null) {
        }
        else {
            for (ASI_CRM_Call_Detail__c detail: detailList) {
                //store the detail id to calc TnE
                if (detail.ASI_CRM_Status__c == 'Achieved' && detail.ASI_CRM_Payment_Option__c != 'Invoice') {
                    detail.ASI_CRM_Sys_Call_Plan_TnE__c = detail.ASI_CRM_Call_Plan__c;
                    
                }
                if(detail.ASI_CRM_Status__c == 'Achieved'){
                    detailIdSet.add(detail.id);
                }
                //If Status changes from Achieved to others, clear ASI_CRM_Sys_Call_Plan_TnE__c
                if (oldDetailMap.get(detail.Id).ASI_CRM_Status__c == 'Achieved' && detail.ASI_CRM_Status__c != 'Achieved' ) {
                    detail.ASI_CRM_Sys_Call_Plan_TnE__c = null;
                }
            }
        }
        
        //Get more info from call detail
        Map<Id, ASI_CRM_Call_Detail__c> detailsMap = new Map<Id, ASI_CRM_Call_Detail__c>([Select Id, ASI_CRM_Call_Plan__r.ownerId, ASI_CRM_Total_Number_of_Attendees__c, ASI_CRM_Customer__r.ASI_CRM_Metropolitan__c, ASI_CRM_Customer__r.ASI_CRM_PostalCode__c, ASI_CRM_Call_Detail__c.ASI_CRM_Price_of_SKU1__c, ASI_CRM_Customer__r.ASI_TH_CRM_OutletType__r.ASI_CRM_Class__c, ASI_CRM_Customer__r.ASI_TH_CRM_OutletType__r.ASI_TH_CRM_Code__c,ASI_CRM_Number_of_SKU1_Consumed__c, ASI_CRM_Number_of_SKU2_Consumed__c, ASI_CRM_Number_of_SKU3_Consumed__c, ASI_CRM_Number_of_Attendees_BS__c, ASI_CRM_Number_of_Attendees_Other__c, ASI_CRM_Number_of_PRJ_Sales_Attendees__c, ASI_CRM_Actual_Amount__c, ASI_CRM_Activity_Sub_brand_1__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Description__c, ASI_CRM_Tax_Routing__c From ASI_CRM_Call_Detail__c Where Id In :detailIdSet]);
        for(ASI_CRM_Call_Detail__c d:detailsMap.values()){
            userIdSet.add(d.ASI_CRM_Call_Plan__r.ownerId);
        }
        Map<Id, User> userMap = new Map<Id, User>([Select Id, ASI_JP_TnE_Department_Category_Code__c From User Where Id In :userIdSet]);
        
        for (ASI_CRM_Call_Detail__c detail:detailList) {
            //Calculate TnE when Achieved
            if (detail.ASI_CRM_Status__c == 'Achieved') {
            //Build taxRoutingTbl from custom settings
            if (taxRoutingTbl == null) {
                taxRoutingTbl = new Map<String, Object>();
                for (ASI_CRM_JP_Tax_Routing_Tbl__c tbl:ASI_CRM_JP_Tax_Routing_Tbl__c.getAll().values()) {
                    //String keyString = tbl.ASI_CRM_JP_Brand__c.trim().replaceAll('(\\s+)', '');
                    String keyString = tbl.ASI_CRM_JP_Brand__c;
                    String[] keyList = keyString.split(';');
                    for (String str:keyList) {
                        String key = str + (Integer)tbl.ASI_CRM_JP_Stage__c;
                        if(tbl.ASI_CRM_JP_Type__c == 'Integer'){
                            Integer value = Integer.valueOf(tbl.ASI_CRM_JP_Value__c);
                            taxRoutingTbl.put(key,value);
                            System.debug('Check table: ' + key + ' ' + value);
                        }else if(tbl.ASI_CRM_JP_Type__c == 'Boolean'){
                            Boolean value = (tbl.ASI_CRM_JP_Value__c == 'true');
                            taxRoutingTbl.put(key,value);
                             System.debug('Check table: ' + key + ' ' + value);
                        }else if(tbl.ASI_CRM_JP_Type__c == 'String'){
                            String value = tbl.ASI_CRM_JP_Value__c;
                            taxRoutingTbl.put(key,value);
                            System.debug('Check table: ' + key + ' ' + value);
                        }
                    }   
                }
            }
            
            //Calculate parameters
            Long taxableAmt = ((detail.ASI_CRM_Actual_Taxable_Amount__c == null)?0:detail.ASI_CRM_Actual_Taxable_Amount__c).round(System.RoundingMode.CEILING);
            Long total = ((taxableAmt - ((detail.ASI_CRM_Price_of_SKU1__c == null)?0:detail.ASI_CRM_Price_of_SKU1__c) * ((detail.ASI_CRM_Number_of_SKU1_Consumed__c == null)?0:detail.ASI_CRM_Number_of_SKU1_Consumed__c) - 
                    ((detail.ASI_CRM_Price_of_SKU2__c == null)?0:detail.ASI_CRM_Price_of_SKU2__c) * ((detail.ASI_CRM_Number_of_SKU2_Consumed__c == null)?0:detail.ASI_CRM_Number_of_SKU2_Consumed__c) - 
                    ((detail.ASI_CRM_Price_of_SKU3__c == null)?0:detail.ASI_CRM_Price_of_SKU3__c) * ((detail.ASI_CRM_Number_of_SKU3_Consumed__c == null)?0:detail.ASI_CRM_Number_of_SKU3_Consumed__c)) /
                    (detail.ASI_CRM_Total_Number_of_Attendees__c)).round(System.RoundingMode.CEILING);
            Long numOfBtl = (((detail.ASI_CRM_Number_of_SKU1_Consumed__c == null)?0:detail.ASI_CRM_Number_of_SKU1_Consumed__c ) + 
                            ((detail.ASI_CRM_Number_of_SKU2_Consumed__c == null)?0:detail.ASI_CRM_Number_of_SKU2_Consumed__c) + 
                            ((detail.ASI_CRM_Number_of_SKU3_Consumed__c == null)?0:detail.ASI_CRM_Number_of_SKU3_Consumed__c)).round(System.RoundingMode.CEILING);
            Long ttlPerson = (((detail.ASI_CRM_Number_of_Attendees_BS__c == null)?0:detail.ASI_CRM_Number_of_Attendees_BS__c) + 
                             ((detail.ASI_CRM_Number_of_PRJ_Sales_Attendees__c == null)?0:detail.ASI_CRM_Number_of_PRJ_Sales_Attendees__c)).round(System.RoundingMode.CEILING);
            Long PRJStaff = (((detail.ASI_CRM_Number_of_PRJ_Sales_Attendees__c == null)?0:detail.ASI_CRM_Number_of_PRJ_Sales_Attendees__c)).round(System.RoundingMode.CEILING);
            String brandDescription = detailsMap.get(detail.id).ASI_CRM_Activity_Sub_brand_1__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Description__c;
            
            System.debug('CheckPoint Total:' + total + ' NumofBtl:' + numOfBtl + ' ttlPerson:' + ttlPerson + ' PRFStaff:' + PRJStaff + ' Brand:' +brandDescription + ' isTesting: ' + Test.isRunningTest() + ' plan id: ' + detail.ASI_CRM_Call_Plan__c + ' dohan: ' + detail.ASI_CRM_Dohan__c + ' department code: ' + userMap.get(detailsMap.get(detail.Id).ASI_CRM_Call_Plan__r.ownerId).ASI_JP_TnE_Department_Category_Code__c + ' sub-brand: ' + detail.ASI_CRM_Activity_Sub_brand_1__c);
            
            //For Dohan, PJ, Martell&CR, Others
            if (detail.ASI_CRM_Dohan__c == true || (userMap.get(detailsMap.get(detail.Id).ASI_CRM_Call_Plan__r.ownerId).ASI_JP_TnE_Department_Category_Code__c != '1' && !Test.isRunningTest())){
                if (total <= (Integer)taxRoutingTbl.get('Dohan1')) {
                    System.debug('CheckPoint settins: ' + taxRoutingTbl.get('Dohan1'));
                    detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_PROMOTION);
                } else {
                    //System.debug('CheckPoint settins: ' + taxRoutingTbl.get('Dohan1'));
                    detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_VISIT);
                }
            } else if (brandDescription == PJ) {
                //system.debug('Checkpoint PJ: ' + (Integer)taxRoutingTbl.get(brandDescription + '1'));
                if (total <= (Integer)taxRoutingTbl.get(brandDescription + '1')) {
                    detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_PROMOTION);
                } else {
                    if (numOfBtl <= (Integer)taxRoutingTbl.get(brandDescription + '2')) {
                        if (ttlPerson < (Integer)taxRoutingTbl.get(brandDescription + '3')) {
                            if(PRJStaff < (Integer)taxRoutingTbl.get(brandDescription + '4')) {
                                if (detailsMap.get(detail.id).ASI_CRM_Customer__r.ASI_CRM_Metropolitan__c == taxRoutingTbl.get(brandDescription + '5')) {
                                    if (total <= (Integer)taxRoutingTbl.get(brandDescription + '6')){
                                        detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_PROMOTION);
                                    } else {
                                        detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_VISIT);
                                    }
                                } else {
                                    if (total <= (Integer)taxRoutingTbl.get(brandDescription + '7')) {
                                        detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_PROMOTION);
                                    } else {
                                        detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_VISIT);
                                    }
                                }   
                            } else {
                                detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_VISIT);
                            }
                        } else {
                            detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_VISIT);
                        }
                    } else {
                        detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_VISIT);
                    }
                }
            } else if (brandDescription == Martell || brandDescription == CR) {
                if (total <= (Integer)taxRoutingTbl.get(brandDescription + '1')) {
                    detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_PROMOTION);
                } else {
                    if (numOfBtl <= (Integer)taxRoutingTbl.get(brandDescription + '2')) {
                        if (ttlPerson < (Integer)taxRoutingTbl.get(brandDescription + '3')) {
                            if(PRJStaff < (Integer)taxRoutingTbl.get(brandDescription + '4')) {
                                if((detailsMap.get(detail.id).ASI_CRM_Customer__r.ASI_TH_CRM_OutletType__r.ASI_TH_CRM_Code__c >= '300' && detailsMap.get(detail.id).ASI_CRM_Customer__r.ASI_TH_CRM_OutletType__r.ASI_TH_CRM_Code__c < '400') &&
                                    (detailsMap.get(detail.id).ASI_CRM_Customer__r.ASI_TH_CRM_OutletType__r.ASI_CRM_Class__c == 'High' || detailsMap.get(detail.id).ASI_CRM_Customer__r.ASI_TH_CRM_OutletType__r.ASI_CRM_Class__c == 'Middle')) {
                                    if (detailsMap.get(detail.id).ASI_CRM_Customer__r.ASI_TH_CRM_OutletType__r.ASI_CRM_Class__c == 'Middle') {
                                        if (total <= (Integer)taxRoutingTbl.get(brandDescription + '9')) {
                                            detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_PROMOTION);
                                        }else{
                                            detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_VISIT);
                                        }
                                    }
                                    if (detailsMap.get(detail.id).ASI_CRM_Customer__r.ASI_TH_CRM_OutletType__r.ASI_CRM_Class__c == 'High') {
                                        if (detailsMap.get(detail.id).ASI_CRM_Customer__r.ASI_CRM_Metropolitan__c == taxRoutingTbl.get(brandDescription + '6')) {
                                            system.debug('Checking: metropolitan: ' + detailsMap.get(detail.id).ASI_CRM_Customer__r.ASI_CRM_Metropolitan__c + ' table: ' + taxRoutingTbl.get(brandDescription + '6') + ' equal1: ' + (taxRoutingTbl.get(brandDescription + '6') == 'true') + ' equal2: ' + (detailsMap.get(detail.id).ASI_CRM_Customer__r.ASI_CRM_Metropolitan__c == (taxRoutingTbl.get(brandDescription + '6') == 'true')) + ' equal3: ' + (detailsMap.get(detail.id).ASI_CRM_Customer__r.ASI_CRM_Metropolitan__c == taxRoutingTbl.get(brandDescription + '6')));
                                            if (total <= (Integer)taxRoutingTbl.get(brandDescription + '7')){
                                                detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_PROMOTION);
                                            }else{
                                                detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_VISIT);
                                            }
                                        }else{
                                            if (total <= (Integer)taxRoutingTbl.get(brandDescription + '8')) {
                                                detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_PROMOTION);
                                            }else{
                                                detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_VISIT);
                                            }
                                        }
                                    }
                                }else{
                                    detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_VISIT);
                                }
                            }else{
                                detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_VISIT);
                            }
                        }else{
                            detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_VISIT);
                        }
                    } else {
                        detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_VISIT);
                    }
                }
            } else if (total <= (Integer)taxRoutingTbl.get('Others' + '1')) {
                detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_PROMOTION);
            } else {
                if (numOfBtl <= (Integer)taxRoutingTbl.get('Others' + '2')){
                    if (ttlPerson < (Integer)taxRoutingTbl.get('Others' + '3')) {
                        if ( PRJStaff< (Integer)taxRoutingTbl.get('Others' + '4')) {
                            if((detailsMap.get(detail.id).ASI_CRM_Customer__r.ASI_TH_CRM_OutletType__r.ASI_TH_CRM_Code__c >= '300' && detailsMap.get(detail.id).ASI_CRM_Customer__r.ASI_TH_CRM_OutletType__r.ASI_TH_CRM_Code__c < '400') &&
                                    (detailsMap.get(detail.id).ASI_CRM_Customer__r.ASI_TH_CRM_OutletType__r.ASI_CRM_Class__c == 'High' || detailsMap.get(detail.id).ASI_CRM_Customer__r.ASI_TH_CRM_OutletType__r.ASI_CRM_Class__c == 'Middle')) {
                               if (total <= 22000) {
                                   detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_PROMOTION);
                               } else {
                                   detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_VISIT);
                               }
                            }else{
                                detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_VISIT);
                            }
                        }else{
                            detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_VISIT);
                        }
                    }else{
                        detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_VISIT);
                    }
                }else{
                    detail.ASI_CRM_Tax_Routing__c = getTaxRouting(BAR_VISIT);
                }
            }
        }
        }
    }
    
    private Id getTaxRouting (Integer promoOrVisit) {
        if (routingMap == null) {
            routingMap = new Map<String, Id>();
            for (ASI_JP_TnE_Expense_Classification__c item:[Select Id,Name From ASI_JP_TnE_Expense_Classification__c Where (Name = 'ﾊﾞｰﾋﾞｼﾞｯﾄ' OR Name = 'ﾊﾞｰﾌﾟﾛﾓｰｼｮﾝ') AND (ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c = '6175.CP' OR ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c = '6160.CP')]) {
                routingMap.put(item.Name,item.Id);
            }
        }
        return routingMap.get(getRoutingName(promoOrVisit));
    }
    
    private String getRoutingName (Integer promoOrVisit) {
        String routingName;
        if (promoOrVisit == BAR_PROMOTION) {
            routingName = 'ﾊﾞｰﾌﾟﾛﾓｰｼｮﾝ';
        } else if (promoOrVisit == BAR_VISIT) {
            routingName = 'ﾊﾞｰﾋﾞｼﾞｯﾄ';
        }
        return routingName;
    }
    
    private Map<String, Id> routingMap;
    private final Integer BAR_PROMOTION = 0;
    private final Integer BAR_VISIT = 1;
    
    //For Classification, may remove the function later
    private final String CHAMPAGNE = 'MUMM CHAMPAGNE';
    private final String MRC = '';
    private final String TOT = '';
    //End For Classification, may remove the function later
    
    private final String CDP = 'CAFE de PARIS';
    private final String CR = 'CHIVAS REGAL';
    private final String PJ = 'PERRIER JOUET';
    private final String Martell = 'MARTELL';
    Private final String MUMM = 'MUMM';
}