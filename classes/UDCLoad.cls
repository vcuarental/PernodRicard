/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
* Responsável por criar e recuperar UDC__c.
* NAME: UDCLoad.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 
*
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 11/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/
global class UDCLoad {
   
    private static Id idRecTypeUdc = RecordTypeForTest.getRecType( 'UDC__c' , 'BRA_Standard' );
    webService static String[] ETL_UDCLoad(Integer country, String codigoModulo,String codigoLista, String idItem, String description, String codDefUser) 
    {
    	
        UDC__c udc = crateUDC(codigoModulo, codigoLista,idItem, description, codDefUser);
        return new String[]{udc.CodProd__c, udc.CodUs__c, udc.Name,udc.Descricao2__c,udc.CodDefUsuario__c};
        
    }
    
    private static UDC__c crateUDC(String codigoModulo,String codigoLista, String idItem, String description, String codDefUser)
    {
    	
        UDC__c udc;
        String lIntId = codDefUser + codigoModulo + codigoLista;
        List<UDC__c> udcList = [ SELECT CodProd__c, CodUs__c,Name, Descricao2__c, CodDefUsuario__c 
            FROM UDC__c WHERE Internal_id__c =:lIntId AND RecordTypeId =: idRecTypeUdc limit 1];
            
        if (udcList.size()==0)
            udc = new UDC__c(Internal_Id__C=lIntId);
        else
          udc = udcList.get(0); 
        udc.CodDefUsuario__c = codDefUser;
        udc.CodProd__c = codigoModulo;
        udc.CodUs__c=codigoLista;
        udc.Name = idItem;
        udc.Descricao2__c=description;        
        upsert udc;
        return udc;
        
    }    
}