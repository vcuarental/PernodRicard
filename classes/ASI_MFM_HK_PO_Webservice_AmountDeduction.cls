/*********************************************************************************
 * Name:ASI_MFM_HK_PO_Webservice_AmountDeduction
 * Description: 
 * Test Class: ASI_MFM_HK_PO_Webservice_AmountDeducTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 30/05/2018       Wilken              [WL 1.0] Add two more expense type for validating PO
 * 10/07/2018       Wilken              [WL 2.0] Handle Concur user with "2" in the username (e.g. Philippe.guettat2@pernod-ricard.com)
 * 29/11/2018       Wilken              [WL 3.0] Reject claim if PO is A&D type (as user should not claim from Concur for this PO type)
 * 02/01/2019       Wilken              [WL 4.0] All Expense Type are validated against MFM PO Number
 * 21/01/2019       Wilken              [WL 5.0] Block T&E Claim from FOC PO for HK Market
 * 05/08/2019       Wilken              [WL 6.0] Fix foreign currency duplicated exchange rate multiplication
*********************************************************************************/
@RestResource(UrlMapping='/ASI_MFM_HK_PO_Webservice_AmountDeduction/*')
Global without Sharing class ASI_MFM_HK_PO_Webservice_AmountDeduction {

    //{\"poId\":\"a9NM00000004EbC\"}
    @HttpPost
    Global Static void getPORecord(){
       
        Map<Id, ASI_MFM_PO__c> po = new Map<Id, ASI_MFM_PO__c>();
        Map<Id, ASI_MFM_PLan__c> plan = new Map<Id, ASI_MFM_Plan__c>();
        Map<String, ASI_MFM_PO__c> mapPObyName = new Map<String, ASI_MFM_PO__c>();
        Map<String, ASI_MFM_Plan__c> mapPlanbyName = new Map<String, ASI_MFM_Plan__c>();
        Map<String, Decimal> mapPOAmountByName = new Map<String, Decimal>();
        Map<String, Boolean> mapExpenseType = new Map<String, Boolean>{
            'capex - hardware (pre-approved)' => false  //[WL 4.0]
            , 'capex - software (pre-approved)' => false  //[WL 4.0]
            , 'po accrued' => false
            , 'marketing expense' => false
      /*[WL 1.0] BEGIN*/
      , 'marketing expense (gift)' => false
      , 'marketing expense (hospitality)' => false
      /*[WL 1.0] END*/  
            }; // true = Plan, false = PO
                
        Set<String> poNumberSet = new Set<String>();
        Set<String> planNumberSet = new Set<String>();
        
        String currentUserId = '';
        //String poRecordType = '';
        Set<Id> poRecordType = new Set<Id>();
        
        restRequest req = restcontext.request;
        restResponse res = RestContext.response;
        
        parametersClass parameterList = (parametersClass)system.JSON.deserialize(req.requestBody.toString(), parametersClass.class);
        res.addHeader('Content-Type','application/json');
        
        replaceNullValue(parameterList, poNumberSet, planNumberSet, mapExpenseType);
        
        if(!parameterList.success){
            res.responseBody = blob.valueOf(JSON.serialize(parameterList));
            Return;
        }
        
        if(parameterList.currentUser != Null && parameterList.currentUser != ''){
      /*[WL 2.0] BEGIN*/
      if (parameterList.currentUser.contains('2'))
        parameterList.currentUser = parameterList.currentUser.replace('2','');
      
      system.debug('parameterList.currentUser: ' + parameterList.currentUser);
      /*[WL 2.0] END*/
      
            List<User> tmpU = new List<User>([SELECT id, username, ASI_MFM_Country__c FROM User WHERE username Like : parameterList.currentUser OR username Like : (parameterList.currentUser + '.asisb6conf')]);
            
            if(tmpU.size() > 0){
                
                currentUserId = tmpU[0].id;
                if(tmpU[0].ASI_MFM_Country__c == 'TR'){
                    
                    poRecordType.add(Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_TR_PO'));
                    poRecordType.add(Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_TR_PO_Read_Only'));
                }else{
                    
                    poRecordType.add(Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'));
                    poRecordType.add(Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO_Read_Only'));
                    poRecordType.add(Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_RM_PO'));
                    poRecordType.add(Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_RM_PO_Read_Only'));
                    poRecordType.add(Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CAP_Accrual_PO'));
                    poRecordType.add(Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CAP_Accrual_PO_Read_Only'));
                    poRecordType.add(Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CAP_PO'));  //[WL 4.0]
                    poRecordType.add(Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CAP_PO_Read_Only'));   //[WL 4.0]
                }
                //poRecordType = tmpU[0].ASI_MFM_Country__c == 'TR' ? 'ASI_MFM_TR_PO%' : 'ASI_MFM_HK_PO%';
            }else{
                parameterList.success = False;
                parameterList.returnMsg = appendMsg(parameterList.returnMsg, 'User: ' + parameterList.currentUser + ' cannot be found.');//+= ' User: ' + parameterList.currentUser + ' cannot be found.';
                res.responseBody = blob.valueOf(JSON.serialize(parameterList));
                Return;
            }
        }
        
        Savepoint sp = Database.setSavepoint();
        
        List<ASI_TnE_ClaimHeader__c> existingTnE = new List<ASI_TnE_ClaimHeader__c>([SELECT id, ASI_TnE_Status__c
                                                                                     , ASI_TnE_3rd_Party__c
                                                                                     FROM ASI_TnE_ClaimHeader__c 
                                                                                     WHERE ASI_TnE_KR_External_ID__c = : parameterList.concurReportId 
                                                                                     AND ASI_TnE_Status__c = 'Final'
                                                                                     AND recordTypeId = : Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header')
                                                                                     Order By CreatedDate DESC]);
        
        for(ASI_TnE_ClaimHeader__c obj : existingTnE){
            obj.ASI_TnE_Status__c = 'Draft';
            obj.ASI_TnE_3rd_Party__c = False;
        }
        
        ASI_TnE_ClaimHeader__c tneHeader = new ASI_TnE_ClaimHeader__c();
        tneHeader.recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header');
        tneHeader.ASI_TnE_Sys_Allow_Submit_Approval__c = true;
        tneHeader.ASI_TnE_Sync_to_JDE_Date__c = date.today();
        tneHeader.ASI_TnE_Status__c = 'Final';
        tneHeader.ASI_TnE_Payee_Employee__c = currentUserId;
        tneHeader.ASI_TnE_KR_External_ID__c = parameterList.concurReportId;
        tneHeader.ASI_TnE_3rd_Party__c = True;
        
        try{
            
            existingTnE.add(tneHeader);
            Upsert existingTnE;
            
        }catch(dmlException dmle){
            
            Database.rollback(sp);
            parameterList.success = False;
            parameterList.returnMsg = appendMsg(parameterList.returnMsg, 'Unable to create T&E Claim in SFDC, Please contact admin, Error Message: ' + dmle.getMessage());//+= ' Unable to create T&E Claim in SFDC, Please contact admin, Error Message: ' + dmle.getMessage();
            res.responseBody = blob.valueOf(JSON.serialize(parameterList));
            Return;
        }
        
        List<ASI_TnE_ClaimDetail__c> tneLine = new List<ASI_TnE_ClaimDetail__c>();
                
        if(poNumberSet.size() > 0){
            po = new Map<Id, ASI_MFM_PO__c>([SELECT ID
                                             , Name
                                             , ASI_MFM_PO_Balance__c
                                             , ASI_MFM_Plan__r.Name
                                             , ASI_MFM_Supplier_Name__r.Name
                                             , ASI_MFM_Invoice_Amount_from_JDE__c
                                             , ASI_MFM_Base_Currency_Amount__c
                                             , ASI_MFM_T_E_Amount__c
                       , ASI_MFM_AP_AD__c //[WL 3.0]
                                             , ASI_MFM_Is_FOC_PO__c //[WL 5.0]
                                             , RecordType.DeveloperName //[WL 5.0]
                                             FROM ASI_MFM_PO__c
                                             WHERE Name IN : poNumberSet
                                             AND RecordTypeId IN : poRecordType
                                            ]);
            
            for(ASI_MFM_PO__c obj : po.values()){
                mapPObyName.put(obj.Name.toLowerCase(), obj);
                mapPOAmountByName.put(obj.Name.toLowerCase(), obj.ASI_MFM_PO_Balance__c);
            }
        }
        
    system.debug('mapPObyName: ' + mapPObyName);
    
        if(planNumberSet.size() > 0){
            plan = new Map<Id, ASI_MFM_Plan__c>([SELECT ID
                                                 , Name
                                                 , ASI_MFM_Status__c
                                                 FROM ASI_MFM_Plan__c
                                                 WHERE Name IN : planNumberSet
                                                 AND RecordType.DeveloperName Like 'ASI_MFM_CAP_Plan%'
                                                ]);
            
            for(ASI_MFM_Plan__c obj : plan.values()){
                mapPlanbyName.put(obj.Name.toLowerCase(), obj);
            }
        }
        
        for(detailDataClass obj : parameterList.transactions){
            system.debug('obj.poNumber: ' + obj.poNumber);
            
            if(obj.poNumber != Null && obj.poNumber != '' && !mapPObyName.containsKey(obj.poNumber.toLowerCase())){
                
                parameterList.success = False;
                obj.returnMsg = 'PO(' + obj.poNumber + ') cannot be found.';
                parameterList.returnMsg = appendMsg(parameterList.returnMsg, obj.returnMsg);//+= ' ' + obj.returnMsg;
                obj.success = False;
                
            }
      /*[WL 4.0] BEGIN*/
      /*else if(obj.CAPEXPlanNumber != '' && obj.CAPEXPlanNumber != Null && !mapPlanbyName.containsKey(obj.CAPEXPlanNumber.toLowerCase())){
                
                parameterList.success = False;
                obj.returnMsg = 'Plan(' + obj.CAPEXPlanNumber + ') cannot be found.';
                parameterList.returnMsg = appendMsg(parameterList.returnMsg, obj.returnMsg);//+= ' ' + obj.returnMsg;
                obj.success = False;
                
            }*/
      /*[WL 4.0] END*/
      /*[WL 3.0] BEGIN*/
      else if(obj.poNumber != Null && obj.poNumber != '' && mapPObyName.containsKey(obj.poNumber.toLowerCase()) && mapPObyName.get(obj.poNumber.toLowerCase()).ASI_MFM_AP_AD__c == 'A&D'){
                
                parameterList.success = False;
                obj.returnMsg = 'A and D PO (' + obj.poNumber + ') cannot be claimed through Concur.';
                parameterList.returnMsg = appendMsg(parameterList.returnMsg, obj.returnMsg);//+= ' ' + obj.returnMsg;
                obj.success = False;
                
            }
      /*[WL 3.0] END*/
            /*[WL 5.0] BEGIN*/
            else if (obj.poNumber != Null && obj.poNumber != '' && mapPOByName.get(obj.poNumber.toLowerCase()).RecordType.DeveloperName.contains('ASI_MFM_HK_PO')
                 && mapPOByName.get(obj.poNumber.toLowerCase()).ASI_MFM_Is_FOC_PO__c){
                system.debug('HK FOC PO, return fail');
                
                parameterList.success = False;
                obj.returnMsg =  'FOC PO (' + obj.poNumber + ') cannot be claimed through Concur.';                
                parameterList.returnMsg = appendMsg(parameterList.returnMsg, obj.returnMsg);
                obj.success = False;                
             }
            /*[WL 5.0] END*/                
      else if(obj.poNumber != '' && obj.poNumber != Null && mapPObyName.containsKey(obj.poNumber.toLowerCase())){
                system.debug('Validation Success, PO A&P A&D Type: ' + mapPObyName.get(obj.poNumber.toLowerCase()).ASI_MFM_AP_AD__c );
        
				/*[WL 6.0] BEGIN*/
                //Decimal expenseAmount = (obj.expenseAmount * (obj.fxRate != Null ? obj.fxRate : 1)).setScale(2); // 20180313 Introv Added setScale(2);
				Decimal expenseAmount = obj.expenseAmount.setScale(2);	
				/*[WL 6.0] END*/
                
                tneLine.add(new ASI_TnE_ClaimDetail__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_HK_Claim_Detail')
                                                       , ASI_TnE_Receipt_Amount__c = expenseAmount //20180313 Introv changed to expenseAmount
                                                       //, ASI_TnE_Total_Number_Pax__c = 1
                                                       , ASI_TnE_MFM_PO__c = mapPObyName.get(obj.poNumber.toLowerCase()).id
                                                       , ASI_TnE_ClaimHeader__c = tneHeader.Id
                                                       , ASI_TnE_Name_Company__c = 'Pernod Ricard Hong Kong'
                                                       , ASI_TnE_FX_Rate__c = ( obj.fxRate != Null ? obj.fxRate : 1 )
                                                       , ASI_TnE_KR_Detail_External_ID__c = obj.concurLineId
                                                      ));
                
                //obj.returnMsg = '';//'Success'; //, PO remaining: ' + mapPOAmountByName.get(obj.poNumber.toLowerCase()).setScale(2) + ', transaction amount: ' + (obj.expenseAmount * ( obj.fxRate != Null ? obj.fxRate : 1 )).setScale(2);
                //obj.returnMsg = obj.returnMsg + ', after deduction: ' + (mapPOAmountByName.get(obj.poNumber.toLowerCase()) - (obj.expenseAmount * ( obj.fxRate != Null ? obj.fxRate : 1 ))).setScale(2);
                //parameterList.returnMsg = appendMsg(parameterList.returnMsg, obj.returnMsg);//+= ' ' + obj.returnMsg;
                //mapPOAmountByName.put(obj.poNumber.toLowerCase(), mapPOAmountByName.get(obj.poNumber.toLowerCase()) - (obj.expenseAmount * ( obj.fxRate != Null ? obj.fxRate : 1 )));
                
            }
      /*[WL 4.0] BEGIN*/
      /*else if(obj.CAPEXPlanNumber != '' && obj.CAPEXPlanNumber != Null && mapPlanbyName.containsKey(obj.CAPEXPlanNumber.toLowerCase())){
                
                Decimal expenseAmount = (obj.expenseAmount * (obj.fxRate != Null ? obj.fxRate : 1)).setScale(2); // 20180313 Introv Added setScale(2);
                
                tneLine.add(new ASI_TnE_ClaimDetail__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_HK_Claim_Detail')
                                                       , ASI_TnE_Receipt_Amount__c = expenseAmount //20180313 Introv changed to expenseAmount
                                                       //, ASI_TnE_Total_Number_Pax__c = 1
                                                       , ASI_TnE_CAP_Plan__c  = mapPlanbyName.get(obj.CAPEXPlanNumber.toLowerCase()).id
                                                       , ASI_TnE_ClaimHeader__c = tneHeader.Id
                                                       , ASI_TnE_Name_Company__c = 'Pernod Ricard Hong Kong'
                                                       , ASI_TnE_FX_Rate__c = ( obj.fxRate != Null ? obj.fxRate : 1 )
                                                       , ASI_TnE_KR_Detail_External_ID__c = obj.concurLineId
                                                      ));
            }*/
      /*[WL 4.0] END*/
        }
        
        if(parameterList.success){
            try{
                
                Insert tneLine;
            }catch(dmlException dmle){
                
                Database.rollback(sp);
                parameterList.success = False;
                parameterList.returnMsg = appendMsg(parameterList.returnMsg, 'Unable to create T&E Claim in SFDC, Please contact admin, Error Message: ' + dmle.getMessage());//+= ' Unable to create T&E Claim in SFDC, Please contact admin, Error Message: ' + dmle.getMessage();
                res.responseBody = blob.valueOf(JSON.serialize(parameterList));
                Return;
            }
            
            /*try{
                
                tneHeader.ASI_TnE_Status__c = 'Final';
                Update tneHeader;
                
            }catch(dmlException dmle){
                
                Database.rollback(sp);
                parameterList.success = False;
                parameterList.returnMsg = 'Unable to create T&E Claim in SFDC, Please contact admin, Error Message: ' + dmle.getMessage();
                res.responseBody = blob.valueOf(JSON.serialize(parameterList));
                Return;
            }*/
        }
        
        parameterList.tneHeaderId = tneHeader.id;
        res.responseBody = blob.valueOf(JSON.serialize(parameterList));
        return;
    }
    
    Private Static String appendMsg(String currentMsg, String appendMsg){
        
        String msg = currentMsg;
        
        if(appendMsg != '')
            msg = ' ' + currentMsg + appendMsg + '\r\n';
        
        Return msg;
    }
    
    Private Static Void replaceNullValue(parametersClass parameterList, Set<String> poNumberSet, Set<String> planNumberSet, Map<String, Boolean> mapExpenseType){
        
        parameterList.concurReportId = parameterList.concurReportId != Null ? parameterList.concurReportId : '';
        parameterList.currentUser = parameterList.currentUser != Null ? parameterList.currentUser : '';
        parameterList.success = parameterList.success != Null ? parameterList.success : True;
        parameterList.returnMsg = parameterList.returnMsg != Null ? parameterList.returnMsg : '';
        parameterList.tneHeaderId = parameterList.tneHeaderId != Null ? parameterList.tneHeaderId : '';
        parameterList.transactions = parameterList.transactions != Null ? parameterList.transactions : new List<detailDataClass>();
        
        for(detailDataClass obj : parameterList.transactions){
            
            obj.returnMsg = obj.returnMsg != Null ? obj.returnMsg : '';
            obj.concurReportId = obj.concurReportId != Null ? obj.concurReportId : '';
            obj.poNumber = obj.poNumber != Null ? obj.poNumber : '';
            obj.CAPEXPlanNumber = obj.CAPEXPlanNumber != Null ? obj.CAPEXPlanNumber : '';
            obj.concurLineId = obj.concurLineId != Null ? obj.concurLineId : '';
            obj.fxRate = obj.fxRate != Null ? obj.fxRate : 1;
            obj.expenseAmount = obj.expenseAmount != Null ? obj.expenseAmount : 0;
            obj.success = obj.success != Null ? obj.success : True;
            obj.expenseType = obj.expenseType != Null ? obj.expenseType : '';
            obj.recordNumber = obj.recordNumber != Null ? obj.recordNumber : '';
            
            if(mapExpenseType.containsKey(obj.expenseType.toLowerCase()) && mapExpenseType.get(obj.expenseType.toLowerCase()) && obj.expenseType != ''){
                
                obj.CAPEXPlanNumber = obj.recordNumber;
            }else if(mapExpenseType.containsKey(obj.expenseType.toLowerCase()) && !mapExpenseType.get(obj.expenseType.toLowerCase()) && obj.expenseType != ''){
                
                obj.poNumber = obj.recordNumber;
            }
            
            if(obj.poNumber != Null && obj.poNumber != '')
                poNumberSet.add(obj.poNumber);
            if(obj.CAPEXPlanNumber != Null && obj.CAPEXPlanNumber != '')
                planNumberSet.add(obj.CAPEXPlanNumber);
            
            if(obj.expenseType == '' || obj.recordNumber == ''){
                parameterList.success = False;
                obj.success = False;
                obj.returnMsg = 'Expense Type and Plan/PO Number cannot be null';
                parameterList.returnMsg += ' ' + obj.returnMsg;
            }
        }
    }
    
    Public class parametersClass{
        
        Public String concurReportId;
        Public String currentUser;
        Public String returnMsg;
        Public Boolean success; // allOrNone;
        Public String tneHeaderId;
        Public List<detailDataClass> transactions = new List<detailDataClass>();
    }
    
    Public Class detailDataClass{
        
        Public String returnMsg;
        Public String concurReportId;
        Public String poNumber;
        Public String concurLineId;
        Public String CAPEXPlanNumber;
        Public Decimal fxRate;
        Public Decimal expenseAmount;
        Public Boolean success;
        Public String expenseType;
        Public String recordNumber;
    }
}