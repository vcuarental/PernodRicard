public with sharing class ASI_MFM_EditSmallAmountPaymentP2_Ctrl {
    
    public String poid{set;get;}
    public String paid{set;get;}
    public ASI_MFM_Payment__c payment{get;set;}
    
    public ASI_MFM_EditSmallAmountPaymentP2_Ctrl() {
        poid = ApexPages.CurrentPage().getParameters().get('poid');
        paid = ApexPages.CurrentPage().getParameters().get('paid');
    }
    
    public void init(){
        /*
        ASI_MFM_PO__c po = [select ASI_MFM_PO_Type__c from ASI_MFM_PO__c where id = :poid];
        payment = [select Name, ASI_MFM_Is_AMEX_Payment__c, ASI_MFM_G_L_Date__c from ASI_MFM_Payment__c where id = :paid];
        
        List<ASI_MFM_PO_Line_Item__c> poLines = [select ASI_MFM_Amount__c, (select id from ASI_MFM_PO_Line_Item__c.PO_Receipt_Items__r) from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c = :poid];
        
        if (poLines.size() > 0){
            System.debug('Size of Receipt Item of PO Line: ' + poLines.get(0).PO_Receipt_Items__r.size());
            
            //Only create Receipt if there are no existing receipt item child of the PO Line
            if (poLines.get(0).PO_Receipt_Items__r.size() == 0){
                ASI_MFM_PO_Receipt__c rec = new ASI_MFM_PO_Receipt__c();
               
                rec.ASI_MFM_Receipt_Date__c = payment.ASI_MFM_G_L_Date__c;
                rec.ASI_MFM_Status__c = 'Final';
                rec.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_GF_PO_Receipt_Read_Only');
                rec.ASI_MFM_Is_AMEX_Receipt__c = payment.ASI_MFM_Is_AMEX_Payment__c;
                
                insert rec; 
                
                List<ASI_MFM_PO_Receipt_Item__c> recLines = new List<ASI_MFM_PO_Receipt_Item__c>();
                
                for (ASI_MFM_PO_Line_Item__c poLine:poLines){
                    ASI_MFM_PO_Receipt_Item__c recLine = new ASI_MFM_PO_Receipt_Item__c();
                    
                    recLine.ASI_MFM_PO_Receipt__c = rec.id;
                    recLine.ASI_MFM_PO_Line_Item__c = poLine.id;
                    recLine.ASI_MFM_PO__c = po.id;
                    recLine.ASI_MFM_Amount__c = poLine.ASI_MFM_Amount__c;
                    recLine.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_GF_PO_Receipt_item');
                    
                    recLines.add(recLine);
                }
                
                insert recLines;
            }
        }*/
    }
    
    public PageReference ViewPayment() {        
        return new PageReference('/' + this.paid); 
    }
}