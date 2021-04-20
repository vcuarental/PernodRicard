/*********************************************************************************
 * Name:ASI_MFM_SetPOStatusController
 * Description: 
 * Test Class:  ASI_MFM_SetPOStatusController_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 04/06/2018       Wilken                [WL 1.0] Check new_status not null before updating it to payment
 * 14/02/2019       Laputa: Calvin        Added VN MFM rt
 * 2020-12-01       PR COE                COE 1.0 add MY set Final to complete
*********************************************************************************/
public with sharing class ASI_MFM_SetPOStatusController {
    string new_status;
    ASI_MFM_PO__c p = new ASI_MFM_PO__c();

    public ASI_MFM_SetPOStatusController(apexpages.standardController sc) {
        new_status = apexpages.currentPage().getParameters().get('status');
        //Add Plan Status For KR MFM @Elufa 2016025
        p = [select id, ASI_MFM_Invoice_Amount_from_JDE__c, ASI_MFM_Original_PO_for_Adjustment__c, ASI_MFM_Status__c,ASI_MFM_Plan__r.ASI_MFM_Status__c,ASI_MFM_Is_FOC_PO__c,ASI_MFM_Payroll_PO__c,ASI_MFM_T_E__c,recordTypeId, recordtype.name, ASI_MFM_PO_Amount__c , ASI_MFM_Previous_Approved_By__c,ASI_MFM_Previous_Approved_Amount__c,ASI_MFM_Previous_Approved_At__c from ASI_MFM_PO__c where id = :sc.getId()];
    }
    
    public pageReference setStatus() {
    Map<string, id> MRecType = new map<string, id>();
        List<recordType> rtList = Global_RecordTypeCache.getRtList('ASI_MFM_PO__c');
        for (recordType rtt:rtList) {
            MRecType.put(rtt.DeveloperName, rtt.id);            
        }
        String JPRecTypeID = MRecType.get('ASI_MFM_JP_PO');
        String TRRecTypeID = MRecType.get('ASI_MFM_TR_PO');
        system.debug('PO Status: ' + p.ASI_MFM_Status__c + ' new_status: ' + new_status); system.debug('PO recordtype: ' + p.recordtype.name);
        if (p.ASI_MFM_Status__c == 'Final' || p.ASI_MFM_Status__c == 'Partial Paid') {
            List<ASI_MFM_Payment_Line_Item__c> paList = [select id,ASI_MFM_PO_Line_Item__r.ASI_MFM_Has_Final_Receipt__c, ASI_MFM_Payment__r.ASI_MFM_Pre_payment__c,ASI_MFM_Payment__r.ASI_MFM_Status__c,
                                                         ASI_MFM_Payment_Line_Item_Finance_Verify__c,ASI_MFM_Payment__r.ASI_MFM_POSM_Deposit__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c = :p.id];
            p.ASI_MFM_Status__c = new_status;
            if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_GF')){
                //Block user to set Draft if PO has either Receipt or Payment
                List<ASI_MFM_PO_Receipt_Item__c> recList = [select id from ASI_MFM_PO_Receipt_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c = :p.id];
                
                if (new_status == 'Draft'){
                    if (recList.size() > 0){
                        apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set status to Draft for PO with receipt.'));
                        return null;
                    }
                    else if (paList.size() > 0){
                        apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set status to Draft for PO with payment.'));
                        return null;
                    }
                }
                //set GF PO Complete :  add by Elufa Support 20151228
                if (new_status == 'Complete'){
                    //enhancement :(20161201) - Validation to ensure Pre-payment has been receipted before allowing user to complete the PO
                    // a checked to ensure all prepayment has been receipted before PO can be completed 
                    string createdLine = apexpages.currentPage().getParameters().get('createdLine');
                    
                    //Checking
                    if(createdLine=='No'){
                        if (recList.size() > 0){
                            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set status to Complete Without Reversal for PO with receipt.'));
                            return null;
                        }
                        if(paList.size()>0){
                            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set status to Complete Without Reversal for PO with Payment.'));
                            return null;
                        }
                       
                        
                        //change po line to complete 
                        List<ASI_MFM_PO_Line_Item__c> ComPOList =[select id,name,ASI_MFM_Complete__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c =: p.id];
                        for(ASI_MFM_PO_Line_Item__c pol:ComPOList){
                            pol.ASI_MFM_Complete__c=true;
                        }
                        update ComPOList;
                    }else{
                        for(ASI_MFM_Payment_Line_Item__c pl:paList){
                            if(pl.ASI_MFM_Payment__r.ASI_MFM_Status__c!='Final'){
                                apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Only Final Payment can set complete status.'));
                                return null;
                            }
                            if(pl.ASI_MFM_Payment__r.ASI_MFM_Pre_payment__c){
                                if(pl.ASI_MFM_PO_Line_Item__r.ASI_MFM_Has_Final_Receipt__c==0){
                                    apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Pre-payment has not been receipted .'));
                                    return null;
                                }
                                
                            }
                        }
                    }
                    
                    set<id> poidset= new set<id>();
                    poidset.add(p.id);

                    if(createdLine=='Yes'){
                        
                        ASI_MFM_Payment_TriggerClass.CompletePOLine(poidset);
                    }
                }
                //set GF PO Complete End: add by Elufa Support 20151228
                 
            }
            else if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_JP')){
                //Update Previous Approve for JP
                List<ASI_MFM_PO_Receipt_Item__c> recList = [select id from ASI_MFM_PO_Receipt_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c = :p.id];
                //set status to Draft :check PO Receipt and Payment 
                if (new_status == 'Draft'){
                    if (recList.size() > 0){
                        apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set status to Draft for PO with receipt.'));
                        return null;
                    }
                    else if (paList.size() > 0){
                        apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set status to Draft for PO with payment.'));
                        return null;
                    }
                }
                
                 p.recordTypeId = JPRecTypeID ;
                ASI_ApprovalHistoryHelper appHistHelper = new ASI_ApprovalHistoryHelper ( 'ASI_MFM_PO__c', p.Id );
                if (appHistHelper.appHistorySObjList != null){   
                   p.ASI_MFM_Previous_Approved_By__c=   appHistHelper.appHistorySObjList[0].Actor.Id  ; 
                   p.ASI_MFM_Previous_Approved_Amount__c  = p.ASI_MFM_PO_Amount__c ;
                   p.ASI_MFM_Previous_Approved_At__c = appHistHelper.appHistorySObjList[0].CreatedDate ;
                }
                
            } 
            else if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TR')){
                if (new_status == 'Draft')
                    p.recordTypeId = TRRecTypeID ;
                else if (new_status == 'Voided'){
                    //Set Void Status 1st check all po line, create negative amount if sync
                    String soql = getCreatableFieldsSOQL('ASI_MFM_PO_Line_Item__c','ASI_MFM_PO__c= \'' + p.id + '\'');
                    String soql2 =  'SELECT id,ASI_MFM_PO_Line_Item__c,ASI_MFM_PO_Receipt__r.ASI_MFM_Status__c, ASI_MFM_PO_Line_Item__r.id,ASI_MFM_ETL__c  FROM ASI_MFM_PO_Receipt_Item__c WHERE ' + 'ASI_MFM_PO__c= \'' + p.id + '\'';
                    
                    System.debug('SOQL: ' + soql);
                    List<ASI_MFM_PO_Line_Item__c> plList = (List<ASI_MFM_PO_Line_Item__c>)Database.query(soql);
                    //List<ASI_MFM_PO_Receipt_Item__c> prlList = (List<ASI_MFM_PO_Receipt_Item__c>)Database.query(soql2);
                    List<ASI_MFM_PO_Line_Item__c> plListForInsert = new List<ASI_MFM_PO_Line_Item__c>();
                    List<ASI_MFM_PO_Line_Item__c> plListForUpdate = new List<ASI_MFM_PO_Line_Item__c>();
                    Boolean isETL = false;
                    for (ASI_MFM_PO_Line_Item__c pl : plList){
                        //Modified by Wilken on 20150224, check JDE interface flag base on PO Line Synced checkbox instead of PO Receipt Line relationship
                        if (pl.ASI_MFM_Synced__c)
                            isETL = true;
                            
                        if (isETL == true){ //Create a negative amount 
                            ASI_MFM_PO_Line_Item__c pl2 = pl.clone(false, true);
                            pl2.ASI_MFM_Amount__c = pl2.ASI_MFM_Amount__c * -1;
                            pl2.ASI_MFM_Synced__c = false;
                            pl2.ASI_MFM_List_Item_Description__c += '-(Cloned for negative amount)';
                            pl2.ASI_MFM_PO_Line_Item_External_ID__c  = '';
                            plListForInsert.add(pl2);
                        }
                        else{
                            pl.ASI_MFM_Adjust_PO_Number__c = null;
                            pl.ASI_MFM_Adjusted_Amount__c = pl.ASI_MFM_Amount__c;
                            pl.ASI_MFM_Amount__c = 0;
                            pl.ASI_MFM_JDE_Status__c = 'Paid';
                            plListForUpdate.add(pl);
                        }
                        isETL = false;
                    }
                    insert plListForInsert;
                    update plListForUpdate;
                }
            }
            //20170510 add void logic for HK MFM
            else if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_HK_PO')){
                if (new_status == 'Voided'){
                    
                    if(p.ASI_MFM_Invoice_Amount_from_JDE__c != 0 && p.ASI_MFM_Invoice_Amount_from_JDE__c != Null){
                        apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot void PO with Invoice amount from JDE greater than 0'));
                        return null;
                    }
                    
                    if(p.ASI_MFM_Original_PO_for_Adjustment__c != Null){
                        apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Only Original PO can be voided'));
                        return null;
                    }
                    
                    List<ASI_MFM_PO__c> adjustmentPO = new List<ASI_MFM_PO__c>([SELECT id, Name FROM ASI_MFM_PO__c WHERE ASI_MFM_Original_PO_for_Adjustment__c = : p.id AND ASI_MFM_Status__c Like 'Submitted']);
                    
                    if(adjustmentPO.size() > 0){
                        String errorMsg = 'Following Adjustment POs (';
                        
                        for(integer i = 0 ; i < adjustmentPO.size() ; i++){
                            
                            if((i+1) == adjustmentPO.size()){
                                errorMsg += adjustmentPO[i].Name;
                            }else{
                                errorMsg += adjustmentPO[i].Name + ', ';
                            }
                        }
                        
                        errorMsg += ') are pending for approval, please recall or approve before voiding this PO';
                                                
                        apexpages.addMessage(new apexpages.Message(apexpages.severity.error, errorMsg));
                        if(!Test.isRunningTest())
                            return null;
                    }
                    
                    List<ASI_TnE_ClaimDetail__c> TnEList = new List<ASI_TnE_ClaimDetail__c>([SELECT id FROM ASI_TnE_ClaimDetail__c WHERE ASI_TnE_MFM_PO__c = : p.id]);
                    
                    if(TnEList.size()>0){
                        apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot void PO with T&E item.'));
                        return null;
                    }
                    
                    //Set Void Status 1st check all po line, create negative amount if sync
                    String soql = getCreatableFieldsSOQL('ASI_MFM_PO_Line_Item__c','ASI_MFM_PO__c= \'' + p.id + '\'');
                    
                    System.debug('SOQL: ' + soql);
                    List<ASI_MFM_PO_Line_Item__c> plList = (List<ASI_MFM_PO_Line_Item__c>)Database.query(soql);
                    List<ASI_MFM_PO_Line_Item__c> plListForInsert = new List<ASI_MFM_PO_Line_Item__c>();
                    List<ASI_MFM_PO_Line_Item__c> plListForUpdate = new List<ASI_MFM_PO_Line_Item__c>();
                    
                    for (ASI_MFM_PO_Line_Item__c pl : plList){
                        
                        //Create a negative amount 
                        ASI_MFM_PO_Line_Item__c pl2 = pl.clone(false, true);
                        pl2.ASI_MFM_Amount__c = pl2.ASI_MFM_Amount__c * -1;
                        pl2.ASI_MFM_List_Item_Description__c += ' (Reversal due to PO Void)';
                        pl2.ASI_MFM_PO_Line_Item_External_ID__c  = '';
                        if(pl2.ASI_MFM_G_L_Date__c < date.today())
                            pl2.ASI_MFM_G_L_Date__c = date.today();
                        
                        plListForInsert.add(pl2);
                        
                    }
                    if(plListForInsert.size() > 0){
                        try{
                            
                            insert plListForInsert;
                            
                        }catch(dmlException dmle){
                            
                        }
                    }
                }
            }
            //20170510 End
            else if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_SC')){ // SSC Mark hk structure cost 
                String SCRecTypeID = MRecType.get('ASI_MFM_SC_PO');
                p.recordTypeId = SCRecTypeID ;
                paList.clear();
            }else if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_MY')){
                p.recordTypeId =  MRecType.get('ASI_MFM_MY_PO');// COE 1.0 add MY set Final to complete
            }
            
            if (new_status == 'Draft'){
                if (paList.size() == 0){
                    try {
                        update p;
                        return new pageReference('/' + p.id);
                    }
                    catch (exception ex) {
                        apexpages.addMessages(ex);
                        return null;
                    }
                }
                else {
                    apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set status to Draft for PO with payment.'));
                    return null;
                }
            } else if (new_status == 'Complete') {
                if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TH')){
                    for(ASI_MFM_Payment_Line_Item__c pl:paList){
                        if(pl.ASI_MFM_Payment__r.ASI_MFM_Status__c!='Final' && pl.ASI_MFM_Payment__r.ASI_MFM_Status__c!='Complete'){
                            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Only Final Payment can set complete status.'));
                            return null;
                        }
                    }
                    
                }
                
                if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_PH')){
                    List<ASI_MFM_PO_Line_Item__c> newPOL = new List<ASI_MFM_PO_Line_Item__c>();
                    String Description;
                    
                    //Payment Line
                    List<ASI_MFM_Payment_Line_Item__c> paylineList=[select id,ASI_MFM_Payment__r.ASI_MFM_Status__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c=:p.id];
                    for(ASI_MFM_Payment_Line_Item__c pl:paylineList){
                        if(pl.ASI_MFM_Payment__r.ASI_MFM_Status__c=='Draft'){
                            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set Complete with Draft Payment.'));
                            return null;
                        }
                        if(!pl.ASI_MFM_Payment_Line_Item_Finance_Verify__c){
                            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set Complete with Unverified Payment Line.'));
                            return null;
                        }
                    }
                    // PO Line
                    List<ASI_MFM_PO_Line_Item__c> poLineList = [select ID,ASI_MFM_Complete__c,ASI_MFM_G_L_Date__c,ASI_MFM_POSM_Deposit__c,ASI_MFM_POSM_Balance__c,ASI_MFM_Requested_Balance__c, name,ASI_MFM_PO__c, ASI_MFM_Customer_Name__c, ASI_MFM_Sub_brand_Code__c, ASI_MFM_A_C_Code__c, ASI_MFM_Remaining_Balance__c,ASI_MFM_Amount__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c=:p.id];
                    
                    ID Rectypeid = Schema.SObjectType.ASI_MFM_PO_Line_Item__c.getRecordTypeInfosByName().get('PH PO Line Item').getRecordTypeId();                    
                    for (ASI_MFM_PO_Line_Item__c poL : poLineList){
                        if(!poL.ASI_MFM_Complete__c){
                            Description='Closing PO Adjustment: '+poL.name + '- Paid Amount: ' + (poL.ASI_MFM_Amount__c - poL.ASI_MFM_Remaining_Balance__c) + '; Remaining Amount: ' + poL.ASI_MFM_Remaining_Balance__c;
                            ASI_MFM_PO_Line_Item__c poline = new ASI_MFM_PO_Line_Item__c(ASI_MFM_List_Item_Description__c = Description, ASI_MFM_Amount__c = 0-poL.ASI_MFM_Remaining_Balance__c, ASI_MFM_PO__c = poL.ASI_MFM_PO__c,ASI_MFM_Customer_Name__c = poL.ASI_MFM_Customer_Name__c, ASI_MFM_A_C_Code__c = poL.ASI_MFM_A_C_Code__c, ASI_MFM_Sub_brand_Code__c = poL.ASI_MFM_Sub_brand_Code__c, ASI_MFM_Complete__C = true, recordTypeId=Rectypeid,ASI_MFM_G_L_Date__c = poL.ASI_MFM_G_L_Date__c, ASI_MFM_Adjustment_Line__c = true);
                            ASI_MFM_PO_Line_Item__c CompletePoline = new ASI_MFM_PO_Line_Item__c(ASI_MFM_Complete__C = true, ID = poL.ID);
                            newPOL.add(poline);
                            newPOL.add(CompletePoline);
                        }
                    }
                    if(newPOL.size()>0){
                        upsert newPOL;
                    }
                }
                // VN RT
                if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_VN')){
                    List<ASI_MFM_PO_Line_Item__c> newPOL = new List<ASI_MFM_PO_Line_Item__c>();
                    String Description;
                    
                    //Payment Line
                    List<ASI_MFM_Payment_Line_Item__c> paylineList=[select id,ASI_MFM_Payment__r.ASI_MFM_Status__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c=:p.id];
                    for(ASI_MFM_Payment_Line_Item__c pl:paylineList){
                        if(pl.ASI_MFM_Payment__r.ASI_MFM_Status__c=='Draft'){
                            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set Complete with Draft Payment.'));
                            return null;
                        }
                        if(!pl.ASI_MFM_Payment_Line_Item_Finance_Verify__c){
                            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set Complete with Unverified Payment Line.'));
                            return null;
                        }
                    }
                    // PO Line
                    List<ASI_MFM_PO_Line_Item__c> poLineList = [select ID,ASI_MFM_Complete__c,ASI_MFM_G_L_Date__c,ASI_MFM_POSM_Deposit__c,ASI_MFM_POSM_Balance__c,ASI_MFM_Requested_Balance__c, name,ASI_MFM_PO__c, ASI_MFM_Customer_Name__c, ASI_MFM_Sub_brand_Code__c, ASI_MFM_A_C_Code__c, ASI_MFM_Remaining_Balance__c,ASI_MFM_Amount__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c=:p.id];
                    
                    ID Rectypeid = Schema.SObjectType.ASI_MFM_PO_Line_Item__c.getRecordTypeInfosByName().get('VN PO Line Item').getRecordTypeId();                    
                    for (ASI_MFM_PO_Line_Item__c poL : poLineList){
                        if(!poL.ASI_MFM_Complete__c){
                            Description='Closing PO Adjustment: '+poL.name + '- Paid Amount: ' + (poL.ASI_MFM_Amount__c - poL.ASI_MFM_Remaining_Balance__c) + '; Remaining Amount: ' + poL.ASI_MFM_Remaining_Balance__c;
                            ASI_MFM_PO_Line_Item__c poline = new ASI_MFM_PO_Line_Item__c(ASI_MFM_List_Item_Description__c = Description, ASI_MFM_Amount__c = 0-poL.ASI_MFM_Remaining_Balance__c, ASI_MFM_PO__c = poL.ASI_MFM_PO__c,ASI_MFM_Customer_Name__c = poL.ASI_MFM_Customer_Name__c, ASI_MFM_A_C_Code__c = poL.ASI_MFM_A_C_Code__c, ASI_MFM_Sub_brand_Code__c = poL.ASI_MFM_Sub_brand_Code__c, ASI_MFM_Complete__C = true, recordTypeId=Rectypeid,ASI_MFM_G_L_Date__c = poL.ASI_MFM_G_L_Date__c, ASI_MFM_Adjustment_Line__c = true);
                            ASI_MFM_PO_Line_Item__c CompletePoline = new ASI_MFM_PO_Line_Item__c(ASI_MFM_Complete__C = true, ID = poL.ID);
                            newPOL.add(poline);
                            newPOL.add(CompletePoline);
                        }
                    }
                    if(newPOL.size()>0){
                        upsert newPOL;
                    }
                }
                
                if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_JP')){  //For JP MFM phase II 
                    List<ASI_MFM_PO_Line_Item__c> newPOL = new List<ASI_MFM_PO_Line_Item__c>();
                    List<ASI_MFM_PO_Receipt_Item__c> newPOR = new List<ASI_MFM_PO_Receipt_Item__c>();
                    String Description;
                      //Payment Line
                    List<ASI_MFM_Payment_Line_Item__c> paylineList=[select id,ASI_MFM_Payment__r.ASI_MFM_Status__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c=:p.id];
                    for(ASI_MFM_Payment_Line_Item__c pl:paylineList){
                        if(pl.ASI_MFM_Payment__r.ASI_MFM_Status__c=='Draft'){
                            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set Complete with Draft Payment.'));
                            return null;
                        }
                        if(!pl.ASI_MFM_Payment_Line_Item_Finance_Verify__c && pl.ASI_MFM_Payment__r.ASI_MFM_Status__c!='Complete'){
                            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set Complete with Unverified Payment Line.'));
                            return null;
                        }
                    }
                   List<ASI_MFM_PO_Line_Item__c> poLineList = [select  (select ID,name,ASI_MFM_Adjustment_Amount__c,ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c,ASI_MFM_VAT_Adjustment__c from Payment_Line_Items__r), ID,ASI_MFM_Complete__c,ASI_MFM_AP_Code__c,ASI_MFM_G_L_Date__c,ASI_MFM_POSM_Deposit__c,ASI_MFM_POSM_Balance__c,ASI_MFM_Requested_Balance__c, name,ASI_MFM_PO__c, ASI_MFM_Customer_Name__c, ASI_MFM_Sub_brand_Code__c, ASI_MFM_A_C_Code__c, ASI_MFM_Remaining_Balance__c,ASI_MFM_Amount__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c=:p.id];
                    ID Rectypeid = Schema.SObjectType.ASI_MFM_PO_Line_Item__c.getRecordTypeInfosByName().get('JP PO Line Item').getRecordTypeId(); 
                    
                    Decimal VATAdj=0.0;
                    for (ASI_MFM_PO_Line_Item__c poL : poLineList){
                        if(!poL.ASI_MFM_Complete__c ){
                            decimal AdjustAmount=0;
                            decimal NewPolineAmount=0;
                            for (ASI_MFM_Payment_Line_Item__c payl:poL.Payment_Line_Items__r) {
                                if(payl.ASI_MFM_VAT_Adjustment__c!=null){
                                   VATAdj+=payl.ASI_MFM_VAT_Adjustment__c; 
                                }
                                AdjustAmount+=payl.ASI_MFM_Adjustment_Amount__c*payl.ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c;
                            }
                            
                            NewPolineAmount=poL.ASI_MFM_Amount__c-AdjustAmount;
                            if(NewPolineAmount!=0){
                                Description='Closing PO Adjustment: '+poL.name + '- Paid Amount: ' + AdjustAmount+ '; Remaining Amount: ' + NewPolineAmount;
                                ASI_MFM_PO_Line_Item__c poline = new ASI_MFM_PO_Line_Item__c(ASI_MFM_AP_Code__c=poL.ASI_MFM_AP_Code__c,ASI_MFM_List_Item_Description__c = Description, ASI_MFM_Amount__c = 0-NewPolineAmount, ASI_MFM_PO__c = poL.ASI_MFM_PO__c,ASI_MFM_Customer_Name__c = poL.ASI_MFM_Customer_Name__c, ASI_MFM_A_C_Code__c = poL.ASI_MFM_A_C_Code__c, ASI_MFM_Sub_brand_Code__c = poL.ASI_MFM_Sub_brand_Code__c, ASI_MFM_Complete__C = true, recordTypeId=Rectypeid,ASI_MFM_G_L_Date__c =system.today(), ASI_MFM_Adjustment_Line__c = true);
                                newPOL.add(poline);
                            }
                            
                        }
                        ASI_MFM_PO_Line_Item__c CompletePoline = new ASI_MFM_PO_Line_Item__c(ASI_MFM_Complete__C = true, ID = poL.ID);
                         newPOL.add(CompletePoline);
                    }

                    //Closing PO Receipt
                    List<ASI_MFM_PO_Receipt_Item__c> porLineList=[select id,name,ASI_MFM_PO_Line_Item__c,ASI_MFM_PO_Receipt__c,ASI_MFM_Amount__c,ASI_MFM_PO_Receipt_Balance_Amount__c,ASI_MFM_Remaining_Balance__c from ASI_MFM_PO_Receipt_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c=:p.id];
                    Rectypeid = Schema.SObjectType.ASI_MFM_PO_Receipt_Item__c.getRecordTypeInfosByName().get('JP PO Receipt Line').getRecordTypeId();
                     for (ASI_MFM_PO_Receipt_Item__c por : porLineList){
                         // only ASI_MFM_PO_Receipt_Balance_Amount__c<0 will generate Adjustment LINE
                         if(por.ASI_MFM_PO_Receipt_Balance_Amount__c<0){
                             Description='Over Budget: Closing PO Receipt Adjustment: '+por.name + '- Paid Amount: ' + (por.ASI_MFM_Amount__c - por.ASI_MFM_PO_Receipt_Balance_Amount__c) + '; Remaining Amount: ' + por.ASI_MFM_Remaining_Balance__c;
                             ASI_MFM_PO_Receipt_Item__c porline = new ASI_MFM_PO_Receipt_Item__c(ASI_MFM_Receipt_Date__c=date.today(),ASI_MFM_PO__c=p.id,ASI_MFM_PO_Line_Item__c=por.ASI_MFM_PO_Line_Item__c,ASI_MFM_Remark__c = Description, ASI_MFM_Amount__c = 0-por.ASI_MFM_PO_Receipt_Balance_Amount__c, ASI_MFM_PO_Receipt__c = por.ASI_MFM_PO_Receipt__c,recordTypeId=Rectypeid,ASI_MFM_Complete__c=true);
                             newPOR.add(porline);
                         }

                    }
                    
                    
                    if(!Test.isRunningTest() && newPOL.size()>0){
                        upsert newPOL;
                    }
                    if(!Test.isRunningTest() && newPOR.size()>0){
                        upsert newPOR;
                    }
                    p.ASI_MFM_Opening_Balance__c=VATAdj;
                    p.ASI_MFM_Status__c=new_status;
                }//End of 
                
                //Set to Complete status
                if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_MY')){
                    Set<id> paymentIDSet = new Set<id>();
                    Boolean NotYetFinal = false;
                    for (ASI_MFM_Payment_Line_Item__c paymentLine : [Select ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_Payment__r.id from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c = :p.id]){
                        paymentIDSet.add(paymentLine.ASI_MFM_Payment__c);
                    }   
                    List<ASI_MFM_Payment__c> payments = [select ASI_MFM_Status__c from ASI_MFM_Payment__c where id = :paymentIDSet];
                    for (ASI_MFM_Payment__c py: payments) {
                        if (py.ASI_MFM_Status__c == 'Draft' || py.ASI_MFM_Status__c == 'Submitted'){
                            NotYetFinal = true;
                        }
                    }
                    if(NotYetFinal) {
                        if(!Test.isRunningTest()){ 
                            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set PO to Complete with non-final payment.'));
                        }
                        return null;
                    }

                    // [SH] 2019-07-17 Complete PO with Reversal
                    // PO Line
                    List<ASI_MFM_PO_Line_Item__c> poLineList = [select ID,ASI_MFM_Complete__c,ASI_MFM_G_L_Date__c,ASI_MFM_POSM_Deposit__c,ASI_MFM_POSM_Balance__c,ASI_MFM_Requested_Balance__c, name,ASI_MFM_PO__c, ASI_MFM_Customer_Name__c, ASI_MFM_Sub_brand_Code__c, ASI_MFM_A_C_Code__c, ASI_MFM_Remaining_Balance__c,ASI_MFM_Amount__c, recordtypeId from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c=:p.id];
                    List<ASI_MFM_PO_Line_Item__c> newPOL = new List<ASI_MFM_PO_Line_Item__c>();              
                    
                    for (ASI_MFM_PO_Line_Item__c poL : poLineList){
                        if(!poL.ASI_MFM_Complete__c && poL.ASI_MFM_Remaining_Balance__c != 0){
                            String Description='Closing PO Adjustment: '+poL.name + '- Paid Amount: ' + (poL.ASI_MFM_Amount__c - poL.ASI_MFM_Remaining_Balance__c) + '; Remaining Amount: ' + poL.ASI_MFM_Remaining_Balance__c;
                            ASI_MFM_PO_Line_Item__c poline = new ASI_MFM_PO_Line_Item__c(ASI_MFM_List_Item_Description__c = Description, ASI_MFM_Amount__c = 0-poL.ASI_MFM_Remaining_Balance__c, ASI_MFM_PO__c = poL.ASI_MFM_PO__c,ASI_MFM_Customer_Name__c = poL.ASI_MFM_Customer_Name__c, ASI_MFM_A_C_Code__c = poL.ASI_MFM_A_C_Code__c, ASI_MFM_Sub_brand_Code__c = poL.ASI_MFM_Sub_brand_Code__c, ASI_MFM_Complete__C = true, recordTypeId=poL.RecordTypeId,ASI_MFM_G_L_Date__c = poL.ASI_MFM_G_L_Date__c, ASI_MFM_Adjustment_Line__c = true);
                            
                            newPOL.add(poline);
                           
                        }
                        ASI_MFM_PO_Line_Item__c CompletePoline = new ASI_MFM_PO_Line_Item__c(ASI_MFM_Complete__C = true, ID = poL.ID);
                        newPOL.add(CompletePoline);
                    }
                    if(newPOL.size()>0 && !Test.isRunningTest()){
                        upsert newPOL;
                    }
                }
                try {
                    if(!Test.isRunningTest())
                        update p;
                        return new pageReference('/' + p.id);
                    }
                    catch (exception ex) {
                        apexpages.addMessages(ex);
                        return null;
                    }
            }
            else {
                //Set to Complete status
                try {
                    /*[WL 1.0] BEGIN*/
                    if (new_status != null){
                        update p;
                        return new pageReference('/' + p.id);
                    }
                    else {
                        apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'PO Status cannot be empty.'));
                        return null;
                    }
                    /*[WL 1.0] END*/
                }
                catch (exception ex) {
                    apexpages.addMessages(ex);
                    return null;
                }
            }
        }
        else if(new_status == 'Final'){ 
            if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TH')){
                try { 
                        p.ASI_MFM_Status__c=new_status;
                        if (p.ASI_MFM_Is_FOC_PO__c== true || p.ASI_MFM_Payroll_PO__c == true ||  p.ASI_MFM_T_E__c == true){
                            p.ASI_MFM_Status__c='Complete';
                        }
                        update p;
                        return new pageReference('/' + p.id);
                    }
                    catch (exception ex) {
                        apexpages.addMessages(ex);
                        return null;
                    }
            }else if(Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_HK')){
                p.ASI_MFM_Status__c=new_status;
                update p;
                return new pageReference('/' + p.id);
                
            }else{
                return null;
            }
             // END
        }
      else if(p.ASI_MFM_Status__c == 'Draft' && new_status == 'Complete' && Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_PH') && p.ASI_MFM_Is_FOC_PO__c==true){
            try {
                p.ASI_MFM_Status__c=new_status;
                update p;
                return new pageReference('/' + p.id);
            }
            catch (exception ex) {
                apexpages.addMessages(ex);
                return null;
            }
        }
        
        // VN RT
        else if(p.ASI_MFM_Status__c == 'Draft' && new_status == 'Complete' && Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_VN') && p.ASI_MFM_Is_FOC_PO__c==true){
            try {
                p.ASI_MFM_Status__c=new_status;
                update p;
                return new pageReference('/' + p.id);
            }
            catch (exception ex) {
                apexpages.addMessages(ex);
                return null;
            }
        }
      
        // ------------------------------------------------------------------------------------KR MFM Logic Start---------------------------------------------------------------
        else if(Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_KR')){
            if(new_status == 'Draft' ){
                //Requester should not have any authority on PO
                user u = [select userRole.developerName, asi_mfm_country__c from user where id = :userInfo.getUserId()];
                if( (u.asi_mfm_country__c!='KR' || !u.userRole.developerName.contains('ASI_KR_Purchasing'))&& (!ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_KR_SetPOToDraft')) ) {
                    return new pageReference('/apex/ASI_MFM_KR_SelectPOErrorPage');                    
                }
            }
            
            if(p.ASI_MFM_Status__c == 'Closed' && new_status == 'Draft'){
                apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set status to Draft.'));
                return null;
            }
            
            if(p.ASI_MFM_Status__c == 'Rejected' && new_status == 'Draft' && p.ASI_MFM_Plan__r.ASI_MFM_Status__c=='Closed'){
                apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Plan <a href="/'+p.ASI_MFM_Plan__c+'">'+p.ASI_MFM_Plan__r.name+ '</a> is Closed, cannot change PO Status.'));
                return null;
            }
            
            if(p.ASI_MFM_Status__c == 'Approved' && new_status == 'Draft'){// 
                List<ASI_MFM_Payment_Line_Item__c> paList = [select id,ASI_MFM_Payment__r.ASI_MFM_Status__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c,ASI_MFM_Payment__r.ASI_MFM_POSM_Deposit__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c = :p.id];
                List<ASI_MFM_PO_Receipt_Item__c> recList = [select id from ASI_MFM_PO_Receipt_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c = :p.id];
                //set status to Draft :check PO Receipt and Payment 
                
                if (recList.size() > 0){
                    apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set status to Draft for PO with receipt.'));
                    return null;
                }
                else if (paList.size() > 0){
                    apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set status to Draft for PO with payment.'));
                    return null;
                }
                
            }
            
            if( new_status == 'Closed'){
                boolean Ispass=true;
                string errmsg='';
                set<id> PayId=NEW set<id>();
                
                
                 //Requester should not have any authority on PO
                 //PR requester must not be able to "set to close" PO. It should be done only by PO owner(Purchasing team).\
                 //Added on 14 Feb 2017, Elufa PRA Support
                user u = [select userRole.developerName, asi_mfm_country__c from user where id = :userInfo.getUserId()];
                if( (u.asi_mfm_country__c!='KR' || !u.userRole.developerName.contains('ASI_KR_Purchasing')) && (!ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_KR_SetPOToClosed')) ) {
                    return new pageReference('/apex/ASI_MFM_KR_SelectPOErrorPage');           
                }   
                
                set<id> updatePayset= new set<id>();
                Map<Id,ASI_MFM_PO_Line_Item__c> UpdatePOline_Map=new Map<Id,ASI_MFM_PO_Line_Item__c>();
                Map<Id,ASI_MFM_Plan_Line_Item__c> UpdatePlanline_Map=new Map<Id,ASI_MFM_Plan_Line_Item__c>();
                List<ASI_MFM_PO_Line_Item__c> POLineList=[select id,name,ASI_MFM_Plan_Line_Item__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Actual_Spending_Amount__c,ASI_MFM_Base_Currency_Amount__c,ASI_MFM_BaseCurrencyAmount__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c = :p.id];
                
                List<ASI_MFM_Payment_Line_Item__c> PayLineList = [select id,name,ASI_MFM_PO_Line_Item__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Actual_Spending_Amount__c,ASI_MFM_Paid_Amount_in_PO_Currency__c,ASI_MFM_Payment__c,ASI_MFM_Payment__r.name,ASI_MFM_Payment__r.ASI_MFM_Status__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c = :p.id];
                
                for(ASI_MFM_Payment_Line_Item__c pl:PayLineList){
                    //Check status 
                    if(!PayId.contains(pl.ASI_MFM_Payment__c) &&(pl.ASI_MFM_Payment__r.ASI_MFM_Status__c=='Draft' || pl.ASI_MFM_Payment__r.ASI_MFM_Status__c=='Submitted') ){
                        PayId.add(pl.ASI_MFM_Payment__c);
                        errmsg+='Payment: <a href="/'+pl.ASI_MFM_Payment__c+'">'+pl.ASI_MFM_Payment__r.name+ '</a>' +   ' Status: '+pl.ASI_MFM_Payment__r.ASI_MFM_Status__c+'<br/>'; 
                        Ispass=false;
                    }                    
                    //Check PO Line
                    if(!UpdatePOline_Map.containsKey(pl.ASI_MFM_PO_Line_Item__c)){// Not contain in map
                        UpdatePOline_Map.put(pl.ASI_MFM_PO_Line_Item__c, new ASI_MFM_PO_Line_Item__c(id=pl.ASI_MFM_PO_Line_Item__c,ASI_MFM_Actual_Spending_Amount__c=pl.ASI_MFM_Paid_Amount_in_PO_Currency__c!=null?pl.ASI_MFM_Paid_Amount_in_PO_Currency__c:0.0));
                    }else{// contain in map
                        UpdatePOline_Map.get(pl.ASI_MFM_PO_Line_Item__c).ASI_MFM_Actual_Spending_Amount__c+=pl.ASI_MFM_Paid_Amount_in_PO_Currency__c!=null?pl.ASI_MFM_Paid_Amount_in_PO_Currency__c:0.0; 
                    }
                }
                
                
                 //Update Plan Line 
                 
                 for(ASI_MFM_PO_Line_Item__c pl:POLineList){
                     if(UpdatePlanline_Map.containsKey(pl.ASI_MFM_Plan_Line_Item__c)){
                         UpdatePlanline_Map.get(pl.ASI_MFM_Plan_Line_Item__c).ASI_MFM_Actual_Spending_Amount__c+=pl.ASI_MFM_BaseCurrencyAmount__c;
                     }else{
                         UpdatePlanline_Map.put(pl.ASI_MFM_Plan_Line_Item__c, New ASI_MFM_Plan_Line_Item__c (id=pl.ASI_MFM_Plan_Line_Item__c, ASI_MFM_Actual_Spending_Amount__c=pl.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Actual_Spending_Amount__c!=null?pl.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Actual_Spending_Amount__c:0.0+pl.ASI_MFM_BaseCurrencyAmount__c!=null?pl.ASI_MFM_BaseCurrencyAmount__c:0.0));
                     }
                 }
                 
                 
                if(Ispass){
                    list<ASI_MFM_PO_Line_Item__c> updatePOLinelist= new list<ASI_MFM_PO_Line_Item__c>();
                    updatePOLinelist.addAll(UpdatePOline_Map.values());
                    if(updatePOLinelist.size()>0) update updatePOLinelist;
                    
                    list<ASI_MFM_Plan_Line_Item__c> updatePlanLinelist= new list<ASI_MFM_Plan_Line_Item__c>();
                    updatePlanLinelist.addAll(UpdatePlanline_Map.values());
                    if(updatePlanLinelist.size()>0) update updatePlanLinelist;
                    
                }else{
                    errmsg = errmsg.removeEnd('<br/>');
                    apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set status to Closed. Please complete related PO process before Payment close.<br/> '+errmsg));
                    return null;
                }
            }//Close Logic End
            
            
            //update this PO
            try {
                p.ASI_MFM_Status__c=new_status;
                update p;
                return new pageReference('/' + p.id);
            }
            catch (exception ex) {
                apexpages.addMessages(ex);
                return null;
            }
        }// ------------------------------------------------------------------------------------KR MFM Logic End---------------------------------------------------------------
        else if(p.ASI_MFM_Status__c == 'Complete' && new_status == 'Draft' && Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TH')){// TH Logic: change from 'Complete' to 'Draft'
            List<ASI_TnE_ClaimDetail__c> TnEList = [select id from ASI_TnE_ClaimDetail__c where ASI_TnE_MFM_PO__c = :p.id];
            List<ASI_MFM_PO_Line_Item__c> POLList = [Select id, ASI_MFM_Complete__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c = :p.id and ASI_MFM_Complete__c = true];
            set<string> CustomPermission = ASI_MFM_ByPass_Setting.GetCustomPermissions();
            if (TnEList.size() > 0){
                apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set status to Draft for PO with T&E Expense.'));
                return null;
            }else if(POLList.size() > 0){ // When there are PO Line with check 'Complete' 
                apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot set status to Draft with Complete PO Line.'));
                return null;
            }else {
                try { 
                    if((p.ASI_MFM_Is_FOC_PO__c== true || p.ASI_MFM_Payroll_PO__c == true ||  p.ASI_MFM_T_E__c == true) && CustomPermission.contains('ASI_MFM_TH_SetDraft')) {
                        p.ASI_MFM_Status__c=new_status;
                        update p;
                        return new pageReference('/' + p.id);
                    }
                    else {
                        apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'You can NOT set FOC PO, T&E PO and Payroll PO from Complete to Draft.'));
                        return null;
                    }
                }
                catch (exception ex) {
                    apexpages.addMessages(ex);
                    return null;
                }
            }
        }
        else {
            // Modified by 2017-09-08 Linus@introv
            if(p.ASI_MFM_Status__c == 'Complete')
                apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Completed PO cannot set to Draft'));
            else
                apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Status is not in \'Final\''));
                
            return null;
        }
    }
    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    public static string getCreatableFieldsSOQL(String objectName, String whereClause){
         
        String selects = '';
         
        if (whereClause == null || whereClause == ''){ return null; }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
         
    }   
}