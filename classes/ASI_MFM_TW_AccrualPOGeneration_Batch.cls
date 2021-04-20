/*Filename:        ASI_MFM_TW_AccrualPOGeneration_Batch.cls
* Author:          Trophy Chen (Introv Limited)
* Purpose:         Auto generate PO based on PO Line
* Created Date:    2017/07/01
*
* History
* -----------------------------------------------------------------------------
*/
global class ASI_MFM_TW_AccrualPOGeneration_Batch implements Database.Batchable<sObject> ,Database.Stateful
{
    global Id supplierId;   
    global Date targetMonthStartDate;
    global Date targetMonthEndDate;
    global String  fiscalYear;
    global String POOwnerId;
    global String PrefixId;
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String emptyQuery = 'SELECT Id FROM  ASI_MFM_Plan__c WHERE Id =null ';
        Date targetDate;
        Date today = Date.today();
        Integer genDay ;
        
        ASI_MFM_Setting__c   TWMFMSetting = ASI_MFM_Setting__c.getInstance ();
        if(TWMFMSetting!=null && TWMFMSetting.ASI_MFM_TW_Today__c  !=null){
            today = TWMFMSetting.ASI_MFM_TW_Today__c ;
        }
        if(TWMFMSetting!=null && TWMFMSetting.ASI_MFM_TW_Accrual_PO_Generation_Day__c   !=null){
            genDay = Integer.valueOf(TWMFMSetting.ASI_MFM_TW_Accrual_PO_Generation_Day__c);
        }
        system.debug('**Accrual PO Batch: Today='+today+'; Generation Day='+genDay);
        
        //Only when Generation Day = Today.Day() will the system run the generation actions:
        if(genDay==null){
            system.debug('**Accrual PO Batch: Missing generation date information');
            return Database.getQueryLocator(emptyQuery);
        }else if(today.day()!=genDay){
            system.debug('**Accrual PO Batch: Today is not the generation date');
            return Database.getQueryLocator(emptyQuery);
        }
        
        
        targetDate = today.addMonths(-1);       
        targetMonthStartDate = Date.newInstance(targetDate.year(), targetDate.month() , 1);
        targetMonthEndDate = Date.newInstance(targetDate.year(), targetDate.month() , Date.daysInMonth(targetDate.year(), targetDate.month()));
        system.debug('**Accrual PO Batch: Target Month:'+targetMonthStartDate+' - '+ targetMonthEndDate);
        fiscalYear =getStrFiscalYear(targetDate);
        system.debug('**Accrual PO Batch: Fiscal Year:'+fiscalYear);
        
        //Update: pre-define a owner for all accrual POs:
        //Only when the po owner Id is not null and the prefix for owner exist, will the system run the generation:
        if(TWMFMSetting!=null && !String.isEmpty(TWMFMSetting.ASI_MFM_TW_Accrual_PO_Owner_ID__c ) ){
            User owner;
            try{
                owner = [SELECT Id, UserRoleId, UserRole.DeveloperName FROM User WHERE Id =:TWMFMSetting.ASI_MFM_TW_Accrual_PO_Owner_ID__c LIMIT 1];
                POOwnerId = owner.Id;
                
                ASI_MFM_Role_Prefix_Relationship__c  owner_PrefixLine = new ASI_MFM_Role_Prefix_Relationship__c ();
                
                owner_PrefixLine = [SELECT Id, name, ASI_MFM_Prefix__c ,ASI_MFM_Role_Name__c  FROM ASI_MFM_Role_Prefix_Relationship__c 
                                    WHERE ASI_MFM_Role_Name__c =: owner.UserRole.DeveloperName AND ASI_MFM_Prefix__r.ASI_MFM_Module__c ='Accrual PO' AND ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c =:fiscalYear 
                                    AND ASI_MFM_Prefix__r.RecordTypeId =:Global_RecordTypeCache.getRTId('ASI_MFM_Prefix__cASI_MFM_TW_Prefix') AND ASI_MFM_Prefix__r.ASI_MFM_Inactive__c =false 
                                    ORDER BY CreatedDate DESC LIMIT 1];
                PrefixId = owner_PrefixLine.ASI_MFM_Prefix__c;
            }catch(exception e){
                system.debug('**Accrual PO Batch: Cannot find the user. The User Id is incorrect! Or missing prefix for the owner');
            }
        }
        if(String.isEmpty(POOwnerId) || String.isEmpty(PrefixId)){
            system.debug('**Accrual PO Batch: Missing Owner Id in custom setting or id is incorrect! Or Missing prefix for the owner');
            return Database.getQueryLocator(emptyQuery);
        }
        
        system.debug('**Accrual PO Batch: POOwnerId='+POOwnerId+'; PrefixId='+PrefixId);
        
        Account supplier;
        try{
            supplier = [SELECT Id, name FROM Account WHERE ASI_MFM_Customer_Supplier_Number__c ='99999' AND RecordTypeId=:Global_RecordTypeCache.getRTId('AccountASI_MFM_TW_Supplier') LIMIT 1];
        }catch (exception e){
            system.debug('**Accrual PO Batch: Missing TW Supplier for PO gneration');
            return Database.getQueryLocator(emptyQuery);
        }
        supplierId = supplier.Id;
        
        String soqlQuery = 'SELECT Id, name, ASI_MFM_Error_Log__c, ASI_MFM_Start_Date__c, ASI_MFM_End_Date__c, ASI_MFM_TW_Related_PAF__c, ASI_MFM_TW_Related_PAF__r.ASI_HK_CRM_PAF_Status__c, ownerId, owner.UserRole.DeveloperName  FROM  ASI_MFM_Plan__c ';
        soqlQuery+=' WHERE (RecordTypeId =\''+ Global_RecordTypeCache.getRTId('ASI_MFM_Plan__cASI_MFM_TW_Plan_Read_Only') +'\' OR RecordTypeId =\''+ Global_RecordTypeCache.getRTId('ASI_MFM_Plan__cASI_MFM_TW_Plan')+'\' )';
        soqlQuery+=' AND ASI_MFM_Status__c =\'Final\' ';
        soqlQuery+=' AND ASI_MFM_End_Date__c >='+getQueryDateStr(targetMonthStartDate)+' AND ASI_MFM_Start_Date__c <='+getQueryDateStr(targetMonthEndDate)+' ';
        system.debug('**Accrual PO Batch: soqlQuery:' + soqlQuery);
        
        return Database.getQueryLocator(soqlQuery);
    }
    
    
    
    
    global void execute(Database.BatchableContext BC, List<ASI_MFM_Plan__c> listPlan)
    {
        ASI_MFM_Settings__c mfmSetting = [select id, ASI_MFM_TW_Accrual_PO_Generation_Day__c, ASI_MFM_TW_Post_G_L_Date__c,ASI_MFM_TW_Today__c from ASI_MFM_Settings__c where recordtype.DeveloperName = 'ASI_MFM_TW_Setting' limit 1];
        Date PostGLDate = system.today();
        if(mfmSetting.ASI_MFM_TW_Post_G_L_Date__c!=null){
            PostGLDate = mfmSetting.ASI_MFM_TW_Post_G_L_Date__c;
        }
        
        system.debug('**Accrual PO Batch: listPlan.size()='+listPlan.size());
        
        //Dulplication check with existing PO. If existed, bypass PO generation for the corresponding bucket:
        Map<String, ASI_MFM_PO__c> map_genKey_ExistedPO = new Map<String, ASI_MFM_PO__c>();
        List<ASI_MFM_PO__c> PODuplicationCheckList  = new List<ASI_MFM_PO__c>();
        PODuplicationCheckList =[SELECT Id, name, ASI_MFM_PO_Start_Date__c , ASI_MFM_PO_End_Date__c, ASI_MFM_TW_Auto_Generation_Key__c  FROM  ASI_MFM_PO__c 
                                 WHERE ASI_MFM_Accrual_PO__c = true AND (RecordTypeId =:Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TW_PO') OR RecordTypeId =:Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TW_PO_Read_Only') ) 
                                 AND ASI_MFM_PO_Start_Date__c=:targetMonthStartDate AND ASI_MFM_PO_End_Date__c=:targetMonthEndDate
                                 AND ASI_MFM_TW_Auto_Generation_Key__c != null AND ASI_MFM_TW_Auto_Generation_Key__c!=''];
        system.debug('**Accrual PO Batch: PODuplicationCheckList.size()='+PODuplicationCheckList.size());
        for(ASI_MFM_PO__c po :PODuplicationCheckList){
            map_genKey_ExistedPO.put(po.ASI_MFM_TW_Auto_Generation_Key__c, po);
        }
        
        Set<Id> set_ValidPlanId = new Set<Id>();
        map<Id, ASI_MFM_Plan__c> map_IdPlan = new map<Id, ASI_MFM_Plan__c>();
        map<Id, String> map_PlanId_roleName = new map<Id, String>();
        map<Id, Id> map_planId_POPrefixId = new map<Id, Id>();
        
        //Use "ASI_MFM_TW_Auto_Generation_Key__c" to exclude the plans that have been generated AND "ASI_MFM_TW_Related_PAF__r.ASI_HK_CRM_PAF_Status__c" to exculde PAF-not-fianl plans:
        for(ASI_MFM_Plan__c  plan : listPlan){
            String genKey = '';
            if(plan.ASI_MFM_TW_Related_PAF__c == null){
                genKey+='PLAN'+plan.Id+targetMonthStartDate.year()+(''+targetMonthStartDate.month()).leftPad(2,'0');
            }else{
                genKey+='PAFX'+plan.Id+targetMonthStartDate.year()+(''+targetMonthStartDate.month()).leftPad(2,'0');
            }
            system.debug('**Accrual PO Batch: genKey='+genKey);
            if(map_genKey_ExistedPO.get(genKey)==null){
                //Exclude the plan whose PAF is not final:
                if(plan.ASI_MFM_TW_Related_PAF__c!=null && plan.ASI_MFM_TW_Related_PAF__r.ASI_HK_CRM_PAF_Status__c=='Final'){
                    map_IdPlan.put(plan.Id, plan);
                    map_PlanId_roleName.put(plan.Id, plan.owner.UserRole.DeveloperName);
                }else if(plan.ASI_MFM_TW_Related_PAF__c==null){
                    map_IdPlan.put(plan.Id, plan);
                    map_PlanId_roleName.put(plan.Id, plan.owner.UserRole.DeveloperName);   
                }
            }
        }
        system.debug('**Accrual PO Batch: map_PlanId_roleName='+map_PlanId_roleName);
        
        if(map_IdPlan.size()>0){
            //Query the matching Plan Item:
            List<ASI_MFM_Plan_Line_Item__c > listPlanLine = new List<ASI_MFM_Plan_Line_Item__c>();
            Map<ID, ASI_MFM_Plan_Line_Item__c> planLineMap = new Map<ID, ASI_MFM_Plan_Line_Item__c>();
            Map<Id ,List<ASI_MFM_Plan_Line_Item__c>> map_PAFPlan_Lines = new Map<Id ,List<ASI_MFM_Plan_Line_Item__c>>();
            Map<Id ,List<ASI_MFM_Plan_Line_Item__c>> map_DirectPlan_Lines = new Map<Id ,List<ASI_MFM_Plan_Line_Item__c>>();
            
            listPlanLine = [SELECT Id, name, ASI_MFM_Plan__c, ASI_MFM_Plan__r.ASI_MFM_TW_Related_PAF__c , ASI_MFM_A_C_Code__c, ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c , ASI_MFM_Customer_Name__c, ASI_MFM_Sub_brand_Code__c, ASI_MFM_Sub_Brand_Code_Only__c, 
                            ASI_MFM_Sub_Brand_Code_Name__c, ASI_MFM_TW_Related_PAF_Item__c, ASI_MFM_List_Item_Description__c,  ASI_MFM_Customer_Name__r.ASI_MFM_Channel__c, ASI_MFM_Month_1_Cost__c, ASI_MFM_Month_2_Cost__c, ASI_MFM_Month_3_Cost__c, ASI_MFM_Month_4_Cost__c, ASI_MFM_Month_5_Cost__c, ASI_MFM_Month_6_Cost__c, 
                            ASI_MFM_Month_7_Cost__c, ASI_MFM_Month_8_Cost__c, ASI_MFM_Month_9_Cost__c, ASI_MFM_Month_10_Cost__c, ASI_MFM_Month_11_Cost__c, ASI_MFM_Month_12_Cost__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_Target_Volume_Qty__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Per_Bottle_w_VAT__c, 
                            ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P1__c,ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P2__c,ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P3__c,ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P4__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P5__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P6__c, 
                            ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P7__c,ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P8__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P9__c,ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P10__c,ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P11__c,ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Amounts_w_VAT_P12__c, 
                            ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P1__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P2__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P3__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P4__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P5__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P6__c, 
                            ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P7__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P8__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P9__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P10__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P11__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Target_Volume_Qty_P12__c, 
                            ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P1__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P2__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P3__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P4__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P5__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P6__c, 
                            ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P7__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P8__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P9__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P10__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P11__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume_P12__c, 
                            ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_FOC_Volume__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_or_FOC__c, ASI_MFM_A_C_Code__r.ASI_CRM_Default_For__c, ASI_MFM_TW_Related_PAF_Item__r.RecordTypeId,ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Start_Date__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_End_Date__c, 
                            ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_CRM_Valid_Invoice__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Contracted_Item__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Expenses_Product__c, ASI_MFM_Unit_Cost__c,ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c, ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c  
                            FROM ASI_MFM_Plan_Line_Item__c
                            WHERE  (ASI_MFM_Plan__c  in :map_IdPlan.keySet()) AND (NOT  (( ASI_MFM_Plan__r.ASI_MFM_Prefix__r.Plan_Type__c = 'Fixed Assets' OR ASI_MFM_Plan__r.ASI_MFM_Prefix__r.Plan_Type__c = 'Handling Charge' OR ASI_MFM_Plan__r.ASI_MFM_Prefix__r.Plan_Type__c = 'Structure Cost' ) 
                                                                                         AND ASI_MFM_Customer_Name__r.RecordTypeId = :Global_RecordTypeCache.getRTId('AccountASI_MFM_TW_Customer') ) )  
                            ORDER BY Name ASC
                           ]; //AND ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c ='Total A&D'
            
            if(listPlanLine!=null && listPlanLine.size()>0 ){
                for(ASI_MFM_Plan_Line_Item__c planLine :listPlanLine){
                    //Plan converted from PAF:
                    if( planLine.ASI_MFM_Plan__r.ASI_MFM_TW_Related_PAF__c!=null ){
                        if(planLine.ASI_MFM_TW_Related_PAF_Item__c != null ){
                            if(map_PAFPlan_Lines.get(planLine.ASI_MFM_Plan__c)==null){
                                map_PAFPlan_Lines.put(planLine.ASI_MFM_Plan__c, new List<ASI_MFM_Plan_Line_Item__c>{planLine});
                            }else{
                                map_PAFPlan_Lines.get(planLine.ASI_MFM_Plan__c).add(planLine);
                            }
                        }
                    }
                    //Plan directly created :
                    else{
                        if(planLine.ASI_MFM_TW_Related_PAF_Item__c == null ){
                            if(map_DirectPlan_Lines.get(planLine.ASI_MFM_Plan__c)==null){
                                map_DirectPlan_Lines.put(planLine.ASI_MFM_Plan__c, new List<ASI_MFM_Plan_Line_Item__c>{planLine});
                            }else{
                                map_DirectPlan_Lines.get(planLine.ASI_MFM_Plan__c).add(planLine);
                            }
                        }
                    }
                    
                    planLineMap.put(planLine.ID, planLine);
                }
                
                //1.Create PO from "Direct Plan":
                List<ASI_MFM_PO__c > newPOs = new List<ASI_MFM_PO__c >();
                List<ASI_MFM_PO_Line_Item__c > newPOLines = new List<ASI_MFM_PO_Line_Item__c >();
                Map<Id, ASI_MFM_PO__c> map_PlanId_PO = new Map<Id, ASI_MFM_PO__c>();
                
                //1.1 Create new PO headers:
                for(Id planId :map_DirectPlan_Lines.keySet()){
                    ASI_MFM_Plan__c plan = map_IdPlan.get(planId);
                    ASI_MFM_PO__c po = new ASI_MFM_PO__c();
                    po.ASI_MFM_Currency__c ='TWD';
                    po.recordTypeID =Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TW_PO_Read_Only') ;
                    po.ASI_MFM_Plan__c = plan.Id;
                    //po.ASI_MFM_PAF_Number__c = plan.ASI_MFM_TW_Related_PAF__c;
                    po.ASI_MFM_Status__c = 'Final';
                    //po.OwnerId = plan.ownerId;
                    po.OwnerId = POOwnerId;
                    //po.ASI_MFM_Prefix__c =map_planId_POPrefixId.get(plan.Id);
                    po.ASI_MFM_Prefix__c = PrefixId;
                    po.ASI_MFM_Supplier_Name__c=supplierId;
                    po.ASI_MFM_Accrual_PO__c =true;
                    po.ASI_MFM_PO_Start_Date__c=targetMonthStartDate;
                    po.ASI_MFM_PO_End_Date__c=targetMonthEndDate;
                    po.ASI_MFM_TW_Auto_Generation_Key__c ='PLAN'+plan.Id+targetMonthStartDate.year()+(''+targetMonthStartDate.month()).leftPad(2,'0');
                    newPOs.add(po);
                    map_PlanId_PO.put(planId, po);
                }
                
                system.debug('**Accrual PO Batch: newPOs list= '+newPOs);
                if(newPOs.size()>0){
                    //insert newPOs;
                    Database.SaveResult[] lsr = Database.insert(newPOs);
                    String lsrLog = '';
                    
                    for (Integer i = 0; i < lsr.size(); i++){
                        if (!lsr[i].isSuccess()){
                            ASI_MFM_Plan__c plan = map_IdPlan.get(newPOs[i].ASI_MFM_Plan__c);
                            if (plan != null){
                                lsrLog += 'Error in PO#: ' + newPOs[i].name + '. Error msg=' + lsr[i].getErrors()[0].getMessage() + '\n';
                                if (plan.ASI_MFM_Error_Log__c == null){
                                    plan.ASI_MFM_Error_Log__c = '';
                                }
                                plan.ASI_MFM_Error_Log__c += 'Error in PO#: ' + newPOs[i].name + '. Error msg=' + lsr[i].getErrors()[0].getMessage() + '\n';
                            }
                        }
                    }
                    
                    System.Debug('errLog1: ' + lsrLog);
                    
                    //1.2 Create new PO Lines:
                    Integer monthFieldCounter = targetMonthStartDate.Month()-6;
                    if(monthFieldCounter<=0){
                        monthFieldCounter+=12;
                    }
                    
                    for(Id planId :map_DirectPlan_Lines.keySet()){
                        Id POId = map_PlanId_PO.get(planId).Id;
                        for(ASI_MFM_Plan_Line_Item__c planLine : map_DirectPlan_Lines.get(planId)){
                            
                            ASI_MFM_PO_Line_Item__c poline = new ASI_MFM_PO_Line_Item__c();
                            poline.recordTypeID =Global_RecordTypeCache.getRTId('ASI_MFM_PO_Line_Item__cASI_MFM_TW_PO_Line_Item') ;  
                            poline.ASI_MFM_PO__c = POId;
                            poline.ASI_MFM_G_L_Date__c =  targetMonthEndDate;
                            poline.ASI_MFM_Post_G_L_Date__c =  PostGLDate;
                            poline.ASI_MFM_Sub_brand_Code__c =  planLine.ASI_MFM_Sub_brand_Code__c ;
                            poline.ASI_MFM_List_Item_Description__c =planLine.ASI_MFM_List_Item_Description__c;
                            poline.ASI_MFM_A_C_Code__c = planLine.ASI_MFM_A_C_Code__c;
                            poline.ASI_MFM_Customer_Name__c = planLine.ASI_MFM_Customer_Name__c ;
                            poline.ASI_MFM_Plan_Line_Item__c = planLine.Id;
                            String fieldName = 'ASI_MFM_Month_'+monthFieldCounter+'_Cost__c';
                            Decimal monthCost= (Decimal) planLine.get(fieldName);
                            if(monthCost == null){
                                continue;
                            }
                            poline.ASI_MFM_Amount__c = monthCost.round(System.RoundingMode.CEILING);
                            newPOLines.add(poline);
                        }
                    }
                    if(newPOLines.size()>0){
                        //insert newPOLines;    
                        Database.SaveResult[] lsr_lines = Database.insert(newPOLines);
                        String lsr_linesLog = '';
                        
                        for (Integer i = 0; i < lsr_lines.size(); i++){
                            if (!lsr_lines[i].isSuccess()){
                                ASI_MFM_Plan_Line_Item__c pLine = planLineMap.get(newPOLines[i].ASI_MFM_Plan_Line_Item__c);
                                if (pLine != null){
                                    ASI_MFM_Plan__c plan = map_IdPlan.get(pLine.ASI_MFM_Plan__c);
                                    
                                    if (plan != null){
                                        lsr_linesLog += 'Error in PO Line#: ' + newPOLines[i].name + '. Error msg=' + lsr_lines[i].getErrors()[0].getMessage() + '\n';
                                        if (plan.ASI_MFM_Error_Log__c == null){
                                            plan.ASI_MFM_Error_Log__c = '';
                                        }
                                        plan.ASI_MFM_Error_Log__c += 'Error in PO Line#: ' + newPOLines[i].name + '. Error msg=' + lsr_lines[i].getErrors()[0].getMessage() + '\n';
                                    }
                                }
                            }
                        }
                        System.Debug('errLog2: ' + lsr_linesLog);
                    }
                    
                }
                
                
                //2.Create PO from "PAF Plan":
                List<ASI_MFM_PO__c > newPAFPOs = new List<ASI_MFM_PO__c >();
                List<ASI_MFM_PO_Line_Item__c > newPAFPOLines = new List<ASI_MFM_PO_Line_Item__c >();
                
                //2.1 Create new PAF PO headers:
                for(Id planId :map_PAFPlan_Lines.keySet()){
                    ASI_MFM_Plan__c plan = map_IdPlan.get(planId);
                    ASI_MFM_PO__c po = new ASI_MFM_PO__c();
                    po.ASI_MFM_Currency__c ='TWD';
                    po.recordTypeID =Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TW_PO_Read_Only') ;
                    po.ASI_MFM_Plan__c = plan.Id;
                    po.ASI_MFM_PAF_Number__c = plan.ASI_MFM_TW_Related_PAF__c;
                    po.ASI_MFM_Status__c = 'Final';
                    //po.OwnerId = plan.ownerId;
                    po.OwnerId = POOwnerId;
                    //po.ASI_MFM_Prefix__c =map_planId_POPrefixId.get(plan.Id);
                    po.ASI_MFM_Prefix__c =PrefixId;
                    po.ASI_MFM_Supplier_Name__c=supplierId;
                    po.ASI_MFM_Accrual_PO__c =true;
                    po.ASI_MFM_PO_Start_Date__c=targetMonthStartDate;
                    po.ASI_MFM_PO_End_Date__c=targetMonthEndDate;
                    po.ASI_MFM_TW_Auto_Generation_Key__c ='PAFX'+plan.Id+targetMonthStartDate.year()+(''+targetMonthStartDate.month()).leftPad(2,'0');
                    newPAFPOs.add(po);
                    map_PlanId_PO.put(planId, po);
                }
                
                if(newPAFPOs.size()>0){
                    //insert newPAFPOs;
                    Database.SaveResult[] lsr2 = Database.insert(newPAFPOs);
                    String lsr2Log = '';
                    
                    for (Integer i = 0; i < lsr2.size(); i++){
                        if (!lsr2[i].isSuccess()){
                            ASI_MFM_Plan__c plan = map_IdPlan.get(newPAFPOs[i].ASI_MFM_Plan__c);
                            if (plan != null){
                                lsr2Log += 'Error in PO#: ' + newPAFPOs[i].name + '. Error msg=' + lsr2[i].getErrors()[0].getMessage() + '\n';
                                if (plan.ASI_MFM_Error_Log__c == null){
                                    plan.ASI_MFM_Error_Log__c = '';
                                }
                                plan.ASI_MFM_Error_Log__c += 'Error in PO#: ' + newPAFPOs[i].name + '. Error msg=' + lsr2[i].getErrors()[0].getMessage() + '\n';
                            }
                        }
                    }
                    
                    System.Debug('errLog3: ' + lsr2Log);
                    
                    system.debug('**Accrual PO Batch: newPAFPOs list= '+newPAFPOs);
                    
                    //2.2 Create new PO Lines:
                    for(Id planId :map_PAFPlan_Lines.keySet()){
                        Id POId = map_PlanId_PO.get(planId).Id;
                        for(ASI_MFM_Plan_Line_Item__c planLine : map_PAFPlan_Lines.get(planId)){
                            if(planLine.ASI_MFM_TW_Related_PAF_Item__r.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment') || planLine.ASI_MFM_TW_Related_PAF_Item__r.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment') || planLine.ASI_MFM_TW_Related_PAF_Item__r.RecordTypeId ==Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment') ){ 
                                ASI_MFM_PO_Line_Item__c poline = new ASI_MFM_PO_Line_Item__c();
                                poline.recordTypeID =Global_RecordTypeCache.getRTId('ASI_MFM_PO_Line_Item__cASI_MFM_TW_PO_Line_Item') ;  
                                poline.ASI_MFM_PO__c =  POId;
                                poline.ASI_MFM_G_L_Date__c =  targetMonthEndDate;
                                poline.ASI_MFM_Post_G_L_Date__c =  PostGLDate;
                                poline.ASI_MFM_Sub_brand_Code__c =  planLine.ASI_MFM_Sub_brand_Code__c ;
                                poline.ASI_MFM_List_Item_Description__c =planLine.ASI_MFM_List_Item_Description__c;
                                poline.ASI_MFM_A_C_Code__c = planLine.ASI_MFM_A_C_Code__c;
                                poline.ASI_MFM_Customer_Name__c = planLine.ASI_MFM_Customer_Name__c ;
                                poline.ASI_MFM_Plan_Line_Item__c = planLine.Id;
                                Decimal monthCost;
                                
                                Date PAFStartDate =planLine.ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Start_Date__c ;
                                Date PAFEndDate =planLine.ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_End_Date__c ;
                                //Make sure the target month is between PAF start date and end date (assumption: year difference will not exceed 2 years):
                                if(PAFStartDate!=null && PAFEndDate!=null && PAFStartDate<=targetMonthEndDate && targetMonthStartDate<=PAFEndDate){
                                    Integer fieldNumIndex = (targetMonthStartDate.year() - PAFStartDate.year())*12 + targetMonthStartDate.month() - PAFStartDate.month();
                                    fieldNumIndex = fieldNumIndex+1;
                                    system.debug('**Accrual PO Batch: fieldNumIndex='+fieldNumIndex);
                                    if(fieldNumIndex <=12){
                                        if((planLine.ASI_MFM_TW_Related_PAF_Item__r.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment') && planLine.ASI_MFM_List_Item_Description__c != null && planLine.ASI_MFM_List_Item_Description__c.contains('Cash')) || ((planLine.ASI_MFM_TW_Related_PAF_Item__r.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment') || planLine.ASI_MFM_TW_Related_PAF_Item__r.RecordTypeId ==Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment') )&&planLine.ASI_MFM_List_Item_Description__c != null && planLine.ASI_MFM_List_Item_Description__c.contains('Cash'))){  
                                            //2.2.1 Cash Lines:
                                            Decimal amtDivisor = 1;
                                            if(planLine.ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_CRM_Valid_Invoice__c){
                                                amtDivisor =1.05;
                                            }
                                            //2.2.1 a.Variable Lines:
                                            if(planLine.ASI_MFM_TW_Related_PAF_Item__r.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment')){
                                                String qtyFieldName = 'ASI_CRM_Target_Volume_Qty_P'+fieldNumIndex+'__c';
                                                Decimal monthQty = (Decimal)planLine.getSobject('ASI_MFM_TW_Related_PAF_Item__r').get(qtyFieldName);
                                                Decimal cashPerBottle = planLine.ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Per_Bottle_w_VAT__c != null ? planLine.ASI_MFM_TW_Related_PAF_Item__r.ASI_CRM_Cash_Per_Bottle_w_VAT__c :0 ;
                                                if(monthQty == null ){
                                                    monthCost =0;
                                                    continue;
                                                }else{
                                                    monthCost = (monthQty * cashPerBottle)/amtDivisor;
                                                }
                                            }
                                            //2.2.1 b. Fixed and Conditional Lines:
                                            else if(planLine.ASI_MFM_TW_Related_PAF_Item__r.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment') || planLine.ASI_MFM_TW_Related_PAF_Item__r.RecordTypeId ==Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment') ){
                                                System.debug('**Accrual PO Batch: PAF Plan -  Cash - Fixed/Conditional Investment');
                                                System.debug('**Accrual PO Batch: planline id = ' + planline.id);
                                                String amtFieldName = 'ASI_CRM_Cash_Amounts_w_VAT_P'+fieldNumIndex+'__c';
                                                Decimal monthAmt = (Decimal)planLine.getSobject('ASI_MFM_TW_Related_PAF_Item__r').get(amtFieldName);
                                                if(monthAmt == null){
                                                    monthCost = 0;
                                                    continue;
                                                }else{
                                                    monthCost =monthAmt/amtDivisor;
                                                }
                                            }
                                        }
                                        else if((planLine.ASI_MFM_TW_Related_PAF_Item__r.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment') && planLine.ASI_MFM_List_Item_Description__c != null && planLine.ASI_MFM_List_Item_Description__c.contains('FOC') ) || ((planLine.ASI_MFM_TW_Related_PAF_Item__r.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment') || planLine.ASI_MFM_TW_Related_PAF_Item__r.RecordTypeId ==Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment') )&&planLine.ASI_MFM_List_Item_Description__c != null && planLine.ASI_MFM_List_Item_Description__c.contains('FOC'))){  
                                            //2.2.2. FOC Lines:
                                            
                                            //2.2.2 a. Variable Lines:
                                            if(planLine.ASI_MFM_TW_Related_PAF_Item__r.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment')){
                                                String qtyFieldName = 'ASI_CRM_Target_Volume_Qty_P'+fieldNumIndex+'__c';
                                                Decimal monthQty = (Decimal)planLine.getSobject('ASI_MFM_TW_Related_PAF_Item__r').get(qtyFieldName);
                                                Decimal buyQty = planLine.ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c;
                                                Decimal freeQty =  planLine.ASI_MFM_TW_Related_PAF_Item__r.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c;
                                                Decimal unitCost =planLine.ASI_MFM_Unit_Cost__c;
                                                if(monthQty ==null){
                                                    continue;
                                                }
                                                if( buyQty== null || freeQty== null || unitCost== null  || buyQty==0  ){
                                                    monthCost =0;
                                                }else{
                                                    monthCost =(monthQty/buyQty)*freeQty * unitCost;
                                                }
                                            }
                                            //2.2.2 b. Fixed and Conditional Lines:
                                            else if(planLine.ASI_MFM_TW_Related_PAF_Item__r.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment') || planLine.ASI_MFM_TW_Related_PAF_Item__r.RecordTypeId ==Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment') ){
                                                String FOCVolFieldName = 'ASI_CRM_FOC_Volume_P'+fieldNumIndex+'__c';
                                                Decimal monthQty = (Decimal)planLine.getSobject('ASI_MFM_TW_Related_PAF_Item__r').get(FOCVolFieldName);
                                                if(monthQty == null ){
                                                    continue;
                                                }
                                                if(planLine.ASI_MFM_Unit_Cost__c == null){
                                                    monthCost = 0;
                                                }else{
                                                    monthCost =monthQty * planLine.ASI_MFM_Unit_Cost__c;
                                                }
                                            }
                                        }
                                    }else{
                                        system.debug('**Accrual PO Batch: PAF time range may exceed 1 year and not appropriate for PO generation.');
                                        continue;
                                    }
                                    
                                    
                                }else{
                                    system.debug('**Accrual PO Batch: PAF Date is not appropriate for PO generation.');
                                    continue;
                                }
                                
                                
                                if(monthCost == null){
                                    system.debug('**Accrual PO Batch: No appropriate month Cost for PO line item.');
                                    continue;
                                }
                                poline.ASI_MFM_Amount__c = monthCost.round(System.RoundingMode.CEILING);
                                newPAFPOLines.add(poline); 
                            }
                            
                        }
                    }
                    if(newPAFPOLines.size()>0){
                        //insert newPAFPOLines;    
                        Database.SaveResult[] lsr_lines2 = Database.insert(newPAFPOLines);
                        String lsr_lines2Log = '';
                        
                        for (Integer i = 0; i < lsr_lines2.size(); i++){
                            if (!lsr_lines2[i].isSuccess()){
                                ASI_MFM_Plan_Line_Item__c pLine = planLineMap.get(newPAFPOLines[i].ASI_MFM_Plan_Line_Item__c);
                                if (pLine != null){
                                    ASI_MFM_Plan__c plan = map_IdPlan.get(pLine.ASI_MFM_Plan__c);
                                    if (plan != null){
                                        lsr_lines2Log += 'Error in PO Line#: ' + newPAFPOLines[i].name + '. Error msg=' + lsr_lines2[i].getErrors()[0].getMessage() + '\n';
                                        if (plan.ASI_MFM_Error_Log__c == null){
                                            plan.ASI_MFM_Error_Log__c = '';
                                        }
                                        plan.ASI_MFM_Error_Log__c += 'Error in PO Line#: ' + newPAFPOLines[i].name + '. Error msg=' + lsr_lines2[i].getErrors()[0].getMessage() + '\n';
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            update map_IdPlan.values();
        }
        
        
        
    } 
    
    global void finish(Database.BatchableContext BC)
    {
        try{
            ASI_MFM_Setting__c   TWMFMSetting = [SELECT Id,ASI_MFM_TW_Today__c  FROM ASI_MFM_Setting__c LIMIT 1];
            if(TWMFMSetting!=null && TWMFMSetting.ASI_MFM_TW_Today__c  !=null){
                system.debug('TWMFMSetting='+TWMFMSetting);
                TWMFMSetting.ASI_MFM_TW_Today__c=null ;
                update TWMFMSetting;
            }
        }catch(exception e){
            system.debug('NO valid custom setting for MFM TW');
        }
        
        
    }
    
    
    public static string getQueryDateStr(date strDate){
        string strReturn;
        if (strDate != null){
            strReturn = string.valueof(strDate.Year());
            if (strDate.Month() < 10)
                strReturn += '-0'+ strDate.Month();
            else
                strReturn += '-'+ strDate.Month();
            if (strDate.Day() < 10)
                strReturn += '-0' + strDate.Day();
            else
                strReturn += '-' + strDate.Day();
        }
        return strReturn;
    }
    
    public static string getStrFiscalYear(Date dt){
        String strFiscalYear;
        if(dt != null){
            Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
            Integer yearA0;
            Integer yearA1;
            if(dt.month()>=orgFiscalMonth){
                yearA0=dt.year();
                yearA1= dt.year()+1;
            }else{
                yearA0=dt.year()-1;
                yearA1= dt.year();
            }
            String str_yearA0=String.valueOf(yearA0).right(2);
            String str_yearA1=String.valueOf(yearA1).right(2);    
            strFiscalYear = 'FY' + str_yearA0 + str_yearA1 ;
        }
        
        return strFiscalYear;
    }
}