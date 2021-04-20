/********************************
 * Created by: Linus @Introv    
 * Created Date: 2017-12-22
 * Objective: get PO PDF and save as attachment to PO
 * Module: MFM HK and MFM TR
******************************/
public class ASI_MFM_SavePDFAsAttachment{
@future(callout=true)

    public static void savePDF(String PO_Id, String PO_Name, String Country){

        PageReference pdf = Country == 'HK' ? Page.ASI_MFM_HK_PO_PDF_Page: Page.ASI_MFM_TR_PO_PDF_Page;        
        pdf.getParameters().put('id', PO_Id);
        pdf.setRedirect(true);
                
        Attachment att = new Attachment();
                
        Blob body;
        String debugText;
        try{
            body = pdf.getContent();            
        }catch (VisualforceException e){
            body = Blob.valueOf('Error');   
            System.debug('Error: ' + e.getMessage());                                         
        }
                
        att.Name = PO_Name + '_' + System.today().year() + '_' + System.today().month() + '_' + System.today().day() + '.pdf';
        att.body = body;
        att.IsPrivate = false;
        att.Parentid = PO_id;
        
        if(!Test.isRunningTest())
            insert att;
    }
}