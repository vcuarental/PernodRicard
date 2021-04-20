/************************
 * Create Date: 2017-06-14
 * Create By: Linus@Introv
 * Function: Update the Invoice Date and Invoice number when Payment is submitted (For Finance use only)
 * 
*************************/ 
public class ASI_MFM_JP_ReviseInvoiceDetailController {
    
    public Boolean access {get;set;}    
    public ASI_MFM_Payment__c payment {get;set;}        
        
    public List<ASI_MFM_Payment_Line_Item__c> plineList = new List<ASI_MFM_Payment_Line_Item__c>();
    
    public ASI_MFM_JP_ReviseInvoiceDetailController(apexpages.standardController sc){
        payment = [Select id, ASI_MFM_Invoice_Number__c, ASI_MFM_Invoice_Date__c, ASI_MFM_Payment_Term__c, ASI_MFM_JP_Payment_Date__c from ASI_MFM_Payment__c where id = :sc.getId()];
    }
    
    public Date CalLastDayOfMonth (string terms, date currentDate){
        integer year;
        integer month;        
        date newPaymentDate;
        
        boolean isCal;
        
        if(currentDate != null){        
            if(terms == '301'){
                isCal = true;
                if(currentDate.month() == 12){
                    month = 2;
                    year = currentDate.year() + 1;
                }else if(currentDate.month() == 11){
                    month = 1;
                    year = currentDate.year() + 1;
                }else{
                    month = currentDate.month() + 2;
                    year = currentDate.year();
                }                            
            }else if(terms == '601'){
                isCal = true;            
                if(currentDate.month() == 12){
                    month = 3;
                    year = currentDate.year() + 1;
                }else if(currentDate.month() == 11){
                    month = 2;
                    year = currentDate.year() + 1;
                }else if(currentDate.month() == 10){
                    month = 1;
                    year = currentDate.year() + 1;
                }else{
                    month = currentDate.month() + 3;
                    year = currentDate.year();
                }  
            }else if(terms == '902'){
                isCal = true;                
                if(currentDate.month() == 12){
                    month = 4;
                    year = currentDate.year() + 1;
                }else if(currentDate.month() == 11){
                    month = 3;
                    year = currentDate.year() + 1;
                }else if(currentDate.month() == 10){
                    month = 2;
                    year = currentDate.year() + 1;
                }else if(currentDate.month() == 9){
                    month = 1;
                    year = currentDate.year() + 1;
                }else{
                    month = currentDate.month() + 4;
                    year = currentDate.year();
                }                          
            }else{
                // for other payment term, Payment Date will be equal to Invoice Date
                isCal = false;
            }
            return newPaymentDate = isCal == true? Date.newInstance(year, month, 1) - 1 : currentDate;
        }else
            return null;
    }
    
    public pageReference init(){
        
        Id user_id;
        Id p_id;
        List<PermissionSetAssignment> permissionSet = new List<PermissionSetAssignment>();
                
        user_id = apexpages.currentPage().getParameters().get('userid');    
        
        permissionSet = [Select PermissionSet.Id from PermissionSetAssignment where Assigneeid = :user_id and PermissionSet.Name = 'ASI_MFM_JP_Accounting_User' limit 1];
        system.debug('Permission Set: ' + permissionSet);
 
        if(permissionSet.size() != 0){
            access = true;              
        }else{
            access = false;
            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Only Accounting User can set Invoice Date and Invoice Number after submission'));
            return null;
        }
        return null;
    }

    public pageReference save(){
        
        date newPaymentDate;  system.debug('Payment term: ' + payment.ASI_MFM_Payment_Term__c);  system.debug('Invoice number: ' + payment.ASI_MFM_Invoice_Number__c);
        List<String> termSplit = payment.ASI_MFM_Payment_Term__c != null ? payment.ASI_MFM_Payment_Term__c.split(' '): new List<String>();  
        String terms = termSplit.size() != 0 ? termSplit[termSplit.size() - 1] : '999';
        
        plineList = [Select id, ASI_MFM_Invoice_Date__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Payment_Date__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :payment.id];
        system.debug('Terms: ' + termSplit[termSplit.size() - 1]); system.debug(payment.ASI_MFM_Invoice_Date__c);
        
        newPaymentDate = CalLastDayOfMonth(terms, payment.ASI_MFM_Invoice_Date__c);  // get Calculated Date
        system.debug('New Payment Date: ' + newPaymentDate);
        payment.ASI_MFM_JP_Payment_Date__c = newPaymentDate;
               
        // update the Invoice Number, Invoice Date, Payment Date of PO line
        for(ASI_MFM_Payment_Line_Item__c pline: plinelist){
            pline.ASI_MFM_Invoice_Number__c = payment.ASI_MFM_Invoice_Number__c;
            pline.ASI_MFM_INvoice_Date__c = payment.ASI_MFM_Invoice_Date__c;         
            // If Payment Date is blank, then use calculated Date. Otherwise, just keep the input Date   
            pline.ASI_MFM_Payment_Date__c = pline.ASI_MFM_Payment_Date__c != null ? newPaymentDate: pline.ASI_MFM_Payment_Date__c;
        }
        
        if(!Test.isRunningtest()){
            update payment;
            update plinelist;
        }
        return new pageReference('/' + payment.id);
    }
}