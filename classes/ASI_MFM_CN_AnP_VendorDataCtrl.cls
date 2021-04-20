public without sharing class ASI_MFM_CN_AnP_VendorDataCtrl {
    public id POID {get;set;}
    public String supplierName {get;set;}
    public List<ASI_MFM_PO__c> relatePoList {get;set;}
    public Decimal poAmount {get;set;}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public ASI_MFM_CN_AnP_VendorDataCtrl(){}
    
    public boolean init(){
        Id poRTID = Global_recordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO');
        Id poroRTID = Global_recordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO_Read_Only');
        
        Id supplierId = null;
        String eMailSubject = null;
        supplierName = '';
        List<ASI_MFM_PO__c> polist = [SELECT ASI_MFM_Supplier_Name__c,ASI_MFM_Supplier_Name__r.Name, ASI_MFM_Prefix__r.ASI_MFM_CN_eMail_Subject__c 
                                      FROM ASI_MFM_PO__c 
                                      WHERE (RecordTypeId=:poRTID OR RecordTypeId=:poroRTID)
                                      AND id = :POID
                                     ];
        if(polist!=null && polist.size()>0) {
            for(ASI_MFM_PO__c po :polist){
                supplierName = po.ASI_MFM_Supplier_Name__r.Name;
                supplierId = po.ASI_MFM_Supplier_Name__c;
                eMailSubject = po.ASI_MFM_Prefix__r.ASI_MFM_CN_eMail_Subject__c;
            }
        }
        if(supplierId==null) return false;
        Date now = Date.today();
        Date past = now.addMonths(-12);
        
        relatePoList = [SELECT id, name, ASI_MFM_PO_Start_Date__c, ASI_MFM_PO_End_Date__c, ASI_MFM_Status__c, ASI_MFM_CN_PO_Amount_RMB__c, ASI_MFM_Remarks__c,CreatedBy.name
                        FROM ASI_MFM_PO__c 
                        WHERE (RecordTypeId=:poRTID OR RecordTypeId=:poroRTID)
                        AND ASI_MFM_Supplier_Name__c=:supplierId
                        AND (ASI_MFM_Status__c LIKE 'Final' OR ASI_MFM_Status__c LIKE 'Complete' OR ASI_MFM_Status__c LIKE 'Submitted')
                        AND ASI_MFM_PO_Start_Date__c < :now
                        AND ASI_MFM_PO_End_Date__c > :past
                        AND id != :POID
                        ORDER BY ASI_MFM_PO_Start_Date__c desc
                        LIMIT 5
                       ];
        poAmount = 0;
        List<AggregateResult> aList =[SELECT SUM(ASI_MFM_CN_PO_Amount_RMB__c)amts
                                      FROM ASI_MFM_PO__c 
                                      WHERE (RecordTypeId=:poRTID OR RecordTypeId=:poroRTID)
                                      AND ASI_MFM_Supplier_Name__c=:supplierId
                                      AND (ASI_MFM_Status__c LIKE 'Final' OR ASI_MFM_Status__c LIKE 'Complete' OR ASI_MFM_Status__c LIKE 'Submitted')
                                      AND ASI_MFM_PO_Start_Date__c < :now
                                      AND ASI_MFM_PO_End_Date__c > :past
                                      AND id != :POID
                                     ];
        if(aList!= null && aList.size() > 0){ 
        for(AggregateResult agg:aList){
            poAmount=(Decimal)agg.get('amts'); 
        } 
    }

        
        
        return true;
    }

}