public without sharing class ASI_MY_CRM_SalesOrder_Handler {
    
    public static Map<String, String> m_order_type = ASI_MY_CRM_SalesOrder_Ctrl.getOrderTypeMapping();
    
    //public static List<ASI_CRM_Dynamic_Approval_Route__c> dynamicApprovalList = ASI_MY_CRM_SalesOrder_Ctrl.getDynamicApprovalList();
    public static Map<Id, ASI_CRM_Dynamic_Approval_Route__c> m_dynamicApproval = ASI_MY_CRM_SalesOrder_Ctrl.getDynamicApprovalMap();
    
    //public static List<ASI_CRM_Fix_Approval_Route__c> fixApprovalList = ASI_MY_CRM_SalesOrder_Ctrl.getFixApprovalList();
    public static Map<String, ASI_CRM_Fix_Approval_Route__c> m_fixApproval = ASI_MY_CRM_SalesOrder_Ctrl.getFixApprovalMap();
    
    public static Map<Id, ASI_CRM_Fix_Approval_Route__c> m_sub_brand_type_fixApproval = ASI_MY_CRM_SalesOrder_Ctrl.getSub_Brand_TypeFixApprovalMap();
    
    public static Map<Id, Id> m_CODI_fixApproval = ASI_MY_CRM_SalesOrder_Ctrl.getCODI_FixApprovalMap();
    
    public static void routineBeforeInsert(List<sObject> l_new, Map<Id, sObject> m_new, List<sObject> l_old, Map<Id, sObject> m_old){
        
        List<ASI_HK_CRM_Sales_Order__c> l_sales_order = (List<ASI_HK_CRM_Sales_Order__c>)l_new;
        for(ASI_HK_CRM_Sales_Order__c sales_order : l_sales_order){
            sales_order.Name = sales_order.ASI_HK_CRM_JDE_Order_No__c;
            sales_order.ASI_CRM_Order_Status__c = 'Interfaced';
        }
        
    }
    
    public static void routineBeforeUpdate(List<sObject> l_new, Map<Id, sObject> m_new, List<sObject> l_old, Map<Id, sObject> m_old){
        
		system.debug('@@@m_dynamicApproval: '+m_dynamicApproval);        
		List<ASI_HK_CRM_Sales_Order__c> l_sales_order = (List<ASI_HK_CRM_Sales_Order__c>)l_new;
        Map<Id, ASI_HK_CRM_Sales_Order__c> m_old_sales_order = (Map<Id, ASI_HK_CRM_Sales_Order__c>)m_old;
        
        List<ASI_HK_CRM_Sales_Order__c> l_filter_code_sales_order = new List<ASI_HK_CRM_Sales_Order__c>();
        Set<Id> s_sales_order_id = new Set<Id>();    
        
        Map<Id, Set<Id>> m_s_dynamic_user = new Map<Id, Set<Id>>();
        Map<Id, Id> m_line_manager = new Map<Id, Id>();
        Map<String, List<ASI_HK_CRM_Sales_Order__c>> m_l_sales_order = new Map<String, List<ASI_HK_CRM_Sales_Order__c>>();
        
        List<ASI_HK_CRM_Sales_Order__c> l_CODI_sales_order = new List<ASI_HK_CRM_Sales_Order__c>();
        
        Set<Id> s_userId = new Set<Id>();
        for(ASI_HK_CRM_Sales_Order__c sales_order : l_sales_order){
            if(m_order_type.containsKey(sales_order.ASI_HK_CRM_JDE_Order_Type_Code__c)  &&
               ( String.isBlank(sales_order.ASI_CRM_Order_Status__c) ||  sales_order.ASI_CRM_Order_Status__c == 'Interfaced' || sales_order.ASI_CRM_Order_Status__c == 'On Hold' ||
                (sales_order.ASI_CRM_Order_Status__c == 'Pending Approval' && m_old_sales_order.get(sales_order.Id).ASI_CRM_Order_Status__c != 'Pending Approval') )){
                setApproverToNull(sales_order);
                setBrandManagerToNull(sales_order);
                serLineManagerToNull(sales_order);
                //sales_order.ASI_CRM_System_Order_Type__c = m_order_type.get(sales_order.ASI_HK_CRM_JDE_Order_Type_Code__c);
                if(m_CODI_fixApproval.containsKey(sales_order.OwnerId)){
                    l_CODI_sales_order.add(sales_order);
                }
                else{
                    if( m_order_type.get(sales_order.ASI_HK_CRM_JDE_Order_Type_Code__c) == 'Sales Order' || m_order_type.get(sales_order.ASI_HK_CRM_JDE_Order_Type_Code__c) == 'Sales Order Return' ){
                        if( String.isNotBlank(sales_order.ASI_CRM_Hold_Code__c) ){
                            if(m_order_type.get(sales_order.ASI_HK_CRM_JDE_Order_Type_Code__c) == 'Sales Order'){
                                sales_order.ASI_CRM_System_Order_Type__c = ASI_MY_CRM_SalesOrder_Ctrl.so_with_ch;
                                List<ASI_HK_CRM_Sales_Order__c> l_system_order_type_sales_order = checkContainsKey(ASI_MY_CRM_SalesOrder_Ctrl.so_with_ch, m_l_sales_order, sales_order);
                                m_l_sales_order.put(ASI_MY_CRM_SalesOrder_Ctrl.so_with_ch, l_system_order_type_sales_order);
                            }
                            else{
                                sales_order.ASI_CRM_System_Order_Type__c = ASI_MY_CRM_SalesOrder_Ctrl.sor_with_ch;
                                List<ASI_HK_CRM_Sales_Order__c> l_system_order_type_sales_order = checkContainsKey(ASI_MY_CRM_SalesOrder_Ctrl.sor_with_ch, m_l_sales_order, sales_order);
                                m_l_sales_order.put(ASI_MY_CRM_SalesOrder_Ctrl.sor_with_ch, l_system_order_type_sales_order);
                            }
                        }
                        else{
                            if(m_order_type.get(sales_order.ASI_HK_CRM_JDE_Order_Type_Code__c) == 'Sales Order'){
                                sales_order.ASI_CRM_System_Order_Type__c = ASI_MY_CRM_SalesOrder_Ctrl.so_without_ch;
                                List<ASI_HK_CRM_Sales_Order__c> l_system_order_type_sales_order = checkContainsKey(ASI_MY_CRM_SalesOrder_Ctrl.so_without_ch, m_l_sales_order, sales_order);
                                m_l_sales_order.put(ASI_MY_CRM_SalesOrder_Ctrl.so_without_ch, l_system_order_type_sales_order);
                            }
                            else{
                                sales_order.ASI_CRM_System_Order_Type__c = ASI_MY_CRM_SalesOrder_Ctrl.sor_without_ch;
                                List<ASI_HK_CRM_Sales_Order__c> l_system_order_type_sales_order = checkContainsKey(ASI_MY_CRM_SalesOrder_Ctrl.sor_without_ch, m_l_sales_order, sales_order);
                                m_l_sales_order.put(ASI_MY_CRM_SalesOrder_Ctrl.sor_without_ch, l_system_order_type_sales_order);
                            }
                        }
                    }
                    else if( m_order_type.get(sales_order.ASI_HK_CRM_JDE_Order_Type_Code__c) == 'FOC' || m_order_type.get(sales_order.ASI_HK_CRM_JDE_Order_Type_Code__c) == 'FOC Return' ){
                        if( m_order_type.get(sales_order.ASI_HK_CRM_JDE_Order_Type_Code__c) == 'FOC' ){
                            sales_order.ASI_CRM_System_Order_Type__c = ASI_MY_CRM_SalesOrder_Ctrl.foc;
                            List<ASI_HK_CRM_Sales_Order__c> l_system_order_type_sales_order = checkContainsKey(ASI_MY_CRM_SalesOrder_Ctrl.foc, m_l_sales_order, sales_order);
                            m_l_sales_order.put(ASI_MY_CRM_SalesOrder_Ctrl.foc, l_system_order_type_sales_order);
                        }
                        else{
                            sales_order.ASI_CRM_System_Order_Type__c = ASI_MY_CRM_SalesOrder_Ctrl.focr;
                            List<ASI_HK_CRM_Sales_Order__c> l_system_order_type_sales_order = checkContainsKey(ASI_MY_CRM_SalesOrder_Ctrl.focr, m_l_sales_order, sales_order);
                            m_l_sales_order.put(ASI_MY_CRM_SalesOrder_Ctrl.focr, l_system_order_type_sales_order);
                        }
                    }
                    else if(m_order_type.get(sales_order.ASI_HK_CRM_JDE_Order_Type_Code__c) == 'Debit Note'){
                        sales_order.ASI_CRM_System_Order_Type__c = ASI_MY_CRM_SalesOrder_Ctrl.dn;
                        List<ASI_HK_CRM_Sales_Order__c> l_system_order_type_sales_order = checkContainsKey(ASI_MY_CRM_SalesOrder_Ctrl.dn, m_l_sales_order, sales_order);
                        m_l_sales_order.put(ASI_MY_CRM_SalesOrder_Ctrl.dn, l_system_order_type_sales_order);
                    }
                    else if( m_order_type.get(sales_order.ASI_HK_CRM_JDE_Order_Type_Code__c) == 'Credit Note'){
                        sales_order.ASI_CRM_System_Order_Type__c = ASI_MY_CRM_SalesOrder_Ctrl.cn;
                        List<ASI_HK_CRM_Sales_Order__c> l_system_order_type_sales_order = checkContainsKey(ASI_MY_CRM_SalesOrder_Ctrl.cn, m_l_sales_order, sales_order);
                        m_l_sales_order.put(ASI_MY_CRM_SalesOrder_Ctrl.cn, l_system_order_type_sales_order);
                    }
                    s_userId.add(sales_order.OwnerId);
                    l_filter_code_sales_order.add(sales_order);
                    s_sales_order_id.add(sales_order.Id);
                }          
            }
        }
        
        system.debug('@@@m_l_sales_order: '+m_l_sales_order);
        
        //////////////////   Dynamic Approval Route   //////////////////
        if(!s_userId.isEmpty()){
            Map<Id, User> m_managerId = new Map<Id, User>([SELECT ManagerId FROM User WHERE Id IN :s_userId]);
            system.debug('@@@m_managerId: '+m_managerId);
            
            for(ASI_HK_CRM_Sales_Order__c sales_order : l_filter_code_sales_order){
                /*
                if(m_dynamicApproval.containsKey(sales_order.OwnerId)){
                    Id userId = sales_order.OwnerId;
                    Set<Id> s_dynamic_user = get_sales_order_dynamic_user(userId);
                    m_s_dynamic_user.put(sales_order.Id, s_dynamic_user);
                }
                else{
				*/
					if(m_managerId.containsKey(sales_order.OwnerId)){
                        User user = m_managerId.get(sales_order.OwnerId);
                        Id managerId = user.ManagerId;
                        if(managerId != null){
                        	Set<Id> s_dynamic_user = get_sales_order_dynamic_user(managerId);
                            m_s_dynamic_user.put(sales_order.Id, s_dynamic_user); 
                        }
                        
                        if(m_CODI_fixApproval.containsKey(sales_order.OwnerId)){
                            
                        }
                        else{
                            if(managerId != null){
                                if(m_CODI_fixApproval.containsKey(sales_order.OwnerId)){
                                	
                                }
                                else{
                                    m_line_manager.put(sales_order.Id, managerId);
                                }
                            }
                        }
                        
                    } 
                /*
                }
				*/
            }
            system.debug('@@@m_s_dynamic_user: '+m_s_dynamic_user);
        }
        //////////////////   Dynamic Approval Route   //////////////////
        
        
        //////////////////   Fix Approval Route   //////////////////
        for(String fixApproval_key : m_fixApproval.keySet()){
            system.debug('@@@fixApproval_key : '+fixApproval_key);
            ASI_CRM_Fix_Approval_Route__c fixApproval_route = m_fixApproval.get(fixApproval_key);
            if(m_l_sales_order.containsKey(fixApproval_key)){
                
                system.debug('@@@ASI_MY_CRM_SalesOrder_Ctrl.dn : '+ASI_MY_CRM_SalesOrder_Ctrl.dn);
            	List<ASI_HK_CRM_Sales_Order__c> l_system_order_type_sales_order = m_l_sales_order.get(fixApproval_key);
                if(fixApproval_key == ASI_MY_CRM_SalesOrder_Ctrl.so_without_ch ||
                   fixApproval_key == ASI_MY_CRM_SalesOrder_Ctrl.sor_without_ch ||
                   fixApproval_key == ASI_MY_CRM_SalesOrder_Ctrl.dn ||
                   fixApproval_key == ASI_MY_CRM_SalesOrder_Ctrl.cn){
                    for(ASI_HK_CRM_Sales_Order__c sales_order : l_system_order_type_sales_order){
                        Set<Id> s_approver;
                        if(m_s_dynamic_user.containsKey(sales_order.Id)){
                            s_approver = m_s_dynamic_user.get(sales_order.Id);
                        }
                        else{
                            s_approver = new Set<Id>();
                        }   
                        Decimal order_gross_amount = sales_order.ASI_CRM_Order_Gross_Amount__c != null ? sales_order.ASI_CRM_Order_Gross_Amount__c : 0;
                        order_gross_amount = order_gross_amount.abs();
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_1__c != null 
                           && fixApproval_route.ASI_CRM_CN_Approver_1__c != null
                           && order_gross_amount >= fixApproval_route.ASI_CRM_CN_Approval_Limit_1__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_1__c);
                        }
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_2__c != null 
                            && fixApproval_route.ASI_CRM_CN_Approver_2__c != null
                            && order_gross_amount >= fixApproval_route.ASI_CRM_CN_Approval_Limit_2__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_2__c);	                
                        }
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_3__c != null 
                            && fixApproval_route.ASI_CRM_CN_Approver_3__c != null
                            && order_gross_amount >= fixApproval_route.ASI_CRM_CN_Approval_Limit_3__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_3__c);
                        }
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_4__c != null
                            && fixApproval_route.ASI_CRM_CN_Approver_4__c != null 
                            && order_gross_amount >= fixApproval_route.ASI_CRM_CN_Approval_Limit_4__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_4__c);
                        }
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_5__c != null 
                            && fixApproval_route.ASI_CRM_CN_Approver_5__c != null
                            && order_gross_amount >= fixApproval_route.ASI_CRM_CN_Approval_Limit_5__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_5__c);
                        }
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_6__c != null 
                            && fixApproval_route.ASI_CRM_CN_Approver_6__c != null
                            && order_gross_amount >= fixApproval_route.ASI_CRM_CN_Approval_Limit_6__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_6__c);
                        }
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_7__c != null 
                            && fixApproval_route.ASI_CRM_CN_Approver_7__c != null 
                            && order_gross_amount >= fixApproval_route.ASI_CRM_CN_Approval_Limit_7__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_7__c);
                        }
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_8__c != null
                            && fixApproval_route.ASI_CRM_CN_Approver_8__c != null
                            && order_gross_amount >= fixApproval_route.ASI_CRM_CN_Approval_Limit_8__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_8__c);
                        }
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_9__c != null 
                            && fixApproval_route.ASI_CRM_CN_Approver_9__c != null
                            && order_gross_amount >= fixApproval_route.ASI_CRM_CN_Approval_Limit_9__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_9__c);
                        }
                        m_s_dynamic_user.put(sales_order.Id, s_approver);
                    }
                }
                else if (fixApproval_key == ASI_MY_CRM_SalesOrder_Ctrl.so_with_ch || fixApproval_key == ASI_MY_CRM_SalesOrder_Ctrl.sor_with_ch){
                    for(ASI_HK_CRM_Sales_Order__c sales_order : l_system_order_type_sales_order){
                        Set<Id> s_approver;
                        if(m_s_dynamic_user.containsKey(sales_order.Id)){
                            s_approver = m_s_dynamic_user.get(sales_order.Id);
                        }
                        else{
                            s_approver = new Set<Id>();
                        }
                        Decimal exceeded_credit_limit = sales_order.ASI_HK_CRM_Exceeded_Credit_Limit__c != null ? sales_order.ASI_HK_CRM_Exceeded_Credit_Limit__c : 0;
                        exceeded_credit_limit = exceeded_credit_limit.abs();
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_1__c != null 
                           && fixApproval_route.ASI_CRM_CN_Approver_1__c != null
                           && exceeded_credit_limit >= fixApproval_route.ASI_CRM_CN_Approval_Limit_1__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_1__c);
                        }
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_2__c != null 
                            && fixApproval_route.ASI_CRM_CN_Approver_2__c != null
                            && exceeded_credit_limit >= fixApproval_route.ASI_CRM_CN_Approval_Limit_2__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_2__c);	                
                        }
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_3__c != null 
                            && fixApproval_route.ASI_CRM_CN_Approver_3__c != null
                            && exceeded_credit_limit >= fixApproval_route.ASI_CRM_CN_Approval_Limit_3__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_3__c);
                        }
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_4__c != null
                            && fixApproval_route.ASI_CRM_CN_Approver_4__c != null 
                            && exceeded_credit_limit >= fixApproval_route.ASI_CRM_CN_Approval_Limit_4__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_4__c);
                        }
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_5__c != null 
                            && fixApproval_route.ASI_CRM_CN_Approver_5__c != null
                            && exceeded_credit_limit >= fixApproval_route.ASI_CRM_CN_Approval_Limit_5__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_5__c);
                        }
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_6__c != null 
                            && fixApproval_route.ASI_CRM_CN_Approver_6__c != null
                            && exceeded_credit_limit >= fixApproval_route.ASI_CRM_CN_Approval_Limit_6__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_6__c);
                        }
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_7__c != null 
                            && fixApproval_route.ASI_CRM_CN_Approver_7__c != null 
                            && exceeded_credit_limit >= fixApproval_route.ASI_CRM_CN_Approval_Limit_7__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_7__c);
                        }
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_8__c != null
                            && fixApproval_route.ASI_CRM_CN_Approver_8__c != null
                            && exceeded_credit_limit >= fixApproval_route.ASI_CRM_CN_Approval_Limit_8__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_8__c);
                        }
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_9__c != null 
                            && fixApproval_route.ASI_CRM_CN_Approver_9__c != null
                            && exceeded_credit_limit >= fixApproval_route.ASI_CRM_CN_Approval_Limit_9__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_9__c);
                        }   
                        m_s_dynamic_user.put(sales_order.Id, s_approver);
                    }
                }
                else if(fixApproval_key == ASI_MY_CRM_SalesOrder_Ctrl.foc || fixApproval_key == ASI_MY_CRM_SalesOrder_Ctrl.focr){
                    for(ASI_HK_CRM_Sales_Order__c sales_order : l_system_order_type_sales_order){
                        Set<Id> s_approver;
                        if(m_s_dynamic_user.containsKey(sales_order.Id)){
                            s_approver = m_s_dynamic_user.get(sales_order.Id);
                        }
                        else{
                            s_approver = new Set<Id>();
                        }
                        Decimal total_order_quantity = sales_order.ASI_MY_CRM_Total_Order_Quantity__c != null ? sales_order.ASI_MY_CRM_Total_Order_Quantity__c : 0;
                        total_order_quantity = total_order_quantity.abs();
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_1__c != null 
                           && fixApproval_route.ASI_CRM_CN_Approver_1__c != null
                           && total_order_quantity  >= fixApproval_route.ASI_CRM_CN_Approval_Limit_1__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_1__c);
                        }
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_2__c != null 
                            && fixApproval_route.ASI_CRM_CN_Approver_2__c != null
                            && total_order_quantity  >= fixApproval_route.ASI_CRM_CN_Approval_Limit_2__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_2__c);	                
                        }
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_3__c != null 
                            && fixApproval_route.ASI_CRM_CN_Approver_3__c != null
                            && total_order_quantity  >= fixApproval_route.ASI_CRM_CN_Approval_Limit_3__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_3__c);
                        }
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_4__c != null
                            && fixApproval_route.ASI_CRM_CN_Approver_4__c != null 
                            && total_order_quantity  >= fixApproval_route.ASI_CRM_CN_Approval_Limit_4__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_4__c);
                        }
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_5__c != null 
                            && fixApproval_route.ASI_CRM_CN_Approver_5__c != null
                            && total_order_quantity  >= fixApproval_route.ASI_CRM_CN_Approval_Limit_5__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_5__c);
                        }
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_6__c != null 
                            && fixApproval_route.ASI_CRM_CN_Approver_6__c != null
                            && total_order_quantity  >= fixApproval_route.ASI_CRM_CN_Approval_Limit_6__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_6__c);
                        }
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_7__c != null 
                            && fixApproval_route.ASI_CRM_CN_Approver_7__c != null 
                            && total_order_quantity  >= fixApproval_route.ASI_CRM_CN_Approval_Limit_7__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_7__c);
                        }
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_8__c != null
                            && fixApproval_route.ASI_CRM_CN_Approver_8__c != null
                            && total_order_quantity  >= fixApproval_route.ASI_CRM_CN_Approval_Limit_8__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_8__c);
                        }
                        if( fixApproval_route.ASI_CRM_CN_Approval_Limit_9__c != null 
                            && fixApproval_route.ASI_CRM_CN_Approver_9__c != null
                            && total_order_quantity  >= fixApproval_route.ASI_CRM_CN_Approval_Limit_9__c ){
                            s_approver.add(fixApproval_route.ASI_CRM_CN_Approver_9__c);
                        }   
                        m_s_dynamic_user.put(sales_order.Id, s_approver);   
                    }
                }
            }
        }
        system.debug('@@@m_s_dynamic_user2: '+m_s_dynamic_user);
        //////////////////   Fix Approval Route   //////////////////
        
        
        
        Map<Id, Map<Id, Decimal>> m_sales_order_additionalFOC = getSalesOrderItemAdditionalFOC(s_sales_order_id);
        system.debug('@@@m_sales_order_additionalFOC: '+m_sales_order_additionalFOC);
        for(Id recordId : m_sales_order_additionalFOC.keyset()){
            Map<Id, Decimal> m_additionalFOC = m_sales_order_additionalFOC.get(recordId);
            Set<Id> s_approver;
            if(m_s_dynamic_user.containsKey(recordId)){
                s_approver = m_s_dynamic_user.get(recordId);
            }
            else{
                s_approver = new Set<Id>();
            }
            
            for(Id key : m_additionalFOC.keyset()){
				system.debug('@@@m_additionalFOC key: '+key);
                system.debug('@@@m_additionalFOC value: '+m_additionalFOC.get(key)); 
                
                if(m_sub_brand_type_fixApproval.containsKey(key)){
                    ASI_CRM_Fix_Approval_Route__c sub_brand_type_fix_approval_route = m_sub_brand_type_fixApproval.get(key);
                    Decimal sub_brand_total_quantity = m_additionalFOC.get(key);
                    
                    system.debug('@@@sub_brand_total_quantity: '+sub_brand_total_quantity);
                    system.debug('@@@ASI_CRM_CN_Approval_Limit_1__c: '+sub_brand_type_fix_approval_route.ASI_CRM_CN_Approval_Limit_1__c);
                    if(	sub_brand_type_fix_approval_route.ASI_CRM_CN_Approval_Limit_1__c != null &&
                        sub_brand_type_fix_approval_route.ASI_CRM_CN_Approver_1__c != null &&
                        sub_brand_total_quantity > sub_brand_type_fix_approval_route.ASI_CRM_CN_Approval_Limit_1__c){
                            
                        system.debug('@@@sub_brand_total_quantity > sub_brand_type_fix_approval_route.ASI_CRM_CN_Approval_Limit_1__c');
                            
                        if(!s_approver.contains(sub_brand_type_fix_approval_route.ASI_CRM_CN_Approver_1__c)){
                            s_approver.add(sub_brand_type_fix_approval_route.ASI_CRM_CN_Approver_1__c);
                        }   
                    }
                    
                    if( sub_brand_type_fix_approval_route.ASI_CRM_CN_Approval_Limit_2__c != null &&
                        sub_brand_type_fix_approval_route.ASI_CRM_CN_Approver_2__c != null &&
                        sub_brand_total_quantity > sub_brand_type_fix_approval_route.ASI_CRM_CN_Approval_Limit_2__c){
                        
                        if(!s_approver.contains(sub_brand_type_fix_approval_route.ASI_CRM_CN_Approver_2__c)){
                            s_approver.add(sub_brand_type_fix_approval_route.ASI_CRM_CN_Approver_2__c);
                        }
                            
                    }
                    
                    if( sub_brand_type_fix_approval_route.ASI_CRM_CN_Approval_Limit_3__c != null &&
                        sub_brand_type_fix_approval_route.ASI_CRM_CN_Approver_3__c != null &&
                        sub_brand_total_quantity > sub_brand_type_fix_approval_route.ASI_CRM_CN_Approval_Limit_3__c){
                        
                        if(!s_approver.contains(sub_brand_type_fix_approval_route.ASI_CRM_CN_Approver_3__c)){
                            s_approver.add(sub_brand_type_fix_approval_route.ASI_CRM_CN_Approver_3__c);
                        }
                            
                    }
                }
                
            }
            
            m_s_dynamic_user.put(recordId, s_approver);
            
        }
		
        
        Map<Id, Set<Id>> m_sales_order_brand_manager = getSalesOrderBrandManager(s_sales_order_id);
        assignApproverAndBrandManager(l_filter_code_sales_order, m_s_dynamic_user, m_sales_order_brand_manager, m_line_manager);
        
        
        //////////////////   CODI Approval Route   //////////////////
        for(ASI_HK_CRM_Sales_Order__c sales_order : l_CODI_sales_order){
            sales_order.ASI_HK_CRM_SYS_Approver_1__c = m_CODI_fixApproval.get(sales_order.OwnerId);
        } 
        
    }
    
    public static void assignApproverAndBrandManager(List<ASI_HK_CRM_Sales_Order__c> l_sales_order, Map<Id, Set<Id>> m_s_dynamic_user, Map<Id, Set<Id>> m_sales_order_brand_manager, Map<Id, Id> m_line_manager){
        for(ASI_HK_CRM_Sales_Order__c sales_order : l_sales_order){
            //if(m_s_dynamic_user.containsKey(sales_order.Id)){
                
                if(m_s_dynamic_user.containsKey(sales_order.Id)){
                    Integer i = 1;
                    Set<Id> s_approver = m_s_dynamic_user.get(sales_order.Id);
                    for(Id approver : s_approver){
                        String sysApproverField = 'ASI_HK_CRM_SYS_Approver_' + i +'__c';
                        sales_order.put(sysApproverField, approver);
                        i++;
                    }
                }
                
                if(m_sales_order_brand_manager.containsKey(sales_order.Id)){
                    Integer j = 1;
                	Set<Id> s_brand_manager = m_sales_order_brand_manager.get(sales_order.Id);
                    for(Id brand_manager_Id : s_brand_manager){ 
                        String brandManagerField = 'ASI_CRM_Brand_Manager_' + j +'__c';
                        sales_order.put(brandManagerField, brand_manager_Id);
                        j++;
                    }    
                }
            
                if(m_line_manager.containsKey(sales_order.Id)){
                    sales_order.ASI_CRM_Line_Manager__c = m_line_manager.get(sales_order.Id);
                }
            	
            //}            
        }
    }
    
    
    
    public static void routineAfterUpdate(List<sObject> l_new, Map<Id, sObject> m_new, List<sObject> l_old, Map<Id, sObject> m_old){
        
        List<ASI_HK_CRM_Sales_Order__c> l_sales_order = (List<ASI_HK_CRM_Sales_Order__c>)l_new;
        Map<Id, ASI_HK_CRM_Sales_Order__c> m_sales_order = (Map<Id, ASI_HK_CRM_Sales_Order__c>)m_old;
        
        List<ASI_HK_CRM_Sales_Order__c> l_sales_order_approval = new List<ASI_HK_CRM_Sales_Order__c>();
        
        for(ASI_HK_CRM_Sales_Order__c sales_order : l_sales_order){
            ASI_HK_CRM_Sales_Order__c old_sales_order = m_sales_order.get(sales_order.Id);
            if(old_sales_order.ASI_CRM_ETL_Completed__c  != sales_order.ASI_CRM_ETL_Completed__c  && sales_order.ASI_CRM_ETL_Completed__c ){
                l_sales_order_approval.add(sales_order);
            }
        }
        
        
        system.debug('@@@l_sales_order_approval: '+l_sales_order_approval);
        if(!l_sales_order_approval.isEmpty()){
            
            List<Approval.ProcessSubmitRequest> itm_reqList = new List<Approval.ProcessSubmitRequest>();
            for(ASI_HK_CRM_Sales_Order__c sales_order : l_sales_order_approval){
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                //req1.setComments('Submitting request for approval.');
                req1.setObjectId(sales_order.Id);
                
                // Submit on behalf of a specific submitter
                req1.setSubmitterId(sales_order.OwnerId); 
                
                // Submit the record to specific process and skip the criteria evaluation
                req1.setProcessDefinitionNameOrId('ASI_MY_CRM_SO_Submit_Approval');
                req1.setSkipEntryCriteria(true);
                itm_reqList.add(req1);
            }
            
            // Submit the approval request
            Approval.ProcessResult[] result = Approval.process(itm_reqList);
            
        }
        
        
        
    }
    
    public static Set<Id> get_sales_order_dynamic_user(Id userId){
        
        Boolean isRun = true;
        Set<Id> s_dynamic_user = new Set<Id>();
        
        while (isRun) {
            if(m_dynamicApproval.containsKey(userId)){
                system.debug('@@@get_sales_order_dynamic_user: '+userId);
                ASI_CRM_Dynamic_Approval_Route__c dynamicApproval = m_dynamicApproval.get(userId);
                s_dynamic_user.add(userId);
                if(dynamicApproval.ASI_CRM_End_of_Dynamic_Route__c){
                    isRun = false;
                }
                else{
                    userId = dynamicApproval.ASI_CRM_Manager_ID__c;
                }
            }
            else{
                isRun = false;
            }
        }
        
        return s_dynamic_user;
        
    }
    
    public static Map<Id, Map<Id, Decimal>> getSalesOrderItemAdditionalFOC(Set<Id> s_sales_order_id){
        Map<Id, Map<Id, Decimal>> m_sales_order_additionalFOC = new Map<Id, Map<Id, Decimal>>();
        Map<Id, Map<Id, Integer>> m_sales_order_normal_so_item = new Map<Id, Map<Id, Integer>>();
        
        if(!s_sales_order_id.isEmpty()){
            
            AggregateResult[] normal_so_item_groupedResults =  [SELECT ASI_HK_CRM_Sales_Order__c, ASI_CRM_Sub_Brand__c, SUM(ASI_HK_CRM_Quantity__c) total_Quantity
                                                                FROM ASI_HK_CRM_Sales_Order_Item__c
                                                                WHERE ASI_HK_CRM_Sales_Order__c IN :s_sales_order_id
                                                                AND ASI_CRM_System_Item_Type__c = 'Normal SO Item'
                                                                GROUP BY ASI_HK_CRM_Sales_Order__c, ASI_CRM_Sub_Brand__c];
            
            AggregateResult[] foc_so_item_groupedResults =  [SELECT ASI_HK_CRM_Sales_Order__c, ASI_CRM_Sub_Brand__c, SUM(ASI_HK_CRM_Quantity__c) total_Quantity
                                                             FROM ASI_HK_CRM_Sales_Order_Item__c
                                                             WHERE ASI_HK_CRM_Sales_Order__c IN :s_sales_order_id
                                                             AND (ASI_CRM_System_Item_Type__c = 'Add FOC' OR ASI_CRM_System_Item_Type__c = 'FOC')
                                                             GROUP BY ASI_HK_CRM_Sales_Order__c, ASI_CRM_Sub_Brand__c];
            
            for(AggregateResult ar : normal_so_item_groupedResults){
                Id sales_order_id = (Id) ar.get('ASI_HK_CRM_Sales_Order__c');
                Id sub_brand_Id = (Id) ar.get('ASI_CRM_Sub_Brand__c');
                Integer total_Quantity = Integer.valueOf(ar.get('total_Quantity'));
                Map<Id, Integer> m_normal_so_item;
                if(m_sales_order_normal_so_item.containsKey(sales_order_id)){
                    m_normal_so_item = m_sales_order_normal_so_item.get(sales_order_id);
                    m_normal_so_item.put(sub_brand_Id, total_Quantity);
                }
                else{
                    m_normal_so_item = new Map<Id, Integer>();
                    m_normal_so_item.put(sub_brand_Id, total_Quantity);
                }
                m_sales_order_normal_so_item.put(sales_order_id, m_normal_so_item);
            }
            

            for(AggregateResult ar : foc_so_item_groupedResults){
                Id sales_order_id = (Id) ar.get('ASI_HK_CRM_Sales_Order__c');
                Id sub_brand_Id = (Id) ar.get('ASI_CRM_Sub_Brand__c');
                Integer total_Quantity = Integer.valueOf(ar.get('total_Quantity'));
                Map<Id, Decimal> m_additionalFOC;
                if(m_sales_order_additionalFOC.containsKey(sales_order_id)){
                    m_additionalFOC = m_sales_order_additionalFOC.get(sales_order_id);
                    //m_additionalFOC.put(sub_brand_Id, total_Quantity);
                }
                else{
                    m_additionalFOC = new Map<Id, Decimal>();
                    //m_additionalFOC.put(sub_brand_Id, total_Quantity);
                }
                Integer normal_so_item_qty = 0;
                if(m_sales_order_normal_so_item.containsKey(sales_order_id)){
                    Map<Id, Integer> m_normal_so_item = m_sales_order_normal_so_item.get(sales_order_id);
                    normal_so_item_qty = m_normal_so_item.containsKey(sub_brand_Id) ? m_normal_so_item.get(sub_brand_Id) : 0;
                }

                Decimal foc_qty = 0;
                if(normal_so_item_qty > 0){
                    foc_qty = (Double.valueOf(total_Quantity)  * 12.0)/ Double.valueOf(normal_so_item_qty);
                }
                else{
                    foc_qty = total_Quantity;
                }
                
                m_additionalFOC.put(sub_brand_Id, foc_qty);
                m_sales_order_additionalFOC.put(sales_order_id, m_additionalFOC);
            }
            
        }
        
        return m_sales_order_additionalFOC;
    }
    
    public static Map<Id, Set<Id>> getSalesOrderBrandManager(Set<Id> s_sales_order_id){
        Map<Id, Set<Id>> m_sales_order_brand_manager = new Map<Id, Set<Id>>();
        
        if(!s_sales_order_id.isEmpty()){
            List<ASI_HK_CRM_Sales_Order_Item__c> l_Sales_Order_Item =  [SELECT ASI_HK_CRM_Sales_Order__c, ASI_CRM_MY_Brand_Manager__c
                                                                        FROM ASI_HK_CRM_Sales_Order_Item__c
                                                                        WHERE ASI_HK_CRM_Sales_Order__c IN :s_sales_order_id
                                                                        AND ASI_CRM_System_Item_Type__c = 'Premium Item'
                                                                        AND ASI_CRM_MY_Brand_Manager__c != null];

            for(ASI_HK_CRM_Sales_Order_Item__c sales_order_item : l_Sales_Order_Item){
                Id sales_order_id = sales_order_item.ASI_HK_CRM_Sales_Order__c;
                Set<Id> s_brand_manager_Id;
                if(m_sales_order_brand_manager.containsKey(sales_order_id)){
                    s_brand_manager_Id = m_sales_order_brand_manager.get(sales_order_id);
                    s_brand_manager_Id.add(sales_order_item.ASI_CRM_MY_Brand_Manager__c);
                }
                else{
                    s_brand_manager_Id = new Set<Id>();
                    s_brand_manager_Id.add(sales_order_item.ASI_CRM_MY_Brand_Manager__c);
                }
                m_sales_order_brand_manager.put(sales_order_id, s_brand_manager_Id);
            }
            
        }
        
        return m_sales_order_brand_manager;
    }
    
    public static List<ASI_HK_CRM_Sales_Order__c> checkContainsKey(String key, Map<String, List<ASI_HK_CRM_Sales_Order__c>> m_l_sales_order, ASI_HK_CRM_Sales_Order__c sales_order){
        
        List<ASI_HK_CRM_Sales_Order__c> l_system_order_type_sales_order;
        if(m_l_sales_order.containsKey(key)){
            l_system_order_type_sales_order = m_l_sales_order.get(key);
            l_system_order_type_sales_order.add(sales_order);
        }
        else{
            l_system_order_type_sales_order = new List<ASI_HK_CRM_Sales_Order__c>();
            l_system_order_type_sales_order.add(sales_order);
        }
        
        return l_system_order_type_sales_order;
        
    }
    
    public static void setApproverToNull(ASI_HK_CRM_Sales_Order__c sales_order){
        sales_order.ASI_HK_CRM_SYS_Approver_1__c = null;
        sales_order.ASI_HK_CRM_SYS_Approver_2__c = null;
        sales_order.ASI_HK_CRM_SYS_Approver_3__c = null;
        sales_order.ASI_HK_CRM_SYS_Approver_4__c = null;
        sales_order.ASI_HK_CRM_SYS_Approver_5__c = null;
        sales_order.ASI_HK_CRM_SYS_Approver_6__c = null;
        sales_order.ASI_HK_CRM_SYS_Approver_7__c = null;
        sales_order.ASI_HK_CRM_SYS_Approver_8__c = null;
        sales_order.ASI_HK_CRM_SYS_Approver_9__c = null;
    }
    
    public static void setBrandManagerToNull(ASI_HK_CRM_Sales_Order__c sales_order){
        sales_order.ASI_CRM_Brand_Manager_1__c = null;
        sales_order.ASI_CRM_Brand_Manager_2__c = null;
        sales_order.ASI_CRM_Brand_Manager_3__c = null;
    }
    
    public static void serLineManagerToNull(ASI_HK_CRM_Sales_Order__c sales_order){
        sales_order.ASI_CRM_Line_Manager__c = null;
    }
    
}