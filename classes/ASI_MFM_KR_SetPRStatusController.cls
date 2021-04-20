public without sharing  class ASI_MFM_KR_SetPRStatusController {
    public string new_status;
    public string closingComment; //20180119 Introv
    ASI_MFM_Purchase_Request__c p = new ASI_MFM_Purchase_Request__c();
    
    public ASI_MFM_KR_SetPRStatusController(apexpages.standardController sc) {
        new_status = apexpages.currentPage().getParameters().get('status');
        closingComment = apexpages.currentPage().getParameters().get('comment');
        p = [select id, ASI_MFM_Closing_Comments__c, ASI_MFM_Plan__c,ASI_MFM_Submit_for_Approval__c,ASI_MFM_Plan__r.name,ASI_MFM_Plan__r.ASI_MFM_Status__c,ASI_MFM_Status__c, recordTypeId from ASI_MFM_Purchase_Request__c where id = :sc.getId()];
        //20180119 Introv added ASI_MFM_Closing_Comments__c
    }
    
    public pageReference setStatus() {
        List<ASI_MFM_PO__c> poList = [select id,name,ASI_MFM_Status__c, ASI_MFM_Total_Receipt_Amount__c from ASI_MFM_PO__c where ASI_MFM_Purchase_Request__c = :p.id]; // 20180109 Introv added ASI_MFM_PO__c.ASI_MFM_Total_Receipt_Amount__c 
        
        //Case: change to Closed 
        if(new_status=='Closed'){
            boolean Ispass=true;
            string errmsg='';
            
            //20180109 Introv
            Boolean hasReceipt = False;
            Decimal totalApprovedPaymentAmt = 0;
            Decimal totalReceiptAmt = 0;
            
            List<ASI_MFM_Payment_Line_Item__c> payList=[select id,name,ASI_MFM_Payment__r.name,ASI_MFM_PO_Line_Item__c,ASI_MFM_Paid_Amount_in_PO_Currency__c,ASI_MFM_Payment__c,ASI_MFM_Payment__r.ASI_MFM_Status__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO__r.ASI_MFM_Purchase_Request__c = :p.id ];                     
            
            //Updated List
            list<ASI_MFM_PO__c> updatePOlist= new list<ASI_MFM_PO__c>();
            list<ASI_MFM_Payment__c> updatePaymentlist= new list<ASI_MFM_Payment__c>();
            
            
            
            //check related PO
            if(poList.size()>0){
                for(ASI_MFM_PO__c po:poList){
                    if(po.ASI_MFM_Status__c=='Draft' || po.ASI_MFM_Status__c=='Submitted'){
                        errmsg+='PO: <a href="/'+po.id+'">'+po.name+ '</a>' +   ' Status: '+po.ASI_MFM_Status__c+'<br/>';  // <a href="/'+paid+'">View Payment</a>  po.name
                        Ispass=false;
                    }
                    if(po.ASI_MFM_Status__c=='Approved'){
	                    po.ASI_MFM_Closing_Comments__c = closingComment;//p.ASI_MFM_Closing_Comments__c;//Introv 20180117
                        po.ASI_MFM_Status__c='Closed';
                        updatePOlist.add(po);
                    }

                    
                    totalReceiptAmt += (po.ASI_MFM_Total_Receipt_Amount__c != Null ? po.ASI_MFM_Total_Receipt_Amount__c : 0);
                } 
            }
            
            
            //Check related Payment 
            if(payList.size()>0){
                Set<id> PayId= new Set<id>();
                for(ASI_MFM_Payment_Line_Item__c pay:payList){
                    if(!PayId.contains(pay.ASI_MFM_Payment__c) && (pay.ASI_MFM_Payment__r.ASI_MFM_Status__c=='Draft' || pay.ASI_MFM_Payment__r.ASI_MFM_Status__c=='Submitted')){
                        errmsg+='Paymenmt: <a href="/'+pay.ASI_MFM_Payment__c+'">'+pay.ASI_MFM_Payment__r.name+ '</a>' +   ' Status: '+pay.ASI_MFM_Payment__r.ASI_MFM_Status__c+'<br/>';  
                        Ispass=false;
                        PayId.add(pay.ASI_MFM_Payment__c);
                    }
                    
                    //20180109 Introv
                    if(pay.ASI_MFM_Payment__r.ASI_MFM_Status__c=='Approved' || pay.ASI_MFM_Payment__r.ASI_MFM_Status__c=='Complete'){
                        totalApprovedPaymentAmt += ( pay.ASI_MFM_Paid_Amount_in_PO_Currency__c != Null ? pay.ASI_MFM_Paid_Amount_in_PO_Currency__c : 0);
                    }
                    //20180109 End
                    
                    //20180123 Introv Commented
                    /*if(!PayId.contains(pay.ASI_MFM_Payment__c) && pay.ASI_MFM_Payment__r.ASI_MFM_Status__c=='Approved'){
                        updatePaymentlist.add(new ASI_MFM_Payment__c ( id=pay.ASI_MFM_Payment__c, ASI_MFM_Status__c='Closed' ));
                        PayId.add(pay.ASI_MFM_Payment__c);
                    }*/
                }
            }//Check related Payment End
            
            Decimal tol = ASI_MFM_Setting__c.getInstance().ASI_MFM_KR_PO_Close_Tolerance__c != Null ? ASI_MFM_Setting__c.getInstance().ASI_MFM_KR_PO_Close_Tolerance__c/100 : 1;
            Decimal rangeS = totalReceiptAmt * (1 - tol);
            Decimal rangeE = totalReceiptAmt * (1 + tol);
            //20180109 Introv
            if(!(rangeS <= totalApprovedPaymentAmt && totalApprovedPaymentAmt <= rangeE)){
                Ispass = False;
                errmsg += 'You cannot close this PR as there exists remaining receipt amount, Total Receipt Amt: ' + totalReceiptAmt + ' Total Payment Amt: ' + totalApprovedPaymentAmt;
            }
            
            if(Ispass){
                if(updatePOlist.size()>0) update updatePOlist;
                if(updatePaymentlist.size()>0) update updatePaymentlist;
                
                //***Update PR Line
                Map<Id,ASI_MFM_Purchase_Request_Line__c> UpdatePRline_Map=new Map<Id,ASI_MFM_Purchase_Request_Line__c>();
                //Roll-up summary of PO amount
                list<ASI_MFM_PO_Line_Item__c> POLineList=[select id,name,ASI_MFM_Purchase_Request_Line__c,ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Plan_Line_Item__c,ASI_MFM_Base_Currency_Amount__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Actual_Spending_Amount__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__r.ASI_MFM_Purchase_Request__c = :p.id];
                
                for(ASI_MFM_PO_Line_Item__c pol:POLineList){
                    //PR Line
                    if(pol.ASI_MFM_Purchase_Request_Line__c!=null && !UpdatePRline_Map.containsKey(pol.ASI_MFM_Purchase_Request_Line__c)){// Not contain in map
                        UpdatePRline_Map.put(pol.ASI_MFM_Purchase_Request_Line__c, new ASI_MFM_Purchase_Request_Line__c(id=pol.ASI_MFM_Purchase_Request_Line__c,ASI_MFM_Actual_Spending_Amount__c=pol.ASI_MFM_Base_Currency_Amount__c));
                    }else if(pol.ASI_MFM_Purchase_Request_Line__c!=null && UpdatePRline_Map.containsKey(pol.ASI_MFM_Purchase_Request_Line__c)){// contain in map  
                        UpdatePRline_Map.get(pol.ASI_MFM_Purchase_Request_Line__c).ASI_MFM_Actual_Spending_Amount__c+=pol.ASI_MFM_Base_Currency_Amount__c;
                    }
                }
                
                list<ASI_MFM_Purchase_Request_Line__c> updatePRLinelist= new list<ASI_MFM_Purchase_Request_Line__c>();
                updatePRLinelist.addAll(UpdatePRline_Map.values());
                if(updatePRLinelist.size()>0) update updatePRLinelist;
                
                //***Update Plan Line
                Map<Id,ASI_MFM_Plan_Line_Item__c> UpdatePlanline_Map=new Map<Id,ASI_MFM_Plan_Line_Item__c>();
                for(ASI_MFM_PO_Line_Item__c pl:POLineList){
                    if(UpdatePlanline_Map.containsKey(pl.ASI_MFM_Plan_Line_Item__c)){
                        UpdatePlanline_Map.get(pl.ASI_MFM_Plan_Line_Item__c).ASI_MFM_Actual_Spending_Amount__c+=pl.ASI_MFM_Base_Currency_Amount__c;
                    }else{
                        UpdatePlanline_Map.put(pl.ASI_MFM_Plan_Line_Item__c, New ASI_MFM_Plan_Line_Item__c (id=pl.ASI_MFM_Plan_Line_Item__c, ASI_MFM_Actual_Spending_Amount__c=(pl.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Actual_Spending_Amount__c != Null ? pl.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Actual_Spending_Amount__c: 0 )+pl.ASI_MFM_Base_Currency_Amount__c));
                    }
                }
                
                list<ASI_MFM_Plan_Line_Item__c> updatePlanLinelist= new list<ASI_MFM_Plan_Line_Item__c>();
                updatePlanLinelist.addAll(UpdatePlanline_Map.values());
                if(updatePlanLinelist.size()>0) update updatePlanLinelist;
                
                //***Update PO line----
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
                apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set status to Closed. Please complete related PO process before PR close.<br/> '+errmsg));
                return null;
            }
            
        }// -----------------------------Closed Logic End-----------------------
        
        //Case: Closed->Draft
        if(p.ASI_MFM_Status__c=='Closed' && new_status=='Draft'){
            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Closed PR cannot set status to Draft.'));
            return null;
        }//
        
        //Submitted->Draft
        if(p.ASI_MFM_Status__c=='Submitted' && new_status=='Draft'){
            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Submitted PR cannot set Draft Status.'));
            return null;
        }
        
        if(p.ASI_MFM_Status__c=='Draft' && new_status=='Draft'){
            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'PR Status is Draft.'));
            return null;
        }
        
        //Case:  Rejected->  Draft
        if(p.ASI_MFM_Status__c=='Rejected' && new_status=='Draft' && p.ASI_MFM_Plan__r.ASI_MFM_Status__c=='Closed'){
            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Plan <a href="/'+p.ASI_MFM_Plan__c+'">'+p.ASI_MFM_Plan__r.name+ '</a> is Closed, cannot change PR Status.'));
            return null;
        }
        //  Case:	Approved-> Draft
        if(p.ASI_MFM_Status__c=='Approved' && new_status=='Draft'){
            list<ASI_MFM_PO_Line_Item__c> polinelist=[select id,name from ASI_MFM_PO_Line_Item__c where ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__c =:p.id];
            if(polinelist.size()>0 || poList.size()>0){  //  if(poList.size()>0){
                apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Have Created PO(s), cannot change PR Status.'));
                return null;
            }
        }
        
        //Update
        p.ASI_MFM_Status__c = new_status;
        if(p.ASI_MFM_Status__c=='Draft'){
            p.ASI_MFM_Submit_for_Approval__c=false;
            p.recordTypeId=Global_RecordTypeCache.getRTId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request');
        }
        
        try {
            update p;
            return new pageReference('/' + p.id);
        }
        catch (exception ex) {
            apexpages.addMessages(ex);
            return null;
        }
        
        
    }
    
}