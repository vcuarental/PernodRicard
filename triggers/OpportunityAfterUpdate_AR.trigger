/**********************************************
 Dev: Juan Pablo Cubo       Version: 1
**********************************************/

trigger OpportunityAfterUpdate_AR on Opportunity (after update) {

    for (Opportunity opp : trigger.new) {
    	if  (WS03_SalesOrderHandlerInterface_AR.isProcessing == null) {
    		WS03_SalesOrderHandlerInterface_AR.isProcessing = false;
    	}
        if (!WS03_SalesOrderHandlerInterface_AR.isProcessing &&
            (opp.StageName == 'Pedido con descuento aprobado' || opp.StageName == 'Approved' || opp.StageName == 'Mobile Order')
            && opp.StageName != trigger.oldMap.get(opp.Id).StageName) {
            WS03_SalesOrderHandlerInterface_AR.SalesOrderInterfaceFuture(opp.Id);
            WS03_SalesOrderHandlerInterface_AR.isProcessing = true;
        }
    }
	   
}