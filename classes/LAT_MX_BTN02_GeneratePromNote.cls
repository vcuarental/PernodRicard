/*************************************************************************************************************************
*   Company:Valuenet    Developers:   Elena J. Schwarzböck                                                               *                                                                                      *
*   Date:26/09/2013     Descripcion: Genera el pagare en formato PDF                                                     *
**************************************************************************************************************************/

global with sharing class LAT_MX_BTN02_GeneratePromNote {
    
    webService static String GeneratePromNote(String idPagare){
		LAT_MX_PMN_PromissoryNote__c pagare = [SELECT Id, Name FROM LAT_MX_PMN_PromissoryNote__c WHERE Id =: idPagare];
        
        PageReference pdf = Page.LAT_MX_VFP01_GeneratePromNote;
        pdf.getParameters().put('idPagare',pagare.Id);
        Attachment attach = new Attachment();
        Blob body = !Test.isRunningTest() ? pdf.getContent() : Blob.ValueOf('dummy text');
        DateTime d = DateTime.now() ;
        attach.Name = 'Form04- Pagaré N°' + pagare.Name + ' - ' + d.format('dd/MM/yy') + '.pdf';
        attach.Body = body;
        attach.IsPrivate = false;
        attach.ParentId = pagare.Id;
        insert attach;
        
        return null;
    }
}