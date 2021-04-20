public class ASI_FOC_HK_Request_Item_TriggerClass {

    public static void routineAfterUpsert(list<ASI_FOC_Request_Item__c> trigger_new, map<id, ASI_FOC_Request_Item__c> trigger_oldMap) {
    
                //added by ssc mark
        boolean needUpdate = false;
        if(trigger_oldMap!=null){
            for (ASI_FOC_Request_Item__c i:trigger_new) {
                if(i.ID!=null && trigger_oldMap.get(i.ID)!=null){
                    ASI_FOC_Request_Item__c oldItem = trigger_oldMap.get(i.ID);
                    if( oldItem.ASI_FOC_SKU__c!=i.ASI_FOC_SKU__c || 
                        oldItem.ASI_FOC_Request_Quantity_Bottle__c!=i.ASI_FOC_Request_Quantity_Bottle__c ||
                        (oldItem.ASI_FOC_Issued_Qty__c!=null && i.ASI_FOC_Issued_Qty__c!=null&& oldItem.ASI_FOC_Issued_Qty__c !=i.ASI_FOC_Issued_Qty__c) ||
                        oldItem.ASI_FOC_Issued_Qty__c==null && i.ASI_FOC_Issued_Qty__c!=null
                    ){
                            needUpdate = true;
                            break;                          
                    }
                }else{
                    needUpdate = true;
                    break;
                }
            }
        }else
            needUpdate = true;
            
        if(needUpdate){     
    // Set ASI_FOC_SYS_Request_Line_Information__c for the related request order
            set<id> rq_set = new set<id>();
            for (ASI_FOC_Request_Item__c i:trigger_new) {
                rq_set.add(i.ASI_FOC_Request_Order__c);
            }
            
            
            
            list<ASI_FOC_Free_Goods_Request__c> rq_list = [select Name, (select Name, ASI_FOC_SKU__r.name, ASI_FOC_Request_Quantity_Bottle__c, ASI_FOC_Packing_Description__c, ASI_FOC_SKU__c,ASI_FOC_Issued_Qty__c 
                from ASI_FOC_Request_Items__r where ASI_FOC_Brand_Director_Approval_Status__c != 'Rejected' and ASI_FOC_Brand_Director_Approval_Status__c != 'Cancelled' order by ASI_FOC_SKU__r.name)
                from ASI_FOC_Free_Goods_Request__c where id in :rq_set for update];
                
            string sku_x = 'SKU';
            string pkg_x = 'Packaging';
            string qty_x = 'Qty.';
            string hdr = sku_x.rightPad(31) + pkg_x.rightPad(11) + qty_x + '<br/>'; 
            
            
            for (ASI_FOC_Free_Goods_Request__c rq:rq_list) {
                System.debug('Start check each FOC after upsert: ' + rq.Name);  
                Set<id> duplicateSKUSet = new Set<id>();
                rq.ASI_FOC_SYS_Request_Line_Information__c = '<pre>' + hdr;
                
                for (ASI_FOC_Request_Item__c i:rq.ASI_FOC_Request_Items__r) {
                    string sku_name = i.ASI_FOC_SKU__r.name == null ? '' : i.ASI_FOC_SKU__r.name;
                    rq.ASI_FOC_SYS_Request_Line_Information__c += sku_name.trim().left(30).rightPad(31);
                    string sku_pkg = i.ASI_FOC_Packing_Description__c == null ? '' : i.ASI_FOC_Packing_Description__c;
                    rq.ASI_FOC_SYS_Request_Line_Information__c += sku_pkg.trim().left(10).rightPad(11);             
                    string sku_qty = i.ASI_FOC_Request_Quantity_Bottle__c == null ? '' : string.valueOf(i.ASI_FOC_Request_Quantity_Bottle__c);
                    rq.ASI_FOC_SYS_Request_Line_Information__c += sku_qty.trim().right(5) + '<br/>';
                    
                    System.debug('Start check each FOC Item after upsert: ' + i.Name + ' ' + i.ASI_FOC_SKU__r.name + ' SKU Set: ' + duplicateSKUSet + ' This SKU: ' + i.ASI_FOC_SKU__c);
                    
                    if (duplicateSKUSet.contains(i.ASI_FOC_SKU__c)){
                        for (ASI_FOC_Request_Item__c item:trigger_new){
                            if (item.id == i.id)
                                item.addError('Duplicate SKU found');
                        }
                    }
                    else {
                        duplicateSKUSet.add(i.ASI_FOC_SKU__c);
                    }
                }
                rq.ASI_FOC_SYS_Request_Line_Information__c += '</pre>';                                       
            }
            update rq_list; 
        }
    }
    
    public static void routineBeforeUpsert(list<ASI_FOC_Request_Item__c> trigger_new, map<id, ASI_FOC_Request_Item__c> trigger_oldMap) {
        
        //added by ssc mark
        boolean needUpdate = false;
        if(trigger_oldMap!=null){
            for (ASI_FOC_Request_Item__c i:trigger_new) {
                if(i.ID!=null && trigger_oldMap.get(i.ID)!=null){
                    ASI_FOC_Request_Item__c oldItem = trigger_oldMap.get(i.ID);
                    if( oldItem.ASI_FOC_SKU__c!=i.ASI_FOC_SKU__c || 
                        oldItem.ASI_FOC_Request_Quantity_Bottle__c!=i.ASI_FOC_Request_Quantity_Bottle__c ||
                        (oldItem.ASI_FOC_Issued_Qty__c!=null && i.ASI_FOC_Issued_Qty__c!=null&& oldItem.ASI_FOC_Issued_Qty__c !=i.ASI_FOC_Issued_Qty__c) ||
                        oldItem.ASI_FOC_Issued_Qty__c==null && i.ASI_FOC_Issued_Qty__c!=null
                    ){
                            needUpdate = true;
                            break;                          
                    }
                }else{
                    needUpdate = true;
                    break;
                }
            }
        }else
            needUpdate = true;
        
        if(needUpdate){
        
            boolean result = false;
            Set<id> reqid_Set = new Set<id>();
            
            for (ASI_FOC_Request_Item__c i:trigger_new) {
                if (i.ASI_FOC_Sys_Clone_Flag__c) {
                    i.ASI_FOC_Sys_Clone_Flag__c = false;
                }
                reqid_Set.add(i.ASI_FOC_Request_Order__c);
            }
    // Set Request Item FOC Price
            set<id> customer_set = new set<id>();       
            List<ASI_FOC_Free_Goods_Request__c> req_List = [select Name,ASI_FOC_STK_4_Count_Sales_Volume__c, ASI_FOC_Account_DA__c from ASI_FOC_Free_Goods_Request__c where id = :reqid_Set];
            Map<id, ASI_FOC_Free_Goods_Request__c> req_Map = new Map<id, ASI_FOC_Free_Goods_Request__c>(req_List);
            
            for (ASI_FOC_Free_Goods_Request__c req : req_List){
                customer_set.add(req.ASI_FOC_Account_DA__c);
            }
            
            System.debug('Customer Set: ' + customer_set);
            list<ASI_HK_CRM_Customer_Product_Price__c> customerProdPrice = [select ASI_HK_CRM_Bottle_Price__c, ASI_HK_CRM_SKU_Lookup__c, ASI_HK_CRM_Customer_Name__c from ASI_HK_CRM_Customer_Product_Price__c
                where ASI_HK_CRM_Customer_Name__c in :customer_set];
            System.debug('Channel Price List: ' + customerProdPrice);
            
            List<ASI_MFM_SKU_Code__c> sku_List = [select ASI_FOC_Stock_Price__c from ASI_MFM_SKU_Code__c where recordTypeid = :Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_HK_CRM_SKU')];
            Map<id, ASI_MFM_SKU_Code__c> sku_Map = new Map<id, ASI_MFM_SKU_Code__c>(sku_List);
                    
            for (ASI_FOC_Request_Item__c i:trigger_new) {
                //Set Channel Price for STK4 request
                ASI_FOC_Free_Goods_Request__c req = req_Map.get(i.ASI_FOC_Request_Order__c);
                System.debug('Request Header Name: ' + req.Name + ' IsSTK4?: ' + req.ASI_FOC_STK_4_Count_Sales_Volume__c);
                
                System.debug('Is STK4 Channel Price?: ' + req.ASI_FOC_STK_4_Count_Sales_Volume__c);
                if (req.ASI_FOC_STK_4_Count_Sales_Volume__c == true){
                    for (ASI_HK_CRM_Customer_Product_Price__c p :customerProdPrice){
                        System.debug('Customer Product Price Account Name: ' + p.ASI_HK_CRM_Customer_Name__c + ' Account Price SKU ID: ' + p.ASI_HK_CRM_SKU_Lookup__c + ' Request Item SKU ID: ' + i.ASI_FOC_SKU__c);
                        if (p.ASI_HK_CRM_Customer_Name__c == req.ASI_FOC_Account_DA__c && p.ASI_HK_CRM_SKU_Lookup__c == i.ASI_FOC_SKU__c){
                            i.ASI_FOC_Free_Good_Cost__c = p.ASI_HK_CRM_Bottle_Price__c * (i.ASI_FOC_Issued_Qty__c==null? i.ASI_FOC_Request_Quantity_Bottle__c : i.ASI_FOC_Issued_Qty__c);
                            result = true;
                        }
                    }
                    System.debug('Found STK4 Channel Price? : ' + result);
                    //If cannot find Channel Price for the SKU of that customer, use SKU cost
                    if (!result){
                        i.addError('The selected item does not have base price');
                    }
                }
                else {
                    if (sku_Map.get(i.ASI_FOC_SKU__c).ASI_FOC_Stock_Price__c > 0){
                        System.debug('STK3 SKU Stock Cost: ' + sku_Map.get(i.ASI_FOC_SKU__c).ASI_FOC_Stock_Price__c);
                        i.ASI_FOC_Free_Good_Cost__c = sku_Map.get(i.ASI_FOC_SKU__c).ASI_FOC_Stock_Price__c *  (i.ASI_FOC_Issued_Qty__c==null? i.ASI_FOC_Request_Quantity_Bottle__c : i.ASI_FOC_Issued_Qty__c);
                        
                    }
                }
            }
        }
    }
    
    public static void routineBeforeUpdate(list<ASI_FOC_Request_Item__c> trigger_new, map<id, ASI_FOC_Request_Item__c> trigger_oldMap) {

    }
}