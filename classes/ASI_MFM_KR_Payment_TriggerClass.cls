//test: ASI_MFM_KR_Trigger_TestClass
public class ASI_MFM_KR_Payment_TriggerClass{
    
    
    public static void routineAfterUpdate(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {
        Set<Id> approvedPays = new Set<Id>(); //20170223, Leo
        Set<Id> rejectedPays = new Set<Id>(); //20170223, Leo
        Set<Id> approvedPaymentSet = new Set<Id>(); // 20180123 Introv
        Id POReadOnlyId= Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_KR_PO_Read_Only');
        Set<ID> poIDs = new Set<ID>();
        set<ID> paymentIDs = new Set<ID>();
        Map<Id,String> InvoiceNumberMap= new Map<Id,String>();
        //Once the direct payment is approved, dummy PO status should be updated to “Closed” accordingly.
        for (ASI_MFM_Payment__c pay:trigger_new) { //20180123 Introv added offset and cash out payment
            if (pay.ASI_MFM_Status__c == 'Approved' && (trigger_oldMap.get(pay.id).ASI_MFM_Status__c == 'Submitted' || trigger_oldMap.get(pay.id).ASI_MFM_Status__c == 'Draft' )&& ( pay.ASI_MFM_Is_Direct_Payment__c==true || pay.ASI_MFM_Cash_Out_Payment__c || pay.ASI_MFM_Offset_Payment__c ) && pay.ASI_MFM_PO__c !=null){
                poIDs.add(pay.ASI_MFM_PO__c);
                paymentIDs.add(pay.id);
            } 
            if (pay.ASI_MFM_Invoice_Number__c!=null && pay.ASI_MFM_Invoice_Number__c != trigger_oldMap.get(pay.id).ASI_MFM_Invoice_Number__c){
                InvoiceNumberMap.put(pay.id, pay.ASI_MFM_Invoice_Number__c);
            }
            
            if (trigger_oldMap != null && ((pay.ASI_MFM_Status__c == 'Approved' && trigger_oldMap.get(pay.id).ASI_MFM_Status__c != 'Approved') || (pay.ASI_MFM_Status__c == 'Completed' && trigger_oldMap.get(pay.id).ASI_MFM_Status__c != 'Completed'))){
                approvedPays.add(pay.Id);
                if(pay.ASI_MFM_Status__c == 'Approved'){
                    approvedPaymentSet.add(pay.Id);
                    
                }
            }//end if: approved payment
            
            if (trigger_oldMap != null  && ((pay.ASI_MFM_Status__c != 'Approved' && pay.ASI_MFM_Status__c != 'Completed' && trigger_oldMap.get(pay.id).ASI_MFM_Status__c == 'Approved') || (pay.ASI_MFM_Status__c != 'Completed' && pay.ASI_MFM_Status__c != 'Approved' && trigger_oldMap.get(pay.id).ASI_MFM_Status__c == 'Completed'))){
                rejectedPays.add(pay.Id);
            }//end if: rejected payment
            
        }//For loop current payment
        
        // direct payment Logic
        List<ASI_MFM_PO__c> poList =new List<ASI_MFM_PO__c>();
        if(poIDs.size()>0){
            poList=[select id,name from ASI_MFM_PO__c where id in : poIDs];
        }
        if(poList.size()>0){
            //Update PO Header
            for(ASI_MFM_PO__c po:poList){
                po.ASI_MFM_Status__c='Closed';
                po.ASI_MFM_Closing_Comments__c = 'Closed by System';
                PO.recordTypeId=POReadOnlyId;
            }
            update poList;
            
            //Update PO line
            Map<Id,ASI_MFM_PO_Line_Item__c> UpdatePOline_Map=new Map<Id,ASI_MFM_PO_Line_Item__c>();
            set<id> PlanLineSet=new set<id>();
            for(ASI_MFM_Payment_Line_Item__c pl: [select id,name,ASI_MFM_PO_Line_Item__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Plan_Line_Item__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Status__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Actual_Spending_Amount__c,ASI_MFM_Payment_Amount__c,ASI_MFM_Paid_Amount_in_PO_Currency__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c in: paymentIDs]){
                if(pl.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Status__c=='Closed'){
                    if(!UpdatePOline_Map.containsKey(pl.ASI_MFM_PO_Line_Item__c)){// Not contain in map pl.ASI_MFM_PO_Line_Item__r.ASI_MFM_Actual_Spending_Amount__c+ 
                        UpdatePOline_Map.put(pl.ASI_MFM_PO_Line_Item__c, new ASI_MFM_PO_Line_Item__c(id=pl.ASI_MFM_PO_Line_Item__c,ASI_MFM_Actual_Spending_Amount__c=pl.ASI_MFM_Paid_Amount_in_PO_Currency__c));
                    }else{// contain in map
                        UpdatePOline_Map.get(pl.ASI_MFM_PO_Line_Item__c).ASI_MFM_Actual_Spending_Amount__c+=pl.ASI_MFM_Paid_Amount_in_PO_Currency__c;
                    }
                    PlanLineSet.add(pl.ASI_MFM_PO_Line_Item__r.ASI_MFM_Plan_Line_Item__c);
                }
            }//End if
            
            
            //Update PO line with Status='Closed'
            list<ASI_MFM_PO_Line_Item__c> updatePOLinelist= new list<ASI_MFM_PO_Line_Item__c>();
            updatePOLinelist.addAll(UpdatePOline_Map.values());
            if(updatePOLinelist.size()>0) update updatePOLinelist;
            
            UpdatePLASA(PlanLineSet);
            
            //End Plan Line update
        }
        // direct payment Logic End
        
        if(!InvoiceNumberMap.isEmpty()){
            
            List<ASI_MFM_Payment_Line_Item__c> PaymentLinelist=[select id,ASI_MFM_Invoice_Number__c,ASI_MFM_Payment__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c in : InvoiceNumberMap.keySet()];
            if(PaymentLinelist.size()>0){
                for(ASI_MFM_Payment_Line_Item__c pl:PaymentLinelist){
                    if(InvoiceNumberMap.containsKey(pl.ASI_MFM_Payment__c)){
                        pl.ASI_MFM_Invoice_Number__c=InvoiceNumberMap.get(pl.ASI_MFM_Payment__c);
                    }
                }//END For Loop
                update PaymentLinelist;
            }
        }
        //20170223, Leo
        if(approvedPays.size()>0 || rejectedPays.size()>0)
        {
            List<ASI_MFM_Payment_Line_Item__c> combinedPaymentLineList = new List<ASI_MFM_Payment_Line_Item__c>([SELECT Id
                                                                                                                 , ASI_MFM_Effective__c 
                                                                                                                 , ASI_MFM_G_L_Date__c
                                                                                                                 , ASI_MFM_Payment__c
                                                                                                                 FROM ASI_MFM_Payment_Line_Item__c 
                                                                                                                 WHERE ASI_MFM_Payment__c IN: approvedPays
                                                                                                                 OR ASI_MFM_Payment__c IN: rejectedPays
                                                                                                                ]);//20180123 Introv
            
            if(combinedPaymentLineList.size()>0)
            {
                
                //20180123 Combined reject and approved logic
                //if(approvedPays.size()>0)
                //{
                    /*List<ASI_MFM_Payment_Line_Item__c> lineList 
                            = new List<ASI_MFM_Payment_Line_Item__c>([SELECT Id,ASI_MFM_Effective__c 
                            FROM ASI_MFM_Payment_Line_Item__c 
                            WHERE ASI_MFM_Payment__c IN: approvedPays]);*/
                    //if(combinedPaymentLineList.size()>0)
                    //{
                    for(ASI_MFM_Payment_Line_Item__c pl: combinedPaymentLineList)
                    {
                        if(approvedPays.contains(pl.ASI_MFM_Payment__c))
                            pl.ASI_MFM_Effective__c = TRUE;
                        
                        //20180123 Introv
                        if(approvedPaymentSet.contains(pl.ASI_MFM_Payment__c))
                            pl.ASI_MFM_G_L_Date__c = date.today();
                        
                        if(rejectedPays.contains(pl.ASI_MFM_Payment__c))
                            pl.ASI_MFM_Effective__c = FALSE;
                        
                        
                    }//end for
                    //update lineList;
                    //}//end if: has approved payment line
                //}
                //if(rejectedPays.size()>0)
                //{
                    /*List<ASI_MFM_Payment_Line_Item__c> lineList 
                            = new List<ASI_MFM_Payment_Line_Item__c>([SELECT Id,ASI_MFM_Effective__c 
                            FROM ASI_MFM_Payment_Line_Item__c 
                            WHERE ASI_MFM_Payment__c IN: rejectedPays]);*/
                    //if(combinedPaymentLineList.size()>0)
                    //{
                    //for(ASI_MFM_Payment_Line_Item__c pl: combinedPaymentLineList)
                    //{
                        //if(rejectedPays.contains(pl.ASI_MFM_Payment__c))
                            //pl.ASI_MFM_Effective__c = FALSE;
                    //}//end for
                    //update lineList;
                    //}//end if: has rejected payment line
                //}
                
                Update combinedPaymentLineList;
            }
        }//end if: has approved/rejected payment
        //20170223, Leo
    }
    
    public static void UpdatePLASA(set<id> PLSet){
        //update Plan Line Actual Spending Amount
        list<ASI_MFM_Plan_Line_Item__c> updatePlanLinelist= [select id,name,ASI_MFM_Actual_Spending_Amount__c,(select id, name,ASI_MFM_Base_Currency_Amount__c  from PO_Line_Items__r) from ASI_MFM_Plan_Line_Item__c where  id in: PLSet];
        for(ASI_MFM_Plan_Line_Item__c pl:updatePlanLinelist){
            pl.ASI_MFM_Actual_Spending_Amount__c=0;
            for(ASI_MFM_PO_Line_Item__c pol:pl.PO_Line_Items__r){
                if(pol.ASI_MFM_Base_Currency_Amount__c!=null){
                    pl.ASI_MFM_Actual_Spending_Amount__c+=pol.ASI_MFM_Base_Currency_Amount__c;
                }
                
            }
        }
        
        if(updatePlanLinelist.size()>0) update updatePlanLinelist;
        
    }
    
    public static void routineBeforerDelete(list<ASI_MFM_Payment__c> trigger_old) {
        Set<Id> setPOId = new Set<Id>();
        List<ASI_MFM_PO__c> listPO = new List<ASI_MFM_PO__c>();
        set<id> PlanLineSet=new set<id>();
        
        for (ASI_MFM_Payment__c pa : trigger_old){
            if (pa.ASI_MFM_Status__c == 'Final' || pa.ASI_MFM_Status__c == 'Complete'){
                pa.addError('Not allowed to delete because the Payment is in \'Final\' or \'Complete\' status');
            }  
            //For KR MFM
            if (pa.RecordTypeId != null  && pa.ASI_MFM_Is_Direct_Payment__c == TRUE){
                setPOId.add(pa.ASI_MFM_PO__c);
            }  
            
            
        }
        //delete PO
        if(setPOId != NULL){
            listPO = [SELECT id,(select id,name,ASI_MFM_Plan_Line_Item__c from PO_Line_Items__r) FROM ASI_MFM_PO__c WHERE id IN:setPOId];  
            for(ASI_MFM_PO__c po:listPO){
                for(ASI_MFM_PO_Line_Item__c pol:po.PO_Line_Items__r){
                    PlanLineSet.add(pol.ASI_MFM_Plan_Line_Item__c);
                }
            }    
        }
        
        delete listPO;
        
        if(PlanLineSet.size()>0){ //update Plan Line Actual Spending Amount 
            UpdatePLASA(PlanLineSet);
        }
        
    }
    
    
    
    
    
    public static void routineBeforeUpdate(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {
        Set<Id> paymentId = new Set<Id>();
        Set<Id> hasPrepaymentChangeLogApproved = new Set<Id>();//20180111 Introv
        Map<Id, Id> mapPrepaymentLog = new Map<Id, Id>();//20180111 Introv
        
        Id PaymentROId= Global_RecordTypeCache.getRTId('ASI_MFM_Payment__cASI_MFM_KR_Payment_Read_Only');
        
        boolean IsDraft=false;
        
        Map<ID, ASI_MFM_Tax_Code__c> ChangedTXMap = new Map<ID, ASI_MFM_Tax_Code__c>(); 
        
        
        for(ASI_MFM_Payment__c payment: trigger_new){
            
            if(payment.ASI_MFM_Total_ApprovedProposalChangeLog__c != trigger_oldMap.get(payment.id).ASI_MFM_Total_ApprovedProposalChangeLog__c){
                hasPrepaymentChangeLogApproved.add(payment.id);
            }
            
            if (payment.ASI_MFM_Status__c == 'Approved' && (trigger_oldMap.get(payment.id).ASI_MFM_Status__c == 'Submitted' || trigger_oldMap.get(payment.id).ASI_MFM_Status__c == 'Draft' )){
                payment.RecordTypeId=PaymentROId;
                //20180125 Introv
                if(payment.ASI_MFM_Offset_Payment__c){
                    payment.ASI_MFM_G_L_Date__c = date.today();
                }
            }
            
            //Set G/L date
            if(payment.ASI_MFM_G_L_Date__c==null && !payment.ASI_MFM_Offset_Payment__c ){//20180125 Introv added ! ASI_MFM_Offset_Payment__c 
                payment.ASI_MFM_G_L_Date__c=system.today();
            }
            if(payment.ASI_MFM_Invoice_Date__c==null){
                payment.ASI_MFM_Invoice_Date__c =system.today();
            }
            //Set G/L date --End
            
            paymentId.add(payment.Id);
            if(payment.ASI_MFM_Status__c=='Draft' || payment.ASI_MFM_Status__c=='Submitted'){
                IsDraft=true;
            }
        }//end for
        
        //20180111 Introv
        for(ASI_MFM_Prepayment_Proposal_Change_Log__c obj : [SELECT id, ASI_MFM_Payment__c
                                                             FROM ASI_MFM_Prepayment_Proposal_Change_Log__c 
                                                             WHERE ASI_MFM_Payment__c IN : hasPrepaymentChangeLogApproved
                                                             AND ASI_MFM_Status__c Like 'Approved'
                                                             ORDER By ASI_MFM_Last_Approved_Time__c DESC
                                                            ]){
                                                                if(!mapPrepaymentLog.containsKey(obj.ASI_MFM_Payment__c))
                                                                    mapPrepaymentLog.put(obj.ASI_MFM_Payment__c, obj.id);
                                                            }
        
        for(ASI_MFM_Payment__c payment: trigger_new){
            
            if(mapPrepaymentLog.containsKey(payment.id))
                payment.ASI_MFM_Contract_Changes_Application__c = mapPrepaymentLog.get(payment.id);
        }//20180111 Introv End
        
        if(IsDraft){
            Map<ID, User> mapUser = new Map<ID,User>([SELECT ID, Name, ManagerID, UserRole.DeveloperName,ASI_MFM_Team__c, ASI_MFM_Brand_Manager__c FROM User WHERE ASI_MFM_Country__c = 'KR']);
            
            //Fix Approval Route
            Map<String,ASI_MFM_Fix_Approval_Route__c> FARMap  =new Map<String,ASI_MFM_Fix_Approval_Route__c>();
            List<ASI_MFM_Fix_Approval_Route__c> FARList = new List<ASI_MFM_Fix_Approval_Route__c>([SELECT Id,ASI_MFM_Module__c, ASI_MFM_KR_Sub_Category__c,ASI_MFM_Team__c,ASI_MFM_Need_Brand_Marketing__c,  ASI_MFM_KR_Grand_Category__c,ASI_MFM_BA__c, ASI_MFM_Approval_Limit_BA__c, ASI_MFM_Approval_Limit_CA1__c,ASI_MFM_Approval_Limit_CA2__c,ASI_MFM_Approval_Limit_CA3__c, ASI_MFM_Approval_Limit_CA4__c,ASI_MFM_Approval_Limit_CA5__c,ASI_MFM_Approval_Limit_CA6__c,ASI_MFM_Approval_Limit_CA7__c,ASI_MFM_Approval_Limit_CA8__c,ASI_MFM_Approval_Limit_CA9__c,ASI_MFM_Approval_Limit_CA10__c,ASI_MFM_Approval_Limit_CA11__c,ASI_MFM_Approval_Limit_CA12__c, ASI_MFM_Corporate_Approver_1__c, ASI_MFM_Corporate_Approver_2__c,ASI_MFM_Corporate_Approver_3__c,ASI_MFM_Corporate_Approver_4__c,ASI_MFM_Corporate_Approver_5__c,ASI_MFM_Corporate_Approver_6__c,ASI_MFM_Corporate_Approver_7__c,ASI_MFM_Corporate_Approver_8__c,ASI_MFM_Corporate_Approver_9__c,ASI_MFM_Corporate_Approver_10__c,ASI_MFM_Corporate_Approver_11__c,ASI_MFM_Corporate_Approver_12__c  FROM ASI_MFM_Fix_Approval_Route__c WHERE RecordType.DeveloperName LIKE 'ASI_MFM_KR_Fix_Approval_Route' AND ASI_MFM_Module__c LIKE 'Payment' AND ASI_MFM_Inactive__c = false ]);
            for(ASI_MFM_Fix_Approval_Route__c FAR: FARList){
                string keyword='';
                keyword+=FAR.ASI_MFM_Team__c;

                if(FAR.ASI_MFM_KR_Grand_Category__c!=null){
                    keyword+=FAR.ASI_MFM_KR_Grand_Category__c;
                }
                FARMap.put(keyword, FAR);
            }//end for: loop approval route list
            
            // Modified by 2018-02-23 Linus@introv
            // Dynamic Approval Route
            Map<String,ASI_MFM_Dynamic_Approval_Route__c> DARMap  =new Map<String,ASI_MFM_Dynamic_Approval_Route__c>();
            /*List<ASI_MFM_Dynamic_Approval_Route__c> DARList   = new List<ASI_MFM_Dynamic_Approval_Route__c>([SELECT id,ASI_MFM_Type__c,  ASI_MFM_User__c, ASI_MFM_Approval_Limit__c,ASI_MFM_End_of_1st_Route__c FROM ASI_MFM_Dynamic_Approval_Route__c WHERE RecordType.DeveloperName LIKE 'ASI_MFM_KR_Dynamic_Approval_Route'  AND ASI_MFM_Type__c LIKE 'Payment' and ASI_MFM_Inactive__c=false ]);
            for(ASI_MFM_Dynamic_Approval_Route__c DAR: DARList){
                DARMap.put(DAR.ASI_MFM_User__c, DAR);
            }*/
            
            //Payment Line 
            List<ASI_MFM_Payment_Line_Item__c> paymentLine  = new List<ASI_MFM_Payment_Line_Item__c>([SELECT Id,  ASI_MFM_Payment__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Purchase_Request__r.ASI_MFM_Service_Item_POSM__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand_Marketing_Leader__c, ASI_MFM_PO__r.ASI_MFM_Purchase_Request__r.ASI_MFM_Service_Item_POSM__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand_Manager__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name FROM ASI_MFM_Payment_Line_Item__c  WHERE RecordType.DeveloperName LIKE: 'ASI_MFM_KR_Payment_Line_Item' AND ASI_MFM_Payment__c IN: paymentId]);
            Map<String,ASI_MFM_Payment_Line_Item__c> paymentLineMap  =new Map<String,ASI_MFM_Payment_Line_Item__c>();
            for(ASI_MFM_Payment_Line_Item__c line: paymentLine){
                if(!paymentLineMap.containsKey(line.ASI_MFM_Payment__c)){
                    paymentLineMap.put(line.ASI_MFM_Payment__c,line);//Map<payment id, payment line>
                }
            }//End of payment line for loop
            
            for(ASI_MFM_Payment__c payment: trigger_new){
                if(payment.ASI_MFM_Status__c=='Draft'|| payment.ASI_MFM_Status__c=='Submitted'){
                    setApprover(payment,paymentLineMap,mapUser,FARMap,DARMap);
                }
               
            }//end for
            
        }
        
    }
    
    private static void setApprover(ASI_MFM_Payment__c payment,map<String,ASI_MFM_Payment_Line_Item__c> paymentLineMap,Map<ID, User> mapUser,Map<String, ASI_MFM_Fix_Approval_Route__c> FARMap, Map<String, ASI_MFM_Dynamic_Approval_Route__c> DARMap){
        ASI_MFM_Fix_Approval_Route__c CurrentFAR= new ASI_MFM_Fix_Approval_Route__c();
        if( paymentLineMap.size()>0 && mapUser.containsKey(payment.OwnerId) && payment.ASI_MFM_Payment_Amount__c!=null){
            //construct key word
            string keyword='';
            if(mapUser.get(payment.OwnerId).ASI_MFM_Team__c!=null){
                keyword+=mapUser.get(payment.OwnerId).ASI_MFM_Team__c;
            }
            
            //handle brand team and trade marketing team
            if( !payment.ASI_MFM_Is_Direct_Payment__c/* && paymentLineMap.get(payment.id).ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Purchase_Request__r.ASI_MFM_Service_Item_POSM__c!=null*/){ //20180111 Introv Comemnted
                //20160504, Leo@Elufa
                if(payment.ASI_MFM_Pre_payment__c || payment.ASI_MFM_Pre_payment__c)//for pre-payment
                {//pre-payment service
                    
                    //20180111 Introv
                    keyword+='Pre-payment';
                    
                    //20180111 Introv Commented
                    if(paymentLineMap.get(payment.id).ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Purchase_Request__r.ASI_MFM_Service_Item_POSM__c=='Service'){
                        keyword+='Pre-payment Service';
                    }else{//pre-payment non service
                        keyword+='Pre-payment Non Service';
                    }
                    
                }else if(payment.ASI_MFM_Offset_Payment__c){//20180111 Introv if is offset Payment
                    
                    keyword+='Offset Payment';
                }else //not pre-payment
                {//service
                    if(paymentLineMap.get(payment.id).ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Purchase_Request__r.ASI_MFM_Service_Item_POSM__c != null && paymentLineMap.get(payment.id).ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Purchase_Request__r.ASI_MFM_Service_Item_POSM__c=='Service'){
                        keyword+=paymentLineMap.get(payment.id).ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Purchase_Request__r.ASI_MFM_Service_Item_POSM__c;
                    }else{//non service
                        keyword+='Non Service';
                    }
                }//20160504, Leo@Elufa
            }else if(payment.ASI_MFM_Is_Direct_Payment__c){
                keyword+='Direct Payment';
            }
            
            
            if(FARMap.containsKey(keyword)){
                CurrentFAR=FARMap.get(keyword);
                
            }
            //handle sales rep
            else if(!FARMap.containsKey(keyword) && FARMap.containsKey(mapUser.get(payment.OwnerId).ASI_MFM_Team__c)){
                if(!payment.ASI_MFM_Pre_payment__c)
                    CurrentFAR=FARMap.get(mapUser.get(payment.OwnerId).ASI_MFM_Team__c);
                else
                    CurrentFAR=FARMap.get(mapUser.get(payment.OwnerId).ASI_MFM_Team__c+'Pre-payment');
            }
            
            //Get Fix Route type
            if(CurrentFAR.Id !=null && payment.OwnerId !=null){
                boolean EndFindManager=false;
                integer CurrApproverNum=1;
                //ID approverID = mapUser.get(payment.OwnerId).ManagerID;
                Boolean HasBrdManager = mapUser.get(payment.OwnerId).ASI_MFM_Brand_Manager__c != null && mapUser.get(payment.OwnerId).ASI_MFM_Team__c == 'Brand Marketing' ? true: false;
                Boolean LineManager = mapUser.get(payment.OwnerId).ManagerId != null ? true: false;
                setApproverToNull(payment);
                //Find normal approver
                for(integer i = 1 ; i <= 12 ; i++){ //20160822,edited by Leo, 9->12
                    string sysApprover = 'ASI_MFM_Sys_Approver_' + string.valueOf(CurrApproverNum)  + '__c';
                    string fixApprover = 'ASI_MFM_Corporate_Approver_'+ i +'__c';
                    string approvalLimit = 'ASI_MFM_Approval_Limit_CA' + i + '__c';
                    if(HasBrdManager){
                        payment.put(sysApprover, mapUser.get(payment.OwnerId).ASI_MFM_Brand_Manager__c);  system.debug('Linus: has Brand Manager');
                        HasBrdManager = false;    
                        CurrApproverNum++;                    
                    }else if(LineManager){
                        payment.put(sysApprover, mapUser.get(payment.OwnerId).ManagerId);
                        LineManager = false;
                        CurrApproverNum++;
                    }else{
                        decimal local_amount=0;
                        if(payment.ASI_MFM_Exchange_Rate__c!=null){
                            local_amount= payment.ASI_MFM_Payment_Amount__c* payment.ASI_MFM_Exchange_Rate__c;
                        }else{
                            local_amount= payment.ASI_MFM_Payment_Amount__c;
                        }
                        
                        
                        //compare amount    *****Modified by 2018-02-23 Linus@introv
                        if(CurrentFAR.get(fixApprover) != null && CurrentFAR.get(approvalLimit)!=NULL && local_amount > Double.valueOf(CurrentFAR.get(approvalLimit))){
                            payment.put(sysApprover,CurrentFAR.get(fixApprover));
                            CurrApproverNum++;
                        }
                        EndFindManager=true;
                    }/*else{
                        if(CurrentFAR.ASI_MFM_Need_Brand_Marketing__c!=null && CurrentFAR.ASI_MFM_Need_Brand_Marketing__c==string.valueOf(i) && paymentLineMap.containsKey(payment.id)  ){
                            if(paymentLineMap.get(payment.id).ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand_Marketing_Leader__c !=null){
                                CurrApproverNum=FindDynamicApprover(payment,paymentLineMap.get(payment.id).ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand_Marketing_Leader__c,mapUser,DARMap,CurrApproverNum);
                            }
                        }else if( approverID!=null && EndFindManager==false ){
                            //20160504, Leo@Elufa
                            //for brand marketing team, submiter not brand manager
                            if(mapUser.get(payment.OwnerId).ASI_MFM_Team__c != null
                               && mapUser.get(payment.OwnerId).ASI_MFM_Team__c == 'Brand Marketing'
                               && paymentLineMap.containsKey(payment.id)
                               && paymentLineMap.get(payment.id).ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand_Manager__c != null
                               && paymentLineMap.get(payment.id).ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand_Manager__c != payment.OwnerId)
                            {
                                system.debug('Enter Brand Marketing');
                                CurrApproverNum=FindDynamicApprover(payment,paymentLineMap.get(payment.id).ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand_Manager__c,mapUser,DARMap,CurrApproverNum);
                            }//end if
                            //for trade marketing team / brand marketing submit with brand manager
                            else
                            {
                                system.debug('No Enter Brand Marketing');
                                if(!DARMap.containsKey(payment.OwnerId) || (DARMap.containsKey(payment.OwnerId)&& !DARMap.get(payment.OwnerId).ASI_MFM_End_of_1st_Route__c)){
                                    CurrApproverNum=FindDynamicApprover(payment,approverID,mapUser,DARMap,CurrApproverNum);
                                }
                                
                            }//end else
                        }//20160504, Leo@Elufa
                        
                    }*/
                }//end of for loop
            }
            
        }
        
        
    }
    
    /* Modified by 2018-02-28 Linus@introv
    private static integer FindDynamicApprover(ASI_MFM_Payment__c payment,Id CurrentManagerId, Map<ID, User> mapUser, Map<String, ASI_MFM_Dynamic_Approval_Route__c> DARMap, integer CurrApproverNum){
        boolean proceed = true;
        id currentUserid = CurrentManagerId;
        
        while(proceed){//system.debug(DARMap.containsKey(currentUserid)+'Test User By Tony'+currentUserid);
            if(DARMap.containsKey(currentUserid)){
                decimal local_amount=0;
                if(payment.ASI_MFM_Exchange_Rate__c!=null){
                    local_amount= payment.ASI_MFM_Payment_Amount__c* payment.ASI_MFM_Exchange_Rate__c;
                }else{
                    local_amount= payment.ASI_MFM_Payment_Amount__c;
                }
                
                if(local_amount >DARMap.get(currentUserid).ASI_MFM_Approval_Limit__c){
                    payment.put('ASI_MFM_Sys_Approver_' + string.valueOf(CurrApproverNum) + '__c',currentUserid);
                    CurrApproverNum++;
                    if(DARMap.get(currentUserid).ASI_MFM_End_of_1st_Route__c ){
                        proceed = false;
                    }
                    
                }else if(DARMap.get(currentUserid).ASI_MFM_End_of_1st_Route__c || !mapUser.containsKey(currentUserid) || (mapUser.containsKey(currentUserid) && mapUser.get(currentUserid).ManagerID==null) ){//contain user but manager is null
                    proceed = false;
                }
                
                if(mapUser.containsKey(currentUserid) && mapUser.get(currentUserid).ManagerID!=null){
                    currentUserid=mapUser.get(currentUserid).ManagerID;
                }
                
                
            }else{
                
                payment.put('ASI_MFM_Sys_Approver_' + string.valueOf(CurrApproverNum) + '__c',currentUserid);
                CurrApproverNum++;
                if(mapUser.containsKey(currentUserid)){
                    currentUserid=mapUser.get(currentUserid).ManagerID;
                }
                system.debug(mapUser.containsKey(currentUserid)+'change user'+currentUserid);
                if(!mapUser.containsKey(currentUserid) || (mapUser.containsKey(currentUserid) && mapUser.get(currentUserid).ManagerID==null)){
                    proceed = false;
                }
            }
            //
        }// end of while
        
        return CurrApproverNum;
        
    }
    */
    
    
    
    
    public static void setApproverToNull(ASI_MFM_Payment__c payment)
    {
        String sysApprover;
        
        for(integer i = 1 ; i <=16 ; i++) //20160822,edited by Leo, 11->16
        {
            sysApprover = 'ASI_MFM_Sys_Approver_' + i + '__c';
            payment.put(sysApprover,null);
        }//end for
    }//end method: setApproverToNull
    
    
    public static void routineBeforeInsert(list<ASI_MFM_Payment__c> trigger_new) {
        set<id> px_set = new set<id>();
        for (ASI_MFM_Payment__c p:trigger_new) {
            if (p.asi_mfm_prefix__c != null) {
                px_set.add(p.asi_mfm_prefix__c);
                
                if(p.ASI_MFM_G_L_Date__c==null){
                    p.ASI_MFM_G_L_Date__c=system.today();
                }
                if(p.ASI_MFM_Invoice_Date__c==null){
                    p.ASI_MFM_Invoice_Date__c =system.today();
                }
            }
        }
        
        // Set the Payment ID for new Payment               
        map<id, asi_mfm_prefix__c> px_map = new map<id, asi_mfm_prefix__c>([select name, asi_mfm_next_number__c,ASI_MFM_Company__c from asi_mfm_prefix__c  where asi_mfm_module__c = 'Payment' and id in :px_set for update]);
        for (ASI_MFM_Payment__c p:trigger_new) {
            if (px_map.containsKey(p.asi_mfm_prefix__c)) {                   
                if(px_map.get(p.asi_mfm_prefix__c).ASI_MFM_Company__c!=null){
                    if(Date.today().month()>9){
                        p.name = px_map.get(p.asi_mfm_prefix__c).ASI_MFM_Company__c +string.valueof(Date.today().year()).substring(2,4)+string.valueof(Date.today().month())+ string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 1000).substring(1, 4);
                    }else{
                        p.name = px_map.get(p.asi_mfm_prefix__c).ASI_MFM_Company__c +string.valueof(Date.today().year()).substring(2,4)+'0'+string.valueof(Date.today().month())+ string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 1000).substring(1, 4);
                    }
                }else{
                    p.name = px_map.get(p.asi_mfm_prefix__c).name +string.valueof(Date.today().year()).substring(2,4)+string.valueof(Date.today().month())+ string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 1000).substring(1, 4);
                }
                px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c++;
                p.ASI_MFM_Company__c=px_map.get(p.asi_mfm_prefix__c).name;
                //Company Code
                if(p.ASI_MFM_Company__c=='PRK'){
                    p.ASI_MFM_Company_Code__c='222';
                }
                if(p.ASI_MFM_Company__c=='PRKI'){
                    p.ASI_MFM_Company_Code__c='286';
                }
                if(p.ASI_MFM_Invoice_Number__c==null) p.ASI_MFM_Invoice_Number__c=p.name;
                
                
                
            }
        }
        ASI_MFM_Function.updatePrefix(px_map.values());           
    }
    
    
    public static void routineBeforeUpsert(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {
        
        // Retrieve exchange rate for new payment or when the currency or payment date is changed
        set<id> pay_set = new set<id>();
        set<string> ccy_set = new set<string>(); 
        date last_effective_date=system.today();
        set<id> SupplierIdsSet = new set<id>();
        
        set<id> TaxIdsSet = new set<id>();     
        set<id> po_set = new set<id>();
        
        Map<Id, Decimal> mapTotalReceiptAmount = new Map<Id, Decimal>();
        for(ASI_MFM_Payment_Line_Item__c obj : [SELECT id
                                                , ASI_MFM_Payment__c
                                                , ASI_MFM_PO_Line_Item__c 
                                                , ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_Receipt_Amount__c
                                                FROM ASI_MFM_Payment_Line_Item__c
                                                WHERE ASI_MFM_Payment__c IN : trigger_new
                                               ]){
                                                   
                                                   Decimal totalReceiptAmt = 0;
                                                   
                                                   if(mapTotalReceiptAmount.containsKey(obj.ASI_MFM_Payment__c)){
                                                       
                                                       totalReceiptAmt = mapTotalReceiptAmount.get(obj.ASI_MFM_Payment__c);
                                                   }
                                                   
                                                   totalReceiptAmt += obj.ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_Receipt_Amount__c;
                                                   
                                                   mapTotalReceiptAmount.put(obj.ASI_MFM_Payment__c, totalReceiptAmt);
                                               }
        
        for (ASI_MFM_Payment__c pay:trigger_new) {
            if(pay.ASI_MFM_Venue_Loan_Payment__c){
                pay.ASI_MFM_Pre_payment__c =true;
            }else{
                pay.ASI_MFM_Pre_payment__c =false;
            }
            if(mapTotalReceiptAmount.containsKey(pay.id))
                pay.ASI_MFM_KR_PO_Receipt_Amount__c = mapTotalReceiptAmount.get(pay.id);
                
            
            if(pay.ASI_MFM_Tax_Code__c==null ){//  insert or delete tax code
                SupplierIdsSet.add(pay.ASI_MFM_Supplier_Name__c);
            }else if(pay.ASI_MFM_Tax_Code__c!=null && trigger_oldMap == null ){// insert but have enter tax code 
                 TaxIdsSet.add(pay.ASI_MFM_Tax_Code__c);
            }else if(pay.ASI_MFM_Tax_Code__c!=null && trigger_oldMap != null){
                if( pay.ASI_MFM_Tax_Code__c != trigger_oldMap.get(pay.id).ASI_MFM_Tax_Code__c){
                    TaxIdsSet.add(pay.ASI_MFM_Tax_Code__c);
                }
               
            }
            
            if (pay.ASI_MFM_Exchange_Rate__c == null || (trigger_oldMap != null &&  (pay.ASI_MFM_Currency__c != trigger_oldMap.get(pay.id).ASI_MFM_Currency__c || pay.ASI_MFM_Payment_Date__c != trigger_oldMap.get(pay.id).ASI_MFM_Payment_Date__c))) {
                pay_set.add(pay.id);
                ccy_set.add(pay.ASI_MFM_Currency__c);
            }
            
            //introv 20180117
            /*if(pay.ASI_MFM_PO__c!=null){
                if(!po_set.contains(pay.ASI_MFM_PO__c)){
                    po_set.add(pay.ASI_MFM_PO__c);
                }
            }*/
            
        }//end of for loop 
        
        if(SupplierIdsSet.size()>0){ // Tax Code (ASI_MFM_Tax_Code__c) = Null
            //Supplier Id/ Supplier 
            Map<Id,Account> SuuplierMap= new Map<Id,Account>();
            // Tax Code Name
            set<String> TXNameSet=new set<String>(); 
            // Tax Explanation Code
            set<String> TXExpSet=new set<String>();
            //key: Tax Code Name+ Tax Explanation Code
            Map<String,ASI_MFM_Tax_Code__c> TaxCodeMap= new Map<String,ASI_MFM_Tax_Code__c>();
            
            List<Account> AccList= [select Id,ASI_MFM_Site_Code__c,ASI_HK_CRM_Payment_Term_Code__c from Account where id in :SupplierIdsSet and ASI_MFM_Site_Code__c!=null];
            for(Account acc: AccList){
                SuuplierMap.put(acc.Id, acc);
                TXNameSet.add(acc.ASI_MFM_Site_Code__c);
                TXExpSet.add(acc.ASI_HK_CRM_Payment_Term_Code__c);
            }//End for loop
            
            List<ASI_MFM_Tax_Code__c> TaxList=[select id,name,ASI_MFM_Tax_Expl_Code__c from ASI_MFM_Tax_Code__c where name in : TXNameSet AND ASI_MFM_Tax_Expl_Code__c in :TXExpSet];
            
            for(ASI_MFM_Tax_Code__c tx:TaxList){
                String keyname='';
                if(tx.name!=null && tx.ASI_MFM_Tax_Expl_Code__c!=null){
                    keyname=tx.name+tx.ASI_MFM_Tax_Expl_Code__c;
                    TaxCodeMap.put(keyname,tx);
                }
            }// end of tax code for loop
            
            for (ASI_MFM_Payment__c pay:trigger_new) {
                if(pay.ASI_MFM_Supplier_Name__c!=null && SuuplierMap.containsKey(pay.ASI_MFM_Supplier_Name__c)){
                    if(SuuplierMap.get(pay.ASI_MFM_Supplier_Name__c).ASI_MFM_Site_Code__c!=null && SuuplierMap.get(pay.ASI_MFM_Supplier_Name__c).ASI_HK_CRM_Payment_Term_Code__c!=null ){
                        string tempkey= SuuplierMap.get(pay.ASI_MFM_Supplier_Name__c).ASI_MFM_Site_Code__c+SuuplierMap.get(pay.ASI_MFM_Supplier_Name__c).ASI_HK_CRM_Payment_Term_Code__c;
                        if(TaxCodeMap.containsKey(tempkey)){
                            pay.ASI_MFM_Tax_Code__c=TaxCodeMap.get(tempkey).Id;
                            pay.ASI_MFM_Tax_Explanation_Code__c=TaxCodeMap.get(tempkey).ASI_MFM_Tax_Expl_Code__c;
                        }
                    }
                }
            }
        }
        
        if(TaxIdsSet.size()>0){// assign ASI_MFM_Tax_Expl_Code__c
            
            Map<ID, ASI_MFM_Tax_Code__c>  ChangedTXMap = new Map<ID,ASI_MFM_Tax_Code__c>([select id,name,ASI_MFM_Tax_Expl_Code__c from ASI_MFM_Tax_Code__c where Id in : TaxIdsSet]);
            
            for(ASI_MFM_Payment__c payment: trigger_new){
                if(ChangedTXMap.containsKey(payment.ASI_MFM_Tax_Code__c)){
                    payment.ASI_MFM_Tax_Explanation_Code__c=ChangedTXMap.get(payment.ASI_MFM_Tax_Code__c).ASI_MFM_Tax_Expl_Code__c;
                }
            }//end for
        }
        
        
        if (pay_set.size() > 0 && !trigger_new[0].ASI_MFM_Is_Direct_Payment__c) {
            string country = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.substring(8, 10);
            string base_ccy = trigger_new[0].ASI_MFM_Sys_Local_Currency__c;
            
            list<ASI_MFM_Exchange_Rate__c> xr_list = [select ASI_MFM_Counter_Currency__c, ASI_MFM_Effective_Date__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c
                                                      where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c = :country and ASI_MFM_Base_Currency__c = :base_ccy
                                                      and ASI_MFM_Counter_Currency__c in :ccy_set and ASI_MFM_Effective_Date__c <= :last_effective_date
                                                      order by ASI_MFM_Counter_Currency__c asc, ASI_MFM_Effective_Date__c desc];
            
            
            for (ASI_MFM_Payment__c pay:trigger_new) {
                
                if (pay_set.contains(pay.id)) {
                    if (pay.ASI_MFM_Currency__c == pay.ASI_MFM_Sys_Local_Currency__c) {
                        pay.ASI_MFM_Exchange_Rate__c = 1;
                    }
                    else {
                        pay.ASI_MFM_Exchange_Rate__c = null;    
                        if (pay.ASI_MFM_Currency__c != null && pay.ASI_MFM_Payment_Date__c != null ) {                                                                           
                            for (ASI_MFM_Exchange_Rate__c xr:xr_list) {
                                if (xr.ASI_MFM_Counter_Currency__c == pay.ASI_MFM_Currency__c && xr.ASI_MFM_Effective_Date__c <= pay.ASI_MFM_Payment_Date__c) {
                                    pay.ASI_MFM_Exchange_Rate__c = xr.ASI_MFM_Exchange_Rate__c;
                                    break;
                                }
                                else if (xr.ASI_MFM_Counter_Currency__c > pay.ASI_MFM_Currency__c) {
                                    break;
                                }
                            }
                        }
                    }               
                }
            }                       
        }
        
        //introv 20180117 copy Po Receipt Amount
        /*if(po_set.size()>0){
            Map<Id,ASI_MFM_PO__c> POMap = new Map<Id,ASI_MFM_PO__c>([select Id, ASI_MFM_Total_Receipt_Amount__c from ASI_MFM_PO__c where Id in :po_set]);
            for (ASI_MFM_Payment__c pay:trigger_new) {
                if(POMap.get(pay.ASI_MFM_PO__c)!=null){
                    pay.ASI_MFM_KR_PO_Receipt_Amount__c = ((ASI_MFM_PO__c)POMap.get(pay.ASI_MFM_PO__c)).ASI_MFM_Total_Receipt_Amount__c;
                }
            }
        }*/
        
    }
    
    
    
}//end class: ASI_MFM_KR_Payment_TriggerClass