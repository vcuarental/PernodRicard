/* Filename:    ASI_CRM_CN_PaymentRequest_TriggerCls.cls
 * Author:      Michael Yip (Introv Limited)
 * Purpose:     CRM CN Payment Request Trigger Class
 *
 *
 * History
 * -----------------------------------------------------------------------------
 * 2014-04-29   michael.yip@introv.com      Created
 * 2014-07-29   michael.yip@introv.com      Copy A/C Code & cost type to payment request line item
 * 2014-07-31   michael.yip@introv.com      Fill in reference code from custom setting for last year payment
 * 2014-07-31   michael.yip@introv.com      Copy sequence from contract cost
 * 2014-09-29   twinkle.li@introv.com       IHBR approval process
 * 2014-10-20   twinkle.li@introv.com       Put the managers even that are not included in Dynamic Route into the approval process
 * 2014-11-25   twinkle.li@introv.com       Insert an Approval comment with "CN Payment Request Comment" record type when new a Payment Record
 */

public without sharing class ASI_CRM_CN_PaymentRequest_TriggerCls {
    public static String className = 'ASI_CRM_CN_PaymentRequest_TriggerCls';
    public static Boolean refreshSkip = false;
    public static void routineAfterInsert(list<ASI_TH_CRM_PaymentRequest__c> trigger_new) {
        if(!ASI_CRM_CN_Function.IsBypassTrigger(className)) {
            //Added by Michael Yip (Introv) 29Apr2014 for creating payment request line item according to contract
            Set<id> SContractID = new Set<id>();
            Map<id,id> MContractIDPaymentRequest = new Map<id,id>();
            Set<id> SOutletID = new Set<id>();
            
            for(ASI_TH_CRM_PaymentRequest__c p : trigger_new){
                SContractID.add(p.ASI_TH_CRM_Contract__c);
                MContractIDPaymentRequest.put(p.ASI_TH_CRM_Contract__c,p.id);
                SOutletID.add(p.ASI_CRM_CN_OutletWS__c);
                System.debug(p);
                
                //Added by Twinkle 11/25/2014 to insert an approval comment
                List<ASI_CRM_Approval_Comment__c> LNewPRComment_Insert = new List<ASI_CRM_Approval_Comment__c>();
                
                if(Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_CRM_CN_Payment_Request')){
                    LNewPRComment_Insert.add(new ASI_CRM_Approval_Comment__c(ASI_CRM_Payment_Request__c = p.id, recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_Payment_Request_Comment')));
                }
                if(LNewPRComment_Insert !=null && LNewPRComment_Insert.size() > 0) 
                    insert LNewPRComment_Insert;
                //Ended by Twinkle 11/25/2014
                
            }
 
            List<ASI_CRM_Contract_Cost__c> LContractCost = [Select id, name, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Chinese_Description__c,
                                ASI_CRM_CN_Activity_Code__c, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Sequence__c
                                from ASI_CRM_Contract_Cost__c 
                                where ASI_CRM_CN_Other_Cost_Payment_Request__c = true and ASI_CRM_CN_Contract__c IN :SContractID
                                order by ASI_CRM_CN_Contract__c, ASI_CRM_CN_Sequence__c];
            
            List<ASI_TH_CRM_PaymentRequestLineItem__c> LPaymentRequestItem = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
            
            //Other Payment
            // Edited by Michael Yip (Introv) 17Jul2014 swap name and chinese description when copy to other payment
            for(ASI_CRM_Contract_Cost__c c : LContractCost){
                ASI_TH_CRM_PaymentRequestLineItem__c PaymentRequestLine = new ASI_TH_CRM_PaymentRequestLineItem__c(ASI_CRM_CN_Contract_Cost__c = c.id,
                    recordtypeid = Global_recordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other'),
                    ASI_CRM_CN_Expense_Type__c = c.ASI_CRM_CN_Chinese_Description__c,
                    ASI_TH_CRM_Payment_Request__c = MContractIDPaymentRequest.get(c.ASI_CRM_CN_Contract__c),
                    ASI_CRM_CN_Payment_Description__c = c.Name,
                    ASI_CRM_CN_Cost_Type__c = c.ASI_CRM_CN_Cost_Type__c,
                    ASI_CRM_CN_Sequence__c = c.ASI_CRM_CN_Sequence__c,
                    ASI_CRM_CN_AC_Code__c = c.ASI_CRM_CN_Activity_Code__c);
                LPaymentRequestItem.add(PaymentRequestLine);
                
            }           
            if(LPaymentRequestItem.size()>0){
                insert LPaymentRequestItem;
            }
        }
    }
    
    public static void routineBeforeUpdate(list<ASI_TH_CRM_PaymentRequest__c> trigger_new, map<id, ASI_TH_CRM_PaymentRequest__c> trigger_oldMap) {
        
        if(!ASI_CRM_CN_Function.IsBypassTrigger(className)) {
            
            //20151210 Ben @ Elufa System
            Set<ID> payID = new Set<ID>();
            Map<String, String> mapRejectedComment = new Map<String, String>();

            Set<Id> refreshSet = new Set<Id>();
            
            for(ASI_TH_CRM_PaymentRequest__c obj : trigger_new){
                if(trigger_oldMap.get(obj.id).ASI_TH_CRM_Status__c == 'Submitted' && obj.ASI_TH_CRM_Status__c == 'Draft'){
                    payID.add(obj.id);
                }

                /* 
                    2020-01-21 Bowen 
                    因为在wholesaler Promotion的page页面中，当update end date，refresh payment request line item的时候，出现了大批量payment request line item的数据进行insert，
                    根据trigger机制，会自动按200一批次进行insert，而payment request line item中有update payment request的方法，
                    导致该方法多次进入，而所有的sql都会执行一次，一旦达到8次重复触发，就会导致事务报错：SOQL limit 101。
                    故增加一个filed，如果是refresh的时候，就不执行下面的方法
                */
                if(obj.ASI_CRM_CN_IsRefresh__c && (obj.ASI_CRM_CN_Promotion_Type__c == 'Wholesaler Promotion' || obj.ASI_CRM_CN_Promotion_Type__c == 'Outlet Promotion' 
                    ||obj.ASI_CRM_CN_Promotion_Type__c == 'Consumer Promotion'))
                {
                    refreshSet.add(obj.Id);
                }
            }
            // 2020-01-21 Bowen 当获取到的set的大小与trigger.new的大小一致，即所有的payment request的数据都是refresh过来的，可以不执行下面的方法。
            if(refreshSet.size() == trigger_new.size() || ASI_CRM_CN_PaymentRequest_TriggerCls.refreshSkip) return;


            if(payID.size() > 0){
                List<ProcessInstance> processIn = new List<ProcessInstance>([SELECT Id, TargetObjectId, Status, (SELECT Comments FROM Steps WHERE StepStatus = 'Rejected') FROM ProcessInstance where TargetObjectId IN : payID AND Status = 'Rejected' ORDER BY CompletedDate DESC]);
                if(processIn.size() > 0){
                    for(ProcessInstance obj : processIn){
                        for(ProcessInstanceStep obj2 : obj.Steps){
                            if(!mapRejectedComment.containsKey(obj.TargetObjectId)){
                                if(obj2.Comments != NULL && obj2.Comments != '')
                                    mapRejectedComment.put(obj.TargetObjectId, obj2.Comments);
                            }
                        }
                    }
                    for(ASI_TH_CRM_PaymentRequest__c obj : trigger_new){
                        if(mapRejectedComment.containsKey(obj.id) && obj.ASI_CRM_CN_Approval_Status__c == 'Rejected' && trigger_oldMap.get(obj.id).ASI_CRM_CN_Approval_Status__c == 'Submitted'){
                            obj.ASI_CRM_CN_Return_Comments__c = ( (obj.ASI_CRM_Branch__c == 'returned') ? 'Returned-': 'Rejected-')  + mapRejectedComment.get(obj.id);
                            /*obj.ASI_CRM_Reject_Return_Comments__c = (obj.ASI_CRM_Reject_Return_Comments__c == NULL || obj.ASI_CRM_Reject_Return_Comments__c == '') ? ( (trigger_oldMap.get(obj.id).ASI_CRM_CN_Return_Flag__c && !obj.ASI_CRM_CN_Return_Flag__c) ? 'Return Comment : ' : 'Reject Comment : ') + mapRejectedComment.get(obj.id) : obj.ASI_CRM_Reject_Return_Comments__c + '\n' + ( (trigger_oldMap.get(obj.id).ASI_CRM_CN_Return_Flag__c && !obj.ASI_CRM_CN_Return_Flag__c) ? 'Return Comment : ' : 'Reject Comment : ' ) + mapRejectedComment.get(obj.id);*/
                            //obj.ASI_CRM_Reject_Return_Comments__c = (obj.ASI_CRM_Reject_Return_Comments__c == NULL || obj.ASI_CRM_Reject_Return_Comments__c == '') ? ( (trigger_oldMap.get(obj.id).ASI_CRM_CN_Return_Flag__c && !obj.ASI_CRM_CN_Return_Flag__c) ? 'Return Comment / ': 'Reject Comment / ') + UserInfo.getName() + ' / ' + Datetime.now().format('YYYY-MM-dd') + ':' + '\n' + mapRejectedComment.get(obj.id) :  ( (trigger_oldMap.get(obj.id).ASI_CRM_CN_Return_Flag__c && !obj.ASI_CRM_CN_Return_Flag__c) ? 'Return Comment / ': 'Reject Comment / ')  + UserInfo.getName() + ' / ' + Datetime.now().format('YYYY-MM-dd') + ':' + '\n' + mapRejectedComment.get(obj.id)+ '\n' + obj.ASI_CRM_Reject_Return_Comments__c;
                            //20160929, edited by Leo
                            obj.ASI_CRM_Reject_Return_Comments__c = (obj.ASI_CRM_Reject_Return_Comments__c == NULL || obj.ASI_CRM_Reject_Return_Comments__c == '') ? ( (obj.ASI_CRM_Branch__c == 'returned') ? 'Return Comment / ': 'Reject Comment / ') + UserInfo.getName() + ' / ' + Datetime.now().format('YYYY-MM-dd') + ':' + '\n' + mapRejectedComment.get(obj.id) :  ( (obj.ASI_CRM_Branch__c == 'returned') ? 'Return Comment / ': 'Reject Comment / ')  + UserInfo.getName() + ' / ' + Datetime.now().format('YYYY-MM-dd') + ':' + '\n' + mapRejectedComment.get(obj.id)+ '\n' + obj.ASI_CRM_Reject_Return_Comments__c;
                           /* obj.ASI_CRM_CN_Return_Comments__c = mapRejectedComment.get(obj.id);
                            obj.ASI_CRM_Reject_Return_Comments__c = (obj.ASI_CRM_Reject_Return_Comments__c == NULL || obj.ASI_CRM_Reject_Return_Comments__c == '') ? ( (trigger_oldMap.get(obj.id).ASI_CRM_CN_Return_Flag__c && !obj.ASI_CRM_CN_Return_Flag__c) ? 'Return Comment : ' : 'Reject Comment : ') + mapRejectedComment.get(obj.id) : obj.ASI_CRM_Reject_Return_Comments__c + '\n' + ( (trigger_oldMap.get(obj.id).ASI_CRM_CN_Return_Flag__c && !obj.ASI_CRM_CN_Return_Flag__c) ? 'Return Comment : ' : 'Reject Comment : ') + mapRejectedComment.get(obj.id);*/
                        }
                    }
                }
            }
            //20151210 End
            
            // Added by Michael Yip (Introv) 3May2014 Assign Approver
            // Updated by Twinkle Li (Introv) 20Oct2014 to find the manager from hierarchy if it is not included in dynamic route       
            Map<id, ASI_CRM_Dynamic_Approval_Route__c> MAppRoute = new Map<id, ASI_CRM_Dynamic_Approval_Route__c>();
            Map<string, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix = new Map<string, ASI_CRM_Fix_Approval_Route__c>();
            Map<string, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix2 = new Map<string, ASI_CRM_Fix_Approval_Route__c>();
            Map<id, ASI_CRM_Dynamic_Approval_Route__c> MAppLastPaymentRoute = new Map<id, ASI_CRM_Dynamic_Approval_Route__c>();
            Map<string, ASI_CRM_Fix_Approval_Route__c> MAppLastPaymentRouteFix = new Map<string, ASI_CRM_Fix_Approval_Route__c>();
            Map<string, ASI_CRM_Fix_Approval_Route__c> MAppLastPaymentRouteFix2 = new Map<string, ASI_CRM_Fix_Approval_Route__c>();
            Map<id, User> MUser = new Map<id, User>(); //Twinkle 20/10/2014
            
            // Added by Twinkle Li (Introv) 26Sept2014 for checking IHBR flag
            Set<id> SPaymentID = new Set<id>();
            Set<id> SIHBR = new Set<id>();
    
            List<User> LUser = [Select id, ManagerID, ASI_CRM_Sales_Team__c from User Where CompanyName = 'Pernod Ricard China' ];               
            for(User u : LUser){
                MUser.put(u.id, u);
            }        
            
            // Updated by William Yang(Introv) 30Oct2014 to limit set approver when status is draft
            Boolean needSetApprover = false;    
            for(ASI_TH_CRM_PaymentRequest__c payment: trigger_new){
                if(payment.ASI_TH_CRM_Status__c == 'Draft')
                {
                    SPaymentID.add(payment.id);
                    needSetApprover = true;
                    break;
                }
            }
            /*
                Author:Bowen
                Date:2020-02-06
                update reason：
                    由于setApprovers()代码不规范，在for循环中写sql，导致客户时常报101错误，且其查询数据为paymentrequest中的ASI_TH_CRM_Contract__c的数据
                    所以借用当前的查询list，多加一个map 
                    当该list原逻辑在needSetApprover = true下才使用，可map不能只在if内定义，因此将其剥离到外面，for循环中的if多加一个needSetApprover = true
                    的判断，即可完成原逻辑，且不影响新逻辑           
            */
            Map<Id ,ASI_TH_CRM_PaymentRequest__c> paymentMap = new Map<Id ,ASI_TH_CRM_PaymentRequest__c>();
            List<ASI_TH_CRM_PaymentRequest__c> LFlag = [Select id, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Is_IHBR_Outlet__c, ASI_CRM_CN_Return_Flag__c ,
                                                                ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c
                                                            from ASI_TH_CRM_PaymentRequest__c
                                                            where id IN: SPaymentID];
            for(ASI_TH_CRM_PaymentRequest__c c:LFlag ){                                             
                if(c.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Is_IHBR_Outlet__c == true && needSetApprover){
                    SIHBR.add(c.id);
                }
                paymentMap.put(c.Id, c);
            }

            if(needSetApprover)
            {
                // 如上注释所述
                // List<ASI_TH_CRM_PaymentRequest__c> LFlag = [Select id, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Is_IHBR_Outlet__c, ASI_CRM_CN_Return_Flag__c 
                //                                              from ASI_TH_CRM_PaymentRequest__c
                //                                              where id IN: SPaymentID];
    
                // for(ASI_TH_CRM_PaymentRequest__c c:LFlag ){                                             
                //     if(c.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Is_IHBR_Outlet__c == true){
                //         SIHBR.add(c.id);
                //         system.debug('IHBR');
                //     }
                // }
                // End of Twinkle Li (Introv) 26Sept2014
                
                for(ASI_CRM_Dynamic_Approval_Route__c a : [Select id, ASI_CRM_Approval_Limit__c,
                    ASI_CRM_End_of_Dynamic_Route__c, ASI_CRM_Manager_ID__c, ASI_CRM_Type__c, ASI_CRM_User__c
                    from ASI_CRM_Dynamic_Approval_Route__c 
                    where ASI_CRM_Type__c = 'Payment' or ASI_CRM_Type__c = 'Last Payment']){
                    if(a.ASI_CRM_Type__c =='Payment')
                        MAppRoute.put(a.ASI_CRM_User__c, a);
                    if(a.ASI_CRM_Type__c =='Last Payment')
                        MAppLastPaymentRoute .put(a.ASI_CRM_User__c, a);
                }
                System.debug(MAppRoute);   
                
                // Updated by Twinkle Li (Introv) 26Sept2014 for setting IHBR approval process 
                for(ASI_CRM_Fix_Approval_Route__c a : [Select ASI_CRM_CN_Region_Area_Channel__c, ASI_CRM_CN_Entry_Limit__c,
                                                       ASI_CRM_CN_Approver_1__c, ASI_CRM_CN_Approver_2__c, ASI_CRM_CN_Approver_3__c,
                                                       ASI_CRM_CN_Approver_4__c, ASI_CRM_CN_Approver_5__c, ASI_CRM_CN_Approver_6__c,ASI_CRM_CN_Type__c,
                                                       ASI_CRM_CN_Approval_Limit_1__c, ASI_CRM_CN_Approval_Limit_2__c, ASI_CRM_CN_Approval_Limit_3__c,
                                                       ASI_CRM_CN_Approval_Limit_4__c, ASI_CRM_CN_Approval_Limit_5__c, ASI_CRM_CN_Approval_Limit_6__c, ASI_CRM_CN_Regional_BA__c 
                                                       ,ASI_CRM_Sales_Team__c //201060819,added by Leo
                                                       , ASI_CRM_Commercial_Team__c //20161118 Elufa
                                                       from ASI_CRM_Fix_Approval_Route__c
                                                       where ASI_CRM_CN_Type__c = 'Payment 1st Part' or ASI_CRM_CN_Type__c = 'Last Payment 1st Part'
                                                       or ASI_CRM_CN_Type__c = 'Payment (IHBR) 1st Part' or ASI_CRM_CN_Type__c = 'Last Payment (IHBR) 1st Part']){
                                                           
                    String commercialTeam = a.ASI_CRM_Commercial_Team__c != Null && a.ASI_CRM_Commercial_Team__c != '' ? a.ASI_CRM_Commercial_Team__c : '';//20161118 Elufa
                    
                    if(a.ASI_CRM_CN_Type__c =='Payment 1st Part')
                        MAppRouteFix.put(a.ASI_CRM_Sales_Team__c + commercialTeam, a); //20160819,edited by Leo
                        //MAppRouteFix.put(a.ASI_CRM_CN_Region_Area_Channel__c, a); //20160819,edited by Leo
                    else if(a.ASI_CRM_CN_Type__c =='Last Payment 1st Part')
                        MAppLastPaymentRouteFix.put(a.ASI_CRM_Sales_Team__c + commercialTeam, a);
                        //MAppLastPaymentRouteFix.put(a.ASI_CRM_CN_Region_Area_Channel__c, a); //20160819,edited by Leo
                    else if(a.ASI_CRM_CN_Type__c == 'Payment (IHBR) 1st Part')
                        MAppRouteFix.put('Payment (IHBR) 1st Part' + a.ASI_CRM_Sales_Team__c + commercialTeam, a);//20160921 Ben @ Elufa
                        //MAppRouteFix.put('Payment (IHBR) 1st Part', a);
                    else if(a.ASI_CRM_CN_Type__c == 'Last Payment (IHBR) 1st Part')
                        MAppLastPaymentRouteFix.put('Last Payment (IHBR) 1st Part' + a.ASI_CRM_Sales_Team__c + commercialTeam, a);//20160921 Ben @ Elufa
                        //MAppLastPaymentRouteFix.put('Last Payment (IHBR) 1st Part', a);
                }
                System.debug(MAppRouteFix);
                
                for(ASI_CRM_Fix_Approval_Route__c a : [Select ASI_CRM_CN_Region_Area_Channel__c, ASI_CRM_CN_Entry_Limit__c,
                                                       ASI_CRM_CN_Approver_1__c, ASI_CRM_CN_Approver_2__c, ASI_CRM_CN_Approver_3__c,
                                                       ASI_CRM_CN_Approver_4__c, ASI_CRM_CN_Approver_5__c, ASI_CRM_CN_Approver_6__c,ASI_CRM_CN_Type__c,  
                                                       ASI_CRM_CN_Approval_Limit_1__c, ASI_CRM_CN_Approval_Limit_2__c, ASI_CRM_CN_Approval_Limit_3__c,
                                                       ASI_CRM_CN_Approval_Limit_4__c, ASI_CRM_CN_Approval_Limit_5__c, ASI_CRM_CN_Approval_Limit_6__c
                                                       ,ASI_CRM_Sales_Team__c //201060819,added by Leo
                                                       , ASI_CRM_Commercial_Team__c //20161118 Elufa
                                                       from ASI_CRM_Fix_Approval_Route__c
                                                       where ASI_CRM_CN_Type__c = 'Payment 2nd Part' or ASI_CRM_CN_Type__c = 'Last Payment 2nd Part'
                                                       or ASI_CRM_CN_Type__c = 'Payment (IHBR) 2nd Part' or ASI_CRM_CN_Type__c = 'Last Payment (IHBR) 2nd Part']){
                                                           
                        String commercialTeam = a.ASI_CRM_Commercial_Team__c != Null && a.ASI_CRM_Commercial_Team__c != '' ? a.ASI_CRM_Commercial_Team__c : '';//20161118 Elufa
                                                           
                        if(a.ASI_CRM_CN_Type__c =='Payment 2nd Part') 
                            MAppRouteFix2.put(a.ASI_CRM_Sales_Team__c + commercialTeam, a); //20160819,edited by Leo
                            //MAppRouteFix2.put(a.ASI_CRM_CN_Region_Area_Channel__c, a); //20160819,edited by Leo
                        else if(a.ASI_CRM_CN_Type__c  =='Last Payment 2nd Part') 
                            MAppLastPaymentRouteFix2.put(a.ASI_CRM_Sales_Team__c + commercialTeam, a);
                            //MAppLastPaymentRouteFix2.put(a.ASI_CRM_CN_Region_Area_Channel__c, a); //20160819,edited by Leo
                        else if(a.ASI_CRM_CN_Type__c == 'Payment (IHBR) 2nd Part')
                            MAppRouteFix2.put('Payment (IHBR) 2nd Part' + a.ASI_CRM_Sales_Team__c + commercialTeam, a);//20160921 Ben @ Elufa
                            //MAppRouteFix2.put('Payment (IHBR) 2nd Part', a);
                        else if(a.ASI_CRM_CN_Type__c == 'Last Payment (IHBR) 2nd Part')
                            MAppLastPaymentRouteFix2.put('Last Payment (IHBR) 2nd Part' + a.ASI_CRM_Sales_Team__c + commercialTeam, a);
                            //MAppLastPaymentRouteFix2.put('Last Payment (IHBR) 2nd Part', a);
                }
                System.debug(MAppRouteFix2);
            }

            /*lokman 27/6/2014 issue 200 (Check first payment flag) start*/
           String[] contract_id=new String[trigger_new.size()];
           Integer counter=0;
           /*lokman 27/6/2014 issue 200 set approvers end*/ 
            for(ASI_TH_CRM_PaymentRequest__c payment : trigger_new){
                if(payment.ASI_CRM_CN_Last_Payment__c==false && payment.ASI_TH_CRM_Status__c == 'Draft'){
                    setApproverToNull(payment);
                    setApprovers(paymentMap ,payment, MAppRoute, MAppRouteFix, MAppRouteFix2, MUser);}
                if(payment.ASI_CRM_CN_Last_Payment__c==true && payment.ASI_TH_CRM_Status__c == 'Draft'){
                    setApproverToNull(payment);
                    setApprovers(paymentMap ,payment, MAppLastPaymentRoute , MAppLastPaymentRouteFix, MAppLastPaymentRouteFix2, MUser);}
            /*lokman 27/6/2014 issue 200 start*/
            if(counter<trigger_new.size()){
            contract_id[counter++]=payment.ASI_TH_CRM_Contract__c ;}
            /*lokman 27/6/2014 issue 200 end*/ 
            }
            
            /*lokman 27/6/2014 issue 200 start*/
            
            ASI_CRM_CN_CustomSetting__c customSetting = ASI_CRM_CN_CustomSetting__c.getOrgDefaults();
            String lastYrPaymentCode = customSetting.ASI_CRM_CN_Last_Year_Payment_Code__c;
            List<ASI_TH_CRM_PaymentRequest__c > check_1st_payment_List = [Select id, Name,ASI_TH_CRM_Contract__c,ASI_TH_CRM_Status__c, ASI_CRM_CN_Return_Flag__c from ASI_TH_CRM_PaymentRequest__c where ASI_TH_CRM_Contract__c in :contract_id];
            for(ASI_TH_CRM_PaymentRequest__c newpayment : trigger_new){
                //check the payments in same contract
                Integer no_of_Final=0;
                for(ASI_TH_CRM_PaymentRequest__c paymentRequest_checker:check_1st_payment_List ){
                    if(paymentRequest_checker.ASI_TH_CRM_Contract__c==newpayment.ASI_TH_CRM_Contract__c){
                        //check any final status
                            if((paymentRequest_checker.ASI_TH_CRM_Status__c =='Final'||paymentRequest_checker.ASI_TH_CRM_Status__c =='Approved') && paymentRequest_checker.id!=newpayment.id){no_of_Final++;}
                        }
                }
                // see how many final status existed.  
                if(no_of_Final==0){
                    if(newpayment.ASI_TH_CRM_Status__c =='Final'||newpayment.ASI_TH_CRM_Status__c =='Approved'){
                        newpayment.ASI_CRM_CN_First_Payment__c=true;
                    }
                }
                
                if(newpayment.ASI_CRM_CN_Last_Year_Payment__c && !trigger_oldMap.get(newpayment.id).ASI_CRM_CN_Last_Year_Payment__c ){
                    newpayment.ASI_CRM_CN_Reference_Code__c = lastYrPaymentCode; 
                }
                else if(!newpayment.ASI_CRM_CN_Last_Year_Payment__c && trigger_oldMap.get(newpayment.id).ASI_CRM_CN_Last_Year_Payment__c ){
                    newpayment.ASI_CRM_CN_Reference_Code__c = ''; 
                }
                
            }
            /*lokman 27/6/2014 issue 200 end*/   
            
            //20200401:AM@introv - set LastUpdatedBy for Payment API (GL Date + Invoice Number)
            setFinanceLastUpdated(trigger_new, trigger_oldMap);
        }
    }
    
    //Added by Twinkle @20150216
    public static void routineAfterUpdate(list<ASI_TH_CRM_PaymentRequest__c> trigger_new, map<id, ASI_TH_CRM_PaymentRequest__c> trigger_oldMap) {
        Set<Id> idPaymentRequest = new Set<Id>();
        List<ASI_TH_CRM_Contract__c> cs = new List<ASI_TH_CRM_Contract__c>();
        if(!ASI_CRM_CN_Function.IsBypassTrigger(className)) {
            for(ASI_TH_CRM_PaymentRequest__c paymentrequest : trigger_new){
                if(paymentrequest.ASI_CRM_CN_Payment_Type__c != trigger_oldMap.get(paymentrequest.id).ASI_CRM_CN_Payment_Type__c){
                    idPaymentRequest.add(paymentrequest.id);
                }
                if((paymentrequest.ASI_TH_CRM_Status__c != trigger_oldMap.get(paymentrequest.id).ASI_TH_CRM_Status__c && trigger_oldMap.get(paymentrequest.id).ASI_TH_CRM_Status__c =='draft' && paymentrequest.ASI_CRM_CN_Last_Payment__c==true)||(paymentrequest.ASI_CRM_CN_Last_Payment__c != trigger_oldMap.get(paymentrequest.id).ASI_CRM_CN_Last_Payment__c && paymentrequest.ASI_CRM_CN_Last_Payment__c ==true && paymentrequest.ASI_TH_CRM_Status__c !='draft')){
                   ASI_TH_CRM_Contract__c c = new ASI_TH_CRM_Contract__c();
                    c.id = paymentrequest.ASI_TH_CRM_Contract__c;
                        c.ASI_CRM_Last_Payment_Submitted__c = true;
                    cs.add(c);
                }
                if((paymentrequest.ASI_TH_CRM_Status__c != trigger_oldMap.get(paymentrequest.id).ASI_TH_CRM_Status__c && paymentrequest.ASI_TH_CRM_Status__c =='draft' && paymentrequest.ASI_CRM_CN_Last_Payment__c==true)||(paymentrequest.ASI_CRM_CN_Last_Payment__c != trigger_oldMap.get(paymentrequest.id).ASI_CRM_CN_Last_Payment__c && paymentrequest.ASI_CRM_CN_Last_Payment__c == false )){
                   ASI_TH_CRM_Contract__c c = new ASI_TH_CRM_Contract__c();
                    c.id = paymentrequest.ASI_TH_CRM_Contract__c;
                        c.ASI_CRM_Last_Payment_Submitted__c = false;
                    cs.add(c);
                }
            }

            if(idPaymentRequest.size() > 0)
            {
                List<ASI_CRM_CN_PH_Payee_Line_Item__c> listPHLineItem = [SELECT ID FROM ASI_CRM_CN_PH_Payee_Line_Item__c WHERE ASI_CRM_CN_Payment_Request__c IN:idPaymentRequest];
                delete listPHLineItem;
            }
            
            //update cs;
        }
    }

    public static void routineBeforeDelete(list<ASI_TH_CRM_PaymentRequest__c> trigger_old){
        
        if(!ASI_CRM_CN_Function.IsBypassTrigger(className)) {
            for(ASI_TH_CRM_PaymentRequest__c objPR : trigger_old) {
                if(objPR.ASI_TH_CRM_Status__c != 'Draft'){
                    objPR.addError('Only Draft Payment Request can be deleted.');
                }
            }
        }        
    }
    
    public static void routineBeforeInsert(list<ASI_TH_CRM_PaymentRequest__c> trigger_new, map<id, ASI_TH_CRM_PaymentRequest__c> trigger_oldMap) {
        generateInterfacePaymentName(trigger_new);
        if(!ASI_CRM_CN_Function.IsBypassTrigger(className)) {
            /*lokman 2/7/2014 SIT issue 201 start*/
            system.debug('trigger_new'+trigger_new);
            String [] trigger_new_id=new String[trigger_new.size()];
            Integer i=0;
            ASI_CRM_CN_CustomSetting__c customSetting = ASI_CRM_CN_CustomSetting__c.getOrgDefaults();
            String lastYrPaymentCode = customSetting.ASI_CRM_CN_Last_Year_Payment_Code__c;
            for(ASI_TH_CRM_PaymentRequest__c paymentrequest : trigger_new){
                trigger_new_id[i++]=paymentrequest.ASI_TH_CRM_Contract__c;
                system.debug(i);
                if(paymentrequest.ASI_CRM_CN_Last_Year_Payment__c){
                    paymentrequest.ASI_CRM_CN_Reference_Code__c = lastYrPaymentCode; 
                }
            }
            system.debug('trigger_new_id'+trigger_new_id);
            
            //  payment with same contract
            List<ASI_TH_CRM_PaymentRequest__c> Payment_list=[Select id,Name,ASI_TH_CRM_Contract__c,ASI_CRM_CN_Last_Payment__c, ASI_TH_CRM_Status__c, ASI_CRM_CN_Return_Flag__c From ASI_TH_CRM_PaymentRequest__c where ASI_TH_CRM_Contract__c IN :trigger_new_id And ASI_TH_CRM_Status__c !='Draft'];
            Map<id,String> Payment_Map=new Map<id,String>();
    
                for(ASI_TH_CRM_PaymentRequest__c paymentrequest : Payment_list){
                    
                    if(paymentrequest.ASI_CRM_CN_Last_Payment__c==true){
                        /*add last payment to map*/
                        Payment_Map.put(paymentrequest.ASI_TH_CRM_Contract__c,paymentrequest.Name);
                    }
                   
                }
                system.debug('Payment_Map'+Payment_Map);
                String error_Msg = Label.ASI_CRM_CN_ErrorMsg_MakePayment;  
                            
                Map <String, String> labelAPIName = new Map <String, String> ();
                
                Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.ASI_TH_CRM_PaymentRequest__c.fields.getMap();
                for (Schema.SObjectField field : fieldsMap.values())
                {
                    labelAPIName.put( field.getDescribe().getName(),field.getDescribe().getLabel());
                }
                
                String payment_no = labelAPIName.get('Name');
            User prof = [select id, Name, Profile.name, Profile.id, UserRole.developername from User where Id = :UserInfo.getUserId() ];
            boolean isuserAdmin = prof.profile.name.contains('System Administrator');    
            for(ASI_TH_CRM_PaymentRequest__c paymentrequest : trigger_new){
            system.debug('paymentrequest'+paymentrequest);   
                if(Payment_Map.containskey(paymentrequest.ASI_TH_CRM_Contract__c) && !isuserAdmin){
                    paymentrequest.addError(error_Msg+' '+payment_no+Payment_Map.get(paymentrequest.ASI_TH_CRM_Contract__c));
                }
            }
            /*lokman 2/7/2014 SIT issue 201 end*/    
            
            //20200401:AM@introv - set LastUpdatedBy for Payment API (GL Date + Invoice Number)
            setFinanceLastUpdated(trigger_new, trigger_oldMap);
        }
        
        //**20180414**
        if(!ASI_CRM_CN_Function.IsBypassTrigger('HeavyPaymentTriggerCls_routineBeforeInsert')){
            if(trigger_new[0].ASI_CRM_CN_Promotion_Type__c=='Heavy Contract On'){
                if(trigger_new[0].ASI_TH_CRM_Contract__c != null ){
                    List<ASI_TH_CRM_PaymentRequest__c> PaymentList = [select id,createddate,ASI_TH_CRM_Status__c from ASI_TH_CRM_PaymentRequest__c 
                                                                      where ASI_TH_CRM_Contract__c =:trigger_new[0].ASI_TH_CRM_Contract__c 
                                                                      and ASI_TH_CRM_Status__c ='Draft'];
                    if(PaymentList.size()>0){
                        for(ASI_TH_CRM_PaymentRequest__c paymentrequest : trigger_new){
                            paymentrequest.adderror('已经存在草稿状态的付款，不能新建新的付款。');
                        }
                    }
                    
                } 
            }
        }
    }
       
    //Update by Twinkle Li (Introv) 26Sept2014 for IHBR    
    public static void setApprovers(Map<Id ,ASI_TH_CRM_PaymentRequest__c> paymentMap , 
                        ASI_TH_CRM_PaymentRequest__c p,
                        Map<id, ASI_CRM_Dynamic_Approval_Route__c> MAppRoute, 
                        Map<string, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix, 
                        Map<string, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix2, 
                        Map<id, User> MUser){
        Integer approver_count = 0;

        // List<ASI_TH_CRM_PaymentRequest__c> LPayment = [Select id, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Is_IHBR_Outlet__c, ASI_CRM_CN_Return_Flag__c, OwnerId
        //                                              from ASI_TH_CRM_PaymentRequest__c
        //                                              where id =:p.id];
                
        List<ASI_TH_CRM_PaymentRequest__c> LPayment = new List<ASI_TH_CRM_PaymentRequest__c>();
        if(paymentMap.containsKey(p.id))
        {
            LPayment.add(paymentMap.get(p.Id));   
        }
                                          
        // First Fix Route for payment
        System.debug(p.ASI_CRM_CN_Division__c);
        System.debug(MAppRouteFix);
        
        ASI_CRM_Fix_Approval_Route__c fixApprover;
        if(MUser.containsKey(p.OwnerId) && MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c != null){

        }
        
        for(ASI_TH_CRM_PaymentRequest__c c: LPayment){
            //20160921 Ben @ Elufa
            if(MUser.containsKey(p.OwnerId) && MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c != null){
                
                /*20160922 Ben @ Elufa Commented
                 * if(c.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Is_IHBR_Outlet__c == true){
                    
                    if(p.ASI_CRM_CN_Last_Payment__c==true)
                        fixApprover = MAppRouteFix.get('Last Payment (IHBR) 1st Part' + MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c);
                    else
                        fixApprover = MAppRouteFix.get('Payment (IHBR) 1st Part' + MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c);
                }
                20160922 End
                */
                //20160921 Ben @ Elufa
                
                //else{
                    //fixApprover = MAppRouteFix.get(p.ASI_CRM_CN_Division__c); //20160819,edited by Leo
                    //if(MUser.containsKey(p.OwnerId) && MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c != null) //20160819,edited by Leo
                        fixApprover = MAppRouteFix.containsKey(MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c + p.ASI_CRM_Commercial_Team__c) ? MAppRouteFix.get(MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c + p.ASI_CRM_Commercial_Team__c) : MAppRouteFix.get(MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c); //20160819,edited by Leo
                //}
            }
        }
        System.debug('fixApprover'+fixApprover);
        
        /* 7/2/2014 lokman set last payment payment request limit start*/
        decimal paymentrequest_limit=0;
        if(p.ASI_CRM_CN_Last_Payment__c==true){
            paymentrequest_limit= 0;
            List<ASI_TH_CRM_Contract__c> LCont = [Select id, ASI_CRM_CN_Total_Contract_Amount__c 
                from ASI_TH_CRM_Contract__c where id =:p.ASI_TH_CRM_Contract__c limit 1]; 
            if(LCont != null && LCont.size()==1){
                paymentrequest_limit= LCont[0].ASI_CRM_CN_Total_Contract_Amount__c==null?0:LCont[0].ASI_CRM_CN_Total_Contract_Amount__c;
            }
        }
        else{
            paymentrequest_limit=p.ASI_CRM_CN_Total_Payment__c;
        }
        System.debug(paymentrequest_limit);
        /* 7/2/2014 lokman set last payment payment request limit end*/
        if(fixApprover != null && fixApprover.ASI_CRM_CN_Entry_Limit__c <paymentrequest_limit){
            if(fixApprover.ASI_CRM_CN_Approver_1__c != null){         
                setApproverByCount(p, approver_count, fixApprover.ASI_CRM_CN_Approver_1__c);
                approver_count++;
           }
            if(fixApprover.ASI_CRM_CN_Approval_Limit_1__c < p.ASI_CRM_CN_Total_Payment__c){
                if(fixApprover.ASI_CRM_CN_Approver_2__c!=null){
                setApproverByCount(p, approver_count, fixApprover.ASI_CRM_CN_Approver_2__c);
                approver_count++;}
            }
            if(fixApprover.ASI_CRM_CN_Approval_Limit_2__c < p.ASI_CRM_CN_Total_Payment__c){
                if(fixApprover.ASI_CRM_CN_Approver_3__c!=null){
                setApproverByCount(p, approver_count, fixApprover.ASI_CRM_CN_Approver_3__c);
                approver_count++;
                }
            }
            if(fixApprover.ASI_CRM_CN_Approval_Limit_3__c < p.ASI_CRM_CN_Total_Payment__c){
                if(fixApprover.ASI_CRM_CN_Approver_4__c!=null){
                setApproverByCount(p, approver_count, fixApprover.ASI_CRM_CN_Approver_4__c);
                approver_count++;
                }
            }
            if(fixApprover.ASI_CRM_CN_Approval_Limit_4__c < p.ASI_CRM_CN_Total_Payment__c){
                if(fixApprover.ASI_CRM_CN_Approver_5__c!=null){
                setApproverByCount(p, approver_count, fixApprover.ASI_CRM_CN_Approver_5__c);
                approver_count++;
                }
            }
            if(fixApprover.ASI_CRM_CN_Approval_Limit_5__c < p.ASI_CRM_CN_Total_Payment__c){
                if(fixApprover.ASI_CRM_CN_Approver_6__c!=null){
                setApproverByCount(p, approver_count, fixApprover.ASI_CRM_CN_Approver_6__c);
                approver_count++;
                }
            }                    
        }       
        
        //Dynamic route        
        boolean proceed = true;
        id currentUserid = p.ASI_CRM_CN_Owner_Manager_ID__c;
        ASI_CRM_Dynamic_Approval_Route__c currentApprover = null;
        User currentApproverU = null;
        system.debug(currentUserid);
        
        while(proceed){
             if(currentUserid!=null && (MAppRoute.containsKey(currentUserid) || MUser.containsKey(currentUserid))){
                    if(MAppRoute.get(currentUserid) != null){
                        currentApprover = MAppRoute.get(currentUserid);
                        currentUserid = currentApprover.ASI_CRM_Manager_ID__c;
                    }
                    else{
                        if(MUser.get(currentUserid) != null){
                            currentApproverU = MUser.get(currentUserid);
                            currentUserid = currentApproverU.ManagerID;
                        }
                    }
                    
                    system.debug(currentUserid);
                    if(currentApprover != null && currentApproverU == null){                            
                        setApproverByCount(p, approver_count, currentApprover.ASI_CRM_User__c);
                    }
                    else if(currentApprover == null && currentApproverU != null){
                        setApproverByCount(p, approver_count, currentApproverU.id);
                    }
                    approver_count++;
                    
                     if(currentApprover != null){
                        if( currentApprover.ASI_CRM_End_of_Dynamic_Route__c || currentApprover.ASI_CRM_Approval_Limit__c >= paymentrequest_limit){
                            proceed = false;
                        }
                     }
                    
                    system.debug(p);
                    system.debug(approver_count);
                    
                    currentApprover = null;
                    currentApproverU = null;
             }
             else{
                proceed = false;
             }
        }
        System.debug(p.ASI_CRM_CN_Division__c);
        
        //Second fix route
        ASI_CRM_Fix_Approval_Route__c fixApprover2;
        for(ASI_TH_CRM_PaymentRequest__c c: LPayment ){
            //20160921 Ben @ ELufa
            if(MUser.containsKey(p.OwnerId) && MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c != null){
                /*20160922 Ben @ Elufa Commented
                if(c.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Is_IHBR_Outlet__c == true){
                    if(p.ASI_CRM_CN_Last_Payment__c==true)
                        fixApprover2 = MAppRouteFix2.get('Last Payment (IHBR) 2nd Part' + MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c);
                    else
                        fixApprover2 = MAppRouteFix2.get('Payment (IHBR) 2nd Part' + MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c);
                }20160922 End
                */
                //else{
                    //fixApprover2 = MAppRouteFix2.get(p.ASI_CRM_CN_Division__c); //20160819,edited by Leo
                    //if(MUser.containsKey(p.OwnerId) && MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c != null) //20160819,edited by Leo
                        fixApprover2 = MAppRouteFix2.containsKey(MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c + p.ASI_CRM_Commercial_Team__c) ? MAppRouteFix2.get(MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c + p.ASI_CRM_Commercial_Team__c) : MAppRouteFix2.get(MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c); //20160819,edited by Leo
                //}
            }
        }
        System.debug(fixApprover2);
        System.debug(paymentrequest_limit);
        System.debug(p.ASI_CRM_CN_Total_Payment__c);
        if(fixApprover2 != null && fixApprover2.ASI_CRM_CN_Entry_Limit__c < paymentrequest_limit){           
            //Modified by William Yang(Introv) 20140929 to set Return Approvers
            Integer return_approver_count = 0;
        
            if(fixApprover2.ASI_CRM_CN_Approver_1__c != null){         
                setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_1__c);
                approver_count++;
                
                if(p.ASI_CRM_CN_Return_Flag__c){
                    setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_1__c);
                    return_approver_count++;
                }
            }
            if(fixApprover2.ASI_CRM_CN_Approval_Limit_1__c < p.ASI_CRM_CN_Total_Payment__c){
                if(fixApprover2.ASI_CRM_CN_Approver_2__c!=null){
                    setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_2__c);
                    approver_count++;
                    
                    if(p.ASI_CRM_CN_Return_Flag__c){
                        setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_2__c);
                        return_approver_count++;
                    }
                }
            }
            if(fixApprover2.ASI_CRM_CN_Approval_Limit_2__c < p.ASI_CRM_CN_Total_Payment__c){
                if(fixApprover2.ASI_CRM_CN_Approver_3__c!=null){
                    setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_3__c);
                    approver_count++;
                    
                    if(p.ASI_CRM_CN_Return_Flag__c){
                        setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_3__c);
                        return_approver_count++;
                    }
                }
            }
            if(fixApprover2.ASI_CRM_CN_Approval_Limit_3__c < p.ASI_CRM_CN_Total_Payment__c){
                if(fixApprover2.ASI_CRM_CN_Approver_4__c!=null){
                    setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_4__c);
                    approver_count++;
                    
                    if(p.ASI_CRM_CN_Return_Flag__c){
                        setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_4__c);
                        return_approver_count++;
                    }
                }
            }
            if(fixApprover2.ASI_CRM_CN_Approval_Limit_4__c < p.ASI_CRM_CN_Total_Payment__c){
                if(fixApprover2.ASI_CRM_CN_Approver_5__c!=null){
                    setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_5__c);
                    approver_count++;
                    
                    if(p.ASI_CRM_CN_Return_Flag__c){
                        setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_5__c);
                        return_approver_count++;
                    }
                }
            }
            if(fixApprover2.ASI_CRM_CN_Approval_Limit_5__c < p.ASI_CRM_CN_Total_Payment__c){
                if(fixApprover2.ASI_CRM_CN_Approver_6__c!=null){
                    setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_6__c);
                    approver_count++;
                    
                    if(p.ASI_CRM_CN_Return_Flag__c){
                        setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_6__c);
                        return_approver_count++;
                    }
                }
            }            
        }
    }
    
    public static void setApproverByCount(ASI_TH_CRM_PaymentRequest__c p, integer approver_count, Id userId){
        if(approver_count == 0)
            p.ASI_CRM_CN_Sys_Approver_1__c = userId;

        else if(approver_count == 1)
            p.ASI_CRM_CN_Sys_Approver_2__c = userId;

        else if(approver_count == 2)
            p.ASI_CRM_CN_Sys_Approver_3__c = userId;

        else if(approver_count == 3)
            p.ASI_CRM_CN_Sys_Approver_4__c = userId;

        else if(approver_count == 4)
            p.ASI_CRM_CN_Sys_Approver_5__c = userId;

        else if(approver_count == 5)
            p.ASI_CRM_CN_Sys_Approver_6__c = userId;

        else if(approver_count == 6)
            p.ASI_CRM_CN_Sys_Approver_7__c = userId;

        else if(approver_count == 7)
            p.ASI_CRM_CN_Sys_Approver_8__c = userId;

        else if(approver_count == 8)
            p.ASI_CRM_CN_Sys_Approver_9__c = userId;

        else if(approver_count == 9)
            p.ASI_CRM_CN_Sys_Approver_10__c = userId;

        else if(approver_count == 10)
            p.ASI_CRM_CN_Sys_Approver_11__c = userId;

    }
    
    public static void setReturnApproverByCount(ASI_TH_CRM_PaymentRequest__c p, integer approver_count, Id userId){
         if(approver_count == 0)
            p.ASI_CRM_CN_Return_Approver_1__c = userId;
        
        else if(approver_count == 1)
            p.ASI_CRM_CN_Return_Approver_2__c = userId;

        else if(approver_count == 2)
            p.ASI_CRM_CN_Return_Approver_3__c = userId;

        else if(approver_count == 3)
            p.ASI_CRM_CN_Return_Approver_4__c = userId;

        else if(approver_count == 4)
            p.ASI_CRM_CN_Return_Approver_5__c = userId;

        else if(approver_count == 5)
            p.ASI_CRM_CN_Return_Approver_6__c = userId;

        else if(approver_count == 6)
            p.ASI_CRM_CN_Return_Approver_7__c = userId;

        else if(approver_count == 7)
            p.ASI_CRM_CN_Return_Approver_8__c = userId;

        else if(approver_count == 8)
            p.ASI_CRM_CN_Return_Approver_9__c = userId;

        else if(approver_count == 9)
            p.ASI_CRM_CN_Return_Approver_10__c = userId;

        else if(approver_count == 10)
            p.ASI_CRM_CN_Return_Approver_11__c = userId;
    }
    
    public static void setApproverToNull(ASI_TH_CRM_PaymentRequest__c p){
        p.ASI_CRM_CN_Sys_Approver_1__c = null;
        p.ASI_CRM_CN_Sys_Approver_2__c = null;
        p.ASI_CRM_CN_Sys_Approver_3__c = null;
        p.ASI_CRM_CN_Sys_Approver_4__c = null;
        p.ASI_CRM_CN_Sys_Approver_5__c = null;
        p.ASI_CRM_CN_Sys_Approver_6__c = null;
        p.ASI_CRM_CN_Sys_Approver_7__c = null;
        p.ASI_CRM_CN_Sys_Approver_8__c = null;
        p.ASI_CRM_CN_Sys_Approver_9__c = null;
        p.ASI_CRM_CN_Sys_Approver_10__c = null;
        p.ASI_CRM_CN_Sys_Approver_11__c = null;       
        
        p.ASI_CRM_CN_Return_Approver_1__c = null;
        p.ASI_CRM_CN_Return_Approver_2__c = null;
        p.ASI_CRM_CN_Return_Approver_3__c = null;
        p.ASI_CRM_CN_Return_Approver_4__c = null;
        p.ASI_CRM_CN_Return_Approver_5__c = null;
        p.ASI_CRM_CN_Return_Approver_6__c = null;
        p.ASI_CRM_CN_Return_Approver_7__c = null;
        p.ASI_CRM_CN_Return_Approver_8__c = null;
        p.ASI_CRM_CN_Return_Approver_9__c = null;
        p.ASI_CRM_CN_Return_Approver_10__c = null;
        p.ASI_CRM_CN_Return_Approver_11__c = null;  
    }   
    
    //20200401:AM@introv - set LastUpdatedBy for Payment API (GL Date + Invoice Number)
    private static void setFinanceLastUpdated(list<ASI_TH_CRM_PaymentRequest__c> trigger_new, map<id, ASI_TH_CRM_PaymentRequest__c> trigger_oldMap) {
        for (ASI_TH_CRM_PaymentRequest__c p : trigger_new) {
            if (trigger_oldMap == NULL) {
                if (p.ASI_TH_CRM_GL_Date__c != NULL) p.ASI_CRM_Finance_Last_Updated_By__c = UserInfo.getUserId();
            } else {
                if (p.ASI_TH_CRM_GL_Date__c != trigger_oldMap.get(p.Id).ASI_TH_CRM_GL_Date__c) p.ASI_CRM_Finance_Last_Updated_By__c = UserInfo.getUserId();
            }
        }
    }

    // 对于Dolphin乐家会小程序过来的payment自动生成编号-编号规则 合同号-D-三位数自增
    // Added By Zhonghui Li, 2020-11-04
    public static void generateInterfacePaymentName(List<ASI_TH_CRM_PaymentRequest__c> trigger_new) {
        Map<Id, Integer> contractPaymentIntMap = new Map<Id, Integer>();
        for (ASI_TH_CRM_PaymentRequest__c payment : trigger_new) {
            if (payment.ASI_CRM_CN_Is_Dolphin_Auto_Payment__c && String.isNotBlank(payment.ASI_TH_CRM_Contract__c)) {
                contractPaymentIntMap.put(payment.ASI_TH_CRM_Contract__c, 0);
            }
        }
        if (contractPaymentIntMap.isEmpty()) {
            return;
        }
        for (AggregateResult re : [SELECT  ASI_TH_CRM_Contract__c, count(Id)
                                  FROM ASI_TH_CRM_PaymentRequest__c 
                                  WHERE ASI_TH_CRM_Contract__c IN:contractPaymentIntMap.keySet() AND ASI_CRM_CN_Is_Dolphin_Auto_Payment__c = TRUE
                                  GROUP BY ASI_TH_CRM_Contract__c]) {
            contractPaymentIntMap.put((Id)re.get('ASI_TH_CRM_Contract__c'), (Integer)re.get('expr0'));
        }
        Map<Id, ASI_TH_CRM_Contract__c> contractIdPONOMap = new Map<Id, ASI_TH_CRM_Contract__c>([SELECT Id, ASI_CRM_CN_PO_No__c 
                                                                    FROM ASI_TH_CRM_Contract__c
                                                                    WHERE Id IN:contractPaymentIntMap.keySet()]);
        for (ASI_TH_CRM_PaymentRequest__c payment : trigger_new) {
            if (payment.ASI_CRM_CN_Is_Dolphin_Auto_Payment__c && contractPaymentIntMap.containsKey(payment.ASI_TH_CRM_Contract__c)) {
                Integer iIndex = contractPaymentIntMap.get(payment.ASI_TH_CRM_Contract__c);
                payment.Name = contractIdPONOMap.get(payment.ASI_TH_CRM_Contract__c)?.ASI_CRM_CN_PO_No__c
                                + '-D-' 
                                + digit_formatting(3, iIndex + 1);
                System.debug(LoggingLevel.INFO, '*** generate Auto Name: ' + payment.Name);
                contractPaymentIntMap.put(payment.ASI_TH_CRM_Contract__c, iIndex + 1);
            }
        }
    }
    public static String digit_formatting(Integer digit,Decimal numbers){
        Decimal base=Math.pow(10,(digit-1));
        String formate='';
        Decimal counter = numbers/base;
        if(counter>1)formate= String.valueOf(numbers);
        else{ 
            counter=0;
            for(Integer dec=Integer.valueOf(numbers);dec>0;dec=dec/10){
                counter++;
            }
            for(Integer a=0;a<digit-counter;a++){
                formate+='0';
            }
            
            formate +=numbers;
        }
        return formate;
    }

}