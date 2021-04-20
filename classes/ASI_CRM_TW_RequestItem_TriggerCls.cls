public without sharing class ASI_CRM_TW_RequestItem_TriggerCls{
    //Bypass user from specific validation
    private static Boolean isBypassByCurrentUser() {
        Boolean isByPass = false;
        ID curUserId = UserInfo.getUserId();
        List<User> users = [SELECT Id, BypassTriggers__c FROM User WHERE Id = :curUserId];
        if (users.size() > 0 && users[0].BypassTriggers__c != null) {
            if (users[0].BypassTriggers__c.contains('ASI_CRM_TW_FreeGoodsRequest_TriggerCls')){
                isByPass = true;
            }
        }
        return isByPass;
    }
    
    public static void routineBeforeUpsert(list<ASI_FOC_Request_Item__c> trigger_new, map<id, ASI_FOC_Request_Item__c> trigger_oldMap) {
        Set<Id> setSKUId = new Set<Id>();
        Set<Id> setItemGpId = new Set<Id>();
        Set<Id> setPlanLineId = new Set<Id>();
        
        Map<Id, Id> mapSKUbyItemGp = new Map<Id, Id>();
        Map<Id, String> mapPlanLineType = new Map<Id, String>();
        Map<Id, Date> mapPlanLineStartDate = new Map<Id, Date>();
        Map<Id, String> mapPlanLineAccChannel = new Map<Id, String>();
        
        //retrieve default values
        Set<Id> setHeaderId = new Set<Id>();
        Set<Id> setDeliveryToAccId = new Set<Id>();
        Map<Id, ASI_FOC_Free_Goods_Request__c> mapHeader = new Map<Id, ASI_FOC_Free_Goods_Request__c>();
        Map<Id, Account> mapDeliveryToAcc = new Map<Id, Account>();
        
        for(ASI_FOC_Request_Item__c itm : trigger_new){
            setHeaderId.add(itm.ASI_FOC_Request_Order__c);
            setDeliveryToAccId.add(itm.ASI_CRM_Delivery_To__c);       
        }
        
        for(ASI_FOC_Free_Goods_Request__c header : [SELECT ASI_CRM_Target_Outlet__c, ASI_CRM_Delivery_To__c, ASI_CRM_SG_Delivery_Address__c, ASI_CRM_Delivery_Tel__c, ASI_CRM_Receiver__c, ASI_FOC_Request_Status__c FROM ASI_FOC_Free_Goods_Request__c WHERE Id IN: setHeaderId]){
            mapHeader.put(header.id, header);
            setDeliveryToAccId.add(header.ASI_CRM_Delivery_To__c);     
        }
        
        for(Account acc : [SELECT ASI_HK_CRM_Address__c, Phone, (select firstname, lastname from contacts limit 1), (Select Id, ASI_CRM_TW_Warehouse_Address__c From ASI_CRM_Accounts_Additional_Fields__r) FROM Account WHERE Id IN:setDeliveryToAccId]){
            mapDeliveryToAcc.put(acc.id, acc);
        }
        
        //For query SKU Price/Cost
        //String strAccChannel = '';
        List<String> listType = new List<String>();
        listType.add('A&D FOC Unit Cost');
        listType.add('A&P FOC Unit Cost');
        
        //get current user permission sets
        List<PermissionSetAssignment> listCurrentUserPerSet = [SELECT Id FROM PermissionSetAssignment
                                                               WHERE AssigneeId = :Userinfo.getUserId() AND 
                                                               PermissionSet.Name = 'ASI_CRM_TW_OP_Team'];
        
        for(ASI_FOC_Request_Item__c itm : trigger_new){
            setSKUId.add(itm.ASI_FOC_SKU__c); 
            setPlanLineId.add(itm.ASI_CRM_Plan_Line_Item__c);
        }
        
        for(ASI_MFM_SKU_Code__c sku : [SELECT Id, ASI_MFM_Item_Group__c FROM ASI_MFM_SKU_Code__c WHERE Id IN: setSKUId]){
            setItemGpId.add(sku.ASI_MFM_Item_Group__c);
            mapSKUbyItemGp.put(sku.Id, sku.ASI_MFM_Item_Group__c);
        }
        
        //PRA COE 202007: Include Structure cost AC Code into A&P FOC Amount calculation
        for(ASI_MFM_Plan_Line_Item__c pline : [SELECT Id, ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c, ASI_MFM_Customer_Name__r.ASI_MFM_Channel__c, ASI_MFM_Start_Date_Sys__c FROM ASI_MFM_Plan_Line_Item__c WHERE Id IN: setPlanLineId]){
            if(pline.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c == 'Total A&D')
                mapPlanLineType.put(pline.id, 'A&D FOC Unit Cost');
            else if(pline.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c == 'TOTAL A&P' || pline.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c=='Capex' || pline.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c==' Structure Cost' )
                mapPlanLineType.put(pline.id, 'A&P FOC Unit Cost');
            
            mapPlanLineStartDate.put(pline.id, pline.ASI_MFM_Start_Date_Sys__c);
            mapPlanLineAccChannel.put(pline.id, pline.ASI_MFM_Customer_Name__r.ASI_MFM_Channel__c);
            
            //strAccChannel += pline.ASI_MFM_Customer_Name__r.ASI_MFM_Channel__c+';';
        }
        
        //Get all related Item Gp's SKU Price/Cost (A&D & A&P Cost)
        ASI_CRM_TW_ItemGroup_UtilityCls utilityCls = new ASI_CRM_TW_ItemGroup_UtilityCls();
        List<ASI_CRM_MY_SKUPriceCost__c> listSKUPriceCost = utilityCls.getAllChannelSKUpc(/*strAccChannel, */setItemGpId, listType);
        system.debug('listSKUPriceCost: '+listSKUPriceCost);
        
        Boolean isByPass = isBypassByCurrentUser();
        
        for(ASI_FOC_Request_Item__c itm : trigger_new){
            //Validate required fields
            if(itm.ASI_FOC_Request_Quantity_Bottle__c == null)
                itm.addError('Error: Request Quantity cannot be blank.');
            
            //Only SKU is allowed to be edited by OP Team for Approved FOC (by pass admin)
            system.debug('FOC header status: ' + mapHeader.get(itm.ASI_FOC_Request_Order__c).ASI_FOC_Request_Status__c);
            if(!isBypass && (listCurrentUserPerSet == null || listCurrentUserPerSet.size() <= 0)){
                if(mapHeader != NULL && mapHeader.size() > 0 && mapHeader.get(itm.ASI_FOC_Request_Order__c) != NULL && mapHeader.get(itm.ASI_FOC_Request_Order__c).ASI_FOC_Request_Status__c == 'Approved'){
                    itm.addError('You are not allowed to update line item(s) of \'Approved\' Request.');
                }
            }
            
            //retrieve default values from Header if empty        
            if(mapHeader != NULL && mapHeader.size() > 0 && mapHeader.get(itm.ASI_FOC_Request_Order__c) != NULL){
                if(itm.ASI_CRM_Target_Outlet__c == null)
                    itm.ASI_CRM_Target_Outlet__c = mapHeader.get(itm.ASI_FOC_Request_Order__c).ASI_CRM_Target_Outlet__c;
                if(itm.ASI_CRM_Delivery_To__c == null)
                    itm.ASI_CRM_Delivery_To__c = mapHeader.get(itm.ASI_FOC_Request_Order__c).ASI_CRM_Delivery_To__c;
                if(itm.ASI_CRM_Delivery_Address__c == null)
                    itm.ASI_CRM_Delivery_Address__c = mapHeader.get(itm.ASI_FOC_Request_Order__c).ASI_CRM_SG_Delivery_Address__c;
                if(itm.ASI_CRM_Delivery_Tel__c == null)
                    itm.ASI_CRM_Delivery_Tel__c = mapHeader.get(itm.ASI_FOC_Request_Order__c).ASI_CRM_Delivery_Tel__c;
            }        
            
            //retrieve default value of Reviever from Header if empty
            if(itm.ASI_CRM_Receiver__c == NULL && mapHeader != NULL && mapHeader.size() > 0 && mapHeader.get(itm.ASI_FOC_Request_Order__c) != NULL){
                //itm.ASI_CRM_Receiver__c = mapHeader.get(itm.ASI_FOC_Request_Order__c).ASI_CRM_Receiver__c;
            }

            if(itm.ASI_CRM_Receiver__c == NULL && mapDeliveryToAcc != NULL && mapDeliveryToAcc.size() > 0 && mapDeliveryToAcc.get(itm.ASI_CRM_Delivery_To__c) != NULL)
            {
                Account Deliveryto = mapDeliveryToAcc.get(itm.ASI_CRM_Delivery_To__c);
                contact ct = Deliveryto.contacts.size() > 0 ? Deliveryto.contacts[0] : new contact();
                itm.ASI_CRM_Receiver__c = (ct.LastName != null ? ct.LastName : '') + ' ' + (ct.FirstName != null ? ct.FirstName : '');
            }
                 
            if(mapPlanLineType.get(itm.ASI_CRM_Plan_Line_Item__c) == 'A&D FOC Unit Cost')
                itm.ASI_CRM_A_D_or_A_P__c = 'A&D';
            else if(mapPlanLineType.get(itm.ASI_CRM_Plan_Line_Item__c) == 'A&P FOC Unit Cost')
                itm.ASI_CRM_A_D_or_A_P__c = 'A&P';
            
            Boolean foundCost= false;// PRA COE@ 202007: if sku cost cannot find in FOC Amount calculation, leave sku cost as 0
            for(ASI_CRM_MY_SKUPriceCost__c skupc : listSKUPriceCost){
                //system.debug('Channel: '+mapPlanLineAccChannel.get(itm.ASI_CRM_Plan_Line_Item__c));
                //system.debug('Item Gp: '+mapSKUbyItemGp.get(itm.ASI_FOC_SKU__c));
                //system.debug('Type: '+mapPlanLineType.get(itm.ASI_CRM_Plan_Line_Item__c));
                //system.debug('Plan Start Date: '+mapPlanLineStartDate.get(itm.ASI_CRM_Plan_Line_Item__c));
                
                if(/*skupc.ASI_CRM_Applied_To__c.contains(mapPlanLineAccChannel.get(itm.ASI_CRM_Plan_Line_Item__c)) &&*/
                   skupc.ASI_CRM_Item_Group__c == mapSKUbyItemGp.get(itm.ASI_FOC_SKU__c) &&
                   skupc.ASI_CRM_Type__c == mapPlanLineType.get(itm.ASI_CRM_Plan_Line_Item__c) &&
                   skupc.ASI_CRM_EffectiveDate__c <= mapPlanLineStartDate.get(itm.ASI_CRM_Plan_Line_Item__c)){
                    system.debug(skupc.Id+'SKU Cost: '+skupc.ASI_CRM_Cost__c);
                    itm.ASI_FOC_Unit_Cost_PC_BT__c = Math.abs(skupc.ASI_CRM_Cost__c);
                    itm.ASI_FOC_CN_SKU_Description__c = skupc.Id;
                    foundCost= true;
                    break;
                }
            }
            
            if(!foundCost){
                itm.ASI_FOC_Unit_Cost_PC_BT__c =0;
                itm.ASI_FOC_CN_SKU_Description__c = 'No found';
            }
            //system.debug('Line Item Cost: '+itm.Name+' '+itm.ASI_FOC_Unit_Cost_PC_BT__c);
        }
    }
    
    public static void routineAfterUpsert(list<ASI_FOC_Request_Item__c> trigger_new, map<id, ASI_FOC_Request_Item__c> trigger_oldMap) {
        Set<Id> setHeaderId = new Set<Id>();
        List<ASI_FOC_Free_Goods_Request__c> listHeader = new List<ASI_FOC_Free_Goods_Request__c>();
        Map<Id, ASI_FOC_Free_Goods_Request__c> mapHeader = new Map<Id, ASI_FOC_Free_Goods_Request__c>();
        List<ASI_FOC_Free_Goods_Request__c> listHeaderToUpdate = new List<ASI_FOC_Free_Goods_Request__c>();
        
        Set<Id> setPlanId = new Set<Id>();
        List<ASI_MFM_Plan__c> listPlan = new List<ASI_MFM_Plan__c>();
        
        // Added by 2018-07-06 Linus@introv        
        List<ASI_FOC_Request_Item__c> AllFOC = new List<ASI_FOC_Request_Item__c>();
        
        Map<Id, Boolean> mapCheckOutstanding = new Map<Id, Boolean>(); //Added by Introv for checking if any Outstanding item
        
        for(ASI_FOC_Request_Item__c itm : trigger_new){
            setHeaderId.add(itm.ASI_FOC_Request_Order__c);  
        }
        
        for(ASI_FOC_Request_Item__c itm :[SELECT id, ASI_FOC_Request_Order__c, ASI_CRM_Outstanding_Qty__c FROM ASI_FOC_Request_Item__c WHERE ASI_FOC_Request_Order__c IN: setHeaderId]){
            if(mapCheckOutstanding == null || mapCheckOutstanding.get(itm.ASI_FOC_Request_Order__c) == null)
                mapCheckOutstanding.put(itm.ASI_FOC_Request_Order__c, true);
            if(itm.ASI_CRM_Outstanding_Qty__c == null || (itm.ASI_CRM_Outstanding_Qty__c != null && itm.ASI_CRM_Outstanding_Qty__c != 0))
                mapCheckOutstanding.put(itm.ASI_FOC_Request_Order__c, false);
            
            system.debug(mapCheckOutstanding);
        }
        
        listHeader = [SELECT Id, ASI_CRM_FOC_Amount__c, ASI_CRM_FOC_Amount_w_o_A_D__c, ASI_CRM_Plan__c, 
                       ASI_FOC_Request_Status__c, ASI_CRM_No_of_Detail_Line__c
                       FROM ASI_FOC_Free_Goods_Request__c 
                       WHERE Id IN: setHeaderId]; 
        for(ASI_FOC_Free_Goods_Request__c header : listHeader){
            mapHeader.put(header.id, header);
            setPlanId.add(header.ASI_CRM_Plan__c); 
        }
        listPlan = [SELECT Id, ASI_CRM_Total_FOC_Amount__c, ASI_CRM_FOC_Amount_w_o_A_D__c FROM ASI_MFM_Plan__c WHERE Id IN: setPlanId];
        
        for(ASI_FOC_Request_Item__c itm : trigger_new){
            //Added by Introv @20170526 for update Free Goods Request status to 'Completed' if no Outstanding item
            if(!mapHeader.get(itm.ASI_FOC_Request_Order__c).ASI_FOC_Request_Status__c.contains('Complete') 
                    && mapHeader.get(itm.ASI_FOC_Request_Order__c).ASI_CRM_No_of_Detail_Line__c != 0 
                    && mapCheckOutstanding.get(itm.ASI_FOC_Request_Order__c))
            {
                mapHeader.get(itm.ASI_FOC_Request_Order__c).ASI_FOC_Request_Status__c = 'Complete';
                listHeaderToUpdate.add(mapHeader.get(itm.ASI_FOC_Request_Order__c));
                
                system.debug ('header='+itm.ASI_FOC_Request_Order__c);
            }
        }
        update listHeaderToUpdate;
        
    }
    
    public static void routineBeforeDelete(list<ASI_FOC_Request_Item__c> trigger_old) {
        if(!isBypassByCurrentUser()){
            Set<Id> setHeaderId = new Set<Id>();
            Map<Id, ASI_FOC_Free_Goods_Request__c> mapHeader = new Map<Id, ASI_FOC_Free_Goods_Request__c>();
            
            //get current user permission sets
            List<PermissionSetAssignment> listCurrentUserPerSet = [SELECT Id FROM PermissionSetAssignment
                                                                   WHERE AssigneeId = :Userinfo.getUserId() AND 
                                                                   PermissionSet.Name = 'ASI_CRM_TW_OP_Team'];
            system.debug('Current User Permision: '+listCurrentUserPerSet);
            
            for(ASI_FOC_Request_Item__c itm : trigger_old){
                setHeaderId.add(itm.ASI_FOC_Request_Order__c);   
            }
            
            for(ASI_FOC_Free_Goods_Request__c header : [SELECT ASI_FOC_Request_Status__c, ASI_CRM_Target_Outlet__c, ASI_CRM_Delivery_To__c, ASI_CRM_SG_Delivery_Address__c, ASI_CRM_Delivery_Tel__c FROM ASI_FOC_Free_Goods_Request__c WHERE Id IN: setHeaderId]){
                mapHeader.put(header.id, header);
            }
            
            for(ASI_FOC_Request_Item__c itm : trigger_old){
                if(mapHeader.get(itm.ASI_FOC_Request_Order__c).ASI_FOC_Request_Status__c == 'Submitted' ||
                   mapHeader.get(itm.ASI_FOC_Request_Order__c).ASI_FOC_Request_Status__c == 'Final' ||
                   mapHeader.get(itm.ASI_FOC_Request_Order__c).ASI_FOC_Request_Status__c.contains('Complete') ||
                   mapHeader.get(itm.ASI_FOC_Request_Order__c).ASI_FOC_Request_Status__c == 'Cancel'){
                    itm.addError('You are not allowed to delete line items.');
                }
                else if(mapHeader.get(itm.ASI_FOC_Request_Order__c).ASI_FOC_Request_Status__c == 'Approved'){
                    if(listCurrentUserPerSet == null || listCurrentUserPerSet.size() <= 0)
                        itm.addError('You are not allowed to delete line items.');
                }
            }
        }
    }
    
    public static void routineAfterDelete(list<ASI_FOC_Request_Item__c> trigger_old) {
        Set<Id> setHeaderId = new Set<Id>();
        Set<Id> setPlanId = new Set<Id>();
        
        List<ASI_MFM_Plan__c> listPlan = new List<ASI_MFM_Plan__c>();
        
        Map<Id, ASI_FOC_Free_Goods_Request__c> mapHeader = new Map<Id, ASI_FOC_Free_Goods_Request__c>();
        Map<Id, Map<Id, ASI_FOC_Request_Item__c>> mapLineByPlan = new Map<Id, Map<Id, ASI_FOC_Request_Item__c>>();
        
        for(ASI_FOC_Request_Item__c itm : trigger_old){
            setHeaderId.add(itm.ASI_FOC_Request_Order__c); 
        }

    }
}