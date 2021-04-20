public without sharing class ASI_HK_CRM_SalesOrderDataManipulation extends ASI_HK_CRM_TriggerAbstract {
    
    public ASI_HK_CRM_SalesOrderDataManipulation() {
        super('ASI_HK_CRM_SalesOrderDataManipulation');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        if ((tAction == TriggerAction.BEFORE_INSERT || tAction == TriggerAction.BEFORE_UPDATE)  && !isBypassByCurrentUser()) {
            List<ASI_HK_CRM_Sales_Order__c> soList = (List<ASI_HK_CRM_Sales_Order__c>)sObjList;
            
            Set<id> OwnerId = new Set<id>();
            Set<id> CustomerId = new Set<id>();
            for (ASI_HK_CRM_Sales_Order__c so : soList) {
                if(so.ASI_HK_CRM_Customer_DA__c!=null) {
                	CustomerID.add(so.ASI_HK_CRM_Customer_DA__c);   
                }
                OwnerId.add(so.OwnerId);
            }
            
            Map<ID, User> OwnerMap  = new Map<ID,User>([SELECT ID, Name,BypassTriggers__c,ASI_Department__c  FROM User WHERE Id in :  OwnerId ]); 
            
            Map<id,ASI_CRM_AccountsAdditionalField__c> CustomerMap = new Map<id,ASI_CRM_AccountsAdditionalField__c>();
            List<ASI_CRM_AccountsAdditionalField__c> aclist = [SELECT id, ASI_CRM_Account__r.ASI_HK_CRM_Payment_Term_Code__c,ASI_CRM_CN_Phone_Number__c, ASI_CRM_CN_Fax_Number__c, ASI_HK_CRM_Delivery_Window_Instruction__c, ASI_HK_CRM_Delivery_Time_1__c, ASI_HK_CRM_Delivery_Time_2__c, ASI_HK_CRM_Payment_Method__c, ASI_HK_CRM_Instruction_txt__c, ASI_HK_CRM_Attention__c, ASI_HK_CRM_Delivery_Remarks__c, ASI_HK_CRM_User_D_O__c, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c IN :CustomerID];
            for (ASI_CRM_AccountsAdditionalField__c ac : aclist){
            	CustomerMap.put(ac.ASI_CRM_Account__c ,ac);
            }
            // End
            // Modified 201512 P2: copy account info when insert
            for (ASI_HK_CRM_Sales_Order__c so : soList) {
                ASI_HK_CRM_Sales_Order__c oldSO = tAction == TriggerAction.BEFORE_UPDATE ? (ASI_HK_CRM_Sales_Order__c)oldMap.get(so.Id) : null;
                if(so.ASI_HK_CRM_Payment_Method__c!=null && so.ASI_HK_CRM_Payment_Method__c == 'SALESMAN' && OwnerMap.containsKey(so.OwnerId) ){
                    if(OwnerMap.get(so.OwnerId).ASI_Department__c!='Luxury' && (OwnerMap.get(so.OwnerId).BypassTriggers__c ==null || (OwnerMap.get(so.OwnerId).BypassTriggers__c !=null && !OwnerMap.get(so.OwnerId).BypassTriggers__c.contains('ASI HK CRM Salesman Payment method') ) ) ){
                        so.ASI_HK_CRM_Payment_Method__c.addError('Cannot select SALESMAN.');
                    }
                }
                if(so.ASI_HK_CRM_Payment_Method__c!=null && so.ASI_HK_CRM_Payment_Method__c == 'VIP-Bank Transfer' && OwnerMap.containsKey(so.OwnerId) ){
                    if(OwnerMap.get(so.OwnerId).ASI_Department__c!='Luxury' && (OwnerMap.get(so.OwnerId).BypassTriggers__c ==null || (OwnerMap.get(so.OwnerId).BypassTriggers__c !=null && !OwnerMap.get(so.OwnerId).BypassTriggers__c.contains('ASI HK CRM Salesman Payment method') ) ) ){
                        so.ASI_HK_CRM_Payment_Method__c.addError('Cannot select VIP-Bank Transfer.');
                    }
                }
                if(so.ASI_HK_CRM_Payment_Method__c!=null && so.ASI_HK_CRM_Payment_Method__c == 'N/A' && so.ASI_HK_CRM_Customer_DA__c != null && CustomerMap.containsKey(so.ASI_HK_CRM_Customer_DA__c) &&
                   CustomerMap.get(so.ASI_HK_CRM_Customer_DA__c).ASI_CRM_Account__r.ASI_HK_CRM_Payment_Term_Code__c =='COD'  &&
                   (OwnerMap.get(so.OwnerId).BypassTriggers__c ==null ||  (OwnerMap.get(so.OwnerId).BypassTriggers__c !=null && !OwnerMap.get(so.OwnerId).BypassTriggers__c.contains('ASI HK CRM COD Account select NA') ) ) ) {
                    so.ASI_HK_CRM_Payment_Method__c.addError('For COD account, it’s not allowed to select the payment method N/A.');
                }
                if(oldSO != null){
                    if(so.ASI_HK_CRM_Payment_Method__c != oldSO.ASI_HK_CRM_Payment_Method__c ){
                        boolean showError = true;
                        if(so.ASI_HK_CRM_Payment_Method__c !=null && so.ASI_HK_CRM_Payment_Method__c =='N/A' && so.ASI_HK_CRM_Customer_DA__c != null && CustomerMap.containsKey(so.ASI_HK_CRM_Customer_DA__c) && CustomerMap.get(so.ASI_HK_CRM_Customer_DA__c).ASI_CRM_Account__r.ASI_HK_CRM_Payment_Term_Code__c !='COD' ){
                            showError =false ; //bypass Credit account for N/A option
                        }
                        so.ASI_HK_CRM_Changetime_for_Payment_Method__c = Datetime.now(); 
                        so.ASI_HK_CRM_Old_Payment_Method__c = oldSO.ASI_HK_CRM_Payment_Method__c;
                        if( (so.ASI_HK_CRM_Reason_PaymentMethodChange__c == null || so.ASI_HK_CRM_Reason_PaymentMethodChange__c.isWhitespace()) && showError ) {
                            so.ASI_HK_CRM_Reason_PaymentMethodChange__c.addError('once user change "Payment Method", should input "Reason for Payment Method Change"'); // prevent update
                        }
                    }
                    if(so.ASI_CRM_Delivery_Address__c != oldSO.ASI_CRM_Delivery_Address__c){
                        so.ASI_HK_CRM_Change_time_for_Address__c =  Datetime.now();
                    }
                }

                if (tAction == TriggerAction.BEFORE_INSERT )
                	DefaultInstruction(so, CustomerMap);
                updateForInstruction(so);
                updateForCustPONum(so);
            }
        }
    }
    
    //Added by Alan Wong (Elufa) 20150916 Default Instruction from Customer
    private void DefaultInstruction(ASI_HK_CRM_Sales_Order__c so,  Map<id,ASI_CRM_AccountsAdditionalField__c> CustomerMap) {
        if(so.ASI_HK_CRM_Customer_DA__c != null && CustomerMap.containsKey(so.ASI_HK_CRM_Customer_DA__c)) {
            if(so.ASI_HK_CRM_Phone_Number__c == null) so.ASI_HK_CRM_Phone_Number__c = CustomerMap.get(so.ASI_HK_CRM_Customer_DA__c).ASI_CRM_CN_Phone_Number__c;
            if(so.ASI_HK_CRM_Fax__c == null)   so.ASI_HK_CRM_Fax__c = CustomerMap.get(so.ASI_HK_CRM_Customer_DA__c).ASI_CRM_CN_Fax_Number__c;
            if(so.ASI_HK_CRM_Delivery_Window_Instruction__c == null)   so.ASI_HK_CRM_Delivery_Window_Instruction__c = CustomerMap.get(so.ASI_HK_CRM_Customer_DA__c).ASI_HK_CRM_Delivery_Window_Instruction__c;
            if(so.ASI_HK_CRM_Delivery_Time_1__c == null) so.ASI_HK_CRM_Delivery_Time_1__c = CustomerMap.get(so.ASI_HK_CRM_Customer_DA__c).ASI_HK_CRM_Delivery_Time_1__c;
            if(so.ASI_HK_CRM_Delivery_Time_2__c == null)  so.ASI_HK_CRM_Delivery_Time_2__c = CustomerMap.get(so.ASI_HK_CRM_Customer_DA__c).ASI_HK_CRM_Delivery_Time_2__c;
            if(so.ASI_HK_CRM_Payment_Method__c == null || so.ASI_HK_CRM_Payment_Method__c == 'N/A')  so.ASI_HK_CRM_Payment_Method__c = CustomerMap.get(so.ASI_HK_CRM_Customer_DA__c).ASI_HK_CRM_Payment_Method__c;
            if(so.ASI_HK_CRM_Instruction_txt__c == null)  so.ASI_HK_CRM_Instruction_txt__c = CustomerMap.get(so.ASI_HK_CRM_Customer_DA__c).ASI_HK_CRM_Instruction_txt__c;
            if(so.ASI_HK_CRM_Attention__c == null)   so.ASI_HK_CRM_Attention__c = CustomerMap.get(so.ASI_HK_CRM_Customer_DA__c).ASI_HK_CRM_Attention__c;
            if(so.ASI_HK_CRM_Delivery_Remarks__c == null)  so.ASI_HK_CRM_Delivery_Remarks__c = CustomerMap.get(so.ASI_HK_CRM_Customer_DA__c).ASI_HK_CRM_Delivery_Remarks__c;
            so.ASI_HK_CRM_User_D_O__c = CustomerMap.get(so.ASI_HK_CRM_Customer_DA__c).ASI_HK_CRM_User_D_O__c;
        }
    }
     
    private void updateForInstruction(ASI_HK_CRM_Sales_Order__c so) {
        String winInstType = so.ASI_HK_CRM_Delivery_Window_Instruction__c;
        //Datetime dt1 = so.ASI_HK_CRM_Delivery_Window_Time_1__c;
        //Datetime dt2 = so.ASI_HK_CRM_Delivery_Window_Time_2__c;
        //Jeffrey 13-08-2013 change Delivery time field to picklist
        string new_dt1 = so.ASI_HK_CRM_Delivery_Time_1__c;
        string new_dt2 = so.ASI_HK_CRM_Delivery_Time_2__c;
       
        String paymentMethod = so.ASI_HK_CRM_Payment_Method__c;
        if(paymentMethod == 'SALESMAN')
        {
            paymentMethod='SFollowPmt';
        }
        
        String wholeInstStr = null;
        
        if(so.ASI_HK_CRM_SYS_PA_Acct_Type__c!='Credit')
        {

            if ('Between' == winInstType) {
                if (new_dt1 != null && new_dt2 != null) 
                {
                    wholeInstStr = String.format('{0}\\{1}\\{2}\\{3}', new String[] {
                        winInstType
                        , new_dt1
                        , new_dt2
                        , paymentMethod
                    });
                }
                else if(new_dt1 != null && new_dt2 == null)
                {
                    string dt1_hr = new_dt1.mid(0,2);
                    integer dt2_hr = integer.valueof(dt1_hr) +2;
                    new_dt2=string.valueof(dt2_hr) + ':' + new_dt1.mid(3,2);
                    so.ASI_HK_CRM_Delivery_Time_2__c=new_dt2;
                    
                    wholeInstStr = String.format('{0}\\{1}\\{2}\\{3}', new String[] {
                        winInstType
                        , new_dt1
                        , new_dt2
                        , paymentMethod
                    });
                }
            } 
            else 
            {
                if (new_dt1 != null) {
                    wholeInstStr = String.format('{0}\\{1}\\{2}', new String[] {
                        winInstType
                        , new_dt1
                        , paymentMethod
                    });
                }
                else
                {
                    wholeInstStr = String.format('{0}', new String[] {
                        paymentMethod
                    });
                }
            }

        }
        else
        {
            if(paymentMethod=='N/A')
            {
                if(so.ASI_HK_CRM_Delivery_Time_1__c=='' && so.ASI_HK_CRM_Delivery_Time_2__c=='')
                {
                    
                }
                else
                {
                    if ('Between' == winInstType) 
                    {
                        if (new_dt1 != null && new_dt2 != null) 
                        {
                            wholeInstStr = String.format('{0}\\{1}\\{2}', new String[] {
                                winInstType
                                , new_dt1
                                , new_dt2
                            });
                        }
                        else if(new_dt1 != null && new_dt2 == null)
                        {
                            string dt1_hr = new_dt1.mid(0,2);
                            integer dt2_hr = integer.valueof(dt1_hr) +2;
                            new_dt2=string.valueof(dt2_hr) + ':' + new_dt1.mid(3,2);
                            so.ASI_HK_CRM_Delivery_Time_2__c=new_dt2;
                            
                            wholeInstStr = String.format('{0}\\{1}\\{2}', new String[] {
                                winInstType
                                , new_dt1
                                , new_dt2
                            });
                        }
                    }
                    else 
                    {
                        if (new_dt1 != null) {
                            wholeInstStr = String.format('{0}\\{1}', new String[] {
                                winInstType
                                , new_dt1
                            });
                        }

                    }
                }
            }
            else
            {
                if ('Between' == winInstType) 
                {
                    if (new_dt1 != null && new_dt2 != null) 
                    {
                        wholeInstStr = String.format('{0}\\{1}\\{2}\\{3}', new String[] {
                            winInstType
                            , new_dt1
                            , new_dt2
                            , paymentMethod
                        });
                    }
                    else if(new_dt1 != null && new_dt2 == null)
                    {
                        string dt1_hr = new_dt1.mid(0,2);
                        integer dt2_hr = integer.valueof(dt1_hr) +2;
                        new_dt2=string.valueof(dt2_hr) + ':' + new_dt1.mid(3,2);
                        so.ASI_HK_CRM_Delivery_Time_2__c=new_dt2;
                        
                        wholeInstStr = String.format('{0}\\{1}\\{2}\\{3}', new String[] {
                            winInstType
                            , new_dt1
                            , new_dt2
                            , paymentMethod
                        });
                    }
                } 
                else 
                {
                    if (new_dt1 != null) {
                        wholeInstStr = String.format('{0}\\{1}\\{2}', new String[] {
                            winInstType
                            , new_dt1
                            , paymentMethod
                        });
                    }
                    else
                    {
                        wholeInstStr = String.format('{0}', new String[] {
                            paymentMethod
                        });
                    }
                    
                }
            }
        
        }
        
        so.ASI_HK_CRM_Instruction_txt__c = wholeInstStr;
    }
    
    
    
    
    
    private String timeStrForInstruction(Datetime dt) {
        return leftPadWithChar(String.valueOf(dt.hour()), 2, '0') + ':' + leftPadWithChar(String.valueOf(dt.minute()), 2, '0');
    }
    
    private void updateForCustPONum(ASI_HK_CRM_Sales_Order__c so) {
        if (String.isBlank(so.ASI_HK_CRM_Cust_PO__c)) {
            Date todayDate = System.today();
            so.ASI_HK_CRM_Cust_PO__c = '' + todayDate.year() + leftPadWithChar(String.valueOf(todayDate.month()), 2, '0') + leftPadWithChar(String.valueOf(todayDate.day()), 2, '0');
        }
    }
    
    private String leftPadWithChar(String str, Integer length, String theChar) {
        return str.leftPad(length).replace(' ', theChar);
    }
    
}