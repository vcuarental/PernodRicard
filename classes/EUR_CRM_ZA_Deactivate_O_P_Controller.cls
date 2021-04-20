public class EUR_CRM_ZA_Deactivate_O_P_Controller{

    public Pagereference deactivateOP(){
        String d = ApexPages.currentPage().getParameters().get('id'); 
        PageReference pr = null;
        if(d != null){
            try{
                update (new EUR_CRM_ObjPromo__c(id = d, EUR_CRM_Status__c = 'Deactivated'));
            }catch(Exception e){
                system.debug('Error : ' + e);
            }
            pr = new PageReference('/'+ d);
        }else
            pr = new PageReference('/');
            
        pr.setRedirect(true);
        return pr;
    }
}