/*
 * *******************************************************************************
 * Name: ASI_CRM_CN_SalesOrderTriggerClass
 * Description: 
 * Version History
 * Date 			Developer 			Comments
 * --------------- -------------------- --------------------------------------------------------------------------------
 * ???				???			 		Created
 * 2018-12-24		Vincent Lam			[VL 1.0] Hide approval route criteria City > Sub-region as it's not deployed yet
 * 2019-06-12       Wilson Chow         Add findDeliverZoneByCustomer() to assign delivery zone at before insert, update
 * 2019-06-23		Vincent Lam			[VL 2.0] Batch 5.3: rollback promotion qty
 * 2019-06-23		Vincent Lam			[VL 3.0] Batch 5.3: add Customer and Channel level to Item Group Allocation checking
 * 2019-06-26       Wilson Chow         Modified calculateRemainingQty() for getting correct allocation item by diff key
 */
public without sharing class ASI_CRM_CN_SalesOrderTriggerClass {
    
    public Static Set<Id> allocationSet = new Set<Id>();
    
    public Static Void beforeInsertMethod(List<ASI_KOR_Sales_Order_Request__c> triggerNew){
        
        Set<Id> customerIdSet = new Set<Id>();
        
        for(ASI_KOR_Sales_Order_Request__c obj : triggerNew){
            
            customerIdSet.add(obj.ASI_CRM_CN_Customer__c);
        }

        // 20190612 - retrieve ASI_CRM_CN_NewChannel__c, ASI_CRM_CN_Region__c, ASI_CRM_CN_CCity__c
        Map<id, ASI_CRM_AccountsAdditionalField__c> mapCustomer =
                new Map<Id, ASI_CRM_AccountsAdditionalField__c>([SELECT id, ASI_CRM_CN_Commercial_Team__c, ASI_CRM_CN_NewChannel__c, ASI_CRM_CN_Region__c, ASI_CRM_CN_CCity__c
                            FROM ASI_CRM_AccountsAdditionalField__c
                            WHERE id IN : customerIdSet]);

        // 20190612 start
        Map<Id, ASI_FOC_Delivery_Zone__c> customerDeliveryZoneMap = findDeliverZoneByCustomer(mapCustomer);
        system.debug('customerDeliveryZoneMap:' + customerDeliveryZoneMap);
        // 20190612 end

        for(ASI_KOR_Sales_Order_Request__c obj : triggerNew){
            
            obj.ASI_CRM_SG_Order_Date__c = date.today();
            
            if(mapCustomer.containsKey(obj.ASI_CRM_CN_Customer__c) && mapCustomer.get(obj.ASI_CRM_CN_Customer__c).ASI_CRM_CN_Commercial_Team__c == 'Premium' )
                obj.ASI_CRM_CN_Premium__c = True;

            // 20190612 start
            if(customerDeliveryZoneMap != null && obj.ASI_CRM_CN_Customer__c != null
                    && customerDeliveryZoneMap.containsKey(obj.ASI_CRM_CN_Customer__c)
                    && customerDeliveryZoneMap.get(obj.ASI_CRM_CN_Customer__c) != null
                    && customerDeliveryZoneMap.get(obj.ASI_CRM_CN_Customer__c).Id != null) {
                obj.ASI_CRM_Delivery_Zone__c = customerDeliveryZoneMap.get(obj.ASI_CRM_CN_Customer__c).Id;
            }
            // 20190612 end
        }
    }
    
    public static void beforeUpdateMethod(List<ASI_KOR_Sales_Order_Request__c> triggerNew, Map<id, ASI_KOR_Sales_Order_Request__c> triggerOldMap){
        
        Map<ID, User> mapUser = new Map<ID,User>([SELECT ID, Name, ManagerID FROM User WHERE CompanyName = 'Pernod Ricard China']); 
        Map<String, ASI_CRM_Fix_Approval_Route__c> mapFixRoute = new Map<String, ASI_CRM_Fix_Approval_Route__c>();
        Map<String, ASI_CRM_Dynamic_Approval_Route__c> mapDynamicRoute = new Map<String, ASI_CRM_Dynamic_Approval_Route__c>();
        Map<id, Boolean> isPromotionCodeExist = new Map<id, Boolean>();
        
        //20170525
        Set<Id> headerId = new Set<Id>();
        Set<Id> rejectHeaderId = new Set<Id>(); //20180321
        Map<Id, String> allOverSO = new Map<Id, String>();
        Set<Id> regionSet = new Set<Id>();
        Set<Id> itemGroupSet = new Set<Id>();
        Set<String> commercialTeamSet = new Set<String>();
        Date startDate;
        Date endDate;
        Boolean hasError = False;
        Boolean updateAllocationRecord = False;

        Map<id, ASI_KOR_Sales_Order_Request__c> mapSalesOrder = new Map<id, ASI_KOR_Sales_Order_Request__c>([SELECT id
                                                                                                        	 , ASI_CRM_CN_Customer__c
                                                                                                        	 , ASI_CRM_CN_Customer__r.ASI_CRM_CN_Is_IHBR_Outlet__c
                                                                                                        	 , ASI_CRM_CN_Customer__r.ASI_CRM_CN_Region__c
                                                                                                             , ASI_CRM_CN_Customer__r.ASI_CRM_CN_Sub_Channel__r.Name
                                                                                                             , ASI_CRM_CN_Customer__r.ASI_CRM_VIP__c
                                                                                                             , ASI_CRM_CN_Customer__r.recordType.developerName
                                                                                                             , ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c //20160803 Ben @ Elufa
                                                                                                             , ASI_CRM_CN_Customer__r.ASI_CRM_CN_NewChannel__r.Name
                                                                                                             /* [VL 3.0] BEGIN */
                                                                                                             , ASI_CRM_CN_Customer__r.ASI_CRM_CN_NewChannel__c
                                                                                                             /* [VL 3.0] END */
                                                                                                             , ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                                                                                             /* [VL 1.0] BEGIN */
																										     /*
																										     , ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_Sub_Region__c //20180320 Introv
																											 */
																											 /* [VL 1.0] END */
                                                                                                             , ASI_CRM_CN_Customer__r.ASI_CRM_Customer_Type_Picklist__c //20181106 Alan Lau
                                                                                                        	 FROM ASI_KOR_Sales_Order_Request__c
                                                                                                        	 WHERE id IN: triggerNew
                                                                                                       		]);
        
        List<ASI_KOR_Sales_Order_Transaction__c> salesOrderLineItem = new List<ASI_KOR_Sales_Order_Transaction__c>([SELECT id
                                                                                                                    , ASI_CRM_CN_Promotion_Code__c
                                                                                                                    , ASI_KOR_Sales_Order_Request__c
                                                                                                                    , ASI_CRM_CN_Product_Name__c
                                                                                                                    , ASI_CRM_Order_Qty_Bottle__c
                                                                                                                    , ASI_CRM_CN_Product_Name__r.Name
                                                                                                                    , ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                                                                                                    /* [VL 1.0] BEGIN */
																													/*
																													, ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_Sub_Region__c //20180320 Introv
                                                                                                                    */
																													/* [VL 1.0] END */
																													, ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c
                                                                                                                    , ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c
                                                                                                                    FROM ASI_KOR_Sales_Order_Transaction__c 
                                                                                                                    WHERE ASI_KOR_Sales_Order_Request__c IN: triggerNew
                                                                                                                   ]);
        
        List<ASI_CRM_Dynamic_Approval_Route__c> dynamicRoute = new List<ASI_CRM_Dynamic_Approval_Route__c>([SELECT id
                                                                                                            , ASI_CRM_End_of_Dynamic_Route__c
                                                                                                            , ASI_CRM_User__c
                                                                                                            , ASI_CRM_Type__c
                                                                                                            , ASI_CRM_Approval_Limit__c//20170515 Added
                                                                                                            FROM ASI_CRM_Dynamic_Approval_Route__c
                                                                                                            WHERE ASI_CRM_Type__c LIKE 'Sales Order%'
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
                                                                                                , ASI_CRM_CN_Approval_Limit_7__c //20181113 Added
                                                                                                , ASI_CRM_CN_Approval_Limit_8__c //20181113 Added
                                                                                                , ASI_CRM_CN_Approval_Limit_9__c //20181113 Added
                                                                                                , ASI_CRM_CN_Approval_Limit_10__c //20181113 Added
                                                                                                , ASI_CRM_CN_Approval_Limit_11__c //20181113 Added
                                                                                                , ASI_CRM_CN_Approver_1__c
                                                                                                , ASI_CRM_CN_Approver_2__c
                                                                                                , ASI_CRM_CN_Approver_3__c
                                                                                                , ASI_CRM_CN_Approver_4__c
                                                                                                , ASI_CRM_CN_Approver_5__c
                                                                                                , ASI_CRM_CN_Approver_6__c
                                                                                                , ASI_CRM_CN_Approver_7__c //20181113 Added
                                                                                                , ASI_CRM_CN_Approver_8__c //20181113 Added
                                                                                                , ASI_CRM_CN_Approver_9__c //20181113 Added
                                                                                                , ASI_CRM_CN_Approver_10__c //20181113 Added
                                                                                                , ASI_CRM_CN_Approver_11__c //20181113 Added
                                                                                                , ASI_CRM_CN_Region_Area_Channel__c
                                                                                                , ASI_CRM_IHBR__c
                                                                                                , ASI_CRM_VIP__c
                                                                                                , ASI_CRM_Channel__c
                                                                                                , ASI_CRM_Commercial_Team__c
                                                                                                , ASI_CRM_Channel__r.Name
                                                                                                FROM ASI_CRM_Fix_Approval_Route__c
                                                                                                WHERE ASI_CRM_CN_Type__c LIKE 'Sales Order%'
                                                                                               ]);

        // 20190612 start
        Set<Id> customerIdSet = new Set<Id>();

        for(ASI_KOR_Sales_Order_Request__c obj : triggerNew){

            customerIdSet.add(obj.ASI_CRM_CN_Customer__c);
        }

        Map<id, ASI_CRM_AccountsAdditionalField__c> mapCustomer =
                new Map<Id, ASI_CRM_AccountsAdditionalField__c>([SELECT id, ASI_CRM_CN_Commercial_Team__c, ASI_CRM_CN_NewChannel__c, ASI_CRM_CN_Region__c, ASI_CRM_CN_CCity__c
                FROM ASI_CRM_AccountsAdditionalField__c
                WHERE id IN : customerIdSet]);

        Map<Id, ASI_FOC_Delivery_Zone__c> customerDeliveryZoneMap = findDeliverZoneByCustomer(mapCustomer);
        system.debug('customerDeliveryZoneMap:' + customerDeliveryZoneMap);
        // 20190612 end

        for(ASI_KOR_Sales_Order_Request__c salesOrderObj : triggerNew){
            // 20190612 start
            if((customerDeliveryZoneMap != null && salesOrderObj.ASI_CRM_CN_Customer__c != null
                    && customerDeliveryZoneMap.containsKey(salesOrderObj.ASI_CRM_CN_Customer__c)
                    && customerDeliveryZoneMap.get(salesOrderObj.ASI_CRM_CN_Customer__c) != null
                    && customerDeliveryZoneMap.get(salesOrderObj.ASI_CRM_CN_Customer__c).Id != null)
                    && (triggerOldMap.containsKey(salesOrderObj.id) && triggerOldMap.get(salesOrderObj.id) != null
                    && triggerOldMap.get(salesOrderObj.id).ASI_CRM_CN_Customer__c != salesOrderObj.ASI_CRM_CN_Customer__c)) {
                salesOrderObj.ASI_CRM_Delivery_Zone__c = customerDeliveryZoneMap.get(salesOrderObj.ASI_CRM_CN_Customer__c).Id;
            }
            // 20190612 end

            if((salesOrderObj.ASI_KOR_Order_Status__c == 'Submitted' && triggerOldMap.get(salesOrderObj.id).ASI_KOR_Order_Status__c == 'Open')
			   /* [VL 1.0] BEGIN */
			   /*
               || (salesOrderObj.ASI_KOR_Order_Status__c == 'Open' && triggerOldMap.get(salesOrderObj.id).ASI_KOR_Order_Status__c == 'Submitted')
			   */
			   /* [VL 1.0] END */
              ){
                  
                  //20170525 sales order allocation logic
				  /* [VL 1.0] BEGIN */
				  /*
                  //20180320 Introv added Premium sub region logic
                  Id regionId = mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c.containsIgnoreCase('Premium') 
                      && mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_Sub_Region__c != Null ? 
                      mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_Sub_Region__c : mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c;
                  */
				  /* [VL 1.0] END */
				  
                  regionSet.add(mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c);
				  /* [VL 1.0] BEGIN */
				  /*
                  regionSet.add(regionId);
				  */
				  /* [VL 1.0] END */
                  
                  commercialTeamSet.add(mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c);
				  
                  if(startDate == Null || startDate > salesOrderObj.ASI_CRM_SG_Order_Date__c)
                      startDate = salesOrderObj.ASI_CRM_SG_Order_Date__c;
                  
                  if(endDate == Null || endDate < salesOrderObj.ASI_CRM_SG_Order_Date__c)
                      endDate = salesOrderObj.ASI_CRM_SG_Order_Date__c;
                  
                  //20170525 End
                  /* [VL 1.0] BEGIN */
				  /*
                  if(salesOrderObj.ASI_KOR_Order_Status__c == 'Submitted')
				  */
				  /* [VL 1.0] END */
                  
                      headerId.add(salesOrderObj.id);
                  
                  /* [VL 1.0] BEGIN */
				  /*
                  //20180321 Introv
                  if(salesOrderObj.ASI_KOR_Order_Status__c == 'Open')
                      rejectHeaderId.add(salesOrderObj.id);
				  */
				  /* [VL 1.0] END */
                  
                  //20170724 Introv
                  updateAllocationRecord = True;
              }
            
            //20170724 Introv
		    /* [VL 1.0] BEGIN */
		    /* comment the following commented code
            /*if(salesOrderObj.ASI_KOR_Order_Status__c == 'Open' && triggerOldMap.get(salesOrderObj.id).ASI_KOR_Order_Status__c == 'Submitted'){
                
                updateAllocationRecord = True;
            }*/
			/**/
			if(salesOrderObj.ASI_KOR_Order_Status__c == 'Open' && triggerOldMap.get(salesOrderObj.id).ASI_KOR_Order_Status__c == 'Submitted'){
                
                updateAllocationRecord = True;
            }
			/* [VL 1.0] END */
        }
        
        for(ASI_CRM_Dynamic_Approval_Route__c obj : dynamicRoute)
            mapDynamicRoute.put(obj.ASI_CRM_User__c + '' + obj.ASI_CRM_Type__c, obj);
        
        for(ASI_CRM_Fix_Approval_Route__c obj : fixRoute){
            if(obj.ASI_CRM_CN_Type__c == 'Sales Order - MOT'){ //20181113 Added
                mapFixRoute.put(obj.ASI_CRM_CN_Type__c + '', obj);
            } else
            if(obj.ASI_CRM_CN_Type__c == 'Sales Order - RTD'){
                if(obj.ASI_CRM_CN_Region_Area_Channel__c != null && obj.ASI_CRM_CN_Region_Area_Channel__c != '')
                	mapFixRoute.put(obj.ASI_CRM_CN_Type__c + obj.ASI_CRM_CN_Region_Area_Channel__c, obj);
                else
                    mapFixRoute.put(obj.ASI_CRM_CN_Type__c + '', obj);
            }else{

                String Key = obj.ASI_CRM_CN_Type__c;
                Key += obj.ASI_CRM_Commercial_Team__c != NULL ? obj.ASI_CRM_Commercial_Team__c : '';
                Key += obj.ASI_CRM_VIP__c ? 'TRUE' : 'FALSE';
                key += obj.ASI_CRM_IHBR__c ? 'TRUE' : 'FALSE';
                key += obj.ASI_CRM_Channel__c != NULL ? obj.ASI_CRM_Channel__r.Name : '';
                key += obj.ASI_CRM_CN_Region_Area_Channel__c != NULL ? obj.ASI_CRM_CN_Region_Area_Channel__c : '';

                mapFixRoute.put(key, obj);
            }
        }
        
        for(ASI_KOR_Sales_Order_Transaction__c obj : salesOrderLineItem){
            if(obj.ASI_CRM_CN_Promotion_Code__c != null)
            	isPromotionCodeExist.put(obj.ASI_KOR_Sales_Order_Request__c, TRUE);
            
            if((headerId.contains(obj.ASI_KOR_Sales_Order_Request__c)
				/* [VL 1.0] BEGIN */
				/*
				|| rejectHeaderId.contains(obj.ASI_KOR_Sales_Order_Request__c)
				*/
				/* [VL 1.0] END */
			) //20180321 Introv added rejectHeaderId.contains(obj.ASI_KOR_Sales_Order_Request__c)
               && ((regionSet.contains(obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c))
					/* [VL 1.0] BEGIN */
					/*
                   || ( regionSet.contains(obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_Sub_Region__c)
                       && obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c.containsIgnoreCase('Premium'))
					*/
					/* [VL 1.0] END */
                   )
               && commercialTeamSet.contains(obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c)
               && triggerOldMap.get(obj.ASI_KOR_Sales_Order_Request__c).ASI_CRM_SG_Order_Date__c >= startDate
               && triggerOldMap.get(obj.ASI_KOR_Sales_Order_Request__c).ASI_CRM_SG_Order_Date__c <= endDate
              ){
                  
                  itemGroupSet.add(obj.ASI_CRM_CN_Product_Name__c);
              }
        }
        
        //20170526
        if(itemGroupSet.size() > 0 ) {
            allOverSO = calculateRemainingQty(headerId, regionSet, itemGroupSet, commercialTeamSet, startDate, endDate);
		}
        
        //Loop Trigger New
        for(ASI_KOR_Sales_Order_Request__c salesOrderObj : triggerNew){
            
            if(allOverSO.containsKey(salesOrderObj.id)){
                
                hasError = True;
                salesOrderObj.addError(allOverSo.get(salesOrderObj.id));
                break;
            }
            //20151103 Ben @ Elufa
            /*if(salesOrderLineItem.size() > 0 && triggerOldMap.get(salesOrderObj.id).ASI_CRM_UOM__c != salesOrderObj.ASI_CRM_UOM__c){
                salesOrderObj.addError('UOM can not be changed.');
                break;
            }*/
            
            //20160926, added by Leo
            if(salesOrderLineItem.size() > 0 && triggerOldMap.get(salesOrderObj.id).ASI_CRM_CN_Premium__c != salesOrderObj.ASI_CRM_CN_Premium__c){
                
                hasError = True;
                salesOrderObj.addError('Premium can not be changed.');
                break;
            }
            //20160926, added by Leo
            
            if(salesOrderLineItem.size() > 0 && triggerOldMap.get(salesOrderObj.id).ASI_CRM_CN_RTD__c != salesOrderObj.ASI_CRM_CN_RTD__c){
                
                hasError = True;
                salesOrderObj.addError('RTD can not be changed.');
                break;
            }
            
            if(triggerOldMap.get(salesOrderObj.id).ASI_CRM_CN_Customer__c != salesOrderObj.ASI_CRM_CN_Customer__c){
                
                hasError = True;
                salesOrderObj.addError('Customer can not be changed.');
                break;
            }
            
            if(!mapUser.containsKey(salesOrderObj.OwnerId)){
                
                hasError = True;
                salesOrderObj.addError('For Pernod Ricard China staff only.');
                break;
            }
            
            if(salesOrderObj.ASI_KOR_Order_Status__c != 'Open')
                Continue;
            
            setApproverToNull(salesOrderObj);
            
            //boolean wsManager = mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_Is_IHBR_Outlet__c ? FALSE : TRUE;//recordType.developerName == 'ASI_CRM_CN_WS' ? TRUE : FALSE;
            //20160803 Ben @ Elufa
            Boolean WSorOutlet = mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.recordType.developerName.Contains('ASI_CRM_CN_WS') ? TRUE : FALSE;
            String Key = 'Sales Order - ' + (WSorOutlet ? 'WS' : 'Outlet');

            if(mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_Is_IHBR_Outlet__c && mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c == 'HQ/Hotel'){

                setDynamicApprover(salesOrderObj, mapUser, mapDynamicRoute, 'Sales Order - IHBR');
            }

            if (mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_Customer_Type_Picklist__c == 'MOT') { //20181106 Alan Lau
                Key = 'Sales Order - MOT';
                setFixApprover(salesOrderObj, mapFixRoute, isPromotionCodeExist, Key);
            }
            //RTD
            else if (salesOrderObj.ASI_CRM_CN_RTD__c) {

                setFixApprover(salesOrderObj, mapFixRoute, isPromotionCodeExist, ('Sales Order - RTD' + mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_Region__c));
            } else {

                Key += mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c != NULL ? mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c : '';
                Key += mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_NewChannel__r.Name == 'VIP' || mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_VIP__c ? 'TRUE' : 'FALSE';
                Key += mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_Is_IHBR_Outlet__c ? 'TRUE' : 'FALSE';
                Key += mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_NewChannel__c != NULL ? mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_NewChannel__r.Name : '';
                Key += mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_Region__c != NULL ? mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_Region__c : '';

                setFixApprover(salesOrderObj, mapFixRoute, isPromotionCodeExist, Key);
            }
            
            //20160803 End
            
            //RTD
            /*if(salesOrderObj.ASI_CRM_CN_RTD__c){
                
                setFixApprover(salesOrderObj, mapFixRoute, isPromotionCodeExist, mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_Region__c, 'Sales Order - RTD', FALSE, wsManager);
            
            // VIP & E-Commerce
            //}else if(mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_Sub_Channel__r.Name == 'VIP' || mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_Sub_Channel__r.Name == 'E-Commerce'){
              
            }else if(mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_Sub_Channel__r.Name == 'VIP' || mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_VIP__c){
                
                setFixApprover(salesOrderObj, mapFixRoute, isPromotionCodeExist, '', 'Sales Order - VIP', FALSE, wsManager);
                
            }else if(mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_Sub_Channel__r.Name == 'E-Commerce'){
                
                setFixApprover(salesOrderObj, mapFixRoute, isPromotionCodeExist, '', 'Sales Order - eCommerce', FALSE, wsManager);
                
			//Dynamic Route
            //}else if(mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_Is_IHBR_Outlet__c || mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_Region__c == 'Headquarter'){
             
            }else if(mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_Is_IHBR_Outlet__c){
                
                setDynamicApprover(salesOrderObj, mapUser, mapDynamicRoute, 'Sales Order - IHBR');
                setFixApprover(salesOrderObj, mapFixRoute, isPromotionCodeExist, '', 'Sales Order - IHBR', TRUE, wsManager);
                
            }else if(mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_Region__c == 'Headquarter'){
                
                setDynamicApprover(salesOrderObj, mapUser, mapDynamicRoute, 'Sales Order - HQ');
                setFixApprover(salesOrderObj, mapFixRoute, isPromotionCodeExist, 'Headquarter', 'Sales Order - HQ', TRUE, wsManager);
                
			//Fix Route
            }else{
                setFixApprover(salesOrderObj, mapFixRoute, isPromotionCodeExist, mapSalesOrder.get(salesOrderObj.id).ASI_CRM_CN_Customer__r.ASI_CRM_CN_Region__c, 'Sales Order', FALSE, wsManager);
            }*/
        }
        
        if(!system.isBatch() && !system.isFuture() && updateAllocationRecord)
            updateAllocation(allocationSet);
    
    	//20190722@AM-Introv - fix missing approved email notification
    	checkStatusUpdate2Approved(triggerNew, triggerOldMap);
    }
    
    //20190722@AM-Introv - fix missing approved email notification (start)
    public static void checkStatusUpdate2Approved(List<ASI_KOR_Sales_Order_Request__c> triggerNew, Map<id, ASI_KOR_Sales_Order_Request__c> triggerOldMap) {
        for(ASI_KOR_Sales_Order_Request__c oNewSO : triggerNew){
            if((oNewSO.ASI_KOR_Order_Status__c == 'Approved' && triggerOldMap.get(oNewSO.id).ASI_KOR_Order_Status__c != 'Approved')){
                oNewSO.ASI_CRM_SYS_Send_Approved_Notification__c = TRUE;
            }
        }
    }
    //20190722@AM-Introv - fix missing approved email notification (end)
    
	/* [VL 2.0] BEGIN */
    public static void afterUpdateMethod(List<ASI_KOR_Sales_Order_Request__c> triggerNew, Map<id, ASI_KOR_Sales_Order_Request__c> triggerOldMap){
        
        Set<String> rejectHeaderId = new Set<String>(); 
        
        for(ASI_KOR_Sales_Order_Request__c salesOrderObj : triggerNew){

            if((salesOrderObj.ASI_KOR_Order_Status__c == 'Open' && triggerOldMap.get(salesOrderObj.id).ASI_KOR_Order_Status__c == 'Submitted')){
                rejectHeaderId.add(salesOrderObj.id);
            }
        }
		
		if(rejectHeaderId.size()>0){
			rollbackSplitPromotionQty(rejectHeaderId);
		}
        
    }
	
	public static void rollbackSplitPromotionQty(Set<String> rejectHeaderId){
		map<string, ASI_KOR_Sales_Order_Transaction__c> map_line = new map<string, ASI_KOR_Sales_Order_Transaction__c>();
		list<ASI_KOR_Sales_Order_Transaction__c> list_toDelete = new list<ASI_KOR_Sales_Order_Transaction__c>();
		list<ASI_KOR_Sales_Order_Transaction__c> list_toUpdate = new list<ASI_KOR_Sales_Order_Transaction__c>();
		
		for(ASI_KOR_Sales_Order_Transaction__c line : [
			select 
				id, ASI_KOR_Sales_Order_Request__c, ASI_KOR_Order_Qty__c, ASI_CRM_Sales_Order_Request_Item__c
			from ASI_KOR_Sales_Order_Transaction__c
			where 
				ASI_KOR_Sales_Order_Request__c in :rejectHeaderId
				AND ASI_CRM_Sales_Order_Request_Item__c <> null
		]){
			string key = line.ASI_KOR_Sales_Order_Request__c + '_' + line.ASI_CRM_Sales_Order_Request_Item__c;
			map_line.put(key, line);
			list_toDelete.add(line);
		}
		
		for(ASI_KOR_Sales_Order_Transaction__c line : [
			select 
				id, ASI_KOR_Sales_Order_Request__c, ASI_KOR_Order_Qty__c, ASI_CRM_Sales_Order_Request_Item__c
			from ASI_KOR_Sales_Order_Transaction__c
			where 
				ASI_KOR_Sales_Order_Request__c in :rejectHeaderId
				AND ASI_CRM_Sales_Order_Request_Item__c = null
		]){
			string key = line.ASI_KOR_Sales_Order_Request__c + '_' + line.Id;
			if(map_line.containsKey(key)){
				ASI_KOR_Sales_Order_Transaction__c clonedLine = map_line.get(key);
				line.ASI_KOR_Order_Qty__c += clonedLine.ASI_KOR_Order_Qty__c;
				list_toUpdate.add(line);
			}
		}
		
		if(list_toDelete.size() > 0){
			delete list_toDelete;
		}
		if(list_toUpdate.size() > 0){
			update list_toUpdate;
		}
	}
	/* [VL 2.0] END */
    
    @future
    public Static void updateAllocation(Set<Id> allocationSet){
        
        if(allocationSet.size() > 0){
            try{
                
                List<ASI_CRM_Item_Group_Allocation__c> updateList = new List<ASI_CRM_Item_Group_Allocation__c>();
                
                for(id allocationId : allocationSet){
                    
                    updateList.add(new ASI_CRM_Item_Group_Allocation__c(id = allocationId));
                }
                
                Update updateList;
                
            }catch(dmlException dmle){
                
            }
        }
    }
    
    private static void setDynamicApprover(ASI_KOR_Sales_Order_Request__c salesOrderObj, Map<ID, User> mapUser, Map<String, ASI_CRM_Dynamic_Approval_Route__c> mapDynamicRoute, String dynamicApprovalType){
        
        ID approverID = mapUser.get(salesOrderObj.OwnerId).ManagerID;
        String sysApprover;
        
        for(integer i = 1 ; i <= 10 ; i++){
            
            sysApprover = 'ASI_CRM_CN_Sys_Approver_' + i + '__c';
            
            if(mapUser.containsKey(approverID)){
                
                salesOrderObj.put(sysApprover, approverID);
                
                if(mapDynamicRoute.containsKey(approverID + dynamicApprovalType)){
                    if(mapDynamicRoute.get(approverID + dynamicApprovalType).ASI_CRM_End_of_Dynamic_Route__c || (mapDynamicRoute.get(approverID + dynamicApprovalType).ASI_CRM_Approval_Limit__c != Null && salesOrderObj.ASI_CRM_CN_Total_order_Amt__c <= mapDynamicRoute.get(approverID + dynamicApprovalType).ASI_CRM_Approval_Limit__c)){
                    	break;
                    }
                }
                
                approverID = mapUser.get(approverID).ManagerID;
                
            }else break;
        }
    }
    
    private static void setFixApprover(ASI_KOR_Sales_Order_Request__c salesOrderObj, Map<String, ASI_CRM_Fix_Approval_Route__c> mapFixRoute, Map<id, Boolean> isPromotionCodeExist, String Key){
        
        String fixApprover;
        String fixApproverLimit;
        String sysApprover;
        List<String> sysApproverList = new List<String>();
        integer sysApproverNumber = 1;
        integer approverNumber = 1;
        integer sysApproverListIndex = 0;
            
        for(integer i = 1 ; i <= 11 ; i++){
            sysApprover = 'ASI_CRM_CN_Sys_Approver_' + i + '__c';
            if(salesOrderObj.get(sysApprover) == null){
                sysApproverList.add(sysApprover);
            }
        }
        
        while(approverNumber <= 11){
            
            fixApprover = 'ASI_CRM_CN_Approver_'+ approverNumber +'__c';
            fixApproverLimit = 'ASI_CRM_CN_Approval_Limit_'+ approverNumber +'__c';
            
            if(mapFixRoute.containsKey(Key)){
				system.debug('check3');
                
                if(mapFixRoute.get(Key).get(fixApprover) != null){
                    
                    salesOrderObj.put(sysApproverList[sysApproverListIndex], mapFixRoute.get(Key).get(fixApprover));
                    sysApproverListIndex++;
                    
                    if(sysApproverListIndex >= sysApproverList.size())
                        break;
                }
                
                if(mapFixRoute.get(Key).get(fixApproverLimit) != null && salesOrderObj.ASI_CRM_CN_Total_order_Amt__c <= Double.valueOf(mapFixRoute.get(Key).get(fixApproverLimit)) && salesOrderObj.ASI_CRM_CN_Customer__r.ASI_CRM_Customer_Type_Picklist__c != 'MOT'){
                    break;
                } else if(mapFixRoute.get(Key).get(fixApproverLimit) != null && salesOrderObj.ASI_CRM_Total_Promotion_Cost__c <= Double.valueOf(mapFixRoute.get(Key).get(fixApproverLimit)) && salesOrderObj.ASI_CRM_CN_Customer__r.ASI_CRM_Customer_Type_Picklist__c == 'MOT') { //20181106 Alan Lau
                    break;
                }
            }
            approverNumber++;
        }
        
        if(isPromotionCodeExist.containsKey(salesOrderObj.id)){
            
            while(sysApproverNumber <= 11){
                if(salesOrderObj.get('ASI_CRM_CN_Sys_Approver_' + sysApproverNumber + '__c') != null)
                    sysApproverNumber++;
                else
                    break;
            }
            if(mapFixRoute.containsKey(Key))
            	salesOrderObj.put('ASI_CRM_CN_Sys_Approver_' + sysApproverNumber + '__c', mapFixRoute.get(Key).ASI_CRM_CN_Regional_BA__c);
        }
    }
    
    public static void setApproverToNull(ASI_KOR_Sales_Order_Request__c salesOrderObj){
        
        String sysApprover;
        
        for(integer i = 1 ; i <=11 ; i++){
            sysApprover = 'ASI_CRM_CN_Sys_Approver_' + i + '__c';
            salesOrderObj.put(sysApprover,null);
        }
    }
    
    Private Static Map<Id, String> calculateRemainingQty(Set<Id> headerId, Set<id> regionSet, Set<Id> itemGroupSet, Set<String> commercialTeamSet, Date Startdate, Date endDate){
        
        Startdate = date.newInstance(Startdate.year(), Startdate.month(), 1);
        endDate = date.newInstance(endDate.year(), endDate.month(), date.daysInMonth(endDate.year(), endDate.month()));
        Set<Id> allocatedItemGroup = new Set<Id>();
        Map<Id, String> overAllocatedQty = new Map<Id, String>();
        Map<String, ASI_CRM_Item_Group_Allocation__c> allocationMap = new Map<String, ASI_CRM_Item_Group_Allocation__c>();
        allocationSet = new Set<Id>();
        
        for(ASI_CRM_Item_Group_Allocation__c allocationItem : [SELECT id
                                                               , ASI_CRM_Allocation_Quantity_Bottle__c
                                                               , ASI_CRM_Commercial_Team__c
                                                               , ASI_CRM_Effective_Date__c
                                                               , ASI_CRM_Item_Group__c
                                                               , ASI_CRM_Region__c
                                                               , ASI_CRM_MTD_Order_Quantity__c
															   /* [VL 3.0] BEGIN */
															   , ASI_CRM_Customer__c
															   , ASI_CRM_Channel__c
															   /* [VL 3.0] END */
                                                               FROM ASI_CRM_Item_Group_Allocation__c
                                                               WHERE ASI_CRM_Effective_Date__c >= : startDate
                                                               AND ASI_CRM_Effective_Date__c <= : endDate
                                                               AND ASI_CRM_Item_Group__c IN : itemGroupSet
                                                               AND ASI_CRM_Region__c IN : regionSet
                                                               AND ASI_CRM_Inactive__c = False
                                                               AND recordType.developerName Like '%_CN_%']){
            
			/* [VL 3.0] BEGIN */
			/*
            String Key = '' + allocationItem.ASI_CRM_Item_Group__c + allocationItem.ASI_CRM_Region__c + allocationItem.ASI_CRM_Commercial_Team__c + String.valueOf(date.newInstance(allocationITem.ASI_CRM_Effective_Date__c.year(), allocationITem.ASI_CRM_Effective_Date__c.month(), 1));
			*/
            String allocationKey = '' +
						 allocationItem.ASI_CRM_Customer__c + '_' +
						 allocationItem.ASI_CRM_Channel__c + '_' +
						 allocationItem.ASI_CRM_Item_Group__c + '_' +
						 allocationItem.ASI_CRM_Region__c + '_' +
						 allocationItem.ASI_CRM_Commercial_Team__c + '_' +
						 String.valueOf(date.newInstance(allocationITem.ASI_CRM_Effective_Date__c.year(), allocationITem.ASI_CRM_Effective_Date__c.month(), 1));
			/* [VL 3.0] END */
            
            allocatedItemGroup.add(allocationItem.ASI_CRM_Item_Group__c);
            
            allocationItem.ASI_CRM_MTD_Order_Quantity__c = 0;
            allocationMap.put(allocationKey, allocationItem);
            allocationSet.add(allocationItem.id);
        }

        if(allocatedItemGroup.size() > 0){
            
            for(ASI_KOR_Sales_Order_Transaction__c obj : [SELECT id
                                                          , ASI_CRM_CN_Product_Name__c
                                                          , ASI_CRM_CN_Product_Name__r.Name
                                                          , ASI_CRM_Order_Qty_Bottle__c
                                                          , ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                                          , ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c
														  /* [VL 3.0] BEGIN */
                                                          , ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__c
                                                          , ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_NewChannel__c
														  /* [VL 3.0] END */
														  /* [VL 1.0] BEGIN */
														  /*
                                                          , ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_Sub_Region__c //20180320 Introv
                                                          */
														  /* [VL 1.0] END */
														  , ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c
                                                          , ASI_KOR_Sales_Order_Request__c
                                                          FROM ASI_KOR_Sales_Order_Transaction__c
                                                          WHERE ASI_CRM_CN_Product_Name__c IN : allocatedItemGroup
                                                          AND (ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c IN : regionSet
															/* [VL 1.0] BEGIN */
															/*
                                                               OR (ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_Sub_Region__c IN : regionSet
                                                                   AND ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c LIKE 'Premium')
															*/
															/* [VL 1.0] END */
                                                               )//20180320 Introv
                                                          AND ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c IN : commercialTeamSet
                                                          AND ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c >= : startDate
                                                          AND ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c <= : endDate
                                                          AND ((NOT ASI_KOR_Sales_Order_Request__r.ASI_KOR_Order_Status__c Like 'Open')
                                                               OR ASI_KOR_Sales_Order_Request__c IN : headerId
                                                              )
                                                          AND RecordType.developerName Like '%_CN_%']){
                
				/* [VL 1.0] BEGIN */
				/*
                //20180320 Introv added Premium sub region logic
                Id regionId = obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c.containsIgnoreCase('Premium') 
                    && obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_Sub_Region__c != Null ? 
                    obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_Sub_Region__c : obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c;
                				
                String key = '' + obj.ASI_CRM_CN_Product_Name__c + regionId 
					//obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c 
					+ obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c + String.valueOf(date.newInstance(obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c.year(), obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c.month(), 1));
                */
				/* [VL 3.0] BEGIN */
				/*
				String key = '' + obj.ASI_CRM_CN_Product_Name__c + obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c + obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c + String.valueOf(date.newInstance(obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c.year(), obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c.month(), 1));
				*/
				String key1 = '' +
							 obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__c + '_' +
							 obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_NewChannel__c + '_' +
							 obj.ASI_CRM_CN_Product_Name__c + '_' +
							 obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c + '_' +
							 obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c + '_' +
							 String.valueOf(date.newInstance(obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c.year(), obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c.month(), 1));

                // 20190626 Wilson Chow
                String key2 = 'null_' +
                        obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_NewChannel__c + '_' +
                        obj.ASI_CRM_CN_Product_Name__c + '_' +
                        obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c + '_' +
                        obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c + '_' +
                        String.valueOf(date.newInstance(obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c.year(), obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c.month(), 1));

                String key3 = 'null_null_' +
                        obj.ASI_CRM_CN_Product_Name__c + '_' +
                        obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c + '_' +
                        obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c + '_' +
                        String.valueOf(date.newInstance(obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c.year(), obj.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c.month(), 1));

                system.debug('calculateRemainingQty key1:' + key1);
                system.debug('calculateRemainingQty key2:' + key2);
                system.debug('calculateRemainingQty key3:' + key3);

                ASI_CRM_Item_Group_Allocation__c tmp =
                        (allocationMap.containsKey(key1) ? allocationMap.get(key1)
                                : allocationMap.containsKey(key2) ? allocationMap.get(key2)
                                        : allocationMap.containsKey(key3) ? allocationMap.get(key3) : null);
                String finalKey =
                        (allocationMap.containsKey(key1) ? key1
                                : allocationMap.containsKey(key2) ? key2
                                : allocationMap.containsKey(key3) ? key3 : null);

                system.debug('allocation map item:' + tmp);
                system.debug('final key:' + finalKey);
                /*
                if(allocationMap.containsKey(key1)) {
                    tmp = allocationMap.get(key1);
                    finalKey = key1;
                }
                else if(allocationMap.containsKey(key2)) {
                    tmp = allocationMap.get(key2);
                    finalKey = key2;
                }
                else if(allocationMap.containsKey(key3)) {
                    tmp = allocationMap.get(key3);
                    finalKey = key3;
                }
                */
                // 20190626 Wilson Chow
                /* [VL 3.0] END */
				/* [VL 1.0] END */

                // 20190626 Wilson Chow
                /*
                if(allocationMap.containsKey(Key)){
                */
                if(tmp != null){
                    /*
                    ASI_CRM_Item_Group_Allocation__c tmp = allocationMap.get(Key);
                    */
                    tmp.ASI_CRM_MTD_Order_Quantity__c = tmp.ASI_CRM_MTD_Order_Quantity__c + obj.ASI_CRM_Order_Qty_Bottle__c;
                    /*
                    allocationMap.put(Key, tmp);
                    */
                    allocationMap.put(finalKey, tmp);
                // 20190626 Wilson Chow
                    if(tmp.ASI_CRM_MTD_Order_Quantity__c > tmp.ASI_CRM_Allocation_Quantity_Bottle__c){
                        if(overAllocatedQty.containsKey(obj.ASI_KOR_Sales_Order_Request__c)){
                            
                            String msg = overAllocatedQty.get(obj.ASI_KOR_Sales_Order_Request__c) + ', ' + obj.ASI_CRM_CN_Product_Name__r.Name;
                            overAllocatedQty.put(obj.ASI_KOR_Sales_Order_Request__c, msg);
                            
                        }else{
                            
                            String msg = 'The following item groups over the allocated Qty: ' + obj.ASI_CRM_CN_Product_Name__r.Name;
                            overAllocatedQty.put(obj.ASI_KOR_Sales_Order_Request__c, msg);
                        }
                    }
                }
            }
            
            Return overAllocatedQty;
        }
        Return new Map<Id, String>();
    }

    // 20190612
    @TestVisible
    private static Map<Id, ASI_FOC_Delivery_Zone__c> findDeliverZoneByCustomer(Map<id, ASI_CRM_AccountsAdditionalField__c> mapCustomer) {
        Map<Id, ASI_FOC_Delivery_Zone__c> customerDeliveryZoneMap = null;

        if(mapCustomer != null && !mapCustomer.isEmpty()) {

            Set<Id> channelSet = new Set<Id>();
            Set<String> regionSet = new Set<String>();
            Set<String> commercialTeamSet = new Set<String>();
            Set<Id> cityToSet = new Set<Id>();


            for (id key : mapCustomer.keySet()) {
                ASI_CRM_AccountsAdditionalField__c mapValue = mapCustomer.get(key);

                if (mapValue.ASI_CRM_CN_NewChannel__c != null
                        && !channelSet.contains(mapValue.ASI_CRM_CN_NewChannel__c)) {
                    channelSet.add(mapValue.ASI_CRM_CN_NewChannel__c);
                }

                if (String.isNotBlank(mapValue.ASI_CRM_CN_Region__c)
                        && !regionSet.contains(mapValue.ASI_CRM_CN_Region__c)) {
                    regionSet.add(mapValue.ASI_CRM_CN_Region__c);
                }

                if (String.isNotBlank(mapValue.ASI_CRM_CN_Commercial_Team__c)
                        && !commercialTeamSet.contains(mapValue.ASI_CRM_CN_Commercial_Team__c)) {
                    commercialTeamSet.add(mapValue.ASI_CRM_CN_Commercial_Team__c);
                }

                if (mapValue.ASI_CRM_CN_CCity__c != null
                        && !cityToSet.contains(mapValue.ASI_CRM_CN_CCity__c)) {
                    cityToSet.add(mapValue.ASI_CRM_CN_CCity__c);
                }
            }

            List<ASI_FOC_Delivery_Zone__c> deliveryZoneList = [
                    SELECT Id, ASI_CRM_Customer__c, ASI_CRM_Channel__c, ASI_CRM_Region__c, ASI_CRM_Commercial_Team__c, ASI_FOC_City_To__c
                    FROM ASI_FOC_Delivery_Zone__c
                    WHERE ((ASI_CRM_Customer__c in :mapCustomer.keySet()
                    AND ASI_CRM_Channel__c in :channelSet
                    AND ASI_CRM_Region__c in :regionSet
                    AND ASI_CRM_Commercial_Team__c in :commercialTeamSet
                    AND ASI_FOC_City_To__c in :cityToSet)
                    OR (ASI_CRM_Channel__c in :channelSet
                    AND ASI_CRM_Region__c in :regionSet
                    AND ASI_CRM_Commercial_Team__c in :commercialTeamSet
                    AND ASI_FOC_City_To__c in :cityToSet)
                    OR (ASI_CRM_Region__c in :regionSet
                    AND ASI_CRM_Commercial_Team__c in :commercialTeamSet
                    AND ASI_FOC_City_To__c in :cityToSet))
                    AND Id != null
                    ORDER BY ASI_CRM_Customer__c DESC NULLS LAST,
                            ASI_CRM_Channel__c DESC NULLS LAST,
                            ASI_CRM_Region__c DESC NULLS LAST,
                            ASI_CRM_Commercial_Team__c DESC NULLS LAST,
                            ASI_FOC_City_To__c DESC NULLS LAST
            ];

            map<string, ASI_FOC_Delivery_Zone__c> map_deliveryZone = new map<string, ASI_FOC_Delivery_Zone__c>();
            for (ASI_FOC_Delivery_Zone__c d : deliveryZoneList) {
                string key = d.ASI_CRM_Region__c + +'_' +
                        d.ASI_CRM_Commercial_Team__c + '_' +
                        d.ASI_FOC_City_To__c + '_' +
                        d.ASI_CRM_Channel__c + '_' +
                        d.ASI_CRM_Customer__c;
                map_deliveryZone.put(key, d);
            }
            system.debug(map_deliveryZone);

            if (deliveryZoneList != null && !deliveryZoneList.isEmpty()) {
                for (id customerId : mapCustomer.keySet()) {
                    ASI_CRM_AccountsAdditionalField__c c = mapCustomer.get(customerId);
                    string key1 = c.ASI_CRM_CN_Region__c + '_' + c.ASI_CRM_CN_Commercial_Team__c + '_' + c.ASI_CRM_CN_CCity__c + '_' + c.ASI_CRM_CN_NewChannel__c + '_' + c.Id;
                    string key2 = c.ASI_CRM_CN_Region__c + '_' + c.ASI_CRM_CN_Commercial_Team__c + '_' + c.ASI_CRM_CN_CCity__c + '_' + c.ASI_CRM_CN_NewChannel__c + '_null';
                    string key3 = c.ASI_CRM_CN_Region__c + '_' + c.ASI_CRM_CN_Commercial_Team__c + '_' + c.ASI_CRM_CN_CCity__c + '_null_null';

                    system.debug(key1);
                    system.debug(key2);
                    system.debug(key3);

                    if ((map_deliveryZone.containsKey(key1)
                            || map_deliveryZone.containsKey(key2)
                            || map_deliveryZone.containsKey(key3))
                                && customerDeliveryZoneMap == null) {
                        customerDeliveryZoneMap = new Map<Id, ASI_FOC_Delivery_Zone__c>();
                    }

                    if (map_deliveryZone.containsKey(key1)) {
                        customerDeliveryZoneMap.put(customerId, map_deliveryZone.get(key1));
                    }
                    else if (map_deliveryZone.containsKey(key2)) {
                        customerDeliveryZoneMap.put(customerId, map_deliveryZone.get(key2));
                    }
                    else if (map_deliveryZone.containsKey(key3)) {
                        customerDeliveryZoneMap.put(customerId, map_deliveryZone.get(key3));
                    }
                }
            }
        }

        return customerDeliveryZoneMap;
    }
}