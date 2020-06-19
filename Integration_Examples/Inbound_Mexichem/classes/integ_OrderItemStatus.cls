public with sharing class integ_OrderItemStatus implements IFormulaField {
	public Object resolve(IntegrationMapItem__c item, Map<String, Object> externalDataMap) {
        String aux = (String)externalDataMap.get(item.ExternalFieldNameTxt__c);
        String fatAmtStr = (String)externalDataMap.get('RFMNG');
        Decimal fatAmt = fatAmtStr != null ? Decimal.valueOf(fatAmtStr.trim()) : 0;
        String orderStatus = (String)externalDataMap.get('STATV2');
        if(orderStatus == 'Processado completamente') return 'ENTREGUE';
        if(fatAmt != 0) return 'FATURADO';
        if(aux == 'REPOSIÇÃO' || aux == 'REPOSICAO' || aux == 'SUBSTITUICAO' || aux == 'SUBSTITUIÇÃO') return null;
        return aux;
	}
}