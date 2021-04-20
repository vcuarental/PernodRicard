/*
Create at 201905
Extension class for ASI_MFM_CN_MassCreateAndUpdateFast Comp.
This compontent used in ASI_MFM_CN_InputPOItemsPage Only

Override function commitAll() from ASI_MFM_MassCreateAndUpdateController
Remove localized recordType checking except CN recordType
*/ 

public class ASI_MFM_CN_MassCreateAndUpdateExtCtrl {
    

    private ASI_MFM_MassCreateAndUpdateController controller {set;get;}
    @testVisible
    private Map<id,decimal> last_planline_balanceMap;
    @testVisible
    private decimal last_plan_balance;
    private boolean negative_pol_balance = false;
    
    public ASI_MFM_CN_MassCreateAndUpdateExtCtrl(ASI_MFM_MassCreateAndUpdateController ctrl) {
        controller = ctrl;
		last_planline_balanceMap = new Map<id,decimal>();
    }
    
    public PageReference commitAll(){
        ASI_MFM_PO__c objPO = controller.objPO;
        List<ASI_MFM_MassCreateAndUpdateController.interimData> results = controller.results;
        List <ASI_MFM_Sub_brand_Allocation__c> delItemList = controller.delItemList;
        List<ASI_MFM_MassCreateAndUpdateController.RecordTypeElement> theRecordTypeElementList = controller.theRecordTypeElementList;
        String sObjTypeStr = controller.sObjTypeStr;
        
        
        //For sub-brand allocation
        if(objPO != null && (objPO.RecordType.DeveloperName == 'ASI_MFM_CN_PO' || objPO.RecordType.DeveloperName == 'ASI_MFM_CN_PO_Read_Only')){
            Decimal decSBPercentage = 0;
            Set<id> setExistSubBrandID = new Set<id>();
            Set<id> setSBId = new Set<Id>();
            Map<id, ASI_MFM_Sub_brand__c> mapSB = new Map<id, ASI_MFM_Sub_brand__c>();
            List<ASI_MFM_Sub_brand_Allocation__c> saveItemList = new List<ASI_MFM_Sub_brand_Allocation__c>();
            
            for(ASI_MFM_MassCreateAndUpdateController.interimData r : results){
                setSBId.add(r.ppl.ASI_MFM_Sub_brand_Code__c);
            }
            List<ASI_MFM_Sub_brand__c> listSB = [SELECT id, name FROM ASI_MFM_Sub_brand__c WHERE id IN: setSBId];
            for(ASI_MFM_Sub_brand__c sb : listSB){
                mapSB.put(sb.id, sb);
            }            
            
            for(ASI_MFM_MassCreateAndUpdateController.interimData r : results){
                ASI_MFM_Sub_brand_Allocation__c ppl = new ASI_MFM_Sub_brand_Allocation__c();
                ppl = r.ppl;
                ppl.name = mapSB.get(r.ppl.ASI_MFM_Sub_brand_Code__c).name;
                saveItemList.add(ppl);
            }           
            for(ASI_MFM_MassCreateAndUpdateController.interimData r: results){
                if(r.ppl != null){
                    if(r.ppl.ASI_MFM_Sub_brand_percentage__c == null)
                        r.ppl.ASI_MFM_Sub_brand_percentage__c = 0;
                    
                    decSBPercentage += r.ppl.ASI_MFM_Sub_brand_percentage__c;               
                }
            }
            if(decSBPercentage != 0 && decSBPercentage != 100){
                apexpages.addMessage(new apexpages.message(apexpages.severity.error, 'Total allocation percentage should be either 0% or 100%.')); 
                return null;
            }
                        
            try{
                upsert saveItemList;
                
                if(delItemList != null && delItemList.size() > 0){
                    delete delItemList;
                    delItemList.clear();
                }
            }catch(DmlException dmle){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,dmle.getMessage()));
                return null;
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
                return null;
            } 
        }
        //For sub-brand allocation - End
        
        List<sObject> insertList = new List<sObject>();
        List<sObject> updateList = new List<sObject>();
        List<sObject> deleteList = new List<sObject>();
        for (ASI_MFM_MassCreateAndUpdateController.RecordTypeElement rtEle : theRecordTypeElementList) {
            for (ASI_MFM_MassCreateAndUpdateController.TableRow tr : rtEle.myRecordList) {
                if (!tr.isBlankAndHidden) {
                    if (tr.isDelete) {
                        if (tr.mySObj.Id != null)
                            deleteList.add(tr.mySObj);
                    } else if (tr.isNew) {
                        if (tr.mySObj.getsObjectType() == asi_mfm_po_line_item__c.sObjectType) {
                            tr.mySObj = asi_mfm_POLineItem.setAmount((asi_mfm_po_line_item__c)tr.mySObj);
                        }
                        insertList.add(tr.mySObj.clone(false, true)); 
                    } else if (tr.isEdit) {
                        updateList.add(tr.mySObj);
                    }
                }
            }
        }
        System.Savepoint sp = database.setSavepoint();

        if (deleteList.size() > 0) {
            try {
                database.delete(deleteList);
            } catch (DmlException dmle) {
                Integer numOfError = dmle.getNumDml();
                for (Integer i = 0; i < numOfError; i++) {
                    sObject errorSObj = deleteList.get(dmle.getDmlIndex(i));
                    errorSObj.addError(formatMsg(dmle.getDmlMessage(i)));
                }
                database.rollback(sp);
                return null;
            }
        }
        if (updateList.size() > 0) {
            try { 
                database.update(updateList);
            } catch (DmlException dmle) {
                Integer numOfError = dmle.getNumDml();
                for (Integer i = 0; i < numOfError; i++) {
                    sObject errorSObj = updateList.get(dmle.getDmlIndex(i));
                    errorSObj.addError(formatMsg(dmle.getDmlMessage(i)));                  
                }
                database.rollback(sp);
                return null;
            }
        }
        if (insertList.size() > 0) {
            try {  
                database.insert(insertList);
            } catch (DmlException dmle) {
                Integer numOfError = dmle.getNumDml();
                for (Integer i = 0; i < numOfError; i++) {
                    sObject errorSObj = insertList.get(dmle.getDmlIndex(i));
                    errorSObj.addError(formatMsg(dmle.getDmlMessage(i)));
                }
                database.rollback(sp);
                return null;
            }
        }        
        // Custom change starts
        if (sObjTypeStr == 'ASI_MFM_PO_Line_Item__c') {
            //Modified by Wilken on 20130924, HK MFM need hard error to block PO Amt > Plan Amt
            //Original SOQL
            
            //20190715@AM Introv - replace soft warning to show continuously
            List<string> oErrorMsg = new List<string>();
            
            ASI_MFM_PO__c po = [select ASI_MFM_Plan__c, ASI_MFM_Plan__r.ASI_MFM_Plan_Balance__c, RecordType.DeveloperName from ASI_MFM_PO__c where id = :apexpages.currentPage().getParameters().get('id')];
            if (po.ASI_MFM_Plan__r.ASI_MFM_Plan_Balance__c < 0 && po.ASI_MFM_Plan__r.ASI_MFM_Plan_Balance__c != last_plan_balance) {
                System.debug('PO Record Type Name: ' + po.RecordType.DeveloperName);
                if (last_plan_balance == null) {
                    //apexpages.addMessage(new apexpages.message(apexpages.severity.warning, 
                    //                                           'Total PO amount exceeds the available plan balance. Click "Save All" button again if want to proceed. Click "Cancel" button if do not want to proceed.'));
                    oErrorMsg.add('Total PO amount exceeds the available plan balance. Click "Save All" button again if want to proceed. Click "Cancel" button if do not want to proceed.');                 
                }
                else {
                    //apexpages.addMessage(new apexpages.message(apexpages.severity.warning, 
                    //                                           'Total PO amount still exceeds the available plan balance after you made changes. Click "Save All" button again if want to proceed. Click "Cancel" button if do not want to proceed.'));                    
                	oErrorMsg.add('Total PO amount still exceeds the available plan balance after you made changes. Click "Save All" button again if want to proceed. Click "Cancel" button if do not want to proceed.');
                }
                last_plan_balance = po.ASI_MFM_Plan__r.ASI_MFM_Plan_Balance__c;
                //database.rollback(sp);
                //return null;                
                
            }
            //Edit CN checking on plan line amount Enoch Introv @201905
            if (po.RecordType.DeveloperName.contains('ASI_MFM_CN')){
                integer iLineCount = 1;
                
                for(ASI_MFM_Plan_Line_Item__c planline :[
                    SELECT id, name ,ASI_MFM_Remaining_Balance__c  FROM ASI_MFM_Plan_Line_Item__c 
                    WHERE ASI_MFM_Plan__c = :po.ASI_MFM_Plan__c
                    AND ASI_MFM_Remaining_Balance__c != null
                    AND ASI_MFM_Remaining_Balance__c<0
                ]) {
                    if(!last_planline_balanceMap.containsKey(planline.id)) {
                        system.debug('### planline.ASI_MFM_Remaining_Balance__c: ' + planline.ASI_MFM_Remaining_Balance__c);
                        last_planline_balanceMap.put(planline.id,planline.ASI_MFM_Remaining_Balance__c);
                        //apexpages.addMessage(new apexpages.message(apexpages.severity.warning, 
                        //                                           'Total PO Line amount exceeds the available plan balance. Click "Save All" button again if want to proceed. Click "Cancel" button if do not want to proceed.'));                 
                        oErrorMsg.add('[#'+ iLineCount +'] '+'Total PO Line amount exceeds the available plan balance. Click "Save All" button again if want to proceed. Click "Cancel" button if do not want to proceed.');
                        last_plan_balance = po.ASI_MFM_Plan__r.ASI_MFM_Plan_Balance__c;
                        //database.rollback(sp);
                        //return null;    
                    } else if(last_planline_balanceMap.get(planline.id) != planline.ASI_MFM_Remaining_Balance__c){
                        last_planline_balanceMap.put(planline.id,planline.ASI_MFM_Remaining_Balance__c);
                        //apexpages.addMessage(new apexpages.message(apexpages.severity.warning, 
                        //                                           'Total PO Line amount still exceeds the available plan balance after you made changes. Click "Save All" button again if want to proceed. Click "Cancel" button if do not want to proceed.'));                    
                        oErrorMsg.add('[#'+ iLineCount +'] '+'Total PO Line amount still exceeds the available plan balance after you made changes. Click "Save All" button again if want to proceed. Click "Cancel" button if do not want to proceed.');
                        last_plan_balance = po.ASI_MFM_Plan__r.ASI_MFM_Plan_Balance__c;
                        //database.rollback(sp);
                        //return null;    
                    }
                    
                    iLineCount++;
                }
            } 

            //20190715@AM Introv - replace soft warning to show continuously
            if (oErrorMsg.size() > 0) {
                string sErrorMsg = String.join(oErrorMsg, '<br/>');
                apexpages.addMessage(new apexpages.message(apexpages.severity.warning, sErrorMsg));                    
                database.rollback(sp);
                return null;   
            }
            
        }        
        else if (sObjTypeStr == 'ASI_MFM_Payment_Line_Item__c') {
            //Added by Michael Yip (Introv) Handle CN payment checking
            Set<id> SCNRecTypeID = new Set<id>();
            // Added by Conrad (LAPUTA) Handle CAPEX Payment
            Set<ID> CapRecTypeID = new Set<ID>();
            for(RecordType rec : Global_RecordTypeCache.getRtList('ASI_MFM_Payment_Line_Item__c')){
                if(rec.DeveloperName.contains('CN_Payment')){
                    SCNRecTypeID.add(rec.id);
                }
                if(rec.DeveloperName.contains('ASI_MFM_CAP_Payment')){
                    CapRecTypeID.add(rec.id);
                }
            }
            
            ASI_MFM_Payment__c py = [select name, ASI_MFM_Status__c, ASI_MFM_OCR__c, ASI_MFM_Payment_Amount__c,RecordType.DeveloperName , ASI_MFM_Is_Direct_Payment__c, (select  recordtypeid, ASI_MFM_PO_Line_Item__r.name, ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c from Payment_Line_Items__r) from ASI_MFM_Payment__c where id = :apexpages.currentPage().getParameters().get('id')];
            if (!negative_pol_balance) {
                string pol_list = '';
                boolean negativePOLCAPEX = false;
                Decimal paymentAmount = 0;
                for (ASI_MFM_Payment_Line_Item__c pyl:py.Payment_Line_Items__r) {
                    //Capex Logic
                    boolean capexSkipChecking = false;
                    if(CapRecTypeID.contains(pyl.recordtypeid))
                    {
                        // Only skip warning if SSC Finance is doing the changes
                        if(py.ASI_MFM_Status__c == 'Final'){
                            capexSkipChecking = true;
                        }
                    }
                    //End of Capex Logic
                    system.debug('###@@@ pyl.ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c : ' + pyl.ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c);
                    system.debug('###@@@ SCNRecTypeID.contains : ' + SCNRecTypeID.contains(pyl.recordtypeid));
                    system.debug('###@@@ capexSkipChecking : ' + capexSkipChecking);
                    if (pyl.ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c < 0 && !SCNRecTypeID.contains(pyl.recordtypeid) && !capexSkipChecking) {
                        negative_pol_balance = true;
                        if (!pol_list.contains(pyl.ASI_MFM_PO_Line_Item__r.name)) {
                            if (pol_list.length() > 0) {
                                pol_list += ', ';
                            }
                            pol_list += pyl.ASI_MFM_PO_Line_Item__r.name;
                        }
                    }
                    // For CAPEX, block user if total Payment amount greater than PO amount
                    if (pyl.ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c < 0 && CapRecTypeID.contains(pyl.recordtypeid) && !capexSkipChecking) {                        
                        negativePOLCAPEX = true;
                        if (!pol_list.contains(pyl.ASI_MFM_PO_Line_Item__r.name)) {
                            if (pol_list.length() > 0) {
                                pol_list += ', ';
                            }
                            pol_list += pyl.ASI_MFM_PO_Line_Item__r.name;
                        }
                    }
                }
                
                if (negativePOLCAPEX) {
                    apexpages.addMessage(new apexpages.message(apexpages.severity.FATAL, 'The total Payment Amount is greater than Amount in PO line item ' + pol_list + '. Please check'));                 
                    database.rollback(sp);
                    return null; 
                } 
                
                if (negative_pol_balance) {
                    apexpages.addMessage(new apexpages.message(apexpages.severity.warning, 
										'The remaining balance of PO line item ' + pol_list + ' is less than the payment amount. Click "Save All" button again if want to proceed. Click "Cancel" button if do not want to proceed.'));                 
                    database.rollback(sp);
                    return null;
                }                          
            }
        }
        // Custom change ends
        return new PageReference(controller.successLink);
    }
    
    // Custom change starts
    @TestVisible
    private string formatMsg(string msg) {
        if (msg.contains('duplicate value found: ASI_MFM_Sys_Deduplication_Key__c')) {
            msg = 'Duplicated Plan Line Items are detected. Please Adjust';
        }
        return msg;
    }
    // Custom change ends 
}