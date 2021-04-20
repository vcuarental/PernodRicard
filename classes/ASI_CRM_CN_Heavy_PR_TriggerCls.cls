/* Filename:    ASI_CRM_CN_Heavy_PR_TriggerCls.cls
* Author:      Laputa
* Purpose:     CRM 4.2 CN Payment Request Trigger Class
*
*
* History
* -----------------------------------------------------------------------------
* 2017-05-29   Laputa      Created
*/

public without sharing class ASI_CRM_CN_Heavy_PR_TriggerCls {
    public static String className = 'ASI_CRM_CN_Heavy_PR_TriggerCls';
    
    public static void routineAfterInsert(list<ASI_TH_CRM_PaymentRequest__c> trigger_new) {
        interfacePaymentAmountCheck(trigger_new);
        if(!ASI_CRM_CN_Function.IsBypassTrigger(className)) {
            //creating payment request line item according to contract
            Set<id> SContractID = new Set<id>();
            Map<id,id> MContractIDPaymentRequest = new Map<id,id>();
            Set<id> SOutletID = new Set<id>();
            
            //insert an approval comment
            List<ASI_CRM_Approval_Comment__c> LNewPRComment_Insert = new List<ASI_CRM_Approval_Comment__c>();
            
            String PaymentId='';

            Id approvalCommentId = Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_Payment_Request_Comment');
            for(ASI_TH_CRM_PaymentRequest__c p : trigger_new){
                PaymentId = p.id;
                SContractID.add(p.ASI_TH_CRM_Contract__c);
                MContractIDPaymentRequest.put(p.ASI_TH_CRM_Contract__c,p.id);
                SOutletID.add(p.ASI_CRM_CN_OutletWS__c);
                
                if(Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_CRM_CN_Payment_Request')){
                    LNewPRComment_Insert.add(new ASI_CRM_Approval_Comment__c(ASI_CRM_Payment_Request__c = p.id, recordtypeid = approvalCommentId));
                }
              
            }
            if(LNewPRComment_Insert !=null && LNewPRComment_Insert.size() > 0){
                insert LNewPRComment_Insert;
            }
            
                
                
            
            List<ASI_TH_CRM_PaymentRequestLineItem__c> LPaymentRequestItem = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
            // 2019-09-24 Bowen Global_recordTypeCache.getRtId方法是一个查询方法，都是原代码是将这个方法放在for循环中，即在for循环中做查询了，会报101错误
            Id paymentRequestId = Global_recordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other');
            //Other Payment swap name and chinese description when copy to other payment
            for(ASI_CRM_Contract_Cost__c c : [Select id, name, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Activity_Code__c, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Sequence__c 
                                              from ASI_CRM_Contract_Cost__c   where ASI_CRM_CN_Other_Cost_Payment_Request__c = true and ASI_CRM_CN_Contract__c IN :SContractID order by ASI_CRM_CN_Contract__c, ASI_CRM_CN_Sequence__c])
            {
                ASI_TH_CRM_PaymentRequestLineItem__c PaymentRequestLine = new ASI_TH_CRM_PaymentRequestLineItem__c(ASI_CRM_CN_Contract_Cost__c = c.id,
                                                                                                                   recordtypeid = paymentRequestId,
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
            
            
            Map<String,ASI_CRM_Module__c> ModuleMap = new Map<String,ASI_CRM_Module__c>();
            //Insert Module
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine : [
                SELECT Id,
ASI_CRM_Module__c,
ASI_CRM_CN_Activity_Code__c,
ASI_CRM_Type__c,
ASI_CRM_CN_Contract__c,
ASI_CRM_Module__r.ASI_CRM_Line_Type__c,
ASI_CRM_Volume_Base__c,
ASI_CRM_Module__r.ASI_CRM_CN_Contract_Volume_Base__c,
ASI_CRM_Module__r.ASI_CRM_Unit__c,
ASI_CRM_Module__r.ASI_CRM_Volume_Base__c,
ASI_CRM_Module__r.ASI_CRM_Methodology__c,
ASI_CRM_Module__r.ASI_CRM_CN_KPI_Base__c,
ASI_CRM_Module__r.ASI_CRM_CN_Minimal_Achievement__c,
ASI_CRM_Module__r.ASI_CRM_CN_Criteria__c,
ASI_CRM_Module__r.ASI_CRM_CN_Is_Capped__c,
ASI_CRM_Module__r.ASI_CRM_CN_Total_Markup__c
                FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
                WHERE ASI_CRM_CN_Contract__c IN :SContractID AND ASI_CRM_Module__c != NULL AND ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c != '999'
            ])
            {
                if(!ModuleMap.containsKey(ContractLine.ASI_CRM_Module__c)){//ASI_CRM_CN_AC_Code__c
                    ASI_CRM_Module__c Module = new ASI_CRM_Module__c(
                        ASI_CRM_Parent_Module__c = ContractLine.ASI_CRM_Module__c,
                        ASI_CRM_CN_AC_Code__c = ContractLine.ASI_CRM_CN_Activity_Code__c != null? ContractLine.ASI_CRM_CN_Activity_Code__c : null,
                        ASI_CRM_Contract__c = ContractLine.ASI_CRM_CN_Contract__c,
                        ASI_CRM_Line_Type__c = ContractLine.ASI_CRM_Type__c,
                        ASI_CRM_Payment_Request__c = PaymentId,
                        ASI_CRM_CN_Contract_Volume_Base__c = ContractLine.ASI_CRM_Module__r.ASI_CRM_CN_Contract_Volume_Base__c,
                        ASI_CRM_Volume_Base__c = ContractLine.ASI_CRM_Volume_Base__c,
                        ASI_CRM_Methodology__c = ContractLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c,
                        ASI_CRM_CN_KPI_Base__c = ContractLine.ASI_CRM_Module__r.ASI_CRM_CN_KPI_Base__c,
                        ASI_CRM_CN_Minimal_Achievement__c = ContractLine.ASI_CRM_Module__r.ASI_CRM_CN_Minimal_Achievement__c,
                        ASI_CRM_CN_Criteria__c = ContractLine.ASI_CRM_Module__r.ASI_CRM_CN_Criteria__c,
                        ASI_CRM_CN_Is_Capped__c = ContractLine.ASI_CRM_Module__r.ASI_CRM_CN_Is_Capped__c,
                        ASI_CRM_CN_Total_Markup__c = ContractLine.ASI_CRM_Module__r.ASI_CRM_CN_Total_Markup__c
                    );
                    
                    if(ContractLine.ASI_CRM_Module__r.ASI_CRM_Unit__c!=null){
                        Module.ASI_CRM_Unit__c=ContractLine.ASI_CRM_Module__r.ASI_CRM_Unit__c;
                    }
                    ModuleMap.put(ContractLine.ASI_CRM_Module__c,Module);
                }
                
            }
            
            
            if(ModuleMap.size()>0){
                insert ModuleMap.values();
            }
            
        }
    }
    
        
    public static void routineBeforeUpdate(list<ASI_TH_CRM_PaymentRequest__c> trigger_new, map<id, ASI_TH_CRM_PaymentRequest__c> trigger_oldMap) {
        
        if(!ASI_CRM_CN_Function.IsBypassTrigger(className)) {
            system.debug('-----routineBeforeUpdate ===');
            
            Set<ID> payID = new Set<ID>();
            Map<String, String> mapRejectedComment = new Map<String, String>();

            Set<Id> refreshSet = new Set<Id>();
            
            for(ASI_TH_CRM_PaymentRequest__c obj : trigger_new){
                system.debug('obj.ASI_TH_CRM_Status__c ==' +obj.ASI_TH_CRM_Status__c);
                system.debug('trigger_oldMap.get(obj.id).ASI_TH_CRM_Status__c  ==' +trigger_oldMap.get(obj.id).ASI_TH_CRM_Status__c );

                // 状态有submitted更改为draft时，触发
                if(trigger_oldMap.get(obj.id).ASI_TH_CRM_Status__c == 'Submitted' && obj.ASI_TH_CRM_Status__c == 'Draft'){
                    payID.add(obj.id);
                }
                // 当状态为draft，且ASI_CRM_CN_Total_Payment__c发生变化，则触发
                else if(trigger_oldMap.get(obj.Id).ASI_CRM_CN_Total_Payment__c != obj.ASI_CRM_CN_Total_Payment__c  && obj.ASI_CRM_CN_Total_Payment__c != null && obj.ASI_TH_CRM_Status__c == 'Draft')
                {
                    payID.add(obj.id);
                }
                else if(trigger_oldMap.get(obj.Id).ASI_CRM_RVP_Approval__c == false && obj.ASI_CRM_RVP_Approval__c == true)
                {
                    payID.add(obj.Id);
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
            if(refreshSet.size() == trigger_new.size()) return;


            system.debug('payID.size() ==' + payID.size());
            if(payID.size() > 0)
            {
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
                        if(mapRejectedComment.containsKey(obj.id) && obj.ASI_CRM_CN_Approval_Status__c == 'Draft' && trigger_oldMap.get(obj.id).ASI_CRM_CN_Approval_Status__c == 'Submitted'){
                            obj.ASI_CRM_CN_Return_Comments__c = ( (obj.ASI_CRM_Branch__c == 'returned') ? 'Returned-': 'Rejected-')  + mapRejectedComment.get(obj.id);
                            
                            obj.ASI_CRM_Reject_Return_Comments__c = (obj.ASI_CRM_Reject_Return_Comments__c == NULL || obj.ASI_CRM_Reject_Return_Comments__c == '') ? ( (obj.ASI_CRM_Branch__c == 'returned') ? 'Return Comment / ': 'Reject Comment / ') + UserInfo.getName() + ' / ' + Datetime.now().format('YYYY-MM-dd') + ':' + '\n' + mapRejectedComment.get(obj.id) :  ( (obj.ASI_CRM_Branch__c == 'returned') ? 'Return Comment / ': 'Reject Comment / ')  + UserInfo.getName() + ' / ' + Datetime.now().format('YYYY-MM-dd') + ':' + '\n' + mapRejectedComment.get(obj.id)+ '\n' + obj.ASI_CRM_Reject_Return_Comments__c;
                        }
                    }
                }
            }            
            
            
            //  Assign Approver
            // find the manager from hierarchy if it is not included in dynamic route       
            Map<id, ASI_CRM_Dynamic_Approval_Route__c> MAppRoute = new Map<id, ASI_CRM_Dynamic_Approval_Route__c>();
            Map<string, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix = new Map<string, ASI_CRM_Fix_Approval_Route__c>();
            Map<string, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix2 = new Map<string, ASI_CRM_Fix_Approval_Route__c>();
            Map<id, ASI_CRM_Dynamic_Approval_Route__c> MAppLastPaymentRoute = new Map<id, ASI_CRM_Dynamic_Approval_Route__c>();
            Map<string, ASI_CRM_Fix_Approval_Route__c> MAppLastPaymentRouteFix = new Map<string, ASI_CRM_Fix_Approval_Route__c>();
            Map<string, ASI_CRM_Fix_Approval_Route__c> MAppLastPaymentRouteFix2 = new Map<string, ASI_CRM_Fix_Approval_Route__c>();
            Map<id, User> MUser = new Map<id, User>();
            
            // for checking IHBR flag
            Set<id> SPaymentID = new Set<id>();
            Set<id> SIHBR = new Set<id>();
            
            List<User> LUser = [Select id, ManagerID, ASI_CRM_Sales_Team__c from User Where CompanyName = 'Pernod Ricard China' ];               
            for(User u : LUser){
                MUser.put(u.id, u);
            }        
            
            // limit set approver when status is draft
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
                Date:2019-09-18
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
            if(needSetApprover){
                // 如上注释所述
                // List<ASI_TH_CRM_PaymentRequest__c> LFlag = [Select id, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Is_IHBR_Outlet__c, ASI_CRM_CN_Return_Flag__c 
                //                                             from ASI_TH_CRM_PaymentRequest__c
                //                                             where id IN: SPaymentID];
                // for(ASI_TH_CRM_PaymentRequest__c c:LFlag ){                                             
                //     if(c.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Is_IHBR_Outlet__c == true){
                //         SIHBR.add(c.id);
                //     }
                // }
                for(ASI_CRM_Dynamic_Approval_Route__c a : [Select id, ASI_CRM_Approval_Limit__c,  ASI_CRM_End_of_Dynamic_Route__c, ASI_CRM_Manager_ID__c, ASI_CRM_Type__c, ASI_CRM_User__c from ASI_CRM_Dynamic_Approval_Route__c  where ASI_CRM_Type__c = 'Payment' or ASI_CRM_Type__c = 'Last Payment']){
                    if(a.ASI_CRM_Type__c =='Payment')
                        MAppRoute.put(a.ASI_CRM_User__c, a);
                    if(a.ASI_CRM_Type__c =='Last Payment')
                        MAppLastPaymentRoute .put(a.ASI_CRM_User__c, a);
                }

                List<String> types = new List<String>{'Heavy Contract On Payment','Heavy Contract On Last Payment' };
                // 2019-08-20 Bowen promotion 多加了Wholesaler Promotion 、Outlet Promotion 、Consumer Promotion
                if (trigger_new[0].ASI_CRM_CN_Promotion_Type__c == 'TOT/MOT Contract' 
                    || trigger_new[0].ASI_CRM_CN_Promotion_Type__c=='Wholesaler Promotion'
                    || trigger_new[0].ASI_CRM_CN_Promotion_Type__c=='Outlet Promotion'
                    || trigger_new[0].ASI_CRM_CN_Promotion_Type__c=='Consumer Promotion') {
                    types = new List<String>{'TOT/MOT Payment','TOT/MOT Last Payment'};
                }
                for(ASI_CRM_Fix_Approval_Route__c a : [Select Id,ASI_CRM_RVP__c,ASI_CRM_CN_Regional_BA__c,ASI_CRM_CN_Region_Area_Channel__c, ASI_CRM_CN_Entry_Limit__c,ASI_CRM_CN_Approver_1__c, ASI_CRM_CN_Approver_2__c, ASI_CRM_CN_Approver_3__c,ASI_CRM_CN_Approver_4__c, ASI_CRM_CN_Approver_5__c, ASI_CRM_CN_Approver_6__c,ASI_CRM_CN_Type__c,  ASI_CRM_CN_Approval_Limit_1__c, ASI_CRM_CN_Approval_Limit_2__c, ASI_CRM_CN_Approval_Limit_3__c, ASI_CRM_CN_Approval_Limit_4__c, ASI_CRM_CN_Approval_Limit_5__c, ASI_CRM_CN_Approval_Limit_6__c,ASI_CRM_Sales_Team__c  , ASI_CRM_Commercial_Team__c from ASI_CRM_Fix_Approval_Route__c where
                                                       ASI_CRM_CN_Type__c IN :types]){

                    String commercialTeam = a.ASI_CRM_Commercial_Team__c != Null && a.ASI_CRM_Commercial_Team__c != '' ? a.ASI_CRM_Commercial_Team__c : '';

                    if(a.ASI_CRM_CN_Type__c =='Heavy Contract On Payment' || a.ASI_CRM_CN_Type__c =='TOT/MOT Payment')
                        MAppRouteFix2.put(a.ASI_CRM_Sales_Team__c + commercialTeam, a);
                    else if(a.ASI_CRM_CN_Type__c  =='Heavy Contract On Last Payment' || a.ASI_CRM_CN_Type__c =='TOT/MOT Last Payment')
                        MAppLastPaymentRouteFix2.put(a.ASI_CRM_Sales_Team__c + commercialTeam, a);
                    
                }
            }
            
            //  (Check first payment flag) start
            String[] contract_id=new String[trigger_new.size()];
            Integer counter=0;
            for(ASI_TH_CRM_PaymentRequest__c payment : trigger_new){
                if(payment.ASI_CRM_CN_Last_Payment__c==false && payment.ASI_TH_CRM_Status__c == 'Draft'){
                    setApproverToNull(payment);
                    setApprovers(paymentMap ,payment, MAppRoute, MAppRouteFix, MAppRouteFix2, MUser);
                    system.debug('payment.ASI_CRM_CN_Last_Payment__c == false;');
                }
                if(payment.ASI_CRM_CN_Last_Payment__c==true && payment.ASI_TH_CRM_Status__c == 'Draft'){
                    setApproverToNull(payment);
                    setApprovers(paymentMap ,payment, MAppLastPaymentRoute , MAppLastPaymentRouteFix, MAppLastPaymentRouteFix2, MUser);
                    system.debug('payment.ASI_CRM_CN_Last_Payment__c == true;');
                }
                
                if(counter<trigger_new.size()){
                    contract_id[counter++]=payment.ASI_TH_CRM_Contract__c ;}
                
            }
            
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
            
            //20200401:AM@introv - set LastUpdatedBy for Payment API (GL Date + Invoice Number)
        	setFinanceLastUpdated(trigger_new, trigger_oldMap);
               
        }
    }
    
   
    public static void routineAfterUpdate(list<ASI_TH_CRM_PaymentRequest__c> trigger_new, map<id, ASI_TH_CRM_PaymentRequest__c> trigger_oldMap) {
        Set<Id> PaidContractIdSet = new Set<Id> ();
        
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
                
                
                if(paymentrequest.ASI_TH_CRM_Status__c =='Approved' && paymentrequest.ASI_TH_CRM_Status__c != trigger_oldMap.get(paymentrequest.id).ASI_TH_CRM_Status__c && paymentrequest.ASI_CRM_CN_Last_Payment__c ){
                    PaidContractIdSet.add(paymentrequest.ASI_TH_CRM_Contract__c);
                }
            }
            List<ASI_CRM_CN_PH_Payee_Line_Item__c> listPHLineItem = [SELECT ID FROM ASI_CRM_CN_PH_Payee_Line_Item__c WHERE ASI_CRM_CN_Payment_Request__c IN:idPaymentRequest];
            delete listPHLineItem;
            update cs;
        }
        
        
        
        
    }
    
    
    /*
    public static void routineBeforeInsert(list<ASI_TH_CRM_PaymentRequest__c> trigger_new, map<id, ASI_TH_CRM_PaymentRequest__c> trigger_oldMap) {
        if(!ASI_CRM_CN_Function.IsBypassTrigger(className)) {
            String [] trigger_new_id=new String[trigger_new.size()];
            Integer i=0;
            ASI_CRM_CN_CustomSetting__c customSetting = ASI_CRM_CN_CustomSetting__c.getOrgDefaults();
            String lastYrPaymentCode = customSetting.ASI_CRM_CN_Last_Year_Payment_Code__c;
            for(ASI_TH_CRM_PaymentRequest__c paymentrequest : trigger_new){
                trigger_new_id[i++]=paymentrequest.ASI_TH_CRM_Contract__c;
                if(paymentrequest.ASI_CRM_CN_Last_Year_Payment__c){
                    paymentrequest.ASI_CRM_CN_Reference_Code__c = lastYrPaymentCode; 
                }
            }
            
            //  payment with same contract
            List<ASI_TH_CRM_PaymentRequest__c> Payment_list=[Select id,Name,ASI_TH_CRM_Contract__c,ASI_CRM_CN_Last_Payment__c, ASI_TH_CRM_Status__c, ASI_CRM_CN_Return_Flag__c From ASI_TH_CRM_PaymentRequest__c where ASI_TH_CRM_Contract__c IN :trigger_new_id And ASI_TH_CRM_Status__c !='Draft'];
            Map<id,String> Payment_Map=new Map<id,String>();
            
            for(ASI_TH_CRM_PaymentRequest__c paymentrequest : Payment_list){
                if(paymentrequest.ASI_CRM_CN_Last_Payment__c==true){
                    Payment_Map.put(paymentrequest.ASI_TH_CRM_Contract__c,paymentrequest.Name);
                }
            }
            
            String error_Msg = Label.ASI_CRM_CN_ErrorMsg_MakePayment;  
            
            Map <String, String> labelAPIName = new Map <String, String> ();
            
            Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.ASI_TH_CRM_PaymentRequest__c.fields.getMap();
            for (Schema.SObjectField field : fieldsMap.values()){
                labelAPIName.put( field.getDescribe().getName(),field.getDescribe().getLabel());
            }
            
            String payment_no = labelAPIName.get('Name');
            User prof = [select id, Name, Profile.name, Profile.id, UserRole.developername from User where Id = :UserInfo.getUserId() ];
            boolean isuserAdmin = prof.profile.name.contains('System Administrator');    
            for(ASI_TH_CRM_PaymentRequest__c paymentrequest : trigger_new){
                if(Payment_Map.containskey(paymentrequest.ASI_TH_CRM_Contract__c) && !isuserAdmin){
                    paymentrequest.addError(error_Msg+' '+payment_no+Payment_Map.get(paymentrequest.ASI_TH_CRM_Contract__c));
                }
            }
            
        }
    }
    */
    //IHBR    
    public static void setApprovers(Map<Id ,ASI_TH_CRM_PaymentRequest__c> paymentMap , ASI_TH_CRM_PaymentRequest__c p,Map<id, ASI_CRM_Dynamic_Approval_Route__c> MAppRoute, Map<string, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix, Map<string, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix2, Map<id, User> MUser){
        Integer approver_count = 0;
        
        // List<ASI_TH_CRM_PaymentRequest__c> LPayment = [Select id, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Is_IHBR_Outlet__c, ASI_CRM_CN_Return_Flag__c, OwnerId from ASI_TH_CRM_PaymentRequest__c where id =:p.id];
        
        // set last payment payment request limit start
        decimal paymentrequest_limit=0;
        if(p.ASI_CRM_CN_Last_Payment__c==true){
            paymentrequest_limit= 0;
            // List<ASI_TH_CRM_Contract__c> LCont = [Select id, ASI_CRM_CN_Total_Contract_Amount__c  from ASI_TH_CRM_Contract__c where id =:p.ASI_TH_CRM_Contract__c limit 1]; 
            // if(LCont != null && LCont.size()==1){
            //     paymentrequest_limit= LCont[0].ASI_CRM_CN_Total_Contract_Amount__c==null?0:LCont[0].ASI_CRM_CN_Total_Contract_Amount__c;
            // }

            if(paymentMap.containsKey(p.id))
            {
                paymentrequest_limit= paymentMap.get(p.Id).ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c==null?0: paymentMap.get(p.Id).ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c;
            }
        }
        else{
            paymentrequest_limit=p.ASI_CRM_CN_Total_Payment__c;
        }
        System.debug(paymentrequest_limit);
        //set last payment payment request limit end
        
        
        //Dynamic route        
        boolean proceed = true;
        id currentUserid = p.ASI_CRM_CN_Owner_Manager_ID__c;
        ASI_CRM_Dynamic_Approval_Route__c currentApprover = null;
        User currentApproverU = null;
        
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
                
                currentApprover = null;
                currentApproverU = null;
            }
            else{
                proceed = false;
            }
        } 
        
        //Second fix route
        ASI_CRM_Fix_Approval_Route__c fixApprover2;
        // for(ASI_TH_CRM_PaymentRequest__c c: LPayment ){
            if(MUser.containsKey(p.OwnerId) && MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c != null){
                fixApprover2 = MAppRouteFix2.containsKey(MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c + p.ASI_CRM_Commercial_Team__c) ? MAppRouteFix2.get(MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c + p.ASI_CRM_Commercial_Team__c) : MAppRouteFix2.get(MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c); 
            }
        // }

        if(fixApprover2 != null && fixApprover2.ASI_CRM_CN_Regional_BA__c!=null){
            p.ASI_CRM_CN_Last_RBA_Approver__c=fixApprover2.ASI_CRM_CN_Regional_BA__c;
        }
        
        if(fixApprover2 != null && fixApprover2.ASI_CRM_CN_Entry_Limit__c < paymentrequest_limit){           
            //set Return Approvers
            Integer return_approver_count = 0;
            
            if(fixApprover2.ASI_CRM_CN_Approver_1__c != null){         
                setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_1__c);
                approver_count++;
                
                if(p.ASI_CRM_CN_Return_Flag__c){
                    setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_1__c);
                    return_approver_count++;
                }
            }

            /*
                Author:Bowen
                Date:2019-10-17
                update : 不知为何将第一个if注释，修改日期在2019年9月17号到18号之间，经过代码排查和分析，认为第一个if 不应该被注释，现重新开放

             */
            if(p.ASI_CRM_RVP_Approval__c && fixApprover2.ASI_CRM_RVP__c!=NULL){
            // if(fixApprover2.ASI_CRM_RVP__c!=NULL){
                Boolean FoundRVP=False;
                Boolean AllowPut=False;
                //Approver_2
                if(fixApprover2 .ASI_CRM_CN_Approver_2__c != null){
                    if(!FoundRVP){ //Have not found RVP
                        if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_2__c){
                            FoundRVP=true;
                        } 
                        AllowPut=true;
                    }else{
                        if(fixApprover2 .ASI_CRM_CN_Approval_Limit_1__c < p.ASI_CRM_CN_Total_Payment__c ){
                            AllowPut=true;
                        }
                    }
                }
                if(AllowPut){
                    setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_2__c);
                    approver_count++;
                    if(p.ASI_CRM_CN_Return_Flag__c){
                        setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_2__c);
                        return_approver_count++;
                    }
                }
                
                
                
                  
                    //Approver_3
                    AllowPut=False;
                    if(fixApprover2 .ASI_CRM_CN_Approver_3__c != null){
                        if(!FoundRVP){ //Have not found RVP
                            if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_3__c){
                                FoundRVP=true;
                            } 
                            AllowPut=true;
                        }else{
                            if(fixApprover2 .ASI_CRM_CN_Approval_Limit_2__c < p.ASI_CRM_CN_Total_Payment__c ){
                                AllowPut=true;
                            }
                        }
                    }                    
                    if(AllowPut){
                        setApproverByCount(p, approver_count, fixApprover2 .ASI_CRM_CN_Approver_3__c);
                        approver_count++;
                        if(p.ASI_CRM_CN_Return_Flag__c){
                            setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_3__c);
                            return_approver_count++;
                        }
                    }
                    
                    
                    
                     //Approver_4
                    AllowPut=False;
                    if(fixApprover2 .ASI_CRM_CN_Approver_4__c != null){
                        if(!FoundRVP){ //Have not found RVP
                            if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_4__c){
                                FoundRVP=true;
                            } 
                            AllowPut=true;
                        }else{
                            if(fixApprover2 .ASI_CRM_CN_Approval_Limit_3__c < p.ASI_CRM_CN_Total_Payment__c ){
                                AllowPut=true;
                            }
                        }
                    }
                    if(AllowPut){
                        setApproverByCount(p, approver_count, fixApprover2 .ASI_CRM_CN_Approver_4__c);
                        approver_count++;
                        if(p.ASI_CRM_CN_Return_Flag__c){
                            setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_4__c);
                            return_approver_count++;
                        }
                    }
                    
                    
                      //Approver_5
                    AllowPut=False;
                    if(fixApprover2 .ASI_CRM_CN_Approver_5__c != null){
                        if(!FoundRVP){ //Have not found RVP
                            if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_5__c){
                                FoundRVP=true;
                            } 
                            AllowPut=true;
                        }else{
                            if(fixApprover2 .ASI_CRM_CN_Approval_Limit_4__c < p.ASI_CRM_CN_Total_Payment__c ){
                                AllowPut=true;
                            }
                        }
                    }
                    if(AllowPut){
                        setApproverByCount(p, approver_count, fixApprover2 .ASI_CRM_CN_Approver_5__c);
                        approver_count++;
                        if(p.ASI_CRM_CN_Return_Flag__c){
                            setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_5__c);
                            return_approver_count++;
                        }
                    }
                    
                    //Approver_6
                    AllowPut=False;
                    if(fixApprover2 .ASI_CRM_CN_Approver_6__c != null){
                        if(!FoundRVP){ //Have not found RVP
                            if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_6__c){
                                FoundRVP=true;
                            } 
                            AllowPut=true;
                        }else{
                            if(fixApprover2 .ASI_CRM_CN_Approval_Limit_5__c < p.ASI_CRM_CN_Total_Payment__c ){
                                AllowPut=true;
                            }
                        }
                    }
                    
                    if(AllowPut){
                        setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_6__c);
                        approver_count++;
                        if(p.ASI_CRM_CN_Return_Flag__c){
                            setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_6__c);
                            return_approver_count++;
                        }
                    }//Ending*************
                    
                
                
            }else{
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
    // 校验auto payment的总费用+历史PSF module已支付总费用，是否超过PO PSF的总费用。
    //如果超了，就邮件通知PO Owner，cc给RBA（通过已知的规则找到FIx approval route，取的Regional BA）
    // Added By Zhonghui Li, 2021-01-04
    public static void interfacePaymentAmountCheck(List<ASI_TH_CRM_PaymentRequest__c> trigger_new) {
        Set<Id> ownerIdSet = new Set<Id>();
        Set<Id> contractIdSet = new Set<Id>();
        Set<String> salesTeamSet = new Set<String>();
        Set<String> commercialTeamSet = new Set<String>();
        for (ASI_TH_CRM_PaymentRequest__c payment : trigger_new) {
            if (payment.ASI_CRM_CN_Is_Dolphin_Auto_Payment__c) {
                ownerIdSet.add(payment.OwnerId);
                contractIdSet.add(payment.ASI_TH_CRM_Contract__c);
                if (String.isNotBlank(payment.ASI_CRM_Commercial_Team__c)) {
                    commercialTeamSet.add(payment.ASI_CRM_Commercial_Team__c);
                }                
            }
        }
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, ManagerID, ASI_CRM_Sales_Team__c 
                                                   FROM User 
                                                   WHERE CompanyName = 'Pernod Ricard China'
                                                   AND Id IN:ownerIdSet]);
        for (User usr : userMap.values()) {
            if (String.isNotBlank(usr.ASI_CRM_Sales_Team__c)) {
                salesTeamSet.add(usr.ASI_CRM_Sales_Team__c);
            }
        }
        Map<Id, ASI_TH_CRM_Contract__c> contractMap = new Map<Id, ASI_TH_CRM_Contract__c>(
                                [SELECT Id, ASI_CRM_CN_Expected_PSF_Est_Total__c, OwnerId, ASI_CRM_CN_PO_No__c,
                                      (SELECT Id, ASI_CRM_CN_Total_PSF_Amount__c
                                        FROM ASI_TH_CRM_PaymentRequests_Contract__r
                                        WHERE ASI_TH_CRM_Status__c IN ('Approved','Submitted','Paid')) 
                                 FROM ASI_TH_CRM_Contract__c 
                                 WHERE Id IN:contractIdSet]);
        Map<String, ASI_CRM_Fix_Approval_Route__c> arMap = new Map<String, ASI_CRM_Fix_Approval_Route__c>();
        for (ASI_CRM_Fix_Approval_Route__c ar : [SELECT Id, ASI_CRM_CN_Regional_BA__c,ASI_CRM_Sales_Team__c, ASI_CRM_Commercial_Team__c 
                                                 FROM ASI_CRM_Fix_Approval_Route__c
                                                 WHERE (ASI_CRM_Sales_Team__c IN :salesTeamSet OR
                                                       ASI_CRM_Commercial_Team__c IN:commercialTeamSet) AND
                                                    ASI_CRM_CN_Type__c IN ('Payment 2nd Part', 'Last Payment 2nd Part','Payment (IHBR) 2nd Part','Last Payment (IHBR) 2nd Part')]) {
            arMap.put(String.isBlank(ar.ASI_CRM_Commercial_Team__c)?ar.ASI_CRM_Sales_Team__c:ar.ASI_CRM_Sales_Team__c + ar.ASI_CRM_Commercial_Team__c, ar);
        }
        System.debug(LoggingLevel.INFO, '*** contractMap: ' + contractMap);
        System.debug('*** arMap.keySet(): ' + JSON.serializePretty(arMap.keySet()) + '');
        System.debug(LoggingLevel.INFO, '*** salesTeamSet: ' + salesTeamSet);
        System.debug(LoggingLevel.INFO, '*** commercialTeamSet: ' + commercialTeamSet);
        Messaging.SingleEmailMessage[] messages = 
            new List<Messaging.SingleEmailMessage> ();
        for (ASI_TH_CRM_PaymentRequest__c payment : trigger_new) {
            if (payment.ASI_CRM_CN_Is_Dolphin_Auto_Payment__c) {
                Decimal historyPSFAmount = 0;
                if (contractMap.get(payment.ASI_TH_CRM_Contract__c) != null) {
                    ASI_TH_CRM_Contract__c contract = contractMap.get(payment.ASI_TH_CRM_Contract__c);
                    for (ASI_TH_CRM_PaymentRequest__c historyPayment : contract.ASI_TH_CRM_PaymentRequests_Contract__r) {
                        historyPSFAmount += historyPayment.ASI_CRM_CN_Total_PSF_Amount__c;
                    }
                    System.debug(LoggingLevel.INFO, '*** historyPSFAmount: ' + historyPSFAmount);
                    System.debug(LoggingLevel.INFO, '*** payment.ASI_CRM_Total_Actual_Amount__c: ' + payment.ASI_CRM_Total_Actual_Amount__c);
                    System.debug(LoggingLevel.INFO, '*** contract.ASI_CRM_CN_Expected_PSF_Est_Total__c: ' + contract.ASI_CRM_CN_Expected_PSF_Est_Total__c);
                    // 金额大于合同PSF金额，发送邮件
                    if (payment.ASI_CRM_Total_Actual_Amount__c + historyPSFAmount > contract.ASI_CRM_CN_Expected_PSF_Est_Total__c) {
                        String salesTeam = userMap.get(payment.OwnerId)?.ASI_CRM_Sales_Team__c;
                        if (String.isNotBlank(salesTeam)) {
                           String teamKey = String.isBlank(payment.ASI_CRM_Commercial_Team__c)?salesTeam:salesTeam + payment.ASI_CRM_Commercial_Team__c;
                           Id RBAID = arMap.get(teamKey)?.ASI_CRM_CN_Regional_BA__c;
                           RBAID = RBAID ==null? (arMap.get(salesTeam)?.ASI_CRM_CN_Regional_BA__c):RBAID;
                           messages.add(generatesendEmailAlert(contract, RBAID));
                        }
                    }
                }
            }
        }
        if (!messages.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }

    }
    public static Messaging.SingleEmailMessage generatesendEmailAlert(ASI_TH_CRM_Contract__c cont, Id RBAID) {

            String recordUrl = Url.getSalesforceBaseUrl().toExternalForm()+'/' +cont.Id;
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] { cont.OwnerId};
            if (String.isNotBlank(RBAID)) {
                message.setCcAddresses(new String[] {RBAID});
            }
            message.subject = 'Dolphin PO '+
                            cont.ASI_CRM_CN_PO_No__c +' Payment总金额大于PO 金额，请做PO修改';
            message.htmlbody = 'Dolphin PO '+
                            cont.ASI_CRM_CN_PO_No__c +' Payment总金额大于PO 金额，请做PO修改</br>'
                            + recordUrl;
            return message;
    }
}