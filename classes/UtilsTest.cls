/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe que faz o teste de cobertura da classe Utils
* NAME: UtilsTest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 17/09/2012
*
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 11/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/

@isTest(SeeAllData=true)
private class UtilsTest {

    static testMethod void myUnitTest()
    {
      Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c' , 'BRA_Standard' );
      
      Utils.decodeString( 'qwe|2|descriçao|23,11|222,33', true );
      Utils.decodeString( 'qwe|3|descriçao|111,34|222,33', false );
      Utils.decodeString( 'qwe', false );
      
      //Cria Regional
	    UDC__c lUDC = new UDC__c(
	      CodDefUsuario__c = '2',
	      CodProd__c     = '01',
	      CodUs__c     = '01',
	      Internal_Id__c   = '1234',
	      RecordTypeId = idRecTypeUdc
	    );
	    insert lUDC;
      
      Utils.getCodeFromUDC( lUDC.id );
      //Id hard code colocado propositalmente
      Utils.getCodeFromUDC( '001Q000000V3O95' );
      
      Utils.getNameFromUDC( lUDC.id );
      //Id hard code colocado propositalmente
      Utils.getNameFromUDC( '001Q000000V3O95' );
      
      Utils.getIDFromUDC( '03', 'CRM', 'DF' );
      
      String lStr = Utils.getUserNameSplit( 'Usuario teste' );

      Utils.isMobileUser(UserInfo.getUserId());

      String components = 'Preço Base - Cond. Pagto com ICMS|1|112,22|116,34|116,34#Desconto PRB|1|-13,54|-14,03|-14,03#Valor NF PRB|1|98,69|102,31|102,31#Desconto Faseamento|1|0,00|0,00|0,00#Desconto FOB|1|0,00|0,00|0,00#PIS|1|1,51|1,57|1,57#COFINS|1|6,97|7,22|7,22#Valor Mercadoria|1|98,69|102,31|102,31#IPI|1|22,92|23,76|23,76#Valor Mercadoria + IPI|1|114,61|118,82|118,82#Substitução Tributaria|1|35,96|37,28|37,28#NBASE3|1|91,69|95,05|95,05#ICMS|1|11,00|11,41|11,41#Valor Total NF|1|150,57|156,10|156,10';
      Decimal price = Utils.getFlexAmount(components);

    }

    static testMethod void testIsPartOfGroup()
    {
      
      Boolean belongsToGroup = Utils.isPartOfGroup('LAT_MX_Alta_Grupos');

      system.assertEquals(false, belongsToGroup);

    }
    
}