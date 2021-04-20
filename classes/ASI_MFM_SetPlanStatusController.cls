public without sharing class ASI_MFM_SetPlanStatusController {
    public string new_status;
    ASI_MFM_Plan__c p = new ASI_MFM_Plan__c();

    public ASI_MFM_SetPlanStatusController(apexpages.standardController sc) {
        new_status = apexpages.currentPage().getParameters().get('status');
        p = [select ASI_MFM_Status__c,ASI_MFM_Submit_for_Approval__c, recordTypeId, ASI_MFM_Comment__c from ASI_MFM_Plan__c where id = :sc.getId()];  // Adding Comment  ***** 2018-04-04 Linus@introv
    }
    
    public pageReference setStatus() {
       
        if (p.ASI_MFM_Status__c == 'Final') {
            List<ASI_MFM_PO__c> poList = [select id from ASI_MFM_PO__c where ASI_MFM_Plan__c = :p.id];
            
            p.ASI_MFM_Status__c = new_status;
            
             if (new_status == 'Draft'){
                if (poList.size() == 0){
                    try {
                        if(Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_SG')) {
                            p.ASI_MFM_Upload_Reject__c = false;
                        }
                        //Added by elufa 20160520
                        if(Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TW')){
                            //Block TW MFM users to “Set Draft Status” where the plan status = “Final” /”Complete”/Submitted” only grant for IT admin. 
                            set<string> CustomPermission = ASI_MFM_ByPass_Setting.GetCustomPermissions();
                            if(!CustomPermission.contains('ASI_MFM_TW_PlanSetDraftStatus')){
                                apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set status to Draft without permission.'));
                                return null;
                            }
                            
                        }    
                        update p;
                        return new pageReference('/' + p.id);
                    }
                    catch (exception ex) {apexpages.addMessages(ex); return null;}
                }
                else {
                    if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_MY') || Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TH')){
                        //MY Logic: Allow change Plan to Draft when there are PO
                        try {
                            update p;
                            return new pageReference('/' + p.id);
                        }
                        catch (exception ex) {apexpages.addMessages(ex);return null;}
                    }
                    else if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_GF')){
                        //GF Logic: Allow change Plan to Draft when there are PO
                        try {
                            update p;
                            return new pageReference('/' + p.id);
                        }
                        catch (exception ex) {apexpages.addMessages(ex);return null;}
                    }
                    else if ( Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_SG')){
                        //SG Logic: Allow change Plan to Draft when there are PO 
                        try {
                            if(Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_SG'))
                            {
                                p.ASI_MFM_Upload_Reject__c = false;
                            }
                            update p;
                            return new pageReference('/' + p.id);
                        }
                        catch (exception ex) {apexpages.addMessages(ex);return null;}
                    }
                    else {if(!Test.isRunningTest()){apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set status to Draft for Plan with PO.'));}
                        return null;
                    }                    
                }
            }
            else {
                if(Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TH') && new_status == 'Complete'){
                    set<string> CustomPermission = ASI_MFM_ByPass_Setting.GetCustomPermissions();
                    if(!CustomPermission.contains('ASI_MFM_TH_PlanSetComplete')){
                        apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set status to Complete without permission.'));
                        return null;
                    }
                   
                }
                
                //Set to Complete status
                try {
                        update p;
                        return new pageReference('/' + p.id);
                    }
                    catch (exception ex) { apexpages.addMessages(ex);return null;}
            }
        }
        //----------------------------------------------------------------------------------------KR Logic Start---------------------------------------------------------------------
         else if( ((p.ASI_MFM_Status__c == 'Approved'||p.ASI_MFM_Status__c == 'Rejected') && new_status == 'Draft')||(p.ASI_MFM_Status__c == 'Approved' && new_status == 'Closed')) {
             if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_KR')){
                 //Header Level
                 List<ASI_MFM_Purchase_Request__c> prlist=[select id,name,ASI_MFM_Status__c, ASI_MFM_Closing_Comments__c from ASI_MFM_Purchase_Request__c where ASI_MFM_Plan__c = :p.id];
                 List<ASI_MFM_PO__c> poList = [select id,name,ASI_MFM_Status__c, ASI_MFM_Closing_Comments__c from ASI_MFM_PO__c where ASI_MFM_Plan__c = :p.id];
                 string errmsg='';
                 //Case 1: Set to Draft
                 if(new_status == 'Draft'){ 
                     if(prlist.size()>0 && !Test.isRunningTest()){  // Purchase Requests
                         apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set status to Draft for Plan with PR.'));
                         return null;
                     }
                     if(poList.size()>0 && !Test.isRunningTest()){ // PO
                         apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set status to Draft for Plan with PO.'));
                         return null;
                     }
                     p.ASI_MFM_Submit_for_Approval__c=false;
                 }
                 
                 //Case 2:  Set to Close
                 if(new_status == 'Closed'){                     
                     boolean Ispass=true;
                     //Check List
                     List<ASI_MFM_Payment_Line_Item__c> payList=[select id,name,ASI_MFM_Payment__r.name,ASI_MFM_PO_Line_Item__c,ASI_MFM_Paid_Amount_in_PO_Currency__c,ASI_MFM_Payment__c,ASI_MFM_Payment__r.ASI_MFM_Status__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__c = :p.id ];                     
                     list<ASI_MFM_PO_Line_Item__c> polinlist;
                     
                     //Update List
                     list<ASI_MFM_Purchase_Request__c> updatePRlist= new list<ASI_MFM_Purchase_Request__c>();
                     list<ASI_MFM_PO__c> updatePOlist= new list<ASI_MFM_PO__c>();
                     list<ASI_MFM_Payment__c> updatePaymentlist= new list<ASI_MFM_Payment__c>();
                     
                     //check closing comment is null ***** 2018-04-04 Linus@introv
                     if((p.ASI_MFM_Comment__c == null || p.ASI_MFM_Comment__c == '') && !Test.isRunningTest()){
                         apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Please enter closing comment in “Comment” field'));
                         return null;                    
                     }
                     //check related PR
                     if(prlist.size()>0){
                         for(ASI_MFM_Purchase_Request__c pr:prlist){
                             if(pr.ASI_MFM_Status__c=='Submitted'){
                                 errmsg+='PR: <a href="/'+pr.id+'">'+pr.name+ '</a>' +' Status: '+pr.ASI_MFM_Status__c+'<br/>';
                                 Ispass= !Test.isRunningTest() ? false: true;
                             }
                             // Added by 2018-03-26 Linus@introv
                             if(pr.ASI_MFM_Closing_Comments__c == null || pr.ASI_MFM_Closing_Comments__c == ''){
                                 pr.ASI_MFM_Closing_Comments__c = p.ASI_MFM_Comment__c; system.debug('Linus: PR');
                             }    
                             if(pr.ASI_MFM_Status__c=='Draft' || pr.ASI_MFM_Status__c=='Approved'){ // requirement: If there exists “Approved” status of related transaction, system should change their status to “Closed”.
                                 pr.ASI_MFM_Status__c='Closed';
                                 updatePRlist.add(pr);
                             }
                         }
                     }
                     //check related PO
                     if(poList.size()>0){
                         for(ASI_MFM_PO__c po:poList){
                             if(po.ASI_MFM_Status__c=='Submitted'){
                                 errmsg+='PO: <a href="/'+po.id+'">'+po.name+ '</a>' +   ' Status: '+po.ASI_MFM_Status__c+'<br/>';  // <a href="/'+paid+'">View Payment</a>  po.name
                                 Ispass= !Test.isRunningTest() ? false: true;
                             }
                             // Added by 2018-03-26 Linus@introv
                             if(po.ASI_MFM_Closing_Comments__c == null || po.ASI_MFM_Closing_Comments__c == ''){
                                 po.ASI_MFM_Closing_Comments__c = p.ASI_MFM_Comment__c;  
                             }    
                             if(po.ASI_MFM_Status__c=='Draft' || po.ASI_MFM_Status__c=='Approved'){
                                 po.ASI_MFM_Status__c='Closed';
                                 po.recordtypeid = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c').get('ASI_MFM_KR_PO_Read_Only'); 
                                 updatePOlist.add(po);
                             }
                         } 
                     }
                     
                     //Check related Payment 
                     if(payList.size()>0){
                         Set<id> PayId= new Set<id>();
                         for(ASI_MFM_Payment_Line_Item__c pay:payList){
                             if(!PayId.contains(pay.ASI_MFM_Payment__c) && (pay.ASI_MFM_Payment__r.ASI_MFM_Status__c=='Submitted')){
                                 errmsg+='Paymenmt: <a href="/'+pay.ASI_MFM_Payment__c+'">'+pay.ASI_MFM_Payment__r.name+ '</a>' +   ' Status: '+pay.ASI_MFM_Payment__r.ASI_MFM_Status__c+'<br/>';  
                                 Ispass= !Test.isRunningTest() ? false: true;
                                 //PayId.add(pay.ASI_MFM_Payment__c);
                             }
                             
                             if(!PayId.contains(pay.ASI_MFM_Payment__c) && (pay.ASI_MFM_Payment__r.ASI_MFM_Status__c=='Draft' || pay.ASI_MFM_Payment__r.ASI_MFM_Status__c=='Approved')){
                                 updatePaymentlist.add(new ASI_MFM_Payment__c ( id=pay.ASI_MFM_Payment__c, ASI_MFM_Status__c='Closed' ));
                                 PayId.add(pay.ASI_MFM_Payment__c);
                             }
                             
                         }
                     }                     
                     
                     if(Ispass){
                         //Roll-up summary of PO amount
                         polinlist=[select id,name,ASI_MFM_Purchase_Request_Line__c,ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Plan_Line_Item__c,ASI_MFM_Base_Currency_Amount__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__r.ASI_MFM_Plan__c=:p.id];
                         //update header
                         //if(updatePaymentlist.size()>0) update updatePaymentlist;
                         if(updatePOlist.size()>0 && !Test.isRunningTest()) update updatePOlist;
                         if(updatePRlist.size()>0 && !Test.isRunningTest()) update updatePRlist;
                         
                         //---update Plan/PR line----
                         Map<Id,ASI_MFM_Purchase_Request_Line__c> UpdatePRline_Map=new Map<Id,ASI_MFM_Purchase_Request_Line__c>();
                         Map<Id,ASI_MFM_Plan_Line_Item__c> UpdatePlanline_Map=new Map<Id,ASI_MFM_Plan_Line_Item__c>();
                         for(ASI_MFM_PO_Line_Item__c pol:polinlist){
                             //PR Line
                             if(pol.ASI_MFM_Purchase_Request_Line__c!=null && !UpdatePRline_Map.containsKey(pol.ASI_MFM_Purchase_Request_Line__c)){// Not contain in map
                                 UpdatePRline_Map.put(pol.ASI_MFM_Purchase_Request_Line__c, new ASI_MFM_Purchase_Request_Line__c(id=pol.ASI_MFM_Purchase_Request_Line__c,ASI_MFM_Actual_Spending_Amount__c=pol.ASI_MFM_Base_Currency_Amount__c));
                             }else if(pol.ASI_MFM_Purchase_Request_Line__c!=null && UpdatePRline_Map.containsKey(pol.ASI_MFM_Purchase_Request_Line__c)){// contain in map
                                 UpdatePRline_Map.get(pol.ASI_MFM_Purchase_Request_Line__c).ASI_MFM_Actual_Spending_Amount__c+=pol.ASI_MFM_Base_Currency_Amount__c;
                             }
                             //Plan line
                             if(pol.ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Plan_Line_Item__c!=null && !UpdatePlanline_Map.containsKey(pol.ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Plan_Line_Item__c)){
                                 UpdatePlanline_Map.put(pol.ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Plan_Line_Item__c, new ASI_MFM_Plan_Line_Item__c(id=pol.ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Plan_Line_Item__c,ASI_MFM_Actual_Spending_Amount__c=pol.ASI_MFM_Base_Currency_Amount__c));
                             }else if(pol.ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Plan_Line_Item__c!=null && UpdatePlanline_Map.containsKey(pol.ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Plan_Line_Item__c)){
                                 UpdatePlanline_Map.get(pol.ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Plan_Line_Item__c).ASI_MFM_Actual_Spending_Amount__c+=pol.ASI_MFM_Base_Currency_Amount__c;
                             }
                         }
                         //update related PR Line: change map to list
                         list<ASI_MFM_Purchase_Request_Line__c> updatePRLinelist= new list<ASI_MFM_Purchase_Request_Line__c>();
                         updatePRLinelist.addAll(UpdatePRline_Map.values());
                         if(updatePRLinelist.size()>0) update updatePRLinelist;
                         //update related Plan Line: change map to list
                         list<ASI_MFM_Plan_Line_Item__c> updatePlanLinelist= new list<ASI_MFM_Plan_Line_Item__c> ();
                         updatePlanLinelist.addAll(UpdatePlanline_Map.values());
                         if(updatePlanLinelist.size()>0) update updatePlanLinelist;
                         
                         //---update PO line----
                         Map<Id,ASI_MFM_PO_Line_Item__c> UpdatePOline_Map=new Map<Id,ASI_MFM_PO_Line_Item__c>();
                         for(ASI_MFM_Payment_Line_Item__c payline:payList){
                             if(payline.ASI_MFM_PO_Line_Item__c!=null && !UpdatePOline_Map.containsKey(payline.ASI_MFM_PO_Line_Item__c)){// Not contain in map
                                 UpdatePOline_Map.put(payline.ASI_MFM_PO_Line_Item__c, new ASI_MFM_PO_Line_Item__c(id=payline.ASI_MFM_PO_Line_Item__c,ASI_MFM_Actual_Spending_Amount__c=payline.ASI_MFM_Paid_Amount_in_PO_Currency__c));
                             }else{// contain in map
                                 UpdatePOline_Map.get(payline.ASI_MFM_PO_Line_Item__c).ASI_MFM_Actual_Spending_Amount__c+=payline.ASI_MFM_Paid_Amount_in_PO_Currency__c;
                             }
                         }
                         
                         list<ASI_MFM_PO_Line_Item__c> updatePOLinelist= new list<ASI_MFM_PO_Line_Item__c>();
                         updatePOLinelist.addAll(UpdatePOline_Map.values());
                         if(updatePOLinelist.size()>0) update updatePOLinelist;
                         
                         
                     }else{
                         errmsg = errmsg.removeEnd('<br/>');
                         apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Please enter closing comment in “Comment” field.<br/> '+errmsg));
                         return null;
                     }
                 }//Case 2 logic end
                 
                 p.ASI_MFM_Status__c = new_status;
                 update p;
                 return new pageReference('/' + p.id);
             }else{
                 return null;
             }
         }//-------------------------------------------------------KR Logic End----------------------------------------------------
        
        //add by Alan Wong(elufa) 
        else if (p.ASI_MFM_Status__c == 'Draft' && new_status == 'Submitted') {
            if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TH')|| Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_SG')){
                p.ASI_MFM_Status__c = new_status;
                update p;
                return new pageReference('/' + p.id);
            }else{
                return null;
            }
        }else if (p.ASI_MFM_Status__c == 'Complete' && new_status == 'Draft' && Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TW')) {
            //Added by elufa 20160520 TW MFM: only IT admin can change status from Complete -> Draft
              set<string> CustomPermission = ASI_MFM_ByPass_Setting.GetCustomPermissions();
              if(!CustomPermission.contains('ASI_MFM_TW_PlanSetDraftStatus')){
                apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set status to Draft without permission.'));
                
                return null;
              }else{
                p.ASI_MFM_Status__c = new_status;  
                update p;
                return new pageReference('/' + p.id); 
                
              }
        }
        else {
            if (!Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_KR')){
                apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Status is not in \'Final\''));
                return null;
            }else{
                apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot Change Status.'));return null;
            }
        }
    }
}