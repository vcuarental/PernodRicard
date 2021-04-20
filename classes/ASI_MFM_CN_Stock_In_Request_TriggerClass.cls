public class ASI_MFM_CN_Stock_In_Request_TriggerClass {

    Private Static Final String CONFRIMED_STATUS = 'Confirmed';
    Private Static Final String SKU_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_POSM_SKU');
    
    Private Static Final String PO_RECEIPT_RT = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_CN_PO_Receipt');
    Private Static Final String PO_RECEIPT_ITEM_RT = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_CN_PO_Receipt_item');

    Public Static void beforeInsertFunction(List<ASI_MFM_Stock_In_Request__c> triggerNew){
        assignEmailAddresses(triggerNew);
        assignDefaultFields4SKU(triggerNew);
    }
    
    Public Static void beforeUpdateFunction(List<ASI_MFM_Stock_In_Request__c> triggerNew, Map<Id, ASI_MFM_Stock_In_Request__c> triggerOldMap){
		Set<Id> itemgGroupSetId = new Set<Id>();
        Set<Id> poPOSMLineSetId = new Set<Id>();
        Set<Id> confirmedSetId = new Set<Id>();
		Set<String> newSKUSet = new Set<String>();
        Set<Id> noSKUPOSMLineSet = new Set<Id>();
        //Set<String> itemgroupCodeSet = new Set<String>();
        Set<String> new9YSKUSet = new Set<String>();

        Map<String, ASI_MFM_SKU_Code__c> sku9y9dMap = new Map<String, ASI_MFM_SKU_Code__c>();
        Map<String, ASI_MFM_SKU_Code__c> skuMap = new Map<String, ASI_MFM_SKU_Code__c>();
        Map<String, ASI_MFM_SKU_Code__c> mapSKUByPOSMLineId = new Map<String, ASI_MFM_SKU_Code__c>();
        Map<String, ASI_MFM_SKU_Code__c> mapSKUBySKUCode = new Map<String, ASI_MFM_SKU_Code__c>();
        Map<String, String> mapSKUCodeByPOSMLineId = new Map<String, String>();
        Map<Id, ASI_MFM_PO_POSM_Line__c> poPOSMLineMap = new Map<Id, ASI_MFM_PO_POSM_Line__c>();
        Map<String, ASI_MFM_Item_Group__c> itemGroupMap = new Map<String, ASI_MFM_Item_Group__c>();
        
        List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
        List<ASI_MFM_PO_POSM_Line__c> updatePOSMLineList = new List<ASI_MFM_PO_POSM_Line__c>();

        for(ASI_MFM_Stock_In_Request__c obj : triggerNew){
            
            if(obj.ASI_MFM_Qty_Per_Bag_Box__c == Null)
                obj.ASI_MFM_Qty_Per_Bag_Box__c = (obj.ASI_MFM_Qty_Per_Box__c != Null ? obj.ASI_MFM_Qty_Per_Box__c : 0) * (obj.ASI_MFM_Total_Qty_Per_Bag_Box__c != Null ? obj.ASI_MFM_Total_Qty_Per_Bag_Box__c : 0);
            
            if(obj.ASI_MFM_Status__c == CONFRIMED_STATUS && triggerOldMap.get(obj.id).ASI_MFM_Status__c != obj.ASI_MFM_Status__c){
                
                confirmedSetId.add(obj.id);
                poPOSMLineSetId.add(obj.ASI_MFM_PO_POSM_Line_Number__c);
            }
        }
        
        if(poPOSMLineSetId.size() > 0){
            for(ASI_MFM_PO_POSM_Line__c obj : [SELECT Id, ASI_MFM_Item_Group__c, ASI_MFM_SKU__c FROM ASI_MFM_PO_POSM_Line__c WHERE Id IN : poPOSMLineSetId]){
                
                itemgGroupSetId.add(obj.ASI_MFM_Item_Group__c);
                poPOSMLineMap.put(obj.id, obj);
            }
            
            if(itemgGroupSetId.size() > 0){
                for(ASI_MFM_Item_Group__c obj : [SELECT Id, ASI_MFM_Sub_brand__c, Name, ASI_CRM_CN_Eng_Name__c, ASI_CRM_CN_Chinese_Name__c, ASI_MFM_Item_Group_Code__c, (SELECT Id, ASI_MFM_Minimum_Packing_Qty__c, ASI_MFM_Minimum_Box_Qty__c, ASI_MFM_Item_Group__c FROM SKUs__r) FROM ASI_MFM_Item_Group__c WHERE Id IN : itemgGroupSetId]){
                    
                    itemGroupMap.put(obj.ASI_MFM_Item_Group_Code__c, obj);
                    
                    for(ASI_MFM_SKU_Code__c sku : obj.SKUs__r){
                        if (obj.ASI_MFM_Item_Group_Code__c.startsWithIgnoreCase('9Y') || obj.ASI_MFM_Item_Group_Code__c.startsWithIgnoreCase('9D')) {//modify by alex BLS
                            sku9y9dMap.put(obj.ASI_MFM_Item_Group_Code__c, sku);
                        } else {
                            skuMap.put(obj.ASI_MFM_Item_Group_Code__c + '_' + sku.ASI_MFM_Minimum_Packing_Qty__c + '_' + sku.ASI_MFM_Minimum_Box_Qty__c, sku);
                        }
                    }
                }
            }
        }
        
        for(ASI_MFM_Stock_In_Request__c obj : triggerNew){
            //if item group code start with 9Y/9D , no need to base on the min package and the max number package, modify by alex BLS
            Boolean is9Y9D = String.isNotBlank(obj.ASI_MFM_Item_Group_Code__c) && (obj.ASI_MFM_Item_Group_Code__c.startsWithIgnoreCase('9Y') || obj.ASI_MFM_Item_Group_Code__c.startsWithIgnoreCase('9D'));
            //Assume one POSM Line will only have one SKU
            if(confirmedSetId.contains(obj.id) && itemGroupMap.containsKey(obj.ASI_MFM_Item_Group_Code__c) && 
                ((!is9Y9D && !skuMap.containsKey(obj.ASI_MFM_Item_Group_Code__c + '_' + Integer.valueOf(obj.ASI_MFM_Qty_Per_Box__c) + '_' + Integer.valueOf(obj.ASI_MFM_Total_Qty_Per_Bag_Box__c))) 
                    || (is9Y9D && !sku9y9dMap.containsKey(obj.ASI_MFM_Item_Group_Code__c)))){
                
                if((!is9Y9D && !newSKUSet.contains(obj.ASI_MFM_Item_Group_Code__c + '_' + Integer.valueOf(obj.ASI_MFM_Qty_Per_Box__c) + '_' + Integer.valueOf(obj.ASI_MFM_Total_Qty_Per_Bag_Box__c)))
                    || (is9Y9D && !new9YSKUSet.contains(obj.ASI_MFM_Item_Group_Code__c))){
                    ASI_MFM_SKU_Code__c tmpSKU = new ASI_MFM_SKU_Code__c(recordTypeId = SKU_RECORD_TYPE_ID
                                                                     , ASI_MFM_Minimum_Packing_Qty__c = Integer.valueOf(obj.ASI_MFM_Qty_Per_Box__c)
                                                                     //, Name = itemGroupMap.get(obj.ASI_MFM_Item_Group_Code__c).Name
                                                                     , ASI_CRM_SKU_Status__c = 'Active'
                                                                     , ASI_MFM_Item_Group__c = itemGroupMap.get(obj.ASI_MFM_Item_Group_Code__c).id
                                                                     , ASI_MFM_Box_Size_M3__c = obj.ASI_MFM_Box_Size_M3__c
                                                                     //Andy@Introv 20181212 - fix field		//, ASI_MFM_Minimum_Box_Qty__c = obj.ASI_MFM_Qty_Per_Bag_Box__c
                                                                     , ASI_MFM_Minimum_Box_Qty__c = Integer.valueOf(obj.ASI_MFM_Total_Qty_Per_Bag_Box__c)
                                                                     , ASI_MFM_SKU_Description__c = itemGroupMap.get(obj.ASI_MFM_Item_Group_Code__c).ASI_CRM_CN_Eng_Name__c
                                                                     , ASI_FOC_SKU_Chinese_Description__c = itemGroupMap.get(obj.ASI_MFM_Item_Group_Code__c).ASI_CRM_CN_Chinese_Name__c
                                                                     , ASI_MFM_Sub_brand__c = itemGroupMap.get(obj.ASI_MFM_Item_Group_Code__c).ASI_MFM_Sub_brand__c 
                                                                     , ASI_MFM_Box_Net_Weight_KG__c = obj.ASI_MFM_Box_Net_Weight__c
                                                                     , ASI_FOC_Active__c = False
                                                                     //Andy@Introv 20190123 - need to set null to prevent error during create request item
                                                                     , ASI_HK_CRM_Available_Quantity__c = NULL
                                                                    );
	                skuList.add(tmpSKU);
                    if (is9Y9D) {
                        new9YSKUSet.add(obj.ASI_MFM_Item_Group_Code__c);
                    } else {
                        newSKUSet.add(obj.ASI_MFM_Item_Group_Code__c + '_' + Integer.valueOf(obj.ASI_MFM_Qty_Per_Box__c) + '_' + Integer.valueOf(obj.ASI_MFM_Total_Qty_Per_Bag_Box__c));
                    }
                    mapSKUByPOSMLineId.put(obj.ASI_MFM_PO_POSM_Line_Number__c, tmpSKU);
                    //Start 20181108 fix for multi POSM line with non SKU Item Group
                    mapSKUBySKUCode.put(obj.ASI_MFM_Item_Group_Code__c + '_' + Integer.valueOf(obj.ASI_MFM_Qty_Per_Box__c) + '_' + Integer.valueOf(obj.ASI_MFM_Total_Qty_Per_Bag_Box__c),tmpSKU);
                    
                }
                mapSKUCodeByPOSMLineId.put(obj.ASI_MFM_PO_POSM_Line_Number__c,obj.ASI_MFM_Item_Group_Code__c + '_' + Integer.valueOf(obj.ASI_MFM_Qty_Per_Box__c) + '_' + Integer.valueOf(obj.ASI_MFM_Total_Qty_Per_Bag_Box__c));
                //End 20181108 fix for multi POSM line with non SKU Item Group
                noSKUPOSMLineSet.add(obj.ASI_MFM_PO_POSM_Line_Number__c);
                
            }else if(confirmedSetId.contains(obj.id) && poPOSMLineMap.containsKey(obj.ASI_MFM_PO_POSM_Line_Number__c) && poPOSMLineMap.get(obj.ASI_MFM_PO_POSM_Line_Number__c).ASI_MFM_SKU__c == Null && itemGroupMap.containsKey(obj.ASI_MFM_Item_Group_Code__c) && 
                ((!is9Y9D && skuMap.containsKey(obj.ASI_MFM_Item_Group_Code__c + '_' + Integer.valueOf(obj.ASI_MFM_Qty_Per_Box__c) + '_' + Integer.valueOf(obj.ASI_MFM_Total_Qty_Per_Bag_Box__c))) || (is9Y9D && sku9y9dMap.containsKey(obj.ASI_MFM_Item_Group_Code__c)) )){
                if(!is9Y9D && skuMap.get(obj.ASI_MFM_Item_Group_Code__c + '_' + Integer.valueOf(obj.ASI_MFM_Qty_Per_Box__c) + '_' + Integer.valueOf(obj.ASI_MFM_Total_Qty_Per_Bag_Box__c)).id != Null){
                    poPOSMLineMap.get(obj.ASI_MFM_PO_POSM_Line_Number__c).ASI_MFM_SKU__c = skuMap.get(obj.ASI_MFM_Item_Group_Code__c + '_' + Integer.valueOf(obj.ASI_MFM_Qty_Per_Box__c) + '_' + Integer.valueOf(obj.ASI_MFM_Total_Qty_Per_Bag_Box__c)).id;
                } else if (is9Y9D && sku9y9dMap.get(obj.ASI_MFM_Item_Group_Code__c).id != null) {
                    poPOSMLineMap.get(obj.ASI_MFM_PO_POSM_Line_Number__c).ASI_MFM_SKU__c = sku9y9dMap.get(obj.ASI_MFM_Item_Group_Code__c).id;
                } else {
                    noSKUPOSMLineSet.add(obj.ASI_MFM_PO_POSM_Line_Number__c);
                }
                updatePOSMLineList.add(poPOSMLineMap.get(obj.ASI_MFM_PO_POSM_Line_Number__c));
            }
        }
        
        //try{
        
        if(skuList.size() > 0)
            Insert skuList;
        
        if(noSKUPOSMLineSet.size() > 0){
            for(String recordId : noSKUPOSMLineSet){
                //Start 20181108 fix for multi POSM line with non SKU Item Group
                if(poPOSMLineMap.containsKey(recordId) && poPOSMLineMap.get(recordId).ASI_MFM_SKU__c == Null && mapSKUCodeByPOSMLineId.containsKey(recordId)){
                    poPOSMLineMap.get(recordId).ASI_MFM_SKU__c = mapSKUBySKUCode.get(mapSKUCodeByPOSMLineId.get(recordId)).id;
                    updatePOSMLineList.add(poPOSMLineMap.get(recordId));
                }
                //End 20181108 fix for multi POSM line with non SKU Item Group
            }
        }
        
        if(updatePOSMLineList.size() > 0){
            Update updatePOSMLineList;
        }
            
        //}catch(dmlException dmle){
            
        //}
        
        assignEmailAddresses(triggerNew);
    }
    
    private static void assignDefaultFields4SKU(List<ASI_MFM_Stock_In_Request__c> triggerNew){
        for(ASI_MFM_Stock_In_Request__c obj : triggerNew){
            decimal sub_part = 1;
            decimal sub_box = 1;
            
            if (obj.ASI_MFM_Qty_Per_Box__c == NULL) {
                obj.ASI_MFM_Qty_Per_Box__c = sub_part;
            } else {
                sub_part = obj.ASI_MFM_Qty_Per_Box__c;
            }
            
            if (obj.ASI_MFM_Total_Qty_Per_Bag_Box__c == NULL) {
                 obj.ASI_MFM_Total_Qty_Per_Bag_Box__c = sub_box;
            } else {
                sub_box = obj.ASI_MFM_Total_Qty_Per_Bag_Box__c;
            }
            
            if (obj.ASI_MFM_Qty_Per_Bag_Box__c == NULL) {
                obj.ASI_MFM_Qty_Per_Bag_Box__c = sub_part * sub_box;
            }
        }
    }
    
    private static void assignEmailAddresses(List<ASI_MFM_Stock_In_Request__c> triggerNew){
        Set<Id> setPOSMLine = new Set<Id>();
        for(ASI_MFM_Stock_In_Request__c obj : triggerNew){
            setPOSMLine.add(obj.ASI_MFM_PO_POSM_Line_Number__c);
        }
        
        Map<Id, ASI_MFM_PO_POSM_Line__c> mapPOSMLine = new Map<Id, ASI_MFM_PO_POSM_Line__c>([
            select id, ASI_MFM_Operation_Team_Email_1__c, ASI_MFM_Operation_Team_Email_2__c, ASI_MFM_Operation_Team_Email_3__c, ASI_MFM_Operation_Team_Email_4__c
            	, ASI_MFM_Operation_Team_Email_5__c, ASI_MFM_Operation_Team_Email_6__c, ASI_MFM_Operation_Team_Email_7__c, ASI_MFM_Operation_Team_Email_8__c
            from ASI_MFM_PO_POSM_Line__c where id in :setPOSMLine
        ]);
        
        for(ASI_MFM_Stock_In_Request__c obj : triggerNew){
            ASI_MFM_PO_POSM_Line__c objLine = mapPOSMLine.get(obj.ASI_MFM_PO_POSM_Line_Number__c);
            obj.ASI_MFM_OperationTeamEmail1__c = objLine.ASI_MFM_Operation_Team_Email_1__c;
            obj.ASI_MFM_OperationTeamEmail2__c = objLine.ASI_MFM_Operation_Team_Email_2__c;
            obj.ASI_MFM_OperationTeamEmail3__c = objLine.ASI_MFM_Operation_Team_Email_3__c;
            obj.ASI_MFM_OperationTeamEmail4__c = objLine.ASI_MFM_Operation_Team_Email_4__c;
            obj.ASI_MFM_OperationTeamEmail5__c = objLine.ASI_MFM_Operation_Team_Email_5__c;
            obj.ASI_MFM_OperationTeamEmail6__c = objLine.ASI_MFM_Operation_Team_Email_6__c;
            obj.ASI_MFM_OperationTeamEmail7__c = objLine.ASI_MFM_Operation_Team_Email_7__c;
            obj.ASI_MFM_OperationTeamEmail8__c = objLine.ASI_MFM_Operation_Team_Email_8__c;
        }
    }
    
    Public Static void afterUpdateFunction(List<ASI_MFM_Stock_In_Request__c> triggerNew, Map<Id, ASI_MFM_Stock_In_Request__c> triggerOldMap) {
		Boolean checkLogic = true;
        ASI_MFM_CN_Setting__mdt setting = [SELECT id,DeveloperName, ASI_MFM_CN_CheckValue__c
                                           FROM ASI_MFM_CN_Setting__mdt
                                           WHERE DeveloperName LIKE 'ASI_MFM_CN_POSM_AutoReceipt'
                                           LIMIT 1];
        if(setting==null || setting.ASI_MFM_CN_CheckValue__c==false) checkLogic=false;
        if(!checkLogic) return;
        
        Set<Id> poPOSMLineSetId = new Set<Id>();
        Set<Id> poSetId = new Set<Id>();
		Map<Id, List<ASI_MFM_PO_Line_Item__c>> mapPOLinsbyPOId = new Map<Id, List<ASI_MFM_PO_Line_Item__c>>();
        Map<Id, Double> mapRemainAmountByPOId = new Map<Id, Double>();
        Map<Id, Double> mapReceiptAmountByPOLineId = new Map<Id, Double>();
        for(ASI_MFM_Stock_In_Request__c sir : triggerNew) {
            poPOSMLineSetId.add(sir.ASI_MFM_PO_POSM_Line_Number__c);
            poSetId.add(sir.ASI_MFM_PO_Number__c);
        }

        for(ASI_MFM_PO_Line_Item__c poline : [SELECT id, ASI_MFM_Sub_brand_Code__c, ASI_MFM_Amount__c, ASI_MFM_CN_Receipt_Amount__c, ASI_MFM_Currency__c, ASI_MFM_PO__c, ASI_MFM_PO__r.ASI_MFM_CN_PO_Amount_RMB__c, ASI_MFM_A_C_Code__c FROM ASI_MFM_PO_Line_Item__c WHERE ASI_MFM_PO__c IN : poSetId]){
            if(!mapPOLinsbyPOId.containsKey(poline.ASI_MFM_PO__c)) {
                mapPOLinsbyPOId.put(poline.ASI_MFM_PO__c, new List<ASI_MFM_PO_Line_Item__c>());
            }
            mapPOLinsbyPOId.get(poline.ASI_MFM_PO__c).add(poline);
            
            if(!mapRemainAmountByPOId.containsKey(poline.ASI_MFM_PO__c)) {
                mapRemainAmountByPOId.put(poline.ASI_MFM_PO__c, 0);
            }
            mapRemainAmountByPOId.put(poline.ASI_MFM_PO__c, mapRemainAmountByPOId.get(poline.ASI_MFM_PO__c)+(poline.ASI_MFM_Amount__c-poline.ASI_MFM_CN_Receipt_Amount__c));
            
            mapReceiptAmountByPOLineId.put(poline.id, poline.ASI_MFM_CN_Receipt_Amount__c);
        }
        Map<Id, ASI_MFM_PO_POSM_Line__c> posmLineMap = new Map<Id,ASI_MFM_PO_POSM_Line__c>([SELECT id, ASI_MFM_PO__c, ASI_MFM_Total_Price__c, ASI_MFM_Quantity__c
                                                                                            FROM ASI_MFM_PO_POSM_Line__c 
                                                                                            WHERE id IN :poPOSMLineSetId]);

        
        //Search PO Receipt Header of Current day
        List<ASI_MFM_PO_Receipt__c> poReceiptHeaderList = [SELECT id FROM ASI_MFM_PO_Receipt__c 
                                                           WHERE recordTypeId = :PO_RECEIPT_RT
                                                           AND ASI_MFM_POSM_Receipt__c = True
                                                           AND ASI_MFM_Receipt_Date__c = :date.today() 
                                                           ORDER BY ASI_MFM_Receipt_Date__c
                                                           LIMIT 1];
        ASI_MFM_PO_Receipt__c poReceiptHeader = null;
        if(poReceiptHeaderList!=null && poReceiptHeaderList.size() > 0) { 
            poReceiptHeader = poReceiptHeaderList[0];
        }
        if(poReceiptHeader==null) {
            poReceiptHeader = new ASI_MFM_PO_Receipt__c(ASI_MFM_Receipt_Date__c = date.today()
                                                        , recordTypeId = PO_RECEIPT_RT
                                                        , ASI_MFM_POSM_Receipt__c = True);
            insert poReceiptHeader;
        }
        
        List<ASI_MFM_PO_Receipt_Item__c> insertPOReceiptItemList = new List<ASI_MFM_PO_Receipt_Item__c>();
        for(ASI_MFM_Stock_In_Request__c sir : triggerNew) {
            ASI_MFM_PO_POSM_Line__c posmLine = posmLineMap.get(sir.ASI_MFM_PO_POSM_Line_Number__c);
            if(posmLine==null) continue;
            
            List<ASI_MFM_PO_Line_Item__c> poLineForReceiptList = null;

            Double currReceipt = (sir.ASI_MFM_ActualReceipt__c==null)?0:sir.ASI_MFM_ActualReceipt__c;
            if(triggerOldMap.get(sir.id).ASI_MFM_ActualReceipt__c!=null) currReceipt -= triggerOldMap.get(sir.id).ASI_MFM_ActualReceipt__c;
            Double currRemainAmt = mapRemainAmountByPOId.get(sir.ASI_MFM_PO_Number__c);
            
            
            if(currReceipt==0) continue;
            if(currRemainAmt==null||currRemainAmt==0) continue;
            
            //AM 20181220: use unit price with tax
            Double posmLineUnitPrice = sir.ASI_MFM_Min_Unit_Price__c;
            
            //if(posmLine.ASI_MFM_Quantity__c>0) {
            //    posmLineUnitPrice = (posmLine.ASI_MFM_Total_Price__c/posmLine.ASI_MFM_Quantity__c);
            //}
			
            
            if(sir.ASI_MFM_PendingReceipt__c<0) currReceipt+=sir.ASI_MFM_PendingReceipt__c;//special handling for posm line amount ceil
            Double currReceiptAmt = currReceipt * posmLineUnitPrice;
            
            if(mapPOLinsbyPOId.get(sir.ASI_MFM_PO_Number__c)==null || mapPOLinsbyPOId.get(sir.ASI_MFM_PO_Number__c).size()==0) continue;
            
            for(ASI_MFM_PO_Line_Item__c poline: mapPOLinsbyPOId.get(sir.ASI_MFM_PO_Number__c)) {
                Double polineReceiptAmt = (mapReceiptAmountByPOLineId.get(poline.id)==null)? 0:mapReceiptAmountByPOLineId.get(poline.id);
                Double polineRemainAmt = poline.ASI_MFM_Amount__c-polineReceiptAmt;
                
                
                if(polineRemainAmt > 0 && currReceiptAmt >= 0 ) {
                    Double poAmt = Math.min(polineRemainAmt, currReceiptAmt);
                    insertPOReceiptItemList.add(new ASI_MFM_PO_Receipt_Item__c(ASI_MFM_Amount__c = poAmt+polineReceiptAmt // Add prev receipt amt for PO Receipt Item Trigger Logic
                                                                       , recordTypeId = PO_RECEIPT_ITEM_RT
                                                                       , ASI_MFM_PO_POSM_Line__c = sir.ASI_MFM_PO_POSM_Line_Number__c
                                                                       , ASI_MFM_PO_Line_Item__c = poline.id
                                                                       , ASI_MFM_PO__c = poline.ASI_MFM_PO__c
                                                                       , ASI_MFM_Sub_brand_temp__c = poline.ASI_MFM_Sub_brand_Code__c
                                                                       , ASI_MFM_A_C_Code_temp__c = poline.ASI_MFM_A_C_Code__c
                                                                       , ASI_MFM_PO_Receipt__c = poReceiptHeader.id
                                                                       , ASI_MFM_POSM_Receipt__c = True
                                                                       , ASI_MFM_Receipt_Date__c = date.today()
                                                                       , ASI_MFM_Currency_Temp__c = poline.ASI_MFM_Currency__c
                                                                      ));
                    currReceiptAmt-=poAmt;
                    mapRemainAmountByPOId.put(sir.ASI_MFM_PO_Number__c, mapRemainAmountByPOId.get(sir.ASI_MFM_PO_Number__c)-poAmt);
                    mapReceiptAmountByPOLineId.put(sir.ASI_MFM_PO_POSM_Line_Number__c, currReceiptAmt+polineReceiptAmt);
                    if(currReceiptAmt==0) continue;
                }
            }

        }
        try {	
            if(insertPOReceiptItemList.size() > 0) {insert insertPOReceiptItemList;}
        } catch(dmlException dmle) {
            system.debug(dmle.getMessage());
        }
    }
}