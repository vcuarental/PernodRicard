public class ASI_MFM_CN_RentalRequestNewPayment {

    Public String contractId {Get; Set;}
    Public ASI_MFM_Rental_Request_Line__c header {Get; Set;}
    Public Boolean allowCreatePayment {Get; Set;}{allowCreatePayment = True;}
    
    public ASI_MFM_CN_RentalRequestNewPayment(apexPages.StandardController stdc){
        
        contractId = ApexPages.currentPage().getParameters().get('id');
        
        if(contractId != Null && contractId != ''){
            header = [SELECT id
                      , ASI_MFM_Rental_Request__c
                      , ASI_MFM_Rental_Request__r.ASI_MFM_BU__c
                      , ASI_MFM_Rental_Request__r.ASI_MFM_Department__c
                      , ASI_MFM_ExpenseType__c
                      , ASI_MFM_Completion__c
                      , ASI_MFM_Rental_Request__r.ASI_MFM_Status__c
                      , ASI_MFM_Tax_Code__c
                      , ASI_MFM_Apply_CIP_Logic__c
                      FROM ASI_MFM_Rental_Request_Line__c
                      WHERE id = : contractId
                     ];
            
            if(header.ASI_MFM_Apply_CIP_Logic__c && header.ASI_MFM_Completion__c){
                for(ASI_MFM_Payment__c obj : [SELECT id, ASI_MFM_Completion__c, ASI_MFM_ETL__c FROM ASI_MFM_Payment__c WHERE ASI_MFM_Dummy_Payment__c = False AND ASI_MFM_Contract__c = : contractId AND (ASI_MFM_ETL__c = False OR ASI_MFM_Completion__c = True)]){
                    
                    if(obj.ASI_MFM_Completion__c){
                        allowCreatePayment = True;
                        Break;
                    }
                    
                    if(!obj.ASI_MFM_ETL__c && !obj.ASI_MFM_Completion__c){
                        allowCreatePayment = False;
                    }
                }
            }
        }
    }
    
    public pageReference redirectToPayment(){
        
        if(!allowCreatePayment){
            
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , '請和當地財務聯繫，上次付款還未進行處理'));
            
            Return Null;
        }else if(header != Null && contractId != Null && contractId != ''){
            
            /*if(header.ASI_MFM_Rental_Request__r.ASI_MFM_Status__c != 'Final'){
                apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'Error'));
                Return null;
            }*/
            
            PageReference redirect = new PageReference('/apex/ASI_MFM_CN_StructureCostPrefix_Page');
	        redirect.getParameters().put('contractid', contractId);
            redirect.getParameters().put('bu', header.ASI_MFM_Rental_Request__r.ASI_MFM_BU__c);
            redirect.getParameters().put('department', header.ASI_MFM_Rental_Request__r.ASI_MFM_Department__c);
            redirect.getParameters().put('expensetype', header.ASI_MFM_ExpenseType__c);
            redirect.getParameters().put('completion', String.valueOf(header.ASI_MFM_Completion__c));
            redirect.getParameters().put('taxCode', header.ASI_MFM_Tax_Code__c);
            
        	Return redirect;//new pageReference('/apex/ASI_MFM_CN_StructureCostPrefix_Page?contractid=' + contractId + '&bu=' + header.ASI_MFM_Rental_Request__r.ASI_MFM_BU__c + '&department=' + header.ASI_MFM_Rental_Request__r.ASI_MFM_Department__c + '&expensetype=' + header.ASI_MFM_ExpenseType__c);
        }else
            Return Null;
    }
}