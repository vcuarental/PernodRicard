/*********************************************************************************
 * Name:			ASI_MFM_CAP_ConvertAccrual_Controller 
 * Description: 	Production Change Request for CAPEX/OPEX: Controller to delete related PO and Plan
 *                 	Payment to convert OCR Payment to Accrual
 * Test Class:		ASI_MFM_CAP_ConvertAccrual_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 04/12/2014       Laputa: Conrad          Created
 * 14/06/2017       Wilken Lee          	[WL 1.0] Default Payment Status as Manual Processed when converted to T&E
 *********************************************************************************/
public class ASI_MFM_CAP_ConvertAccrual_Controller{

    public ASI_MFM_Payment__c payment {get;set;}

    public ASI_MFM_CAP_ConvertAccrual_Controller (ApexPages.StandardController controller){
    
    }
    
    public PageReference Convert (){
    
        ID headerId = ApexPages.currentPage().getParameters().get('id');
        String actionType = ApexPages.currentPage().getParameters().get('actionType');
        this.payment = retrievePaymentHeader(headerId);
        
        Savepoint sp = Database.setSavepoint();
        
        //Convert Direct Payment or OCR Payment to Accrual Payment type, delete existing Payment Lines, PO Lines, PO, uncheck Payment Header OCR/Direct Payment flag to allow select accrual lines
        if(actionType == 'ConvertToAccrual' && (payment.ASI_MFM_OCR__c || payment.ASI_MFM_Is_Direct_Payment__c)) {
        
            
            
            try {
            
                List<ASI_MFM_Payment_Line_Item__c> paymentLinesToDelete = new List<ASI_MFM_Payment_Line_Item__c>();
                List<ASI_MFM_PO_Line_Item__c> poLinesToDelete = new List<ASI_MFM_PO_Line_Item__c>();
                List<ASI_MFM_PO__c> poToDelete = new List<ASI_MFM_PO__c>();
            
                Set<ID> poLinesIDSet = new Set<ID>();
                Set<ID> poIDSet = new Set<ID>();
            
                paymentLinesToDelete = [SELECT ID, name, ASI_MFM_PO_Line_Item__c FROM ASI_MFM_Payment_Line_Item__c WHERE ASI_MFM_Payment__c = : payment.id];
            
                for(ASI_MFM_Payment_Line_Item__c paymentLine : paymentLinesToDelete) {
                    poLinesIDSet.add(paymentLine.ASI_MFM_PO_Line_Item__c);
                }
            
                if (poLinesIDSet.size() > 0) {
                    poLinesToDelete = [SELECT ID, Name, ASI_MFM_PO__c FROM ASI_MFM_PO_Line_Item__c WHERE ID IN : poLinesIDSet];
                }
            
                for(ASI_MFM_PO_Line_Item__c poLine : poLinesToDelete) {
                    poIDSet.add(poLine.ASI_MFM_PO__c);
                }
            
                if (poIDSet.size() > 0) { 
                    poToDelete = [SELECT ID, Name FROM ASI_MFM_PO__c WHERE ID IN : poIDSet];
                }
            
                if (poLinesToDelete.size() > 0) {
                    delete poLinesToDelete;
                }
            
                if (poToDelete.size() > 0) {
                    delete poToDelete;
                }
            
                if (paymentLinesToDelete.size() > 0) {
                  //  delete paymentLinesToDelete;
                }
            
                payment.ASI_MFM_OCR__c = false;
                payment.ASI_MFM_Is_Direct_Payment__c = false;
            
                update payment;
            }
            catch (QueryException e) {
                Database.rollback(sp);
                PageReference ref = new pagereference('/' + payment.id);
                ref.setRedirect(true);
                return ref;
            }
        }
        else if(actionType == 'ConvertToTnE'){
            try {
                payment.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_T_E_Payment');
                payment.ASI_MFM_OCR__c = false;
                payment.ASI_MFM_Is_Direct_Payment__c = false;
				/*[WL 1.0 Begin]*/
				payment.ASI_MFM_Status__c = 'Manually Processed';
				/*[WL 1.0 End]*/
                
                update payment;
            }
            catch (QueryException e) {
                Database.rollback(sp);
                PageReference ref = new pagereference('/' + payment.id);
                ref.setRedirect(true);
                return ref;
            }
        }
        
        PageReference ref = new pagereference('/' + payment.id);
        ref.setRedirect(true);
        return ref;
    }
    
    private ASI_MFM_Payment__c retrievePaymentHeader(ID paymentID ){
        ASI_MFM_Payment__c header =  new ASI_MFM_Payment__c();
        Map<String, Schema.SObjectField> paymentFieldMap = Schema.SObjectType.ASI_MFM_Payment__c.fields.getMap();
        String theQuery = 'Select ';
            
        for(String fields  : paymentFieldMap.keySet()){
            theQuery += fields + ' ,';
        }
             
        thequery = theQuery.subString(0,theQuery.length()-1);
        thequery += ', recordtype.developername, owner.name, createdby.name ' +
        ' From ASI_MFM_Payment__c where  ID = ' + '\'' + paymentID + '\' ';
         
        List<ASI_MFM_Payment__c> paymentList = (List<ASI_MFM_Payment__c>)Database.query(theQuery); 
        if (paymentList.size() > 0) {
            header = paymentList.get(0);
        }
        return header;
    
    }
    
}