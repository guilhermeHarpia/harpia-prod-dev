public with sharing class integ_CustomOperationOrderItem implements integ_IIntegrationOperation {
	
	public Object execute(List<SObject> recordList) {
        System.debug(LoggingLevel.INFO, '*** integ_CustomOperationOrderItem::execute() ' + recordList);
		List<OrderItem__c> orderItemList = new List<OrderItem__c>();        
		orderItemList.addAll((List<OrderItem__c>)recordList);
        //ALTERADO - Paulo
        List<OrderItem__c> orderItemListAlterada = new List<OrderItem__c>();
        for(OrderItem__c item: orderItemList){
            //VERIFICA SE TEM ALGO PREENCHIDO NO ORDERMDT__C
            if(item.OrderMdt__c != null){
                //VERIFICA SE O ID SETADO NO CAMPO É DO TIPO ID DO SF
                if(!Pattern.compile( '[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ).matcher( item.OrderMdt__c ).matches()){
                    system.debug('não é sf');
                    //INSTANCIA UM ORDERITEM COM AS MESMAS INFORMAÇÕES, MAS SEM O OrderMdt__c (QUE VEM COM ID INVÁLIDO)
                    OrderItem__c novoItem = new OrderItem__c();
                    novoItem.CenterTxt__c=item.CenterTxt__c;
                    novoItem.LiquidNmb__c=item.LiquidNmb__c;
                    novoItem.WarehouseTxt__c=item.WarehouseTxt__c;
                    novoItem.OrderQuantityNmb__c=item.OrderQuantityNmb__c;
                    novoItem.OriginalQuantityNmb__c=item.OrderQuantityNmb__c;
                    novoItem.InvoiceAmountNmb__c = item.InvoiceAmountNmb__c;
                    novoItem.InvoiceDateDte__c = item.InvoiceDateDte__c;
                    novoItem.ItemNumberTxt__c = item.ItemNumberTxt__c;
                    novoItem.ZGAB__c = item.ZGAB__c;
                    novoItem.UMTxt__c=item.UMTxt__c;
                    novoItem.ExpeditionPointTxt__c=item.ExpeditionPointTxt__c;
                    novoItem.ClientMaterialTxt__c=item.ClientMaterialTxt__c;
                    novoItem.TotalGrossCostNmb__c=item.TotalGrossCostNmb__c;
                    novoItem.Remittance1DateDte__c=item.Remittance1DateDte__c;
                    novoItem.LucreCenterTxt__c=item.LucreCenterTxt__c;
                    novoItem.RejectionReasonTxt__c=item.RejectionReasonTxt__c;
                    novoItem.CFOPTxt__c=item.CFOPTxt__c;
                    novoItem.ItineraryTxt__c=item.ItineraryTxt__c;
                    novoItem.RemittanceGroupTxt__c=item.RemittanceGroupTxt__c;
                    novoItem.PaymentConditionTxt__c=item.PaymentConditionTxt__c;
                    novoItem.CustomIDTxt__c=item.CustomIDTxt__c;
                    novoItem.SyncedSAPBln__c = true;
                    novoItem.BX13__c = item.BX13__c;
                    novoItem.BX23__c = item.BX23__c;
                    novoItem.BX41__c = item.BX41__c;
                    novoItem.OriginalROBNoIPINmb__c = item.TotalGrossCostNmb__c - (item.BX41__c != null ? item.BX41__c : 0) - (item.BX23__c != null ? item.BX23__c : 0);
                    //SETA O OrderMdt__r COM O ID EXTERNO RETORNADO, DESSA FORMA O SF ASSOCIA DA MANEIRA CERTA
                    novoItem.OrderMdt__r = new Order__c(CustomIDTxt__c =item.OrderMdt__c);
                    //[LGrillo]: 29/01/2018
                    novoItem.ProductLkp__r = new Product2(ProductCodeTxt__c = item.ProductLkp__r.ProductCodeTxt__c);
                    if(item.CarrierLkp__r != null) novoItem.CarrierLkp__r = new Carrier__c(CodeCarrierTxt__c = item.CarrierLkp__r.CodeCarrierTxt__c);
                    novoItem.StatusTxt__c = item.StatusTxt__c;
                    orderItemListAlterada.add(novoItem);
                }else{
                    system.debug('é id sf');
                    orderItemListAlterada.add(item);
                }
            }            
        }
        SkipValidations__c skipVal = SkipValidations__c.getOrgDefaults();
        try{
            skipVal.Skip__c = true;
            update skipVal;
        }
        catch(exception e){
            system.debug(e.getMessage());
        }
        
		upsert orderItemListAlterada CustomIDTxt__c;
        
        try{
            skipVal.Skip__c = false;
            update skipVal;
        }
        catch(exception e){
            system.debug(e.getMessage());
        }
        
		return orderItemListAlterada;
	}
	
}