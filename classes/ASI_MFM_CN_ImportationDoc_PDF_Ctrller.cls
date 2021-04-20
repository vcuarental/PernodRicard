public class ASI_MFM_CN_ImportationDoc_PDF_Ctrller {
    
    private final static Map<String, Schema.SObjectField> importationDoc_FIELD_MAP = Schema.SObjectType.ASI_MFM_Importation_Document__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> importationDocDetails_FIELD_MAP = Schema.SObjectType.ASI_MFM_Importation_Document_Detail__c.fields.getMap();
    
    public id headerId {set;get;}
    public ASI_MFM_Importation_Document__c importationHeader{ get; set;}{importationHeader = new ASI_MFM_Importation_Document__c();}
    Public List<ASI_MFM_Importation_Document_Detail__c> importationLines {get;set;}{importationLines = new List<ASI_MFM_Importation_Document_Detail__c>();}
    
    Public Boolean hasLine {Get; Set;}{hasLine = False;}

    public ASI_MFM_CN_ImportationDoc_PDF_Ctrller(){}
    
    public ASI_MFM_CN_ImportationDoc_PDF_Ctrller(ApexPages.StandardController controller) {
        
    }  
    
    
    // a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    public boolean init(){
        
        if(headerId != null){
            
            importationHeader = RetrieveImportationDocInfo(HeaderId);
            
            if(importationHeader != Null && importationHeader.ASI_MFM_Request_Purpose__c != Null){
                importationHeader.ASI_MFM_Request_Purpose__c = ASI_MFM_CN_StructureCostHelperClass.splitString(importationHeader.ASI_MFM_Request_Purpose__c, 20);
            }
            
            importationLines = RetrieveImportationDocDetailsInfo(headerId);
            
            if(importationLines != Null){
                
                for(ASI_MFM_Importation_Document_Detail__c obj : importationLines){
                    
                    if(obj.ASI_MFM_Remarks__c != Null)
                        obj.ASI_MFM_Remarks__c = ASI_MFM_CN_StructureCostHelperClass.splitString(obj.ASI_MFM_Remarks__c, 10);
                    
                    if(obj.ASI_MFM_Use_of_Document__c != Null)
                        obj.ASI_MFM_Use_of_Document__c = ASI_MFM_CN_StructureCostHelperClass.splitString(obj.ASI_MFM_Use_of_Document__c, 10);
                    
                    if(obj.ASI_MFM_Document_Type__c  != Null)
                        obj.ASI_MFM_Document_Type__c = ASI_MFM_CN_StructureCostHelperClass.splitString(obj.ASI_MFM_Document_Type__c , 5);
                }
                hasLine = True;
            }
        }
        return true;
    }
    
    private ASI_MFM_Importation_Document__c RetrieveImportationDocInfo(String HeaderId) {
        
        String query = 'SELECT ' + genQueryField(importationDoc_FIELD_MAP) 
            +  ' , ASI_MFM_Region__r.Name '
            + 'FROM ASI_MFM_Importation_Document__c ' 
            + 'Where Id = \''+HeaderId+'\' ';
        
        List<ASI_MFM_Importation_Document__c> importationDoc = (List<ASI_MFM_Importation_Document__c>) Database.query(query);
        
        return importationDoc.size() > 0 ? importationDoc.get(0) : null;
    }
    
    private List<ASI_MFM_Importation_Document_Detail__c>  RetrieveImportationDocDetailsInfo(String HeaderId) {
        
        String query = 'SELECT ' + genQueryField(importationDocDetails_FIELD_MAP)
            + ' , ASI_MFM_SKU_Code__r.Name, ASI_MFM_SKU_Code__r.ASI_MFM_SKU_Code__c ' 
            + 'FROM ASI_MFM_Importation_Document_Detail__c '
            + 'Where ASI_MFM_Importation_Document__c = \''+HeaderId+'\'';
        
        List<ASI_MFM_Importation_Document_Detail__c> importationDocDetails = (List<ASI_MFM_Importation_Document_Detail__c>) Database.query(query);
        
        return importationDocDetails.size() > 0 ? importationDocDetails : null;
    }
    
    
    /***************  * *  Tools Function    ***************/
    private String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for(String fields : fieldMap.keySet()) {
            queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }
}