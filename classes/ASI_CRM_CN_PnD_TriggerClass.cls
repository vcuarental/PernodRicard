/*
 * *******************************************************************************
 * Name: ASI_CRM_CN_PnD_TriggerClass
 * Description: 
 * Version History
 * Date             Developer           Comments
 * --------------- -------------------- --------------------------------------------------------------------------------
 * ???              ???                 Created
 * 2018-12-24       Vincent Lam         [VL 1.0] Hide Customer Group development as it's not deployed yet
 * 2019-03-01       Vincent Lam         [VL 2.0] For all customer, use Sales Order fix approval route logic, for IH&VIP customer, has additional dynamic approval route
 */
public without sharing class ASI_CRM_CN_PnD_TriggerClass {

    static Map<id, ASI_CRM_Price_And_Discount__c> mapPnD; //20161011, added by Leo

    public static void beforeUpdateMedthod(List<ASI_CRM_Price_And_Discount__c> triggerNew, Map<id, ASI_CRM_Price_And_Discount__c> triggerOldMap){

        Map<String, Integer> statusValidtionMap = new Map<String, Integer>();
        Map<Integer, String> statusValidtionMap2 = new Map<Integer, String>();
        Map<id, RecordType> mapRT = new map<id, RecordType>([SELECT id,DeveloperName,Name FROM RecordType WHERE sObjectType = 'ASI_CRM_Price_And_Discount__c']);
        Map<String, ASI_CRM_Fix_Approval_Route__c> mapFixRoute = new Map<String, ASI_CRM_Fix_Approval_Route__c>();
        Map<id, ASI_CRM_Dynamic_Approval_Route__c> mapDynamicRoute = new Map<id, ASI_CRM_Dynamic_Approval_Route__c>();
        Map<ID, User> mapUser = new Map<ID,User>([SELECT ID, Name, ManagerID FROM User WHERE CompanyName = 'Pernod Ricard China']);
        
        /* [VL 1.0] BEGIN */
        /*
        //20161230 Elufa
        Set<Id> customerGroupIDSet = new Set<Id>();
        Set<Id> customerGroupIDSet2 = new Set<Id>();
        Map<Id, List<ASI_CRM_Customer_Group_Line__c>> mapCustomerGroupLineRTD = new Map<Id, List<ASI_CRM_Customer_Group_Line__c>>();
        Map<Id, List<ASI_CRM_Customer_Group_Line__c>> mapCustomerGroupLine = new Map<Id, List<ASI_CRM_Customer_Group_Line__c>>();
        Map<Id, Set<String>> duplicatedCustomer = new Map<Id, Set<String>>();
        Map<Id, Set<Id>> duplicatedCustomer2 = new Map<Id, Set<Id>>();
        //20161230 End
        */
        /* [VL 1.0] END */
        

        mapPnD = new Map<id, ASI_CRM_Price_And_Discount__c>([SELECT id
                                                             , ASI_CRM_Customer__r.ASI_CRM_CN_Region__c
                                                             , ASI_CRM_Customer__r.ASI_CRM_CN_Is_IHBR_Outlet__c
                                                             , ASI_CRM_Customer__r.ASI_CRM_CN_NewChannel__r.Name//20160803 Ben @ Elufa
                                                             , ASI_CRM_Customer__r.ASI_CRM_CN_Commercial_Team__c
                                                             , ASI_CRM_Customer__r.ASI_CRM_Customer_Type_Picklist__c //20181030 Alan Lau
                                                             , ASI_CRM_Customer__r.ASI_CRM_VIP__c
                                                             , ASI_CRM_Customer__r.ASI_CRM_CN_Estimated_annual_order_amount__c //20161011, added by Leo
                                                             /* [VL 1.0] BEGIN */
                                                             /*
                                                             , ASI_CRM_Customer_Group__c //20161230 Elufa
                                                             , ASI_CRM_Customer_Group__r.ASI_CRM_Region__c //20161230 Elufa
                                                             , ASI_CRM_Customer_Group__r.ASI_CRM_Region__r.Name//20170103 Elufa
                                                             */
                                                             /* [VL 1.0] END */
                                                             FROM ASI_CRM_Price_And_Discount__c WHERE id IN : triggerNew
                                                            ]);

        List<ASI_CRM_Price_And_Discount_Detail__c> lineItemList = new List<ASI_CRM_Price_And_Discount_Detail__c>([SELECT id
                                                                                                                  FROM ASI_CRM_Price_And_Discount_Detail__c
                                                                                                                  WHERE ASI_CRM_Price_And_Discount__c IN : triggerNew
                                                                                                                 ]);

        List<ASI_CRM_Dynamic_Approval_Route__c> dynamicRoute = new List<ASI_CRM_Dynamic_Approval_Route__c>([SELECT id
                                                                                                            , ASI_CRM_End_of_Dynamic_Route__c
                                                                                                            , ASI_CRM_User__c
                                                                                                            , ASI_CRM_Type__c
                                                                                                            FROM ASI_CRM_Dynamic_Approval_Route__c
                                                                                                            WHERE ASI_CRM_Type__c LIKE 'Price%'
                                                                                                           ]);

        List<ASI_CRM_Fix_Approval_Route__c> fixRoute = new List<ASI_CRM_Fix_Approval_Route__c>([SELECT id
                                                                                                , ASI_CRM_CN_Type__c
                                                                                                , ASI_CRM_CN_Regional_BA__c
                                                                                                , ASI_CRM_CN_Approval_Limit_1__c
                                                                                                , ASI_CRM_CN_Approval_Limit_2__c
                                                                                                , ASI_CRM_CN_Approval_Limit_3__c
                                                                                                , ASI_CRM_CN_Approval_Limit_4__c
                                                                                                , ASI_CRM_CN_Approval_Limit_5__c
                                                                                                , ASI_CRM_CN_Approval_Limit_6__c
                                                                                                , ASI_CRM_CN_Approval_Limit_7__c
                                                                                                , ASI_CRM_CN_Approval_Limit_8__c
                                                                                                , ASI_CRM_CN_Approval_Limit_9__c
                                                                                                , ASI_CRM_CN_Approval_Limit_10__c
                                                                                                , ASI_CRM_CN_Approval_Limit_11__c
                                                                                                , ASI_CRM_CN_Approver_1__c
                                                                                                , ASI_CRM_CN_Approver_2__c
                                                                                                , ASI_CRM_CN_Approver_3__c
                                                                                                , ASI_CRM_CN_Approver_4__c
                                                                                                , ASI_CRM_CN_Approver_5__c
                                                                                                , ASI_CRM_CN_Approver_6__c
                                                                                                , ASI_CRM_CN_Approver_7__c
                                                                                                , ASI_CRM_CN_Approver_8__c
                                                                                                , ASI_CRM_CN_Approver_9__c
                                                                                                , ASI_CRM_CN_Approver_10__c
                                                                                                , ASI_CRM_CN_Approver_11__c
                                                                                                , ASI_CRM_CN_Region_Area_Channel__c
                                                                                                , ASI_CRM_Commercial_Team__c
                                                                                                , ASI_CRM_VIP__c
                                                                                                , ASI_CRM_IHBR__c
                                                                                                , ASI_CRM_Channel__c
                                                                                                , ASI_CRM_Channel__r.Name
                                                                                                FROM ASI_CRM_Fix_Approval_Route__c
                                                                                                WHERE ASI_CRM_CN_Type__c LIKE 'Price%'
                                                                                               ]);

        Map<id, ASI_CRM_Price_And_Discount__c> priceAndDiscountMap = new Map<id, ASI_CRM_Price_And_Discount__c>([
                SELECT id
                        , ASI_CRM_Customer__c
                        , ASI_CRM_Customer__r.ASI_CRM_CN_Is_IHBR_Outlet__c
                        , ASI_CRM_Customer__r.ASI_CRM_CN_Region__c
                        , ASI_CRM_Customer__r.ASI_CRM_CN_Sub_Channel__r.Name
                        , ASI_CRM_Customer__r.ASI_CRM_VIP__c
                        , ASI_CRM_Customer__r.recordType.developerName
                        , ASI_CRM_Customer__r.ASI_CRM_CN_Commercial_Team__c
                        , ASI_CRM_Customer__r.ASI_CRM_CN_NewChannel__r.Name
                        , ASI_CRM_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                        //, ASI_CRM_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_Sub_Region__c
                        , ASI_CRM_Customer__r.ASI_CRM_Customer_Type_Picklist__c
                FROM ASI_CRM_Price_And_Discount__c
                WHERE id IN:triggerNew
        ]);

        
        /* [VL 1.0] BEGIN */
        /*
        //20161230 Elufa
        for(ASI_CRM_Price_And_Discount__c obj : triggerNew){
            if(obj.ASI_CRM_Customer_Group__c != Null)
                customerGroupIDSet.add(obj.ASI_CRM_Customer_Group__c);
        }

        for(ASI_CRM_Customer_Group_Line__c customerGroupLine : [SELECT id, ASI_CRM_Customer_Group__c, ASI_CRM_Customer__c, ASI_CRM_Customer__r.Name, ASI_CRM_Customer__r.ASI_CRM_CN_JDE_Code__c, ASI_CRM_Customer__r.ASI_CRM_CN_JDE_Code_RTD__c FROM ASI_CRM_Customer_Group_Line__c WHERE ASI_CRM_Customer_Group__c IN : customerGroupIDSet]){

            if(duplicatedCustomer2.containsKey(customerGroupLine.ASI_CRM_Customer_Group__c) && duplicatedCustomer2.get(customerGroupLine.ASI_CRM_Customer_Group__c).contains(customerGroupLine.ASI_CRM_Customer__c)){

                Set<String> tmp = new Set<String>();

                if(duplicatedCustomer.containsKey(customerGroupLine.ASI_CRM_Customer_Group__c))
                    tmp = duplicatedCustomer.get(customerGroupLine.ASI_CRM_Customer_Group__c);

                tmp.add(customerGroupLine.ASI_CRM_Customer__r.Name);

                duplicatedCustomer.put(customerGroupLine.ASI_CRM_Customer_Group__c, tmp);
            }else{

                Set<id> tmp = new Set<id>();

                if(duplicatedCustomer2.containsKey(customerGroupLine.ASI_CRM_Customer_Group__c))
                    tmp = duplicatedCustomer2.get(customerGroupLine.ASI_CRM_Customer_Group__c);

                tmp.add(customerGroupLine.ASI_CRM_Customer__c);
                duplicatedCustomer2.put(customerGroupLine.ASI_CRM_Customer_Group__c, tmp);
            }

            if(customerGroupLine.ASI_CRM_Customer__r.ASI_CRM_CN_JDE_Code_RTD__c == NULL || customerGroupLine.ASI_CRM_Customer__r.ASI_CRM_CN_JDE_Code_RTD__c == ''){

                List<ASI_CRM_Customer_Group_Line__c> tmp = new List<ASI_CRM_Customer_Group_Line__c>();

                if(mapCustomerGroupLineRTD.containsKey(customerGroupLine.ASI_CRM_Customer_Group__c))
                    tmp = mapCustomerGroupLineRTD.get(customerGroupLine.ASI_CRM_Customer_Group__c);

                tmp.add(customerGroupLine);

                mapCustomerGroupLineRTD.put(customerGroupLine.ASI_CRM_Customer_Group__c, tmp);
            }

            if(customerGroupLine.ASI_CRM_Customer__r.ASI_CRM_CN_JDE_Code__c == NULL || customerGroupLine.ASI_CRM_Customer__r.ASI_CRM_CN_JDE_Code__c == ''){

                List<ASI_CRM_Customer_Group_Line__c> tmp = new List<ASI_CRM_Customer_Group_Line__c>();

                if(mapCustomerGroupLine.containsKey(customerGroupLine.ASI_CRM_Customer_Group__c))
                    tmp = mapCustomerGroupLine.get(customerGroupLine.ASI_CRM_Customer_Group__c);

                tmp.add(customerGroupLine);

                mapCustomerGroupLine.put(customerGroupLine.ASI_CRM_Customer_Group__c, tmp);
            }

            customerGroupIDSet2.add(customerGroupLine.ASI_CRM_Customer_Group__c);
        }
        //20161230 End
        */
        /* [VL 1.0] END */
        

        for(ASI_CRM_Dynamic_Approval_Route__c obj : dynamicRoute)
            mapDynamicRoute.put(obj.ASI_CRM_User__c, obj);

        for(ASI_CRM_Fix_Approval_Route__c obj : fixRoute){
//            if(obj.ASI_CRM_CN_Region_Area_Channel__c != null && obj.ASI_CRM_CN_Region_Area_Channel__c != '')
//              mapFixRoute.put(obj.ASI_CRM_CN_Type__c + obj.ASI_CRM_CN_Region_Area_Channel__c, obj);
//            else
//                mapFixRoute.put(obj.ASI_CRM_CN_Type__c + '', obj);
            //20181115 Alan Lau Start
            String key = obj.ASI_CRM_CN_Type__c;
            key += obj.ASI_CRM_Commercial_Team__c != NULL ? obj.ASI_CRM_Commercial_Team__c : '';
            key += obj.ASI_CRM_VIP__c ? 'TRUE' : 'FALSE';
            key += obj.ASI_CRM_IHBR__c ? 'TRUE' : 'FALSE';
            key += obj.ASI_CRM_Channel__c != NULL ? obj.ASI_CRM_Channel__r.Name : '';
            key += obj.ASI_CRM_CN_Region_Area_Channel__c != NULL ? obj.ASI_CRM_CN_Region_Area_Channel__c : '';

            mapFixRoute.put(key, obj);
            //20181115 Alan Lau End
        }

        statusValidtionMap.put('Open', 1);
        statusValidtionMap.put('Pending for BO to PRCSW Pirce', 2);
        statusValidtionMap.put('Pending for PRCSW to PRC Price', 3);
        statusValidtionMap.put('Pending for T1 Price', 4);
        statusValidtionMap.put('Pending for add to order form', 5);
        statusValidtionMap.put('Completed', 6);
        statusValidtionMap2.put(1, 'Open');
        statusValidtionMap2.put(2, 'Pending for BO to PRCSW Pirce');
        statusValidtionMap2.put(3, 'Pending for PRCSW to PRC Price');
        statusValidtionMap2.put(4, 'Pending for T1 Price');
        statusValidtionMap2.put(5, 'Pending for add to order form');
        statusValidtionMap2.put(6, 'Completed');

        // Loop triggerNew
        for(ASI_CRM_Price_And_Discount__c priceAndDiscount : triggerNew){

            if(triggerOldMap.get(priceAndDiscount.id).ASI_CRM_Status__c != priceAndDiscount.ASI_CRM_Status__c && ( mapRT.get(priceAndDiscount.recordTypeid).DeveloperName == 'ASI_CRM_CN_NPL_T1_Price_Request' || mapRT.get(priceAndDiscount.recordTypeid).DeveloperName == 'ASI_CRM_CN_NPL_T1_Price_Request_RO' || ( mapRT.get(priceAndDiscount.recordTypeid).DeveloperName == 'ASI_CRM_CN_Repacking_Price_Request_RO' && triggerOldMap.get(priceAndDiscount.id).ASI_CRM_Status__c == 'Pending for T1 Price' ))){

                if( ( statusValidtionMap.get(priceAndDiscount.ASI_CRM_Status__c) > statusValidtionMap.get( triggerOldMap.get(priceAndDiscount.id).ASI_CRM_Status__c ) ) && statusValidtionMap.get(priceAndDiscount.ASI_CRM_Status__c) != ( statusValidtionMap.get( triggerOldMap.get(priceAndDiscount.id).ASI_CRM_Status__c ) + 1 )){
                    priceAndDiscount.addError('Next status should be ' + statusValidtionMap2.get( ( statusValidtionMap.get( triggerOldMap.get(priceAndDiscount.id).ASI_CRM_Status__c ) + 1 ) ) );
                    break;
                }
            }
            
            /* [VL 1.0] BEGIN */
            /*
            //20161230 Elufa
            if(priceAndDiscount.ASI_CRM_Customer_Group__c != NULL && duplicatedCustomer.containsKey(priceAndDiscount.ASI_CRM_Customer_Group__c)){

                String errorMsg = 'Duplicated Outlet/WS Exists in Customer Group : ';

                for(String name : duplicatedCustomer.get(priceAndDiscount.ASI_CRM_Customer_Group__c)){
                    errorMsg += name + ', ';
                }

                errorMsg = errorMsg.substring(0, errorMsg.length()-2);

                priceAndDiscount.addError(errorMsg);
                break;
            }

            if(priceAndDiscount.ASI_CRM_Customer_Group__c != NULL && !priceAndDiscount.ASI_CRM_RTD__c && mapCustomerGroupLine.containsKey(priceAndDiscount.ASI_CRM_Customer_Group__c)){

                String errorMsg = 'Following Outlet/WS do not have JDE Code : ';

                for(ASI_CRM_Customer_Group_Line__c obj : mapCustomerGroupLine.get(priceAndDiscount.ASI_CRM_Customer_Group__c)){
                    errorMsg += obj.ASI_CRM_Customer__r.Name + ', ';
                }

                errorMsg = errorMsg.substring(0, errorMsg.length()-2);

                priceAndDiscount.addError(errorMsg);
                break;
            }

            if(priceAndDiscount.ASI_CRM_Customer_Group__c != NULL && priceAndDiscount.ASI_CRM_RTD__c && mapCustomerGroupLineRTD.containsKey(priceAndDiscount.ASI_CRM_Customer_Group__c)){

                String errorMsg = 'Following Outlet/WS do not have RTD JDE Code : ';

                for(ASI_CRM_Customer_Group_Line__c obj : mapCustomerGroupLineRTD.get(priceAndDiscount.ASI_CRM_Customer_Group__c)){
                    errorMsg += obj.ASI_CRM_Customer__r.Name + ', ';
                }

                errorMsg = errorMsg.substring(0, errorMsg.length()-2);

                priceAndDiscount.addError(errorMsg);
                break;
            }

            if(priceAndDiscount.ASI_CRM_Customer_Group__c != NULL && !customerGroupIDSet2.contains(priceAndDiscount.ASI_CRM_Customer_Group__c)){
                priceAndDiscount.addError('This Customer Group doesn\'t have any Outlet/WS.');
                break;
            }
            //20161230 End
            */
            /* [VL 1.0] END */
            
            if(triggerOldMap.get(priceAndDiscount.id).ASI_CRM_Customer__c != priceAndDiscount.ASI_CRM_Customer__c){
                priceAndDiscount.addError('Customer can not be changed.');
                break;
            }
            
            /* [VL 1.0] BEGIN */
            /*
            //20161230 Elufa
            if(triggerOldMap.get(priceAndDiscount.id).ASI_CRM_Customer_Group__c != priceAndDiscount.ASI_CRM_Customer_Group__c){
                priceAndDiscount.addError('Customer Group can not be changed.');
                break;
            }
            //20161230 End
            */
            /* [VL 1.0] END */
            
            if(lineItemList.size() > 0 && triggerOldMap.get(priceAndDiscount.id).ASI_CRM_RTD__c != priceAndDiscount.ASI_CRM_RTD__c){
                priceAndDiscount.addError('RTD can not be changed.');
                break;
            }

            if(!mapUser.containsKey(priceAndDiscount.OwnerId)){
                priceAndDiscount.addError('For Pernod Ricard China staff only.');
                break;
            }

            if(priceAndDiscount.ASI_CRM_Status__c == 'Open'){

                setApproverToNull(priceAndDiscount);

                if(mapRT.get(priceAndDiscount.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Repacking_Price_Request'){

                    setFixApprover(priceAndDiscount, mapFixRoute, '', 'Price - RepackFALSEFALSE');

                }else if(mapRT.get(priceAndDiscount.RecordTypeId).DeveloperName == 'ASI_CRM_CN_T1_Price_Adjustment_Request'){

                    setFixApprover(priceAndDiscount, mapFixRoute, '', 'Price - AdjustmentFALSEFALSE');

                }else if(mapRT.get(priceAndDiscount.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Customer_Price_and_Discount_Request'){

                    if(mapPnD.get(priceAndDiscount.id).ASI_CRM_Customer__c != Null){
                        
                        // [VL 2.0] BEGIN
                        // if((mapPnD.get(priceAndDiscount.id).ASI_CRM_Customer__r.ASI_CRM_CN_Is_IHBR_Outlet__c && mapPnD.get(priceAndDiscount.id).ASI_CRM_Customer__r.ASI_CRM_CN_Commercial_Team__c == 'HQ/Hotel') || mapPnD.get(priceAndDiscount.id).ASI_CRM_Customer__r.ASI_CRM_VIP__c){

                        //     setDynamicApprover(priceAndDiscount, mapUser, mapDynamicRoute);
                        //     setFixApprover(priceAndDiscount, mapFixRoute, '', 'Price - Customer Price (IH & VIP)');
                        // } else if (mapPnD.get(priceAndDiscount.id).ASI_CRM_Customer__r.ASI_CRM_Customer_Type_Picklist__c == 'MOT') { //20181030 Alan Lau
                        //     setFixApprover(priceAndDiscount, mapFixRoute, '', 'Price - Customer Price (MOT)');
                        // } else {
                        //     setFixApprover(priceAndDiscount, mapFixRoute, mapPnD.get(priceAndDiscount.id).ASI_CRM_Customer__r.ASI_CRM_CN_Region__c, 'Price - Customer Price');
                        // }
                        if((mapPnD.get(priceAndDiscount.id).ASI_CRM_Customer__r.ASI_CRM_CN_Is_IHBR_Outlet__c && mapPnD.get(priceAndDiscount.id).ASI_CRM_Customer__r.ASI_CRM_CN_Commercial_Team__c == 'HQ/Hotel') || mapPnD.get(priceAndDiscount.id).ASI_CRM_Customer__r.ASI_CRM_VIP__c){
                            setDynamicApprover(priceAndDiscount, mapUser, mapDynamicRoute);
                        }
                        setFixSysApprover(priceAndDiscountMap, mapFixRoute, priceAndDiscount, mapPnD.get(priceAndDiscount.id).ASI_CRM_Customer__r.ASI_CRM_Customer_Type_Picklist__c);
                        // [VL 2.0] END
                    }
//                    else if(mapPnD.get(priceAndDiscount.id).ASI_CRM_Customer_Group__c != Null){//20161230 Elufa
//
//                        setFixApprover(priceAndDiscount, mapFixRoute, mapPnD.get(priceAndDiscount.id).ASI_CRM_Customer_Group__r.ASI_CRM_Region__r.Name, 'Price - Customer Price');
//                    }//20161230 End
//                        /*else{
//
//                        //if(mapPnD.get(PnDObj.id).ASI_CRM_Customer__r.ASI_CRM_CN_Commercial_Team__c == 'HQ/Hotel'){
//                          //setFixApprover(PnDObj, mapFixRoute, '', 'Price - Customer Price (IHBR)');
//                          //setFixApprover(PnDObj, mapFixRoute, '', 'Price - Customer Price (IH & VIP)');
//                        //}
//                        else{//20160803 Ben @ Elufa
//                            setFixApprover(PnDObj, mapFixRoute, '', 'Price - Customer Price (IBR)');
//                        }
//                    }*/
                }
            }
        }
    }

    private static void setFixSysApprover(Map<Id, ASI_CRM_Price_And_Discount__c> priceAndDiscountMap, Map<String, ASI_CRM_Fix_Approval_Route__c> mapFixRoute, ASI_CRM_Price_And_Discount__c priceAndDiscount, String customerType) { //20181115 Alan Lau
        Integer sysApproverListIndex = 0;
        List<String> emptySysApproverList = getEmptySysApproverList(priceAndDiscount);
        String fixApprover;
        String fixApproverLimit;
        String mapFixRouteKey = createMapFixRouteKey(priceAndDiscountMap, priceAndDiscount, customerType);

        // Enoch@Introv 20191218 UserGroup Checking start
        string sNewKey4HQ = 'Price - Customer Price - HQFALSEFALSE';
        if(checkUserGroup('ASI_CN_Price_and_Discount_Submitters_HQ',priceAndDiscount.OwnerId) && mapFixRoute.containsKey(sNewKey4HQ)) {
            mapFixRouteKey = sNewKey4HQ;
        }
        // Enoch@Introv 20191218 UserGroup Checking end

        for (Integer approverNumber = 1; approverNumber <= 11; approverNumber++) {
            fixApprover = 'ASI_CRM_CN_Approver_' + approverNumber + '__c';
            fixApproverLimit = 'ASI_CRM_CN_Approval_Limit_' + approverNumber + '__c';

            if (mapFixRoute.containsKey(mapFixRouteKey) && mapFixRoute.get(mapFixRouteKey).get(fixApprover) != null) {
                if(priceAndDiscount.get(emptySysApproverList[sysApproverListIndex])==null){
                    priceAndDiscount.put(emptySysApproverList[sysApproverListIndex], mapFixRoute.get(mapFixRouteKey).get(fixApprover));
                    
                }    
                sysApproverListIndex++;            

                if (sysApproverListIndex >= emptySysApproverList.size() || isApprovalLimitExceeded(mapFixRoute, mapFixRouteKey, fixApproverLimit, priceAndDiscount)) {
                    break;
                }
            }
        }

    }

    private static Boolean isApprovalLimitExceeded(Map<String, ASI_CRM_Fix_Approval_Route__c> mapFixRoute, String mapFixRouteKey, String fixApproverLimit, ASI_CRM_Price_And_Discount__c priceAndDiscount) {
        return mapFixRoute.get(mapFixRouteKey).get(fixApproverLimit) != null && priceAndDiscount.ASI_CRM_Sys_Total_Amount_for_Approval__c <= Double.valueOf(mapFixRoute.get(mapFixRouteKey).get(fixApproverLimit));
    }

    private static String createMapFixRouteKey(Map<Id, ASI_CRM_Price_And_Discount__c> priceAndDiscountMap, ASI_CRM_Price_And_Discount__c priceAndDiscount, String customerType) { //20181116 Alan Lau
        Boolean isWS = priceAndDiscountMap.get(priceAndDiscount.Id).ASI_CRM_Customer__r.RecordType.DeveloperName.contains('ASI_CRM_CN_WS') ? true : false;
        String mapFixRouteKey = 'Price - Customer Price - ' ;
        mapFixRouteKey += customerType == null ? '' : customerType + ' - ';
        mapFixRouteKey += (isWS ? 'WS' : 'Outlet');

        mapFixRouteKey += priceAndDiscountMap.get(priceAndDiscount.Id).ASI_CRM_Customer__r.ASI_CRM_CN_Commercial_Team__c != null ? priceAndDiscountMap.get(priceAndDiscount.Id).ASI_CRM_Customer__r.ASI_CRM_CN_Commercial_Team__c : '';
        mapFixRouteKey += priceAndDiscountMap.get(priceAndDiscount.Id).ASI_CRM_Customer__r.ASI_CRM_CN_NewChannel__r.Name == 'VIP' || priceAndDiscountMap.get(priceAndDiscount.Id).ASI_CRM_Customer__r.ASI_CRM_VIP__c ? 'TRUE' : 'FALSE';
        mapFixRouteKey += priceAndDiscountMap.get(priceAndDiscount.Id).ASI_CRM_Customer__r.ASI_CRM_CN_Is_IHBR_Outlet__c ? 'TRUE' : 'FALSE';
        mapFixRouteKey += priceAndDiscountMap.get(priceAndDiscount.Id).ASI_CRM_Customer__r.ASI_CRM_CN_NewChannel__c != null ? priceAndDiscountMap.get(priceAndDiscount.Id).ASI_CRM_Customer__r.ASI_CRM_CN_NewChannel__r.Name : '';
        mapFixRouteKey += priceAndDiscountMap.get(priceAndDiscount.Id).ASI_CRM_Customer__r.ASI_CRM_CN_Region__c != null ? priceAndDiscountMap.get(priceAndDiscount.Id).ASI_CRM_Customer__r.ASI_CRM_CN_Region__c : '';

        return mapFixRouteKey;
    }

    private static List<String> getEmptySysApproverList(ASI_CRM_Price_And_Discount__c priceAndDiscount) { //20181115 Alan Lau
        String sysApprover;
        List<String> sysApproverList = new List<String>();

        for (Integer i = 1; i <= 11; i++) {
            sysApprover = 'ASI_CRM_Sys_Approver_' + i + '__c';

            if (priceAndDiscount.get(sysApprover) == null) {
                sysApproverList.add(sysApprover);
            }
        }

        return sysApproverList;
    }

    private static void setFixApprover(ASI_CRM_Price_And_Discount__c PnDObj, Map<String, ASI_CRM_Fix_Approval_Route__c> mapFixRoute, String region, String fixApprovalType){

        String fixApprover;
        String sysApprover;
        List<String> sysApproverList = new List<String>();
        String approvalLimit;
        integer k = 1;
        integer x = 0;

    //    /*for(integer i = 1 ; i <= 10 ; i++){

    //        approvalLimit = 'ASI_CRM_CN_Approval_Limit_' + k + '__c';
    //        sysApprover = 'ASI_CRM_Sys_Approver_' + i + '__c';
    //        fixApprover = 'ASI_CRM_CN_Approver_'+ k +'__c';

    //        if(PnDObj.get(sysApprover) == null){
    //            if(mapFixRoute.containsKey(fixApprovalType + region)){
    //                PnDObj.put(sysApprover, mapFixRoute.get(fixApprovalType + region).get(fixApprover));
    //              k++;
    //                if(math.abs(PnDObj.ASI_CRM_CN_Total_Gross_Sales_Impact__c) <= double.valueOf(mapFixRoute.get(fixApprovalType + region).get(approvalLimit))){
    //                  break;
    //              }
    //            }
    //        }

    //        if(k > 6)break;
    //    }*/

        for(integer i = 1 ; i <= 11 ; i++){
            sysApprover = 'ASI_CRM_Sys_Approver_' + i + '__c';
            if(PnDObj.get(sysApprover) == null){
                sysApproverList.add(sysApprover);
            }
        }
        while(k <= 11){

            fixApprover = 'ASI_CRM_CN_Approver_'+ k +'__c';
            approvalLimit = 'ASI_CRM_CN_Approval_Limit_' + k + '__c';

            if(mapFixRoute.containsKey(fixApprovalType + region)){

                if(mapFixRoute.get(fixApprovalType + region).get(fixApprover) != null){

                    PnDObj.put(sysApproverList[x], mapFixRoute.get(fixApprovalType + region).get(fixApprover));
    //                //20161011, edited by Leo
    //                /*if(math.abs(PnDObj.ASI_CRM_CN_Total_Gross_Sales_Impact__c) <= double.valueOf(mapFixRoute.get(fixApprovalType + region).get(approvalLimit))){
    //                  break;
    //              }*/
    //                if(fixApprovalType != 'Price - Customer Price (IH & VIP)'
    //                   && math.abs(PnDObj.ASI_CRM_CN_Total_Gross_Sales_Impact__c) <= double.valueOf(mapFixRoute.get(fixApprovalType + region).get(approvalLimit))){
    //                  break;
    //              }
    //                else if(fixApprovalType == 'Price - Customer Price (IH & VIP)')
    //                {
    //                    /*Double amt = 0;
    //                    if(mapPnD.containsKey(PnDObj.id)
    //                       && mapPnD.get(PnDObj.id).ASI_CRM_Customer__r.ASI_CRM_CN_Estimated_annual_order_amount__c != null)
    //                        amt = mapPnD.get(PnDObj.id).ASI_CRM_Customer__r.ASI_CRM_CN_Estimated_annual_order_amount__c;
    //                    if(math.abs(amt) <= double.valueOf(mapFixRoute.get(fixApprovalType + region).get(approvalLimit)))
    //                    {
    //                        break;
    //                    }*/
    //                    //20161104, edited by Leo
    //                    if(PnDObj.ASI_CRM_CN_Total_Gross_Sales_Impact__c <= 0)
    //                    {
    //                        if(math.abs(PnDObj.ASI_CRM_CN_Total_Gross_Sales_Impact__c) <= double.valueOf(mapFixRoute.get(fixApprovalType + region).get(approvalLimit)))
    //                        {
    //                            break;
    //                        }
    //                    }
    //                    else
    //                    {
    //                        Double amt = 0;
    //                        if(mapPnD.containsKey(PnDObj.id)
    //                           && mapPnD.get(PnDObj.id).ASI_CRM_Customer__r.ASI_CRM_CN_Estimated_annual_order_amount__c != null)
    //                            amt = mapPnD.get(PnDObj.id).ASI_CRM_Customer__r.ASI_CRM_CN_Estimated_annual_order_amount__c;
    //                        if(math.abs(amt) <= double.valueOf(mapFixRoute.get(fixApprovalType + region).get(approvalLimit)))
    //                        {
    //                            break;
    //                        }
    //                    }
    //                    //20161104, edited by Leo
    //                }
                    //20161011, edited by Leo
                    x++;
                    if(x >= sysApproverList.size())
                        break;
                }
            }
            k++;
        }
    }

   private static void setDynamicApprover(ASI_CRM_Price_And_Discount__c PnDObj, Map<ID, User> mapUser, Map<id, ASI_CRM_Dynamic_Approval_Route__c> mapDynamicRoute){

       ID approverID = mapUser.get(PnDObj.OwnerId).ManagerID;
       String sysApprover;

       for(integer i = 1 ; i <= 10 ; i++){

           sysApprover = 'ASI_CRM_Sys_Approver_' + i + '__c';

           if(mapUser.containsKey(approverID)){

               PnDObj.put(sysApprover, approverID);

               if(mapDynamicRoute.containsKey(approverID))
                   if(mapDynamicRoute.get(approverID).ASI_CRM_End_of_Dynamic_Route__c)
                    break;

               approverID = mapUser.get(approverID).ManagerID;

           }else break;
       }
   }

    public static void setApproverToNull(ASI_CRM_Price_And_Discount__c PnDObj){

        String sysApprover;

        for(integer i = 1 ; i <=11 ; i++){
            sysApprover = 'ASI_CRM_Sys_Approver_' + i + '__c';
            PnDObj.put(sysApprover,null);
        }
    }
    
    // Enoch@Introv 20191218 UserGroup Checking start
    public static Boolean checkUserGroup(String groupKey, Id ownerId) {
        return ([SELECT COUNT() FROM GroupMember WHERE (group.DeveloperName LIKE :groupKey) AND UserOrGroupId = :ownerId] > 0);
    }
    // Enoch@Introv 20191218 UserGroup Checking end
}