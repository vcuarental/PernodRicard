public class ASI_MFM_GenPOPDF_Controller{

    public String Fiscal{get;set;}
        
            
    public void GenHK(){
        system.debug('Linus: Fiscal Year: ' + Fiscal);
                        
        database.executeBatch(new ASI_MFM_GenPOPDF_Batch(Fiscal, 'HK'), 50);
        
    }
    
    public void GenTR(){
        system.debug('Linus: Fiscal Year: ' + Fiscal);
        
        database.executeBatch(new ASI_MFM_GenPOPDF_Batch(Fiscal, 'TR'), 50);
    }
}