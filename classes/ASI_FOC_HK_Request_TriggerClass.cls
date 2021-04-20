public without sharing class ASI_FOC_HK_Request_TriggerClass {
    public static void routineAfterAll(list<ASI_FOC_Free_Goods_Request__c> trigger_new, map<id, ASI_FOC_Free_Goods_Request__c> trigger_oldMap) {
// Recalculate the PO consumed amount
        set<id> po_set = new set<id>();
        if (trigger_new != null) {
            for (ASI_FOC_Free_Goods_Request__c rq:trigger_new) {
                if (trigger_oldMap == null) {
                    po_set.add(rq.ASI_FOC_MFM_Consumer_AP_PO_Number__c);
                }
                else {
                    po_set.add(rq.ASI_FOC_MFM_Consumer_AP_PO_Number__c);
                    po_set.add(trigger_oldMap.get(rq.id).ASI_FOC_MFM_Consumer_AP_PO_Number__c);                        
                }
            }
        }
        else if (trigger_oldMap != null) {
            for (ASI_FOC_Free_Goods_Request__c rq:trigger_oldMap.values()) {
                po_set.add(rq.ASI_FOC_MFM_Consumer_AP_PO_Number__c);               
            }
        }
        
        if (po_set.size() > 0) {
            //20191205:AM@introv - SSC CR + field ASI_FOC_HK_Paid_Amount__c
            list<ASI_MFM_PO__c> po_list = [select Name, (select ASI_FOC_Budget_Amount__c,ASI_FOC_HK_Paid_Amount__c from ASI_FOC_Free_Goods_Requests__r  
                where ASI_FOC_Request_Status__c != 'Rejected' and ASI_FOC_Request_Status__c != 'Cancelled') 
                from ASI_MFM_PO__c where id in :po_set for update];
            for (ASI_MFM_PO__c po:po_list) {
                po.ASI_MFM_FOC_Consumed_Amount__c = 0;
                //20191205:AM@introv - SSC CR start
                po.ASI_MFM_HK_FOC_Amount__c = 0;
                po.ASI_MFM_HK_FOC_Paid_Amount__c = 0;
                //20191205:AM@introv - SSC CR end
                for (ASI_FOC_Free_Goods_Request__c rq:po.ASI_FOC_Free_Goods_Requests__r) {
                    if (rq.ASI_FOC_Budget_Amount__c != null) {
                        po.ASI_MFM_FOC_Consumed_Amount__c += rq.ASI_FOC_Budget_Amount__c;
                        po.ASI_MFM_HK_FOC_Amount__c += rq.ASI_FOC_Budget_Amount__c;					//20191205:AM@introv - SSC CR
                    }
                    //20191205:AM@introv - SSC CR start
                    if (rq.ASI_FOC_HK_Paid_Amount__c != null) {
                        po.ASI_MFM_HK_FOC_Paid_Amount__c += rq.ASI_FOC_HK_Paid_Amount__c;
                    }
                    //20191205:AM@introv - SSC CR end
                }
            }
            if (po_list.size() > 0) {
                update po_list;
            }
        }
    }
    
    public static void routineBeforeUpsert(list<ASI_FOC_Free_Goods_Request__c> trigger_new, map<id, ASI_FOC_Free_Goods_Request__c> trigger_oldMap) {
        if (trigger_new != null) {
            Time cutoffTimeGMT_1 = urgentDeliveryCutoffTimeGMT_1();
            Time cutoffTimeGMT_2 = urgentDeliveryCutoffTimeGMT_2();
            DateTime currentDateTime = Datetime.now();
            Date currentDate = currentDateTime.date();
            Time currentTime = currentDateTime.time();
            Date minDeliveryDate = currentDateTime.date();    
            
            //Added by Wilken on 20150814, move SOQL outside for loop
            Set<ID> poIDs = new Set<ID>();
            for (ASI_FOC_Free_Goods_Request__c r:trigger_new) {
                if (r.ASI_FOC_MFM_Consumer_AP_PO_Number__c != null){
                    poIDs.add(r.ASI_FOC_MFM_Consumer_AP_PO_Number__c);
                }
            }
            
            Map<id,ASI_MFM_PO__c> poMap = new Map<id,ASI_MFM_PO__c>([select id,ASI_MFM_PAF_Number__c from ASI_MFM_PO__c where id = :poIDs]);
            
            for (ASI_FOC_Free_Goods_Request__c r:trigger_new) {
                //20150506 Wilken: Validation to ensure Sales Rep cannot create POS FOC, checking done by record type
                if (Global_RecordTypeCache.getRt(r.recordTypeID).DeveloperName == 'ASI_FOC_HK_Free_Goods_Request_Sales' && r.ASI_FOC_Request_Type__c == 'POS')
                    r.addError('Cannot create POS Free Goods Request by Sales Department');
                    
                updateForInstruction(r);
                
//Auto uncheck STK4 if Request Type is POS
                if (r.ASI_FOC_Request_Type__c == 'POS' && r.ASI_FOC_STK_4_Count_Sales_Volume__c){
                    r.ASI_FOC_STK_4_Count_Sales_Volume__c = false;
                }
                    
//Auto fill in MFM PO PAF Number
                if (r.ASI_FOC_MFM_Consumer_AP_PO_Number__c != null && poMap.get(r.ASI_FOC_MFM_Consumer_AP_PO_Number__c) != null && poMap.get(r.ASI_FOC_MFM_Consumer_AP_PO_Number__c).ASI_MFM_PAF_Number__c != null){
                    r.ASI_FOC_Pre_Approval_Form_Number__c = poMap.get(r.ASI_FOC_MFM_Consumer_AP_PO_Number__c).ASI_MFM_PAF_Number__c;
                }
                
//Default "Alternate Delivery Address Floor" as "." when user leave it blank and "Reason for Address Change" is not blank
                if (r.ASI_FOC_Alternate_Delivery_Address_Floor__c == null && r.ASI_FOC_Reason_for_Address_Change__c != null){
                    r.ASI_FOC_Alternate_Delivery_Address_Floor__c = '.';
                }
                
//Update Delivery Date base on HKCRM SO Logic
                if (r.ASI_FOC_Request_Status__c == 'Open'){
                    Integer numDay;
                    
                    if (r.ASI_FOC_Date_of_Delivery__c != null){
                            numDay = currentDate.daysBetween(r.ASI_FOC_Date_of_Delivery__c);
                    }
                        
                    if (r.ASI_FOC_Urgent_Order__c && r.ASI_FOC_Date_of_Delivery__c != null){
                        //Delivery Date = Today Before 10
                        if (numDay == 0 && currentTime < cutoffTimeGMT_1){
                            System.debug('Delivery Date = Today Before 10');
                            //no validation needed
                        }
                        //Delivery Date = Today After 1000 before 1600
                        else if(numDay == 0 && currentTime <  cutoffTimeGMT_2 && currentTime > cutoffTimeGMT_1){
                            System.debug('Delivery Date = Today After 1000 before 1600');
                            minDeliveryDate = minDeliveryDate.addDays(1);
                            r.ASI_FOC_Urgent_Order__c = false;          
                        }
                        //Delivery Date = Today after 1600
                        else if(numDay == 0 && currentTime > cutoffTimeGMT_2){
                            System.debug('Delivery Date = Today, submitted after 1600, add one day');
                            minDeliveryDate = minDeliveryDate.addDays(1);
                        }
                        //Delivery Date = Today + 1 Before 10
                        else if(numDay == 1 && currentTime < cutoffTimeGMT_1){
                            //*****correct?
                            System.debug('Delivery Date = Today + 1 Before 10');
                            minDeliveryDate = minDeliveryDate;
                          }
                          
                        //DeliveryDate = Today + 1 After 10 before 1600
                        else if(numDay == 1 && currentTime > cutoffTimeGMT_1 && currentTime < cutoffTimeGMT_2){
                            System.debug('DeliveryDate = Today + 1 After 10 before 1600');
                            r.ASI_FOC_Urgent_Order__c = false;
                            minDeliveryDate = r.ASI_FOC_Date_of_Delivery__c;
                        }
                          
                        //DeliveryDate = Today + 1 After 16000 Do nothing
                        else if(numDay == 1 && currentTime > cutoffTimeGMT_2){
                            System.debug('DeliveryDate = Today + 1 After 16000 Do nothing');
                            minDeliveryDate = r.ASI_FOC_Date_of_Delivery__c;
                        }
                          
                        //DeliveryDate = Today + N before 10
                        else if (numDay > 1 &&  currentTime < cutoffTimeGMT_1){
                            System.debug('DeliveryDate = Today + N before 10');
                            minDeliveryDate = minDeliveryDate; 
                        }
                          
                        //DeliveryDate = Today + N after 10 before 1600
                        else if(numDay > 1 &&  currentTime > cutoffTimeGMT_1 && currentTime < cutoffTimeGMT_2){
                            System.debug('DeliveryDate = Today + N after 10 before 1600');
                            minDeliveryDate = minDeliveryDate.addDays(1);
                            r.ASI_FOC_Urgent_Order__c = false;
                        }

                        //DeliveryDate = Today + N after 1630
                        else if(numDay > 1 && currentTime > cutoffTimeGMT_2){
                            System.debug('DeliveryDate = Today + N after 1630');
                            minDeliveryDate = minDeliveryDate.addDays(1);
                        }

                        //Other Case
                        else {
                            System.debug('Other Case');
                            minDeliveryDate = r.ASI_FOC_Date_of_Delivery__c;
                        } 
                    }
                    //Urgent Order = false    
                    else if(r.ASI_FOC_Urgent_Order__c == false && r.ASI_FOC_Date_of_Delivery__c != null){
                        //Delivery Date = Today Before 10 Validation Rule Only              
                        //Delivery Date = Today After 10 before 1630 Validate Rule Only             
                        //Delivery Date = Today after 1630 Validation Rule Only             
                        //Delivery Date = Today + 1 Before 10 Do nothing
                        //Delivery Date = Today + 1 after 1630 before 1000
                        //DeliveryDate = Today + 1 After 1630
                        if(numDay == 0 && currentTime < cutoffTimeGMT_1){
                            System.debug('Not Urgent, Today before 1000 ');
                            minDeliveryDate = minDeliveryDate.addDays(1);
                        }
                        else if(numDay == 1 && currentTime > cutoffTimeGMT_2){
                            System.debug('Not Urgent, Today + 1 after 1600');
                            minDeliveryDate = r.ASI_FOC_Date_of_Delivery__c.addDays(1);
                        }
                        else if(numDay > 1){
                            System.debug('Not Urgent, Today + N');
                            minDeliveryDate = r.ASI_FOC_Date_of_Delivery__c;
                        }
                        else if(numDay == 1 && currentTime < cutoffTimeGMT_2 && currentTime > cutoffTimeGMT_1){
                            System.debug('Not Urgent, Today + 1 between 1000 and 1600');
                            minDeliveryDate = r.ASI_FOC_Date_of_Delivery__c;
                        }

                        //DeliveryDate = Today + N before 10 Do nothing
                        //DeliveryDate = Today + N after 10 before 1630 Do nothing
                        //DeliveryDate = Today + N after 1630 Do nothing  
                        else {
                            System.debug('Not Urgent, Others');
                            minDeliveryDate = r.ASI_FOC_Date_of_Delivery__c;
                        }
                    }
                    
                    //Update Delivery Date after validation
                    r.ASI_FOC_Date_of_Delivery__c = minDeliveryDate;
                }
            }
        }
    }
    
    //Get the DeliveryCutOffTimeGMT from CustomSetting and turn to string
    private static Time urgentDeliveryCutoffTimeGMT_1() {
        Time myUrgentDeliveryCutoffTimeGMT_1;
        ASI_HK_CRM_ThresholdValues__c thresholdValueSetting = ASI_HK_CRM_ThresholdValues__c.getOrgDefaults();
        if (thresholdValueSetting != null) {
            myUrgentDeliveryCutoffTimeGMT_1 = strToTime(thresholdValueSetting.ASI_HK_CRM_SO_Urgent_Cutoff_Time_1__c);
        }
        
        return myUrgentDeliveryCutoffTimeGMT_1;
    }
  
    private static Time urgentDeliveryCutoffTimeGMT_2() {
        Time myUrgentDeliveryCutoffTimeGMT_2;
        ASI_HK_CRM_ThresholdValues__c thresholdValueSetting = ASI_HK_CRM_ThresholdValues__c.getOrgDefaults();
        if (thresholdValueSetting != null) {
            myUrgentDeliveryCutoffTimeGMT_2 = strToTime(thresholdValueSetting.ASI_HK_CRM_SO_Urgent_Cutoff_Time_2__c);
        }
         
        return myUrgentDeliveryCutoffTimeGMT_2;
    }
    
    private static void updateForInstruction(ASI_FOC_Free_Goods_Request__c rq) {
        String winInstType = rq.ASI_FOC_Delivery_Window_Instruction__c;
        string new_dt1 = rq.ASI_FOC_Delivery_Time_1__c;
        string new_dt2 = rq.ASI_FOC_Delivery_Time_2__c;
        String wholeInstStr = null;
        
        if ('Between' == winInstType){
            if (new_dt1 != null && new_dt2 != null){
                wholeInstStr = String.format('{0}\\{1}\\{2}', new String[] {winInstType, new_dt1, new_dt2});
            }
            else if(new_dt1 != null && new_dt2 == null){
                    string dt1_hr = new_dt1.mid(0,2);
                    integer dt2_hr = integer.valueof(dt1_hr) +2;
                    new_dt2= '0' + string.valueof(dt2_hr) + ':' + new_dt1.mid(3,2);
                    rq.ASI_FOC_Delivery_Time_2__c = new_dt2.right(5);
                    
                    wholeInstStr = String.format('{0}\\{1}\\{2}', new String[] {
                        winInstType
                        , new_dt1
                        , new_dt2.right(5)
                    });
            }
        }
        else {
                if (new_dt1 != null) {
                    wholeInstStr = String.format('{0}\\{1}', new String[] {winInstType, new_dt1});
                }
        }
        
        /*if (rq.ASI_FOC_Refer_to_CRM_Order_MKT__c != null)
            wholeInstStr = wholeInstStr + '\\' + rq.ASI_FOC_Refer_to_CRM_Order_MKT__c;
            
        else if (rq.ASI_FOC_Refer_to_CRM_Order__c != null){
            String soNum = [select Name from ASI_HK_CRM_Sales_Order__c where id = :rq.ASI_FOC_Refer_to_CRM_Order__c limit 1].Name;
            wholeInstStr = wholeInstStr + '\\' + soNum;
        }*/
        
        rq.ASI_FOC_Instruction__c = wholeInstStr;
    }
    
    public static void routineBeforeUpdate(list<ASI_FOC_Free_Goods_Request__c> trigger_new, map<id, ASI_FOC_Free_Goods_Request__c> trigger_oldMap) {
// Set the approvers for the free good requests based on the routing rule objects           
        set<id> rid_set = new set<id>();
        set<id> owner_set = new set<id>();
        set<String> validRTDevNameSet = new Set<String>{'ASI_FOC_HK_Free_Goods_Request_Sales_Admin','ASI_FOC_HK_Free_Goods_Request_Sales'};
        list<RecordType> validRTList = [SELECT Id FROM RecordType WHERE DeveloperName IN :validRTDevNameSet AND SobjectType = 'ASI_FOC_Free_Goods_Request__c'];
        set<ID> validRTIdsSet = new Set<ID>();
        
        for (RecordType rt : validRTList) validRTIdsSet.add(rt.Id);
         
        for (ASI_FOC_Free_Goods_Request__c r:trigger_new) {
            System.debug('Request Record Type Name: ' + r.RecordTypeID);
            if (validRTIdsSet.contains(r.RecordTypeId)){
                rid_set.add(r.id);
                owner_set.add(r.ownerId);
                r.ASI_FOC_Approver_1__c = null;
                r.ASI_FOC_Approver_2__c = null;
                r.ASI_FOC_Approver_3__c = null;
                r.ASI_FOC_Approver_4__c = null;
                r.ASI_FOC_Approver_5__c = null; 
                r.ASI_FOC_Approver_6__c = null;
                r.ASI_FOC_Approver_7__c = null;                                                                                                     
            }
        }
          
        Map<id,ASI_FOC_Free_Goods_Request__c> reqMap = new Map<id,ASI_FOC_Free_Goods_Request__c>([select ASI_FOC_Account_DA__r.Name, ASI_FOC_MFM_Consumer_AP_PO_Number__r.ASI_MFM_Prefix__r.Name from ASI_FOC_Free_Goods_Request__c where id in :rid_set]);
        
        if (rid_set.size() > 0) {
            map<id, user> user_map = new map<id, user>([select userRole.developerName from user where id in :owner_set]);
            set<string> role_set = new set<string>();
            for (user u:user_map.values()) {
                role_set.add(u.userRole.developerName);
            }           
            list<ASI_FOC_Route_Type__c> rt_list = [select ASI_FOC_Role_Name__c, ASI_FOC_Line_Manager__c, ASI_FOC_Director__c, ASI_FOC_Finance_Director__c, ASI_FOC_LUX_Approver__c, ASI_FOC_Sales_POS_Approver__c ,ASI_FOC_Department__c, ASI_FOC_Address_Approver__c,  ASI_FOC_Finance_Approver__c,ASI_FOC_POSM_Approver__c,ASI_FOC_GH_Approver__c from ASI_FOC_Route_Type__c where ASI_FOC_Role_Name__c in :role_set];

            //20150318 Wilken: Query Request Item outside for loop
            List<ASI_FOC_Request_Item__c> itemList = [select ASI_FOC_SKU__r.ASI_MFM_SKU_Code__c,  ASI_FOC_Request_Order__c from ASI_FOC_Request_Item__c where ASI_FOC_Request_Order__c in :rid_set];
            System.debug('Request Item List Size: ' + itemList.size());
            
            for (ASI_FOC_Free_Goods_Request__c r:trigger_new) {
                integer approver_count = 0;
                if (rid_set.contains(r.id)) {
                    //Added by Wilken on 20131030, assign MFM PO Prefix to FOC header for sharing rule
                    if (reqMap.get(r.id) != null && reqMap.get(r.id).ASI_FOC_MFM_Consumer_AP_PO_Number__r.ASI_MFM_Prefix__r.Name != null){
                        r.ASI_FOC_MFM_PO_Prefix__c = reqMap.get(r.id).ASI_FOC_MFM_Consumer_AP_PO_Number__r.ASI_MFM_Prefix__r.Name;
                    }
                    
                    string role_name = user_map.get(r.ownerId).userRole.developerName;
                    for (ASI_FOC_Route_Type__c rt:rt_list) {
                        System.debug('Owner Role Name: ' + role_name + ' Route Type Role Name: ' + rt.ASI_FOC_Role_Name__c);
                        if (role_name == rt.ASI_FOC_Role_Name__c) {
                            set<ID> approverSet = new set<ID>();
                            List<ID> approverList = new List<ID>();
                        
                            if (r.ASI_FOC_Request_Type__c == 'POS'){
                                //POS Free Goods
                                
                                if (rt.ASI_FOC_POSM_Approver__c!=null && !approverSet.contains(rt.ASI_FOC_POSM_Approver__c)){ 
                                    approverSet.add(rt.ASI_FOC_POSM_Approver__c);     
                                    approverList.add(rt.ASI_FOC_POSM_Approver__c);     
                                }//ASI_FOC_GH_Approver__c
                                
                            }
                            else {
                                //Non-POS type Free Goods
                                
                                if (r.ASI_FOC_SYS_Total_Premium_Item_Count__c > 0 || r.ASI_FOC_SYS_Total_Bottle_Count__c > 24){
                                    //Premium FOC or More than 6 bottles
                                  
                                    if (!approverSet.contains(rt.ASI_FOC_Director__c)){ 
                                        approverSet.add(rt.ASI_FOC_Director__c);     
                                        approverList.add(rt.ASI_FOC_Director__c);     
                                    }
                                    
                                    if (!approverSet.contains(rt.ASI_FOC_Finance_Director__c)){ 
                                        approverSet.add(rt.ASI_FOC_Finance_Director__c);     
                                        approverList.add(rt.ASI_FOC_Finance_Director__c);     
                                    }
                                }
                                else {
                                    //No Premium or less than 6 bottles
                                    if (!approverSet.contains(rt.ASI_FOC_Line_Manager__c)){ 
                                        approverSet.add(rt.ASI_FOC_Line_Manager__c);
                                        approverList.add(rt.ASI_FOC_Line_Manager__c);
                                    }
                                    
                                    if(!approverSet.contains(rt.ASI_FOC_Finance_Approver__c)){ 
                                        approverSet.add(rt.ASI_FOC_Finance_Approver__c);
                                        approverList.add(rt.ASI_FOC_Finance_Approver__c);
                                    }
                                }
                            }
                            
                            if (r.ASI_FOC_STK_4_Count_Sales_Volume__c){
                                //If STK4 order, need Finance Director approval
                                if (!approverSet.contains(rt.ASI_FOC_Finance_Director__c)){ 
                                    approverSet.add(rt.ASI_FOC_Finance_Director__c);
                                    approverList.add(rt.ASI_FOC_Finance_Director__c);
                                }
                            }
                            
                            System.debug('Owner RT Dept: ' + rt.ASI_FOC_Department__c + ' Reason for Address Change: ' + r.ASI_FOC_Reason_for_Address_Change__c + ' FOC Address Approver: ' + rt.ASI_FOC_Address_Approver__c + ' Account DA Name:' + reqMap.get(r.id).ASI_FOC_Account_DA__r.Name);
                            if (rt.ASI_FOC_Department__c == 'Sales' && r.ASI_FOC_Reason_for_Address_Change__c != null && !reqMap.get(r.id).ASI_FOC_Account_DA__r.Name.startsWith('CASH SALES')){
                                //If Sales FOC and need to change address, add Teresa as approver
                                if (!approverSet.contains(rt.ASI_FOC_Address_Approver__c)){ 
                                    approverSet.add(rt.ASI_FOC_Address_Approver__c);
                                    approverList.add(rt.ASI_FOC_Address_Approver__c);
                                }
                            }
                            
                            if(r.ASI_FOC_Is_GH__c ){
                            
                                if (rt.ASI_FOC_Director__c!=null && !approverSet.contains(rt.ASI_FOC_Director__c)){ 
                                        approverSet.add(rt.ASI_FOC_Director__c);     
                                        approverList.add(rt.ASI_FOC_Director__c);     
                                }
                                    
                                if (rt.ASI_FOC_GH_Approver__c!=null && !approverSet.contains(rt.ASI_FOC_GH_Approver__c)){ 
                                    approverSet.add(rt.ASI_FOC_GH_Approver__c);
                                    approverList.add(rt.ASI_FOC_GH_Approver__c);
                                }
                            }
                            
                            for (ID approverID : approverList){
                                    if (approver_count == 0) {
                                            r.ASI_FOC_Approver_1__c = approverID;
                                        }
                                    else if (approver_count == 1) {                                 
                                        r.ASI_FOC_Approver_2__c = approverID;
                                    }
                                    else if (approver_count == 2) {                                 
                                        r.ASI_FOC_Approver_3__c = approverID;
                                    }
                                    else if (approver_count == 3) {                                 
                                        r.ASI_FOC_Approver_4__c = approverID;
                                    }
                                    else if (approver_count == 4) {                                 
                                        r.ASI_FOC_Approver_5__c = approverID;
                                    }       
                                    else if (approver_count == 5) {                                 
                                        r.ASI_FOC_Approver_6__c = approverID;
                                    }
                                    else if (approver_count == 6) {                                 
                                        r.ASI_FOC_Approver_7__c = approverID;
                                    }                                                                   
                                    approver_count++;        
                                }
                            break;
                        }
                    }
                }               
            }               
        }
    }       
    
    private static Time strToTime(String timeStr) {
        try {
          if (timeStr != null && timeStr.trim() != '') {
            List<String> timeElements = timeStr.trim().split(':', 0);
            Integer numOfTimeEle = timeElements.size();
            if (numOfTimeEle > 3 || numOfTimeEle <= 0) throw new ASI_HK_CRM_CustomException();
            for (String timeEle : timeElements) {
              if (!timeEle.trim().isNumeric())
                throw new ASI_HK_CRM_CustomException();
            }
            Integer hour = 0, minute = 0, second = 0, millisecond = 0;
            if (numOfTimeEle >= 1) hour = Integer.valueOf(timeElements[0].trim());
            if (numOfTimeEle >= 2) minute = Integer.valueOf(timeElements[1].trim());
            if (numOfTimeEle == 3) second = Integer.valueOf(timeElements[2].trim());
            return Time.newInstance(hour, minute, second, millisecond);
          }
        } catch (Exception e) {
          throw new ASI_HK_CRM_CustomException('Invalid time string in custom setting');
        }
        return null;
    }
}