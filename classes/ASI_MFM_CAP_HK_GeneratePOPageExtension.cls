/***************************************************************************************************************************
 * Name:        ASI_MFM_CAP_HK_GeneratePOPageExtension
 * Description: Extension Class to manually generate PO in related list of Plan Line in Plan 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-10-05       Laputa (Hector)         Created
 ****************************************************************************************************************************/
 
public with sharing class ASI_MFM_CAP_HK_GeneratePOPageExtension {
    private List<ASI_MFM_Plan_Line_Item__c> selectedPlanLineItems = new List<ASI_MFM_Plan_Line_Item__c>();
    //private List<ASI_MFM_Plan_Line_Item__c> selectedPlanLineItems ;
    private string retURL = '';
    public Boolean showError {get;set;}{showError = false;}
    public String ErrorMessage {get;set;}
    
    public ASI_MFM_CAP_HK_GeneratePOPageExtension(ApexPages.StandardController controller){
        if(controller.getRecord().getSObjectType() == ASI_MFM_Plan_Line_Item__c.SObjectType) {
            selectedPlanLineItems.add((ASI_MFM_Plan_Line_Item__c)controller.getRecord());
        }
        
    }
    
    public ASI_MFM_CAP_HK_GeneratePOPageExtension(ApexPages.StandardSetController controller){
        if(controller.getRecord().getSObjectType() == ASI_MFM_Plan_Line_Item__c.SObjectType) {
            selectedPlanLineItems = controller.getSelected();
        }
    }
    
    
    public PageReference generatePOFromPage(){
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        if(retURL == null) {
            retURL = '/';
        }
        system.debug('retURL:' + retURL);
        
        try{
            ASI_MFM_CAP_HK_POGeneration.GenerateHKPOFromPlanLineByType(selectedPlanLineItems);
        } catch (DmlException  edml){ApexPages.addMessage(ExtractMessage(edml));return null;}
        catch (Exception  e){ApexPages.addMessage(ExtractMessage(e));return null;}
        return new PageReference(retURL);
    }
    
    public static ApexPages.Message ExtractMessage(DmlException e){
        string innerMsg = e.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,', ': []');
        ApexPages.Message msg;
        if(innerMsg != null){
            msg = new ApexPages.Message(Apexpages.Severity.ERROR,innerMsg );
        }else{
            msg = new ApexPages.Message(Apexpages.Severity.ERROR, e.getdmlMessage(0));
        }
        return msg;
    }
    
    public static  ApexPages.Message ExtractMessage(Exception e){
        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, e.getMessage()) ;
        return msg;
    }

    public PageReference back(){
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        if(retURL == null) {
            retURL = '/';
        }
        return new PageReference(retURL);
    }

}